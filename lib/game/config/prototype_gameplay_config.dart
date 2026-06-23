import '../../game_core/game_core.dart';

class PrototypeGameplayConfig {
  const PrototypeGameplayConfig({
    this.gateInterval = const Duration(seconds: 3),
    this.gateSlideDuration = const Duration(milliseconds: 350),
    this.timing = const GameplayTimingConfig(),
    this.initialLives = 3,
  });

  final Duration gateInterval;
  final Duration gateSlideDuration;
  final GameplayTimingConfig timing;
  final int initialLives;
}
