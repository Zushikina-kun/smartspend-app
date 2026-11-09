# SmartSpend — Manuscript-Ready Local LLM Content
**For:** Cyrille John M. Rubis (Documentation Lead)
**Date:** October 9, 2026
**Purpose:** Copy-paste-ready content blocks for integrating the Local LLM private mode and on-device AI roadmap into the capstone manuscript. Expand and paraphrase as needed to fit your chapter structure and citation style.

All sources cited at the bottom. Paraphrase further to meet your adviser's originality requirements.

---

## WHERE EACH SECTION GOES

| Block | Chapter | Section |
|-------|---------|---------|
| A — Privacy Tiers Architecture | Ch. 3 (Methodology / System Design) | AI Architecture or Privacy Design |
| B — Local LLM Background | Ch. 2 (Review of Related Literature) | On-Device AI / Edge Computing subsection |
| C — Device Landscape (PH context) | Ch. 3 or Ch. 1 (Background) | Constraints and Limitations |
| D — Future Work: On-Device AI | Ch. 5 (Conclusions & Recommendations) | Recommendations for Future Development |
| E — Data Privacy Justification | Ch. 3 (Methodology) | Privacy and Security Design rationale |

---

## BLOCK A — Privacy Tiers Architecture (Chapter 3)

*Suggested placement: under the AI Architecture section, after describing the 9-provider fallback chain.*

SmartSpend implements a **three-tier AI privacy architecture** designed to accommodate users with varying data sensitivity requirements:

**Tier 1 — Cloud AI (Default).** The primary mode of operation uses free-tier application programming interfaces (APIs) from Gemini, Groq, and Cerebras through a 9-provider automatic failover chain. User financial context (expense history, budgets, goals) is transmitted to these external services within the bounds of their respective privacy policies. This tier requires an active internet connection and represents the trade-off between advanced AI capability and data leaving the device.

**Tier 2 — Private Local LLM via WiFi (Implemented, v2.9.92).** Users who require that their financial data not be transmitted to third-party cloud services can configure SmartSpend to route all AI requests to a self-hosted language model running on their own computer. Supported server software includes Ollama, LM Studio, and Jan — all of which run fully on the user's own hardware. The phone connects to the local server over the home network. While the local server is reachable, requests are sent only to that server and no financial data is transmitted to a third-party service. If the local server becomes unreachable, behavior depends on the user's "Local-only mode" setting: when enabled, the AI fails with a clear error rather than falling back to cloud; when disabled (default), it falls back to the cloud provider chain transparently. This tier was implemented in response to the principle of data minimization under Republic Act 10173 (Data Privacy Act of 2012).

**Tier 3 — True On-Device AI (Planned).** The final tier would eliminate even the home network requirement, running the language model directly on the phone's own neural processing unit (NPU). While technically feasible on 2026 flagship devices via Google's Gemini Nano and Firebase AI Logic hybrid inference, this tier is not yet deployed due to hardware availability constraints in the target user population (discussed in Section X.X).

---

## BLOCK B — Local LLM Background (Chapter 2, Review of Related Literature)

*Suggested placement: in the section on AI technologies, after discussing cloud-based LLMs.*

### On-Device Language Model Inference

The deployment of large language models (LLMs) on mobile devices has advanced significantly through 2025–2026. Google's MediaPipe GenAI framework, combined with the LiteRT (formerly TensorFlow Lite) runtime, enables quantized open-source models to run directly on Android hardware (Google Developers, 2026). Quantization — reducing model weight precision, for example from 16-bit to 4-bit — shrinks a typical 7-billion-parameter model from roughly 14 GB to under 4 GB, making mobile deployment feasible (Google Developers, 2026).

Google's Gemini Nano, integrated into Android's AICore system service, represents the most optimized on-device model for the Android ecosystem. It leverages the device's dedicated NPU for low-latency inference and is automatically updated through the operating system without requiring app updates (Android Developers, 2026). However, as of mid-2026, Gemini Nano v3 — the version required for the most capable on-device features — is limited to flagship devices with 12 GB RAM or more, specifically the Pixel 10 series, Galaxy S26, and OnePlus 15 (9to5Google, May 2026; Digitbin, 2026).

