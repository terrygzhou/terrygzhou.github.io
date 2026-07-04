---
layout: post
title: Hello World — New Blog Live
date: 2026-06-30
tags:
  - hugo
  - github-pages
draft: false
summary: First post on my new Hugo blog hosted on GitHub Pages.
---

Early this year, I chose to invest in building a local AI lab rather than consuming commercial APIs. The goal was simple: gain complete control and remove the cost boundaries to aggressive experimentation and production. After driving tens of billions of tokens through local silicon across countless iterations, the results are clear. The true ROI didn't come from perfect runs, but from the 95% 'waste' factor—the failures that forced deep technical understanding. I’m ready to share what actually worked, what didn’t, and why that famous 95% “waste” stat ended up being the most valuable part of the journey.

## The “Wasted” Billions of Tokens Were Never Really Wasted

Yes, I burned through tens of billions of tokens. And if you look at the raw logs, roughly 95% of them went into tuning, failed experiments, and hard-earned corrections.

I over-engineered prompts. I fine-tuned on noisy, misaligned datasets. I chased benchmark scores that meant nothing in practice. I mismanaged context windows, misconfigured RAG retrieval thresholds, and let hallucinated code slip into production branches before catching it.

  
But that “waste” wasn’t waste. It was tuition. In AI engineering, you don’t learn from success. You learn from the gap between expectation and output. Every broken pipeline, every misrouted query, every failed auto-refactor taught me more about system design than any documentation ever could. The tokens didn’t disappear—they became intuition.

## Five Projects, Hundreds of features, Two Tracks

Across five projects—3 greenfield builds and 2 legacy refactors—one consistent pattern emerged: LLMs work best when tightly constrained, not left to freeform execution.

Greenfield work taught me the value of explicit fallbacks and latency budgets. For these new projects, building a reliable, automated execution loop is the gold standard for repeatability. Legacy refactoring, however, requires a different strategy. There, AI’s true leverage isn’t writing code from scratch; it’s surfacing hidden domain boundaries, drafting clear contracts, and accelerating human review.

No matter which path you take, building out observability infrastructure is a non-negotiable step upfront. In this space, treating your skills as long-term  assets is the real investment.


## Under the Hood: Local LLMs, Knowledge Base, and Tooling

### Configuring & Running Local LLMs

Running models locally changed how I think about AI and trade-offs. I standardised around a hybrid stack:

- **Ollama** for rapid iteration and quick prototyping:  `ollama launch claude` was my favorite for using Claude for free.
- **llama.cpp** for ARM/Mac MLX compatibility and low-latency inference.
- **vLLM** when I needed throughput and continuous batching, concurrency, best for agents working
- SGLang - tried, faster, but expensive in consuming my precious VRAM room,  and quickly abandon it as not fit for my agent environments.
- **Qwen3.6-27B-NVFP4** is the best fit in my case, yet there are still many variations to fine-tune (I will cover in my future posts)
- **Hugging Face** is the community I visit most often to stay on top of new models. 

Quantisation became daily reality. `Q4_K_M` struck the best balance between VRAM, speed, context and perplexity for my hardware. I learned early that context window size matters less than **context hygiene**. Garbage in, garbage out is the only law that hasn’t changed. Sliding windows, strategic truncation, and explicit prompt templates made more difference than chasing 128K contexts. Of course, I can share different stories when talking about multi modal scenarios ( I will tell my ai voice and video creation in another post).

### Building a Personal Knowledge Base

My RAG pipeline went through three major rewrites before stabilising and performance. What finally worked:

- **Chunk by semantic boundaries**, not fixed token counts
- **Hybrid search**: BM25 for exact match + vectors for semantic retrieval, node4j for semantic relationship.
- **Embedding strategy**: Fast, smaller models for retrieval; larger models reserved for synthesis
- **Storage**: Chroma for local dev, Qdrant for scalable vectors, node4j for graph-based semantic network.
- **Ingestion guardrails**: Source channels, validation, metadata tagging, and periodic re-embedding to combat drift. 
- **Personal KB** starting from Obsidian note with `Kapathy LLM wiki` and later extended to custom plugin working on backend Qdrant and node4J.

### Evaluating AI Coding Tools

I tested nearly every major assistant on the market. Here’s where I landed:

- **Cursor, OpenCode**: Best for contextual ideation and multi-file editing
- **Continue**: Ideal as a local orchestrator that chains LLMs, tools, and git history
- **Aider**: Surgical precision for targeted refactors and test-driven iteration
- **GitHub Copilot, Codex, Claude code**: Still unbeatable if less care costs.
- **Hermes agent ACP**: not best tool to understand the code syntax, so what?  It's my favourite because it learns by itself, share skills across coding and beyond - I saw the compound returns after 6 month's usage. (I will address this in another post)

None of them work in a vacuum. The real advantage came from building a **repeatable workflow**: AI proposes → I verify → tests enforce → version control guards against drift. AI doesn’t replace engineering discipline; it accelerates and amplifies it.

## Lessons That Actually Stuck

1. **Optimisation is a trap early on.** Ship a working pipeline before you chase latency or throughput.
2. **Evaluation > Generation.** If you can’t measure it, you can’t improve it. I built lightweight eval suites long before I polished prompts.
3. **Local AI isn’t just about privacy.** It’s about iteration speed, data control, and debugging transparency.
4. **The best AI engineers aren’t prompt wizards.** They’re **architects** who know how to isolate problems from systemic observation, execute divide-and-conquer against boundaries, and balance automation and intervention.
5. **95% “waste” is just the tuition fee for intuition.** Treat failed tokens as data, not debt.

## Looking Forward

Investing my time on this journey has made me a better engineer, architect and team-mate of agents.  And I have to be honest: without my over 20 years in architecture and system design, I cannot do this alone. The tokens spent, the models swapped, the dockers crashed, the pipelines rebuilt—they all point to one truth: AI isn’t a silver bullet. It’s a mirror of yourself with more powerful hands. It reflects your process, your rigor, and your willingness to iterate.


**I’d love to hear your take.** Are you running local, cloud, or hybrid? What tools have you standardised on, and what broke your pipeline unexpectedly? what your anticipation on next generation software and enterprise architecture? Drop your thoughts in the comments or reach out directly. 

From now on, I'll publish here regularly.