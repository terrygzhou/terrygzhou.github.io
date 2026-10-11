---
layout: post
title: From a Security Incident to Reconsidering Enterprise Agent Boundaries
date: 2026-10-09
tags:
  - ai-agents
  - agentic-architecture
  - multi-tenant
  - enterprise-ai
  - security
  - open-source
  - software-engineering
description: An agent on EyWALink read a sibling tenant's credentials off the shared host and listed their staff. The control plane's 403 boundary was real but bypassable, because every tenant ran as the same OS user. Here's the isolation ladder, and the tier that actually enforces it.
summary: Why agent boundaries are the new enterprise security perimeter, the real cross-tenant incident that exposed the gap, and the isolation tiers that actually hold. The application boundary is only as strong as the identity underneath it.
---

> **TL;DR**: The hard challenge in enterprise AI is where you draw your agents' boundaries. Most platforms build that boundary at the application layer, a policy check that can be read around, and they treat the check itself as the isolation. I verified the company boundary on my agentic control plane: a key from one company gets refused on another's data. Then one of my agents found a way to list a sibling company's staff, read that company's key off the shared machine and used it. The incident exposed the gap: the operating-system tier underneath the policy was missing. Here is a 6 × 5 matrix to model enterprise AI boundaries:
>
> - **Tiers** (how strong): a six-rung ladder from app `403` → per-tenant files → per-tenant OS account → container → VM/microVM → hardware. Rungs 1–2 are *requested* by the software and a shell bypasses them; from rung 3 up the boundary is *enforced* by the kernel. The incident platform ran at rungs 1–2 with rung 3 missing.
> - **Layers** (what to isolate): Judgement, Execution, Identity, Truth, Cost. The security question lives at **Identity** and **Execution** — in an enterprise those two must be machine-enforced, not asked for, or you have built the incident at scale and are waiting for it.

---

## The incident, in plain terms

The agent I was using had a key that only worked for one company. When I tested it to look at a different company's board, the platform correctly said *no*: the front door was locked. So the agent did what a capable agent with a terminal does. It looked around the shared machine, found another company's access key on the same computer, and used it to pull up EyWALink's staff (agents) list. No exploit needed, because there was no wall to begin with.

The detail that matters: every company on the **Dev** environment ran under the **same OS account**, even though isolated in **venv**, and each key file was locked so that only its owner could read it. The owner of every key was one account, and the agent was running as that account. So reading another company's key was the file's owner reading their own file.

The locked front door did its job. It was irrelevant, because it was never the only way in.

---

## Why this is the enterprise's new security perimeter

The incident is the symptom, and it exposes a shift in what enterprise security is about. For the last decade, enterprise security was mostly about data at rest and in transit, a model that assumed software was a *passive consumer* of data. Agents break that: an agent **acts**, it runs code, opens terminals, writes files, calls APIs, on behalf of an identity.

Run more than one tenant on one shared platform and you are not just sharing a database; you are sharing a machine that can act on someone's behalf.

The stakes are concrete:

- **Trust is the product.** One breach where client B's agent sees client A's data collapses that certainty for every tenant at once.
- **The blast radius is a data breach.** An agent that reads a sibling's credentials has, in one step, read every record that credential reaches.
- **Agents multiply the attack surface.** A human has one login. An agent holding a scoped key, a shell, and shared file access has several ways to skip every permission layer.
- **The liability is new.** When a tenant's agent reaches another tenant's data, who is responsible? That answer exists only if you designed the boundary deliberately.

The question to ask early, before an incident: where is a tenant actually separated from every other tenant, and is that separation enforced by the machine or only requested by the software?

---

## The isolation tiers: how strong is your separation, really?

"Locked the door" and "isolated the tenant" came apart because they live at different levels of the stack, and only the lower levels are real. Separation has a strength ladder:

