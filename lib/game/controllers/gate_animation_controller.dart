import '../../game_core/game_core.dart';
import '../config/prototype_gameplay_config.dart';

class GateAnimationController {
  GateAnimationController({
    this.rotationSystem = const GateRotationSystem(),
    this.config = const PrototypeGameplayConfig(),
  });

  final GateRotationSystem rotationSystem;
  final PrototypeGameplayConfig config;
  int tick = 0;

  Map<GateEdge, GateLane> nextLanes(Map<GateEdge, GateLane> lanes) {
    tick += 1;
    return {
      for (final entry in lanes.entries)
        entry.key: rotationSystem.rotateOnce(entry.value),
    };
  }
}
