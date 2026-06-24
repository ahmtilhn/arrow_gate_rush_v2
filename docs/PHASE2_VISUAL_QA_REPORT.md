# Phase 2 Visual QA Report

## Generated asset previews

The PNG files previously stored directly under `docs/visual_qa/phase2/` were produced by copying individual supplied assets during a test. They are useful as asset fixtures only. They are **not screenshots from a running Flutter or Flame application** and are not authoritative visual evidence.

These historical files must be treated as the contents of the logical category:

`docs/visual_qa/phase2/generated_asset_previews/`

They remain in their original paths to avoid rewriting binary history, but no report or test may describe them as runtime captures.

## Live Android runtime captures

Authoritative evidence is produced by:

`tool/capture_phase2_android_screenshots.ps1`

Expected output:

`docs/visual_qa/phase2/runtime_android/`

Required files are `01_loading.png` through `13_visual_debug_level.png`, plus `capture_manifest.json`. Each PNG must be captured from an Android emulator or physical device framebuffer with `adb shell screencap -p`.

## Runtime scoring

No runtime score is assigned until the live Android artifact is available and inspected. The following categories must each be scored from 0 to 5:

- garden background composition
- stone board quality
- beige cell clarity
- glossy arrow quality
- gate quality
- gate alignment readability
- HUD readability
- safe-area layout
- visual feedback clarity
- consistency with supplied style
- absence of default Material appearance
- absence of checkerboard or baked backgrounds
- absence of clipping
- absence of stretched sprites
- touch-target readability

Any category below 4 requires a correction or a documented production-art limitation.

## Current status

**Phase 2 implemented but not fully accepted.** Live Android frames and manual inspection are still required. Generated asset previews must never be used to satisfy this requirement.
