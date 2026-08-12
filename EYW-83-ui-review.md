# EYW-83: Blog UI Review — Post Listing Redesign

**Issue:** EYW-83
**Status:** In Review
**Reviewer:** AI Platform Operations Engineer
**Date:** 2026-08-10
**Scope:** Post listing page on https://terrygzhou.github.io/

## Current State Assessment

The live site renders as a dense bulleted list (`<ul>`) with:
- No visual hierarchy between posts
- Tight vertical rhythm — list items touch each other with no whitespace
- No preview content — titles alone don't help readers decide what to read
- Dated pattern — bulleted link lists feel like 2010-era blogs
- Tags exist in frontmatter but never display on the index page
- No hover feedback to signal clickability
- Typo in bio: "pratical" → "practical", "strateg." → "strategy."

## Three UI Options Prepared

### Option A: Card Grid (2-column)
- Two-column grid of cards with date, title, 3-line excerpt, and tags
- Hover lifts card with shadow and accent border
- Strongest visual impact — conveys professionalism and content volume
- **Pros:** Best scanning, shows content depth, modern look, mobile-friendly
- **Cons:** Medium implementation effort, lower density (6 posts/page)

### Option B: Vertical Timeline
- Single-column cards with connecting vertical line and dot markers
- Each entry is a distinct block with date, title, excerpt, tags
- Reads top-to-bottom like a story
- **Pros:** Chronological clarity, storytelling feel, lowest implementation cost
- **Cons:** Medium density (5 posts/page), less visual impact than cards

### Option C: Minimal List (Apple Notes style)
- Clean single-column list with right-aligned date, prominent title, one-line excerpt
- Thin horizontal dividers between items, subtle right-arrow on hover
- Most restrained option — prioritizes content density
- **Pros:** Highest density (8 posts/page), fastest to scan, cleanest aesthetic
- **Cons:** Subtle visual impact, least professional enterprise feel

## Recommendation

**Option A: Card Grid**

Why:
1. Best matches Terry Zhou's personal brand as an Enterprise Architect — professional, structured, modern
2. Shows content depth through excerpts, helping visitors quickly find relevant posts
3. Tags become visible, improving discoverability and topical navigation
4. Strong visual impact that differentiates from typical developer blogs
5. Mobile-friendly with 1-column fallback at smaller breakpoints

## Implementation Notes

- Target: Jekyll site using `minima` theme (via `remote_theme`)
- Files to modify: `index.html`, `_layouts/default.html` (if overridden), `_includes` for custom CSS
- Add custom `_sass` or `_css` for card styles
- Override `index.html` to use card grid instead of default minima post list
- Auto-generate excerpts from post content (first 120-150 characters)
- Display tags from frontmatter
- Fix bio typos while we're at it

## Effort Estimate

- Low to medium: ~2-3 hours of CSS + Jekyll template changes
- No backend changes needed — pure frontend presentation
- Deploy via existing `deploy.sh` pipeline

## Comparison Matrix

| Criterion | A: Card Grid | B: Timeline | C: Minimal List |
|-----------|-------------|-------------|-----------------|
| Visual impact | ★★★★★ | ★★★★☆ | ★★★☆☆ |
| Content scannability | ★★★★★ | ★★★★☆ | ★★★★☆ |
| Information density | Medium (6/page) | Medium (5/page) | High (8/page) |
| Implementation effort | Medium | Low | Lowest |
| Mobile experience | Good | Excellent | Excellent |
| Professional brand fit | Best — enterprise feel | Good — storyteller | Good — minimalist |
