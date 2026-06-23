import 'package:flame/components.dart';

import '../../../game_core/game_core.dart';

class GateSlotComponent extends PositionComponent {
  GateSlotComponent({
    required this.edge,
    required this.slotIndex,
    required super.position,
    required double cellSize,
  }) : super(size: Vector2.all(cellSize), anchor: Anchor.center);

  final GateEdge edge;
  final int slotIndex;
}
