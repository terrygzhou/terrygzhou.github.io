# Web Presence Audit — eywalink.org

**Date**: 2026-08-10
**Auditor**: Growth & Product Strategist (EYW-58)
**Scope**: SEO, messaging, conversion paths, content gaps, technical health

---

## Executive Summary

| Area | Score | Notes |
|------|-------|-------|
| Messaging | B | Strong positioning, clear value props, good differentiation |
| Conversion | C- | Only one CTA on landing; contact form is the sole conversion path |
| SEO | C | No structured data, minimal meta, no OG image, thin internal linking |
| Content | B | 12 blog posts, good tags/categories, but blog points externally |
| Technical | B- | Fast (Cloudflare CDN), valid sitemap, hreflang, robots.txt |

---

## 1. Messaging Audit

### Strengths
- H1 "Your Model. Your Intelligence. Your Control." — clear, ownable positioning
- Tagline in footer: "Built by AI agents, for agents" — unique differentiator
- "Three Tiers. One Philosophy." framework — scannable service overview
- About page: "AI Lifecycle" model (Strategy → Safety → Development → Observability) — good framework

### Weaknesses
- No customer proof: zero testimonials, case studies, or logos on any page
- "Get Started" CTA links to contact form — no self-serve path (pricing, free trial, demo)
- Services page duplicates About page content with minor rewording
- No "Open Source" page referenced in footer — links to nowhere meaningful

### Recommendations
| Priority | Action | Impact |
|----------|--------|--------|
| P0 | Add 2-3 client testimonials or case study snippets | Trust signal for enterprise buyers |
| P1 | Create pricing page or "How We Work" page between services and contact | Reduce friction before contact |
| P1 | Replace "Open Source" footer link with a real OSS portfolio page | Credibility for open-source positioning |

---

## 2. Conversion Path Analysis

### Current Funnel
```
Landing page → "Get Started" (or "Book a Free Consultation") → Contact form → Email follow-up
```

### Issues
- Single conversion point (contact form). No secondary CTAs (newsletter, download, demo request)
- "Get Started" button on landing → Contact form. Label mismatch ("Get Started" implies self-serve)
- Blog page ends with "Full blog archive on terrygzhou.github.io" — leaks traffic to personal site instead of keeping user on eywalink.org
- No email capture / newsletter signup anywhere

### Recommendations
| Priority | Action | Conversion Impact |
|----------|--------|-------------------|
| P0 | Rename landing CTA to "Book a Consultation" or "Talk to Us" | Honest label = higher CTR |
| P0 | Add newsletter signup in footer or blog sidebar | Lead capture without commitment |
| P1 | Add "Download AI Strategy Checklist" as lead magnet | Qualify inbound leads |
| P2 | Blog CTA: embed contact form or "Let's Talk" at end of each post | Capture engaged readers |

---

## 3. Content Gaps

### Missing Pages
| Page | Why Needed | Priority |
|------|-----------|----------|
| Pricing / Engagement models | Enterprise buyers need budget signal before contacting | P0 |
| Case studies / success stories | Social proof for enterprise trust | P0 |
| Open Source portfolio | You claim OSS-first; show what you've built | P1 |
| FAQ | Pre-empt common enterprise objections | P1 |
| Team / About (expanded) | "Built by agents" is cool — show the human behind it | P2 |

### Existing Content Quality
- **About page**: Strong. AI lifecycle framework is differentiating. Good technical depth (TOGAF, APP, APRA, GDPR).
- **Services page**: Redundant with About. Should be a scannable services grid with links to dedicated service pages.
- **Blog**: 12 posts across May-Aug 2026. Good topical coverage (private AI, agents, observability). Tag taxonomy is comprehensive (30+ tags) but over-tagged — dilutes category signals.
- **Contact**: Solid. Has form + direct contact details + map.

---

## 4. SEO Audit

### Technical SEO
| Check | Status | Detail |
|-------|--------|--------|
| robots.txt | OK | Present, allows all, blocks /api/ and /admin/ |
| sitemap.xml | OK | 23 URLs, bilingual hreflang (en/zh), priorities set |
| canonical URL | OK | Self-referencing canonical on home page |
| SSL / HTTPS | OK | HSTS enabled, Cloudflare CDN |
| Page speed | OK | Cloudflare HIT cache, static site |
| Mobile | OK | Responsive, nav collapses |

### On-Page SEO
| Check | Status | Detail |
|-------|--------|--------|
| Page title | OK | "EYwALINK" on home; "About | EYwALINK" on pages |
| Meta description | OK | Present on home: "An AI-native organisation..." |
| H1 tags | OK | Single H1 per page |
| Open Graph title | OK | Matches page title |
| Open Graph description | OK | Matches meta description |
| Open Graph image | MISSING | No og:image tag — shared links will look bare on LinkedIn/Twitter |
| Twitter Card | MISSING | No twitter:card meta |
| JSON-LD structured data | MISSING | No schema.org markup (Organization, Article, BreadcrumbList) |
| hreflang | OK | en/zh pairs on sitemap |
| Favicon | UNKNOWN | Not checked |

### Critical SEO Fixes
| Priority | Fix | Estimated Effort |
|----------|-----|-----------------|
| P0 | Add og:image to all pages (600x315px branded image) | 30 min |
| P0 | Add JSON-LD Organization schema to footer | 20 min |
| P1 | Add JSON-LD Article schema to blog posts | 30 min |
| P1 | Add twitter:card meta tags | 10 min |
| P1 | Internal link from blog posts to relevant services/pages | 1 hr |
| P2 | Add BreadcrumbList schema | 20 min |
| P2 | Create /ai-strategy, /private-ai dedicated landing pages for service keywords | 2 hrs |

---

## 5. Navigation and UX

### Current Nav Structure
```
Home | About | Blog | Services | Contact
```
Language toggle + dark mode toggle. Clean and minimal.

### Issues
- Footer "Open Source" link has no dedicated page
- Blog page shows only 10 of 12 posts — no pagination or "load more"
- No search functionality on site
- No "How It Works" or process visualization

---

## 6. Competitive Differentiation

### What Works
- "Built by agents, for agents" is a unique angle — no competitor claims this
- Private AI + OSS positioning is credible (you actually use vLLM, Qdrant, LangGraph)
- Australian compliance angle (APP, APRA) — good for local enterprise buyers

### What's Missing
- No evidence of actual client work (logos, case studies, metrics)
- "Three Tiers" on landing is vague — what does "Front Deployed Engineering" mean to a non-technical buyer?
- Missing competitor comparison: how do you differ from Atlassian AI, Canva AI, or consulting firms?

---

## 7. Priority Action Plan (next 2 weeks)

### Week 1 — Quick Wins
- [ ] Add og:image (branded share image) to all pages
- [ ] Add JSON-LD Organization schema to footer
- [ ] Rename "Get Started" CTA to "Book a Consultation"
- [ ] Add newsletter signup form to footer
- [ ] Fix "Full blog archive" link (internal or remove)

### Week 2 — Medium Impact
- [ ] Create dedicated service landing pages (/ai-strategy, /private-ai, etc.)
- [ ] Add 2-3 case study / testimonial sections to About and Services
- [ ] Create Open Source portfolio page
- [ ] Add internal cross-links between blog posts and service pages
- [ ] Add JSON-LD Article schema to blog posts
