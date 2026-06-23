import 'package:flutter/services.dart';

import '../arrow_gate_game.dart';
import '../qa/phase2_qa_mode.dart';
import 'prototype_level.dart';

class GameBootstrap {
  const GameBootstrap();

  Future<ArrowGateGame> createGame({
    bool debugLevel = false,
    Phase2QaMode mode = Phase2QaMode.normal,
  }) async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return ArrowGateGame(
      initialBundle: PrototypeLevels.forQaMode(mode),
      debugLevel: debugLevel || mode == Phase2QaMode.visualDebugLevel,
      qaMode: mode,
    );
  }
}
