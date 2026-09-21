# SmartSpend: Comprehensive Comparative Research
## Financial Health Score Systems · AI/LLM Architecture · Global & Philippine Competitor Landscape

**Prepared for:** Pre-Final Defense — Adviser Presentation  
**Research date:** September 21, 2026 *(all competitor statuses verified as of this date)*  
**Group:** Lucid Frame | Lorma Colleges CCSE BSIT 2026–2027, 1st Semester  
**Authors:** Brix A. Directo · Cyrille John M. Rubis · Djaunathan Albert S. Madayag  
**App version:** SmartSpend v2.9.49

> **Evidence note:** Product features, pricing, and availability change frequently. All competitor entries are based on public app-store listings, official product pages, and published reviews as of September 21, 2026. SmartSpend feature statuses are PROJECT-REPORTED from code audit. Where a feature was not found in public review, it is marked "not found in public review (Sep 21, 2026)" rather than "does not exist."

---

## PART 1 — AI & LLM LANDSCAPE

### 1.1 General-Purpose LLMs: Current State (September 2026)

The dominant pattern in 2026 is that **frontier general-purpose models** (Gemini, GPT, Claude) are outperforming domain-specific financial LLMs on most practical tasks, because their breadth, multilingual capability, tool-calling, and context windows have surpassed what specialized models offer. Domain-specific models remain relevant only for institutional tasks (SEC filings, trading signals, risk analysis) — not for consumer personal finance.

| Provider | Model family (current) | Context | Key strength | Relevant to SmartSpend? |
|---|---|---|---|---|
| **Google** | Gemini 3.5 Flash-Lite | 1M tokens | Fast, cheap, agentic, free tier | ✅ Primary model in use |
| **Google** | Gemini 3.5 Flash | 1M tokens | Strong agentic/tool-use (83.6% MCP Atlas), Finance Agent v2 +14.9pts | ✅ Fallback 2 in use |
| **Google** | Gemini 3.7 Flash | 1M tokens | Paid only ($0.75/1M input) — frontier capability | ❌ Cost |
| **OpenAI** | GPT-5.6 / GPT-6 Astra | 256K | Best ecosystem breadth, coding, reasoning | ❌ Paid, no free tier |
| **OpenAI** | GPT-OSS 120B / 20B | 131K | Open-weight, via Groq (free) | ✅ Fallbacks 3, 6 in use |
| **Anthropic** | Claude Fable 5 / Opus 4.8 | 200K | Best for long-document analysis, 10-K reading | ❌ Paid |
| **Alibaba** | Qwen3.6 27B / Qwen3.8 27B | 262K | Strong multilingual, Apache 2.0, via Groq free | ✅ Fallbacks 4, 5 in use |
| **Moonshot AI** | Kimi K3 | 1M | #1 open-weight model (Artificial Analysis), 2.8T MoE | ❌ No permanent free API |
| **DeepSeek** | V4 Flash / Pro | 163K | Cheapest frontier ($0.14/MTok) | ❌ No free daily quota |
| **Mistral** | Large / Small / Codestral | 128K | EU-compliant, free experiment tier | ❌ Not in current chain |

**SmartSpend's 8-provider failover chain (v2.9.49):**

| Priority | Provider | Model ID | Free Daily Limit |
|---|---|---|---|
| 1 | Google AI Studio | `gemini-3.5-flash-lite` | ~500 req/day |
| 2 | Google AI Studio | `gemini-3.5-flash` | ~250 req/day |
| 3 | Groq LPU | `openai/gpt-oss-120b` | 1,000 req/day |
| 4 | Groq LPU | `qwen/qwen3.6-27b` | 1,000 req/day |
| 5 | Groq LPU | `qwen/qwen3.8-27b` | 1,000 req/day |
| 6 | Groq LPU | `openai/gpt-oss-20b` | 1,000 req/day |
| 7 | Groq LPU | `groq/compound-mini` | 250 req/day |
| 8 | Cerebras WSE | `openai/gpt-oss-120b` | 1M tokens/day |

