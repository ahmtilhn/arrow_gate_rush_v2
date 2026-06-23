import '../models/game_state.dart';
import '../models/tap_attempt.dart';
import '../models/tap_result.dart';
import '../systems/tap_buffer_system.dart';
import 'alignment_validator.dart';
import 'path_validator.dart';

class MoveValidator {
  const MoveValidator({
    this.pathValidator = const PathValidator(),
    this.alignmentValidator = const AlignmentValidator(),
  });

  final PathValidator pathValidator;
  final AlignmentValidator alignmentValidator;

  TapResult validate({
    required GameState state,
    required TapAttempt attempt,
    required TapTimingDecision timingDecision,
  }) {
    final arrow = state.board.arrows[attempt.arrowId];
    if (arrow == null || arrow.exited) {
      return TapResult(
        TapResultType.arrowNotFound,
        TapDebugInfo(
          arrowId: attempt.arrowId,
          tapTimestampMs: attempt.timestampMs,
          acceptedWindowStartMs: timingDecision.acceptedWindowStartMs,
          acceptedWindowEndMs: timingDecision.acceptedWindowEndMs,
        ),
      );
    }

    final target = alignmentValidator.targetFor(
      arrow: arrow,
      lanes: state.lanes,
    );
    TapDebugInfo debug({dynamic blockingPosition}) {
      return TapDebugInfo(
        arrowId: arrow.id,
        arrowPosition: arrow.position,
        arrowDirection: arrow.direction,
        expectedEdge: target.edge,
        expectedSlotIndex: target.slotIndex,
        currentAlignedGate: target.gate,
        blockingPosition: blockingPosition,
        gateRotationPhase: target.lane?.phase,
        tapTimestampMs: attempt.timestampMs,
        acceptedWindowStartMs: timingDecision.acceptedWindowStartMs,
        acceptedWindowEndMs: timingDecision.acceptedWindowEndMs,
      );
    }

    if (!state.acceptsDirectTap) {
      return TapResult(TapResultType.invalidGamePhase, debug());
    }

    switch (timingDecision.type) {
      case TapTimingDecisionType.tooEarly:
        return TapResult(TapResultType.tapTooEarly, debug());
      case TapTimingDecisionType.tooLate:
        return TapResult(TapResultType.tapTooLate, debug());
      case TapTimingDecisionType.bufferForCommit:
        return TapResult(TapResultType.tapBuffered, debug());
      case TapTimingDecisionType.acceptPreviousCommitted:
      case TapTimingDecisionType.acceptNewCommitted:
        break;
    }

    final path = pathValidator.validate(
      board: state.board,
      arrowId: arrow.id,
      from: arrow.position,
      direction: arrow.direction,
    );
    if (!path.isClear) {
      return TapResult(
        TapResultType.pathBlocked,
        debug(blockingPosition: path.blockingPosition),
      );
    }

    final gate = target.gate;
    if (gate == null) {
      return TapResult(TapResultType.noGateAligned, debug());
    }
    if (gate.isLocked || !gate.isOpen) {
      return TapResult(TapResultType.gateLocked, debug());
    }
    if (gate.color != arrow.color) {
      return TapResult(TapResultType.wrongGateColor, debug());
    }
    return TapResult(TapResultType.validExit, debug());
  }
}
