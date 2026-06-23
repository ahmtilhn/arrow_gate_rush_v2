# Phased Implementation Plan

Review date: 2026-06-23

## Phase 0: Audit and Planning

Status: complete for local planning, except bilingual master prompt file is unresolved.

Deliverables:

- Repository audit.
- Asset audit.
- Asset localization audit.
- Research audit.
- Competitor findings.
- Architecture plan.
- Localization plan.
- Platform integration matrix.
- Economy model.
- Level generation design.
- Gameplay state machine.
- Monetization and consent architecture.
- Release/setup planning docs.

## Phase 1: Core Prototype

- Replace template with app bootstrap skeleton.
- Add pure Dart models.
- Add `move_validator`.
- Add static gate lanes and exact alignment checks.
- Add first tutorial board data.
- Add unit tests for path, gate alignment, invalid enums, and double-tap lock.
- No ads, IAP, or platform services yet.

Exit tests:

- `flutter analyze`
- `flutter test`
- Move validator test suite.

## Phase 2: Timed Gameplay

- Gate timer and discrete lane rotation.
- Tap buffer.
- Lives and result state.
- Hint, undo, restart.
- Flame board rendering with supplied compact assets.
- Screenshot/golden baseline for gameplay.

Exit tests:

- Timing fairness tests.
- Widget/golden tests for gameplay.
- Solver-backed hint tests.

## Phase 3: Content

- First 50 handcrafted/designer-assisted levels.
- Solver and replay logs.
- Level generator.
- Difficulty estimator.
- Daily seed.

Exit tests:

- All bundled levels solved.
- Generated-level property tests.

## Phase 4: UI, Economy, Localization

- Main Menu, Mode Select, Level Select, Pause, Win/Fail, Shop, Settings.
- `localization/source_strings.yaml`.
- ARB/native string generation.
- Android `strings.xml`/plurals generation for Gemini and native text, with Flutter UI remaining ARB-primary.
- Economy config and simulator.
- IAP abstraction with fake tests.

Exit tests:

- Localization completeness.
- Hard-coded string scan.
- UI golden tests EN/TR/long/RTL.
- Economy simulator report.

## Phase 5: Ads and Platform Services

- UMP/ATT.
- AdMob.
- Unity and Meta mediation setup points.
- Meta App Events service.
- Play Games/Game Center.
- Cloud save conflict flow.
- Review/update services.

Exit tests:

- Fake ad frequency tests.
- Fake purchase tests.
- Platform bridge tests.
- Consent gating tests.

## Phase 6: QA and Release

- Golden/integration/performance coverage.
- Android/iOS release build validation.
- Store listing assets and screenshots.
- Data safety/privacy drafts finalized.
- Manual console setup completed.

Exit tests:

- `flutter analyze`
- `flutter test`
- `flutter test integration_test`
- Golden tests.
- Android release build.
- iOS archive/build validation on macOS.
