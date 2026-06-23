# Gameplay State Machine

Review date: 2026-06-23

## States

```text
booting
loadingAssets
tutorial
ready
gateRotating
evaluatingTap
arrowLaunching
resolvingEffects
paused
levelComplete
levelFailed
adShowing
backgrounded
```

## Allowed Input Matrix

| State | Arrow tap | UI buttons | Gate tick | Ads | Save writes |
|---|---|---|---|---|---|
| `booting` | blocked | blocked | blocked | blocked | read only |
| `loadingAssets` | blocked | minimal cancel/debug only | blocked | blocked | read only |
| `tutorial` | tutorial-scripted only | allowed if tutorial permits | scripted | blocked | checkpoints |
| `ready` | allowed | allowed | may enter `gateRotating` | blocked | no direct write |
| `gateRotating` | buffer max 150 ms | pause allowed | active | blocked | no |
| `evaluatingTap` | blocked | pause queued | queued | blocked | no |
| `arrowLaunching` | blocked | pause queued | queued | blocked | snapshot already captured |
| `resolvingEffects` | blocked | pause queued | queued | blocked | result/checkpoint if needed |
| `paused` | blocked | resume/restart/settings/home | frozen | blocked except deliberate rewarded route from overlay | settings/save allowed |
| `levelComplete` | blocked | result actions | frozen | only after overlay and player action | atomic progress write |
| `levelFailed` | blocked | retry/continue/hint/home | frozen | rewarded continue only by opt-in | fail stats write |
| `adShowing` | blocked | blocked | frozen | active | no mutation except earned reward callback |
| `backgrounded` | blocked | blocked | frozen | blocked | atomic suspend save |

## Tap Evaluation Order

1. Is `gameState == ready`?
2. Is the tapped cell an arrow?
3. Is the arrow locked, frozen, or already animating?
4. Is the complete forward path to the board edge clear?
5. Does the exact destination lane slot contain a gate?
6. Is the gate open?
7. Does the gate color match the arrow color?
8. If portals are involved, does the final routed exit satisfy the same checks?

## Valid Move Sequence

1. Capture snapshot.
2. Enter `evaluatingTap`.
3. Glow arrow and matching gate for 100-150 ms.
4. Trigger light haptic if enabled.
5. Enter `arrowLaunching`.
6. Launch from cell center to gate center over 280-450 ms.
7. Collect crossed non-blocking key pickup.
8. Enter `resolvingEffects`.
9. Play gate burst for 350-500 ms.
10. Remove arrow.
11. Update score, combo, objectives.
12. If complete, enter `levelComplete`; otherwise return to `ready` and release queued gate tick.

## Timing Fairness

- Gate slide duration: 240-280 ms.
- Taps during slide are buffered for at most 150 ms and resolved after the lane snaps.
- No ambiguous half-moved gate evaluation.
- Gate tick due during arrow launch is queued until move resolution.
- A single tap cannot produce two moves.
- Debug replay log records state, lane phase, tap time, result enum, and target slot.
