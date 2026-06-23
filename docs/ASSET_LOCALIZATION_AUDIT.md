# Asset Localization Audit

Review date: 2026-06-23

## Rule

Images with baked English text or fixed numbers cannot be final localized runtime UI. They may be used only when classified as runtime-safe, reference-only, or must be composed with live localized text.

## Runtime-Safe

These appear to be text-free or brand-safe runtime assets:

- Parallax backgrounds under `assets/arrow_gate_rush/backgrounds/parallax/`
- Decor, ground, and overlay assets under `assets/arrow_gate_rush/backgrounds/`
- Gameplay cells, frames, arrows, gates, obstacles, keys, and portals
- Effects under `assets/arrow_gate_rush/effects/`
- Common pill button skins when used with live localized text
- Text-free panels and progress frames
- Gem, chest, ticket, and daily-calendar icons when not used to imply paid random loot
- Brand logo assets, because `Arrow Gate Rush` is a non-translated brand

## Reference-Only

These should guide style but not be shipped as final localized UI where they contain baked wording or fixed presentation:

- `assets/arrow_gate_rush/ui/hud/level_complete_banner.png`
- `assets/arrow_gate_rush/ui/hud/game_over_banner.png`
- `assets/arrow_gate_rush/ui/dialogs/pause_panel.png`
- `assets/arrow_gate_rush/ui/dialogs/yes_no.png`
- `assets/arrow_gate_rush/ui/dialogs/ok_green.png`
- `assets/arrow_gate_rush/ui/dialogs/ok_red.png`
- `assets/arrow_gate_rush/ui/cards/coin_offer.png`
- `assets/arrow_gate_rush/ui/cards/gem_offer.png`
- `assets/arrow_gate_rush/ui/cards/shop_offer.png`
- `assets/arrow_gate_rush/ui/cards/level_unlocked_three_stars.png`
- `assets/arrow_gate_rush/ui/cards/level_unlocked_two_stars.png`
- `assets/arrow_gate_rush/ui/cards/level_locked.png`
- `assets/arrow_gate_rush/ui/hud/coin_counter.png`
- `assets/arrow_gate_rush/ui/hud/level_badge.png`
- `assets/arrow_gate_rush/ui/hud/score_panel.png`
- `assets/arrow_gate_rush/ui/hud/daily_progress_panel.png`

## Must Be Composed With Localized Text

- Level complete and failed result overlays
- Level badges and level numbers
- Level cards with dynamic numbers, stars, and lock state
- Store offers, prices, quantities, and sale labels
- Coin/gem counters and all numeric values
- Pause, confirmation, and result dialogs
- Loading tips and progress copy
- Accessibility labels for every image button and gameplay element

## Implementation Requirement

Compose final UI from text-free skins such as `ui/hud/ribbon_plain_red.png`, `ui/panels/square_stone_large.png`, `ui/panels/settings_row.png`, common pill button skins, icons, and live localized text from the canonical localization registry.
