import 'package:flame/components.dart';

import '../../../game_core/game_core.dart';
import '../../layout/gameplay_layout.dart';
import '../../mapping/core_to_flame_mapper.dart';
import 'board_cell_component.dart';

class BoardGridComponent extends PositionComponent {
  BoardGridComponent({required this.board, required this.layout});

  final BoardState board;
  final GameplayLayout layout;

  @override
  Future<void> onLoad() async {
    final mapper = CoreToFlameMapper(layout);
    for (var row = 0; row < board.rows; row += 1) {
      for (var column = 0; column < board.columns; column += 1) {
        add(
          BoardCellComponent(
            position: mapper.cellTopLeft(GridPosition(row, column)),
            cellSize: layout.cellSize,
          ),
        );
      }
    }
  }
}
