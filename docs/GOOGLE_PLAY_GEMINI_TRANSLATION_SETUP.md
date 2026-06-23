# Google Play Gemini Translation Setup

Review date: 2026-06-23

## Why This Exists

Play Console Gemini app-string translation is based on the latest `strings.xml` in a draft AAB. Flutter ARB files remain the primary runtime source for Flutter UI, while Android resources must still be generated for Play Gemini compatibility and native Android text.

## Required Flow

1. Generate `android/app/src/main/res/values/strings.xml` from `localization/source_strings.yaml`.
2. Build an Android App Bundle.
3. Upload the AAB to a draft release in Play Console.
4. Go to Grow users > Translations > App strings.
5. Start app string translation.
6. Add the currently appropriate languages offered by Play Console.
7. Do not hard-code a fixed language count, because availability changes.
8. Exclude brand and technical strings using `translatable=false`.
9. Preview RTL layouts.
10. Use the built-in emulator preview.
11. Download/review generated translations where available.
12. Test translations on every release draft.

## App Requirement

Flutter runtime UI must use generated `AppLocalizations` / ARB resources as the primary source. Android resource lookup is reserved for native Android UI, notification channels, permission/platform descriptions, or explicitly documented native integrations. Do not add a Pigeon localization bridge in Phase 1.

## Manual Console Setup Still Required

- Play Console app entry
- Draft release track
- App signing
- Gemini app strings activation
- Language selection
- Translation review workflow
