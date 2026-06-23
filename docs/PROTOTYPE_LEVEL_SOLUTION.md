# Phase 2 Prototype Level Solution

Review date: 2026-06-23

## Initial Board

Grid: 6x6. Coordinates are `row,column`.

- `g_right`: green, right, at `2,1`
- `b_up`: blue, up, at `4,3`
- `r_left`: red, left, at `1,4`
- `y_down`: yellow, down, at `0,0`
- `g_blocked`: green, right, at `2,0`
- `r_down`: red, down, at `0,5`

`g_blocked` is initially blocked by `g_right`, so the path validator must reject it until the blocking arrow exits.

## Initial Gate Lanes

Top lane, clockwise:

- slot 3: blue open gate

Right lane, clockwise:

- slot 1: red open gate, creating a wrong-color opportunity for a green/right arrow in row 1
- slot 2: green open gate, aligned with `g_right`

Bottom lane, counterclockwise:

- slot 0: yellow open gate
- slot 5: red open gate

Left lane, clockwise:

- slot 1: red open gate

## Required Solution Order

The documented prototype order is:

1. `g_right`
2. `b_up`
3. `r_left`
4. `y_down`
5. `g_blocked`
6. `r_down`

The level is deterministic on restart because the board, lane slot arrays, lane directions, and lives are recreated from `PrototypeLevels.playable()`.

## Expected Alignment Ticks

Phase 2 uses a 3 second gate interval and one-slot deterministic rotation. Tick 0 has at least one valid move: `g_right` exits to the right lane slot 2. Subsequent moves can be tested either by waiting deterministic ticks or by using the controller to rotate lanes explicitly in tests.

## Expected Failure Examples

- Tap `g_blocked` at tick 0: `pathBlocked`
- Tap a row/column with no aligned gate: `noGateAligned`
- Tap an arrow aligned to a gate with a different color after rotation: `wrongGateColor`
- Visual debug level includes a locked matching yellow top gate for `gateLocked`
