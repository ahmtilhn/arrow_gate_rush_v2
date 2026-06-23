import 'package:flame/components.dart';

import '../../game_core/game_core.dart';
import '../layout/gameplay_layout.dart';

class CoreToFlameMapper {
  const CoreToFlameMapper(this.layout);

  final GameplayLayout layout;

  Vector2 cellTopLeft(GridPosition position) {
    return Vector2(
      layout.boardTopLeft.x + position.column * layout.cellSize,
      layout.boardTopLeft.y + position.row * layout.cellSize,
    );
  }

  Vector2 cellCenter(GridPosition position) {
    return cellTopLeft(position) + Vector2.all(layout.cellSize / 2);
  }

  Vector2 gateSlotCenter(GateEdge edge, int index) {
    final gap = layout.gateGap;
    final cell = layout.cellSize;
    return switch (edge) {
      GateEdge.top => Vector2(
        layout.boardTopLeft.x + index * cell + cell / 2,
        layout.boardTopLeft.y - gap - cell / 2,
      ),
      GateEdge.bottom => Vector2(
        layout.boardTopLeft.x + index * cell + cell / 2,
        layout.boardTopLeft.y + layout.boardSize + gap + cell / 2,
      ),
      GateEdge.left => Vector2(
        layout.boardTopLeft.x - gap - cell / 2,
        layout.boardTopLeft.y + index * cell + cell / 2,
      ),
      GateEdge.right => Vector2(
        layout.boardTopLeft.x + layout.boardSize + gap + cell / 2,
        layout.boardTopLeft.y + index * cell + cell / 2,
      ),
    };
  }
}
