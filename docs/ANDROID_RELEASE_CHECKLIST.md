# Android Release Checklist

Review date: 2026-06-23

- Configure application ID and signing.
- Lock portrait orientation.
- Add native splash.
- Generate `strings.xml` and plurals from localization registry.
- Verify Gemini app-string translation flow in Play Console.
- Configure AdMob app ID and ad unit IDs via config.
- Configure UMP privacy messages and consent partners.
- Configure Unity and Meta mediation in AdMob.
- Add Play Games Services v2 project ID in Android resources/manifest.
- Configure achievements, leaderboards, and Saved Games.
- Configure Play Billing products.
- Configure Data Safety.
- Configure store listing, screenshots, and feature graphic.
- Validate test ads in debug and production IDs only in release config.
- Run `flutter build appbundle`.
- Upload draft AAB and test internal track.
