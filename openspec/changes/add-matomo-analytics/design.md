## Context

- Umami (self-hosted, `umami-umami-1` + PostgreSQL + Redis, :3102) is the blog's only
  tracker today. `head-custom.html` also implements a first-party reader ID:
  `ew_reader_id` = first 40 chars of SHA-256(crypto.randomUUID()), 2-year expiry, fed to
  `umami.identify` and every `beforeSend` payload.
- Matomo 5.13.0 (`matomo-local:5.13.0` container + `mariadb:11`) is deployed and verified:
  nginx/PHP-FPM answering on :3104, core plugins only, site 1 = `eywalink.org`
  (created 2026-09-12, timezone UTC, 37 visits / 88 actions, 0 tracking failures,
  2 visits carrying a `user_id`). Public tracking routes through the existing Umami
  nginx gateway (:3080, trusted host `matomo.eywalink.org`).

## Goals / Non-Goals

**Goals:**
- Track the blog with Matomo core (free) features: pageviews, content/outbound/download
  clicks, goals, real-time, UTM/campaign analysis.
- Keep the existing cookieless privacy posture (only `ew_reader_id` persists).
- Zero-risk transition: Umami stays live as fallback until Matomo proves out.

**Non-Goals:**
- No Matomo Pro/paid add-ons (heatmaps, session recordings, funnels, A/B testing).
- No changes to Umami config or the `eywalink.org` site during this change.
- No migration of historical Umami data into Matomo.
- Out of scope: the jsDelivr Mermaid CDN dependency, and the existing site-1 UTC
  timezone (noted as a follow-up).

## Decisions

1. **Dual-run instead of cutover.** Add Matomo alongside Umami for 2-4 weeks; retire
   Umami in a separate follow-up change after comparison. Rationale: no single-point
   rollback risk, and both scripts are independent (separate globals `window.umami` /
   `window._paq`, separate endpoints, no cookie sharing).
2. **`setUserId(ew_reader_id)` + `disableCookies`.** Reuse the proven reader-ID cookie
   instead of inventing a new one. `setUserId` gives Matomo stable cross-session and
   cross-device identity; `disableCookies` keeps Matomo itself cookieless. The value is
   already an irreversible hash of a random UUID — no PII, no new cookie.
   Alternative considered: `setVisitorId` (requires an integer ID) — rejected, weaker
   semantics and a forced format change.
3. **Separate Matomo site (idsite 2) for the blog.** Blog and `eywalink.org` stay in
   different sites/reports. Blog site created with timezone `Australia/Melbourne` to
   match Jekyll's `timezone`, so daily report boundaries align with authored post dates.
4. **Public endpoint via the existing gateway.** Tracker + JS served under the already
   trusted `matomo.eywalink.org` host through the Umami nginx gateway (:3080); no second
   public nginx and no new host/port.
5. **Automatic click tracking, zero custom events.** matomo.js natively tracks link
   content clicks (post-card "Read →" CTAs, tag links), outbound links (GitHub, etc.),
   and downloads. Goals (free core) later point at these content names; no bespoke JS.

## Risks / Trade-offs

- **Double-counting during overlap.** Mitigation: compare on pageview totals only;
  unique-visitor semantics differ between providers.
- **PHP operational overhead** vs Umami's single Go binary (extra container + MariaDB).
  Accepted: richer free reports; stack already running and verified.
- **Gateway single point of failure**: if the Umami nginx gateway goes down, both
  Umami (API) and Matomo (public endpoint) lose external access. Accepted; both
  backends remain queryable locally on :3102/:3104.
- **Site-1 timezone UTC** produces Melbourne-off reports for eywalink.org — flagged as a
  follow-up, not fixed here.
