import '../models/arrow_tile.dart';
import '../models/gate_edge.dart';
import '../models/gate_lane.dart';
import '../models/gate_slot.dart';

class AlignmentTarget {
  const AlignmentTarget({
    required this.edge,
    required this.slotIndex,
    required this.lane,
    required this.gate,
  });

  final GateEdge edge;
  final int slotIndex;
  final GateLane? lane;
  final GateSlot? gate;
}

class AlignmentValidator {
  const AlignmentValidator();

  AlignmentTarget targetFor({
    required ArrowTile arrow,
    required Map<GateEdge, GateLane> lanes,
  }) {
    final edge = arrow.direction.destinationEdge;
    final slotIndex = switch (edge) {
      GateEdge.top || GateEdge.bottom => arrow.position.column,
      GateEdge.left || GateEdge.right => arrow.position.row,
    };
    final lane = lanes[edge];
    return AlignmentTarget(
      edge: edge,
      slotIndex: slotIndex,
      lane: lane,
      gate: lane?.slotAt(slotIndex),
    );
  }
}
