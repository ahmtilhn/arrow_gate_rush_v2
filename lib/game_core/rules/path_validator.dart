import '../models/arrow_direction.dart';
import '../models/board_state.dart';
import '../models/grid_position.dart';

class PathValidationResult {
  const PathValidationResult.clear() : blockingPosition = null;
  const PathValidationResult.blocked(this.blockingPosition);

  final GridPosition? blockingPosition;

  bool get isClear => blockingPosition == null;
}

class PathValidator {
  const PathValidator();

  PathValidationResult validate({
    required BoardState board,
    required String arrowId,
    required GridPosition from,
    required ArrowDirection direction,
  }) {
    for (final position in positionsToEdge(board, from, direction)) {
      if (board.blockerAt(position, ignoringArrowId: arrowId) != null) {
        return PathValidationResult.blocked(position);
      }
    }
    return const PathValidationResult.clear();
  }

  List<GridPosition> positionsToEdge(
    BoardState board,
    GridPosition from,
    ArrowDirection direction,
  ) {
    final positions = <GridPosition>[];
    var row = from.row;
    var column = from.column;

    while (true) {
      switch (direction) {
        case ArrowDirection.up:
          row -= 1;
        case ArrowDirection.down:
          row += 1;
        case ArrowDirection.left:
          column -= 1;
        case ArrowDirection.right:
          column += 1;
      }
      final next = GridPosition(row, column);
      if (!board.contains(next)) {
        break;
      }
      positions.add(next);
    }
    return positions;
  }
}
