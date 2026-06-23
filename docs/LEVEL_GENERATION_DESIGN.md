# Level Generation Design

Review date: 2026-06-23

## Content Strategy

- First 50 levels: handcrafted or designer-assisted.
- First 100 levels: solver-validated and manually visual-QA checked.
- Endless generation is not introduced immediately after onboarding.
- Daily Challenge uses deterministic UTC date seed and same output on Android/iOS.

## Progression

- Levels 1-5: 4x4, one/two colors, static gates, clear-path teaching.
- Levels 6-10: 5x5, move-based gate rotation.
- Levels 11-20: 5x5, 4-second timed rotation, two/three colors.
- Levels 21-40: 5x5/6x6, 3 seconds, four colors, deeper dependencies.
- Levels 41-70: 6x6, keys and locked gates.
- Levels 71-100: 6x6, frozen/chained arrows, 2.5 seconds.
- Levels 101-140: 7x7, 2 seconds, deeper order.
- Levels 141+: portals and challenge combinations.
- Add a recovery/easy level after every 4-6 hard levels.

## Solution-First Generator

1. Create empty board and gate schedule.
2. Generate target solution sequence and gate-tick sequence.
3. Place arrows in reverse solution order.
4. Allow later arrows to be intentionally blocked by earlier-to-remove arrows.
5. Assign gate colors/phases so each planned move has a valid matching window.
6. Add keys, locks, frozen/chained arrows, and portals only after base path is solvable.
7. Run solver.
8. Reject if unsolved, trivial, excessive wait, key-lock cycle, portal loop, or hidden impossible dependency.
9. Estimate difficulty.
10. Persist generation seed and expected solution metadata.

## Solver Requirements

- Operates on pure Dart models.
- Searches board state plus discrete lane phases.
- Supports move-based and timed gate rotation modes.
- Uses state hashing to avoid loops.
- Enforces maximum wait constraints.
- Emits hint path for current or future valid moves.
- Produces replayable solution log.

## Difficulty Features

- Grid size.
- Arrow count.
- Color count.
- Required wait windows.
- Dependency depth.
- Blocker density.
- Key/lock count.
- Frozen/chained count.
- Portal count.
- Mistake likelihood from adjacent candidate arrows.

## Acceptance Tests

- Every bundled level solved.
- Thousands of generated levels solved in property tests.
- Identical seed produces identical level.
- No key-lock cycles.
- No portal loops.
- No missing gate windows.
- Maximum wait stays below configured threshold.
