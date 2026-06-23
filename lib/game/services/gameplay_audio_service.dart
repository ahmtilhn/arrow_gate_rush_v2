enum GameplayAudioEvent {
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

abstract interface class GameplayAudioService {
  void play(GameplayAudioEvent event);
}

class NoopGameplayAudioService implements GameplayAudioService {
  const NoopGameplayAudioService();

  @override
  void play(GameplayAudioEvent event) {}
}
