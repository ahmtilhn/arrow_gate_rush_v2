import 'arrow_color.dart';
import 'arrow_direction.dart';
import 'grid_position.dart';

class ArrowTile {
  const ArrowTile({
    required this.id,
    required this.position,
    required this.color,
    required this.direction,
    this.exited = false,
  });

  final String id;
  final GridPosition position;
  final ArrowColor color;
  final ArrowDirection direction;
  final bool exited;

  ArrowTile copyWith({GridPosition? position, bool? exited}) {
    return ArrowTile(
      id: id,
      position: position ?? this.position,
      color: color,
      direction: direction,
      exited: exited ?? this.exited,
    );
  }
}
