---
layout: post
title: "Managing Context in Vibe Coding: How I Keep Agents Alive Across Sessions"
date: 2026-07-26
tags:
  - AI-Agents
  - ACP
  - Context-Management
  - Vibe-Coding
  - Open-Source
draft: true
summary: Context overflow is an architecture problem. When you code in a large project codebase, did you notice that context windows kill agent sessions mid-task. Here's how I architect handoff files, subagent delegation, and task decomposition to keep coding agents productive across session boundaries.
---

# Managing Context in Vibe Coding: How I Keep Agents Alive Across Sessions

The session always dies. You're deep into a coding task — the agent is refactoring, testing, iterating — then the context window fills, the conversation stalls, and you're staring at half-finished work. Next session starts, the fresh agent spends 30 minutes re-familiarising itself with what already happened, and the cycle repeats.

One-million-token context windows may help, but they're a temporary fix that burns through tokens faster that leads to your token costs. The real solution is not bigger models — it's better architecture around how agents persist state and delegate work.

Here's what works in practice, built over my months of running AI agents through VS Code via the ACP extension.

---

## 1. Handoff Files and Git Commits: The Agent's Survival Pair

Every agent session is a shift. When the shift ends — whether by context overflow or intentional pause — the agent must do two things before going offline: **commit its work** and **write a handoff document**. Together they form a survival pair. The commit is the immutable proof of what changed. The handoff is the human-readable summary of where to resume.

The handoff file lives in the project root, concise — under 50 lines. Not a conversation transcript. A structured summary:

- **Completed:** task names with short commit hashes (e.g., `a1b2c3d`)
- **In Progress:** current task, what's committed, what remains
- **Decisions:** architectural choices, trade-offs, rationale
- **Blockers:** unresolved issues needing human input
- **Next Steps:** the exact task to pick up

The git commit is the anchor. When the next session starts, the new agent reads the handoff file, then runs `git log --oneline -5` or `git diff HANDOFF_COMMIT..HEAD` to see exactly what changed since the last handoff point. No guessing, no re-scanning 200 files. The handoff tells you what to do; the commit history tells you what's already done.

Commit regularly during the session too — not just at handoff time. Every completed sub-task gets its own commit. That way when context overflows mid-task, the agent has already checkpointed the parts that finished. The handoff references the latest commit hash, and the next session knows the exact starting point.

This pair (handoff + commits) beats either one alone. Handoff without commits is just a description that could be wrong. Commits without handoff means the next agent has to read every diff to understand intent. Together they're fast recovery.

---

## 2. Wire Handoff into AGENTS.md

Handoff and commit discipline must be baked into the project's `AGENTS.md` — the instruction file that every agent reads on session start. If it's a separate skill the agent might or might not load, it won't happen consistently.

The `AGENTS.md` section looks like this:

```
## Session Handoff
Before ending any session (context overflow, user request, or task completion):
1. Commit all completed work with descriptive messages.
2. Write a handoff summary to .hermes/handoff.md (max 50 lines).
3. Include commit hashes for completed tasks, not descriptions.
4. The next session will load this file and resume immediately.
```

Two rules:
- **Trigger at 50% context utilisation**, not 90%. At 90%, there's no room left to actually write the handoff or run the commit — the agent is already struggling to complete any meaningful output.
- **Keep it under 50 lines.** If the handoff itself needs compression, the task decomposition is wrong.

---

## 3. Subagents Are Your Multiplier

Each subagent gets its own context window. That is the single most underutilised resource in agentic workflows.

Instead of one agent burning through 128K tokens on a monolithic task, spawn three subagents working on independent slices. Each one operates in a clean context, focused on its slice, with minimal overhead from conversation history. Each subagent commits its own work on completion — so the git history becomes a tree of independent branches rather than one long linear chain.

