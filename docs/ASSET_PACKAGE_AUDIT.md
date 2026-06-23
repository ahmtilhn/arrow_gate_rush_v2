# Asset Package Audit

Review date: 2026-06-23

## Package Source

Expected package: `arrow_gate_rush_assets_codex_ready.zip`

Actual discovered file:

```text
C:\Users\ahmet\Downloads\arrow_gate_rush_assets_codex_ready.zip
```

The user-stated root copy was not present when checked. The discovered package was extracted into the project root preserving its folder structure.

## Required Documents Read

Read in the required package set:

1. `README_START_HERE.md`
2. `CODEX_ASSET_INSTRUCTIONS.md`
3. `docs/ASSET_USAGE_GUIDE.md`
4. `docs/SCREEN_ASSET_MAP.md`
5. `docs/FLUTTER_FLAME_INTEGRATION.md`
6. `config/asset_catalog.json`
7. `config/screen_asset_map.json`
8. `config/transparency_qa_report.json`
9. `lib/generated/arrow_gate_assets.dart`
10. `config/pubspec_assets_snippet.yaml`

## Validation Result

```text
png_count=186
catalog_count=186
qa_count=186
qa_rgba=True
qa_transparent_margin=True
screen_map_missing=0
```

Additional validation:

- `config/asset_catalog.json` parsed successfully.
- `config/package_summary.json` parsed successfully.
- `config/screen_asset_map.json` parsed successfully.
- `config/transparency_qa_report.json` parsed successfully.
- All `ArrowGateAssets` constants point to existing files.
- `pubspec.yaml` includes `assets/arrow_gate_rush/`.

## Binding Asset Rules

- Use `ArrowGateAssets` constants instead of handwritten paths.
- Do not use old sprite sheets.
- Do not replace supplied art with default Flutter or Material icons.
- Do not recolor, tint, crop, or distort PNGs.
- Preserve aspect ratio with `BoxFit.contain` for gameplay and UI assets.
- Use `BoxFit.cover` for full-screen background layers.
- Keep normal and pressed button asset pairs together.
- Gate center must equal arrow lane center.
- Every screen implementation requires screenshot visual comparison.

## Screen Map Summary

`config/screen_asset_map.json` contains these screens:

- `splash`
- `loading`
- `main_menu`
- `gameplay`
- `level_select`
- `pause`
- `level_complete`
- `level_failed`
- `daily_challenge`
- `shop`
- `settings`

## Known Asset Design Caveat

The master prompt requires compact gameplay assets for final board runtime, while the package screen map currently points gameplay gates to `gameplay/gates/large/` and the cell to `empty_beige_large.png`. Implementation must resolve this by using the master prompt for final gameplay board scale:

- Runtime board: compact cell/gate assets.
- Large gate/cell assets: tutorial, overlays, or larger illustrative views only.

No invented paths are allowed.
