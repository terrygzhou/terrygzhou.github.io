---
layout: post
title: "Switching from vLLM to SGLang: Real-World Throughput on Qwen3.6-27B"
date: 2026-07-26
tags:
  - SGLang
  - vLLM
  - Qwen
  - NVFP4
summary: I moved from vLLM to SGLang for Qwen3.6-27B serving. Higher throughput, lower power, but MTP requires a separate drafting model. Here's what changed.
---

Six months with vLLM running Qwen3.6-27B on an RTX 5090. Stable at 150 tokens per second with MTP enabled. Then SGLang released CUDA toolkit support for the new hardware, and I gave it a shot. The results were different enough to warrant a full switch.

---

## The baseline: vLLM with MTP

vLLM had been the workhorse. Multi-token prediction (MTP) ran inline — the Qwen3.6 architecture shared embedding and lm_head weights between the target model and its built-in draft heads, so no extra VRAM overhead. 150 tokens per second, single request. KV cache capacity: 207,142 tokens (7.54 GiB). Configured max_num_seqs=4, but practical concurrency was limited to roughly 1.29x at 160K context before KV cache exhaustion.

The RTX 5090 has 32 GB VRAM. Squeezing a 27B model with context leaves little room for aggressive batching.

---

## SGLang on host first

Initial SGLang deployment ran host-native, not Docker. The cold start is real — FlashInfer autotune takes roughly 90 seconds, bringing total startup to about three minutes. But once warmed up, numbers jumped:

| Metric | vLLM | SGLang (host) |
|---|---|---|
| Per-request speed | 150 tok/s | 50 tok/s |
| Max concurrent requests | 1 (practical) | 4 |
| Aggregate throughput | 150 tok/s | 200 tok/s |
| GPU power draw | baseline | -20% |
| Benchmark output throughput | — | 147.83 tok/s (peak: 204 tok/s) |
| Mean TTFT | — | 10.3s |
| Mean TPOT | — | 23.5ms |

Per-request latency is slower — 50 tokens per second versus 150. But here is where SGLang actually shines:

**Stable token generation.** Where vLLM's per-request speed fluctuates under load, SGLang locks in at roughly 50 tokens per second per request. Consistent. No spikes, no drops. This stability comes from the RadixAttention cache strategy and the underlying FlashAttention implementation — SGLang manages KV cache blocks more efficiently, doing smarter prefix caching and cache reuse across requests. The result is predictable throughput rather than peak-and-trough patterns.

**Aggressive batch scheduling.** SGLang does not wait for one request to finish before moving to the next. It interleaves decoding across concurrent requests, keeping the GPU compute units saturated. That is why four concurrent requests push aggregate throughput to 200 tokens per second — the scheduler finds compute parallelism that vLLM's more conservative batch strategy leaves on the table. Benchmark shows 1.02 req/s with peak concurrency of 26 and effective concurrency of 14.07.

**Context management.** RadixAttention (SGLang's implementation of tree-based prefix caching) shares KV cache across requests with overlapping prompts. If two requests share the same system prompt or conversation history, SGLang reuses the cached blocks instead of recomputing. This is especially valuable in chat and agent workflows where requests share context prefixes. Combined with SGLang's chunked prefill strategy — which breaks long prompts into smaller batches to avoid OOM — the engine handles long-context workloads more gracefully than vLLM's contiguous allocation.

Power consumption dropped 20%, with noticeably less fan noise and lower thermal output. The RTX 5090 runs cooler under SGLang's batch scheduler. That power efficiency alone was a selling point. Less heat, less noise, more throughput.

---

## Moving to Docker

Host deployment worked, but Docker is the target. Clean environment, easy version tracking, monitoring hooks.

The migration was not trivial. Triton SM120 compatibility required the `tokenspeed-triton` fork. CUDA 13.x Docker images from NVIDIA are not yet published, so the host toolkit had to be mounted into the container. Stale model cache (22 GB) needed cleanup before the correct checkpoint could load cleanly.

NVIDIA publishes two separate NVFP4 variants: `nvidia/Qwen3.6-27B-NVFP4` for vLLM (multimodal, modelopt v0.45.0) and `mmangkad/Qwen3.6-27B-NVFP4` for SGLang (text-only, modelopt v0.42.0rc1). The SGLang variant is the one to use — confirmed by PR #27906 merged July 6 in v0.5.15.post1.

Final setup: SGLang container on port 8080 via Docker Compose, with Prometheus scraping and Grafana dashboards wired in.

SGLang is moving fast. New speculative decoding features (DFlash, Spec V2) are in testing. Docker makes it easy to pull the next version and verify stability before upgrading.

(source: [SGLang GitHub](https://github.com/sgl-project/sglang))

---

## The MTP trade-off

This is where SGLang differs from vLLM in a way that matters.

vLLM's MTP uses the model's built-in drafting heads — no extra VRAM. SGLang's MTP requires a separate drafting model loaded alongside the main model. That adds 3.5–4 GB VRAM overhead on top of an already tight 32 GB budget.

Four gigabytes of VRAM is not free — it's KV cache space. The SGLang checkpoint (`mmangkad/Qwen3.6-27B-NVFP4`) loaded at 17.26 GiB in VRAM versus 10.23 GiB for vLLM's `nvidia/Qwen3.6-27B-NVFP4`. The difference is the quantization format and runtime overhead between modelopt versions (v0.42 vs v0.45). Losing another 4 GB to MTP would starve context capacity. The math did not work out.

**Decision: MTP disabled.** More context capacity is worth more than speculative decoding speedup on this hardware.

---

## The checkpoint mismatch

There is no single Qwen3.6-27B-NVFP4 that works with both engines. You cannot simply swap serving stacks and reuse the same weights:

- `nvidia/Qwen3.6-27B-NVFP4` (vLLM, multimodal, modelopt v0.45.0, tested on GB300)
- `mmangkad/Qwen3.6-27B-NVFP4` (SGLang, text-only, modelopt v0.42.0rc1, tested on B300)

The quantization artifacts are engine-specific. The SGLang variant also uses an older modelopt release — as NVIDIA updates their tooling, expect newer SGLang-compatible checkpoints that may close the VRAM gap.

Another wrinkle: the mmangkad repo reports 20B parameters versus 18B for nvidia, suggesting different layer preservation strategies in the quantization pipeline.

---

## Trade-offs

| Factor | Winner | Why |
|---|---|---|
| Aggregate throughput | SGLang | 200 tok/s vs 150 tok/s |
| Power efficiency | SGLang | 20% reduction |
| Per-request latency | vLLM | 150 tok/s single request |
| MTP support | vLLM | Inline, zero extra VRAM |
| Context capacity | vLLM | 10.23 GiB weights leave more KV cache |
| Maturity | vLLM | Six months of stable production use |
| Docker story | SGLang | Clean containerized deployment |

---

## Verdict

SGLang wins on throughput, power efficiency, and batch handling. vLLM wins on per-request latency and inline MTP. For a single-GPU setup where context depth and concurrency matter more than raw token speed on one request, SGLang is the better fit.

The trade-offs are clear: no MTP, no language-only model variant, and a younger ecosystem. But the power savings and batch throughput are real, measurable improvements.

Self-hosted AI on consumer hardware gets better when the serving stack improves its efficiency profile. SGLang's scheduler is doing more with less VRAM and less power — that matters when you're the one paying the electricity bill and sitting next to the fan noise.

SGLang is worth the switch — if your workload benefits from concurrent requests and you value power efficiency. Let's talk about your stack.
