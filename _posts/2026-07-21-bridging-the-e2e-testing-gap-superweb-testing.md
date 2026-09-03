---
layout: post
title: "Bridging the E2E Testing Gap: Introducing SuperWeb Testing"
tags:
  - AI-Agents
  - E2E-Testing
  - Playwright
  - OpenHands
  - DevOps
date: 2026-07-21
---
End-to-end testing is supposed to be the last line of defence before users hit broken features. In practice, it is often the first thing teams cut when deadlines tighten.

The problem is worse now than it was two years ago. AI coding agents write features, merge PRs, and deploy at speeds no human QA team can match. The old model -- write code, hand it off to a tester, wait for a report -- simply cannot keep up with autonomous development loops.

I recently published [**SuperWeb Testing**](https://github.com/terrygzhou/superweb-testing), an open-source tool that closes the gap between source code, test data generation, browser automation, and server-side log correlation. This post explains why it exists, the gaps it fills, and how it works.

---

## The Challenge: AI-Generated Code Needs Automated Verification

When an AI agent writes a login form, a payment checkout flow, or a data export feature, who tests it?

In traditional workflows, the answer is a human QA engineer. In agent-driven workflows, that bottleneck disappears -- but so does quality assurance. Agents do not instinctively verify their own work against the full application stack. They write code, run unit tests, and merge. The integration gaps surface later, in production.

The core challenge is threefold:

1. **Test data generation is disconnected from source code.** Most E2E frameworks expect you to write static test data or use mock factories that drift from the actual schemas in your codebase.
2. **Browser automation is blind to server behaviour.** Playwright scripts fill forms and click buttons, but they do not correlate failures with backend logs, database errors, or API responses.
3. **Root cause attribution is manual.** When a test fails, the engineer must trace from the browser screenshot through the network tab, then into server logs, then back to the source file. Agents cannot do this reliably without structured instrumentation.

---

## The Gap in Existing Tools

Several tools exist, each solving part of the problem but not the whole chain.

### Playwright Automation

Playwright is excellent at browser automation -- navigation, form filling, assertions. But it operates at the presentation layer. A Playwright script knows that a form submission returned an error page. It does not know whether that error came from a missing database index, a malformed validation rule, or a third-party API timeout. Without log correlation, you are debugging blind.

### OpenHands (AI Coding Agents)

OpenHands is powerful for code generation and exploration. An agent can scan your repository, write Playwright tests, and run them. But the workflow is fragmented: the agent writes tests in isolation, without structured test data derived from source schemas. When tests fail, the agent has no mechanism to correlate browser errors with server logs. The result is often superficial test scripts that miss edge cases or produce false positives.

### Chrome DevTools and Browser-Based Testing

Browser developer tools give visibility into the client side -- network requests, console logs, DOM state. But they are reactive, not automated. You need a human watching the tab. They also cannot reach into server-side logs or database state.

### The Missing Link

The fundamental gap is the absence of a **pipeline that connects source code analysis, test data generation, browser execution, and server log correlation** into a single traceable workflow. Existing tools are either too narrow (one layer) or too broad (agent autonomy without structured output). Neither approach gives agents the context they need to diagnose failures accurately.

---

## What Is SuperWeb Testing?

SuperWeb Testing is a four-phase pipeline that bridges these gaps:

```
Phase 1: Source Analysis  →  Extract form schemas and API routes from source code
Phase 2: Data Generation  →  Generate realistic test data using LLM inference
Phase 3: Browser Testing  →  Execute Playwright automation with generated data
Phase 4: Log Correlation  →  Match test results against server logs and source files
```

Each phase produces structured JSON output that flows into the next. The pipeline is designed to be both **deterministic** (reproducible results) and **agent-aware** (structured enough for AI agents to reason about failures).

---

## Architecture: Script Mode vs Agent Mode

![SuperWeb Testing four-phase pipeline](/assets/2026-07-21-superweb-testing/pipeline.png)

SuperWeb Testing offers two execution modes to suit different workflows.

### Script Mode (Default)

```bash
superweb run --target http://localhost:8080 --source /path/to/source --mode scripted
```

Runs the four-phase pipeline deterministically:

1. **Analyze** -- Scans source code for forms, routes, and input schemas using AST-like pattern matching
2. **Generate** -- Creates N test data variations per form via LLM (any OpenAI-compatible endpoint)
3. **Test** -- Executes Playwright browser tests with generated data
4. **Correlate** -- Matches server logs to test timestamps and produces a structured report

Script mode is fast, reproducible, and CI/CD friendly. No container overhead. Ideal for automated pipelines and pre-commit hooks.

### Agent Mode (OpenHands-Powered)

![Script vs Agent execution modes](/assets/2026-07-21-superweb-testing/modes.png)

```bash
superweb run --target http://localhost:8080 --source /path/to/source --mode agent
```

Delegates to OpenHands Agent Server through a three-conversation workflow:

1. **Analyze** -- AI examines source code, generates schemas and test data
2. **Test** -- AI writes and executes Playwright tests against the target
3. **Report** -- AI compiles structured results with failure triage

Agent mode requires Docker (for the OpenHands container) and gives you the flexibility of autonomous test creation. It is designed for scenarios where the application is evolving too quickly for static test scripts to keep up.

### How to Choose

| Factor | Script Mode | Agent Mode |
| --- | --- | --- |
| Speed | Seconds to minutes | 5-30 minutes |
| Reproducibility | Deterministic | LLM-dependent |
| Coverage | Schema-driven | Agent-driven exploration |
| CI/CD | First choice | Prototype and exploratory |

---

## Light Instrumentation, Deep Visibility

SuperWeb Testing deliberately avoids heavy instrumentation. There is no test harness to install in your application, no modified code paths, no test-specific endpoints required.

The pipeline works with your application as-is:

- **Source analysis** reads files directly (Pydantic models, WTForms, SQLAlchemy, FastAPI routes)
- **Browser testing** interacts with the application through the same URLs real users use
- **Log correlation** connects to existing log sources (Docker containers, log files, systemd journal)

This means you can drop SuperWeb Testing into any existing project without modifying the codebase. The instrumentation cost is zero -- the only requirement is access to source code, a running application, and server logs.

---

## Example: Testing the globalEV Customer Application

Consider a real-world scenario: testing the **globalEV customer application** -- a web portal for electric vehicle service bookings and customer management.

```bash
superweb run \
  --target http://localhost:8080 \
  --source /path/to/customev-app \
  --mode scripted \
  --variations 3 \
  --llm-url http://localhost:8080 \
  --llm-model Qwen3.6-27B
```

The pipeline would:

1. **Analyze** -- Discover forms like `CustomerRegistrationForm`, `ServiceBookingForm`, and `PaymentDetails` from the source schemas. Extract API routes for `/api/bookings`, `/api/customers`, `/api/payments`.

2. **Generate** -- Create three realistic test data variations per form:
   - Standard case: valid Australian customer with a BYD vehicle
   - Edge case: international phone number with special characters
   - Negative case: expired credit card details

3. **Test** -- Navigate to each form page, fill fields with generated data, submit, and capture the response. Screenshot failures automatically.

4. **Correlate** -- Cross-reference test timestamps with server logs. If the payment form fails with a 500 error, the correlation report points directly to the source file (e.g., `src/payments/processor.py`) and the specific error pattern (e.g., `Stripe API timeout`).

The output is a structured JSON report that an AI agent can parse and act on -- no human interpretation needed.

---

## Why This Matters for AI-Driven Development

As AI agents take over more coding tasks, the testing gap widens. The traditional separation between development and QA is collapsing. SuperWeb Testing addresses this by making E2E testing a first-class part of the development loop -- not a gate at the end.

The tool is designed to integrate with agent-driven workflows:

- **Structured output** that AI agents can consume and reason about
- **Source-to-failure traceability** that eliminates guesswork
- **Zero instrumentation overhead** so it works with any application
- **Dual modes** for both deterministic CI and exploratory testing

The repository is open source on GitHub: [terrygzhou/superweb-testing](https://github.com/terrygzhou/superweb-testing). MIT licensed. Contributions welcome.

---

## Next Steps

SuperWeb Testing is evolving. The next areas of focus:

- **Parallel test execution** for faster pipelines
- **Custom form extractors** for React, Vue, and Angular frameworks
- **Integration with LangGraph workflows** for agent-driven test orchestration
- **Support for API-level testing** alongside browser automation

If you are building AI-driven development workflows, the testing gap is your constraint. SuperWeb Testing aims to remove it.