---
layout: post
title: Open Agile Architecture Overlay is released for agile digital transformation
tags:
  - enterprise-architecture
  - open-agile-architecture
  - arckit
  - opengroup-c208
  - ai-agents
date: 2026-09-03
status: published
---
Last month I published [Executable Enterprise Architecture — Agentic-TOGAF-ADM](/blog/2026/07/01/executable-enterprise-architecture), where I showed how the **ArcKit** open-source project turned the TOGAF ADM into agent-readable slash commands and build recipes. The core insight: architecture frameworks stop being slide decks and become executable, auditable, repeatable workflows.

Today, I'm shipping a new ArcKit plugin that pushes this thesis one step further: **ArcKit OAA — the Open Agile Architecture (O-AA, [Open Group C208](https://pubs.opengroup.org/architecture/o-aa-standard/)) overlay.** It's a standalone plugin with 5 commands and the `oaa-full` build recipe for sprint-based, product-driven architecture delivery. And it raises a question worth answering directly: **when do you actually need TOGAF ADM, and when does agile O-AA do the job better?**

---

## Why a Second Overlay?

TOGAF ADM is a stage-gate machine. It works when you need a defensible, enterprise-wide baseline: regulatory audits, 50-stakeholder architecture boards, long multi-year migration programmes. But it's also *heavy*. If your deadline is 8 weeks and you have a cross-functional product team, a 200-page deliverable cycle is the wrong tool.

