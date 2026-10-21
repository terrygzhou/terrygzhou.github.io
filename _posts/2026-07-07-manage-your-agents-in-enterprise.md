---
layout: post
title: Manage Your AI Agents at Enterprise Scale
date: 2026-07-07
permalink: /2026-07-07/manage-your-agents-in-enterprise
description: "Enterprises are deploying hundreds of AI agents but most lack a systematic way to govern, secure, and orchestrate them. The ArcKit Agent Architecture plugin brings Enterprise Architecture methodology to agent programmes, providing inventory, design, governance, security, and maturity workflows through six slash commands and a six-phase build recipe."
tags:
  - AI-Agents
  - Agent-governance
  - ArcKit
  - Agentic-Architecture
  - enterprisearchitecture
  - agentic-togaf
status: published
---
> **TL;DR**: Enterprises are deploying hundreds of AI agents across their operations, but most lack a systematic way to govern, secure, and orchestrate them. Recently I have published a milestone update to the **ArcKit** open-source project: [**PR #626**](https://github.com/tractorjuice/arc-kit/pull/626#event-27379874865).  The ArcKit Agent Architecture overlay, implemented in this  [Arckit Agent-Architecture plugin](https://github.com/terrygzhou/arc-kit/tree/main/plugins/arckit-agent-architecture) brings Enterprise Architecture methodology to AI agent programmes, providing inventory, design, governance, security, and maturity assessment workflows.

---

## The Big Picture: AI Agents Going Mainstream

In 2026, AI agents have moved from experiment to production. Financial services run autonomous compliance checkers. Healthcare organisations deploy triage agents. Government agencies use research and analysis agents for policy development. Manufacturing companies orchestrate entire supply chains through agent networks.

**The numbers tell the story:**

- **Adoption rate**: According to 2025/2026 market data, approximately 70% of Fortune 500 firms have active deployments or pilots of autonomous agentic AI platforms to combat operational complexity. _(Source: SNS Insider / Enterprise Agentic AI Report)_
- **Scale**: Large enterprises typically run 50-200+ agents across their organisation
- **Complexity**: Agents range from simple task automation to multi-agent swarms coordinating across business units

The challenge is no longer *building* agents; it's **managing** them at scale.

---

## The Problem: Too Many Agents, Too Little Coordination

Here's what happens when organisations scale agents without a governance framework:

| Symptom               | Root Cause                                          | Impact                                       |
| --------------------- | --------------------------------------------------- | -------------------------------------------- |
| **Agent Sprawl**      | Shadow AI agents: teams build agents independently | 100+ agents with no inventory, no visibility |
| **Duplicate Effort**  | Multiple teams solving the same problem             | Wasted investment, conflicting outputs       |
| **Security Gaps**     | No standardised security review for agents          | Data exposure, compliance violations         |
| **Integration Chaos** | Agents can't communicate or share context           | Siloed automation, missed opportunities      |
| **Compliance Risk**   | No oversight model or audit trail                   | Regulatory penalties, board-level scrutiny   |

**The fundamental issue**: Organisations treat agents as individual projects rather than as a **programme** that needs architecture, governance, and lifecycle management.

---

## Enterprise Architecture (EA)

EA, leveraging established frameworks like TOGAF ADM, brings the necessary discipline to AI agent programs by enforcing structured planning, strategic traceability, clear governance, and full lifecycle management. However, because traditional EA wasn’t built for autonomous systems, it must be adapted with agent-specific approaches, including tailored design patterns, risk-calibrated oversight, seamless integration protocols, robust security against modern AI threats, and maturity models, to effectively govern and scale enterprise AI deployments.

---

## The DDD Lens: Bounded Contexts for Agent Programmes

Enterprise Architecture tells you *what* to build; **Domain-Driven Design (DDD)** tells you *how to slice* the work so each agent domain stays a coherent model ([Evans, 2003](https://en.wikipedia.org/wiki/Domain-driven_design)). Three DDD moves map directly onto agent programmes:

- **Bounded contexts over one giant model.** A large agent programme is not one system. The *post-purchase*, *returns*, and *tracking* domains each have their own model and their own **ubiquitous language** — the shared vocabulary between domain experts and the agents that serve them. Forcing one model across all of them is the "big ball of mud" DDD warns against.
- **The ubiquitous language *is* the tool contract.** When every agent-callable API speaks the domain's own terms — a *consent scope*, a *mandate*, a *delivery preference* — the model and the code stop drifting. The tool contracts you design are the ubiquitous language made executable.
- **Strategic design via context mapping.** Where two bounded contexts meet, DDD ships off-the-shelf patterns: an **Anti-Corruption Layer** isolates an upstream model from yours; a **Conformist** adopts the upstream model wholesale; an **Open Host Service** exposes your context to many downstream consumers. Agent programmes live at these seams: the agent layer is an anti-corruption boundary *in front of* the systems of record, not a bypass of them.

Tactical design fills in each context: **entities** that matter by *identity* (a parcel), **value objects** that matter by *attributes* (a delivery preference, a receipt), **aggregate roots** that guard consistency (the consent/mandate that gates every write), **repositories** for retrieval, and **domain events** (a delivery exception) that propagate **integration events** across contexts ([Cui, 2019](https://en.wikipedia.org/wiki/Domain-driven_design)).

> DDD is a *complexity* tool, not a default — it earns its keep where the model genuinely clarifies a shared understanding. Microsoft recommends it "only for complex domains where the model provides clear benefits." An agent programme with many journey domains and a shared capability layer is exactly that kind of domain.

---

## The Solution: ArcKit Agent Architecture Overlay

The [**ArcKit Agent Architecture** plugin](https://github.com/terrygzhou/arc-kit/tree/main/plugins/arckit-agent-architecture) bridges EA methodology with AI agent governance. It provides six slash commands and a six-phase build recipe:

### Six Core Commands

| Command                     | Doc Type | Purpose                                                                                 |
| --------------------------- | -------- | --------------------------------------------------------------------------------------- |
| `/arckit:agent-inventory`   | `AAGI`   | Catalog all agents with capabilities, security classification, and oversight levels     |
| `/arckit:agent-design`      | `AAGR`   | Design agent architecture, patterns, tool contracts, memory, orchestration, guardrails |
| `/arckit:agent-governance`  | `AAOV`   | Establish oversight models, approval workflows, audit requirements, compliance mapping  |
| `/arckit:agent-integration` | `AAIN`   | Design agent-to-agent integration, tool contracts, and orchestration patterns           |
| `/arckit:agent-security`    | `AASE`   | Harden agent security, sandboxing, permission models, threat assessment                |
| `/arckit:agent-maturity`    | `AAMT`   | Assess and track agent programme maturity with continuous improvement metrics           |

### Six-Phase Recipe

```
inventory → design → governance → integration → security → maturity
```

Each phase produces traceable artefacts that feed into the next. No silos, no duplication.

### The Verify → Repair Closed Loop

The overlay doesn't just generate artefacts — it closes the loop. The `arckit-agent-architecture` plugin ships a **verification** step that checks a designed agent architecture against its standards (pattern, tool contracts, guardrails, governance mapping) and reports a list of **gaps**. A gap is a concrete deviation, e.g. "agent X declares MCP tool access but has no L5 sandbox boundary" or "governance tier is HOTL but the audit cadence is monthly". The loop then:

1. **Verify** — run `agent:verify` against the design artefacts; every check returns pass or a named gap.
2. **Repair** — resolve each flagged gap (add the missing boundary, tighten the permission model, map the approval tier).
3. **Re-run** — re-verify and diff against the previous pass, confirming the gap set is shrinking.

The loop repeats until **zero open gaps**, at which point the design is publishable and logged to the G6 audit entry. This mirrors the classic "design–inspect–correct" discipline of EA review gates, but automates the inspection. In short: the six phases build the artefacts; the verify→repair loop is what keeps them honest.

> **Blueprint diagrams** of this machinery live in the ArcKit example project [`001-agentic-commerce/diagrams/`](https://github.com/terrygzhou/arc-kit/tree/main/plugins/arckit-agent-architecture). Three rendered views:
> - `arc001-agent-architecture-blueprint.html` — the seven-layer stack (L0 context → L6 governance) with the control-plane audit feedback
> - `arc001-agent-maturity-blueprint.html` — five maturity levels and the O4 audit loop
> - `arc001-verify-repair-loop-blueprint.html` — the verify → repair → re-run closed loop shown above

---

## How to Use the Plugin

### Installation (local)

```bash
git clone https://github.com/terrygzhou/arc-kit/tree/main
cd arc-kit

claude --plugin-dir ./plugins/arckit-agent-architecture
```
	
### Workflow

Run the six slash commands in sequence — each produces a named artefact:

- `agent-inventory` — master register: agent IDs, owners, risk tiers, capability matrices, dependency maps
- `agent-design` — architecture spec: pattern, component diagrams, tool contracts, memory layers, orchestration
- `agent-governance` — oversight framework: HITL/HOTL/AWA tiers, approval SLAs, audit cadence, KPIs, compliance mapping
- `agent-integration` — communication plan: MCP/REST/events patterns, shared contracts, retry strategies
- `agent-security` — hardening: sandbox isolation, least-privilege, threat modeling, guardrail config
- `agent-maturity` — programme health: cross-dimension scoring, improvement roadmap, benchmarking

### Next Steps

- Install the ArcKit Agent Architecture overlay: `claude plugin install arckit arckit-agent-architecture`
- Start with `/arckit:agent-inventory` to catalogue your current agent landscape
- Follow the six-phase recipe: inventory → design → governance → integration → security → maturity
- Pair with the ArcKit TOGAF ADM overlay (`arckit-togaf-adm`) for full Enterprise Architecture coverage

---

## Example: MarsPost Agentic Commerce

*Context: [MarsPost's](https://github.com/terrygzhou/arc-kit/tree/main) agentic commerce programme (`001-agentic-commerce`) — a bounded post-purchase pilot where eight agents orchestrate delivery journeys for MyPost customers, anchored in the app and extending to partner agents.*

The example below reuses the two ArchiMate blueprints produced by the ArcKit plugin for this exact project — the agent fleet in its enterprise environment, and the architecture blueprint.

### The DDD cut

Applying the DDD lens from above, the programme slices into bounded contexts per journey domain — *tracking*, *redirect*, *locker*, *exception*, *returns*, *sending* — each with its own ubiquitous language. The agent layer sits as an **anti-corruption layer in front of the systems of record** (Fulfilment, SAP, Salesforce, Genesys): agents never touch a SOR directly; every write is routed through a consent-gated, agent-callable domain API (tool contract T-002/T-003) that speaks the domain's own terms. A delivery *exception* fires a **domain event** that an **integration event** carries across to the exception-recovery context — the seam the anti-corruption layer owns.

### The fleet in the enterprise

![Agentic Commerce — agent fleet in its enterprise environment: one orchestrator (AGT-001) supervising six journey agents, observed by the AI-safety/AgentOps guardrail plane, every agent acting through the consent-gated agent-callable API layer with the P19 autonomy-ladder constraint and tamper-evident run ledger](/assets/2026-07-07-manage-your-agents-in-enterprise/agent-inventory-view.png)

*Agent inventory view (AAGI): eight agents — 1 orchestrator, 6 journey agents, 1 guardrail agent — catalogued with ownership, risk and oversight per autonomy level, all reachable from the orchestrator and observed by the guardrail plane.*
Source: [`agent-inventory-view.puml`](/assets/2026-07-07-manage-your-agents-in-enterprise/agent-inventory-view.puml) (PlantUML ArchiMate, pinned plantuml-1.2026.8.jar).

### The architecture blueprint

![Agentic Commerce — agent architecture blueprint: the agent system (orchestrator + journey agents) hosted on GCP PaaS Agent Engine, reasoning via the LLM core, invoking six agent-callable tools, gated by consent/Model Armor, with every run logged to the tamper-evident ledger and no direct SOR access](/assets/2026-07-07-manage-your-agents-in-enterprise/agent-architecture-view.png)

*Agent architecture view (AAGR): hierarchical supervisor/worker pattern; PP-01 prohibits any agent/LLM from reaching a SOR directly — consent, SVID and Model Armor gate all writes.*
Source: [`agent-architecture-view.puml`](/assets/2026-07-07-manage-your-agents-in-enterprise/agent-architecture-view.puml) (PlantUML ArchiMate).

### Challenge

MarsPost needed to govern agents spanning six post-purchase journey domains, where a single customer intent (*"manage my delivery"*) can trigger tracking, a locker redirect **and** an exception recovery in one journey:

- **Post-purchase orchestrator** that routes intent across journey agents
- **Journey agents** for tracking, redirect, locker/OOH, exception recovery, returns, sending
- **Guardrail agent** (AGT-008) that gates the fleet with consent scope, Model Armor and a tamper-evident ledger

### Outcome: Agent Architecture (6 artefacts)

Produced by the ArcKit plugin over project `001-agentic-commerce`:

|Artefact|Description|
|---|---|
|AAGI|Agent Inventory — 8 agents (1 orchestrator, 6 journey, 1 guardrail), capability matrix, 14 mapped dependencies|
|AAGR|Agent Design — hierarchical pattern, 6 tool contracts (T-001…T-006), 3-layer memory, orchestration, 5 guardrails|
|AAOV|Agent Governance — autonomy-ladder oversight, AGF exception process, sprint-embedded cadence|
|AAIN|Agent Integration — governed MCP/REST tool contracts through the Agent Gateway protocol edge|
|AASE|Agent Security — consent/SVID/Model Armor gates, sandbox isolation, injection/exfil defense|
|AAMT|Agent Maturity — bounded-pilot baseline, stage-gated autonomy promotion roadmap|

### Approach

1. **Inventory** (`/arckit:agent-inventory`): Catalogued all 8 agents with ownership, risk level, autonomy tier and deployment status
2. **Design** (`/arckit:agent-design`): Architected the hierarchical pattern, the six consent-gated tool contracts (the ubiquitous language), 3-layer memory and guardrails
3. **Governance** (`/arckit:agent-governance`): Established the autonomy-ladder model (P19) — no journey starts above *Recommend* without an AGF exception
4. **Integration** (`/arckit:agent-integration`): Wired agents through the governed Agent Gateway protocol edge, treating it as the anti-corruption layer in front of the SORs
5. **Security** (`/arckit:agent-security`): Enforced consent scope, SVID, Model Armor and per-channel kill-switches; every run logged to a tamper-evident ledger
6. **Maturity** (`/arckit:agent-maturity`): Set the bounded-pilot baseline and the stage-gated path from read-only MVP to consent-gated writes


---

## Key Takeaways

1. **Inventory first**: You can't govern what you can't see. Start with `/arckit:agent-inventory`
2. **Architecture over ad-hoc**: Design agents systematically using proven patterns
3. **Slice by domain driven design**: Use DDD bounded contexts to keep each agent domain a coherent model, with the agent layer as an anti-corruption boundary in front of the systems of record.
4. **Governance is non-negotiable**: Oversight models, audit trails, and compliance mapping are table stakes
5. **Security by design**: Build guardrails into agent architecture, not as an afterthought
6. **Measure to improve**: Maturity models track progress and guide investment
7. **Traceability matters**: Every agent decision links to business strategy and requirements

> *"The difference between an agent programme that scales and one that collapses is not technology; it's architecture."*

---

## References

- [ArcKit Agent Architecture Plugin](https://github.com/terrygzhou/arc-kit/tree/main/plugins/arckit-agent-architecture)
- [TOGAF Standard](https://www.opengroup.org/standards/togaf)
- Evans, Eric. *Domain-Driven Design: Tackling Complexity in the Heart of Software*. Addison-Wesley, 2003. [Wikipedia overview](https://en.wikipedia.org/wiki/Domain-driven_design) — bounded contexts, ubiquitous language, and the strategic-design patterns (anti-corruption layer, conformist, open host service) this post applies to agent programmes.
- Cui, Yan. *Serverless Architectures on AWS*. Manning, 2019. — the domain-event / integration-event distinction used to wire journey contexts together.
- NIST. *AI Risk Management Framework (AI RMF 1.0)*. NIST AI 100-1, 2023. [PDF](https://nvlpubs.nist.gov/nistpubs/ai/nist.ai.100-1.pdf) — the Govern / Map / Measure / Manage functions this post's oversight tiers map to.
- NIST. *AI RMF Generative AI Profile*. NIST AI 600-1, 2024. [PDF](https://nvlpubs.nist.gov/nistpubs/ai/NIST.AI.600-1.pdf) — LLM-specific risk guidance feeding the security phase.
- *"AI Agents Under Threat: A Survey of Key Security Challenges and Defenses."* ACM Computing Surveys, 2025. [DOI 10.1145/3716628](https://dl.acm.org/doi/10.1145/3716628) — a taxonomy of jailbreak / prompt-injection / exfiltration threats that the security phase (`agent-security`) operationalises.
- *"A Survey on Agentic Security: Applications, Threats and Defenses."* 2025/2026. Companion resource: [Awesome-Agentic-Security](https://github.com/kagnlp/Awesome-Agentic-Security) — the running index of threats/defenses for multi-agent and coding-assistant systems.
- *"Prompt Injection Attacks on Agentic Coding Assistants."* arXiv, 2026. [PDF](https://arxiv.org/pdf/2601.17548) — concrete attack surface for tool-calling agents; motivates the sandbox + least-privilege guardrails in `agent-security`.

---

**Tags**: `#AI #Agents #EnterpriseArchitecture #Governance #ArcKit #AgentArchitecture`