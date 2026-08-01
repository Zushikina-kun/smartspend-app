# LLM Comparative Analysis — Chapter 3 Reference
**SmartSpend Capstone 2 | Lucid Frame | June 2026 (Updated)**

---

## Selection Criteria

| Criterion | Weight | Description |
|-----------|--------|-------------|
| Filipino-English Accuracy | 25% | Ability to understand and respond in mixed Filipino-English (Taglish) |
| Speed / Latency | 20% | Response time for real-time mobile interaction (<3 seconds ideal) |
| Tool Use / Function Calling | 20% | Ability to output structured JSON actions reliably |
| Cost / Free Tier | 15% | Availability of free tier suitable for academic project |
| Context Window | 10% | Token limit for system prompt + user context + history |
| Reasoning Quality | 10% | Financial advice accuracy and logical consistency |

---

## Full Benchmarking Table (Updated June 2026)

| Model | Provider | Context Window | Speed (tokens/s) | Filipino-English | Tool Use | Cost | Selected? |
|-------|----------|---------------|-------------------|-----------------|----------|------|-----------|
| **Gemini 3.1 Flash-Lite** | Google | 1,000,000 | ~200 t/s | ★★★★★ (Excellent) | ★★★★★ | **Free** (1,000/day) | ✅ **PRIMARY** (v2.9.1) |
| **Gemini 3.5 Flash** | Google | 1,000,000 | ~150 t/s | ★★★★★ (Excellent) | ★★★★★ | **Free** (250/day) | ✅ **FALLBACK 1** (v2.9.1) |
| **LLaMA 3.3 70B** | Groq | 128,000 | ~315 t/s | ★★★★★ (Excellent) | ★★★★★ | **Free** (14,400/day) | ✅ **FALLBACK 2** (v2.9.1) |
| **LLaMA 3.1 8B Instant** | Groq | 8,192 | ~800 t/s | ★★★★☆ (Good) | ★★★★☆ | **Free** (14,400/day) | ✅ **FALLBACK 3** (v2.9.1) |
| **LLaMA 3.1 70B** | Cerebras | 128,000 | ~400 t/s | ★★★★★ (Excellent) | ★★★★★ | **Free** (1M tokens/day) | ✅ **FALLBACK 4** (v2.9.1) |
| GPT-4o | OpenAI | 128,000 | ~80 t/s | ★★★★★ (Excellent) | ★★★★★ | $5/1M input tokens | ❌ Cost |
| GPT-4o Mini | OpenAI | 128,000 | ~120 t/s | ★★★★☆ (Good) | ★★★★★ | $0.15/1M input | ❌ No free tier |
| Claude 3.5 Sonnet | Anthropic | 200,000 | ~70 t/s | ★★★★★ (Excellent) | ★★★★★ | $3/1M input | ❌ Cost |
| Gemini 2.0 Flash | Google | 1,000,000 | ~150 t/s | ★★★★☆ (Good) | ★★★★☆ | Free (15 req/min) | ❌ Superseded by 2.5 |
| Mistral 7B | Mistral AI | 32,000 | ~600 t/s | ★★★☆☆ (Fair) | ★★★☆☆ | Free (self-host) | ❌ Filipino weak |
| Phi-3 Mini (3.8B) | Microsoft | 4,096 | ~900 t/s | ★★☆☆☆ (Poor) | ★★☆☆☆ | Free (local) | ❌ Too small |
| Gemma 2 9B | Google | 8,192 | ~500 t/s | ★★★☆☆ (Fair) | ★★★☆☆ | Free (local) | ❌ No hosted API |
| Mixtral 8x7B | Mistral/Groq | 32,000 | ~400 t/s | ★★★☆☆ (Fair) | ★★★★☆ | Free (Groq) | ❌ Filipino weak |

---

## v2.8.0 Multi-Model Architecture

