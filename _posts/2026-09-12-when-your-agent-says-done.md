---
layout: post
title: When Your Agent Says "Done"
date: 2026-09-12
tags:
  - AI-Agents
  - Agentic-Workflow
  - Verification
  - Open-Source
  - DevOps
---
My own verification script marked a half-finished project complete. That ended the trust-based workflow. Now completion is an observable fact: a task queue, executable checks, a cron runner, exit codes.

If you're running agents on multi-day work:

- **Don't gate on self-reports.** Require an artifact, a test, an exit code.
- **Make completion re-derivable.** Any session should be able to re-verify, cheaply.
- **Verify the verifier.** Test your checks against the way the work could plausibly be skipped.
- **Give fresh sessions a context file.** Memory on disk beats memory in the session.
- **Cap the loop.** N zero-progress cycles → stop, report, escalate to a human.

Your agent is not lying when it says "all done." It's answering the question you asked. Ask it to show instead.

![From trust to evidence: seven stages — the five-step evolution of an evidence-based workflow, plus two properties of the finished system](/assets/2026-09-12-when-your-agent-says-done/phases.svg)

## "All done" — the most expensive claim in agentic engineering

I was refactoring **Digital Twins**, my local AI wiki app, from a Tauri desktop application into a web server. Five phases, multi-day effort, a multi-agent pipeline: an orchestrator dispatches subagents for each work item; subagents write Rust and TypeScript.

Phase three finished, and the agent reported: **"All done."**

No proof. No build output, no test results, no list of touched files. Just a claim. At the time, that was the entire workflow — agent self-reports, I believe it. Completion was trust.

The problem is not that agents lie. It's that **"all done" is the cheapest sentence in the language.** Implementing an endpoint costs tokens and time; asserting it's finished costs nothing. Unless the environment distinguishes the two, every optimizer in the loop finds the cheap path first. So I stopped asking "did you do it?" and started asking for something I can check myself.

## Stage 1: trust. The baseline I outgrew

The first workflow looked like this:

```
User: "Build these 5 phases"
Agent: dispatches 5 subagents
Agent: "All done"
```

The failure mode is subtle. Subagent self-reports ("I wrote the file", "the handler is wired") sound authoritative. They're also unverifiable from outside the session. No mechanism to resume across sessions, no way to detect a stub left in place, no completion criteria. Just the gap between what the agent thinks it did and what actually happened.

I don't distrust my agents. I distrust absence of evidence.

## Stage 2: a checkpoint that proved nothing

So I built a persistent checkpoint: `wiki_resume.py`, a thin orchestrator that loads a JSON task queue, checks each item, and exits `1` if anything is unverified, `0` if everything passes. The idea was sound. The first version of the verification logic was not:

```python
# CHECKED FILE EXISTENCE, NOT ACTUAL WORK
if os.path.exists(filepath) and "NOT_IMPLEMENTED" not in content:
    mark_done()  # FALSE POSITIVE
```

The check passed because *the file existed*. Stub files from an earlier generation step already did. Within one run, everything marked itself done — and I had designed that verification. The agent's handler wiring "existed" as a file while remaining completely unwired; the frontend still called `invoke()` in 12 places. My verifier had become a lie detector with the wires swapped.

That cost me a day, and it set the direction for everything after: **verification logic is itself a product, and it can be wrong in the worst possible way — confidently.**

## Stage 3: completion as an executable fact

The fix: replace every Python heuristic with a shell command that returns `0` only when the work is *actually* present. Each queue item carries a `check` field:

```bash
# Agent wiring: the import AND the runtime must both be in the source
grep -q 'wiki_server::agent' src-wiki-server/src/main.rs \
  && grep -q 'AgentRuntime' src-wiki-server/src/main.rs

# Frontend migration: no Tauri invoke() calls may remain
! grep -r 'invoke(' src/commands/ src/lib/ src/components/ \
  --include='*.ts' --include='*.tsx'

# Build verification: the code compiles
command -v cargo && cargo check --manifest-path src-wiki-server/Cargo.toml
```

`wiki_resume.py` runs each check with `bash -c`, captures the exit code and the first 500 characters of output, and reports gaps. No more "the file is there" — now it's "grep finds the symbol, and the build passes." Two properties matter:

