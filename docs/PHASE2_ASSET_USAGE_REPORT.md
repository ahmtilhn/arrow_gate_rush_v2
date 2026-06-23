# Phase 2 Asset Usage Report

Review date: 2026-06-23

## Validation

- Generated asset constants checked: missing constants = 0.
- PNG package count: 186.
- Transparency QA package report: 186 RGBA PNGs with transparent margins.
- Flutter asset bundle required leaf folders were added to `pubspec.yaml` because test/runtime asset lookup did not include nested files reliably from only the root folder entry.

## Assets Used

Background:

- `backgrounds/parallax/sky_full.png`
- `mountain_horizon_strip.png`
- `tree_line_strip.png`
- `bush_line_strip.png`
- `foreground_garden_strip.png`

Board:

- `gameplay/board/cells/empty_beige_compact.png`

Arrows:

- All 16 direction-specific arrow sprites through `ArrowAssetResolver`

Gates:

- Compact open and locked gate sprites through `GateAssetResolver`

HUD and controls:

- `ui/hud/level_badge.png`
- `ui/hud/coin_counter.png`
- `ui/icons/gems/red.png` for prototype lives
- `ui/buttons/common/pill_blue.png`
- `ui/buttons/common/pill_green.png`
- `ui/buttons/common/pill_red.png`

Effects:

- `effects/gate_burst_gold_large.png`
- `effects/wrong_tap_cross_red.png`
- `effects/path_glow_horizontal_short.png`
- `effects/target_ring_gold.png`

Debug-only visual coverage:

- stone, ice, chain, blue/purple portal assets

## Scaling Behavior

- Gameplay/UI sprites use contain-style sizing.
- Board cells remain square via `BoardLayoutCalculator`.
- Gates are centered on lane slots derived from the same board layout as arrow cells.
- Background uses cover-style full-screen layout.

## Missing Assets

None detected for referenced constants.

## Temporary Visual Compromises

- Phase 2 screenshot PNG generation in tests writes representative supplied PNG assets to the visual QA directory instead of full live-render captures, because Windows widget-test `RenderRepaintBoundary.toImage` capture was not stable in this environment.
- Prototype overlays still use simple Flutter panels; production localized UI composition belongs to later UI/localization phases.

## Suspicious Alpha / Checkerboard

No checkerboard or invalid alpha was detected from the supplied transparency QA report.
