import '../bootstrap/prototype_level.dart';

class GameSessionController {
  GameSessionController({this.debugLevel = false});

  final bool debugLevel;

  PrototypeLevelBundle createInitialLevel() {
    return debugLevel
        ? PrototypeLevels.visualDebug()
        : PrototypeLevels.playable();
  }
}
