---
layout: post
title: Testing vs Evaluation — Two Paradigms for AI Agents
tags:
  - ai-agents
  - testing
  - evaluation
  - open-source
  - deepeval
  - playwright
date: 2026-08-06
---

## Overview

When I started building AI agents, I treated them like any other software. I wrote Playwright tests for the UI, pytest assertions for the API, and CI gates for regressions. Standard engineering discipline.

Then I realized I was testing the plumbing but not the brain.

My agent could pass every test — correct HTTP status codes, valid JSON responses, no 500 errors — and still hallucinate, contradict itself, or pick the wrong tool. The tests were green. The output was wrong.

**Deterministic testing and probabilistic evaluation are two fundamentally different paradigms.** They don't compete. They complement each other. And until you understand the boundary between them, you'll keep writing tests that give you false confidence.

---

## 1. Two Paradigms

### Testing — Deterministic Verification

Testing asks: **Does the system work as specified?**

Same input → same output → binary verdict (pass/fail). Testing validates structure, contracts, and behavior. It's the foundation of software engineering, unchanged for 70 years.

```typescript
// Playwright — does the search button exist and work?
await expect(page.locator('#search-btn')).toBeVisible();
await page.locator('#search-btn').click();
await expect(page.locator('#results')).toBeVisible();
// Pass = UI renders, click works, results appear
```

```python
# pytest — does the API return valid JSON?
response = client.get("/api/vehicles")
assert response.status_code == 200
assert isinstance(response.json(), list)
# Pass = correct status, correct shape
```

Testing tools: **Playwright** (browser E2E), **pytest** (unit/integration), **axe-core** (accessibility), **Vitest** (frontend unit), **JUnit** (Java backend).

### Evaluation — Probabilistic Assessment

Evaluation asks: **Is the output any good?**

Same input → different outputs → score distributions. Evaluation measures semantic quality, reasoning accuracy, and alignment. The evaluator itself is often an LLM.

```python
# DeepEval — is the agent's answer faithful to the source?
from deepeval.metrics import HallucinationMetric, FaithfulnessMetric

metrics = [HallucinationMetric(), FaithfulnessMetric()]
evaluate([
    EvaluationInstance(
        input="How much does a BYD Aura cost?",
        actual_output="The BYD Aura Essential starts at $45,990",
        retrieval_context=["BYD Aura Essential 75kWh: $45,990"],
        metrics=metrics
    )
])
# Score: Hallucination = 0.95, Faithfulness = 0.88
```

Evaluation tools: **DeepEval** (general LLM eval), **Ragas** (RAG quality), **TruLens** (RAG with tracing), **Arize Phoenix** (observability + eval), **Promptfoo** (declarative eval).

---

## 2. The Decision Matrix

| Question | Testing Tool | Evaluation Tool |
|---|---|---|
| **Determinism** | Yes — same input, same output | No — measure distributions, not exact matches |
| **Verdict** | Binary (pass / fail) | Score (0.0–1.0, with confidence) |
| **Evaluator** | Code assertions (`expect()`, `assertEqual`) | LLM-as-a-judge or embedding similarity |
| **Scope** | Structure, contracts, behavior | Semantics, reasoning, alignment |
| **Reproducibility** | 100% — flaky tests are bugs | Statistical — run 100 samples, look at aggregates |
| **CI Gate** | Yes — fail the build on any test failure | Yes — but threshold-based (e.g., score ≥ 0.80) |
| **Failure means** | Bug: something is broken | Degradation: quality dropped, but system "works" |

---

## 3. Focus Areas

### What Testing Catches
- **UI rendering** — pages load, components render, navigation works
- **API contracts** — correct HTTP status codes, response schemas, error handling
- **Accessibility** — WCAG compliance, screen reader support, keyboard navigation
- **Security** — authentication flows, input validation, injection resistance
- **Performance** — load times, API latency, memory usage
- **Integration** — service-to-service communication, database queries, file I/O

### What Evaluation Catches
- **Hallucination** — agent fabricates facts not in the source material
- **Faithfulness** — answer contradicts retrieved context
- **Relevance** — response doesn't address the actual question
- **Tool selection** — agent picks wrong tool for the task
- **Reasoning quality** — multi-step reasoning contains logical gaps
- **Safety** — output contains harmful content despite "working"
- **Consistency** — agent gives different answers to the same question

### The Blind Spots

**Testing without evaluation:** Your app works perfectly and gives completely wrong answers. Green lights everywhere, users get garbage.

**Evaluation without testing:** Your agent gives brilliant answers when it responds, but crashes on 40% of requests, times out under load, and breaks when the database is slow.

You need both. Testing validates the foundation. Evaluation validates the intelligence.

---

## 4. Open Source Tool Landscape

### Testing Tools (Deterministic)

