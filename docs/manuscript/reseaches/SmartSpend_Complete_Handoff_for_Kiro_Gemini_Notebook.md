# SmartSpend Complete Re-Research and Verification Handoff

**Date:** 9 September 2026  
**For:** Kiro, Gemini Notebook, Claude, Perplexity, and human validators  
**Upload with:** `smartspend-complete-consolidated-portfolio.md`, `SmartSpend_Research_Verification.docx`, source code/build records, raw datasets, surveys, SUS sheets, benchmark logs, and privacy documents.

## Mission

Re-research, verify, correct, and expand the SmartSpend capstone. Treat every claim in the supplied portfolio as a claim to audit, not as established fact. Use current official documentation, original peer-reviewed research, Philippine government sources, model cards, standards, and official product pages. Search for contrary evidence. Never invent citations, model IDs, prices, quotas, statistics, app capabilities, or benchmark results.

Separate: (1) evidence the problem exists; (2) theory supporting a design choice; (3) evidence that similar features may work; and (4) evidence that SmartSpend itself works.

## Required statuses

Use VERIFIED, PARTLY VERIFIED, PROJECT-REPORTED, NOT ESTABLISHED, CONTRADICTED, OUTDATED, MISATTRIBUTED, or LOW QUALITY. For every claim provide exact evidence, limitation, corrected wording, and required action.

## Executive audit

SmartSpend is defensible as a Philippine-context, offline-first Android personal-finance tracking prototype with multimodal input, transparent transaction-derived feedback, and bounded AI assistance. It is not yet defensible as a validated financial-health measurement system, fully compliant production financial product, autonomous financial adviser, perfectly secure system, or first/only/unique Philippine app.

The custom Financial Health Score should be named a prototype Financial Pattern Indicator or Observed Financial Pattern Indicator. FHN, CFPB, and UNSGSA support financial-health concepts and measurement approaches, but they do not validate SmartSpend’s weights, thresholds, missing-data rules, or penalties. CFPB’s instrument is a separate prescribed self-report scale of financial well-being.

Remove or verify the draft’s unsupported figures: 32% overspending reduction, 10–20% expense-tracking effect, 22% gamification improvement, 2.5x/$133 subscription claim, 41.5M user claim, and all first/only/unique claims.

## Current LLM re-research

Google’s current official documentation lists **Gemini 3.1 Flash-Lite**, endpoint `gemini-3.1-flash-lite`, as a low-latency, cost-effective multimodal model for high-frequency lightweight tasks. It documents text, image, video, audio, and PDF input; structured outputs; function calling; caching; file search; search grounding; code execution; a 1,048,576-token input limit; and 65,536-token output limit. [web:130]

Google’s Gemini 3 guide gives a 1M input / 64k output context and current pricing, but describes Gemini 3 models as preview at the page’s August 2026 update. Google’s lifecycle/deprecation documentation lists a future replacement path toward Gemini 3.5 Flash-Lite. The thesis must record exact endpoint, API/library version, test date, region/account tier, prompt version, tool settings, and model lifecycle status. [web:134][web:136]

Google documents structured JSON output using JSON Schema and Gemini 3’s combination of structured outputs with tools. This supports schema-constrained extraction but does not prove correct arithmetic, no duplicate IDs, safe business logic, or safe database writes. [web:131]

Do not retain “GPT-5.6 Terra,” “Claude Fable 5,” “DeepSeek V4,” or other model names unless official provider pages and exact endpoint identifiers are supplied. Do not copy “1,000 requests/day” without account-specific dated rate-limit evidence; quotas vary by model, tier, and time. [web:101]

### Required model table

| Provider | Exact endpoint | Status | Modalities | Context | Structured/tool support | Price/quota date | Test date | Evidence |
|---|---|---|---|---:|---|---|---|---|
| Google | `gemini-3.1-flash-lite` | Verify preview/stable | Verify official page | 1,048,576 input / 65,536 output documented | Structured output/function calling documented | Account-specific | Project log | [web:130][web:134] |
| Other providers | Exact IDs only | Verify | Verify | Verify | Verify | Verify | Project log | Official provider URLs required |

## Critical security correction

Firebase Remote Config does not make a billable third-party LLM key secret when an Android client can retrieve and use it. Firebase API keys are identifiers in the Firebase context and must be restricted; Firebase Security Rules and App Check protect Firebase resources, but they do not safely hide a provider secret placed in a client application. [web:100][web:107]

Required production architecture: server-side proxy or authenticated Cloud Function; provider secrets in server-side secret storage; user authentication; per-user quotas; server-side authorization and schema validation; minimized/redacted prompts; model calls never directly holding write authority; application code performs SQLite writes only after user confirmation; audit log and undo. If the prototype lacks this, label it a limitation/future remediation rather than claiming secure key handling.

