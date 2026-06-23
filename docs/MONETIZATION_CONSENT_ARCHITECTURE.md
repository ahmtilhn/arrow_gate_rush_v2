# Monetization and Consent Architecture

Review date: 2026-06-23

## Consent Sequence

1. Startup loads local config and save.
2. UMP consent information is updated every launch.
3. If required, official UMP form is shown.
4. Privacy Options entry point appears in Settings when required.
5. On iOS, ATT is requested only at an appropriate value moment and in the correct order with GDPR consent.
6. Ads initialize/request only when `canRequestAds()` permits.
7. If consent or ATT is denied, gameplay remains fully available.

## Ad Architecture

- Primary SDK: AdMob through `google_mobile_ads`.
- Unity Ads: AdMob mediation only.
- Meta Audience Network: AdMob mediation only.
- No direct Unity or Meta ad load/show calls.
- Debug builds use Google test IDs and test devices.
- Production IDs live in environment/config layers, not UI/game code.

## Placements

Rewarded:

- Continue.
- Hint.
- Double Coins.
- Booster refill.

Interstitial:

- None in first five levels.
- Never during gameplay.
- Only after result overlay and player Next/Retry action.
- Default cap: every four completed levels and at least 120 seconds apart.
- Never immediately after rewarded continue.

Banner:

- Never on gameplay.
- Optional adaptive banner on Level Select or Shop with reserved space.
- Removed by `remove_ads`.

App Open:

- Disabled for initial release.

## Meta App Events

Meta App Events is separate from Meta ad mediation.

Wrap in `MetaEventsService`, consent-aware, with no PII:

- `app_open`
- `tutorial_start`
- `tutorial_complete`
- `level_start`
- `level_complete`
- `level_failed`
- `perfect_tap`
- `hint_used`
- `rewarded_ad_started`
- `rewarded_ad_completed`
- `purchase_started`
- `purchase_completed`
- `remove_ads_purchased`
- `daily_challenge_completed`

## Manual Setup Required

- AdMob app and ad unit IDs.
- Unity mediation network setup in AdMob.
- Meta mediation bidding setup in AdMob.
- UMP privacy message configuration and partner list.
- iOS ATT purpose string review.
- Play Data Safety and App Store Privacy labels.
- Meta developer app setup if App Events is enabled.
