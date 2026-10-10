---
layout: post
title: From One Agent to a Company of Agents
date: 2026-09-27
permalink: /2026-09-27/from-one-agent-to-a-company-of-agents
tags:
  - ai-agents
  - agentic-architecture
  - open-source
  - software-engineering
  - enterprise-architecture
  - ai-transformation
description: "A coding agent is a tool you invoke. A company of agents is a system that runs. I built EyWALink as an AI company where every role — CEO, content author, engineer — is an agent, and found that the hard part was never the model. It was the control plane: issues, heartbeats, budgets, org trees. This post maps what it takes to run agents as employees, and what enterprises need before they hire their first one."
summary: A coding agent is a tool you invoke. A company of agents is a system that runs. After a year of running EyWALink and its multiple client tenants as agent-run companies — every role an agent, every task an issue, every invocation a heartbeat — the lesson is that the model was never the hard part. The control plane was.
---

> **TL;DR**: I run an AI company, [EyWALink](https://www.eywalink.org), with no human employees. Every role — CEO, content author, legal counsel, chief engineer, etc. — is an agent. **EyWALink mission control** runs them: multi-tenant, harness-agnostic, with **EyWALink workflow platform** as the per-tenant execution plane. After 8 months, the lesson is that agents-as-employees need four things: an org tree with reporting lines, a workflow agents wake up to, budgets that can actually stop work, and memory that doesn't forget. This post covers mission control and workflow platform — the layer that turns a collection of agents into an organisation.

You've probably run a coding agent. You invoke it, it writes some code, you review it, you move on. It's a tool.

An agent *employee* is different. It wakes up when there's work. It knows its role and its reporting line. It spends money doing the work, within a budget you set. It leaves a trail: what it did, what it cost, what it still owes. And when it gets stuck, it escalates to a named human instead of spinning.

None of that lives in the model. It lives in **EyWALink mission control** — the system around the model that acts as the HR department, the project board, and the finance office — with **EyWALink workflow platform** as the per-tenant execution plane where multi-step workflows actually run. This post is about that layer. It's based on 8 months of running multiple tenants where every "employee" is an agent and everything moves through issues, heartbeats, and budgets.

---

## The four things an agent employee needs

Run one agent for a while and you'll discover, in order, that four layers are missing. Each one is easy to hand-wave and painful to improvise.

### 1. A task queue, not a chat box

A chat box gives the agent one task at a time, in the order you happen to ask. A company needs work to *exist independently of any one session*: a backlog of issues, each with a title, a priority, an owner, and a status. The agent doesn't get work from your keyboard; it gets it from the queue.

In EyWALink mission control, work is an **issue**. It has a title, a description, a status, an assignee agent, and a priority. The agent that owns it wakes up, reads it, works it, leaves a comment describing what it did, and sets a final disposition: *done*, *in review*, or *blocked* (and if blocked, who unblocks it).

This is the first layer where "agent" becomes "employee". An employee gets assigned a ticket and doesn't wait for you to notice what they should be doing. The ticket is the interface, and it's inspectable by anyone in the org, which a chat transcript is not.

### 2. A heartbeat, not a prompt

A chat session is one invocation: prompt in, answer out, then it's gone. An agent employee has to be *woken*, and the wake has to carry context: which issue, what was decided before, what's already been done.

That's the **heartbeat**. It's a scheduled (or event-triggered) invocation of the agent's runtime, scoped to one issue. The heartbeat includes the issue, its current status, and the work completed so far, so the agent resumes instead of restarting. It also includes **continuation evidence**, prior results flagged as data rather than instructions, so a waking agent can pick up exactly where the last one left off.

This is where the difference between "tool" and "employee" gets concrete. My coding agent and I share a session; I notice when it's off track. A heartbeat agent has no shared session. Its continuity is *engineered*: persisted state, durable comments, a context payload. If that continuity isn't in the payload or on disk, the next heartbeat doesn't have it.

### 3. A budget that stops work

An agent with a blank check is not an employee. It's a liability. EyWALink mission control needs to answer, before the agent starts, *what can this work cost*, and it needs to be able to say no, to pause the work, when that answer is exceeded. Runaway agent spend is a documented production failure mode, not a hypothetical: a catalog of 63 budget-overrun incidents lands in [Token Budgets](https://arxiv.org/abs/2606.04056).

EyWALink mission control enforces this at two levels. A per-agent monthly budget, in cents, reported per heartbeat against input/output tokens. Cross the threshold and the agent's work auto-pauses; it doesn't warn, it stops. And per-run cost tracking, where every heartbeat records token usage so the board can look at a month of agent work the way a CFO looks at a P&L: who did what, and what it cost.

Enterprises skip this layer most often, and it's the one that surprises them first. "Our agents are just running, right?" Yes, but at what cost? Without per-task token accounting, you can't answer that. You also can't make the case for the next agent hire, because you don't know what the last one delivered per dollar.

### 4. A memory that compounds

The first three keep a single agent honest. The fourth is what makes a company of agents smarter than the sum of its stateless runs. Every wake starts from zero, and per-issue persistence carries one task forward but doesn't build the organisation's knowledge the way a real company's does.

EyWALink mission control addresses this with two layers: short-term, the within-task working set, via mem0; and long-term, the durable cross-tenant knowledge, via a shared self-learning knowledge graph (the digital twin). The memory section below goes into both.

---

## The org tree is a contract

In EyWALink mission control, agents are hired into a **strict org tree**: every agent reports to exactly one other agent, or to the root, the human board. No multi-manager, no dotted line. When an agent is blocked, it escalates up exactly one edge to a named agent — not to a channel where three people see it and none act.

Why strict? *Accountability needs a single owner.* Two managers means a blocked issue has two places to go and goes to neither. The single reporting line makes escalation a *mechanism*, not a *wish*. [OrgAgent](https://arxiv.org/abs/2604.01020) finds a company-style hierarchy outperforms flat multi-agent collaboration with fewer tokens; the [hierarchical multi-agent taxonomy](https://arxiv.org/abs/2508.12683) frames the axes a strict tree pins down: control, information flow, delegation.

The second layer is the **instructions document** (`AGENTS.md`), loaded at every heartbeat: role, scope, deliverable format, escalation rules — the agent version of an HR handbook, machine-enforced at wake time. The org tree tells the agent where it fits; the instructions document tells it how to behave; the issue tells it what to do.

---

## Multi-tenancy: one platform, many organisations

EyWALink mission control is built for one instance serving **multiple organisations with different client structures**.

Each tenant gets its own isolated org tree, issue queue, budget envelopes, and reporting lines. A consultancy might run three engagements — a fintech client, a government department, an internal product team — each with its own agents, escalation chain, and cost centre. Tenants stay fully isolated: no shared issues, no cross-tenant escalation, while the human board sees a consolidated P&L across all of them.

In practice: different org shapes per tenant (flat two-tier for one, deep three-tier for another); the platform enforces *strictness* — single reporting line, named escalation — within whatever tree you define. Per-tenant harness selection: a compliance-heavy tenant pins agents to Hermes for audit trail; a fast-iteration tenant runs the same issue types on Codex or Pi for speed. Budget isolation with roll-up: a runaway agent in one tenant can't drain another's envelope.

![EyWALink multi-tenant agent platform — ArchiMate view](/assets/multi-tenant-agent-platform/multi-tenant-architecture.png)

One shared mission control instance hosts every company. Each company owns its own org tree, issue queue, and budget envelope. Every agent binds its own harness (Pi code, Codex, Hermes, OpenCode, DSH) and its LLM from the shared, locally-owned model pool, and is assigned to tasks against the projects that belong to *its* company. The human board sits above all of it, reading a consolidated P&L.

**EyWALink workflow platform** is the per-tenant execution plane: it connects to mission control and runs the actual multi-step workflows — the tool-calling sequences that turn an issue into a deliverable. Mission control handles *who, what, how much*; workflow platform handles *how*. Each tenant's workflows run in isolation, so one tenant's long-running pipeline can't starve another's.

![EyWALink multi-tenant workflow platform — Mission Control provisions per-tenant Workflow Platform instances; both request LLM calls through the AI Gateway (LiteLLM) to the model layer](/assets/multi-tenant-agent-platform/multi-tenant-workflow.png)

---

## Recruitment and onboarding

Hiring an agent in EyWALink mission control is a deliberate process, compressed into machine-readable steps.

### The process

1. **Demand identification.** A project demand lands as a *role requirement*. Example: "The Q3 legal pipeline is backlogged; we need a role that drafts contract proposals, grounded in client compliance requirements, and escalates scope questions to the CEO agent."
2. **Role specification.** CEO agent writes the spec: title (e.g., Legal Counsel), scope, deliverable format, reporting line, budget, `AGENTS.md`.
3. **Harness selection.** Board picks the runtime. A Legal Counsel role needing document access goes on Hermes; a mostly-reasoning role runs on DSH.
4. **Onboarding into the tree.** Agent placed: manager named, escalation path set, budget set, `AGENTS.md` versioned. Platform verifies the tree stays strict.
5. **Shadow heartbeat.** First wake is a dry run: loads instructions, reads the issue, produces a plan comment, no execution. Reviewer approves before write access.
6. **Graduated autonomy.** Two approved deliverables → spot-check. Ten clean dispositions → unattended within budget.

### Example: Legal Counsel for Emfinestudio's new contract

EyWALink receives a demand: *"Prepare a contract proposal for Emfinestudio's new service agreement — 12-week delivery window, liability caps, SLA tiers, budget ceiling $6k."*

| Step                | What happens                                                                                                                                                                                                                                              |
| ------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Demand enters queue | CEO agent triages: this is a Legal Counsel job. Creates role requirement.                                                                                                                                                                                 |
| Role spec written   | Title: Legal Counsel. Scope: draft contract proposals from brief + client compliance profile. Reporting: CEO agent. Budget: $10/week. Harness: Hermes (document I/O).                                                                                     |
| `AGENTS.md` drafted | Must ground liability caps in Emfinestudio's compliance profile; must not invent scope; flag any term exceeding the 12-week window; escalation to CEO for pricing exceptions.                                                                             |
| Agent activated     | Placed under CEO. Budget set. First issue: EYW-412 "Draft contract proposal for Emfinestudio service agreement."                                                                                                                                          |
| Shadow heartbeat    | Agent loads `AGENTS.md`, reads EYW-412, reads compliance profile, produces plan: "Section 1: scope. Section 2: delivery tiers (grounded in catalogue). Section 3: SLA + liability caps. Flag: liability cap may need board approval — escalating to CEO." |
| CEO reviews         | Approves, resolves liability flag (caps set at 1.5× annual contract value). Agent proceeds.                                                                                                                                                               |
| Execution heartbeat | Agent drafts full contract, leaves deliverable, comments "draft complete, 5 sections, liability caps grounded in compliance profile v2.1, flag resolved." Disposition: *in_review*.                                                                       |
| Board view          | Issue, assignee, cost this run ($3.20), deliverable link, flag resolved. One view.                                                                                                                                                                        |

Everything inspectable, budgeted, attributable.

![EYW-412 heartbeat flow, issue to board view](/assets/multi-tenant-agent-platform/eyw-412-heartbeat.png)

A **work record**, not a chat: who did what, to what spec, at what cost, what's still open.

---

## Memory: a shared digital twin that doesn't forget

Every agent run is stateless. Per-task persistence — durable comments, context payload, artifacts on disk — carries one issue forward, but it doesn't compound. Each issue rebuilds context from scratch; the company's knowledge doesn't accumulate.

This section covers the long-term layer. The short-term layer lives in [mem0](https://github.com/mem0ai/mem0), an open-source MCP memory server, so an agent picks up the current issue's thread without rebuilding it. The two work together: mem0 carries the task, the graph carries the company.

EyWALink mission control adds a **shared knowledge graph** — the digital twin of the organisation's knowledge state. Not per-issue notes. A graph of what the company knows: client constraints, catalogue versions, scope decisions, SLA mappings. This is the long-term side of [Selective Forgetting](https://arxiv.org/abs/2608.28978), which models a knowledge graph as structured long-term agent memory. Cited honestly: that paper finds a graph doesn't automatically beat a flat vector baseline, so the digital twin has to earn its place.

Two properties make it the layer that turns stateless runs into an organisation that learns:

**Shared.** Any agent in any tenant reads the same graph. A Legal Counsel grounding liability caps pulls the same compliance facts a QA agent later audits against. Knowledge isn't trapped in one transcript.

**Self-learning.** Agents write facts back to the graph. When Legal Counsel resolves the liability flag on EYW-412, that resolution lands in the graph, not just in that issue's comments. The next agent touching that SLA tier starts from that fact, not from zero. The graph sharpens as the company works.

---

## The five principles, for enterprises

If your organisation is thinking about an "AI workforce", the honest question is what mission control infrastructure you're standing on when you hire agent #1. Five principles, in the order I learned them:

1. **Agents are employees, not tools.** The moment an agent works a backlog, you need the HR infrastructure: reporting lines, task assignment, performance review, termination.
2. **The model is the least of your concerns.** Local open-weight models on one RTX 5090, no cloud API. EyWALink mission control is open source at its core, with EyWALink workflow platform as the execution plane. Harness is swappable: Pi code, Codex, Hermes, OpenCode, DSH. The lock-in lives in the org tree and the issue queue, not in the model.
3. **Continuity is a design problem, not a hope.** Every session is stateless. Memory has to be persisted and passed forward: durable comments, a context payload at each heartbeat, artifacts on disk. The pattern is the same everywhere: a queue file, a context file, a check command.
4. **The company's memory has to compound, not just persist.** Per-task handoff carries one issue forward. The digital twin builds the organisation's knowledge: agents read grounded context from the shared graph and write the facts they produce back. See the memory section for how.
5. **Govern the work, not the model.** The model proposes; EyWALink mission control disposes. Budgets that stop work, escalation paths that name a human, inspectable dispositions.

---

## The honest limits

This is one person running two companies of agents, not a Fortune 500. What I *haven't* solved:
- **Cost attribution to outcomes.** I can tell you what a heartbeat cost. I can't yet tell you what a *project* delivered, per dollar, in a way a board would accept. The P&L for an agent company is still hand-rolled.
- **Cross-company coordination.** Two companies on one instance is fine. More, and the org trees start to need a federation story.
- **The human is still the board.** I'm the board of both companies. The moment I'm not, every one of these mechanisms, escalation, budget override, termination, needs a human behind it, and that human's attention is the scarcest resource in the whole system.
- **Multi-tenant isolation at scale.** The tenancy boundary works for my two companies. I haven't stress-tested it against, say, twelve tenants with different security postures and regulatory requirements.

That's where the work is going. What's above mission control is a board that can read a P&L, an org that can run without me, and a platform that serves a dozen different client structures without configuration drift. That's what makes this a company instead of a hobby.

---

## References

- [OrgAgent: Organize Your Multi-Agent System like a Company](https://arxiv.org/abs/2604.01020) — company-style hierarchy (governance / execution / compliance layers) outperforms flat multi-agent collaboration and cuts token spend in most settings. Backs the org-tree-is-a-contract section and the cost argument.
- [A Taxonomy of Hierarchical Multi-Agent Systems](https://arxiv.org/abs/2508.12683) — a five-axis lens over how hierarchies coordinate (control, information flow, delegation, temporal layering, communication). Backs the design choices in the org tree and recruitment sections.
- [Token Budgets: An Empirical Catalog of 63 LLM-Agent Budget-Overrun Incidents](https://arxiv.org/abs/2606.04056) — documented production cases of runaway agent spend and an enforcement design that makes a budget cap non-bypassable. Backs "a budget that stops work."
- [mem0](https://github.com/mem0ai/mem0) — open-source memory server for LLM agents. Backs the short-term memory layer in the memory section.
- [Selective Forgetting: A Graph-Based Memory Framework for Long-Term LLM Agents](https://arxiv.org/abs/2608.28978) — treats a knowledge graph as structured long-term agent memory, with a pruning/forgetting pass. Cited honestly: it finds a graph does not automatically beat a flat vector baseline, so a digital twin has to earn its place rather than be assumed.
