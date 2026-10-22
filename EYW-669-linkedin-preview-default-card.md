# LinkedIn link preview renders the EyWALink default card instead of the post diagram

**Repo:** `terrygzhou/terrygzhou.github.io` (legacy GitHub-managed Jekyll + `pages-themes/architect`)
**Affected post:** `2026-10-21-intelligence-is-a-system-not-a-model` (permalink `/2026-10-21/intelligence-is-a-system-not-a-model`)
**Date:** 2026-10-22 (AEST)
**Type:** ADR-style Type 2 — two-way door (content/meta only, no site rebuild risk)
**Status:** fixed & deployed — 2 commits, both Pages builds green, live-verified

---

## Symptom

The LinkedIn link preview for the post showed a dark-navy **EyWALink-branded card** (EYwALink wordmark + teal logo) instead of the post's own four-layer "AI System Layers" diagram. On a personal post, the preview read as brand-marketing.

## Root cause

The post front matter had **no per-post `image:` field**. The site's `_includes/head-custom.html` then fell back to a hardcoded default for **both** social protocols:

```
<meta property="og:image"    content="{{ page.image | default: '/assets/og-default.png' | absolute_url }}" />
<meta property="twitter:image" content="{{ page.image | default: '/assets/og-default.png' | absolute_url }}" />
<meta name="twitter:site" content="@EYwALink" />
```

- `/assets/og-default.png` is a **600×315 EyWALink-branded card** (confirmed: `PNG 600 x 315 RGB`).
- `twitter:site` is **hardcoded to `@EYwALink`**, so the handle/brand association is EyWALink too.

**Why LinkedIn specifically:** LinkedIn's link-preview engine reads **Twitter Card** metadata (`twitter:card`, `twitter:image`, `twitter:site`), *not* the Open Graph tags. So even though `og:image` and `twitter:image` would have pointed at the same place, the absence of a per-post image meant both fell back to the EyWALink `og-default.png`. The card therefore carried EyWALink branding on three axes: image, `twitter:site` handle, and the post description ("…where EyWALink's products fit").

A second latent defect: the head emitted `og:image:width/height` = `600×315` **unconditionally** — wrong for any per-post image that isn't that exact size (the diagram is **1562×862**), and a wrong declared size can distort the preview.

## Options for fix

1. **Per-post `image:` front matter (chosen).** Add `image: /assets/2026-10-21-intelligence-is-a-system-not-a-model/ai-system-layers.png` to the post. Lowest-risk, targeted; uses the existing `page.image` hook that already exists in the head. **Recommended.**
   - Trade-off: every post that wants its own preview image must carry the field. Posts without it keep the EyWALink default card.
2. **Fix the default card itself** (make `/assets/og-default.png` a neutral/personal card). Fixes all image-less posts at once, but changes brand identity site-wide — not wanted here; the EyWALink default is intentional for EyWALink pages.
   - Trade-off: one change, many posts affected, brand regression risk.
3. **Change `twitter:site`** from `@EYwALink` to a personal handle. Removes the handle-level brand association. **Not done** — the site is currently branded EyWALink site-wide; flipping the handle is a separate, deliberate decision. Left as a flagged open item.

## What was done

- `_posts/2026-10-21-intelligence-is-a-system-not-a-model.md` — added the `image:` line (Option 1).
- `_includes/head-custom.html` — wrapped `og:image:width/height` in `{% unless page.image %}` so the 600×315 dims are only emitted for the default card, not per-post images.

## Verification (live)

- Live page now serves `og:image` **and** `twitter:image` = `https://terrygzhou.github.io/assets/2026-10-21-intelligence-is-a-system-not-a-model/ai-system-layers.png` (no 600×315 dims on it).
- `og_title == twitter_title`, `og_image == twitter_image` (consistent; only diff was a curly vs straight apostrophe in the description).
- Diagram returns HTTP 200, `image/png`, 213 KB, **1562×862**, `age: 0`.
- Default card (index, no `page.image`) still correctly emits 600×315 dims.
- Both commits pushed to `main`; Pages builds `39705690341` and `39705781257` completed **success**.
- Rendered the card from the live meta tags in a browser — image = four-layer system diagram, not the navy card.

## Remaining / open items

- **LinkedIn cache.** Delete the LinkedIn post and re-paste the link — LinkedIn re-fetches the card on new post creation; re-pasting the same URL into an existing post will not refresh it. This step requires the user's LinkedIn account (private crawler).
- **Description copy.** Still ends "where EyWALink's products fit" — visible EyWALink reference in the preview text. Left as-is (product positioning). Neutralise only if the preview should read purely personal.
- **`twitter:site`** still `@EYwALink` site-wide — decide whether a personal handle is wanted (Option 3 above).

---
*Recorded by: Hermes (default profile). Filed in the Blog project workspace, matching the EYW-622 triage-note convention.*