| Approach | Context burn | Parallelism | Recovery |
|---|---|---|---|
| Single agent, large task | 128K tokens, one window | None | Session loss = full restart |
| Three subagents, decomposed tasks | 4 x 128K tokens, isolated | 3x concurrent | One failure doesn't kill all work; commits preserve completed slices |

Subagents also simplify handoff — each one writes its own concise summary and its own commit. The parent handoff file becomes an aggregate: three commit hashes and three one-line summaries instead of a wall of text.

---

## 4. Task Decomposition Is The Real Skill

The hardest part is not configuring tools or tuning models. It is breaking a large task into thin, independent slices that agents can own end-to-end.

Thin vertical slices, not horizontal layers. A "horizontal layer" approach (e.g., "build all the data models") still requires understanding the full system. A vertical slice (e.g., "implement user registration: model, endpoint, form, test") is self-contained and deliverable.

Good decomposition follows three rules:

1. **Each task fits in one agent session.** If a task regularly overflows context, it's too big.
2. **Tasks have clear entry/exit criteria.** The agent knows when it's done — passing tests, updated files, verified output, committed to git.
3. **Dependencies are explicit.** Task B needs Task A's output. That's fine — just make it a file path or commit hash, not a vague "when the API is ready."

This is where experienced architects outperform everyone else. You don't need better models — you need better task breakdown.

---

## 5. The ACP Extension: Context Visibility That Matters

The VS Code shows context utilisation in real time. That visibility changes how you work:

- **Monitor, don't guess.** See the context bar climb and trigger handoff at 50%, not at the point where the model starts hallucinating.
- **Session boundaries are clear.** ACP manages sessions explicitly — you know when one ends and another begins, rather than wondering if the agent is still grounded in the right context.
- **Tools and skills load predictably.** ACP wires the agent into the IDE's file system, terminal, and tools without leaking unrelated conversation noise into the context window.

The extension is built on the Agent Client Protocol — an open standard that decouples IDE frontends from agent backends. That means the same agent runtime works in VS Code, Zed, or JetBrains without rewriting integration logic.

---

## The Trade-offs

| Factor | Reality |
|---|---|
| Handoff adds overhead | Yes — 2-3 minutes per session to write and later read. Worth it compared to 30 minutes of re-familiarisation. |
| Subagent coordination is manual | The orchestrator still needs to define tasks, sequence dependencies, and verify outputs. No magic. |
| Not every task decomposes cleanly | Some refactoring tasks are inherently systemic. Group them into focused sessions rather than forcing artificial splits. |
| 50-line handoff is aspirational | Complex sessions need more detail. The discipline is to keep it concise by referencing commit hashes instead of rewriting what changed. Read the diff if you need context. |

---

## What This Doesn't Solve

- **Bad prompt engineering.** Handoff doesn't fix vague or contradictory instructions. Garbage in, garbage out.
- **Model quality.** A 27B local model still struggles with the same reasoning tasks that stump any model. Decomposition helps but doesn't replace capability.
- **Human oversight.** Agents still need review. Handoff makes review easier — you see the shift report before approving the next session.

---

## Verdict

Context overflow is not a model problem. It's an architecture problem. The agents that survive session boundaries are the ones that persist state, delegate work, and operate on decomposed tasks — not the ones running on 1M-context models burning through tokens.

The six-practice stack: git commits after every task, handoff files, AGENTS.md wiring, 50% context triggers, subagent delegation, and task decomposition. Every item costs minutes of setup and saves hours of wasted context.

When the open-source agent ecosystem matures, the winners will be the frameworks that bake these patterns in — not the ones that chase bigger context windows.

Every time another team ships an agent that survives its own session boundary, we strengthen the entire agentic workflow ecosystem. Your agents don't need infinite context — they need discipline.

Let's talk. How are you handling session boundaries in your agent pipelines?

---

*Tags: `#AIAgents` `#ACP` `#ContextManagement` `#VibeCoding` `#OpenSource` `#VSCode`*
