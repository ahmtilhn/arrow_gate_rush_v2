import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

import '../game_core/game_core.dart';
import 'bootstrap/game_asset_loader.dart';
import 'bootstrap/prototype_level.dart';
import 'components/arrows/arrow_tile_component.dart';
import 'components/background/garden_background_component.dart';
import 'components/board/board_grid_component.dart';
import 'components/debug/visual_debug_overlay_component.dart';
import 'components/effects/blocked_path_effect_component.dart';
import 'components/effects/gate_alignment_glow_component.dart';
import 'components/effects/gate_burst_component.dart';
import 'components/effects/wrong_tap_effect_component.dart';
import 'components/gates/gate_lane_component.dart';
import 'components/hud/gameplay_hud_component.dart';
import 'config/prototype_gameplay_config.dart';
import 'controllers/gameplay_controller.dart';
import 'layout/board_layout_calculator.dart';
import 'layout/gameplay_layout.dart';
import 'mapping/core_to_flame_mapper.dart';
import 'qa/phase2_qa_mode.dart';

class ArrowGateGame extends FlameGame {
  ArrowGateGame({
    required this.initialBundle,
    GameAssetLoader? assetLoader,
    GameplayController? controller,
    this.config = const PrototypeGameplayConfig(),
    this.debugLevel = false,
    this.qaMode = Phase2QaMode.normal,
  }) : assetLoader = assetLoader ?? GameAssetLoader(),
       controller = controller ??
           GameplayController(initialState: initialBundle.gameState);

  final PrototypeLevelBundle initialBundle;
  final GameAssetLoader assetLoader;
  final GameplayController controller;
  final PrototypeGameplayConfig config;
  final bool debugLevel;
  final Phase2QaMode qaMode;

  late GameplayLayout layout;
  late CoreToFlameMapper mapper;
  late GameplayHudComponent hud;
  final arrowComponents = <String, ArrowTileComponent>{};
  final gateLaneComponents = <GateEdge, GateLaneComponent>{};
  double gateCountdown = 0;
  bool isGameplayReady = false;
  bool _gateVisualMovement = false;
  GateTimingSnapshot _gateTiming = const GateTimingSnapshot.stable();

  int get activeArrowCount => controller.state.board.arrows.values
      .where((arrow) => !arrow.exited)
      .length;

  @override
  Future<void> onLoad() async {
    await GameAssetLoader(
      images: images,
      arrowResolver: assetLoader.arrowResolver,
      gateResolver: assetLoader.gateResolver,
    ).preload();
    layout = const BoardLayoutCalculator().calculate(
      screenSize: size,
      gridSize: controller.state.board.rows,
    );
    mapper = CoreToFlameMapper(layout);
    await add(GardenBackgroundComponent()..priority = 0);
    await add(
      BoardGridComponent(board: controller.state.board, layout: layout)
        ..priority = 10,
    );
    await _addArrows();
    await _addGates();
    hud = GameplayHudComponent(
      lives: controller.state.lives,
      screenSize: size,
    )..priority = 50;
    await add(hud);
    gateCountdown = config.gateInterval.inMilliseconds / 1000;
    isGameplayReady = true;
    if (debugLevel) {
      await _refreshDebug();
    }
    unawaited(_prepareReviewState());
  }

  Future<void> _addArrows() async {
    for (final arrow in controller.state.board.arrows.values) {
      if (arrow.exited) {
        continue;
      }
      final component = ArrowTileComponent(
        arrow: arrow,
        position: mapper.cellCenter(arrow.position),
        cellSize: layout.cellSize,
      )..priority = 20;
      arrowComponents[arrow.id] = component;
      await add(component);
    }
  }

  Future<void> _addGates() async {
    for (final lane in controller.state.lanes.values) {
      final component = GateLaneComponent(lane: lane, layout: layout)
        ..priority = 30;
      gateLaneComponents[lane.edge] = component;
      await add(component);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isGameplayReady ||
        _gateVisualMovement ||
        controller.state.phase != GamePhase.ready) {
      return;
    }
    gateCountdown -= dt;
    if (gateCountdown <= 0) {
      gateCountdown = config.gateInterval.inMilliseconds / 1000;
      unawaited(rotateGates());
    }
  }

  Future<void> rotateGates() async {
    if (_gateVisualMovement || controller.state.phase != GamePhase.ready) {
      return;
    }
    _gateVisualMovement = true;
    final startMs = DateTime.now().millisecondsSinceEpoch;
    final commitMs = startMs + config.gateSlideDuration.inMilliseconds;
    _gateTiming = GateTimingSnapshot(
      state: GateTimingState.visuallyMoving,
      rotationStartMs: startMs,
      commitMs: commitMs,
    );
    controller.rotateGates();
    await Future.wait([
      for (final entry in controller.state.lanes.entries)
        gateLaneComponents[entry.key]!.animateTo(
          entry.value,
          config.gateSlideDuration,
        ),
    ]);
    _gateTiming = GateTimingSnapshot(
      state: GateTimingState.rotationCommitted,
      rotationStartMs: startMs,
      commitMs: commitMs,
    );
    _gateVisualMovement = false;

    final bufferedResult = controller.resolveBufferedTap(_gateTiming);
    if (bufferedResult != null) {
      _renderTapResult(bufferedResult.debug.arrowId, bufferedResult);
    }

    await _refreshDebug();
    await Future<void>.delayed(config.timing.gateTapBuffer);
    if (_gateTiming.commitMs == commitMs) {
      _gateTiming = const GateTimingSnapshot.stable();
    }
  }