## Privacy and Philippine DPA review

Do not claim “complete compliance” with RA 10173 solely from code controls. Use “designed with privacy-by-design controls intended to support alignment.” Document controller/processor roles, lawful basis, purpose limitation, data minimization, notice, granular consent, retention, deletion, access/export/correction, vendor/model-provider transfer, security, research-data separation, privacy impact assessment, and breach procedures. NPC guidance includes breach reporting, including a 72-hour rule for reportable breaches, and privacy-impact-assessment/risk considerations. [web:99][web:106]

Regex redaction is a risk-reduction measure, not a guarantee. It may miss OCR errors, names, QR/barcodes, addresses, order/reference IDs, screenshots containing unrelated content, and sensitive inferences. Add local OCR where feasible, cropping, field-level preview, minimization, explicit consent, and deletion of raw images by default.

## Data-flow table to complete

| Data | Local? | Cloud destination | Purpose | Retention | User control |
|---|---|---|---|---|---|
| Transactions | Complete | Optional sync | Ledger | Define | Edit/delete/export |
| Receipts/screenshots | Prefer local OCR | Only if necessary | Extraction | Delete by default | Crop/review/delete |
| Voice | Device/provider dependent | Document actual route | Transcription | Short/none | Consent/delete |
| Chat/history | Local or provider | AI explanation | Define | Delete/export |
| FHS/FPI | Deterministic local | Optional analytics | Feedback | Define | Explain/disable |
| Research data | Separate | Restricted | Capstone | Ethics-approved | Consent/withdraw |

## Offline and Firestore audit

Firestore supports offline persistence and later synchronization, but this does not prove conflict-free financial-data merging. [web:112] Replace “100% recovery,” “0% conflicts,” and “seamless” with a bounded result: “In [n] controlled scenarios under [build/device/protocol], no duplicate or missing records were observed.”

Add stable UUIDs, idempotency keys, an outbox, append-only audit events, sync states, device/actor IDs, versioning, conflict UI, and tests for simultaneous edits, duplicate imports, retries, clock skew, deletion/recreation, reinstall/recovery, and partial sync.

## OCR and benchmark audit

ML Kit supports on-device text recognition and documents image-quality requirements. [web:113][web:114][web:115] Separate OCR recognition accuracy, field extraction precision/recall, merchant normalization, category classification, end-to-end transaction correctness, user correction rate, and correction time. Do not report “category mapped” as OCR accuracy.

For every benchmark disclose dataset version, receipt source/consent, image-quality strata, language/platform distribution, ground-truth labeling, annotator agreement, code/model version, device/OS, network, prompt settings, sample size, confidence intervals, and errors. Reconcile the portfolio’s conflicting 50 versus 100 document counts and 150 versus 200 transaction counts.

## FHS formula audit

Audit these problems:

- Full Budget Adherence points when no budget exists rewards non-use; use “not assessed” or reweight.
- Logging consistency is data-entry behavior, not necessarily financial health.
- No-spend days do not prove frugality.
- The 40% category-balance threshold can penalize legitimate rent, food, health, tuition, utilities, or debt.
- Warning decay can punish emergencies, caregiving, income loss, and necessary purchases.
- Savings must distinguish savings from transfers, withdrawals, debt repayment, and movement among own wallets.
- Full and Lightweight modes are not directly comparable.
- Define refunds, transfers, reimbursements, cash, shared expenses, irregular income, missing days, and duplicate records.

Recommended display: (1) data coverage/completeness; (2) tracking behaviors; (3) recorded financial patterns. Use: “This indicator summarizes recorded patterns for the selected period. It is not a credit score, diagnosis, professional financial assessment, or complete measure of financial well-being.”

## LLM architecture correction

Do not claim context injection provides 100% accurate reasoning or that RAG is inherently inferior. Use deterministic code for balances, budgets, arithmetic, and FHS calculations. Give the model only derived facts needed for explanation. Validate all structured output. Keep the model outside the ledger’s source of truth. Replace a 50,000-token accounting rulebook with concise versioned instructions unless benchmarking proves it is necessary.

## Methods and results integrity

A purposive N=30 can support formative usability/feasibility evaluation, not population-wide inference, predictive validity, or causal behavior claims. SUS measures perceived usability, not privacy, accuracy, financial improvement, or long-term adoption. Report mean, median, SD, range, confidence interval, raw distribution, translation method, task completion, errors, and whether participants used the prototype independently or after a guided demo. [web:116]

One expert reviewing a questionnaire is content review, not full psychometric validation. Add multiple reviewers, pilot testing, cognitive interviews, and revision history if feasible.

For qualitative work report interview count, recruitment, duration, language, recording/transcription, coding, coders, disagreement resolution, reflexivity, saturation rationale, and anonymized quotations.