> ⚠️ **Retired:** `gemini-3.1-flash-lite` (returns 404, Sep 2026), `llama-4-scout`, `llama-3.3-70b`, `llama-3.1-8b` (all retired from Groq free/dev tier Feb–Aug 2026).

---

### 1.2 Why Gemini 3.5 Flash-Lite as Primary

Gemini 3.5 Flash-Lite was selected through a structured benchmarking study using 100 localized Taglish expense-parsing prompts. Key rationale:

- **GA stable** since July 21, 2026 — migrated from 3.1 which returned 404s in production (Sep 9, 2026)
- **1M token context window** — SmartSpend's per-user context (50 expenses + budgets + goals) = ~1,000–5,000 tokens, fitting in 0.5% of the window
- **6× cheaper** than Gemini 3.5 Flash; best cost-performance ratio for the short, well-specified expense-parsing tasks that dominate SmartSpend's AI usage
- **Native function calling** — required for SmartSpend's 34 agentic action dispatch
- **Filipino-English multilingual** — tested on Taglish phrases (e.g., "nagbayad ako ng 120 pesos para sa pansit at coke sa Jollibee kanina")
- **Free tier: ~500 req/day** — sufficient for academic deployment

**Why context injection over RAG:**
Per-user data fits entirely in one prompt. RAG adds vector-search latency and fails on multi-hop queries like "Can I afford this given my GCash balance, clothing budget, and savings goal?" — which requires all data points simultaneously in context.

---

### 1.3 Financial-Domain LLMs vs General-Purpose: The Key Distinction

**Critical finding for the manuscript:** Financial-domain LLMs are NOT better for SmartSpend's use case.

| LLM | Type | Primary use | Relevant to SmartSpend? | Why not |
|---|---|---|---|---|
| **BloombergGPT** (Bloomberg, 50B params) | Institutional | Market news, SEC filings, sentiment analysis, trading | ❌ Not relevant | Institutional finance ≠ consumer budgeting; proprietary, no public API |
| **FinGPT** (AI4Finance Foundation, open-source) | Research | Financial sentiment, news analysis, trading signals | ❌ Not relevant | Built for institutional trading research, not Taglish budgeting |
| **FinLlama / finance-tuned variants** | Research | Financial document classification, QA on financial texts | ❌ Not relevant | Not tested for Philippine context, Taglish, or agentic actions |
| **Gemini 3.5 Flash-Lite** (Google, general-purpose) | General + Finance | Taglish parsing, agentic actions, multi-modal | ✅ **In use** | Outperforms domain-specific models on well-structured task-based prompts |
| **GPT-OSS 120B** (OpenAI open-weight, via Groq) | General | Reasoning, fallback | ✅ **In use** | Strong general reasoning, free via Groq |

**Key academic point for manuscript Chapter 3:**
> "Financial-domain LLMs such as BloombergGPT and FinGPT are optimized for institutional tasks — sentiment analysis of SEC filings, market news, and trading signals. They are not designed for, nor tested on, Philippine household budgeting, Taglish conversational input, or agentic financial management. SmartSpend uses frontier general-purpose models because their multilingual capability, instruction-following, and tool-calling performance surpasses what domain-specific financial LLMs offer for consumer personal finance applications."

---

## PART 2 — FINANCIAL HEALTH SCORE COMPARATIVE ANALYSIS

### 2.1 Existing FHS Systems Compared

| System | Publisher | Scale | Input Type | Transparency | Philippine Relevance |
|---|---|---|---|---|---|
| **Financial Health Network FinHealth Score** | FHN (US) | 0–100 | 8 survey indicators | Partially disclosed | Academic foundation — four-pillar structure |
| **CFPB Financial Well-Being Scale** | CFPB (US) | 0–100 | 10-question survey | Standardized scoring table | Same scale concept; measures psychological states |
| **MindsBudget** | MindsBudget (web) | 0–100 | Uploaded bank statements | Component structure disclosed | Closest transaction-based model globally |
| **Wingman Money** | Wingman (AU) | 0–100 | Linked bank accounts | Not publicly disclosed | Closest commercial behavioral FHS — not available PH |
| **BudgetPH / KindlyF** | KindlyF (PH) | 0–850 | User-entered data | Not publicly disclosed | Only direct PH competitor with behavioral score |
| **Alkansya AI** | Alkansya (PH) | 0–100 (claimed) | Transactions | Not publicly disclosed | Philippine competitor with claimed FHS |
| **Artha Engine** | Artha (India) | 0–100 | Income, debt, savings, investments | Weighted formula disclosed | Broader, investment-oriented |
| **SmartSpend (Full Mode)** | Lucid Frame (PH) | 0–100 | Recorded transactions + income | **Fully disclosed** | Offline, dual-mode, Filipino context |
| **SmartSpend (Lightweight Mode)** | Lucid Frame (PH) | 0–100 | Spending behavior only | **Fully disclosed** | For students, irregular-income users |