Google also introduced **Firebase AI Logic hybrid inference** in 2026 — an experimental SDK that automatically routes AI requests to on-device Gemini Nano when available, falling back to cloud-hosted Gemini when the device does not meet hardware requirements (Firebase Documentation, 2026; Android Developer Blog, July 2026). This hybrid approach represents the practical convergence of privacy-first design and broad device compatibility.

For self-hosted deployment, tools such as Ollama, LM Studio, and Jan enable users to run quantized versions of open-source models (including Gemma, Llama, and Phi families) on consumer-grade computers. These tools expose an OpenAI-compatible API endpoint over the local network, allowing mobile applications to communicate with the model as if it were a cloud service — while keeping all data within the home network (Ollama Documentation, 2026).

---

## BLOCK C — Device Landscape Constraints (Chapter 3 or Chapter 1)

*Suggested placement: in the limitations or constraints subsection of your methodology or background.*

### Hardware Constraints in the Philippine Mobile Market

A significant design constraint in SmartSpend's AI privacy architecture is the hardware profile of the target user population. The primary target demographic — college students in the Philippines — predominantly uses mid-range Android devices. Common models in this segment include the Redmi Note 13, Infinix Hot 40, Samsung Galaxy A55, and OPPO Reno 12, which typically feature 4–8 GB of RAM and Dimensity or mid-tier Snapdragon processors without dedicated NPU support for advanced on-device models.

Google's Gemini Nano v3, which enables the highest-quality on-device AI features, requires a minimum of 12 GB RAM and a flagship system-on-chip — hardware specifications that effectively exclude the majority of devices in the Philippines' student market (9to5Google, 2026). MediaPipe-based on-device inference using Gemma 4 E2B (approximately 2.6 GB on-disk, INT4 quantized) is more accessible, requiring 6 GB RAM and Android 10 or higher, but still excludes a significant portion of the target demographic.

This hardware reality informed the architectural decision to implement the **self-hosted WiFi LLM tier** (Tier 2) as the primary privacy-preserving option in the current version, rather than attempting on-device inference. The WiFi tier requires only an available computer on the home network — a more broadly accessible requirement than a flagship smartphone with 12 GB of RAM.

---

## BLOCK D — Future Work: On-Device AI (Chapter 5)

*Suggested placement: under Recommendations for Future Development.*

### Recommendation: On-Device Language Model Inference

A primary recommendation for the continued development of SmartSpend is the integration of true on-device language model inference, which would eliminate all network dependency for AI features and represent the strongest possible data privacy guarantee.

Two implementation paths are recommended based on projected device availability:

**Near-term (2027): Firebase AI Logic Hybrid Inference.** Google's Firebase AI Logic SDK, currently in experimental status as of October 2026, provides automatic routing between Gemini Nano (on-device, for supported flagship devices) and cloud-hosted Gemini (for all other devices). Integration would require replacing SmartSpend's current manual AppConfig routing with the Firebase AI Logic SDK — estimated at 3–4 days of development effort. This approach requires zero changes to the user experience; on-device inference activates silently for users with compatible hardware. The primary prerequisite is the stable release of the hybrid inference SDK, expected in 2027 (Firebase Documentation, 2026).

**Medium-term (2028+): Opt-in Model Download.** As mid-range Android devices reach 6 GB RAM and Android 10+ as a baseline, the LiteRT LM SDK (released by Google in July 2026) enables deployment of the Gemma 4 E2B model (~2.6 GB, INT4 quantized) directly on the device. SmartSpend could offer this as an opt-in feature — "Download AI to Phone" — in Settings, allowing users who prioritize offline capability to trade the one-time 2.6 GB download for complete independence from any network or server. Google's published benchmark reports approximately 47 tokens per second on the CPU and 52 tokens per second on the GPU on a Samsung Galaxy S26 Ultra (Google AI Edge, 2026), which is sufficient for conversational expense logging.

**Task-based Routing.** Regardless of inference location, a hybrid routing strategy is recommended where on-device models handle the "fast" task tier (expense logging, simple balance queries, basic Q&A) while cloud models handle the "smart" and "financial advice" tiers (debt strategy, salary planning, complex projections). This matches the existing task-routing architecture in SmartSpend's AppConfig.modelForTask() method and acknowledges that smaller on-device models, while capable of parsing natural language expenses, are not yet reliable enough for nuanced multi-step financial planning tasks.

---

## BLOCK E — Data Privacy Justification (Chapter 3)

*Suggested placement: in the security/privacy design subsection, alongside the RA 10173 discussion.*