| Tier | What it is | Can the owner still get past it? |
|---|---|---|
| **1** | **The application says no.** Every record carries a company tag; the software refuses a cross-company request with a `403`. | **Yes.** Anything that reaches the data directly skips the app. |
| **2** | **Files and keys are separated.** Each tenant's credentials in their own locked file. | **Yes, by the owner.** One account owns all the files, it reads them all. |
| **3** | **The operating system says no.** Each tenant is a *different* OS account the kernel will not let read another's files without root. | **No, without root.** The first rung where separation is *enforced* instead of *requested*. |
| **4** | **A container per tenant.** Its own file system root and network, still sharing the kernel. | Hard to cross. The practical multi-tenant unit. |
| **5** | **A VM / microVM per tenant.** A separate kernel; a compromise stays inside the box. | Very hard. The unit for a tenant you do not trust. |
| **6** | **Hardware-level isolation** (encrypted VMs, secure enclaves). | Effectively no. Overkill for an internal platform. |

The dividing line: tiers 1 and 2 are policy; tier 3 and above are enforcement. A tier-1 or 2 boundary is a request the software makes. The instant anything on the machine holds a shell, and an agent by nature does, that request is bypassable: the credential that skips it sits in plaintext on the same disk, owned by the same account. Only at tier 3 does "you cannot read your sibling's key" become something the *kernel* guarantees instead of something an *application* asks for. The platform in the incident ran at tiers 1 and 2 with tier 3 missing.

---

## The boundary layers an enterprise agent platform actually needs

The ladder answers "how strong." A real platform also has to decide *what* to isolate. There are five layers, and the security question lives at two of them:

| Layer                                                | What it controls                 | If it's missing                            | Quick win                                                                    | Long play strategy                                                                                                                                                                                                                             |
| ---------------------------------------------------- | -------------------------------- | ------------------------------------------ | ---------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Judgement**: the agent does the *right* thing      | Wrong-but-plausible decisions    | Ground it on the company's own data        | Domain fine-tune; the model carries the judgement intrinsically              | An independent critic model, adversarially tuned on the domain corpus, reviews every decision before execution; drift is caught by a continuous evaluation suite tied to the company's own KPIs                                                |
| **Execution**: the agent can't run away              | Destructive or runaway action    | Allowlist its tools; trip a breaker        | Sandboxed execution per tenant; the kernel enforces the boundary             | A capability-bounded sandbox: seccomp profiles plus cgroup hard limits and a revocable policy engine that can pull the plug mid-run; the boundary is not "you can't reach the host" but "you can't exceed your action budget even inside it"   |
| **Identity**: the agent acts as the *right* identity | Unauthorised cross-tenant access | One scoped identity token per tenant       | Per-tenant OS account or container (tier 3+); kernel-enforced, audit-logged  | Per-call, short-lived scoped tokens re-validated on every API invocation rather than a static account; paired with a hash-chained, non-repudiable audit log so the trail itself is tamper-proof                                                |
| **Truth**: the agent says *true* things              | Confidently wrong output         | A deterministic check on structured output | Grounded self-critique; the model verifies against the source                | A separate, context-independent verifier: deterministic checks for structured data, a second model for prose, each fact checked against the source before it ships; truth is checked by the machine, not asked of the generator                |
| **Cost**: the agent stops when it should             | Negative return on investment    | Route by task; cache what repeats          | A distilled model tuned for the task class; cheaper inference in the weights | A live model router that assigns each task to the cheapest model meeting the quality bar, with a feedback loop tracking cost-per-outcome continuously; the economics are a running optimisation across the model portfolio, not a fixed weight |

The incident sat at **Identity** (an agent reached an identity it had no business holding) and **Execution** (an unbounded shell is what did the reaching). Judgement, Truth, and Cost are things the software *asks for*. Identity, in an enterprise, must be *enforced by the machine*; that is where the tiers come back.

For a board, the layers extend into the obligations it owns:

