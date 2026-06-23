# Google Play Data Safety Draft

Review date: 2026-06-23

Final answers depend on SDK configuration and analytics choices.

Likely data areas to review:

- Advertising ID or device identifiers through ads/attribution if enabled.
- Purchases through Play Billing.
- Gameplay analytics events if enabled.
- Crash/performance diagnostics if added later.
- Cloud save payload through Play Games Services.

Principles:

- No PII in custom analytics.
- No per-frame analytics.
- Gameplay remains available when optional network services fail.
- Disclosures must match final SDK behavior.
