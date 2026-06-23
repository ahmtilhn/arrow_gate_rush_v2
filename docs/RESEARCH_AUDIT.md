# Research Audit

Review date: 2026-06-23

This document records the Phase 0 research decisions from official or primary sources checked before application coding.

## Engineering Sources

| Source | URL | Decision | Project impact |
|---|---|---|---|
| Flutter Casual Games | https://flutter.dev/games | Use Flutter with Flame for the 2D game loop and Flutter overlays for app UI. | Architecture separates pure Dart game state, Flame rendering, and Flutter UI. |
| Flame docs | https://docs.flame-engine.org/ | Use Flame component system, sprites, effects, particles, overlays, and testable game loop boundaries. | Rendering components must not own business state. |
| Flutter internationalization | https://docs.flutter.dev/ui/internationalization | Use `gen-l10n`, ARB files, plurals/selects/placeholders, and generated localizations. | ARB remains Flutter fallback and iOS/local testing path. |
| Flutter platform channels | https://docs.flutter.dev/platform-integration/platform-channels | Use Pigeon where useful for type-safe platform-service bridges. | Do not add a Pigeon localization bridge in Phase 1. |
| Android string resources | https://developer.android.com/guide/topics/resources/string-resource | Generate Android `strings.xml` and plurals for Gemini compatibility and native Android text. | Flutter UI remains generated `AppLocalizations` / ARB-primary. |
| Google Play Gemini app string translation | https://support.google.com/googleplay/android-developer/answer/9844778 | Play Console Gemini uses the latest `strings.xml` from a draft AAB. | Keep Android resources generated from the same canonical catalog; do not use them as primary Flutter runtime UI source. |
| Google Mobile Ads Flutter | https://docs.flutter.dev/cookbook/plugins/google-mobile-ads | Use `google_mobile_ads`; initialize SDK, configure app IDs, test IDs, and lifecycle. | Ads behind consent/config services, never in active gameplay. |
| AdMob UMP Flutter | https://developers.google.com/admob/flutter/privacy | Request consent information every launch and expose Privacy Options where required. | Ads cannot request until consent permits. |
| AdMob Meta mediation Flutter | https://developers.google.com/admob/flutter/mediation/meta | Meta Audience Network must be mediated through AdMob. | No direct Meta ad calls. |
| Google Play Games Services v2 | https://developer.android.com/games/pgs/android/migrate-to-v2 | Use v2 flow and Android manifest/string project ID setup. | Non-blocking sign-in plus saved games bridge. |
| Google Play Games Saved Games | https://developer.android.com/games/pgs/savedgames | Saved Games store binary data plus metadata and support offline writes. | Save payload must be small, versioned, conflict-aware. |
| Apple GameKit | https://developer.apple.com/documentation/gamekit | Use GameKit for achievements, leaderboards, and Game Center UI. | Native iOS bridge required. |
| Flutter in_app_purchase | https://pub.dev/packages/in_app_purchase | Use Flutter team IAP plugin for App Store and Google Play. | Store prices remain runtime values, product IDs in config. |
| Apple StoreKit | https://developer.apple.com/documentation/storekit | StoreKit handles App Store purchase processing. | iOS purchase behavior must support restore, pending/error, and validation plan. |
| Google Play In-App Review | https://developer.android.com/guide/playcore/in-app-review | Use native review eligibility without assuming prompt appears. | Review service cannot affect game state. |
| Android In-App Updates | https://developer.android.com/guide/playcore/in-app-updates | Android supports flexible/immediate update flows. | Initial plan uses flexible updates outside gameplay; iOS uses store redirect. |
| Google Play Data Safety | https://support.google.com/googleplay/android-developer/answer/10787469 | Disclose collection/sharing accurately. | Data safety draft must track ads, analytics, purchases, saves. |
| Apple App Review Guidelines | https://developer.apple.com/app-store/review/guidelines/ | Follow Safety, Performance, Business, Design, and Legal sections. | Consent, IAP, ads, privacy labels, and review prompts need conservative gating. |
| Apple App Privacy Details | https://developer.apple.com/app-store/app-privacy-details/ | Disclose data collected by the app and third-party partners. | App privacy draft must include SDK data practices. |
| Flutter performance | https://docs.flutter.dev/perf | Measure performance with real metrics. | Add frame timing and asset cache profiling in QA phase. |
| Android touch targets | https://support.google.com/accessibility/android/answer/7101858 | Use at least 48x48dp touch targets with spacing. | Board scales instead of shrinking hit targets too far. |
| Apple HIG buttons | https://developer.apple.com/design/human-interface-guidelines/buttons | Use at least 44x44pt hit regions. | iOS hit target tests must enforce 44pt minimum. |

## Package Versions Selected

Checked via pub.dev API on 2026-06-23.

| Package | Version selected | Reason |
|---|---:|---|
| `flame` | `^1.37.0` | Current Flame runtime for 2D component game. |
| `google_mobile_ads` | `^9.0.0` | Current official Google Mobile Ads Flutter plugin. |
| `in_app_purchase` | `^3.3.0` | Flutter team storefront-independent IAP API. |
| `pigeon` | `^27.1.0` | Type-safe native bridge generation. |
| `intl` | `^0.20.2` | Flutter localization support. |
| `shared_preferences` | `^2.5.5` | Settings only, not primary save integrity. |
| `path_provider` | `^2.1.6` | Local save file locations. |
| `equatable` | `^2.0.8` | Value objects in pure Dart game models. |
| `collection` | `^1.19.1` | Utility collections for solver/generator. |
| `app_tracking_transparency` | `^2.0.7` | iOS ATT prompt wrapper if native direct bridge is not chosen. |
| `in_app_review` | `^2.0.12` | Native in-app review wrapper. |
| `package_info_plus` | `^10.1.0` | App version display and diagnostics. |
| `url_launcher` | `^6.3.2` | Terms, privacy, support, store fallback links. |

## Research Impact

- The localization architecture must be source-registry-first; Flutter UI is ARB-primary, with generated Android/iOS native resources for platform/Gemini/native text parity.
- AdMob is the only ad request surface; Unity and Meta ads stay mediation-only.
- Meta App Events is separate from Meta ad mediation and must be consent-aware.
- Core gameplay logic must be pure Dart and independently testable.
- Generated levels require solver validation and maximum-wait constraints.
- Screens with text-bearing images must be composed with localized live text.
