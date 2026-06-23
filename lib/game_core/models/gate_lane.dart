import 'gate_edge.dart';
import 'gate_slot.dart';

enum GateRotationDirection { clockwise, counterclockwise }

class GateLane {
  const GateLane({
    required this.edge,
    required this.slots,
    this.rotationDirection = GateRotationDirection.clockwise,
    this.phase = 0,
  });

  final GateEdge edge;
  final List<GateSlot?> slots;
  final GateRotationDirection rotationDirection;
  final int phase;

  GateSlot? slotAt(int index) {
    if (index < 0 || index >= slots.length) {
      return null;
    }
    return slots[index];
  }

  GateLane copyWith({
    List<GateSlot?>? slots,
    GateRotationDirection? rotationDirection,
    int? phase,
  }) {
    return GateLane(
      edge: edge,
      slots: List<GateSlot?>.unmodifiable(slots ?? this.slots),
      rotationDirection: rotationDirection ?? this.rotationDirection,
      phase: phase ?? this.phase,
    );
  }
}
