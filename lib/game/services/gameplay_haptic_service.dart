enum GameplayHapticEvent {
  arrowTap,
  validExit,
  wrongTap,
  blockedPath,
  gateRotationTick,
  lockedGate,
  lifeLost,
  levelComplete,
  levelFailed,
}

abstract interface class GameplayHapticService {
  void trigger(GameplayHapticEvent event);
}

class NoopGameplayHapticService implements GameplayHapticService {
  const NoopGameplayHapticService();

  @override
  void trigger(GameplayHapticEvent event) {}
}
