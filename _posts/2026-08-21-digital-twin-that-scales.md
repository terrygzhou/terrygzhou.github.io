---
layout: post
title: How I Built a Digital Twin of Myself That Actually Scales
date: 2026-08-21
tags:
  - digital-twin
  - Qdrant
  - Mem0
  - RAG
  - local-AI
  - open-source
  - llm-wiki
  - neo4j
  - graphrag
summary: Four iterations of building a digital twin of myself — an AI mirror of who I am, what I know, and how I think — that compounds over time without exploding context windows or leaking data to the cloud.
---

Four iterations to build a digital twin — an AI mirror of who I am, what I know, how I think. It captures everything I engage with: conversations, texts, music, videos, lessons. The end result: a localised system where my agents can query who I am on demand. Semantic search, graph relationships, adaptive memory. All on my hardware, nothing sent to the cloud. The only difference is that I make decisions, not my digital twin.

## Phase 1: Static Snapshot

First version was a snapshot — a frozen capture of my knowledge. I cycled through **[AnythingLLM](https://github.com/Mintplex-Labs/anything-llm)**, **[OpenNotebook](https://github.com/lfnovo/open-notebook)**, and **[llm_wiki](https://github.com/nashsu/llm_wiki)**. All powerful, all with the same flaw: they demanded structure before delivering value.

- **[AnythingLLM](https://github.com/Mintplex-Labs/anything-llm)** — solid document ingestion, multiple workspaces, but cross-project queries were painfully slow
- **[OpenNotebook](https://github.com/lfnovo/open-notebook)** — NotebookLM reimplementation. Source-grounded chat, audio overviews, web research. The wrong shape for my use case: I wanted to ask a question and get an answer, not build a research session.
- **[llm_wiki](https://github.com/nashsu/llm_wiki)** — the most ambitious. Connected concepts, not just documents. I refactored it into a web server so I could reach it from any device. But syncing Obsidian notes meant duplicating my knowledge graph. Two systems, two graphs, no merge path

Common thread: these tools are built for defined projects with clear boundaries. My daily work is the opposite — quick code lookups, sudden research questions, half-remembered facts I need to verify. I needed answers in seconds, not a five-minute workspace config.

## Phase 2: Memory — Single Source of Truth

The fix: collapse everything into one place.

I consolidated all my notes, photos, docs, emails, and experience into a single vector database: **[Qdrant](https://github.com/qdrant/qdrant)**. One collection, one query interface, one source of truth.

What changed:

- "Search my knowledge base" works in any conversation, any task, any project
- Coding sessions pull from the same memory as financial analysis or architecture discussions
- No more sync drift between tools
- Hybrid search catches exact keywords and semantic neighbours simultaneously

The twin grew from ten sources: personal documents, emails, Apple Notes, Obsidian wiki pages, AI conversation history, PDFs and presentations, URLs, and more. Each piece gets chunked, embedded, and stored with metadata.

Then the twin started remembering too much. On larger projects, retrieval pulled so much relevant material that the context window filled up mid-task. Good at finding things — just couldn't be selective about what to share.

## Phase 3: Learning — Adaptive Memory with Mem0

A good memory doesn't remember everything — it remembers what matters. I added **[Mem0](https://github.com/mem0ai/mem0)**, an adaptive memory layer that sits in front of my vector store and decides what to surface, and when.

Three things flat search can't do:

1. **Context-aware retrieval** — loads only what matters for the current task, not everything that loosely matches. Context overflow becomes a non-issue
2. **Adaptive learning** — remembers patterns across sessions. Repeated corrections, preferences, decisions get stored and retrieved automatically
3. **Complementary layer** — sits alongside the agent's built-in memory files and fills the gap. Those files are static. Mem0 is dynamic, scoped to the conversation

I wired it to a separate collection on Qdrant. The compounding effect is real: my agents get measurably better at my domain without touching a cloud API. A mid-tier local model with a strong adaptive knowledge base outperforms a naked frontier model every time.

But Mem0 still thinks in isolated chunks. If I have a doc about an AI project, another about the team that built it, and a third about the client who funded it, the twin can find each one individually but can't tell me how they relate. It knows the pieces but not the story.

## Phase 4: Understanding — GraphRAG

GraphRAG layers a knowledge graph on top of your existing search. After you've indexed your docs, an AI model reads through them, pulls out people, organisations, topics, events, and places, and maps how they relate. You get vector search for "what's similar?" and graph traversal for "what's connected?" and "how has my thinking evolved?"

Two paths: Microsoft's [GraphRAG](https://github.com/microsoft/graphrag) or a custom build. Microsoft's is powerful but heavy and compute-intensive. Custom requires more upfront work but delivers exactly what you need without unused baggage.

I went custom:

- **Existing stack** — the twin already had a body (Qdrant) and a brain (AI model). Adding [Neo4j](https://github.com/neo4j/neo4j) gave it a nervous system — the connections between everything — without a new framework layer
- **Simplicity over ceremony** — I don't need enterprise-scale community reports. I just need to trace concepts, collaborators, and the evolution of my thinking
- **Extraction control** — running extraction locally lets me tune entity and relationship types to what matters to me, not framework defaults
- **Zero compute tax** — GPU is dedicated to the main brain. Extraction runs in batches during ingestion, keeping query-time lookups fast

The result: vector search for recall, graph traversal for context. 344,000 pieces of searchable content in Qdrant. 18,500 entities in the graph. Nearly 75,000 relationships. All on a single home server.

When I ask "How did I become an enterprise architect?" the twin searches for semantically relevant content, explores the graph for career milestones, certifications, organisations, and people, then weaves both into a single answer. The resume provides the skeleton, the graph provides the connections, memory fills in the details.

## The twin grows while I sleep

Three stages: sourcing, processing, consumption. Every conversation feeds back in.

**Sourcing.**  Channels: Telegram, social media, research papers, github, VS Code sessions, Obsidian notes, manual injections, automated research cron jobs, emails, Apple Notes, personal PDFs, working files, web content. Each source has its own ingestion script.

**Processing.** New content gets deduplicated, chunked, and embedded. Embeddings run on CPU to preserve GPU memory for the brain. Then the AI model extracts entities and relationships for the graph — my custom GraphRAG, not a pre-built framework. Everything lands in Qdrant for semantic search, Neo4j for structural connections.

**Consumption.** Any agent session — Telegram, VS Code, web console — starts fresh. Loads the twin's memory, queries both the vector store and the graph. Synthesises into a single answer. Context overflow is managed, not avoided.

**The heartbeat.** Every conversation is a sourcing event. Agent outputs, my corrections, new decisions flow back in. The twin grows from real usage, not manual curation. That's the compounding mechanism.

The twin maintains itself through scheduled jobs:

- **Daily session ingest** — new conversations captured and stored overnight
- **Memory consolidation** — duplicates and redundant entries cleaned up weekly
- **Disk space management** — old data pruned when it stops serving a purpose
- **Graph backfill** — new content triggers entity extraction that enriches the graph

These run autonomously. The twin grows while I sleep.

## Trade-offs

- **Mem0 adds complexity** — another service, another collection. The adaptive retrieval is worth the overhead
- **CPU embeddings** — run on CPU to preserve GPU for the brain. Fast enough for retrieval, not ideal for nuanced similarity
- **Obsidian's native graph is orphaned** — still useful for browsing, but the authoritative relationships live in Neo4j now
- **The twin lives where I live** — everything local. If my server goes down, the twin goes quiet. I accept that risk for full data ownership

## Why This Matters

The digital twin pattern generalises. Every team building AI agents hits the same wall: static context injection doesn't scale. Bigger codebase, heavier knowledge requirement, faster context window burn-through.

The four-phase evolution — snapshot, memory, learning, understanding — is one concrete answer. Each phase solved a real bottleneck from the previous one. All running on a local model. No cloud API token tax.

Your data stays yours. Your costs scale with compute, not tokens. The twin gets smarter without ever phoning home.
