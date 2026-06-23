import '../models/game_state.dart';
import '../models/tap_result.dart';
import '../rules/level_completion_rule.dart';

class GameStateReducer {
  const GameStateReducer({this.completionRule = const LevelCompletionRule()});

  final LevelCompletionRule completionRule;

  GameState beginTapEvaluation(GameState state) {
    if (state.phase != GamePhase.ready) {
      return state;
    }
    return state.copyWith(phase: GamePhase.evaluatingTap);
  }

  GameState applyTapResult(GameState state, TapResult result) {
    if (result.type == TapResultType.validExit) {
      return state.copyWith(phase: GamePhase.arrowLaunching);
    }
    if (state.level.hardModeInvalidTapFails) {
      return state.copyWith(phase: GamePhase.levelFailed);
    }
    final lives = state.lives - 1;
    if (completionRule.isFailed(state.copyWith(lives: lives))) {
      return state.copyWith(lives: lives, phase: GamePhase.levelFailed);
    }
    return state.copyWith(lives: lives, phase: GamePhase.ready);
  }

  GameState resolveValidMove(GameState state, String arrowId) {
    final arrow = state.board.arrows[arrowId];
    if (arrow == null) {
      return state.copyWith(phase: GamePhase.ready);
    }
    final arrows = Map<String, dynamic>.from(state.board.arrows);
    arrows[arrowId] = arrow.copyWith(exited: true);
    final nextBoard = state.board.copyWith(arrows: arrows.cast());
    final resolving = state.copyWith(
      board: nextBoard,
      phase: GamePhase.resolvingEffects,
    );
    if (completionRule.isComplete(resolving)) {
      return resolving.copyWith(phase: GamePhase.levelComplete);
    }
    return resolving.copyWith(phase: GamePhase.ready);
  }

  GameState startGateRotation(GameState state) {
    if (state.phase != GamePhase.ready) {
      return state;
    }
    return state.copyWith(phase: GamePhase.gateRotating);
  }

  GameState finishGateRotation(GameState state) {
    if (state.phase != GamePhase.gateRotating) {
      return state;
    }
    return state.copyWith(phase: GamePhase.ready);
  }

  GameState pause(GameState state) => state.copyWith(phase: GamePhase.paused);

  GameState resume(GameState state) {
    if (state.phase != GamePhase.paused) {
      return state;
    }
    return state.copyWith(phase: GamePhase.ready);
  }

  GameState background(GameState state) {
    return state.copyWith(phase: GamePhase.backgrounded);
  }

  GameState foreground(GameState state) {
    if (state.phase != GamePhase.backgrounded) {
      return state;
    }
    return state.copyWith(phase: GamePhase.ready);
  }
}