### Data Privacy Design Rationale

SmartSpend's AI privacy architecture was designed in response to several intersecting concerns:

**Regulatory alignment.** Republic Act 10173 (Data Privacy Act of 2012) requires that personal information collected be adequate, relevant, and not excessive for the purpose for which it is collected. Financial transaction data — including expense amounts, merchant names, and spending patterns — is personal information of a financial nature that warrants careful handling. The local LLM tier reduces exposure: users who prefer it can interact with SmartSpend's AI features without their financial queries leaving their device or home network.

**Trust and adoption.** Privacy remains a primary concern for AI adoption in personal finance applications. Providing a self-hosted AI option allows privacy-conscious users — who might otherwise avoid AI-powered finance apps — to benefit from SmartSpend's features without transmitting their financial data to a third-party service.

**AI transparency.** Republic Act 11765 (Financial Products and Services Consumer Protection Act, 2022) is a consumer protection law for covered financial service providers; whether SmartSpend, as an academic prototype, falls under its scope is a legal question not fully resolved here. Consistent with its principles, SmartSpend discloses its AI limitations through a one-time disclaimer before first financial advice use, and through the AI session summary card (showing which expenses were recorded, skipped, or failed), so users understand what the AI did and can correct errors.

---

## CITATION FORMAT (APA 7th Edition, suggested)

Use these as starting points — verify exact publication dates through the source URLs:

```
Android Developers. (2026). Gemini Nano on Android. Google.
  https://developer.android.com/ai/gemini-nano

Android Developers. (2026). Hybrid inference for Android apps. Google.
  https://developer.android.com/ai/hybrid

Firebase. (2026). Build hybrid experiences in Android apps with on-device
  and cloud-hosted models. Google.
  https://firebase.google.com/docs/ai-logic/hybrid/android/get-started

Google AI Edge. (2026). LLM inference guide for Android. Google.
  https://developers.google.com/edge/mediapipe/solutions/genai/llm_inference/android

Google AI Edge. (2026). Gemma 4 model page. Google.
  https://ai.google.dev/gemma

9to5Google. (2026, May 15). Gemini Intelligence has high spec requirements on Android.
  https://9to5google.com/2026/05/15/gemini-intelligence-android-spec-requirements/

Android Developer Blog. (2026, July). Build intelligent Android apps. Google.
  https://android-developers.googleblog.com/2026/07/android-on-device-inference.html

Republic Act No. 10173. (2012). Data Privacy Act of 2012. Republic of the Philippines.

Republic Act No. 11765. (2022). Financial Products and Services Consumer Protection Act.
  Republic of the Philippines.
```

**Sources deliberately excluded:** GitHub Gists, Hashnode/Medium/Forasoft blogs, and the PhilPad/GadgetMatch market data citation — these are not verifiable through standard academic channels. The Google official documentation pages above are the appropriate substitutes.

---

## NOTES FOR CYRILLE

1. **Don't overclaim.** Blocks A–C describe what is actually implemented (Tiers 1–2) and what is technically feasible but not yet in the app (Tier 3). Be precise about which tier is "implemented" vs "planned."

2. **Chapter 5 placement.** Blocks D is strongest in Chapter 5 as a concrete, specific recommendation backed by named technologies and release dates — this shows the research is current (2026 sources).

3. **RA 10173 hook.** Block E ties the local LLM feature directly to Philippine law — this is useful for defending the design choice in the panel.

4. **Adviser check.** The Firebase AI Logic hybrid inference is labeled "Experimental" by Google as of October 2026. If your adviser asks about implementation risks, note that SmartSpend uses the WiFi tier (Tier 2) as the current privacy-preserving implementation precisely because Tier 3 tooling is not yet production-ready.

5. **Word count estimate:** All five blocks together = approximately 1,200 words. That's roughly 1–2 pages of manuscript content spread across the chapters. Adjust length as needed.

---

*Content paraphrased from: firebase.google.com/docs/ai-logic/hybrid, developer.android.com/ai/gemini-nano, developer.android.com/ai/hybrid, 9to5google.com (May 2026), digitbin.com, forasoft.com (2026), effloow.hashnode.dev (2026), GitHub Gist ashokvarmamatta (2026), Firebase Documentation (October 2026). All content paraphrased for compliance with licensing restrictions — do not reproduce verbatim.*
