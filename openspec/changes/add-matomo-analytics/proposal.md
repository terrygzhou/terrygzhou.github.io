## Why

The blog currently tracks only Umami pageviews (`_includes/head-custom.html:84-131`): no click,
goal, or campaign (UTM) analytics exist anywhere on the site. A self-hosted Matomo 5.13.0
(core/free plugins only) is already deployed on Pop!_OS (`matomo` + `matomo-mariadb`
containers, host port 3104, public endpoint via the existing nginx gateway) and verified
working (0 tracking failures). Adding Matomo to the blog — alongside Umami as a fallback —
gives content/outbound click tracking, goals, real-time, and UTM analysis, all on free
features only, all local, matching the site's "everything on one home server" stance.

## What Changes

- **Matomo site**: create site `terrygzhou.github.io` in Matomo (timezone Australia/Melbourne
  to match `_config.yml`, IP anonymization on, monthly log-data retention).
- **Blog snippet**: add a Matomo tracking block to `_includes/head-custom.html`:
  - `setSiteId` for the new blog site
  - `setUserId` fed from the existing first-party `ew_reader_id` cookie (SHA-256 of a
    random UUID, 2-year expiry, no PII) — replaces the Umami `identify` hack for Matomo
  - `disableCookies` — Matomo sets no cookies; `ew_reader_id` remains the only cookie
  - matomo.js automatic content/outbound-link/download click tracking (zero extra JS)
- **Dual-run**: the Umami script + `ew_reader_id` cookie helpers stay untouched for a
  2-4 week overlap; Umami retirement is a separate follow-up change.
- **No paid add-ons**: heatmaps, funnels, A/B, and other Matomo Pro features are explicitly
  not installed.

## Capabilities

### New Capabilities
- `analytics-tracker`: site web-analytics tracking — provider configuration (Umami +
  Matomo), reader identity mapping, cookieless tracking posture, and the dual-run
  transition/retirement policy.

### Modified Capabilities
<!-- none: no existing spec-level capabilities -->

## Impact

- **Code**: `_includes/head-custom.html` (add ~25-line Matomo block + loader; Umami block
  and cookie helpers unchanged).
- **Infrastructure**: one new Matomo site row + site settings in `matomo-mariadb`
  (idsite 2); gateway routing unchanged (endpoint already trusted as
  `matomo.eywalink.org`); no new public ports.
- **Data/privacy**: no PII collected; single first-party cookie unchanged; no Matomo
  cookies; IP anonymization on; log retention capped monthly.
- **Reports**: during dual-run, compare on pageview totals (unique-visitor semantics
  differ between providers and must not be compared).
