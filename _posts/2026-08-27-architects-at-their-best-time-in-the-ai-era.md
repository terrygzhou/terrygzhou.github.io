---
layout: post
title: Software Architects Are at Their Best Time in the AI Era
date: 2026-08-27
tags:
  - software-architecture
  - agentic-architecture
  - ai-agents
  - software-engineering
  - enterprise-architecture
  - ai-transformation
description: AI coding keeps lowering the implementation bar, and that is exactly why the architect is more valuable, not less. The bottleneck moves up to design, conformance, and judgment — the layer where strategic, systematic thinking and the specification already live.
summary: "The fear is that agentic coding makes the architect obsolete. It does the opposite: it removes the part of the job that was never the value and leaves the part that was. When the implementation floor has a machine under it, the role can finally sit at the top — strategy, tradeoff judgment, and the specification that is the recipe for the build."
permalink: /2026-08-27/architects-at-their-best-time-in-the-ai-era
draft: true
---

Would architects lose jobs? An agent scaffolds the service, wires the API, writes the tests — before standup ends. So the argument goes: why keep a person who mostly drew boxes?

It does not hold. AI coding lowers the implementation bar — and that is the single most important thing that has happened to the discipline. The part of the job that was never the value (keeping up with code, syntax, framework churn) now has a machine under it. What is left is the part that was: **the design, the judgment on tradeoffs, the enforcement of conformance, and the decision.** The role is not squeezed; it is freed to sit at the top.

---

## The implementation bar is down

A decade ago "know the stack" was a real load: be credible across a language, a runtime, a data store, a cloud provider, a deployment model. No one mastered all of it, and pretending otherwise is how bad designs get signed off.

Agentic coding changes the economics. The same agent that writes TypeScript writes Go and SQL. Implementation becomes **agnostic across technologies no one could master anyway**, and the cost of "write it" keeps dropping. When that line goes down, the constraint stops being "can we build it" and becomes three questions the machine does not answer for you:

- **Should we build it this way?** — the design and the tradeoff between alternatives.
- **Does what got built conform to what we decided?** — the enforcement, the contract, the review.
- **Did we decide the right thing?** — the judgment, the decision, the accountability.

Those three questions are the architect's. The machine lowered the bar underneath them. It did not touch the bar itself.

---

## What the promotion looks like

The skills that made a good architect are the scarce layer now. They were always the job, buried under code-level detail that ate the hours. With the floor braced by agents, the whole weight shifts to the top.

| Architect skill | Why it is worth more now |
|:---|:---|
| **Strategic thinking / big picture** | The design has to hold across years, teams, and models that change every quarter. Only the person at the picture level can keep a coherent course. |
| **Judgment on tradeoffs** | Agents produce many "correct" implementations. Choosing between them is a value call, not a compile check. That is a judgment, and a human owns it. |
| **Holding many views at once** | One system, seen by the business, the operator, the security team, the next quarter's team. The architect is the only role that keeps those views aligned instead of letting each team own a slice. |
| **Staying at the spec and model level** | You are not in the code with the agents. You are above it, at the level where a wrong decision is still cheap to fix. That is the high-leverage seat. |

The last row gets missed most. Staying out of the detail is not laziness — it is where the leverage is. The moment an architect writes the code, they stop seeing the whole board. And the whole board is the job.

---

## Catching the big fish

At the spec and model level you see the problem domain as a domain, not a backlog. From code you see functions and files. From the model level you see the **big fish** — the structural issues that decide whether the system wins or quietly decays: the boundary you should have drawn two designs ago, the coupling that will cost you in year two, the data model that looks fine today and will not survive the next requirement.

Those issues are invisible from the bottom. An agent swarm will faithfully implement a bad boundary; it will not tell you the boundary is the mistake. That catch is the architect's — the most expensive thing they do, more expensive than any line of code they could have written.

