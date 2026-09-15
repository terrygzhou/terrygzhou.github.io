## Purpose
Defines how the blog tracks web analytics: the Umami + Matomo dual-run provider
configuration, reader identity mapping, the cookieless tracking posture, and the
transition/retirement policy.

## ADDED Requirements

### Requirement: Dual-Provider Tracking
Every blog page MUST load both the Umami script (unchanged) and the Matomo tracker.
The Matomo tracker MUST report pageviews and MUST rely on matomo.js built-in tracking
for content clicks, outbound links, and downloads; no custom event script is required.

#### Scenario: Pageview recorded by both providers
- **WHEN** a visitor loads any blog page after deployment
- **THEN** a Umami pageview AND a Matomo pageview are each recorded for the visitor's
  session on their respective backends

#### Scenario: Clicks tracked without custom code
- **WHEN** a visitor clicks a post-card "Read →" CTA, a tag link, or an outbound
  GitHub link
- **THEN** Matomo records the content/internal/outbound click automatically via
  matomo.js built-in click tracking

### Requirement: Reader Identity
Matomo MUST identify readers via `setUserId` using the existing first-party
`ew_reader_id` cookie value (SHA-256 of a random UUID, first 40 chars). No new
cookie or PII field MUST be introduced.

#### Scenario: Returning reader identified
- **WHEN** a visitor with an existing `ew_reader_id` cookie loads a page
- **THEN** the Matomo hit carries that value as the user id, matching prior visits

#### Scenario: First-time visitor
- **WHEN** a visitor has no `ew_reader_id` cookie
- **THEN** the visitor is created exactly as today (cookie helpers set it) and the
  Matomo hit carries that value once the cookie exists; no tracking is blocked or
  dropped

### Requirement: Cookieless Tracking Posture
Matomo MUST NOT set its own cookies on the blog. `ew_reader_id` MUST remain the only
cookie set by the site.

#### Scenario: Cookie audit
- **WHEN** a visitor loads a blog page with Matomo deployed
- **THEN** the document.cookie set contains at most `ew_reader_id` and no Matomo-owned
  cookie

### Requirement: Matomo Blog Site Configuration
A Matomo site for `terrygzhou.github.io` MUST exist with timezone
`Australia/Melbourne`, IP anonymization enabled, and log-data retention capped at one
month. No paid Matomo add-ons MUST be installed.

#### Scenario: Site created
- **WHEN** the blog's Matomo `setSiteId` is resolved in the Matomo database
- **THEN** a site row exists with name `terrygzhou.github.io`, timezone
  `Australia/Melbourne`, and the tracking endpoint accepts hits for that idsite

#### Scenario: Free features only
- **WHEN** the deployed Matomo plugin set is inspected
- **THEN** only core (free) plugins are installed; no Pro add-ons such as heatmaps,
  session recordings, funnels, or A/B testing

### Requirement: Dual-Run Transition and Retirement
The Umami tracker MUST remain active for a dual-run of at least two weeks after
Matomo deployment. Umami retirement MUST be a separate follow-up change that begins
only after the dual-run comparison.

#### Scenario: Retire Umami after a clean dual-run
- **WHEN** two weeks of dual-run data confirm Matomo pageview parity
- **THEN** a follow-up change removes the Umami script block from
  `head-custom.html`, leaving Matomo as the sole tracker and archiving the Umami
  backend

## Verification (manual, dual-run comparison)

During the overlap, compare the two backends on **pageview totals** only — unique-
visitor semantics differ between Umami and Matomo and must not be compared directly.