If Chapter III results are simulated, projected, demo-only, or not supported by raw data/logs, rewrite it as a planned evaluation protocol and remove past-tense findings.

## Internal consistency audit

- 31 versus 34 agentic actions: enumerate actual implemented actions and use one count.
- FHS/FHI/Observed FHI: select one primary term.
- SQLCipher: distinguish implemented from future roadmap.
- Remote Config versus proxy: state actual architecture.
- OCR samples: reconcile 50/100 and all benchmark sizes.
- Categorization: separate OCR category rates from overall classification accuracy.
- Offline/local versus Firestore mirror: document opt-in cloud mode and sync boundaries.
- Adviser/chair/instructor names: reconcile all title, approval, acknowledgment, and signature pages.
- “Fully compliant,” “100%,” “first,” “only,” “unique,” and “privacy-preserving”: replace with bounded evidence language.

## Safer thesis title and abstract

### Title

**SmartSpend: Design and Usability Evaluation of an Offline-First, AI-Assisted Personal Financial Tracking Prototype for Selected Users in San Fernando City, La Union**

### Abstract

This study designed and evaluated SmartSpend, an offline-first Android prototype for personal financial tracking among selected parents and early-career young professionals in San Fernando City, La Union. Developed using Flutter and local SQLite storage, the prototype supports manual expense entry, selected multimodal import workflows, configurable budgets, visual analytics, and bounded AI-assisted transaction interpretation and financial education. SmartSpend also includes a transparent, transaction-derived Financial Pattern Indicator that summarizes recorded budgeting, savings, and tracking behaviors in income-aware and lightweight modes. The indicator is not presented as a credit score, clinical assessment, or validated measure of financial well-being.

A mixed-methods descriptive-developmental approach was used. A needs assessment informed feature requirements, while prototype evaluation used task-based testing, the System Usability Scale, and defined technical benchmarks for selected OCR, transaction-parsing, and offline-recovery workflows. Among the purposively selected participants, SmartSpend obtained a mean SUS score of [verified result], indicating [bounded interpretation] under the stated test conditions. Technical findings are reported by dataset, device, test scenario, and ground-truth method. The study concludes that SmartSpend is a feasible prototype for exploring low-friction, locally contextualized expense tracking. Longer and comparative studies are needed to evaluate accuracy across diverse inputs, production privacy controls, and the effects of behavioral features on sustained financial practices.

## Required final response from Kiro/Gemini Notebook

Return:

1. Executive verdict and top ten corrections.
2. Source-by-source claim audit.
3. Current official LLM/API table.
4. Corrected feature-to-research map.
5. Philippine privacy/data-flow assessment.
6. NIST-style AI threat/risk register.
7. FHS construct/formula/fairness assessment.
8. Firestore/offline-sync audit.
9. OCR/LLM benchmark provenance audit.
10. Methods/results integrity audit.
11. Dated competitor audit.
12. Revised thesis chapters and abstract.
13. Exact redline of removed, softened, added, and unresolved claims.
14. Verified APA 7 bibliography with stable URLs, access dates, and exact source passages.

Use five implementation labels: implemented and tested; implemented but not independently tested; simulated/demo-only; planned/roadmap; claimed but not evidenced. Do not issue legal certification. Do not convert a design rationale into evidence of effectiveness.

## Seed sources

- Gemini 3.1 Flash-Lite: https://ai.google.dev/gemini-api/docs/models/gemini-3.1-flash-lite [web:130]
- Gemini 3 guide: https://ai.google.dev/gemini-api/docs/gemini-3 [web:134]
- Gemini rate limits: https://ai.google.dev/gemini-api/docs/rate-limits [web:101]
- Gemini deprecations: https://ai.google.dev/gemini-api/docs/deprecations.md.txt [web:136]
- Structured outputs: https://ai.google.dev/gemini-api/docs/structured-output [web:131]
- Firebase API keys: https://firebase.google.com/docs/projects/api-keys [web:100]
- Firebase security checklist: https://firebase.google.com/support/guides/security-checklist [web:107]
- Firestore offline access: https://firebase.google.com/docs/firestore/manage-data/enable-offline [web:112]
- ML Kit text recognition: https://developers.google.com/ml-kit/vision/text-recognition/v2 [web:113]
- ML Kit Android guidance: https://developers.google.com/ml-kit/vision/text-recognition/v2/android [web:115]
- Philippine NPC breach reporting: https://privacy.gov.ph/breach-reporting/ [web:99]
- Philippine NPC breach procedures: https://privacy.gov.ph/exercising-breach-reporting-procedures/ [web:106]

## Final handoff rule

The receiving research assistant must preserve uncertainty. It must provide a clean corrected report and a redline showing every changed claim. It must never invent missing evidence or silently convert project-reported results into verified findings.
