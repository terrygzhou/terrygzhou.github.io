---
layout: post
title: "The Impossible Triangle: Speed, Context and Knowledge"
date: 2026-06-03
tags:
  - llm
  - local-AI
  - ai-infra
---
As AI shifts from rule-based logic to pattern-driven LLMs, knowledge is no longer stored as explicit rules—it’s compressed into statistical intuition across billions of parameters. But scale hits a physical wall. In my experience tuning local models, I’ve identified **the Impossible Triangle of LLM Tuning**: Context, Speed, and Knowledge. You can optimize two corners, but the third always suffers.

## The Impossible Triangle: Speed, Context, Knowledge
 
 - **Speed (tokens/sec):** Bound by compute throughput and VRAM bandwidth. Pushing latency limits forces you to shrink the model, aggressively quantize, or truncate context.

- **Context Window:** Lives in the KV cache during inference. Doubling context doesn’t just double memory—it scales superlinearly, choking bandwidth, spiking latency, or triggering OOM errors.

- **Knowledge Depth:** Baked into static weights post-training. More parameters mean sharper reasoning and broader coverage, but they consume VRAM, directly squeezing out context and slowing inference.


## Mirror to Human Intelligence

Humans don’t run on silicon, but our cognitive architecture mirrors the same trade-offs—just with biological workarounds:

| LLM Constraint | Human Equivalent                        | How Humans Bypass the Limit                                                                 |
| -------------- | --------------------------------------- | ------------------------------------------------------------------------------------------- |
| Speed          | Cognitive processing & reaction time    | We don’t optimize for raw throughput. We filter, prioritize, and deliberate.                |
| Context        | Working memory (~4–7 meaningful chunks) | We compress, select or offload to notes, or forget strategically.                           |
| Knowledge      | Crystallized intelligence & experience  | We learn continuously, embed knowledge in habits, experience it, and update without resets. |
Humans face the same trade-offs, but we bypass them biologically. We don’t brute-force speed; we filter and prioritize. We don’t expand working memory; we compress, offload, or forget strategically. And we update knowledge continuously through experience, not resets. Humans don’t fight the triangle with more VRAM—we use sleep, tools, collaboration, and neuroplasticity. Real intelligence isn’t a fixed benchmark score; it’s a flexible toolkit.

## Which Corner I attempt to optimise? 

There’s no “best” configuration. Only context-appropriate ones. Here’s how to choose in my cases:

- ⚡ **Optimize for Speed**  
    _When:_ Real-time agents, edge devices, rapid prototyping, or live coding assistants.  
    _Trade-off:_ Truncated context, narrower coverage, heavier quantization.  
    _My setup:_ `Qwen3.6-27B-NVFP4_Q4` on vLLM, 32K context, 1 concurrent user, fully in VRAM with zero CPU↔GPU cache swapping.
    
- 📖 **Optimise for Context**  
    _When:_ Long documents, legal/medical records, multi-turn analysis, or large codebases.  
    _Trade-off:_ Slower generation, higher memory costs, potential coherence drift.  
    _My setup:_ `Qwen3.6-MoE-3B` on vLLM, 250K context, 2–4 concurrent users, accepting minor VRAM/RAM sharing to compromise latency.
    
- 🧩 **Optimise for Knowledge**  
    _When:_ Vertical domains (finance, healthcare, engineering), complex reasoning, or agent foundations.  
    _Trade-off:_ Higher inference costs, slower cold starts, less real-time agility.  
    _My setup:_ `Qwen3.6-27B-Q5` via llama.cpp (for higher precision beyond the current vLLM supports), but squeezing the kv-cache context length for prioritising depth for investment analysis.
    
## Lessons learnt

1. **Brute-force scaling yields diminishing returns.** Architecture, data quality, and system design quickly outpace raw parameter growth.
2. **Constraints breed innovation.** KV cache limits spawned paged attention; bandwidth caps inspired speculative decoding. Every bottleneck has catalyzed clever workarounds.
3. **Adaptability > Benchmarks.** IQ and static tests measure narrow capability. Real-world AI must navigate ambiguity, update without resets, and align with human intent.
4. **The triangle won’t disappear, but we can navigate it smarter.** Future progress lies in better memory management, neuromorphic efficiency, and systems that know when to think deeply, respond fast, or simply ask a human.


## Final Thought: Strategy first, model second

As we push LLMs further, the goal shouldn’t be to “solve” the triangle by brute-forcing all three corners. The goal is to build systems that **balance** them the way humans do: with purpose, with tools, skills, and strategy to manage "memories", and with enough self-awareness to know when to slow down, remember, or just ask for help.