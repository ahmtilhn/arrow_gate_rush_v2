# Risks and Manual Setup

Review date: 2026-06-23

## Unresolved Input Risk

- User requested `Arrow_Gate_Rush_Codex_Master_Prompt_Bilingual.md` in the project root.
- That exact file was not present in the project root, Desktop, Downloads, or OneDrive Desktop search results.
- Available prompt read instead: `C:\Users\ahmet\Downloads\Arrow_Gate_Rush_Codex_Master_Prompt_EN.md`.
- Risk: if the bilingual file contains extra Turkish-specific requirements, this plan may need revision.

## Current Repo Risks

- Workspace is not a Git repository, so there is no commit/diff safety net.
- Default Flutter template code still contains hard-coded English text.
- No actual game architecture exists yet.
- No integration/golden/platform bridge tests exist yet.
- No macOS/Xcode validation was run in this Windows workspace.

## Manual Console Setup Still Required

- Play Console app, signing, internal testing, draft AAB.
- Play Gemini app strings translation setup.
- Play Games Services v2 project, achievements, leaderboards, Saved Games.
- Play Billing products.
- AdMob app/ad units, UMP messages, test devices.
- Unity and Meta mediation setup inside AdMob.
- Meta App Events developer configuration if enabled.
- App Store Connect app, signing, Game Center, IAP products, privacy labels.
- Store listing screenshots and preview assets.
- Terms, privacy policy, and support URLs.

## Technical Risks

- Android Gemini localization requires native resource bridge, not just Flutter ARB.
- Ads/IAP/platform games introduce SDK privacy disclosure obligations.
- Solver state space can grow quickly if independent gate speeds are added; initial release should use shared tick interval.
- Text-bearing asset images must not ship as localized runtime UI.
- Generated levels need property/fuzz testing before release.
