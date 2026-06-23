import '../config/gameplay_timing_config.dart';

enum GateTimingState {
  stable,
  rotationStarted,
  visuallyMoving,
  rotationCommitted,
  postCommitBufferEnded,
}

enum TapTimingDecisionType {
  acceptPreviousCommitted,
  acceptNewCommitted,
  bufferForCommit,
  tooEarly,
  tooLate,
}

class GateTimingSnapshot {
  const GateTimingSnapshot.stable()
    : state = GateTimingState.stable,
      rotationStartMs = null,
      commitMs = null;

  const GateTimingSnapshot({
    required this.state,
    required this.rotationStartMs,
    required this.commitMs,
  });

  final GateTimingState state;
  final int? rotationStartMs;
  final int? commitMs;
}

class TapTimingDecision {
  const TapTimingDecision({
    required this.type,
    this.acceptedWindowStartMs,
    this.acceptedWindowEndMs,
  });

  final TapTimingDecisionType type;
  final int? acceptedWindowStartMs;
  final int? acceptedWindowEndMs;
}

class TapBufferSystem {
  const TapBufferSystem(this.config);

  final GameplayTimingConfig config;

  TapTimingDecision evaluate({
    required GateTimingSnapshot timing,
    required int tapTimestampMs,
  }) {
    final bufferMs = config.gateTapBuffer.inMilliseconds;
    switch (timing.state) {
      case GateTimingState.stable:
        return const TapTimingDecision(
          type: TapTimingDecisionType.acceptPreviousCommitted,
        );
      case GateTimingState.rotationStarted:
      case GateTimingState.visuallyMoving:
        final commit = timing.commitMs;
        if (commit == null) {
          return const TapTimingDecision(type: TapTimingDecisionType.tooEarly);
        }
        final start = commit - bufferMs;
        if (tapTimestampMs < start) {
          return TapTimingDecision(
            type: TapTimingDecisionType.tooEarly,
            acceptedWindowStartMs: start,
            acceptedWindowEndMs: commit,
          );
        }
        if (tapTimestampMs <= commit) {
          return TapTimingDecision(
            type: TapTimingDecisionType.bufferForCommit,
            acceptedWindowStartMs: start,
            acceptedWindowEndMs: commit,
          );
        }
        return TapTimingDecision(
          type: TapTimingDecisionType.acceptNewCommitted,
          acceptedWindowStartMs: commit,
          acceptedWindowEndMs: commit + bufferMs,
        );
      case GateTimingState.rotationCommitted:
        final commit = timing.commitMs;
        if (commit == null) {
          return const TapTimingDecision(
            type: TapTimingDecisionType.acceptNewCommitted,
          );
        }
        final end = commit + bufferMs;
        if (tapTimestampMs <= end) {
          return TapTimingDecision(
            type: TapTimingDecisionType.acceptNewCommitted,
            acceptedWindowStartMs: commit,
            acceptedWindowEndMs: end,
          );
        }
        return TapTimingDecision(
          type: TapTimingDecisionType.tooLate,
          acceptedWindowStartMs: commit,
          acceptedWindowEndMs: end,
        );
      case GateTimingState.postCommitBufferEnded:
        final commit = timing.commitMs;
        return TapTimingDecision(
          type: TapTimingDecisionType.tooLate,
          acceptedWindowStartMs: commit,
          acceptedWindowEndMs: commit == null
              ? null
              : commit + config.gateTapBuffer.inMilliseconds,
        );
    }
  }
}
