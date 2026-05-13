# KIzty Agent Fork Roadmap

This fork starts from Open WebUI and turns it into KIzty's personal Agent Hub.

## Goal

Build a daily-use agent workspace where:

- Domestic LLMs handle cheap reasoning, summarization, planning, and context compression.
- Codex / Claude Code / OpenHands / Cline / Goose can be connected as coding workers.
- Chat histories from ChatGPT, Claude, Claude Code, and Codex can be imported, searched, summarized, and reused.
- KIzty owns the context layer instead of depending on one vendor's sidebar.

## First Modification Targets

### 1. Provider Presets For Domestic LLMs

Open WebUI already supports OpenAI-compatible endpoints. The fork should add first-class presets and copy for:

- DeepSeek
- Qwen / Alibaba Cloud DashScope
- Kimi / Moonshot
- GLM / Zhipu
- MiniMax
- Ollama / vLLM local models
- LiteLLM gateway

Files to inspect first:

- `src/lib/components/AddConnectionModal.svelte`
- `src/lib/apis/openai/index.ts`
- `backend/open_webui/config.py`
- `src/lib/i18n/locales/zh-CN/translation.json`

### 2. Imported Conversation Sources

Open WebUI already imports ChatGPT exports. This fork should add a source-aware import path:

- `chatgpt`
- `claude`
- `claude_code`
- `codex`
- `manual_markdown`

The import should preserve source metadata and create tags/folders automatically.

Files to inspect first:

- `src/lib/apis/chats/index.ts`
- `backend/open_webui/routers/chats.py`
- `backend/open_webui/models/chats.py`
- `backend/open_webui/tools/builtin.py`

### 3. Sidebar As Work Console

The sidebar should become a personal work console, not only a chat list.

Target groups:

- Today
- Pinned
- Projects
- Imported From Codex
- Imported From Claude
- Task Cards
- Memory Candidates

Files to inspect first:

- `src/lib/components/app/AppSidebar.svelte`
- `src/lib/components/layout/Sidebar.svelte`
- `src/lib/apis/folders/index.ts`
- `src/app.css`

### 4. Task Card Workflow

Add a task-card entity or lightweight note template that turns long conversation context into a compact prompt for coding workers.

Minimum fields:

- Goal
- Background
- Files in scope
- Files out of scope
- Acceptance criteria
- Risks
- Final prompt for Codex / Claude Code
- Result summary

Potential implementation paths:

- Start as a note template.
- Later promote to a first-class table/model if the workflow proves useful.

Files to inspect first:

- Notes components and APIs
- Chat actions / prompt templates
- Built-in tools for chat search

## What Not To Do First

- Do not rebrand heavily before checking license constraints.
- Do not build a desktop shell before the web fork proves the workflow.
- Do not directly pipe every imported conversation into a model context window.
- Do not make domestic LLMs responsible for every coding action; keep coding workers available.

## First Branch

Branch name:

```text
kizty-agent-foundation
```

## Operating Principle

The fork is not about copying a product surface. It is about owning the context system:

```text
history -> summary -> task card -> coding worker -> result -> memory candidate
```

