# AdMob Mediation Setup

Review date: 2026-06-23

## Architecture

- Use `google_mobile_ads`.
- AdMob is the only ad-loading API in the app.
- Unity Ads and Meta Audience Network are mediated in AdMob only.

## Manual Console Tasks

- Create AdMob app entries for Android and iOS.
- Create banner, interstitial, and rewarded ad units.
- Configure test devices.
- Configure Unity Ads mediation source.
- Configure Meta Audience Network bidding mediation source.
- Add all required consent partners to UMP configuration.
- Verify adapter status in Ad Inspector.

## In-App Rules

- Debug builds use test IDs.
- No production IDs in UI/game code.
- No banner or interstitial during gameplay.
- Reward only from `onUserEarnedReward`.
- Dispose/reload full-screen ads through callbacks.
