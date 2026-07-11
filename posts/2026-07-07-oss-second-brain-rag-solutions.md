---
created: 2026-07-07
topic: oss-research
tags: [oss, RAG, second-brain, personal-kb, github-research]
---

# OSS Personal Second Brain & RAG Solutions

> Research snapshot: 2026-07-07. Star counts from GitHub API.

## Tier 1: Full-Stack Second Brain / RAG Platforms

| Project | ⭐ | Lang | Self-Host | Vector DB | Description |
|---|---|---|---|---|---|
| [khoj-ai/khoj](https://github.com/khoj-ai/khoj) | 35.5K | Python | ✅ | Built-in | Your AI second brain. Get answers from web or docs, custom agents, automations |
| [QuivrHQ/quivr](https://github.com/QuivrHQ/quivr) | 39.2K | Python | ✅ | pgvector/Qdrant | Opinionated RAG for integrating GenAI into apps. Easy integration into existing products |
| [Mintplex-Labs/anything-llm](https://github.com/Mintplex-Labs/anything-llm) | 62.7K | JavaScript | ✅ | Multi (Chroma, Pinecone, Qdrant, Weaviate) | Local-first agent experience. Workspaces, multi-LLM, document management |
| [infiniflow/ragflow](https://github.com/infiniflow/ragflow) | 84.5K | Go | ✅ | Built-in | Leading open-source RAG engine with deep document understanding + Agent capabilities |
| [chatchat-space/Langchain-Chatchat](https://github.com/chatchat-space/Langchain-Chatchat) | 38.3K | Python | ✅ | Chroma/FAISS | Langchain-based RAG + Agent app, supports ChatGLM, Qwen, Llama. Chinese-first |

## Tier 2: RAG Engines & Frameworks

| Project | ⭐ | Lang | Description |
|---|---|---|---|
| [langchain-ai/langchain](https://github.com/langchain-ai/langchain) | 141.1K | Python | The agent engineering platform. Framework, not a product |
| [run-llama/llama_index](https://github.com/run-llama/llama_index) | 50.7K | Python | Document agent and OCR platform. Industry-standard RAG framework |
| [microsoft/graphrag](https://github.com/microsoft/graphrag) | 34.2K | Python | Graph-based RAG system. Knowledge graph + retrieval |
| [HKUDS/LightRAG](https://github.com/HKUDS/LightRAG) | 37.4K | Python | "Simple and Fast Retrieval-Augmented Generation" (EMNLP2025) |
| [SciPhi-AI/R2R](https://github.com/SciPhi-AI/R2R) | 7.9K | Python | Production-ready agentic RAG with RESTful API |
| [weaviate/Verba](https://github.com/weaviate/Verba) | 7.7K | Python | RAG chatbot powered by Weaviate |
| [NirDiamant/RAG_Techniques](https://github.com/NirDiamant/RAG_Techniques) | 28.4K | Jupyter | Showcase of advanced RAG techniques (reference/learning, not deployable) |

## Tier 3: AI Memory Layers

| Project | ⭐ | Lang | Description |
|---|---|---|---|
| [mem0ai/mem0](https://github.com/mem0ai/mem0) | 60.3K | Python | Universal memory layer for AI Agents. Graph-backed, multi-user |
| [thedotmack/claude-mem](https://github.com/thedotmack/claude-mem) | 86.2K | JavaScript | Persistent context for every agent. Captures, compresses session memory with AI |

## Tier 4: Personal Knowledge & Bookmark Management

| Project | ⭐ | Lang | Description |
|---|---|---|---|
| [karakeep-app/karakeep](https://github.com/karakeep-app/karakeep) | 27.0K | TypeScript | Self-hostable bookmark-everything app with AI tagging + full text search |
| [blinkospace/blinko](https://github.com/blinkospace/blinko) | 10.7K | TypeScript | Self-hosted personal AI note tool, privacy-first |
| [AgriciDaniel/claude-obsidian](https://github.com/AgriciDaniel/claude-obsidian) | 8.9K | Python | Self-organizing AI second brain for Obsidian + Claude Code |
| [SamurAIGPT/llm-wiki-agent](https://github.com/SamurAIGPT/llm-wiki-agent) | 3.1K | Python | Personal KB that builds itself. Drop sources → Claude/Codex reads & extracts knowledge |

## Tier 5: Local-First Chat + Document RAG

| Project | ⭐ | Lang | Description |
|---|---|---|---|
| [nomic-ai/gpt4all](https://github.com/nomic-ai/gpt4all) | 77.4K | C++ | Run local LLMs on any device. Chat + doc QA |
| [h2oai/h2ogpt](https://github.com/h2oai/h2ogpt) | 12.0K | Python | Private chat with local GPT. Documents, images, video. Ollama/Llama.cpp |
| [getumbrel/llama-gpt](https://github.com/getumbrel/llama-gpt) | 10.9K | TypeScript | Self-hosted offline ChatGPT-like. Llama 2, 100% private |

## Tier 6: Workflow Automation with AI

| Project | ⭐ | Lang | Description |
|---|---|---|---|
| [n8n-io/n8n](https://github.com/n8n-io/n8n) | 195.5K | TypeScript | Fair-code workflow automation with native AI. Self-host or cloud |
| [FlowiseAI/Flowise](https://github.com/FlowiseAI/Flowise) | 54.4K | TypeScript | Build AI Agents visually. Drag-and-drop LLM workflows |

## Tier 7: Vector DB Infrastructure

| Project | ⭐ | Lang | Description |
|---|---|---|---|
| [chroma-core/chroma](https://github.com/chroma-core/chroma) | 28.7K | Rust | Search infrastructure for AI. Embeddings + metadata store |
| [qdrant/qdrant](https://github.com/qdrant/qdrant) | ~30K | Rust | Vector database (your current stack for personal_kb) |

---

## Assessment: Best Fits for Personal Use

### 🏆 Top Recommendations (Self-Hosted, Personal KB)

**1. Khoj** — *Best "AI Second Brain" out of the box*
- Drop in notes/docs, get conversational answers
- Obsidian/Notion/Google Drive integrations
- Supports Ollama/local LLMs (works with your vLLM setup)
- Clean UI, minimal config
- ⚠️ Agent features still maturing

**2. AnythingLLM** — *Best for multi-workspace + multi-LLM*
- Workspaces isolate different knowledge domains
- Supports Chroma, Qdrant, Pinecone, Weaviate (works with your Qdrant)
- Multiple LLM backends (Ollama, OpenAI, Anthropic)
- ⚠️ UI is functional but not polished

**3. RAGFlow** — *Best for deep document understanding*
- Highest stars (84K), Go-based, enterprise-grade
- Deep document parsing (tables, charts, formulas)
- Built-in Agent capabilities
- ⚠️ Heavier resource footprint

### 🥈 Strong Alternatives

**4. Quivr** — *Best for developers integrating RAG into apps*
- Clean API, opinionated but flexible
- Good for building on top of

**5. GraphRAG (Microsoft)** — *Best for graph-based knowledge*
- Knowledge graph + retrieval = better semantic connections
- ⚠️ More complex setup, not turnkey

### 🥉 Emerging / Niche

**6. Karakeep** — Best if you need *bookmark + AI tagging* workflow
**7. mem0** — Best if you want an *agent memory layer* (not a full KB)
**8. MemGPT / Claude-mem** — Session memory for agents, not document KB

---

## Architecture Comparison (vs Your Current Stack)

Your current: **Qdrant (personal_kb, ~85K points) + Hermes Agent + Obsidian vault**

| Approach | Effort | Replaces Qdrant? | Added Value |
|---|---|---|---|
| Khoj | Low | Complements | Obsidian sync, chat UI, web search |
| AnythingLLM | Medium | No (uses Qdrant) | Workspaces, multi-LLM UI |
| RAGFlow | Medium | Replaces | Deep doc parsing, built-in vector DB |
| GraphRAG | High | Complements | Knowledge graph relationships |
| Keep current | Zero | N/A | You already have this working |

**Verdict:** Your current Hermes + Qdrant + Obsidian stack is already competitive. Khoj adds the most value with least friction — essentially a UI layer on top of your existing knowledge. AnythingLLM if you want workspace isolation.
