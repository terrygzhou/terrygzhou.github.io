---
layout: post
title: Private AI Is Production-Ready
date: 2026-05-30
tags:
  - local-AI
  - open-source
  - AI-infrastructure
draft: false
summary: After billions of tokens through local silicon, private AI on open source stacks is ready for production — here's the infrastructure, the tooling, and the workflows that work.
---
Early 2026, I made a deliberate shift: build a private AI instead of renting intelligence from commercial LLM providers. The goal was simple — complete control over the stack, no per-token ceiling, no data leaving my infrastructure. After pushing billions of tokens through local silicon and iterating hard on the tooling, the results speak for themselves. Private AI with open source stacks is production-ready, and it's time we stop treating it as a side experiment.

## Billions of Tokens, Zero Regret

Yes, I ran through tens of billions of tokens locally. And honestly, that's the point. When you control the hardware, you can experiment aggressively without a bill chasing you down. I pushed prompts to their limits, tested models across quantisation levels, stress-tested RAG pipelines, AI agent loops, and broke things on purpose so I could understand failure modes.

Every misconfiguration, every broken pipeline, every model swap sharpened my engineering judgment. Those tokens didn't waste away — they built intuition. And that intuition is what lets me ship real systems, not proof-of-concepts.


## Five Projects, Two Approaches

Across five major projects — three greenfield builds, two legacy refactors — one pattern held up consistently: LLMs perform best when tightly constrained, not left freeform.

Greenfield work rewards explicit fallbacks, latency budgets, and reliable automated execution loops. Build that discipline upfront and repeatability follows. Legacy refactors need a different play — the leverage here isn't rewriting from scratch; it's surfacing hidden domain boundaries, drafting clear contracts, and accelerating human review.

Either way, observability is non-negotiable. Instrument everything from day one. That's the backbone of every system I build.


## Under the Hood: Local LLMs, Knowledge Base, and Tooling

### 1. Configuring and Running Local LLMs

Running models locally changed how I approach AI engineering. I standardised on a hybrid stack:

- **Ollama** for rapid iteration and prototyping — `ollama launch claude` was my go-to for quick Claude access without API calls.
- **llama.cpp** and **LMS Studio** for ARM/Mac MLX compatibility and low-latency inference. Great for parameter tuning, less ideal for concurrency.
- **vLLM** for throughput and continuous batching — the workhorse for agent workloads. Multi-modal scenarios tell a different story; I'll cover that separately.
- **SGLang** — fast on paper, but VRAM-hungry. Dropped it quickly; didn't fit my agent environment.
- **Qwen3.6-27B-NVFP4** is my current sweet spot. Expect a deep dive on fine-tuning variations in a future post.
- **Hugging Face** is where I stay current on model releases.

Quantisation is table stakes now. `Q4_K_M` hit the best balance across VRAM, speed, context, and perplexity for my machines. Early lesson: context window size matters far less than context hygiene. Garbage in, garbage out — that rule hasn't changed. Sliding windows, strategic truncation, and explicit prompt templates did more for quality than any 128K context chase.


### 2. Building a Personal Knowledge Base

My RAG pipeline went through three major rewrites. Here's what stabilised:
- **Chunk by semantic boundaries**, not fixed token counts.
- **Hybrid search**: BM25 for exact match, vectors for semantic retrieval, node4j for semantic relationships.
- **Embedding strategy**: fast, smaller models for retrieval; larger models reserved for synthesis.
- **Storage**: Chroma for local dev, Qdrant for scalable vectors, node4j for graph-based semantic networks.
- **Ingestion guardrails**: source channels, validation, metadata tagging, and periodic re-embedding to combat drift.
- **Personal KB**: started from Obsidian notes with Kapathy LLM wiki, later extended to a custom plugin backed by Qdrant and node4j.

The value of growing my personal KB is obvious — it gives my local agents an edge over frontier models on many tasks.

### 3. Evaluating AI Coding Tools

I tested nearly every major assistant on the market. Here's where I landed:
- **Cursor, OpenCode**: best for contextual ideation and multi-file editing.
- **Continue**: ideal as a local orchestrator chaining LLMs, tools, and git history.
- **Aider**: surgical precision for targeted refactors and test-driven iteration.
- **GitHub Copilot, Codex, Claude Code**: still unbeatable if cost is no concern.
- **Hermes agent ACP**: not the sharpest at raw code syntax — and that's fine. It learns independently, shares skills across coding and beyond. The compound returns are undeniable.
- **Observable, measurable and self-improvement**: spending time establishing the observability and evaluation framework gains faster delivery speed.

None of these tools work in isolation. The real advantage is a repeatable workflow powered by a self-learning knowledge base — AI proposes, I verify, AI executes, tests enforce, version control guards against drift, and the loop self-corrects. AI doesn't replace engineering discipline — it amplifies it.


## What Actually Matters

1. **Ship the pipeline before you optimise it.** Latency and throughput come after working systems.
2. **Evaluation beats generation.** If you can't measure it, you can't improve it. I built lightweight eval suites before I polished prompts.
3. **Local AI isn't just about privacy.** It's about iteration speed, data control, and debugging transparency — things commercial APIs can never give you.
4. **The best AI engineers aren't prompt wizards.** They're architects who isolate problems from systemic observation, execute divide-and-conquer against boundaries, and know when to automate and when to intervene.
5. **Every token spent is data, not debt.** Treat the exploration budget as investment in engineering intuition.


## Why This Matters for the Industry

This journey has made me a better collaborator with AI agents. And I'll be straight with you — none of this works without two decades in architecture and system design as foundation. The models swapped, the dockers crashed, the pipelines rebuilt — they all reinforce one thing: AI is a mirror of your process, your rigor, and your willingness to ship.

But more importantly, this isn't just my project. Every time another team stands up a private LLM, builds a knowledge pipeline, or ships an agent on open source — we strengthen the entire ecosystem. Private AI is the path forward. Your data stays yours. Your costs scale with compute, not tokens. And the open source community delivers faster than any vendor roadmap.


**Let's talk.** Are you running local, cloud, or hybrid? What's your stack? What broke your pipeline that shouldn't have? Drop your thoughts in the comments or reach out directly. Building in public, as always.