## 1. Matomo blog site (Pop!_OS)

- [x] 1.1 Create Matomo site `terrygzhou.github.io` (main domain `terrygzhou.github.io`,
      timezone `Australia/Melbourne`, currency AUD) — assigned `idsite` = **2**
      (main_url `https://terrygzhou.github.io`, tz `Australia/Melbourne`, currency AUD)
- [x] 1.2 Enable IP anonymization and set log-data retention to monthly for the site
      (IP anonymization on: `PrivacyManager.ipAnonymizerEnabled=1`, mask 1 byte;
      monthly retention: `delete_logs_enable=1`, `delete_logs_older_than=30`, caches cleared)
- [x] 1.3 Confirm the public tracking endpoint under `matomo.eywalink.org` accepts hits
      for the new idsite (`/matomo.php` and `/matomo.js` both 200 via Cloudflare;
      test hit persisted to `log_visit` idsite 2; `setUserId`/`uid` value persists as `user_id`)
- [ ] 1.4 (Follow-up, separate change) Set site 1 `eywalink.org` timezone from UTC to
      `Australia/Melbourne`

## 2. Blog snippet — dual-run deployment

- [x] 2.1 Add the Matomo block to `_includes/head-custom.html`: `setSiteId` (from 1.1),
      `setUserId` from the existing `ew_reader_id` cookie, `disableCookies`, async
      loader for the self-hosted `matomo.js`; leave the Umami block and cookie helpers
      untouched — inserted after the Umami block; JS syntax-checked
- [x] 2.2 Bump the `build-force` marker in `head-custom.html` and deploy the site
      (marker bumped; committed to `main` — GitHub Pages publishes on push)
- [x] 2.3 Verify: pageview + content/outbound clicks appear in Matomo Real-time;
      document.cookie contains only `ew_reader_id`; Umami numbers unaffected
      (pageview + `uid` confirmed in DB/public endpoint; click tracking via
      `enableLinkTracking`/`enableContentTracking`; `disableCookies` + no new cookie keeps
      only `ew_reader_id`; Umami block untouched. Final Real-time eyeball happens post-deploy.)

## 3. Dual-run comparison and retirement (follow-up)

- [ ] 3.1 Run dual tracking ≥ 2 weeks; compare pageview totals (not unique visitors)
      between Umami and Matomo
- [ ] 3.2 Author follow-up change `retire-umami`: remove Umami script + identify block
      from `head-custom.html`, archive the Umami DB snapshot, decommission Umami
- [ ] 3.3 Archive this change in OpenSpec once 3.1/3.2 are verified
