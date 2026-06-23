import 'board_state.dart';
import 'gate_edge.dart';
import 'gate_lane.dart';
import 'level_definition.dart';

enum GamePhase {
  ready,
  evaluatingTap,
  arrowLaunching,
  resolvingEffects,
  gateRotating,
  paused,
  levelComplete,
  levelFailed,
  backgrounded,
}

class GameState {
  const GameState({
    required this.board,
    required this.lanes,
    required this.phase,
    required this.level,
    this.lives = 3,
    this.objectivesRemaining = 0,
  });

  final BoardState board;
  final Map<GateEdge, GateLane> lanes;
  final GamePhase phase;
  final LevelDefinition level;
  final int lives;
  final int objectivesRemaining;

  bool get acceptsDirectTap => phase == GamePhase.ready;

  GameState copyWith({
    BoardState? board,
    Map<GateEdge, GateLane>? lanes,
    GamePhase? phase,
    LevelDefinition? level,
    int? lives,
    int? objectivesRemaining,
  }) {
    return GameState(
      board: board ?? this.board,
      lanes: Map<GateEdge, GateLane>.unmodifiable(lanes ?? this.lanes),
      phase: phase ?? this.phase,
      level: level ?? this.level,
      lives: lives ?? this.lives,
      objectivesRemaining: objectivesRemaining ?? this.objectivesRemaining,
    );
  }
}
