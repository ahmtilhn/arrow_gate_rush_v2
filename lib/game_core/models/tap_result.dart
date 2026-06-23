import 'arrow_direction.dart';
import 'gate_edge.dart';
import 'gate_slot.dart';
import 'grid_position.dart';

enum TapResultType {
  validExit,
  pathBlocked,
  noGateAligned,
  wrongGateColor,
  gateLocked,
  invalidGamePhase,
  tapTooEarly,
  tapTooLate,
  tapBuffered,
  arrowNotFound,
}

class TapDebugInfo {
  const TapDebugInfo({
    required this.arrowId,
    this.arrowPosition,
    this.arrowDirection,
    this.expectedEdge,
    this.expectedSlotIndex,
    this.currentAlignedGate,
    this.blockingPosition,
    this.gateRotationPhase,
    this.tapTimestampMs,
    this.acceptedWindowStartMs,
    this.acceptedWindowEndMs,
  });

  final String arrowId;
  final GridPosition? arrowPosition;
  final ArrowDirection? arrowDirection;
  final GateEdge? expectedEdge;
  final int? expectedSlotIndex;
  final GateSlot? currentAlignedGate;
  final GridPosition? blockingPosition;
  final int? gateRotationPhase;
  final int? tapTimestampMs;
  final int? acceptedWindowStartMs;
  final int? acceptedWindowEndMs;
}

class TapResult {
  const TapResult(this.type, this.debug);

  final TapResultType type;
  final TapDebugInfo debug;

  bool get isValidExit => type == TapResultType.validExit;
}