The research has named this risk. [*Architecture Without Architects: How AI Coding Agents Shape Software Architecture*](https://arxiv.org/abs/2604.04990) (arXiv, 2026) catalogs how coding agents quietly make architectural choices — frameworks, databases, deployment targets — and coins the term *vibe architecting*: architecture shaped by prompts, not deliberate design. Its finding is this section's point in one line: those decisions are real, architectural, and almost no one reviews them as such. The big fish is not a metaphor. It is the specific, unreviewed decision an agent just made.

---

## The architect as agent director

The new superpower is not "writes better specs." It is **systematic thinking that scales to an army of agents.** Ten coding agents is not ten conversations — it is one director with ten hands. The director does not micro-manage keystrokes; that drives every agent off track and burns your attention. They hold the picture, set the constraints, hand each agent a well-scoped slice.

That is the skill that separates a person who directs agents from a person who drowns in them:

- **You stay at the specification, not the diff.** The spec is the interface. You review the decision, not every token.
- **You enforce conformance instead of chasing code.** The agent's output is checked against the contract you wrote, not against your memory of what you asked.
- **You do not micro-manage into the track.** The moment you start steering individual edits, the agents stop being a team and become ten slow typosists.

The people who run agent-heavy teams are not the best coders. They hold the whole system in their head, split it cleanly, and tell each part exactly what "done" means. That is the architect, unmodified — now pointed at more workers.

A 2026 *Frontiers in AI* study, [*Comparative Analysis of Strategic vs. Computational Thinking in Management*](https://www.frontiersin.org/journals/artificial-intelligence/articles/10.3389/frai.2026.1729797/full), maps this split in data: pure information-processing work — monitoring, disseminating, resource allocation — is absorbed by machines, while strategic work — value-based tradeoffs, contextual interpretation, principled override — stays anchored to a human. The director's job is the second layer, not the first.

---

## The specification is the recipe

The part the industry under-prices. In an AI-era team the spec **is the recipe for software development** — the thing agents build against, the thing review checks against, the thing that stays true when the language, framework, and model underneath all change.

That makes creating, reviewing, and maintaining specifications a durable, high-value discipline:

- **Create** it well and the agents build the right thing with less of your attention.
- **Review** it and you catch the bad decision at the only point where it is still cheap.
- **Maintain** it and the system stays coherent as the agents keep churning implementation underneath.

The recipe survives the ingredients. Languages rotate, frameworks fall out of fashion, models are replaced. The specification — intent, boundaries, tradeoffs made explicit — is what stays. Whoever owns it owns the system.

This is now a named discipline. [*Spec-Driven Development: From Code to Contract in the Age of AI Coding Assistants*](https://arxiv.org/abs/2602.00180) (arXiv, 2026) makes the spec the source of truth, treats code as a secondary artifact, and lays out a maturity ladder: **spec-first**, **spec-anchored**, **spec-as-source**. The last is the whole discipline the architect now owns: the human edits the spec, the machines build against it. The industry has started shipping it — GitHub Spec Kit, Kiro, Tessl — covered by Birgitta Böckeler's [*Understanding Spec-Driven Development*](https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html), which carries the same caution this post keeps repeating: the tooling lowers the bar, but the spec that multiplies across every agent has to be the one you would sign.

---

## Asking the right questions

The last and least commoditizable role has nothing to do with code. The business does not speak in requirements; it speaks in outcomes, fears, and half-formed intent. Someone has to translate "we need to be faster and safer" into a decision the system can be built from.

That translation does not get automated. It is a judgment about what the organization is actually trying to do, under constraints nobody has written down. The architect asks the question the business did not know it was being asked, and turns the answer into a specification. No agent does that for the room. That is the seat, and it is at the top of the table by construction.

---

## Trade-offs

| What you give | What you get |
|:---|:---|
| Leave the code to the agents | Your attention goes to the design, the picture, and the decision — the part that compounds |
| Hold the spec above the diff | Faster, but a bad spec now multiplies; the review gate has to stay strict |
| Stop being the best coder on the team | You become the best *decider* on the team, which is worth more at scale |
| Take the accountability the machine does not take | The decision and its consequences stay yours — that is the job and the point |

The honest risk: a bad spec multiplies across every agent that reads it, and the review gate has to stay strict or the swarm faithfully builds the wrong thing at high speed. The role got bigger, not smaller — and the failure mode got more expensive. That is a reason to do it at the level it belongs, not to drop it.

---

## At EyWALink, everyone is an architect first

At EyWALink the architect is not a role you grow into on the way to "the real job" — it is the first identity. We staff ourselves as architects before anything else, because that is what keeps the house honest: **do the right thing, then do it right.**

- **The right thing comes first.** The design, the boundaries, the tradeoff, the specification — the picture — is settled before implementation starts, not discovered in the diff. "Right thing" is a decision; it is made at the model level, where it is still cheap.
- **Then do it right.** Only with the picture fixed does execution begin, and execution is exactly the part the agents now carry. Conformance, correctness, and craft run underneath a decision that was already made and signed off.

That ordering is the whole point of the discipline, and why the architect sits at the top. An organization that inverts it — lets implementation decide the design, hand-holds agents into shape after the fact — has skipped the expensive step and will pay for it in a system that is fast to build and wrong by construction. We do not skip it. We start at the right thing and let the machines do the doing.

---

## Conclusion

The architect is not in their last time. They are in their best time. The implementation floor has a machine under it, so the role can finally sit where it was always meant to sit — at the picture, holding the tradeoffs, catching the big fish, writing the specification that is the recipe for the whole build.

The question is not "does AI replace the architect." It is whether you will take the promotion. The floor is gone. The top of the house is open. The people who spend the next five years holding the picture, not the diff, will run the systems the rest of the industry is still hand-holding into shape.

If your team's architects are still writing the code they should be directing, you are paying them to be the slowest worker on the floor. Set them at the top. Let's talk.

---

## Sources

- Centre for Industrial Software, University of Southern Denmark (2026). *Architecture Without Architects: How AI Coding Agents Shape Software Architecture*. arXiv:2604.04990. <https://arxiv.org/abs/2604.04990> — implicit agent architecture decisions; "vibe architecting."
- Nyenno (2026). *Comparative analysis of strategic vs. computational thinking in management*. Frontiers in Artificial Intelligence 9:1729797. <https://www.frontiersin.org/journals/artificial-intelligence/articles/10.3389/frai.2026.1729797/full> — which managerial work absorbs into machines and which stays anchored to a human.
- Piskala (2026). *Spec-Driven Development: From Code to Contract in the Age of AI Coding Assistants*. arXiv:2602.00180. <https://arxiv.org/abs/2602.00180> — spec-first / spec-anchored / spec-as-source maturity ladder.
- Böckeler (2025). *Understanding Spec-Driven Development: Kiro, spec-kit, and Tessl*. martinfowler.com. <https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html> — practitioner view of SDD tooling and its open questions.