---

### 2.2 SmartSpend FHS Formula — Current (v2.9.49, updated from v2.9.42)

#### Full Mode — 4 components × 25 pts = 100 max

**C₁ — Savings Rate:**
$$C_1 = 25 \times \min\!\left(1,\ \frac{\text{Income} - \text{Spent}}{\text{Income} \times 0.20}\right)$$
Full 25 pts when saving ≥ 20% of income. *Basis: Warren & Tyagi (2005) 50/30/20 rule.*

**C₂ — Overspend Control** *(v2.9.39 update — one-off purchase nuance):*
$$C_2 = 25 \times \left(1 - \frac{\text{hardOverDays} + \text{softOverDays} \times 0.5}{\text{activeDays}}\right)$$
- **hardOverDays** = scattered multi-item overspend (full penalty)
- **softOverDays** = single large planned purchase caused overspend (0.5× reduced penalty)

**C₃ — Budget Adherence** *(v2.9.42 update — essential category exemption):*
$$C_3 = 25 \times \frac{\text{on-track discretionary categories}}{\text{total discretionary budgets}}$$
**Bills, Health, and Education excluded** from penalty — essential costs don't unfairly reduce score.

**C₄ — Logging Consistency:**
$$C_4 = 25 \times \min\!\left(1,\ \frac{\text{loggedDays}}{\text{activeDays}}\right)$$
Current month only; grace period for mid-month starters.

#### Lightweight Mode (for students/informal workers)

| Component | Measures | Key formula element |
|---|---|---|
| Spending Restraint | vs spending limit | Full pts at ≤80% of limit |
| Logging Consistency | Same as Full Mode | loggedDays / activeDays |
| Category Balance | No single category > 40% | Penalty when top category > 40% |
| Habit Streak | Consecutive logged days | Full pts at 14-day streak |

#### Behavioral Adjustments *(v2.9.42: discretionary-only)*

| Adjustment | Trigger | Formula |
|---|---|---|
| Warning Decay | Budget exceeded + spending continues (discretionary only) | -5 pts/day, max -15 |
| Gap Penalty | Unlogged days + user confirmed spending occurred | -3 pts/day, max -15 |
| Gap Bonus | Unlogged days + user confirmed no-spend | +2 pts/day, max +10 |

**Score labels (from code):** 90+ = Excellent 👑 · 80–89 = Great 🏆 · 70–79 = Good ⭐ · 60–69 = Fair 🌱 · <60 = Needs Work 📉

#### Theoretical framework

SmartSpend's FHS is a **Prototype Observed Financial Health Indicator (FHI)** per:
- CBA-MI (2018) dual-scale model — distinguishes Observed (transaction-derived) from Reported (survey-based)
- UNSGSA (2021) guidelines for FHI design
- FHN (2018) four-pillar conceptual framework

It is **NOT** validated by the CFPB scale (which measures psychological well-being states, not behavioral transaction outcomes).

---

### 2.3 Summary Comparison Table

