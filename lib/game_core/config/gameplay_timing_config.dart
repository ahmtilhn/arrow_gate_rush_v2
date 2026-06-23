class GameplayTimingConfig {
  const GameplayTimingConfig({
    this.gateTapBuffer = const Duration(milliseconds: 150),
  });

  final Duration gateTapBuffer;
}