1. **A check must be able to fail visibly.** If a check can't fail for the way the work might actually be missing, it's not a check — it's a rubber stamp.
2. **A check must be re-derivable.** Any future session, any agent, can re-run the same command and get the same fact. Exit codes are the universal interface: `0` means proven, anything else means not proven. The full JSON report gets logged for debugging, but the decision logic only ever reads exit codes.

I deliberately kept the checks in shell rather than rich Python assertions. They're readable, a human can edit them without touching code, and adding a new verification step means editing JSON, not deploying a script.

## Stage 4: closing the loop with cron

A verification script that runs once is a snapshot. The next move was to let the loop run itself:

```json
{
  "schedule": "0 */2 * * *",
  "workdir": ".../digital-twins",
  "prompt": "Run wiki_resume.py → dispatch subagents for gaps → re-verify"
}
```

Every two hours: the script runs. Gaps found → exit `1` → the cron agent dispatches a subagent per gap (capped at three in parallel) with the item's check command as the definition of done. Subagent finishes → script re-runs → next gap. The loop terminates on evidence, not on a report.

## Stage 5: fresh sessions need onboarding

One catch: each cron run spawns a **fresh agent session** with no session memory. It doesn't know the project's architecture, the migration rules, or the queue workflow.

The answer was a single self-contained file — `.state/wiki_context.md` — that onboards any fresh session:

- project architecture (services, ports, Docker stack)
- migration rules (no Tauri calls, use the API client)
- the queue workflow (backlog → in_progress → done)
- how to write good checks

The verification script now prints the context file's path, so the cron agent's first act is always: read the context, read the queue, pick a gap. Continuity stopped depending on any one session remembering anything.

## Stage 6: "done" gets five concrete conditions

With the loop running, I made completion explicit — five conditions, all mechanically checkable:

| # | Condition | Check |
|---|-----------|-------|
| 1 | Queue empty | 0 backlog + 0 in_progress |
| 2 | Script passes | `wiki_resume.py` exits 0 |
| 3 | Rust builds | `cargo check` exits 0 |
| 4 | TypeScript typechecks | `npm run typecheck` exits 0 |
| 5 | Every item check passes | each `check` command exits 0 |

Two more behaviors keep the system honest under real-world conditions:

- **New work appends itself.** Subagents that discover additional work — a missing dependency, a build failure, a new endpoint — append it to the backlog with its own check command instead of silently absorbing it.
- **Blocks get detected.** Five consecutive cycles with zero progress → the loop stops and reports BLOCKED, instead of spinning forever on a gap that needs a human.

Queue-driven beats linear-phase here: items can be reordered, dispatched in parallel, appended dynamically. Linear phase plans can't absorb discovery.

## Stage 7: the verifier itself gets verified

A late-stage bug added one more layer I think about more than the rest. At some point a queue item's check was just `cargo check` — the build compiles, so mark done. But a clean build proves *nothing* about whether a specific endpoint exists. The script now keeps a list of checks that are **too broad to be sufficient on their own** and rejects them:

```
BROAD_CHECK_REJECTED: 'cargo check ...' — must grep for endpoint-specific code
```

The pattern is general: the first verification you write is usually weaker than you think, and it fails *while making you feel safe*. The same defect from stage 2 (existence ≈ implementation) resurfaced in a new form (compiles ≈ exists), and only an explicit policy against it — enforced by the script, not by memory — caught it.

## What this is, in one paragraph

An agent's self-report is a claim. A check command's exit code is a fact. Everything above is the machinery that converts claims into facts:

1. **Queue** — explicit state in JSON; any session can see what's pending
2. **Checks** — executable, file-specific, able to fail visibly
3. **Loop** — cron re-runs verification; gaps spawn work; termination is evidence
4. **Context file** — fresh sessions onboard from disk, not from memory
5. **Completion criteria** — five conditions, all mechanical
6. **Meta-verification** — the verifier's rules are enforced by the script itself

I've since run the same loop in two more projects. The same `.state/` layout — queue JSON, context file, check commands — is now my standard operating procedure. It's not glamorous. It's also the reason I can open any project on any machine, run one command, and know exactly what's true.

## Why this matters

This is the same discipline that separates a governed agent programme from a demo. My [executable enterprise architecture](2026-07-01-executable-enterprise-architecture.md) work is built on the identical idea: a policy written in prose is a claim, and a policy you can *run* is a control. "The agent should verify its work" in a governance document is worth nothing until something — a check command, a CI gate, an exit code — enforces it.