| Dimension | SmartSpend | MindsBudget | Wingman | BudgetPH | Alkansya AI | FinHealth Score |
|---|:-:|:-:|:-:|:-:|:-:|:-:|
| Transaction-based (no survey) | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ survey |
| Fully disclosed formula | ✅ | Partial | ❌ | ❌ | ❌ | Partial |
| Offline computation | ✅ | ✅ | ❌ | ✅ | ❌ | N/A |
| No bank API | ✅ | ✅ | ❌ | ✅ | Unknown | N/A |
| Dual-mode (regular + irregular income) | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Philippine / Filipino context | ✅ | ❌ | ❌ | ✅ | ✅ | ❌ |
| Essential category exemption | ✅ v2.9.42 | Unknown | Unknown | Unknown | Unknown | ❌ |
| Mobile-first, free | ✅ | ❌ web | ❌ paid | ✅ | ✅ | N/A |

---

## PART 3 — GLOBAL APP COMPETITOR ANALYSIS

### 3.1 Tier 1 — Direct AI Financial Management Competitors

#### ChatGPT Personal Finance (OpenAI)
- **Launched:** May 15, 2026
- **Platform:** iOS/Android (US only, ChatGPT Pro subscribers)
- **How it works:** Links bank/credit card/brokerage accounts via Plaid (12,000+ institutions); GPT-5.5 answers spending questions grounded in real account data; shows spending dashboard, flags subscriptions, tracks bills
- **SmartSpend comparison:** ChatGPT Finance is US-only via Plaid — no Philippine bank support. Requires paid ChatGPT Pro subscription. SmartSpend works offline, free, with Filipino-specific banks and e-wallets.

#### Cleo 3.0 + Autopilot (US/UK)
- **Updated:** Cleo 3.0 (July 2026) — now **fully agentic** (multi-step task execution, memory, real-time voice)
- **Autopilot feature (2026):** Creates a long-term financial roadmap, daily personalized plans, and will execute financial actions automatically
- **Architecture:** Multi-agent system; background agent monitors transaction history; "roast mode" for spending shame gamification
- **SmartSpend comparison:** Cleo is the strongest direct AI agentic finance competitor globally. Key differences: Cleo is US/UK only, requires bank account link, no offline mode, no Filipino context, no FHS. SmartSpend's 34 agentic actions are narrower but work fully offline without bank API.

#### Origin (US)
- **Description:** All-in-one: budgeting, net worth, investments, credit, tax filing, estate planning, couples visibility
- **AI Advisor:** Scored 98.3% on CFP® exam (6,000 questions); multi-agent architecture using Claude 4.1 Opus + GPT + Gemini + Perplexity; SEC-registered; 138-check compliance framework
- **SmartSpend comparison:** Origin is the strongest global AI financial advisor. Not available in Philippines. SmartSpend is not a licensed advisor — it explicitly disclaims this. Origin represents the global frontier that SmartSpend cannot claim to match on advisory depth.

#### Rocket Money + Rowan (US)
- **Rowan:** Text/SMS-based AI that scans accounts, negotiates bills, cancels subscriptions, warns about upcoming charges
- **SmartSpend comparison:** Rowan validates the concept of proactive agentic finance. US bank API required. SmartSpend's detect_subscriptions action is the equivalent approach without SMS.

---

### 3.2 Tier 2 — Strong Global AI Competitors

| App | Platform | Key AI feature | SmartSpend comparison |
|---|---|---|---|
| **Monarch Money** | iOS/Android/Web | AI Q&A from own data (2026); receipt scanning; Goals 3.0 | Paid $9.99/mo; US bank API required; no offline; no PH context |
| **Quicken Simplifi** | iOS/Android/Web | AI Chat with financial data + knowledge + web search | Paid $3.99/mo; US bank API; #1 PCMag 2026 |
| **Finanzya** | Multi-platform | 96% auto-categorization; FIRE/retirement forecast; 31 currencies; private | No PH-specific features; no offline; not free |
| **YNAB** | All platforms | Zero-based budgeting; AI category suggestions; transaction export | $14.99/mo; US bank API; no offline; no PH context |
| **Copilot Money** | iOS only | AI auto-categorization | iOS-only; paid; US bank API |
| **Empower** | iOS/Android/Web | Investment tracking; portfolio analysis; net worth | US bank API; investment-focused |
| **Goodbudget** | Android/iOS/Web | Envelope budgeting; household sharing | No AI; manual-entry; available in PH |

---

### 3.3 Tier 3 — Non-AI Global Comparators (Available in Philippines)

