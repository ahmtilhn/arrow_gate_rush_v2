import 'gate_edge.dart';

enum ArrowDirection {
  up,
  down,
  left,
  right;

  GateEdge get destinationEdge {
    return switch (this) {
      ArrowDirection.up => GateEdge.top,
      ArrowDirection.down => GateEdge.bottom,
      ArrowDirection.left => GateEdge.left,
      ArrowDirection.right => GateEdge.right,
    };
  }
}
