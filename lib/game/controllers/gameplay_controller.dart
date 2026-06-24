import '../../game_core/game_core.dart';
import '../config/prototype_gameplay_config.dart';
import '../services/gameplay_audio_service.dart';
import '../services/gameplay_haptic_service.dart';
import 'gate_animation_controller.dart';
import 'input_controller.dart';

class GameplayController {
  GameplayController({
    required GameState initialState,
    this.config = const PrototypeGameplayConfig(),
    this.moveValidator = const MoveValidator(),
    this.reducer = const GameStateReducer(),
    TapBufferSystem? tapBufferSystem,
    GateAnimationController? gateController,
    InputController? inputController,
    this.audio = const NoopGameplayAudioService(),
    this.haptics = const NoopGameplayHapticService(),
  }) : state = initialState,
       tapBufferSystem = tapBufferSystem ?? TapBufferSystem(config.timing),
       gateController = gateController ?? GateAnimationController(config: config),
       inputController = inputController ?? InputController();

  GameState state;
  final PrototypeGameplayConfig config;
  final MoveValidator moveValidator;
  final GameStateReducer reducer;
  final TapBufferSystem tapBufferSystem;
  final GateAnimationController gateController;
  final InputController inputController;
  final GameplayAudioService audio;
  final GameplayHapticService haptics;
  TapResult? lastResult;
  bool queuedGateTick = false;
  TapAttempt? _pendingAttempt;

  bool get inputLocked => inputController.isLocked;
  bool get isComplete => state.phase == GamePhase.levelComplete;
  bool get isFailed => state.phase == GamePhase.levelFailed;
  bool get hasBufferedAttempt => _pendingAttempt != null;

  TapResult handleArrowTap(
    String arrowId,
    int timestampMs, {
    GateTimingSnapshot timing = const GateTimingSnapshot.stable(),
  }) {
    if (!inputController.tryLock()) {
      final result = TapResult(
        TapResultType.invalidGamePhase,
        TapDebugInfo(arrowId: arrowId, tapTimestampMs: timestampMs),
      );
      lastResult = result;
      return result;
    }

    audio.play(GameplayAudioEvent.arrowTap);
    haptics.trigger(GameplayHapticEvent.arrowTap);
    final attempt = TapAttempt(arrowId: arrowId, timestampMs: timestampMs);
    final result = moveValidator.validate(
      state: state,
      attempt: attempt,
      timingDecision: tapBufferSystem.evaluate(
        timing: timing,
        tapTimestampMs: timestampMs,
      ),
    );
    lastResult = result;
    if (result.type == TapResultType.validExit) {
      state = reducer.applyTapResult(state, result);
    } else if (result.type == TapResultType.tapBuffered) {
      _pendingAttempt = attempt;
    } else {
      _applyInvalidResult(result);
    }
    return result;
  }

  TapResult? resolveBufferedTap(GateTimingSnapshot timing) {
    final attempt = _pendingAttempt;
    if (attempt == null) {
      return null;
    }
    _pendingAttempt = null;
    final result = moveValidator.validate(
      state: state,
      attempt: attempt,
      timingDecision: tapBufferSystem.evaluate(
        timing: timing,
        tapTimestampMs: attempt.timestampMs,
      ),
    );
    lastResult = result;
    if (result.type == TapResultType.validExit) {
      state = reducer.applyTapResult(state, result);
    } else {
      _applyInvalidResult(result);
    }
    return result;
  }

  void commitValidExit(String arrowId) {
    state = reducer.resolveValidMove(
      state.copyWith(phase: GamePhase.arrowLaunching),
      arrowId,
    );
    audio.play(
      state.phase == GamePhase.levelComplete
          ? GameplayAudioEvent.levelComplete
          : GameplayAudioEvent.validExit,
    );
    haptics.trigger(GameplayHapticEvent.validExit);
    inputController.unlock();
    if (queuedGateTick && state.phase == GamePhase.ready) {
      queuedGateTick = false;
      rotateGates();
    }
  }

  void _applyInvalidResult(TapResult result) {
    final penalized = switch (result.type) {
      TapResultType.pathBlocked ||
      TapResultType.noGateAligned ||
      TapResultType.wrongGateColor ||
      TapResultType.gateLocked ||
      TapResultType.tapTooEarly ||
      TapResultType.tapTooLate => true,
      TapResultType.validExit ||
      TapResultType.invalidGamePhase ||
      TapResultType.tapBuffered ||
      TapResultType.arrowNotFound => false,
    };
    if (penalized) {
      state = reducer.applyTapResult(state, result);
      audio.play(GameplayAudioEvent.lifeLost);
      haptics.trigger(GameplayHapticEvent.lifeLost);
    }
    inputController.unlock();
  }

  void rotateGates() {
    if (state.phase == GamePhase.arrowLaunching ||
        state.phase == GamePhase.resolvingEffects) {
      queuedGateTick = true;
      return;
    }
    if (state.phase != GamePhase.ready) {
      return;
    }
    state = state.copyWith(
      lanes: gateController.nextLanes(state.lanes),
      phase: GamePhase.ready,
    );
    audio.play(GameplayAudioEvent.gateRotationTick);
  }

  void pause() {
    state = reducer.pause(state);
  }

  void resume() {
    state = reducer.resume(state);
  }

  void restart(GameState newState) {
    state = newState;
    queuedGateTick = false;
    lastResult = null;
    _pendingAttempt = null;
    inputController.unlock();
  }
}
