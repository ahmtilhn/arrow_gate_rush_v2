# Platform Integration Matrix

Review date: 2026-06-23

| Area | Android | iOS | Shared rule |
|---|---|---|---|
| Localization | `strings.xml` and plurals for Gemini/native Android text; Flutter UI remains ARB-primary | `Localizable.strings`, `.stringsdict`, ARB fallback | One source registry generates all outputs. |
| Consent | UMP consent update every launch; privacy options if required | UMP plus ATT ordering; localized `NSUserTrackingUsageDescription` | No ad request until consent allows. |
| Ads | AdMob app/ad unit IDs in config; Unity/Meta via mediation adapters | AdMob app/ad unit IDs in config; Unity/Meta via mediation adapters | No direct Unity/Meta ad calls; debug uses test ads. |
| App tracking | Android consent and Play data safety disclosures | ATT prompt via native/API after consent sequence | Denial cannot block gameplay. |
| IAP | Google Play Billing through `in_app_purchase` | StoreKit through `in_app_purchase` | Product IDs in config; prices from store. |
| Remove ads | Non-consumable entitlement disables banners/interstitials | Same | Rewarded opt-in remains available. |
| Platform games | Play Games Services v2 achievements, leaderboards, Snapshots | Game Center/GameKit achievements, leaderboards, saved games | Sign-in non-blocking; offline queue. |
| Cloud save | PGS Saved Games binary payload plus metadata | GameKit/iCloud saved games | Conflict UI with local/cloud timestamp summary. |
| Review | Play In-App Review API | StoreKit review request | Eligibility gated; prompt visibility not assumed. |
| Updates | Play Core flexible/immediate update | Store availability banner/link | Never interrupt active gameplay. |
| Store privacy | Data Safety form | App Privacy Details | Disclosures include SDK partners. |
| Touch target | 48x48dp minimum | 44x44pt minimum | Board scales to preserve usability. |

## Native Bridges

- No Pigeon localization provider in Phase 1. Native Android resource lookup is only for native/platform text.
- Platform games/save: Pigeon or official native plugin if verified current.
- Meta App Events: native bridge or verified maintained Flutter package after current-doc check.
- AdMob/UMP/IAP/review: official Flutter packages where sufficient.