| Tool | Focus | Language | Stars |
|---|---|---|---|
| **Playwright** | Browser E2E | TS/Python/Java | 90k+ ⭐ |
| **pytest** | Unit/integration | Python | 24k+ ⭐ |
| **axe-core** | Accessibility | JS | 7k+ ⭐ |
| **Vitest** | Frontend unit | TS/JS | 28k+ ⭐ |
| **Selenium** | Browser automation | Multi-language | 70k+ ⭐ |

### Evaluation Tools (Probabilistic)

| Tool | Focus | Metrics | Stars |
|---|---|---|---|
| **DeepEval** | General LLM/agent eval | 50+ plug-and-play | 4k+ ⭐ |
| **Ragas** | RAG quality | Faithfulness, context relevance, answer relevancy | 20k+ ⭐ |
| **TruLens** | RAG eval + tracing | Faithfulness, context precision/recall | 15k+ ⭐ |
| **Promptfoo** | Declarative eval, CI | Custom scorers, LLM-as-judge | 20k+ ⭐ |
| **Arize Phoenix** | Observability + eval | Traces, distributions, evaluation | 14k+ ⭐ |
| **Giskard** | ML model testing | Bias, robustness, accuracy | 6k+ ⭐ |
| **LangSmith** (SaaS) | Full lifecycle | Tracing, eval, deployment | Proprietary |
| **AWS Agent-Eval** | Conversation eval | Multi-turn scoring, hooks | 370 ⭐ |

### Specialized Benchmarks

| Benchmark | Scope | Stars |
|---|---|---|
| **SWE-Bench** | Software engineering | 16k+ ⭐ |
| **GAIA** | General agent intelligence | 5k+ ⭐ |
| **WildClawBench** | In-the-wild agent tasks | Growing |
| **Exgentic** | General agent eval framework | 2k+ ⭐ |
| **BenchFlow** | Agent evaluation infrastructure | New |

---

## 5. How They Work Together

### The Layered Approach

```
Layer 1: Unit Tests (pytest)
├─ API endpoint contracts
├─ Database query correctness
└─ Business logic validation

Layer 2: Integration Tests (Playwright)
├─ Full request/response cycles
├─ UI rendering and navigation
└─ Cross-service communication

Layer 3: Accessibility (axe-core)
├─ WCAG compliance
├─ Screen reader support
└─ Keyboard navigation

Layer 4: Agent Evaluation (DeepEval/Ragas)
├─ Answer faithfulness to sources
├─ Hallucination detection
├─ Tool selection accuracy
└─ Reasoning quality
```

### Practical Pipeline

```yaml
# .github/workflows/eval.yml
name: Agent CI
on: [push]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - run: pytest tests/          # Layer 1: deterministic tests
      - run: npx playwright test    # Layer 2: integration tests
      - run: playwright test --axe  # Layer 3: accessibility
      - run: deepeval test run      # Layer 4: agent evaluation
```

Each layer catches what the layer below can't. Skip any layer and you leave a gap.

---

## 6. Real Experience — llm_wiki

In building my LLM Wiki project, I saw this divide firsthand:

- **Playwright tests** verify the React UI renders search results, the knowledge graph loads, and page navigation works
- **DeepEval-style evaluation** would verify that synthesized wiki pages are faithful to source material, contain no contradictions, and answer questions accurately

The current gap: Playwright can confirm the page exists and renders. It can't confirm the content is correct. That's the evaluation layer — where the agent's reasoning lives.

For my wiki's lint pipeline, I'm considering adopting a structured evaluation harness (modeled on AWS Agent-Eval's hook pattern) that checks:
- Contradiction detection between wiki pages
- Orphan page detection (no inbound wikilinks)
- Coverage gaps (sources not referenced by any page)

---

## 7. Choosing Your Stack

### Decision Framework

**Pick based on your maturity:**

1. **Starting out:** pytest + Playwright (get deterministic coverage first)
2. **Adding eval:** DeepEval (easiest drop-in, pytest-native)
3. **RAG focus:** Ragas (specialized RAG metrics, mature ecosystem)
4. **Observability:** Arize Phoenix (tracing + eval in one platform)
5. **CI gating:** Promptfoo (declarative YAML config, CI-friendly)

**Avoid:** Trying to evaluate agent output with testing tools. You'll get brittle string-matching tests that break on every minor rephrase. Evaluation tools exist for a reason.

---

## Summary

Testing validates the foundation. Evaluation validates the intelligence. They're different paradigms with different tools, different failure modes, and different CI gates. Use testing tools for deterministic verification (does it work?). Use evaluation tools for probabilistic assessment (is it good?). Combine them for systems that both function correctly and think correctly.

The best agents don't just pass tests. They consistently score well on faithfulness, relevance, and reasoning quality — across hundreds of samples, not just one.

---

*This post reflects lessons from building the LLM Wiki project and agent loop engineering factory. All tool references are current as of July 2026.*