**[Open Agile Architecture](https://pubs.opengroup.org/architecture/o-aa-standard/) (C208)** — published by The Open Group in 2021 — addresses that gap. It takes the same axiomatic structure TOGAF started (16 axioms total, C208 extends axioms 11–16) but re-frames the delivery around **product teams, sprints, and value streams**. Instead of "Architecture Board meets quarterly," the governance unit becomes "sprint review panel." Instead of "Phase G transition architecture," you get "architecture items as first-class backlog entries."

In one sentence: **TOGAF ADM = enterprise baseline. O-AA C208 = sprint execution engine for the same baseline.**

---

## What's Inside arckit-oaa?

| Command | Doc Type | What it produces |
|---------|----------|------------------|
| `/arckit-oaa:oaa-adm-lite` | `OAAL` | Maps the ADM cycle to 2–4 week sprints (Sprint 0 vision → Sprint 4+ governance gates) |
| `/arckit-oaa:product-architecture` | `OAPR` | Product-centric architecture: team composition, outcomes KPI, backlog items, value stream |
| `/arckit-oaa:agile-strategy` | `OASTR` | Dual transformation canvas — legacy modernization + greenfield innovation, operating model shift |
| `/arckit-oaa:agile-security` | `OASEC` | Security embedded in sprint rhythm: threat model per sprint, compliance-as-code, AI bias checks |
| `/arckit-oaa:agile-governance` | `OAGOV` | Lightweight governance: pre/post-sprint checklists, architecture debt register, quarterly health score |

Recipe: `oaa-full` (5 phases: strategy → product → ADM Lite, plus optional security and governance targets).

```text
PRIN → REQ/STKE → OASTR/OAPR → OAAL → OASEC → OAGOV
```

Foundation commands (`arckit:principles`, `arckit:requirements`, `arckit:stakeholders`) must run first — same pattern as `arckit-togaf-adm`.

---

## OAA vs TOGAF ADM: The Real Difference

| Dimension | `arckit-togaf-adm` | `arckit-oaa` |
|-----------|--------------------|--------------|
| Standard | TOGAF ADM (traditional) | O-AA C208 (agile) |
| Commands | 9 (Preliminary → Phase H + Repository) | 5 (ADM Lite, Product, Strategy, Security, Governance) |
| Cadence | Quarterly architecture boards | 2–4 week sprint windows |
| Artefacts | 200-page deliverables | 1–2 page canvases, max 2/sprint |
| Delivery | Stage-gate (Preliminary → A → H) | Backlog-driven, iterative |
| Organisation | Enterprise-wide, component-focused | Product-centric, cross-functional teams |
| Security | Dedicated phase/gate | Backlog item per sprint |
| Governance | Formal architecture board | Sprint review panels, lightweight evidence |
| When to pick | Full regulatory audit, 50+ stakeholder gates | Hard deadline <8 weeks, agile culture |

**They are complementary, not competing.** Use `togaf-adm` for the enterprise baseline, then `oaa` to execute the capabilities at sprint velocity. One is the map; the other is the driving instruction.

---

## When to Use Which — A Quick Decision

1. **Regulatory / audit-driven enterprise programme, 50+ stakeholders, multi-year horizon** → `togaf-adm`. You need the formal traceability and stage gates.
2. **Product team, hard 8-week deadline, agile culture, cross-functional** → `oaa`. You need sprint cadence and lightweight evidence, not a quarterly board.
3. **Both** → run `togaf-adm` to set the baseline, then feed capabilities into `oaa` sprints. The baseline becomes the reference architecture; the sprints become the delivery rhythm.

---

## Why This Matters

1. **Agile isn't just for development teams.** Enterprise architecture has been stuck in stage-gate mode while the organisations it serves moved to product teams and quarterly OKRs. O-AA C208 is the Open Group's formal answer to that gap.
2. **Frameworks only matter when they ship.** Both overlays are open source, auditable, and community-driven. The rules, templates, and validation logic are forkable — no vendor lock-in.
3. **AI agents change the math — and the trust problem.** A 200-page TOGAF deliverable is a consultant's week of work. With an agentic toolkit, it's an overnight batch run. O-AA's 1–2 page canvases fit in a single sprint. But there's a second, subtler shift: *the agent is the author now, not the EA.* That's where the repo's structure matters.
4. **Guided control via opengroup standard-driven intake.** The [arc-kit codebase](https://github.com/terrygzhou/arc-kit) inserts a control layer between the AI agent and its output: a structured intake interview runs against each template's field schema (required sections, enum choices, cross-references) *before* the agent writes a single artefact line. The interview is the gate, the template is the guardrail, the agent fills the blanks — which is what keeps hallucinated content out of the generated documents.

   On top of that, three layers stack:
   - **Recipes** — `oaa-full`, `togaf-adm` etc. encode the required phase order and the dependencies (foundation commands must run before overlay commands). The agent can't skip a stage.
   - **Schema-validated templates** — each artefact (`OASTR`, `OAPR`, `OAAL`, …) has a strict shape. The intake interview ensures completeness *before* rendering; the schema validation catches it *after*. Incomplete fields fail validation, not quietly get invented.
   - **Per-phase validation gates** — every phase ships its own completeness checks (required sections, cross-references, consistency with the previous phase's output). The gate is the control; the agent is the worker.

   The upshot: AI accelerates the drafting, but the *architecture of the artefact* is still governed by the standard (C208, TOGAF) and enforced by the toolkit. The agent can make it faster; it can't make it structurally wrong. That's the property that makes "executable framework" more than a slogan.

---

## Quick Start

Three ways to run ArcKit — pick the one that fits your workflow:

### 1. Claude Code plugin (premier experience)

Install the core plugin plus the overlays you need. No project initialization required:

```bash
# In Claude Code:
/plugin marketplace add terrygzhou/arc-kit
claude plugin install arckit@arc-kit

# Enterprise architecture and AI agent governance overlays
claude plugin install arckit arckit-togaf-adm arckit-oaa arckit-agent-architecture
```

Then use the slash commands directly:

```text
/arckit:principles Create principles for a financial services company
/arckit:requirements Build a payment processing system...
```

Updates are automatic via the marketplace.

### 2. Codex CLI

Two install paths — plugin or full scaffold:

**Codex plugin (no Python, no scaffolding):**

```bash
codex plugin marketplace add terrygzhou/arckit-codex
codex features enable hooks
codex features enable plugin_hooks
```

Then in Codex:

```text
$arckit-init        Create the projects/ structure (once per repo)
$arckit-principles  Create principles for a financial services company
```

**ArcKit CLI (full project scaffold with templates and schemas):**

```bash
pip install git+https://github.com/terrygzhou/arc-kit.git
arckit init payment-modernization --ai codex
```

All artifacts land as versioned Markdown (`ARC-NNN-TYPE-vN.N.md`) under `projects/` — just commit regularly.

### 3. Bring Your Own LLM

Run any recipe against a local or remote OpenAI-compatible endpoint:

```bash
pip install git+https://github.com/terrygzhou/arc-kit.git
arckit build recipes/togaf-adm/full.yaml \
  --model=deepseek-v4 --api-base=http://localhost:3082/v1
```

See [Platform Support](#platform-support) for what runs where.

---

## What's Next?

- Community co-maintainer for O-AA domain expertise
- Mapping O-AA sprints to compliance frameworks (NIST, ISO)
- Feedback on sprint gate criteria
- Suggestions for mapping TOGAF ADM to O-AA C208

If you work with agile enterprise architecture or open-source EA tooling, please star the repo ([arc-kit](https://github.com/terrygzhou/arc-kit)), comment on the PR, or open an issue with your use case.

Frameworks stop being theoretical when they're executable. Both overlays do exactly that — TOGAF for the baseline, O-AA for the velocity.
