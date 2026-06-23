import 'package:flutter/services.dart';

import '../arrow_gate_game.dart';
import '../controllers/game_session_controller.dart';

class GameBootstrap {
  const GameBootstrap();

  Future<ArrowGateGame> createGame({bool debugLevel = false}) async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    final bundle = GameSessionController(
      debugLevel: debugLevel,
    ).createInitialLevel();
    return ArrowGateGame(initialBundle: bundle, debugLevel: debugLevel);
  }
}
