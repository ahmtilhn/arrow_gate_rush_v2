# Economy Model

Review date: 2026-06-23

## Principles

- The game remains completable without payment.
- IAP provides convenience, speed, or cosmetics, not mandatory solutions.
- No paid random loot boxes.
- Store prices are runtime values from Google Play/App Store, never baked art or Dart literals.

## Soft Currency: Coins

Sources:

- Level completion: 25-40 base.
- Star/perfect bonus: 0-25.
- Daily Challenge.
- Daily streak.
- Optional rewarded double reward.
- Achievements/milestones.

Sinks:

- Hint: initial target 150.
- Undo refill: 100.
- Slow Time: 200, feature-gated until asset/UI support exists.
- Themes/cosmetics.

Early balance:

- First 10 levels should grant enough coins for 2-3 hints.
- First taught hint is free.
- Scarcity is not introduced in the first session.

## Premium Currency: Gems

Sources:

- IAP.
- Rare milestones.
- Daily streak/challenge.
- Limited free drip.

Sinks:

- One-time continue: 5.
- Booster bundles.
- Premium cosmetics.
- Coin conversion.

## IAP Products

Config placeholders:

- `remove_ads` non-consumable.
- `coins_small`, `coins_medium`, `coins_large` consumables.
- `gems_small`, `gems_medium`, `gems_large` consumables.
- Optional cosmetic packs as non-consumables.

## Simulation Requirement

Create `tool/economy_simulator.dart` before final economy tuning. It must simulate at least 100 levels with configurable player skill, hints, fails, rewarded ads, and purchases disabled by default. The output must report earned/spent balance and identify scarcity spikes.

## Storage

Economy defaults belong in:

```text
assets/config/economy_balance.json
```

Optional Remote Config may override safe numeric defaults but local config must keep the game fully playable offline.