  void handleArrowTap(String arrowId) {
    if (!isGameplayReady || controller.inputLocked) {
      return;
    }
    final result = controller.handleArrowTap(
      arrowId,
      DateTime.now().millisecondsSinceEpoch,
      timing: _gateTiming,
    );
    _renderTapResult(arrowId, result);
  }

  void _renderTapResult(String arrowId, TapResult result) {
    final component = arrowComponents[arrowId];
    switch (result.type) {
      case TapResultType.validExit:
        final target = mapper.gateSlotCenter(
          result.debug.expectedEdge!,
          result.debug.expectedSlotIndex!,
        );
        component?.launchTo(target, () {
          component.removeFromParent();
          arrowComponents.remove(arrowId);
          add(
            GateBurstComponent(
              position: target,
              size: layout.cellSize * 1.5,
            )..priority = 40,
          );
          controller.commitValidExit(arrowId);
          _syncGateLanes();
          hud.refreshLives(controller.state.lives);
          if (controller.isComplete) {
            overlays.add('complete');
          }
          _refreshDebug();
        });
      case TapResultType.pathBlocked:
        component?.shake();
        final block = result.debug.blockingPosition;
        if (block != null) {
          add(
            BlockedPathEffectComponent(
              position: mapper.cellCenter(block),
              size: Vector2.all(layout.cellSize),
            )..priority = 40,
          );
        }
        _afterInvalid();
      case TapResultType.wrongGateColor:
      case TapResultType.noGateAligned:
      case TapResultType.gateLocked:
      case TapResultType.tapTooEarly:
      case TapResultType.tapTooLate:
        component?.shake();
        final edge = result.debug.expectedEdge;
        final slot = result.debug.expectedSlotIndex;
        if (edge != null && slot != null) {
          add(
            WrongTapEffectComponent(
              position: mapper.gateSlotCenter(edge, slot),
              size: layout.cellSize,
            )..priority = 40,
          );
        }
        _afterInvalid();
      case TapResultType.tapBuffered:
        component?.markAligned();
        final edge = result.debug.expectedEdge;
        final slot = result.debug.expectedSlotIndex;
        if (edge != null && slot != null) {
          add(
            GateAlignmentGlowComponent(
              position: mapper.gateSlotCenter(edge, slot),
              size: layout.cellSize * 1.25,
            )..priority = 40,
          );
        }
        _refreshDebug();
      case TapResultType.invalidGamePhase:
      case TapResultType.arrowNotFound:
        controller.inputController.unlock();
    }
  }

  void _syncGateLanes() {
    for (final entry in controller.state.lanes.entries) {
      gateLaneComponents[entry.key]?.refresh(entry.value);
    }
  }

  void _afterInvalid() {
    hud.refreshLives(controller.state.lives);
    if (controller.isFailed) {
      overlays.add('failed');
    }
    _refreshDebug();
  }

  void pausePrototype() {
    pauseEngine();
    controller.pause();
    overlays.add('pause');
  }

  void resumePrototype() {
    overlays.remove('pause');
    controller.resume();
    resumeEngine();
  }

  Future<void> restartPrototype() async {
    overlays
      ..remove('pause')
      ..remove('complete')
      ..remove('failed');
    removeAll(children.toList());
    arrowComponents.clear();
    gateLaneComponents.clear();
    controller.restart(initialBundle.gameState);
    isGameplayReady = false;
    _gateVisualMovement = false;
    _gateTiming = const GateTimingSnapshot.stable();
    await onLoad();
    resumeEngine();
  }

  Future<void> _prepareReviewState() async {
    if (qaMode == Phase2QaMode.normal ||
        qaMode == Phase2QaMode.prototypeGameplay ||
        qaMode == Phase2QaMode.loading) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!isMounted || !isGameplayReady) {
      return;
    }
    switch (qaMode) {
      case Phase2QaMode.validAlignment:
        arrowComponents['g_right']?.markAligned();
        add(
          GateAlignmentGlowComponent(
            position: mapper.gateSlotCenter(GateEdge.right, 2),
            size: layout.cellSize * 1.25,
          )..priority = 40,
        );
      case Phase2QaMode.blockedPath:
        handleArrowTap('g_blocked');
      case Phase2QaMode.wrongColorGate:
      case Phase2QaMode.noGateAligned:
      case Phase2QaMode.lockedGate:
        handleArrowTap('g_right');
      case Phase2QaMode.gateRotating:
        unawaited(rotateGates());
      case Phase2QaMode.bufferedTap:
        unawaited(_prepareBufferedReview());
      case Phase2QaMode.pauseOverlay:
        pausePrototype();
      case Phase2QaMode.levelComplete:
        handleArrowTap('g_right');
      case Phase2QaMode.levelFailed:
        handleArrowTap('g_blocked');
      case Phase2QaMode.visualDebugLevel:
      case Phase2QaMode.normal:
      case Phase2QaMode.loading:
      case Phase2QaMode.prototypeGameplay:
        break;
    }
    await _refreshDebug();
  }

  Future<void> _prepareBufferedReview() async {
    final movement = rotateGates();
    final waitMs = config.gateSlideDuration.inMilliseconds - 100;
    await Future<void>.delayed(Duration(milliseconds: waitMs));
    handleArrowTap('g_right');
    await movement;
  }

  Future<void> _refreshDebug() async {
    if (!debugLevel || !isGameplayReady) {
      return;
    }
    children
        .whereType<VisualDebugOverlayComponent>()
        .forEach((component) => component.removeFromParent());
    await add(
      VisualDebugOverlayComponent(
        phase: controller.state.phase,
        lives: controller.state.lives,
        activeArrows: activeArrowCount,
        gateTick: controller.gateController.tick,
        inputLocked: controller.inputLocked,
        lastResult: controller.lastResult?.type,
      )..priority = 100,
    );
  }
}
