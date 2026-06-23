import '../../game_core/game_core.dart';

class PrototypeLevelBundle {
  const PrototypeLevelBundle({
    required this.gameState,
    required this.solutionOrder,
  });

  final GameState gameState;
  final List<String> solutionOrder;
}

class PrototypeLevels {
  static PrototypeLevelBundle playable({int lives = 3}) {
    final arrows = <String, ArrowTile>{
      'g_right': const ArrowTile(
        id: 'g_right',
        position: GridPosition(2, 1),
        color: ArrowColor.green,
        direction: ArrowDirection.right,
      ),
      'b_up': const ArrowTile(
        id: 'b_up',
        position: GridPosition(4, 3),
        color: ArrowColor.blue,
        direction: ArrowDirection.up,
      ),
      'r_left': const ArrowTile(
        id: 'r_left',
        position: GridPosition(1, 4),
        color: ArrowColor.red,
        direction: ArrowDirection.left,
      ),
      'y_down': const ArrowTile(
        id: 'y_down',
        position: GridPosition(0, 0),
        color: ArrowColor.yellow,
        direction: ArrowDirection.down,
      ),
      'g_blocked': const ArrowTile(
        id: 'g_blocked',
        position: GridPosition(2, 0),
        color: ArrowColor.green,
        direction: ArrowDirection.right,
      ),
      'r_down': const ArrowTile(
        id: 'r_down',
        position: GridPosition(0, 5),
        color: ArrowColor.red,
        direction: ArrowDirection.down,
      ),
    };
    return PrototypeLevelBundle(
      gameState: GameState(
        board: BoardState(rows: 6, columns: 6, arrows: arrows),
        lanes: {
          GateEdge.top: GateLane(
            edge: GateEdge.top,
            slots: const [
              null,
              null,
              null,
              GateSlot(id: 'top_blue', color: ArrowColor.blue),
              null,
              null,
            ],
          ),
          GateEdge.right: GateLane(
            edge: GateEdge.right,
            slots: const [
              null,
              GateSlot(id: 'right_red_wrong', color: ArrowColor.red),
              GateSlot(id: 'right_green', color: ArrowColor.green),
              null,
              null,
              null,
            ],
          ),
          GateEdge.bottom: GateLane(
            edge: GateEdge.bottom,
            slots: const [
              GateSlot(id: 'bottom_yellow', color: ArrowColor.yellow),
              null,
              null,
              null,
              null,
              GateSlot(id: 'bottom_red', color: ArrowColor.red),
            ],
            rotationDirection: GateRotationDirection.counterclockwise,
          ),
          GateEdge.left: GateLane(
            edge: GateEdge.left,
            slots: const [
              null,
              GateSlot(id: 'left_red', color: ArrowColor.red),
              null,
              null,
              null,
              null,
            ],
          ),
        },
        phase: GamePhase.ready,
        lives: lives,
        level: const LevelDefinition(
          id: 'phase2_prototype',
          requiredArrowIds: {
            'g_right',
            'b_up',
            'r_left',
            'y_down',
            'g_blocked',
            'r_down',
          },
        ),
      ),
      solutionOrder: const [
        'g_right',
        'b_up',
        'r_left',
        'y_down',
        'g_blocked',
        'r_down',
      ],
    );
  }

  static PrototypeLevelBundle visualDebug() {
    final bundle = playable();
    final arrows = Map<String, ArrowTile>.from(bundle.gameState.board.arrows);
    arrows['locked_demo'] = const ArrowTile(
      id: 'locked_demo',
      position: GridPosition(5, 2),
      color: ArrowColor.yellow,
      direction: ArrowDirection.up,
    );
    final lanes = Map<GateEdge, GateLane>.from(bundle.gameState.lanes);
    final topSlots = List<GateSlot?>.from(lanes[GateEdge.top]!.slots);
    topSlots[2] = const GateSlot(
      id: 'top_yellow_locked',
      color: ArrowColor.yellow,
      isLocked: true,
    );
    lanes[GateEdge.top] = lanes[GateEdge.top]!.copyWith(slots: topSlots);
    return PrototypeLevelBundle(
      gameState: bundle.gameState.copyWith(
        board: bundle.gameState.board.copyWith(
          arrows: arrows,
          cells: {
            const GridPosition(3, 1): const BoardCell.obstacle(),
            const GridPosition(3, 2): const BoardCell.lockedTile(),
          },
        ),
        lanes: lanes,
      ),
      solutionOrder: bundle.solutionOrder,
    );
  }
}
