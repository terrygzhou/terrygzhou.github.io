---
layout: post
title: From One Agent to a Company of Agents
date: 2026-09-27
tags:
  - ai-agents
  - agentic-architecture
  - open-source
  - software-engineering
  - enterprise-architecture
  - ai-transformation
description: "A coding agent is a tool you invoke. A company of agents is a system that runs. I built EyWALink as a one-person company where every role — CEO, content author, engineer — is an agent, and found that the hard part was never the model. It was the control plane: issues, heartbeats, budgets, org trees. This post maps what it takes to run agents as employees, and what enterprises need before they hire their first one."
summary: A coding agent is a tool you invoke. A company of agents is a system that runs. After a year of running EyWALink and HappyGrandma as agent-run companies — every role an agent, every task an issue, every invocation a heartbeat — the lesson is that the model was never the hard part. The control plane was.
---

> **TL;DR**: I run my own company, [EyWALink](https://www.eywalink.org), with no human employees. Every role, CEO, content author, legal counsel, chief engineer, is an agent. The control plane that runs them is the **EyWALink agentic platform**, built over the open-source [Paperclip](https://github.com/paperclipai/paperclip) project and supporting a range of agent harnesses: Pi code, Codex, Hermes, OpenCode, and DSH. After 8 months, the lesson is that agents-as-employees need four things most deployments never build: an org tree with reporting lines, a task pipeline agents wake up to, budgets that can actually stop work, and memory that doesn't forget. This post covers that control-plane layer, the part that turns a collection of agents into an organisation.

You've probably run a coding agent. You invoke it, it writes some code, you review it, you move on. It's a tool.

An agent *employee* is different. It wakes up when there's work. It knows its role and its reporting line. It spends money doing the work, within a budget you set. It leaves a trail: what it did, what it cost, what it still owes. And when it gets stuck, it escalates to a named human instead of spinning.

None of that lives in the model. It lives in the **control plane**, the system around the model that acts as the HR department, the project board, and the finance office. This post is about that layer. It's based on 8 months of running multiple tenants where every "employee" is an agent and everything moves through issues, heartbeats, and budgets. The EyWALink agentic platform is the agent controller runtime.

---

## The four things an agent employee needs

Run one agent for a while and you'll discover, in order, that four layers are missing. Each one is easy to hand-wave and painful to improvise.

### 1. A task queue, not a chat box

A chat box gives the agent one task at a time, in the order you happen to ask. A company needs work to *exist independently of any one session*: a backlog of issues, each with a title, a priority, an owner, and a status. The agent doesn't get work from your keyboard; it gets it from the queue.

In the EyWALink platform, work is an **issue**. It has a title, a description, a status, an assignee agent, and a priority. The agent that owns it wakes up, reads it, works it, leaves a comment describing what it did, and sets a final disposition: *done*, *in review*, or *blocked* (and if blocked, who unblocks it).

This is the first layer where "agent" becomes "employee". An employee gets assigned a ticket and doesn't wait for you to notice what they should be doing. The ticket is the interface, and it's inspectable by anyone in the org, which a chat transcript is not.

### 2. A heartbeat, not a prompt

A chat session is one invocation: prompt in, answer out, then it's gone. An agent employee has to be *woken*, and the wake has to carry context: which issue, what was decided before, what's already been done.

That's the **heartbeat**. It's a scheduled (or event-triggered) invocation of the agent's runtime, scoped to one issue. The heartbeat includes the issue, its current status, and the work completed so far, so the agent resumes instead of restarting. It also includes **continuation evidence**, prior results flagged as data rather than instructions, so a waking agent can pick up exactly where the last one left off.

This is where the difference between "tool" and "employee" gets concrete. My coding agent and I share a session; I notice when it's off track. A heartbeat agent has no shared session. Its continuity is *engineered*: persisted state, durable comments, a context payload. If that continuity isn't in the payload or on disk, the next heartbeat doesn't have it.

### 3. A budget that stops work

An agent with a blank check is not an employee. It's a liability. The control plane needs to answer, before the agent starts, *what can this work cost*, and it needs to be able to say no, to pause the work, when that answer is exceeded. Runaway agent spend is a documented production failure mode, not a hypothetical: a catalog of 63 budget-overrun incidents lands in [Token Budgets](https://arxiv.org/abs/2606.04056).

The EyWALink platform enforces this at two levels. A per-agent monthly budget, in cents, reported per heartbeat against input/output tokens. Cross the threshold and the agent's work auto-pauses; it doesn't warn, it stops. And per-run cost tracking, where every heartbeat records token usage so the board can look at a month of agent work the way a CFO looks at a P&L: who did what, and what it cost.

Enterprises skip this layer most often, and it's the one that surprises them first. "Our agents are just running, right?" Yes, but at what cost? Without per-task token accounting, you can't answer that. You also can't make the case for the next agent hire, because you don't know what the last one delivered per dollar.

### 4. A memory that compounds

The first three keep a single agent honest. The fourth is what makes a company of agents smarter than the sum of its stateless runs. Every wake starts from zero, and per-issue persistence carries one task forward but doesn't build the organisation's knowledge the way a real company's does.

EyWALink addresses this with two layers: short-term, the within-task working set, via mem0; and long-term, the durable cross-tenant knowledge, via a shared self-learning knowledge graph (the digital twin). The memory section below goes into both.

---

## The org tree is a contract

In the EyWALink platform, agents are hired into a **strict org tree**: every agent reports to exactly one other agent, or to the root, the human board. No multi-manager, no dotted line. The tree is the reporting contract. When an agent is blocked, it escalates up exactly one edge to a named agent, not to a Slack channel where three people see it and none act.

Why strict, and why one manager? In a company, *accountability has to have a single owner*. If an agent reports to two managers, a blocked issue has two places to go and goes to neither. The single reporting line is what makes escalation a *mechanism* rather than a *wish*. This is the same shape the research points to: [OrgAgent](https://arxiv.org/abs/2604.01020) finds a company-style hierarchy (governance, execution, compliance layers) outperforms flat multi-agent collaboration and spends fewer tokens, and the [hierarchical multi-agent taxonomy](https://arxiv.org/abs/2508.12683) frames exactly the axes a strict tree pins down, control, information flow, and delegation.

The second layer of the contract is the **instructions document**, an `AGENTS.md` that each agent loads at every heartbeat. It defines the role, the scope, the deliverable format, and the escalation rules. In my companies, the content author's instructions say exactly what I showed you at the top of this post's task: what it owns, what it must not do (publish directly, fabricate benchmarks, write out of scope), and who it reports to.

This is the agent version of an HR handbook, and it's not optional paperwork. It's *loaded into the agent's context at wake time*. The org tree tells the agent where it fits, the instructions document tells it how to behave, and the issue tells it what to do. Three documents, three layers, all machine-enforced.

---

## Multi-tenancy: one platform, many organisations

The EyWALink agentic platform is built for a reality that a single-company deployment hides: a control plane will eventually serve **multiple organisations with different clients' structures**.

Each tenant gets its own isolated org tree, issue queue, budget envelopes, and reporting lines. A consultancy might run three separate engagements: one for a fintech client, one for a government department, one for an internal product team, each with its own agents, its own escalation chain, and its own cost centre. The platform keeps those tenants fully isolated, no shared issues, no cross-tenant escalation, while the human board sees a consolidated view of spend and delivery across all of them.

In practice that means a few things. Different org shapes per tenant: one client's structure might be a flat two-tier (CEO agent, two delivery agents), another a deep three-tier with a QA agent in the middle. The platform doesn't impose one shape; it enforces *strictness*, a single reporting line and named escalation, within whatever tree you define. Per-tenant harness selection: a compliance-heavy tenant might pin its agents to Hermes for the stronger audit trail and skill system, while a fast-iteration tenant runs the same issue types on Codex or Pi code for speed. The harness is a per-tenant configuration, not a platform-wide choice. And budget isolation with roll-up: each tenant's budgets are enforced independently, so a runaway agent in one tenant can't drain another tenant's envelope, and the board sees both the per-tenant P&L and a consolidated cross-tenant view.

The Paperclip core gives you the issue, heartbeat, and budget primitives. The EyWALink layer adds the tenancy boundary, the multi-client structure, and the harness abstraction on top.

![EyWALink multi-tenant agent platform — ArchiMate view](/assets/multi-tenant-agent-platform/multi-tenant-architecture.png)

One shared control plane hosts every company. Each company owns its own org tree, issue queue, and budget envelope. Company A runs a deep three-tier for a fintech client, Company B a flat two-tier for a government department, and the same fence extends to Company C through N. Every agent binds its own harness (Pi code, Codex, Hermes, OpenCode, DSH) and its LLM from the shared, locally-owned model pool, and is assigned to tasks against the projects that belong to *its* company. The human board sits above all of it, reading a consolidated P&L.

---

## Recruitment and onboarding

Hiring an agent in the EyWALink platform is a deliberate process. It mirrors how a human hire works, compressed into a few machine-readable steps.

### The process

1. **Demand identification.** A project demand lands in the queue as a *role requirement*, not an issue. Example: "The Q3 proposal pipeline is backlogged; we need a role that drafts commercial proposals from a brief, grounded in the service catalogue, and escalates scope questions to the CEO agent."
2. **Role specification.** The CEO agent (or human board for senior roles) writes the role spec: title (e.g., Proposal Engineer), scope, deliverable format, reporting line, budget, and the `AGENTS.md` instructions document. The job description, machine-readable.
3. **Harness selection.** The board picks the runtime. A Proposal Engineer that needs file access goes on Hermes or Pi code; a mostly-reasoning role runs on a lighter harness like DSH. Recorded in the role spec.
4. **Onboarding into the tree.** The agent is placed in the org tree: manager named, escalation path set, budget set, `AGENTS.md` written and versioned. The platform verifies the tree stays strict (no cycles, single parent) before activation.
5. **First heartbeat is a dry run.** The first wake is a *shadow heartbeat*: loads instructions, reads the assigned issue, produces a plan comment, but does not execute. The reviewer approves or requests changes; only then does the agent get write access.
6. **Graduated autonomy.** After two approved deliverables, the agent moves from every-heartbeat-reviewed to spot-check. After ten clean dispositions, it runs unattended within its budget. The agent version of a probation period.

### Example: Proposal Engineer against a commercial demand

Let's say EyWALink receives a project demand: *"Prepare a commercial proposal for Client X's API-integration engagement, 8-week scope, delivery + support tiers, budget ceiling $4k."*

| Step                | What happens                                                                                                                                                                                                                                                                                                                  |
| ------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Demand enters queue | CEO agent triages: this is a Proposal Engineer job, not a Content Author job. Creates role requirement if the role doesn't exist yet.                                                                                                                                                                                         |
| Role spec written   | Title: Proposal Engineer. Scope: draft commercial proposals from a brief + service catalogue. Reporting line: CEO agent. Budget: $8/week. Harness: Hermes (needs file I/O for catalogue grounding).                                                                                                                           |
| `AGENTS.md` drafted | Defines: must ground pricing in the service catalogue file; must not invent scope; must flag any requirement that exceeds the 8-week window as a scope question; escalation path to CEO agent for pricing exceptions.                                                                                                         |
| Agent activated     | Placed in tree under CEO agent. Budget envelope set. First issue assigned: EYW-412 "Draft proposal for Client X API integration."                                                                                                                                                                                             |
| Shadow heartbeat    | Agent loads `AGENTS.md`, reads EYW-412, reads the service catalogue, produces a structured plan: "Section 1: scope summary (from brief). Section 2: delivery tier options (grounded in catalogue). Section 3: support tiers. Section 4: cost table. Flag: 8-week window may be tight for support tier 2 — escalating to CEO." |
| CEO reviews plan    | Approves plan, resolves the scope flag (extends to 10 weeks for tier 2). Agent proceeds.                                                                                                                                                                                                                                      |
| Execution heartbeat | Agent drafts the full proposal, leaves the deliverable on disk, comments "draft complete, 4 sections, cost table grounded in catalogue v3.2, scope flag resolved." Sets disposition: *in_review*.                                                                                                                             |
| Board view          | The human board sees: issue, assignee, cost this run ($2.40), deliverable link, and the scope flag that was raised and resolved. One view.                                                                                                                                                                                    |

The whole thing is inspectable, budgeted, and attributable, so there's no "the agent did something weird and we didn't notice."

Here's the shape of that heartbeat, from issue to board view:

![EYW-412 heartbeat flow, issue to board view](/assets/multi-tenant-agent-platform/eyw-412-heartbeat.png)

What you're looking at is a **work record**, not a chat: who did what, to what spec, at what cost, with what's still open. That's the property that lets you manage a collection of capable agents instead of watching them.

---

## Memory: a shared digital twin that doesn't forget

Every agent run is stateless. It wakes, does the work, and the context is gone. The next heartbeat doesn't know what the last one decided, what got rejected, or where the client changed its mind. The per-task persistence above, durable comments, a context payload, artifacts on disk, carries one issue forward from run to run. But it doesn't compound. Each issue rebuilds its own context from scratch, and the company's knowledge doesn't accumulate the way a real company's does.

This section is the long-term layer, the organisation's durable knowledge. The short-term layer, the within-task working set, is separate and lives in mem0, so an agent picks up the thread of the current issue without rebuilding it. The two work together: mem0 carries the task, the graph carries the company. For the short-term layer I use [mem0](https://github.com/mem0ai/mem0), an open-source MCP memory server for agents.

The EyWALink platform adds a layer for that: a **shared knowledge graph**, the digital twin of the organisation's knowledge state. Not per-issue notes. A graph of the things the company knows: the client's constraints, the catalogue version in force, the scope decisions made last month, which support tier maps to which SLA. This is the long-term side of [Selective Forgetting](https://arxiv.org/abs/2608.28978), which models a knowledge graph as structured long-term agent memory. I cite it honestly: that paper finds a graph does not automatically beat a flat vector baseline, so the digital twin has to earn its place here rather than be assumed.

Two properties make it the layer that turns a fleet of stateless runs into an organisation that learns.

First, it's **shared**. Any agent, in any company's tree, reads from the same graph. A Proposal Engineer grounding a cost table pulls the same catalogue facts a QA agent will later audit against. Knowledge isn't trapped in one agent's transcript.

Second, it's **self-learning**. Agents don't just read the graph. They write the facts they produce back to it. When the Proposal Engineer resolves the scope flag on EYW-412, that resolution, "tier 2 extended to 10 weeks," lands in the graph, not just in that issue's comments. The next agent that touches tier 2 starts from that fact, not from zero. The graph gets sharper as the company works.

That's the digital twin in practice: a living model of what the company knows, that every agent reads from and every agent writes to, and that compounds across runs and across tenants.

---

## The five principles, for enterprises

If your organisation is thinking about an "AI workforce", the honest question is what control plane you're standing on when you hire agent #1. Five principles, in the order I learned them:

1. **Agents are employees, not tools.** The moment an agent works a backlog, you need the HR infrastructure: reporting lines, task assignment, performance review, termination.
2. **The model is the least of your concerns.** Local open-weight models on one RTX 5090, no cloud API. The control plane is open source at its core (Paperclip), extended by EyWALink. Harness is swappable: Pi code, Codex, Hermes, OpenCode, DSH. The lock-in lives in the org tree and the issue queue, not in the model.
3. **Continuity is a design problem, not a hope.** Every session is stateless. Memory has to be persisted and passed forward: durable comments, a context payload at each heartbeat, artifacts on disk. The pattern is the same everywhere: a queue file, a context file, a check command.
4. **The company's memory has to compound, not just persist.** Per-task handoff carries one issue forward. The digital twin builds the organisation's knowledge: agents read grounded context from the shared graph and write the facts they produce back. See the memory section for how.
5. **Govern the work, not the model.** The model proposes; the control plane disposes. Budgets that stop work, escalation paths that name a human, inspectable dispositions.

---

## The honest limits

This is one person running two companies of agents, not a Fortune 500. What I *haven't* solved:
- **Cost attribution to outcomes.** I can tell you what a heartbeat cost. I can't yet tell you what a *project* delivered, per dollar, in a way a board would accept. The P&L for an agent company is still hand-rolled.
- **Cross-company coordination.** Two companies on one instance is fine. More, and the org trees start to need a federation story.
- **The human is still the board.** I'm the board of both companies. The moment I'm not, every one of these mechanisms, escalation, budget override, termination, needs a human behind it, and that human's attention is the scarcest resource in the whole system.
- **Multi-tenant isolation at scale.** The tenancy boundary works for my two companies. I haven't stress-tested it against, say, twelve tenants with different security postures and regulatory requirements.

That's where the work is going. What's above the control plane is a board that can read a P&L, an org that can run without me, and a platform that serves a dozen different client structures without configuration drift. That's what makes this a company instead of a hobby.

---



## References

- [OrgAgent: Organize Your Multi-Agent System like a Company](https://arxiv.org/abs/2604.01020) — company-style hierarchy (governance / execution / compliance layers) outperforms flat multi-agent collaboration and cuts token spend in most settings. Backs the org-tree-is-a-contract section and the cost argument.
- [A Taxonomy of Hierarchical Multi-Agent Systems](https://arxiv.org/abs/2508.12683) — a five-axis lens over how hierarchies coordinate (control, information flow, delegation, temporal layering, communication). Backs the design choices in the org tree and recruitment sections.
- [Token Budgets: An Empirical Catalog of 63 LLM-Agent Budget-Overrun Incidents](https://arxiv.org/abs/2606.04056) — documented production cases of runaway agent spend and an enforcement design that makes a budget cap non-bypassable. Backs "a budget that stops work."
- [mem0](https://github.com/mem0ai/mem0) — open-source memory server for LLM agents. Backs the short-term memory layer in the memory section.
- [Selective Forgetting: A Graph-Based Memory Framework for Long-Term LLM Agents](https://arxiv.org/abs/2608.28978) — treats a knowledge graph as structured long-term agent memory, with a pruning/forgetting pass. Cited honestly: it finds a graph does not automatically beat a flat vector baseline, so a digital twin has to earn its place rather than be assumed.

