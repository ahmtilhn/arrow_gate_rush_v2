# Competitor Findings

Review date: 2026-06-23

Format: `Complaint -> Our design response -> Acceptance test`

| Complaint | Our design response | Acceptance test |
|---|---|---|
| Excessive ads or ads during a level | No ads during active gameplay. No interstitials in first five levels. Interstitials only after result screen and player action. | Automated ad frequency test verifies no ad request while `gameState` is `ready`, `gateRotating`, `evaluatingTap`, `arrowLaunching`, or `resolvingEffects`. |
| No one-time ad removal purchase | Add `remove_ads` non-consumable that removes banners/interstitials while keeping opt-in rewarded ads available. | Fake purchase integration test grants `remove_ads`, restarts app, and verifies banner/interstitial placements are disabled. |
| Accidental bottom-button taps wasting currency | Use clear hit regions, confirm costly actions where appropriate, and deduct only after success. | Widget tests verify booster/hint cost is charged only after hint display succeeds. |
| Small hit targets and adjacent-arrow mistakes | Board scales to preserve 48x48dp Android and 44x44pt iOS hit targets; hit areas cannot overlap cells. | Golden/widget tests inspect cell hit boxes on small phone layouts. |
| Levels perceived as unfair or unsolvable | Every level must pass independent solver validation before release. | Unit/property tests solve all bundled levels and reject generated unsolved levels. |
| Timer anxiety too early | Tutorial and Relax avoid real-time pressure; Classic introduces 4s then 3s and 2.5s intervals gradually. | Progression tests verify early levels have no harsh timer/life penalties. |
| Repetitive gameplay | Introduce mechanics gradually: colors, moving gates, keys, frozen/chained arrows, portals, Daily seed. | Content audit verifies mechanic introduction schedule and recovery levels after hard clusters. |
| Wrong tap feedback feels vague | Distinct feedback for blocked path, no gate, wrong color, locked gate, frozen arrow, and input lock. | Move validator tests cover every invalid enum and UI event mapping. |
| Zoom or camera interaction causes unwanted taps | Initial release avoids zoom; board fits portrait safely. If zoom is later added, suppress taps immediately after pinch. | Input tests verify tap is ignored during/after gesture state transition. |
| Store prices or rewards feel misleading | Store prices come from platform APIs; no fixed price images; paid random loot boxes are banned. | Shop tests fail if a product price is hard-coded or read from image art. |

## Source Notes

- Google Play and App Store review snippets for tap-away/block-away games showed recurring complaints about excessive ads, accidental taps, and ad-removal expectations.
- Research on puzzle difficulty and procedural generation supports solver-driven generation and measured difficulty estimates rather than random fill-and-hope content.
