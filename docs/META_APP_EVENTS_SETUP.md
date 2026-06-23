# Meta App Events Setup

Review date: 2026-06-23

Meta App Events is separate from Meta Audience Network mediation.

## Manual Setup

- Create or configure Meta developer app.
- Add Android package and iOS bundle.
- Configure platform SDK settings.
- Review privacy and consent requirements.
- Verify no PII is sent.

## Implementation Plan

- Wrap all calls in `MetaEventsService`.
- Gate event sending on consent/ATT state.
- Use native bridge or a currently verified maintained Flutter package.
- Keep event names and properties in config.
- Add fake service tests.
