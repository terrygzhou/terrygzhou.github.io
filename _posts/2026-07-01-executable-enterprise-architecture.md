---
layout: post
title: Executable Enterprise Architecture - Agentic-TOGAF-ADM
tags:
  - enterprisearchitecture
  - agentic-togaf
  - ai-agents
date: 2026-07-01
---

Are you an executive leader without an architecture background, frustrated by the disconnect between your business goals, operational realities, and technology landscape? You know transformation is critical, but you’re stuck: unclear on where to go, how to get there, and unwilling to spend millions on Big 4 consultants for a “strategy” that may never be executable. That’s exactly why **PR #626** was built. 

Recently, I published a milestone update to the **ArcKit** open-source project: **PR #626** (https://github.com/tractorjuice/arc-kit/pull/626#event-27379874865). This update introduces AI-agentic, tool-agnostic support for the **TOGAF Architecture Development Method (ADM)**.

This release bridges the gap between TOGAF’s iterative framework and real-world execution. It creates and translates architectural guidance into clear, actionable workflows—so you can define the right problems, structure pragmatic solution strategies, and drive progress through ADM cycles without needing a dedicated EA team or a six-figure consulting budget.

repo: https://github.com/terrygzhou/arc-kit

---

## 🔍 Why This Matters

TOGAF ADM remains the most widely adopted enterprise architecture framework globally. Yet, many teams struggle to operationalise it: it needs EA specialists with the domain knowledge of your industry, engage heavily with your business and technology teams in a long period to create a target state architecture with the investment plan and implementation strategy to realise your vision. 

This work will be enabling **configurable, validated, and repeatable architecture workflows** that speak the same language as modern DevOps, IaC, and governance tooling.

---

## 📦 What’s Inside PR #626?

This contribution focuses on making ADM phases **Agent-readable, configurable, and actionable**. Key updates include introduction to `arckit-togaf-adm` that implements the **TOGAF ADM as structured, traceable slash commands and build recipes. It covers the full ADM cycle — Preliminary through Phase H — plus a cross-project Architecture Repository.

### The 9 Commands (Full ADM Cycle)

| Command                               | TOGAF Phase                         | What It Produces                                                                   |
| ------------------------------------- | ----------------------------------- | ---------------------------------------------------------------------------------- |
| `/arckit:adm-preliminary`             | Preliminary                         | Architecture vision, scope boundaries, drivers, constraints, success criteria      |
| `/arckit:business-capability-map`     | Phase A — Business Architecture     | Capability hierarchy, value streams, maturity levels                               |
| `/arckit:application-inventory`       | Phase C — Application               | Portfolio catalog with strategic fit scoring, dependencies, lifecycle status       |
| `/arckit:application-rationalization` | Phase C — Application               | Keep/merge/replace/retire decisions per application                                |
| `/arckit:gap-analysis`                | Phase E — Opportunities & Solutions | Capability matrix, gap severity scoring, workstream mapping                        |
| `/arckit:transition-architecture`     | Phase F — Migration Planning        | Work packages, migration waves, resource plans, acceptance criteria                |
| `/arckit:architecture-board`          | Phase G — Implementation Governance | Board charter, compliance scorecard, governance process                            |
| `/arckit:architecture-change`         | Phase H — Change Management         | Change requests with impact assessment, ADM cycle re-entry                         |
| `/arckit:architecture-repository`     | Continuous                          | Patterns library, standards register, reusable building blocks across all projects |

---

## 🌍 Why This is the game changer for Enterprise Architects

1. **From Theory to Tooling**  
   ADM phases are no longer just slide decks. They’re now configurable and executable building blocks that integrate with CI/CD, artifact stores, and governance dashboards.

2. **Consistency at Scale**  
   Teams (of agents or humans) can enforce phase completion, artifact quality, and stakeholder sign-offs programmatically—reducing manual compliance overhead.

3. **Framework-Agnostic Flexibility**  
   While designed around TOGAF ADM, the schema is intentionally extensible. You can layer EA models, C4, or custom governance frameworks on top.

4. **Open Source Transparency**  
   No vendor lock-in. The rules, templates, and validation logic are fully auditable, forkable, and community-driven.

5. **Composition with AI agent governance.** The `togaf-agent-full` recipe shows TOGAF ADM isn't a replacement — it's a sibling. Enterprise architecture and AI agent architecture run in parallel, feeding into the same gap analysis, transition planning, and governance review. One build, two domains. (see my another post to use this to manage many agents in an agent-architecture)

---

## 🚀 How to Try It

Arckit support claudecode, codex, copilot, gemini, opencode, paperclip, hermes, just pick up your favorite one.

### Local Dev Install (from your repo)

The plugin lives at `plugins/arckit-togaf-adm/`. Link it as a local plugin:

```bash

claude install latest
```


Then in Claude code, if registered in marketplace, then
```
/plugin marketplace add terrygzhou/arc-kit
```

otherwise,  load the plugin from local directory:
```bash
# Check current plugins
claude plugin list

# Enable from local path
git clone https://github.com/terrygzhou/arc-kit
cd arc-kit
claude --plugin-dir ./plugins/arckit-togaf-adm

```


### Quick Test

Once installed, verify the commands appear:

```
/arckit:help
```

Look for the 9 ADM commands. Then try a single command:

```
/arckit init my-project

/arckit-togaf-adm:adm-preliminary  <project ID or name, e.g. '001', 'enterprise transformation vision'>
```

The command will:

1. Ask if PRIN (architecture principles) exists — create it first if missing
2. Ask max 2 rounds of questions about scope, drivers, constraints
3. Generate `ARC-{P}-ADMP-v1.0.md` with architecture vision
4. Suggest next steps (`/arckit:business-capability-map`, `/arckit:gap-analysis`)


### An Example 

Enterprise Architecture artefacts for **MagicDelivery's AgenticEA** AI transformation programme — generated using ArcKit TOGAF ADM and Agent Architecture plugins.
`scope: Omnichannel AI agents across customer sales, service, shopping, and fulfillment`

https://github.com/terrygzhou/MagicDelivery
---

## 🤝 What’s Next?

This PR is currently in review and ready for community testing. I’m looking for:
- Feedback on phase sequencing edge cases
- Real-world ADM workflow exports from enterprise teams.
- Suggestions for mapping ADM to compliance frameworks (NIST, ISO, etc.)
- Contributors for phase-specific linting rules or artifact templates

If you work with TOGAF, architecture governance, or open-source EA tooling, please star the repo, comment on the PR, or open an issue with your use case.


---

## 💡 Final Thoughts

Enterprise architecture doesn’t have to be stuck in PowerPoint. By making TOGAF ADM a first-class citizen in ArcKit, I am taking a concrete step toward **repeatable, auditable, and automated architecture delivery**. Frameworks only matter when they ship. This PR helps them do exactly that.

Thanks to the ArcKit maintainers, early reviewers, and the open-source community that makes tools like this possible. Onward to Phase B. 🛠️📘 and welcome to raise any enquires to my repo https://github.com/terrygzhou/arc-kit.