# Tap Buffer Rules

Review date: 2026-06-23

The Phase 1 core models tap timing without depending on Flame, timers, animation frames, wall-clock scheduling, or device FPS.

## Configuration

`GameplayTimingConfig.gateTapBuffer` defaults to 150 milliseconds.

## Gate Timing States

- `stable`: the lane is fully committed and not visually moving.
- `rotationStarted`: a deterministic rotation step has been scheduled but visual movement has not entered the committed window.
- `visuallyMoving`: the lane is between the previous committed slot order and the next committed slot order.
- `rotationCommitted`: the next slot order is committed.
- `postCommitBufferEnded`: the grace window after commit is over.

## Deterministic Rule

- Stable taps validate against the current committed lane state.
- A tap during visual movement is buffered only when it lands in the final `gateTapBuffer` window before the deterministic commit timestamp.
- A tap before that final pre-commit buffer is rejected as `tapTooEarly`.
- A buffered tap returns `tapBuffered`; it is not treated as an immediate valid exit.
- A tap from commit timestamp through `commit + gateTapBuffer` validates against the new committed lane state.
- A tap tied to the rotation after `commit + gateTapBuffer` is rejected as `tapTooLate`.

This lets tests distinguish previous committed alignment, new committed alignment, too-early taps, too-late taps, and buffered taps.
