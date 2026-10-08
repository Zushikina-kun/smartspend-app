# SmartSpend — On-Device LLM Research & Roadmap
**Date:** October 9, 2026 | **Status:** Research + future planning
**Context:** Expanding beyond the current "Local LLM via WiFi" (self-hosted Ollama/LM Studio) to true on-device inference running directly on the user's phone.

---

## 0 — Current State (v3.0.3)

SmartSpend currently has **three AI tiers**:

| Tier | How it works | Privacy | Internet required |
|------|-------------|---------|------------------|
| Cloud AI (default) | Gemini/Groq/Cerebras via API | Data leaves device | ✅ Yes |
| Local LLM via WiFi | User's own PC running Ollama/LM Studio/Jan on home network | Data stays home | ✅ For initial setup only |
| *(planned) On-device* | LLM running directly on the phone | Data never leaves phone | ❌ None |

The "Local LLM via WiFi" tier (provider #9) already exists. What we're researching here is tier 3 — **the model running on the phone's own chip**, with zero network dependency at all.

---

## 1 — What's Actually Available in 2026

### 1.1 Gemini Nano via Android AICore

Google's **Gemini Nano** runs in Android's AICore system service, leveraging the device's neural processing unit (NPU) for low-latency inference.

**Current reality (May 2026):**
- Requires **Gemini Nano v3**, a **flagship SoC**, and **12 GB RAM minimum**
- Supported on: Pixel 10 series, Galaxy S26, OnePlus 15 (2026 flagships)
- NOT supported on: Pixel 9 series, Galaxy Z Fold 7, Galaxy S25 (confirmed exclusions)
- The Pixel 9 costs over $1,000 and still doesn't qualify — hardware bar is steep

**Flutter plugin:** `gemini_nano_android` (Piero16301/gemini_nano_android) — bridges Flutter to Android's AICore/ML Kit Prompt API. Community-maintained, not an official Flutter plugin.

**What it can do for SmartSpend:**
- Conversational expense logging (basic natural language → structured data)
- Simple Q&A about spending ("how much did I spend today?")
- Local summarization of expense lists

**What it CAN'T do well on-device:**
- Complex multi-step reasoning (plan_salary_split, debt analysis)
- Long financial context (full expense history + budgets + goals)
- The 34 agentic actions that need precise JSON parsing

**Conclusion:** Gemini Nano is viable for basic logging on 2026 flagship phones only. Not broadly deployable to the Filipino student market (most users have mid-range phones, 4–6 GB RAM).

### 1.2 MediaPipe LLM Inference API (Google)

Google's **MediaPipe GenAI framework** + **LiteRT (formerly TensorFlow Lite)** lets apps run open-source models (Gemma, Llama, Phi) directly on Android.

**Models that run on-device (2026):**
| Model | Size on disk | Min RAM | Quality |
|-------|-------------|---------|---------|
| Gemma 2B (INT4 quantized) | ~1.3 GB | ~4 GB | Basic chat |
| Gemma 4 E2B (INT4) | ~2.6 GB | ~6 GB | Good reasoning |
| Gemma 3n 2B | ~2.1 GB | ~4 GB | Multimodal |
| Phi-3 Mini (INT4) | ~2.2 GB | ~4 GB | Good reasoning |

**Flutter integration:** `ai_edge` Flutter plugin (KyoheiG3/ai_edge) — wraps MediaPipe GenAI for Flutter. Also community-maintained.

**Practical constraints for SmartSpend:**
- 2.6 GB model download on first install — unacceptable for most users
- Inference speed: 20–40 tokens/second on mid-range phones (Snapdragon 778G) — slow for a chat experience
- Context window: 2K–8K tokens — potentially too small for SmartSpend's full financial context
- Works on Android 8.0+ (API 26+) with 6 GB RAM — covers more phones than Gemini Nano

**Conclusion:** MediaPipe/LiteRT is more broadly deployable than Gemini Nano but the model download size and RAM floor make it impractical as a default. Better as an opt-in "download AI" feature.

### 1.3 Firebase AI Logic — Hybrid Inference (Experimental, 2026)

Google announced **Firebase AI Logic hybrid inference** in 2026 — the SDK automatically routes requests to Gemini Nano (on-device) when available, and falls back to cloud Gemini when not.

**From the Firebase docs (2026):**
> "Hybrid inference enables running inference using on-device models when available and seamlessly falling back to cloud-hosted models otherwise."

This is the most relevant technology for SmartSpend's architecture. One SDK, automatic routing:
- **Supported device with Nano v3** → runs on-device, zero API cost, zero network
- **Unsupported device** → falls back to cloud Gemini automatically

**Status:** Marked "Experimental" as of October 2026. App Check enforcement required from November 2, 2026.

**Flutter support:** Firebase AI Logic has Flutter SDK (`firebase_ai` package on pub.dev). Hybrid inference support in Flutter is described as experimental but functional.

**This is the right long-term architecture for SmartSpend's on-device tier.**

### 1.4 LiteRT LM SDK (New, July 2026)

Google released the **LiteRT LM SDK** in July 2026 — a higher-level API specifically for LLM inference on Android that abstracts MediaPipe complexity.

- Download and run Gemma 4 E2B (~2.6 GB) on-device
- Kotlin/Java native SDK; Flutter interop via platform channels
- Works on Android 10+ with 6 GB RAM
- Gemma 4 on Pixel 9 (Snapdragon 8 Gen 3): ~55 tokens/second — fast enough for real use

---

## 2 — The Device Landscape Problem (Philippines context)

**The hard truth for the PH market:**

Most SmartSpend users are students with **mid-range phones**:
- Popular 2024–2025 PH student phones: Redmi Note 13, Infinix Hot 40, Samsung A55, OPPO Reno 12
- Typical RAM: 4–8 GB
- Typical chip: Dimensity 6100, Snapdragon 695 (no NPU for Nano v3)
- Typical storage: 128–256 GB (2.6 GB model = ~1–2% of storage, acceptable)

**Gemini Nano v3 requirement** knocks out 95%+ of the Filipino student market.
**MediaPipe with Gemma 2B (INT4, ~1.3 GB)** would run on more phones but with poor performance.

**Gemma 4 E2B INT4 (~2.6 GB)** with LiteRT LM SDK is the most promising option but needs 6 GB RAM and Android 10+.

---

## 3 — SmartSpend's On-Device LLM Strategy

### Phase 0 — Now (v3.x) ✅
Self-hosted Local LLM via WiFi (Ollama/LM Studio/Jan on user's PC). Privacy-conscious power users only.

### Phase 1 — Firebase AI Logic Hybrid (v5.0, ~2027)
Integrate Firebase AI Logic SDK with hybrid inference. This gives:
- On-device (Gemini Nano) for users with 2026+ flagship phones — zero API cost, instant
- Cloud Gemini fallback for everyone else — no behavior change from current
- One codebase, no branching logic, no separate model download

**Implementation:** Replace current manual `AppConfig` routing with Firebase AI Logic SDK. 3–4 days of work. Requires App Check enforcement (already planned for v4.0).

**Why not now:** Marked experimental. App Check enforcement deadline November 2026 creates timing pressure. Better to wait for stable release.

### Phase 2 — Opt-in On-Device Download (v6.0, ~2028)
For users who want true offline AI (no WiFi, no cloud, no PC):
- Add "Download AI to phone" option in Settings → AI → On-Device AI
- Downloads Gemma 4 E2B INT4 (~2.6 GB) via LiteRT LM SDK in the background
- Shows a clear disclaimer: "2.6 GB download, requires 6 GB RAM, Android 10+"
- Stores model in app-specific storage
- Inference runs entirely on-device — no network, no API key, no cost

**Why it's compelling for SmartSpend:**
- Perfect alignment with the "private mode" positioning — even more private than self-hosted PC
- Works on a plane, in areas with no cell signal, completely offline
- Zero AI cost per message for the user and developer

**Limitations to disclose:**
- 2.6 GB download (one-time, Wi-Fi recommended)
- 6 GB RAM minimum — excludes ~60% of current PH student phone market
- Slower than cloud (20–55 tok/sec depending on chip) — manageable for simple logging
- Model quality lower than Gemini 3.5 Flash — handles basic expense logging well, struggles with complex financial advice
- Context window smaller — full expense history may not fit; will need smart truncation

### Phase 3 — Hybrid Routing by Task (v6.x, future)
SmartSpend's 34 agentic actions vary enormously in complexity:

| Action type | On-device viable? | Why |
|-------------|-----------------|-----|
| `log_expense` (simple) | ✅ Yes | Parse "65 pesos lunch" → JSON |
| `update_expense` (edit) | ✅ Yes | Simple field update |
| `get_summary` / "how much did I spend?" | ✅ Yes | Math + retrieval |
| `plan_salary_split` | ⚠️ Maybe | Multi-step reasoning |
| `analyze_goal_feasibility` | ⚠️ Maybe | Needs good math |
| `suggest_debt_payoff` (avalanche/snowball) | ❌ Hard | Complex reasoning |
| `generate_monthly_plan` | ❌ Hard | Long context + planning |
| Financial advice / `financial_advice` tier | ❌ Hard | Needs full context + nuanced reasoning |

**Smart routing:** Use on-device model for `fast` task tier (logging, simple queries), cloud for `smart` and `financial_advice` tiers. Already matches the existing `modelForTask()` architecture in `AppConfig`.

---

## 4 — Implementation Notes for Future Developers

### Firebase AI Logic Hybrid (recommended path)

```dart
// pubspec.yaml — when ready
firebase_ai: ^2.x.x  // Firebase AI Logic SDK

// Replace AppConfig routing with:
final model = FirebaseAI.instance.generativeModel(
  model: 'gemini-2.0-flash',
  // Hybrid: tries Nano on-device, falls back to cloud
  inferenceMode: GenerativeModelInferenceMode.hybridPreferOnDevice,
);
```

### MediaPipe / LiteRT LM SDK (opt-in download path)

```dart
// 1. Add dependency
// mediapipe_genai: ^1.x.x (when Flutter plugin is stable)

// 2. Download model (one-time, background)
// Model: Gemma 4 E2B INT4 — 2.6 GB
// https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference

// 3. Create inference session
final llm = await LlmInference.createFromOptions(
  LlmInferenceOptions.fromModelPath(modelPath)
    ..maxTokens = 1024
    ..temperature = 0.3  // lower = more deterministic for finance
    ..topK = 40,
);

// 4. Run inference
final result = await llm.generateResponse(prompt);
```

### Smart context truncation for on-device models

On-device models have smaller context windows. SmartSpend's system prompt is ~3,000 tokens.
For on-device use, build a `_buildCompactContext()` that:
- Uses only last 7 expenses (not 10)
- Drops the behavioral rules section (500 tokens)
- Keeps only current-month budget/goal summary
- Total target: < 1,500 tokens input

This already partially exists in `_buildExpenseSummary()` — extend it with a `compact: true` mode.

---

## 5 — Decision Framework: Which Path to Take When

| When | What to do |
|------|-----------|
| **Now (v3–v4)** | Keep current 9-provider cloud chain. Add "Use your own Gemini key" to fix shared key problem. |
| **v4.0 (2026–2027)** | Self-hosted Local LLM via WiFi already shipped. Cloud Functions proxy for server-side key management. |
| **Firebase AI Logic goes stable** | Integrate hybrid inference SDK. Replaces manual routing. Gemini Nano auto-used on supported devices. |
| **When 6 GB RAM phones are ≥50% of PH market (~2028)** | Add opt-in "Download AI to phone" using LiteRT LM SDK / Gemma 4 E2B. |
| **When Gemini Nano v3+ is on mid-range phones** | Set on-device as the default path for `fast` tasks; cloud only for `smart`/`financial_advice`. |

---

## 6 — Gaps & Risks

| Risk | Mitigation |
|------|-----------|
| On-device model quality too low for agentic actions | Only use on-device for `fast` tier; always use cloud for `financial_advice` |
| 2.6 GB model download alienates users | Make it clearly opt-in, show download size prominently, require Wi-Fi confirmation |
| Model goes stale (financial knowledge cutoff) | On-device model only does parsing + retrieval; financial advice comes from cloud |
| Firebase AI Logic still experimental | Wait for stable release before v5.0 integration. Monitor firebase.google.com/docs/ai-logic/hybrid |
| LiteRT LM SDK Flutter plugin not yet official | Use platform channel bridge in Kotlin until official Flutter plugin ships |
| App Check enforcement November 2, 2026 | Already in Phase 2 pre-launch checklist — switch to Play Integrity before then |

---

## 7 — Summary for Capstone Documentation

For the manuscript, the current architecture positions SmartSpend as having **three privacy tiers**:
1. **Cloud AI** (default) — uses free-tier Gemini/Groq, 9-provider fallback, data processed remotely
2. **Private Local (WiFi)** — user's own PC running Ollama/LM Studio, data stays on home network ✅ *implemented*
3. **On-Device AI** (planned) — model runs on the phone itself, zero network dependency ⏳ *planned for v5–6*

The on-device tier is technically feasible today for 2026 flagship devices via Gemini Nano/Firebase AI Logic hybrid inference. For mid-range devices, it requires an opt-in model download (~2.6 GB). Full coverage of the Filipino student phone market (4 GB RAM, Dimensity 6100) is not feasible until on-device model compression improves further (estimated 2027–2028).

---

*Sources: firebase.google.com/docs/ai-logic/hybrid (Oct 2026), developer.android.com/ai/gemini-nano, developer.android.com/ai/hybrid, 9to5google.com Gemini Intelligence hardware requirements (May 2026), digitbin.com Gemini Intelligence device list, forasoft.com On-Device AI Android 2026, effloow.hashnode.dev Running LLMs on Phone 2026, dev.to MediaPipe Gemma Android guide. Content paraphrased for licensing compliance.*