| App | Key feature | Why included |
|---|---|---|
| **Money Manager (Realbyte)** | Multi-platform expense tracking; wallets; charts | Widely used in PH; no AI |
| **Monefy** | Simple one-tap expense tracking | Ultra-lightweight; offline; no AI |
| **Spendee** | Shared wallets; budgets; bank sync optional | Available PH; light AI categorization |
| **Goodbudget** | Envelope budgeting; household sharing | Mentioned in Globe PH recommendations |
| **Money Lover** | Expense tracking; bills; multi-currency | Popular in Southeast Asia |

---

## PART 4 — PHILIPPINE & FILIPINO-CONTEXT COMPETITOR ANALYSIS

### 4.1 Direct Philippine Competitors — Full Matrix

| Feature | **SmartSpend v2.9.49** | **Agila v1.2.7** | **BudgetPH** | **Tarsi** | **GCash Pera Coach** | **Alkansya AI** | **PISO Budget** | **Sentimo** |
|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| **Platform** | Android | Android + iOS | Android/PWA | Android + iOS | Android (GCash) | iOS + Android | Android | Android |
| **Price** | Free | Free (cosmetic IAP) | Free | Paid (₱) | Free (GCash req.) | Free | Free | Free |
| **AI chat / agentic** | ✅ 34 actions | ⚠️ Chat logging | ⚠️ Insights only | ⚠️ NLP entry | ✅ Q&A literacy | ⚠️ NLP entry + FHS | ❌ | ❌ |
| **Voice input** | ✅ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |
| **OCR receipt scan** | ✅ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Barcode scanning** | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Batch screenshots (40+)** | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Financial Health Score** | ✅ 0–100 dual-mode | ❌ | ✅ 0–850 budget score | ❌ | ❌ | ✅ 0–100 (claimed) | ❌ | ❌ |
| **Full formula disclosed** | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Offline mode** | ✅ Full | ✅ | ✅ | ✅ | ❌ | ❌ | ✅ | ❌ |
| **Cloud sync** | ✅ Firebase | ✅ Optional | ✅ | ❌ | ✅ GCash | ❌ | ❌ | ❌ |
| **Taglish / Filipino AI** | ✅ Full | Unknown | ❌ | ✅ Natural language PH | ✅ Multi-language | ✅ Filipino context | ❌ | ❌ |
| **GCash / Maya tracking** | ✅ Wallet + import | ❌ | ✅ CSV import | Unknown | ✅ GCash balance | ❌ | ❌ | ❌ |
| **SSS/PhilHealth/Pag-IBIG** | ✅ AI compute + tracker | ❌ | ✅ Records | ⚠️ (user requests) | ❌ | ❌ | ❌ | ❌ |
| **Paluwagan** | ✅ v2.9.35 | ❌ | ✅ Full | ❌ | ❌ | ❌ | ❌ | ❌ |
| **15th/30th payday cycle** | ❌ | ❌ | ✅ Core | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Gamification** | ✅ 25 badges + 10 quests | ⚠️ Monthly Wrapped | ✅ XP/levels | ❌ | ❌ | ❌ | ❌ | ✅ KBoy mascot |
| **Business profile** | ❌ | ✅ Full (unique) | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Installment / BNPL** | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Import from other apps** | ❌ | ✅ (Money Manager etc.) | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **App Lock** | ✅ PIN + biometric | ❌ | ❌ | ❌ | ✅ GCash PIN | ❌ | ❌ | ❌ |
| **RA 10173 PII redaction** | ✅ v2.9.42 | Unknown | Unknown | Unknown | Unknown | Unknown | N/A | Unknown |

---

### 4.2 Additional Philippine Apps Found (Sep 21, 2026)

These are smaller or niche apps that round out the Philippine landscape:

| App | Focus | Key distinction | Relevance to SmartSpend |
|---|---|---|---|
| **Moneygment** | Bills payment, SSS/PhilHealth/Pag-IBIG contributions, money transfer | Primarily a **payments/contributions** tool, not an expense tracker | Low overlap — different core use case |
| **Alkansya AI** | AI-assisted Filipino expense tracking with FHS | Has a Financial Health Score (0–100); iOS + Android | ⚠️ **Direct FHS competitor** — only other PH app claiming an FHS |
| **Kitang-kita** | Business + personal budgeting, free | Built for Filipino businesses; plans to add personal budgeting | Low overlap currently |
| **KitaFlow** | Freelancer-focused; Philippine 8% income tax estimate | Targets BIR simplified income tax for freelancers | Niche overlap on BIR computation |
| **Tarsi** | AI/NLP expense entry, voice, OCR receipts, offline, mascot | **#1 Paid Finance App in Philippines, March 2026** (App Store) | ⚠️ **Direct competitor** — voice + OCR + offline + NLP similar to SmartSpend |
| **TipidMate** | Income, expenses, goals, credit cards, debts, trends | Clean dashboard; no AI | Low threat — basic tracker |
| **Budqo** | Envelope budgeting for couples/solo earners | Paper-feel UX; "Escape Plan" debt payoff | Niche (couples); no AI |
| **MoneyGlow** | Financial literacy for Filipino digital creators | AI money advice for content creators/freelancers | Niche; advisory only |
| **Finnest PH** | Savings tracker with simulated interest growth | Savings-focused; Apple App Store PH | Low overlap |
| **Kaya PH** | Group debt splitting and balance tracking | Peer-to-peer debt clarity; not a full PFM | Low overlap |
| **Lista PH** | Weekly/monthly/bi-monthly budgets; credit score access | Credit score via partner bureaus | Indirect competitor on credit context |
| **SweldoWise / SweldoTrack** | Payday-cycle tracking, MP2 contributions | Niche salary-cycle apps | Payday cycle overlap |

---

### 4.3 Tarsi — New High-Priority Competitor

**Tarsi** reached #1 Paid App AND #1 Finance App in the Philippines App Store in March 2026 within 48 hours of release. This makes it the most directly comparable Filipino indie app to SmartSpend.

| Feature | Tarsi | SmartSpend |
|---|---|---|
| Voice input | ✅ (NLP: "Starbucks 250") | ✅ |
| OCR receipt scan | ✅ | ✅ |
| Offline mode | ✅ Full | ✅ Full |
| Financial Health Score | ❌ | ✅ 0–100 dual-mode |
| Cloud sync | ❌ | ✅ Firebase |
| Agentic AI (34 actions) | ❌ (NLP entry only) | ✅ |
| Batch screenshot import | ❌ | ✅ 40+ platforms |
| Gamification | ❌ | ✅ 25 badges + quests |
| Free | ❌ (paid) | ✅ Always free |
| SSS/PhilHealth/Pag-IBIG | ⚠️ user requests | ✅ AI compute + tracker |
| Mascot | ✅ Tarsi mascot | ❌ |
| iOS support | ✅ | ❌ Android only |

**Assessment:** Tarsi is the strongest Filipino competitor for the voice/OCR/offline use case, but lacks the Financial Health Score, cloud sync, agentic AI depth, gamification, and free pricing that SmartSpend offers. Must be included in the manuscript competitor table.

---

### 4.4 Alkansya AI — Second FHS Competitor

**Alkansya AI** (alkansya.online) explicitly claims to compute a Financial Health Score and provide spending analysis for Filipino users. This makes it the **only other Philippine app with a comparable FHS** besides BudgetPH.

| Feature | Alkansya AI | SmartSpend |
|---|---|---|
| FHS / Financial Health Score | ✅ Claimed (exact formula not disclosed) | ✅ Fully disclosed formula |
| AI chat for expense entry | ✅ | ✅ 34 agentic actions |
| Platform | iOS + Android | Android only |
| Offline | Unknown | ✅ Full |
| Formula transparency | ❌ Not disclosed | ✅ Fully documented |
| Dual-mode (full/lightweight) | ❌ | ✅ |
| Free | ✅ | ✅ |

**Assessment:** Alkansya AI's undisclosed FHS formula means SmartSpend's fully documented formula is a genuine academic differentiator. This should be highlighted in the manuscript.

---

### 4.5 GCash Pera Coach — Critical Distinction

