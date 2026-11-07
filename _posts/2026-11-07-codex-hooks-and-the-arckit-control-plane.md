---
layout: post
title: "How Powerful Codex Hooks Are: ArcKit Makes Them a Control Plane"
date: 2026-11-07
tags:
  - codex
  - ai-agents
  - agentic-architecture
  - hooks
  - open-source
  - arckit
  - guardrails
  - software-engineering
description: "Codex hooks spawn a shell command at a lifecycle event and hand you control with JSON on stdout plus an exit code. Here's how ArcKit wires six of those events to one Node script that acts as a guardrail, a context injector, and a session logger."
summary: A Codex hook is a shell command Codex spawns at a lifecycle event, fed JSON on stdin and answered with JSON on stdout. The model can't skip it. That's the whole idea. My architecture AI tool, ArcKit, wires six of those events to one Node script that acts as a guardrail, a context injector, and a session logger. That's why the toolkit behaves like a control plane instead of a prompt pack.
permalink: /2026-11-07/codex-hooks-and-the-arckit-control-plane
---

People treat codex like a bigger, faster terminal with a language model pasted in. Then they discover the model would `rm -rf` your `.env`, drop a `sk-` key into a file, or ship an artifact with a filename that breaks the whole document taxonomy, and they ask how to stop it. The fix is a hook, not more text in the system prompt.