SmartSpend v2.8.0 implements a **multi-provider LLM routing system** that:
1. Uses **Gemini 2.5 Flash-Lite** as default (best quality, 1M context, 1,000 req/day free)
2. Auto-falls back through the chain when daily limit hit: Flash-Lite → Flash → Groq 70B → Groq 8B → Cerebras
3. User can manually switch models via the model chip in the AI appbar
4. Keys stored in `app_config.dart` (`.gitignore`) and optionally in Firebase Remote Config

**Why Gemini 2.5 Flash-Lite is now primary:**
- Higher reasoning quality than LLaMA 3.1 8B (better financial analysis)
- Larger context window (1M vs 8K) — fits more user data
- 1,000 requests/day free — sufficient for 60 req/user/day limit
- Filipino-English: excellent (multilingual training data)
- Tool use: native function calling support

---

## Selection Justification: Original (LLaMA 3.1 8B on Groq)

### Why Originally Selected (v2.0-2.7):
1. **Free tier** — 30 requests/minute, no credit card required. Essential for an academic project with no budget.
2. **Fastest inference** — Groq's LPU hardware delivers ~800 tokens/second, enabling real-time mobile interaction (<1 second response for expense logging).
3. **Filipino-English capable** — LLaMA 3.1 was trained on multilingual data including Filipino/Tagalog. Handles Taglish naturally (e.g., "nagbayad ako ng 30 pesos sa jeep").
4. **Reliable JSON output** — Consistently generates structured ACTION:{} lines when instructed, enabling the agentic architecture.
5. **Modular architecture** — The AI engine is abstracted behind `AIChatService` and `LLMService`. Swapping to a different model requires changing only the API endpoint and model name in `AppConfig`.

### Why Others Were Excluded:
- **GPT-4o / Claude 3.5** — Superior quality but require paid API keys. Not viable for a college capstone with no funding.
- **Gemini 2.0 Flash** — Strong free-tier candidate and designated as backup. Lower tool-use reliability than LLaMA 3.1 in testing.
- **Mistral / Phi-3 / Gemma** — Weaker Filipino-English understanding. Would require extensive prompt engineering to handle Taglish input.
- **LLaMA 3.1 70B** — Better quality but 2-3x slower on Groq. The 8B model is sufficient for expense parsing and financial advice.

---

## Fallback Plan

If Groq's free tier becomes unavailable or rate-limited:
1. **Primary fallback:** Gemini 2.0 Flash via Google AI Studio (free, 15 req/min)
2. **Secondary fallback:** Together AI free tier (LLaMA 3.1 8B, 60 req/min)
3. **Architecture note:** Switching requires only changing `AppConfig.groqBaseUrl` and `AppConfig.groqModel` — no app rebuild needed for end users if done via remote config.

---

## Architecture: Why Context Injection, Not RAG

| Approach | Description | Suitable For | Our Choice |
|----------|-------------|--------------|------------|
| **RAG** | Vector DB + embedding search + retrieval | Large knowledge bases (1000+ docs) | ❌ Overkill |
| **Fine-tuning** | Train model on custom data | Domain-specific language patterns | ❌ Expensive, inflexible |
| **Context Injection** | Inject full user data into system prompt | Small per-user datasets (<50 items) | ✅ **Selected** |

**Rationale:** A typical SmartSpend user has 20-50 expenses, 5-10 budgets, 3-5 goals, and 2-3 debts. This entire dataset fits in ~1000 tokens — well within the 8,192 token context window. RAG's vector search overhead is unnecessary when the full dataset can be injected directly.

---

## Performance Metrics (Actual from SmartSpend v2.7.0)

| Metric | Value |
|--------|-------|
| Average response time | 0.8–1.5 seconds |
| Action parsing success rate | ~95% (with fallback parser: ~99%) |
| Multi-item logging success | ~90% (improved from ~60% after prompt optimization) |
| Daily message limit | 60/day (device-wide) |
| Token usage per message | ~2000-4000 (system + context + history + response) |
| Conversation summarization | Every 10 messages (saves 40-70% tokens) |

---

*Note: Speed measurements are from Groq's LPU inference hardware. Actual latency includes network round-trip (~200ms Philippines to Singapore region).*
*Ratings are based on internal testing with Filipino-English financial prompts (April-May 2026).*
