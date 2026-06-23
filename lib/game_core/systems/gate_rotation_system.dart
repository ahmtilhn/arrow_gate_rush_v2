import '../models/gate_lane.dart';
import '../models/gate_slot.dart';

class GateRotationSystem {
  const GateRotationSystem();

  GateLane rotateOnce(GateLane lane) => rotateBy(lane, 1);

  GateLane rotateBy(GateLane lane, int steps) {
    if (lane.slots.isEmpty) {
      return lane.copyWith(phase: lane.phase + steps);
    }
    final normalized = steps % lane.slots.length;
    if (normalized == 0) {
      return lane.copyWith(phase: lane.phase + steps);
    }
    final shifted = List<GateSlot?>.filled(lane.slots.length, null);
    for (var index = 0; index < lane.slots.length; index += 1) {
      final target = switch (lane.rotationDirection) {
        GateRotationDirection.clockwise =>
          (index + normalized) % lane.slots.length,
        GateRotationDirection.counterclockwise =>
          (index - normalized) % lane.slots.length,
      };
      shifted[target < 0 ? target + lane.slots.length : target] =
          lane.slots[index];
    }
    return lane.copyWith(slots: shifted, phase: lane.phase + steps);
  }

  GateLane laneAtTick(GateLane initial, int tick) => rotateBy(initial, tick);
}
