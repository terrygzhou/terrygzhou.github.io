---
layout: post
title: How I Built a Personal Knowledge Base That Actually Scales
date: 2026-07-31
tags:
  - personal-KB
  - Qdrant
  - Mem0
  - RAG
  - local-AI
  - open-source
  - llm-wiki
summary: From heavy knowledge tools to adaptive agent memory — three iterations of building a personal knowledge base that compounds over time without exploding context windows.
---

I went through three iterations building a personal knowledge base, all driven by one goal: to create an agent that mirrors my thinking and compounds over time. I wanted it to naturally capture everything I engage with — conversations I’ve had, texts I’ve read, music I’ve listened to, videos I’ve watched, and any experience I can articulate in language, lessons I learnt — so it could continuously refine its recommendations.  The end result is a localised system where my agents can query my accumulated knowledge on demand: semantic retrieval, graph-based relationships, and adaptive memory, all running locally without context overflow.

---

## Phase 1: Heavy Knowledge Tools

The starting point was obvious: local knowledge tools, because my data stays local. I cycled through several — [**AnythingLLM**]([Mintplex-Labs/anything-llm](https://github.com/Mintplex-Labs/anything-llm)), **OpenNotebook** ([lfnovo/open-notebook](https://github.com/lfnovo/open-notebook)), and [**llm_wiki**](https://github.com/nashsu/llm_wiki). Each was powerful in its domain but shared the same flaw: they demanded structure before they could deliver value.

| Tool         | Strength                                             | Friction in my workflow                                          |
| ------------ | ---------------------------------------------------- | ---------------------------------------------------------------- |
| AnythingLLM  | Document ingestion, multi-workspace, agent pipelines | Heavy setup per workspace, slow to query across projects         |
| OpenNotebook | Research-grade knowledge management                  | Over-engineered for ad-hoc questions, time-consuming to maintain |
| llm_wiki     | Graph relationships layered on semantic search       | Desktop-locked, then web-refactored; two separate graphs (Obsidian + wiki) with no merge path |

llm_wiki was the most ambitious: it connected concepts, not just documents. I even refactored it into a [web server](https://github.com/terrygzhou/llm_wiki) so I could reach it over VPN from any device. But syncing Obsidian notes into it meant duplicating my graph — the Kapathy wiki plugin graph in Obsidian lived separately from the llm_wiki graph. Two systems, two graphs, no way to merge them.

The common thread: these tools are built for defined projects with clear boundaries. My daily work is the opposite — quick code lookups, sudden research questions, half-remembered facts I need to verify. I need prompting value in seconds, not a five-minute workspace configuration.

---

## Phase 2: Single Source of Truth — Qdrant

The solution was simple: collapse everything into one vector store.

I consolidated all my notes, project documentation, and accumulated experience into a single Qdrant instance. One collection, one query interface, one source of truth.

The value is immediate:

- **"Search my personal-kb"** — works in any conversation, any agent, any project
- Coding sessions pull from the same knowledge base as financial analysis or architecture discussions
- No more sync drift between tools
- Hybrid search (BM25 + vectors) catches exact matches and semantic neighbours

But then context overflow started killing sessions. Working on a larger codebase, the retrieval was pulling so much relevant material that the context window would fill up mid-task. The knowledge base was working too well.

---

## Phase 3: Adaptive Memory with Mem0

The final piece is **Mem0** ([mem0ai/mem0](https://github.com/mem0ai/mem0)) — an adaptive memory layer that sits in front of my Qdrant store and decides what to inject, and when.

Mem0 gives me three things that flat retrieval cannot:

1. **Context-aware retrieval** — it loads only the semantically relevant items for the current agent's task, not everything that loosely matches. Context overflow becomes a non-issue.
2. **Adaptive learning** — it remembers patterns across sessions. Repeated corrections, preferences, and decisions get stored and retrieved automatically without manual prompting.
3. **Complementary layer** — it sits alongside the native agent memory stack (`SOUL.md`, `User.md`, `MEMORY.md`, `AGENTS.md`) and fills the gap. Those files are static. Mem0 is dynamic, scoped to the conversation.

I wired it to a separate collection on my Qdrant server. The Hermes agent can access it through plugins, and the memory compounds over time — every session teaches the system something new.

The compounding effect is real. My agents are getting measurably better at my domain without touching a frontier model API. A mid-tier local model with a strong adaptive knowledge base outperforms a naked frontier model every time.

---

## Architecture

The system has three stages — sourcing, processing, and consumption — with every conversation feeding back into the knowledge base.

<div class="mermaid">graph LR
    subgraph SOURCING["Sourcing Channels"]
        T["Telegram Chat\nConversations & updates"]
        VC["VS Code ACP\nCoding sessions, code reviews"]
        OB["Obsidian Notes\nPersonal wiki & research"]
        MI["Manual Injection\nmem0 inject CLI"]
        AR["Auto Research\nFinance / Science / Tech / News"]
    end

    subgraph PROCESSING["Processing Layer"]
        BATCH["Batch Collector\nDedup + chunk + metadata"]
        EMB["Embedding Pipeline\nall-minilm:33m, 384-dim"]
        QDRANT[("Qdrant\npersonal_kb / mem0_terry")]
    end

    subgraph CONSUMPTION["Consumption"]
        TG["Telegram Agent\nChat sessions"]
        VCA["VS Code ACP Agent\nCoding assistant"]
        WC["Web Console\nHermes TUI / browser"]
    end

    subgraph AGENTS["Agent Memory Stack"]
        SOUL["SOUL.md\nDomain expertise"]
        USER["USER.md\nUser profile"]
        MEM["MEMORY.md\nSession facts"]
        M0["Mem0\nAdaptive retrieval"]
    end

    T -->|"raw text"|BATCH
    VC -->|"code + context"|BATCH
    OB -->|"markdown notes"|BATCH
    MI -->|"structured input"|BATCH
    AR -->|"curated articles"|BATCH

    BATCH -->|"chunks"|EMB
    EMB -->|"vectors"|QDRANT

    QDRANT -->|"semantic search"|M0
    SOUL -.->|"loaded"|M0
    USER -.->|"loaded"|M0
    MEM -.->|"loaded"|M0

    SOUL -.->|"context"|TG
    SOUL -.->|"context"|VCA
    SOUL -.->|"context"|WC
    M0 -->|"scoped memory"|TG
    M0 -->|"scoped memory"|VCA
    M0 -->|"scoped memory"|WC

    TG -->|"new conversations"|BATCH
    VCA -->|"code decisions"|BATCH
    WC -->|"session output"|BATCH

    style QDRANT fill:#e8f5e9,stroke:#4caf50
    style M0 fill:#e3f2fd,stroke:#2196f3
    style BATCH fill:#fff3e0,stroke:#ff9800
    style EMB fill:#fff3e0,stroke:#ff9800
</div>

### Sourcing

Five channels feed the system:

| Channel | Content Type | Injection Path |
|---|---|---|
| **Telegram Chat** | Conversations, decisions, quick notes | Auto-captured session transcripts |
| **VS Code (ACP)** | Code reviews, refactoring decisions, debugging | Agent conversation history |
| **Obsidian Notes** | Research, architecture docs, personal wiki | Sync script → markdown chunks |
| **Manual Injection** | Ad-hoc facts, corrections, preferences | `mem0 inject` CLI |
| **Auto Research** | Finance signals, tech news, science briefs | Cron jobs → curated markdown |

### Processing

The batch collector deduplicates, chunks, and attaches metadata (source, timestamp, category). The embedding pipeline runs `all-minilm:33m` on CPU via Ollama — 384-dimensional vectors that preserve GPU VRAM for the primary model. Qdrant stores everything in separate collections:

- `personal_kb` — the general knowledge base (~131K points)
- `mem0_terry` — Mem0's adaptive collection with session-scoped metadata

### Consumption

Any agent session — Telegram, VS Code ACP, or the web console — starts fresh. The agent loads its native memory stack (`SOUL.md`, `USER.md`, `MEMORY.md`) and queries Mem0 for semantically relevant items. Mem0 scopes the retrieval to the current context, so only what matters gets injected. Context overflow is managed, not avoided.

### The Feedback Loop

Every conversation is a sourcing event. Agent outputs, user corrections, and new decisions flow back through the batch collector into Qdrant. The knowledge base grows from real usage, not manual curation. That's the compounding mechanism.

---

## The Stack, Today

| Layer | Tool | Role |
|---|---|---|
| Inference | SGLang (Qwen3.6-27B) | Local LLM, :8080 |
| Vector store | Qdrant | Personal KB + Mem0 collections |
| Graph | node4j | Semantic relationships in wiki |
| Adaptive memory | Mem0 | Context-aware retrieval, session learning |
| Agent harness | Hermes (ACP) | Orchestrator, tooling, memory injection |
| Notes | Obsidian | Source of truth for raw notes |

---

## Trade-offs

- **Mem0 adds complexity** — another service to run, another collection to manage. The adaptive retrieval is worth the operational overhead.
- **Ollama for embeddings** — I use `all-minilm:33m` on CPU for embedding to preserve GPU VRAM for the primary model. Fast enough for retrieval, but not ideal for nuanced similarity.
- **Obsidian graph is orphaned** — the Kapathy wiki plugin graph in Obsidian is still useful for visual browsing, but the authoritative relationships live in Qdrant now. Acceptable trade-off.
- **No cloud dependency** — everything runs locally. If my server goes down, the knowledge goes dark. I accept that risk for full data ownership.

---

## Why This Matters

The pattern is generalisable. Every team building AI agents faces the same wall: static context injection doesn't scale. The bigger the codebase, the heavier the knowledge requirement, the faster the context window burns through.

Mem0 — paired with Qdrant, running on a local model — is one concrete answer. Adaptive memory that learns from usage, scoped to context, without the token tax of frontier APIs.

Your data stays yours. Your costs scale with compute, not tokens. And the quality gap keeps closing every time an open-source model ships.

