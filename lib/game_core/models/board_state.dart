import 'arrow_tile.dart';
import 'grid_position.dart';

enum BoardBlockerType { obstacle, lockedTile, arrow }

class BoardCell {
  const BoardCell.empty() : blockerType = null;
  const BoardCell.obstacle() : blockerType = BoardBlockerType.obstacle;
  const BoardCell.lockedTile() : blockerType = BoardBlockerType.lockedTile;

  final BoardBlockerType? blockerType;

  bool get isBlocking => blockerType != null;
}

class BoardState {
  const BoardState({
    required this.rows,
    required this.columns,
    required this.arrows,
    this.cells = const {},
  });

  final int rows;
  final int columns;
  final Map<String, ArrowTile> arrows;
  final Map<GridPosition, BoardCell> cells;

  bool contains(GridPosition position) {
    return position.row >= 0 &&
        position.row < rows &&
        position.column >= 0 &&
        position.column < columns;
  }

  ArrowTile? arrowAt(GridPosition position) {
    for (final arrow in arrows.values) {
      if (!arrow.exited && arrow.position == position) {
        return arrow;
      }
    }
    return null;
  }

  BoardBlockerType? blockerAt(
    GridPosition position, {
    String? ignoringArrowId,
  }) {
    final cell = cells[position];
    if (cell != null && cell.isBlocking) {
      return cell.blockerType;
    }
    final arrow = arrowAt(position);
    if (arrow != null && arrow.id != ignoringArrowId) {
      return BoardBlockerType.arrow;
    }
    return null;
  }

  BoardState copyWith({
    Map<String, ArrowTile>? arrows,
    Map<GridPosition, BoardCell>? cells,
  }) {
    return BoardState(
      rows: rows,
      columns: columns,
      arrows: Map<String, ArrowTile>.unmodifiable(arrows ?? this.arrows),
      cells: Map<GridPosition, BoardCell>.unmodifiable(cells ?? this.cells),
    );
  }
}
