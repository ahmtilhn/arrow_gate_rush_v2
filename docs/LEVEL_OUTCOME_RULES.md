# Level Outcome Rules

Review date: 2026-06-23

## Completion

A level is complete only when:

- all required arrow tiles have exited, and
- no required objective remains, and
- the last valid move has resolved and arrow removal is committed.

Completion never fires during tap evaluation or while an arrow is still launching.

## Failure

A level fails when the configured mode says it can fail and at least one of these is true:

- lives reach zero,
- hard-mode invalid tap failure is enabled and an invalid tap is committed,
- timeout is enabled and remaining time reaches zero.

## Precedence

The reducer evaluates outcomes only after a controlled state transition. Completion takes precedence after a resolved valid move. Failure is evaluated after invalid committed penalties or timeout. If completion and failure appear possible in the same reducer step, completion wins only when the valid move was resolved first; otherwise failure wins. The reducer must never emit both `levelComplete` and `levelFailed`.
