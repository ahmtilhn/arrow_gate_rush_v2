# App Store Privacy Draft

Review date: 2026-06-23

Final App Privacy Details depend on SDK configuration and analytics choices.

Likely areas to review:

- Identifiers for ads/attribution if ATT/consent permits.
- Purchases through StoreKit.
- Gameplay analytics events if enabled.
- Crash/performance diagnostics if added later.
- Game Center/cloud save data if linked to account.

Principles:

- Respect ATT state.
- No PII in custom analytics.
- Keep privacy policy and App Store Connect answers aligned.
- Re-audit after every SDK addition.
