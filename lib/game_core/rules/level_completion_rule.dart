import '../models/game_state.dart';

class LevelCompletionRule {
  const LevelCompletionRule();

  bool isComplete(GameState state) {
    if (state.objectivesRemaining > 0) {
      return false;
    }
    for (final id in state.level.requiredArrowIds) {
      final arrow = state.board.arrows[id];
      if (arrow == null || !arrow.exited) {
        return false;
      }
    }
    return true;
  }

  bool isFailed(
    GameState state, {
    bool invalidTapCommitted = false,
    bool timeoutReached = false,
  }) {
    if (state.level.canFailOnLives && state.lives <= 0) {
      return true;
    }
    if (state.level.hardModeInvalidTapFails && invalidTapCommitted) {
      return true;
    }
    if (state.level.timeoutEnabled && timeoutReached) {
      return true;
    }
    return false;
  }
}