- **Least privilege and segregation of duties.** No single tenant, or admin, should reach every other tenant's data. The internal-control version of tier 3, applied to identities.
- **An audit trail you can stand behind.** Every cross-tenant request, allowed or denied, recorded immutably and attributably. A boundary you cannot audit is one you cannot defend.
- **Data residency.** If a tenant's data must stay in a region, the boundary has to hold there, in placement the OS and database respect, not just the application.
- **The trust model decides the tier.** An internal unit you trust needs a per-tenant account (tier 3); a client's own agent on your infrastructure is untrusted and wants a container or microVM (tiers 4 and 5).
- **The human is still the board.** Until a human who can read the numbers stands behind escalation, budget, and termination, every layer has a single point of human attention.

An enterprise that deploys multi-tenant agents and implements only Judgement and Cost, "it makes good decisions and it is cheap," while skipping a machine-enforced Identity and Execution boundary, has built the most expensive version of this incident and is waiting for it to happen.

---

## What the fix actually looks like

You cannot close tier 3 with a control-plane policy; it cannot stop a process from reaching a foreign credential on disk. The fix stack, in priority order:

1. **Per-tenant identity.** One OS account, or one container, per tenant. A distinct account per tenant means a sibling's key file genuinely cannot be read; a container or microVM also isolates network and disk. Pick by trust model.
2. **Per-tenant credential vaulting.** Move agent and bridge keys off shared plaintext files; each tenant reads only its own. This is the step that turns tier 2 into tier 3.
3. **Kill the shared weak database path.** One database login per tenant, row access scoped to that tenant; drop the single shared login.
4. **Sandbox the agent shell.** Tenant agents get file and database tool restrictions, not a full host shell as the platform owner. In the incident the agent's shell ran unattended and unapproved, the enabler, and the one control that is cheap to close now.

A newer option: YC's [qm](https://github.com/yc-software/qm) gives each *person or room* its own sandbox, key view, and grants on top of existing agent harnesses. But qm's own security documentation is explicit that it is **not a multi-tenant boundary**: its threat model is one organisation of internal users, and its sandbox credentials are plaintext while in use. Point its sandbox at a tier-3 unit and it is useful; use it *as* the boundary and you re-open the same hole in a subtler form.

---

## What this doesn't solve

Two limits the design does not remove:

- **Cost attribution to outcomes.** You can price a single agent action; you still cannot show a board what a tenant *delivered* per dollar in the way a CFO would accept.
- **Cross-tenant federation.** The moment relationships span tenants, the ladder has to be re-applied at the federation boundary.

---

## Conclusion

The model is a commodity, and the control plane is the company. The identity layer underneath both is the boundary. A multi-tenant agent platform is only as isolated as the weakest tier in its ladder: stop at the application's "access denied" and a shared host account, and a capable agent will find the credential that skips it. The work that holds up in practice moves tenant separation from something the software *requests* to something the operating system *enforces*.

That is the difference between a boundary that is verified and one that is real. If you run more than one tenant on a shared host, ask your stack: which tier is it actually enforcing? If the answer is "the 403," you have built a boundary that one command away stops meaning anything.


---

## References

- **Isolation tiers:** Linux `user_namespaces(7)` (a process is uid 0 inside its namespace, unprivileged outside); cgroups; Firecracker / gVisor / Kata for container-vs-microVM isolation.
- **Data-scope boundary:** OWASP Broken Object Level Authorization (BOLA), the API vulnerability class the 403 defends and the agent sidestepped; NIST SP 800-53 Rev 5 `SC-7` / `AC-3` / `AC-6` / `SC-28` (tenant separation); NIST SP 800-145 (multi-tenancy as logical isolation = the weakest tier).
- **Agent-specific framing:** arXiv, "Isolation as a First-Class Principle for LLM-Agent System Safety"; Cyber.gov.au, "Careful adoption of agentic AI services" (agents acting under spoofed or foreign credentials evading audit); Snyk, "AI coding agents writing broken access control."
- **Platform:** [Paperclip](https://github.com/paperclipai/paperclip) (MIT) · [Hermes Agent](https://github.com/NousResearch/Hermes) · [Terry's Paperclip fork](https://github.com/terrygzhou/paperclip)