**Launched:** March 20, 2026. Developed with Microsoft. Philippines' first AI financial coach embedded in an e-wallet.

| Aspect | GCash Pera Coach | SmartSpend |
|---|---|---|
| Purpose | Financial literacy coaching — teaches concepts | Financial management — tracks and manages behavior |
| Expense tracking | ❌ No tracking | ✅ Full tracking |
| Financial Health Score | ❌ | ✅ 0–100 four-component |
| Offline capability | ❌ | ✅ Full SQLite local |
| Agentic actions | ❌ Q&A only | ✅ 34 actions |
| Multi-modal input | ❌ Text only | ✅ Voice, OCR, barcode, batch screenshots |
| Language support | ✅ English + Tagalog + Filipino languages | ✅ Taglish/English |
| Access requirement | GCash Fully Verified account | Any Android device |

**Panel answer:** Pera Coach teaches financial concepts. SmartSpend tracks and manages actual spending behavior. They solve different problems for different user needs — they complement rather than directly compete.

---

## PART 5 — SmartSpend COMPETITIVE POSITIONING

### 5.1 Where SmartSpend Leads (Defensible, Evidence-Based)

| Advantage | Evidence |
|---|---|
| Only free Taglish agentic AI on Android | 34 autonomous actions not found in any reviewed Philippine app; Tarsi and Alkansya have NLP entry only |
| Only app with batch screenshot import | 40+ platforms not found in any reviewed app globally or locally |
| Dual-mode FHS (full + lightweight) | No equivalent found in any reviewed system — unique design for irregular-income users |
| Only offline + cloud sync + free | BudgetPH/PISO/Tarsi offline-only; cloud apps require internet |
| Only fully documented FHS formula | BudgetPH, Alkansya AI, Wingman all do not disclose exact formula |
| RA 10173 PII redaction before LLM | Mobile numbers and reference numbers stripped before any cloud transmission |
| Gamification depth | 25 badges + 10 daily quests — most found in any reviewed PH app |
| 10 color themes + full UI customization | Not found in any reviewed PH competitor |

### 5.2 Where SmartSpend Has Gaps (Honest Assessment)

| Gap | Who has it | Notes |
|---|---|---|
| 15th/30th payday cycle budgeting | BudgetPH (core feature), PISO, SweldoWise | Planned post-capstone |
| Business profile (invoices, inventory) | **Agila** — unique among PH apps | Post-capstone |
| iOS support | Tarsi, Agila, Alkansya AI, most global apps | Flutter supports iOS; post-capstone |
| Import from other PFM apps | Agila (Money Manager, Bluecoins) | Post-capstone |
| Safe-to-Spend number | BudgetPH (core concept) | Post-capstone |
| Mascot / personality layer | Tarsi (Tarsi mascot), Sentimo (KBoy carabao) | Post-capstone |
| FIRE / retirement calculator | Finanzya, Origin, Empower | Post-capstone |

### 5.3 Recommended Positioning Statement

> "SmartSpend is an offline-first, Philippine-context personal finance prototype evaluated among selected users in La Union. It investigates the integration of Taglish-aware multi-modal input, transparent transaction-derived financial-pattern feedback (FHS), deterministic local financial calculations, and bounded agentic AI assistance — in which proposed data actions are validated by software and confirmed by the user — within a free, zero-subscription mobile application designed for Android."

---

## PART 6 — CLAIMS TO AVOID / REPLACE

| ❌ Do not claim | ✅ Replace with |
|---|---|
| "First Filipino-English agentic financial app" | "Among publicly reviewed Philippine applications as of September 2026, no equivalent combination of Taglish-aware agentic AI and offline-first financial management was found" |
| "Only offline financial tracker in PH" | "Among reviewed apps, SmartSpend combines full offline capability with optional cloud sync at no subscription cost" |
| "No Philippine app has AI money coaching" | "GCash Pera Coach provides AI-assisted financial literacy coaching; Tarsi and Alkansya AI provide NLP-assisted expense entry; SmartSpend addresses the distinct need for offline agentic financial management" |
| "23 earnable badges" | **25 earnable badges** |
| "31 agentic actions" | **34 agentic actions** |
| "60 messages/day limit" | **150 messages/day across 8 providers** |
| "5 color themes" | **10 color themes** |
| "Gemini 3.1 Flash-Lite" | **Gemini 3.5 Flash-Lite** (migrated Sep 10, 2026) |
| Any LLaMA model in fallback chain | **Retired — return 404 on this account since Feb–Aug 2026** |
| "FHS validated by CFPB scale" | "FHS is a Prototype Observed Financial Health Indicator per CBA-MI (2018) and UNSGSA (2021)" |
| "100% security / 100% compliance" | "Implements RA 10173 PII redaction and standard mobile security practices; full external audit not conducted" |

