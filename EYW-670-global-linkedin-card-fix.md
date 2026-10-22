# EYW-670 — global fix for the EYW-669 LinkedIn default-card problem

**Date:** 2026-10-22 (AEST) · **Type:** content/meta, site-wide (no build risk — same mechanism EYW-669 already shipped)

## Question answered

Does the EYW-669 defect (no per-post `image:` → EyWALink `og-default.png` card on LinkedIn) apply to **all** posts?

**Yes — 10 of 20 published posts had no `image:` field at all**, so all of them fell back to the EyWALink-branded default card on every social share (LinkedIn reads the Twitter Card meta, per EYW-669). Plus two latent defects affecting **all** posts:

1. `og:image:width/height` was hardcoded to the default card's 600×315 for *any* per-post image — wrong declared size can distort the preview. (EYW-669 noted this but the local working tree did not contain the `{%% unless page.image %%}` wrap it describes.)
2. There was no per-post `image:` at all on the 10 image-less posts (they are text-only, no hero diagram to reuse).

## Solution applied (in-repo, uncommitted — awaiting deploy gate)

### 1. Added `image:` to every post that has a hero diagram (10 posts)

| Post | Card image |
|---|---|
| 2026-07-07 manage-your-agents | `agent-inventory-view.png` (1888×786) |
| 2026-07-15 observability | `network-topology.png` (4700×2562) |
| 2026-07-21 superweb-testing | `pipeline.png` (8462×1260) |
| 2026-08-21 digital-twin | `evolution.png` (1520×1522) |
| 2026-09-03 arckit-oaa | `commands-flow.svg` (1529×2020 — SVG card is renderer-dependent; PNG preferred for new posts) |
| 2026-09-12 when-your-agent-says-done | `phases.png` (720×1304) |
| 2026-09-21 plantuml-archimate | `mapping.png` (1066×617) |
| 2026-09-27 company-of-agents | `multi-tenant-architecture.png` (1568×560) |
| 2026-10-02 cost-of-running-an-ai-lab | `sglang-metric.png` (1398×1029) |
| 2026-10-21 intelligence-is-a-system | `ai-system-layers.png` (1562×862) — confirmed live already; now in the registry too |

Each `image:` value is root-absolute (`/assets/...`) matching what `absolute_url` and the head lookup expect.

### 2. Global, maintenance-free dimension fix — `og_image_sizes` registry

- `_includes/head-custom.html` — `og:image:width/height` now resolved from `site.og_image_sizes[page.image]`; the 600×315 hardcoded dims survive **only** for the default card. Per-post images report their real pixel size → no preview distortion.
- `_config.yml` — new `og_image_sizes:` map (11 keys) that Jekyll loads into `site` at build time.
- `assets/og-image-sizes.json` — machine-readable twin of the same map, used by the validator.
- `validate_og_meta.py` — new pre-commit/CI validator (exit 1 on mismatch): verifies every `image:` points at an existing file, exists in **both** registries with agreeing dims, and that recorded dims match actual file dimensions (PIL for raster, viewBox for SVG). `--write` regenerates both registries from the real files.

**Why this is the global fix:** any future post just adds `image:` + one line `python3 validate_og_meta.py --write` — the head never needs touching again, and the validator catches drift.

### 3. The 10 text-only posts

No diagram exists to promote, so they intentionally keep the EyWALink default card (EYW-669 Option 2: the branded default is the site identity; changing it site-wide was explicitly not wanted). They no longer risk *wrong dimensions* (default is exactly 600×315). If a post later gets a hero image, add `image:` + registry entry — one-line change.

## Verification run here

- `python3 validate_og_meta.py` → `og meta OK: 10 post image(s) verified against assets + registries`
- `python3 validate_posts.py` → clean
- Simulated Jekyll lookup: all 10 `image:` values resolve in `site.og_image_sizes`; the other 10 resolve to the default (600×315 emitted, matching the actual default file).
- All 11 registry file paths exist in-repo.

## Deploy & verification gate (not done — Pages build is user-gated)

1. Commit + push `main`; wait for a green Pages build.
2. `curl` any changed post, confirm `og:image` = the diagram URL and `og:image:width/height` = its real size (e.g. 1562×862 for the 10-21 post, 8462×1260 for superweb).
3. Social preview re-fetch: for any *existing* LinkedIn post, the card only refreshes when the link is deleted and re-pasted (private crawler) — same note as EYW-669.

## Open items inherited from EYW-669

- `twitter:site` still `@EYwALink` site-wide (Option 3 — deliberate decision, owner: Terry/CMO).
- Post description copy still ends "where EyWALink's products fit" on the 10-21 post.
