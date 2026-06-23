# Architecture Plan

Review date: 2026-06-23

## Target Structure

```text
lib/
  main.dart
  app/
    app.dart
    bootstrap.dart
    router.dart
    config/
  game/
    arrow_gate_game.dart
    models/
    components/
    systems/
      move_validator.dart
      gate_rotation_system.dart
      solver.dart
      level_generator.dart
      difficulty_estimator.dart
      scoring_system.dart
      hint_system.dart
      undo_system.dart
    levels/
  ui/
    screens/
    overlays/
    widgets/
  services/
    ads/
    consent/
    analytics/
    purchases/
    platform_games/
    save/
    review/
    update/
    localization/
  l10n/
  generated/
localization/
tool/
test/
integration_test/
docs/
```

## Boundaries

- Pure Dart model layer owns board state, lanes, move validation, solver, generator, scoring, undo snapshots, and save payloads.
- Flame components render sprites and animations only.
- Flutter widgets render menus, overlays, shop, settings, localization text, and platform UI shells.
- Services are interfaces with fake implementations for tests.
- Native bridges use Pigeon for platform services only when a plugin's official API does not satisfy the requirement. Localization is ARB-primary for Flutter UI.

## Core Data Models

- `ArrowColor`: red, blue, green, yellow.
- `Direction`: up, down, left, right.
- `CellType`: empty, arrow, keyPickup, stoneObstacle, frozenArrow, chainedArrow, portalEntry, portalExit.
- `GateLane`: edge, direction, discrete slots, phase, queued tick state.
- `MoveResult`: valid, blockedPath, noGateAligned, wrongGateColor, lockedGate, frozenArrow, inputLocked.
- `LevelDefinition`: id, mode, grid, initial lanes, objectives, solution metadata, difficulty tags.
- `GameSnapshot`: board, lane phases, score, combo, keys, lives, elapsed time, star eligibility.

## Package Plan

- `flame`: runtime game scene and components.
- `google_mobile_ads`: AdMob ads, UMP, mediation status.
- `in_app_purchase`: store products and purchase stream.
- `pigeon`: Android/iOS bridge generation.
- `intl` plus Flutter localizations: ARB fallback and iOS/dev localization.
- `path_provider`: atomic save file paths.
- `shared_preferences`: lightweight settings only.

## Testing Architecture

- Unit tests first for `move_validator`, `gate_rotation_system`, `solver`, `level_generator`, `hint_system`, `undo_system`, economy, and localization key completeness.
- Widget/golden tests for screens after UI exists.
- Integration tests for tutorial, win/fail/continue, fake ad, fake purchase, save/restore, background/resume, offline, and localization resource parity.

## Non-Negotiables

- No user-visible text from Dart literals in production UI.
- No default Material icons as art replacement.
- No direct Unity or Meta ad SDK calls.
- No generated level can ship without solver pass.
- No ad in active gameplay.