---

## PART 7 — BIBLIOGRAPHY (Key Sources, APA 7)

*Content paraphrased for compliance with licensing restrictions. All URLs verified September 21, 2026.*

**AI/LLM:**
- Google. (2026). *Gemini 3.5 Flash-Lite model documentation*. https://ai.google.dev/gemini-api/docs/models/gemini-3.5-flash-lite
- Google. (2026). *Gemini 3.5 Flash model documentation*. https://ai.google.dev/gemini-api/docs/models
- OpenAI. (2026, May 15). *A new personal finance experience in ChatGPT*. https://openai.com/index/personal-finance-chatgpt/
- Cleo. (2026). *Introducing Cleo 3.0*. https://web.meetcleo.com/blog/Introducing-cleo-3-0
- Origin. (2026). *How accurate is AI Advisor?* https://support.useorigin.com/hc/en-us/articles/39416756786061
- Liu, X., et al. (2023). *FinGPT: Open-source financial large language models*. arXiv:2306.06031
- Wu, S., et al. (2023). *BloombergGPT: A large language model for finance*. arXiv:2303.17564
- Xu, R., et al. (2026). *Evaluation and benchmarking suite for financial LLMs*. OpenReview.

**Philippine Competitors:**
- Agila. (2026, Sep). *App Store listing — Agila: Finance Coach*. https://apps.apple.com/us/app/agila-finance-coach/id6765464814
- BudgetPH. (2026). *BudgetPH — The budgeting app for Filipinos*. https://budget.kindlyf.com/
- GCash / Mynt. (2026, March 20). *GCash launches Philippines' first AI financial coach*. PR Newswire. https://www.prnewswire.com/...
- Lim, B. (2026, March). *Tarsi budget tracker* [Android + iOS app]. https://www.tarsi.cloud/
- Alkansya. (2026). *Alkansya AI — Filipino expense tracker with FHS*. https://alkansya.online/
- PISO Budget Tracker. (2026). *P1SO Budget Tracker*. https://pisobudget.com/

**FHS Academic Foundations:**
- Warren, E., & Tyagi, A. W. (2005). *All your worth: The ultimate lifetime money plan*. Free Press.
- Financial Health Network. (2018). *FinHealth Score methodology*. https://finhealthnetwork.org
- Commonwealth Bank of Australia & Melbourne Institute. (2018). *Financial wellbeing: A survey of adults in Australia*. CBA-MI.
- United Nations Secretary-General's Special Advocate (UNSGSA). (2021). *Financial health and inclusion guidance*. UNSGSA.
- Sharma, A., Gaba, P., & Sharma, P. (2026). *Gamification and nudge-based digital financial well-being*. Atlantis Press. [N=656, β_nudge=0.28, β_gamification=0.25, R²=0.56]
- Deci, E. L., & Ryan, R. M. (2000). Self-determination theory and the facilitation of intrinsic motivation. *American Psychologist, 55*(1), 68–78.
- Thaler, R. H., & Sunstein, C. R. (2008). *Nudge: Improving decisions about health, wealth, and happiness*. Yale University Press.

---

*Document compiled September 21, 2026 by Kiro IDE.*
*Research conducted September 21, 2026 — all competitor and model statuses verified on this date.*
*Content paraphrased for compliance with licensing restrictions. Competitor features from public app-store listings and official product pages.*
*Previous version: SmartSpend_Comparative_Research_Updated_Sep2026.md (Sep 12, 2026).*
