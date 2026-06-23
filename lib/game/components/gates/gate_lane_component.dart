import 'package:flame/components.dart';

import '../../../game_core/game_core.dart';
import '../../layout/gameplay_layout.dart';
import '../../mapping/core_to_flame_mapper.dart';
import 'gate_component.dart';

class GateLaneComponent extends PositionComponent {
  GateLaneComponent({required this.lane, required this.layout});

  GateLane lane;
  final GameplayLayout layout;

  @override
  Future<void> onLoad() async {
    refresh(lane);
  }

  void refresh(GateLane nextLane) {
    lane = nextLane;
    removeAll(children.toList());
    final mapper = CoreToFlameMapper(layout);
    for (var index = 0; index < lane.slots.length; index += 1) {
      final gate = lane.slots[index];
      if (gate != null) {
        add(
          GateComponent(
            gate: gate,
            edge: lane.edge,
            slotIndex: index,
            position: mapper.gateSlotCenter(lane.edge, index),
            cellSize: layout.cellSize * 0.92,
          ),
        );
      }
    }
  }
}
