# Localization Plan

Review date: 2026-06-23

## Canonical Registry

All user-visible strings originate in:

```text
localization/source_strings.yaml
```

Each entry must contain:

- key
- English source
- Turkish translation
- translator context
- maxLength
- placeholders
- plural/select metadata
- translatable true/false
- screen

## Generated Outputs

- `lib/l10n/app_en.arb`
- `lib/l10n/app_tr.arb`
- `android/app/src/main/res/values/strings.xml`
- Android plural resources
- `ios/Runner/en.lproj/Localizable.strings`
- `ios/Runner/tr.lproj/Localizable.strings`
- `.stringsdict` files for plurals
- `localization/keys.json`
- `docs/LOCALIZATION_CATALOG.csv`

## Android Gemini Architecture

Google Play Gemini app-string translation reads `strings.xml` from a draft AAB. Android `strings.xml` must exist for Gemini compatibility and native Android text, but Flutter runtime UI uses generated `AppLocalizations` / ARB resources as its primary localization source.

Planned architecture:

1. Generate Android `strings.xml` and plurals from `source_strings.yaml`.
2. Generate Flutter ARB files from the same catalog.
3. Flutter widgets and game overlays read generated `AppLocalizations`.
4. Native Android resource lookup is reserved for native platform UI, notification channels, permission/platform descriptions, and explicitly documented native integrations.
5. Do not implement a Pigeon localization bridge in Phase 1.
6. Tests verify key parity across ARB, Android resources, iOS resources, and `keys.json`.
7. Store brand and technical exclusions as `translatable=false`.

## iOS Architecture

- Generate `Localizable.strings` and `.stringsdict` from the same source registry.
- Use Flutter ARB for the primary widget tree unless a native UI requires iOS resources.
- Support English and Turkish initially.
- Keep import path for additional translations.
- Add RTL pseudo-locale tests before release.

## Hard-Coded Text Baseline

The default Flutter template text has been removed from `lib/main.dart`. Phase 1 has no production Flutter UI, so no user-visible Flutter text should exist outside future generated localization resources.

## Google Play Gemini Setup Doc

See `docs/GOOGLE_PLAY_GEMINI_TRANSLATION_SETUP.md`.