This post has two halves. First, how Codex hooks actually work, because most of the public write-ups get the mental model slightly wrong. Second, how [ArcKit](https://github.com/terrygzhou/arc-kit) uses all six of the available hook events to turn a coding agent into something that behaves like a control plane for an architecture practice.

---

## 1. How hooks work: a command, not a prompt

A Codex hook is a command that Codex spawns at a lifecycle event. It receives its context as JSON on stdin, and you control what happens next with JSON on stdout plus an exit code. The model never runs the hook and can't skip it or rewrite it mid-flight. That's what makes a hook a guarantee instead of a request.

Codex hooks are portable because Codex sets `CLAUDE_PLUGIN_ROOT` and `CLAUDE_PLUGIN_DATA` for Claude Code compatibility, and accepts the same event names and stdin shape for the common events, so a Claude Code hook script often runs in Codex unchanged, with only the config file differing:

- `~/.codex/hooks.json`: user-level, JSON
- `~/.codex/config.toml`: user-level, inline `[[hooks.*]]` TOML tables
- `.codex/` in the project: project-scoped, loads only in trusted projects
- a managed `requirements.toml`: policy, can't be disabled from the UI

A few rules that aren't obvious from the docs:

- All matching layers run. None override each other. If user, project, and managed config all define a `PreToolUse` hook, all of them fire.
- Multiple hooks for one event run concurrently. One hook cannot stop another hook from starting. They're siblings, not a chain.
- The `matcher` is a regex over `tool_name`. `"^Bash$"`, `"apply_patch|Edit|Write"`, `"mcp__github__.*"`, or empty/`*` for everything.
- Trust is by hash. A non-managed command hook must be reviewed and trusted in `/hooks`, and Codex records the trust decision against a hash of the script. Edit the script and it silently stops firing until you re-review. This bites people constantly.
- You can switch the whole thing off with `[features] hooks = false` in `config.toml`.

### The lifecycle events

They fall into three groups:

- Inside a turn: `PreToolUse`, `PermissionRequest`, `PostToolUse`, `PreCompact`, `PostCompact`, `UserPromptSubmit`, `SubagentStop`, `Stop`
- Per model-request attempt: `PreModelRequest`, `PostModelRequest`
- Boundaries: `SessionStart`, `SubagentStart`, `SessionEnd`, `Interrupt`

### What each one can decide

A few of these behave counterintuitively, and the public write-ups cover them unevenly.

- `PreToolUse` is the blocking guardrail. Block a tool call by exiting with code 2 (the reason goes on stderr) or by emitting JSON with `permissionDecision: "deny"`. As of mid-2026 it does not support `"ask"`: return that and Codex marks the hook run as failed and the tool call proceeds unblocked. It supports `"allow"` (pre-approve the call, or pair with `updatedInput` to rewrite it before it runs, which is useful for trusted plugin-internal paths) and `"deny"`.
- `Stop` and `SubagentStop`: `decision: "block"` means "don't stop, keep going." The word "block" is the opposite of what you'd guess; it blocks the stop and forces the agent to continue.
- `UserPromptSubmit`: your stdout becomes extra context for the turn, and `decision: "block"` refuses the prompt outright. This is the event people under-use. It's your chance to inject context before the model even starts reasoning.
- `PostToolUse`: `systemMessage` gets injected as a note. This is where auto-format, lint, and "I just did X" logging live. It runs after the write, so it can safely modify files the tool just touched.
- `PermissionRequest` fires when a tool needs an approval. You can auto-allow a known-safe set, which is how ArcKit whitelists its MCP servers (below).

### Hooks vs. static rules

Codex also has cheap, static policy files under `.codex/rules/` that fire before the model decides to call a tool: allow/forbid lists, no scripting. Use those for the dumb stuff. Use hooks for anything dynamic, like secret scanning, logging, context injection, validation, or formatting. In practice you run both.

One caveat: `PreToolUse` is a guardrail, not a security boundary. The model can route around it through a different tool path. Don't build hard security on it. Build it so the blast radius is small if it's bypassed.

---

## 2. The ArcKit use case: six events, one script, a control plane

ArcKit is an open-source governance toolkit for architecture work. It turns an agent into a disciplined practitioner who produces `ARC-NNN-TYPE-vN.N.md` artifacts (requirements, ADRs, risk registers, compliance assessments) and keeps the whole graph of those documents consistent. It ships a target-specific extension for several agent harnesses. The Codex one, `extensions/arckit-codex/`, is where hooks earn their keep.

The whole hook layer is one Node script, `hooks/arckit-codex-hook.mjs`, wired to six events. The three jobs it plays (guardrail, context injector, session logger) and the memory loop that closes between `Stop` and `SessionStart` are the shape of a control plane:

![Codex hooks with ArcKit. One script wired to six lifecycle events, grouped as guardrail / context injector / session logger, with Stop writing memory that the next SessionStart reads back](/assets/2026-11-07-codex-hooks-and-the-arckit-control-plane/arckit-codex-hooks.html)

([`arckit-codex-hooks.html`](/assets/2026-11-07-codex-hooks-and-the-arckit-control-plane/arckit-codex-hooks.html))

The config is the boring part, so here's the shape (from `config.toml`, auto-generated by the converter from the Claude source plugin):

```toml
[features]
hooks = true

[[hooks.SessionStart]]
# Valid values: startup|resume|clear|compact|fork — ArcKit only needs the first three
matcher = "startup|resume|clear"
[[hooks.SessionStart.hooks]]
type = "command"
command = '... node "$HOOK" SessionStart'
timeout = 10
statusMessage = "Loading ArcKit context"

[[hooks.PreToolUse]]
matcher = "Bash|apply_patch|Edit|Write"
[[hooks.PreToolUse.hooks]]
type = "command"
command = '... node "$HOOK" PreToolUse'
timeout = 10
statusMessage = "Checking ArcKit file policy"

[[hooks.PostToolUse]]
matcher = "apply_patch|Edit|Write"
[[hooks.PostToolUse.hooks]]
type = "command"
command = '... node "$HOOK" PostToolUse'
timeout = 10
statusMessage = "Stamping ArcKit provenance"

[[hooks.PermissionRequest]]
matcher = "mcp__.*"
[[hooks.PermissionRequest.hooks]]
type = "command"
command = '... node "$HOOK" PermissionRequest'
timeout = 10
statusMessage = "Checking ArcKit MCP allowlist"

[[hooks.Stop]]
[[hooks.Stop.hooks]]
type = "command"
command = '... node "$HOOK" Stop'
timeout = 10
statusMessage = "Recording ArcKit session"

[[hooks.UserPromptSubmit]]
[[hooks.UserPromptSubmit.hooks]]
type = "command"
command = '... node "$HOOK" UserPromptSubmit'
timeout = 10
statusMessage = "Scanning prompt"
```

Notice the `command` line: it's a resolver that finds the script from the plugin root, the project's `.codex/hooks/`, or the installed plugin cache, in that order, then runs `node "$HOOK" <EventName>`. The event name is a plain argv, so one script services all six events. That's a design decision worth copying: keep the config declarative and dumb, and push all the logic into a single script that's trivial to test and review.

Each hook also gets a `timeout` (10s) and a `statusMessage`, which is what the user sees in the TUI: "Loading ArcKit context," "Checking ArcKit file policy," "Recording ArcKit session." It's the only UI surface a hook has, so name it well.

Here's what each event does in the ArcKit implementation, and why it matters:

### `SessionStart`: prime the workspace before the model thinks

On startup/resume/clear, the hook walks up from `cwd` to find the workspace root (looks for `.arckit`, `projects/`, or `.git`), reads the plugin version, builds a project inventory ("MarsEV: 42 markdown artifacts"), loads `.arckit/memory/sessions.md` if present, checks template freshness, and emits all of it as `additionalContext` on `SessionStart`. The model's first turn already knows where the project is, what artifacts exist, and what it did last session, without the user having to type "here's the context."

### `UserPromptSubmit`: block secrets, inject the artifact graph

Two jobs. First, `detectSecrets()` regex-scans the incoming prompt for `sk-` keys, `AKIA` AWS keys, `ghp_` tokens, `AIza` Google keys, `xox` Slack tokens, and `-----BEGIN ... PRIVATE KEY-----`. If the prompt contains one, `blockPrompt()` fires with `decision: "block"` and a reason telling the user to use an env var or secret manager instead. This is the prompt-level twin of the tool-level guardrail below.

Second, if the prompt mentions an ArcKit command (`$arckit-search`, `/arckit:traceability`, etc.), the hook runs a graph scan over every `ARC-*.md` file in `projects/`, extracts document IDs, requirement IDs (`BR-001`, `FR-012`), cross-references, and status fields, and injects the resulting artifact graph as context. The model gets a pre-computed dependency map instead of re-reading 40 files. For the `search` command it's a JSON index; for `traceability` it's a requirement-coverage matrix; for `health` it's which projects are missing essential docs. It's the highest-leverage use of the event in the whole system: a corpus scan turned into a model-facing data structure before the turn starts, for free.

### `PreToolUse`: the guardrail

The `PreToolUse` handler (`handlePreToolUse`) is a decision tree:

1. Auto-allow the boring stuff. Reading a file under the plugin root, or reading an ArcKit-managed `/tmp/arckit-*-handoff.json`, or running a whitelisted plugin helper script (`bash/create-project.sh`, etc.) calls `allowTool()`, with a reason. Pre-approval for the known-safe paths means the user isn't pestered for permission on every file read.
2. Validate the artifact filename. If the tool is writing an `ARC-*.md` file, the filename must match `ARC-\d{3}-.+-vN.N.md` or it's `denyTool()`'d. This is the taxonomy enforcement that keeps the whole document graph parseable.
3. Block protected files. A `PROTECTED_BASENAMES` set (`.env`, `id_rsa`, `credentials.json`, `service-account.json`, ...) plus protected extensions (`.key`, `.pem`, `.p12`). Editing any of them is denied.
4. Scan the patch for secrets. For `apply_patch`, the handler extracts the added lines and runs `detectSecrets()` on them. A `sk-` key in a patch is denied, with the specific pattern named.
5. Validate structured payloads. Writing a `vendors/scores.json` triggers a JSON-schema-ish validation: criteria weights must sum to ~1.0, every score in 0-3, every referenced criterion must exist. Fatal errors deny; warnings `warnTool()` a `systemMessage`.

Each of these is a few lines of `if` against the JSON on stdin. The mental model is "a lint check that can say no."

### `PermissionRequest`: whitelist the MCP servers

ArcKit configures a bunch of MCP servers (AWS Knowledge, Microsoft Learn, Google Developer Knowledge, Data Commons, govreposcrape, UK Tenders). Without a hook, the agent pings the user for permission on every MCP call. `handlePermissionRequest` checks whether the tool name starts with one of `ALLOWED_MCP_PREFIXES` and, if so, `allowPermission()`, so no prompt. Unknown MCP servers still fall through to the normal approval. This is `PermissionRequest` doing exactly what it's for: encode a trust policy instead of a thousand yes/no clicks.

### `PostToolUse`: the side effects run after the write

When `apply_patch`/`Edit`/`Write` touches an `ARC-*.md` project artifact, two things happen after the file is on disk:

- Provenance stamp. A `<!-- arckit-provenance -->` block gets injected recording when it was written, which hook, which model, which tool, which session/turn. It's idempotent: it replaces an existing block rather than stacking one. This is the "who made this and when" layer that a human reviewer actually cares about. The block uses asterisk emphasis, not underscore, because the project's markdownlint (MD049) is configured to `asterisk` and the block lands in every stamped artifact.
- Manifest update. `docs/manifest.json` gets the artifact's title, type, category, and path re-indexed, so the doc index stays current without a manual step.

The result is emitted as `systemMessage` so the model knows "provenance stamped + manifest updated" and doesn't redundantly re-do it.

### `Stop`: close the loop, write the memory

When the agent finishes (or fails), `handleStop` classifies the session from which files it touched (Compliance? Governance? Architecture?), runs `git log --since=<last session>` to count commits and changed files, and appends an entry to `.arckit/memory/sessions.md`:

```
### 2026-11-07 14:32 - compliance
- **Commits:** 3 | **Files changed:** 5
- **Artifacts touched:** 2
- **Summary:**
  - ARC-042-SECD-v1.0.md: secure-by-design assessment
  ...
```

It keeps the last 30 entries and writes `.last-session` so the next session knows where to start. That's what makes `SessionStart` on the next run useful: a hook writes a log that a later hook reads back into context. The feedback loop is what turns six independent commands into something with continuity.

---

## 3. Why this is a control plane and not a prompt pack

Hooks are the layer where a coding agent becomes a system instead of a chat.

- A prompt says "please don't write secrets." A `PreToolUse` hook can't be persuaded otherwise. The guarantee is in the harness, not in the model's good intentions.
- A prompt has to re-establish context every session. A `SessionStart` hook does it deterministically, and a `Stop` hook feeds the next one.
- A prompt can't keep a document graph consistent. A `PostToolUse` hook re-indexes the manifest and stamps provenance on every artifact, so the corpus stays queryable by construction.

The cost is real, and worth naming: you now own a script that runs on every tool call, and it has to be fast (10s timeout), idempotent, and tested in CI (`tests/codex/test_codex_extension.py` validates the generated hooks and skill conversion; `node tests/plugin/*.mjs` covers the individual hook utilities). And the trust-by-hash rule means every edit is a re-review. That's the tax for the guarantee. I pay it happily, because the alternative is an agent that occasionally does the wrong thing at exactly the moment you weren't looking.

If you're running Codex on something with a document or artifact model, steal the shape: one script, six events, each doing one narrow job, and a memory loop between `Stop` and `SessionStart`.

---

ArcKit is open-source: [github.com/terrygzhou/arc-kit](https://github.com/terrygzhou/arc-kit). The Codex extension lives in `extensions/arckit-codex/`; the hook script is ~1,300 lines and the most-reviewed file in the repo.
