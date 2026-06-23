# Repository Audit

Review date: 2026-06-23

## Current Tree

Project root is a fresh Flutter application with these top-level directories:

- `.dart_tool`
- `.idea`
- `android`
- `assets`
- `config`
- `docs`
- `ios`
- `lib`
- `linux`
- `macos`
- `test`
- `web`
- `windows`

The project is not currently a Git repository in this workspace, so change tracking must be done by file audit until Git is initialized.

## Current App State

- `lib/main.dart` is a neutral Phase 1 entry point with no user-visible text.
- The default Flutter counter widget test has been removed.
- Pure Dart Phase 1 gameplay core now lives under `lib/game_core/`.
- Gameplay unit tests now live under `test/game_core/`.
- The asset package has been extracted into the root with its exact package structure:
  - `assets/arrow_gate_rush/`
  - `config/`
  - `docs/`
  - `lib/generated/arrow_gate_assets.dart`
  - `README_START_HERE.md`
  - `CODEX_ASSET_INSTRUCTIONS.md`
- `pubspec.yaml` already contains:
  - `assets/arrow_gate_rush/`

## Immediate Technical Debt

- No production app shell exists yet under `lib/app`.
- No Flame rendering exists yet under `lib/game`.
- No services exist yet under `lib/services`.
- No localization registry exists yet under `localization`.
- No integration tests, golden tests, solver tests, or platform bridge tests exist yet.

## Master Prompt Authority

The authoritative project prompt is expected at:

```text
Arrow_Gate_Rush_Codex_Master_Prompt_Bilingual.md
```

As of this audit update, that exact file is not present in the project root. When it is placed there, it must be read completely before further implementation work. Conflict precedence:

1. `Arrow_Gate_Rush_Codex_Master_Prompt_Bilingual.md` is authoritative.
2. Its English technical section is authoritative over translated wording.
3. Existing planning documents may clarify the prompt but may not weaken or replace it.

## Validation Commands

```text
flutter analyze
No issues found! (ran in 1.0s)
```

```text
flutter test
Phase 1 game-core tests now replace the default counter test. See latest terminal output in the Phase 1 report.
```

## Planning Constraint

No full application coding should start until the Phase 0 documents are accepted. The next code phase must begin with core model and move-validation tests, not UI polish.
