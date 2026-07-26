---
layout: post
title: Managing Context Overflow in AI Coding Agents
date: 2026-07-26
tags:
  - AI-Agents
  - ACP
  - Context-Management
  - Vibe-Coding
  - Open-Source
  - VSCode
draft: false
summary: Context overflow is an architecture problem. When coding in a large project codebase, context windows kill agent sessions mid-task. Here's how I architect handoff files, subagent delegation, and task decomposition to keep coding agents productive across session boundaries.
---
Context overflow is an architecture problem. When coding in a large project codebase, context windows kill agent sessions mid-task. Here's how I architect handoff files, subagent delegation, and task decomposition to keep coding agents productive across session boundaries.

The session always dies. You're deep into a coding task — the agent is refactoring, testing, iterating — then the context window fills, the conversation stalls, and you're staring at half-finished work. Next session starts, the fresh agent spends 30 minutes re-familiarising itself with what already happened, and the cycle repeats.

One-million-token context windows are a temporary fix that burns through tokens faster. The real solution is not bigger models — it's better architecture around how agents persist state and delegate work.

---

## 1. Handoff Files and Git Commits: The Agent's Survival Pair

Every agent session is a shift. When it ends — by context overflow or intentional pause — the agent must **commit its work** and **write a handoff document**. The commit is the immutable proof of what changed. The handoff is the human-readable summary of where to resume.

The handoff lives in the project root, under 50 lines. Not a transcript — a structured summary:

- **Completed:** task names with short commit hashes (e.g., `a1b2c3d`)
- **In Progress:** current task, what's committed, what remains
- **Decisions:** architectural choices, trade-offs, rationale
- **Blockers:** unresolved issues needing human input
- **Next Steps:** the exact task to pick up

The next session reads the handoff, then runs `git diff HANDOFF_COMMIT..HEAD` to see exactly what changed since the last checkpoint. No guessing, no re-scanning 200 files.

Commit regularly during the session too. Every completed sub-task gets its own commit, so the handoff simply references the latest commit hash. This pair beats either one alone — handoff without commits is a description that could be wrong; commits without handoff means the next agent has to read every diff to understand intent.

---

## 2. Wire It Into AGENTS.md

Handoff discipline must be baked into the project's `AGENTS.md` — the instruction file every agent reads on session start. Otherwise it's optional and won't happen consistently:

```
## Session Handoff
Before ending any session (context overflow, user request, or task completion):
1. Commit all completed work with descriptive messages.
2. Write a handoff summary to .hermes/handoff.md (max 50 lines).
3. Include commit hashes for completed tasks, not descriptions.
4. The next session will load this file and resume immediately.
```

Two rules:
- **Trigger at 50% context utilisation**, not 90%. At 90%, there's no room left to write the handoff — the agent is already struggling. 
- **Keep it under 50 lines.** If the handoff itself needs compression, the task decomposition is wrong.

---

## 3. Subagents Are Your Multiplier

Each subagent gets its own context window — the single most underutilised resource in agentic workflows.

Instead of one agent burning through 128K tokens on a monolithic task, spawn three subagents on independent slices. Each operates in a clean context, commits its own work, and writes a one-line summary. The parent handoff becomes an aggregate: three commit hashes, three summaries instead of a wall of text.

| Approach | Context burn | Parallelism | Recovery |
|---|---|---|---|
| Single agent, large task | 128K tokens, one window | None | Session loss = full restart |
| Three subagents, decomposed tasks | 4 x 128K tokens, isolated | 3x concurrent | One failure doesn't kill all work; commits preserve completed slices |

---

## 4. Task Decomposition Is The Real Skill

The hardest part is breaking a large task into thin, independent slices that agents can own end-to-end.

Thin vertical slices, not horizontal layers. A "horizontal layer" approach (e.g., "build all the data models") still requires understanding the full system. A vertical slice (e.g., "implement user registration: model, endpoint, form, test") is self-contained and deliverable.

Good decomposition follows three rules:

1. **Each task fits in one agent session.** If it regularly overflows context, it's too big.
2. **Tasks have clear entry/exit criteria.** The agent knows when it's done — passing tests, committed to git.
3. **Dependencies are explicit.** Task B needs Task A's output — make it a file path or commit hash, not a vague "when the API is ready."

---

## 5. The ACP Extension: Context Visibility

The ACP extension shows context utilisation in real time — see the context bar (find details from https://github.com/terrygzhou/vscode-acp and follow instructions to install to your preferred IDEs) climb and trigger handoff at 50%, not at the point where the model starts hallucinating.  Built on the open Agent Client Protocol, it works in VS Code, Zed, or JetBrains without leaking conversation noise into the context window.

---

## Trade-offs

| Factor | Reality |
|---|---|
| Handoff adds overhead | Yes — 2-3 minutes per session. Worth it vs. 30 minutes of re-familiarisation. |
| Subagent coordination is manual | The orchestrator still defines tasks, sequences dependencies, and verifies outputs. |
| Not every task decomposes cleanly | Some refactoring tasks are inherently systemic. Group them into focused sessions. |
| 50-line handoff is aspirational | The discipline is to reference commit hashes instead of rewriting what changed. |

---

## Verdict

Context overflow is not a model problem. It's an architecture problem. The five-practice stack — git commits after every task, handoff files wired into AGENTS.md, 50% context triggers, subagent delegation, and task decomposition — every item costs minutes of setup and saves hours of wasted context.

Bad prompt engineering, model quality limits, and human oversight still matter. Handoff doesn't replace any of them — it just makes recovery faster.

Your agents don't need infinite context — they need discipline.
