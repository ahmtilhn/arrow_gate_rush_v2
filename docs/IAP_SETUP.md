# IAP Setup

Review date: 2026-06-23

## Products

- `remove_ads`: non-consumable.
- `coins_small`, `coins_medium`, `coins_large`: consumables.
- `gems_small`, `gems_medium`, `gems_large`: consumables.
- Optional cosmetic packs: non-consumables.

## Manual Setup

- Create products in Play Console.
- Create products in App Store Connect.
- Configure tester accounts.
- Verify localized store prices.
- Document server validation or server-notification production plan.

## Runtime Rules

- Product IDs in config.
- Prices from store APIs.
- Idempotent consumable grants.
- Restore non-consumables.
- Handle pending, canceled, error, and restored states.
