# SmartSpend: Updated Comparative Research
## Financial Health Score Systems, AI/LLM Architecture, and Philippine Competitor Landscape

**Prepared for:** Pre-Final Defense — Adviser Presentation  
**Date:** September 12, 2026  
**Group:** Lucid Frame | Lorma Colleges CCSE BSIT 2026–2027, 1st Semester  
**Authors:** Brix A. Directo · Cyrille John M. Rubis · Djaunathan Albert S. Madayag  
**App version covered:** SmartSpend v2.9.49

> This document consolidates and updates the comparative research from the original DOCX (Comparative Research on Financial Health Scores, September 2026) with corrections from the v2.9.42–v2.9.49 code changes, updated competitor intelligence, and the current AI/LLM architecture.

---

## Part 1 — Financial Health Score: Comparative Analysis

### 1.1 Overview of Existing FHS Systems

| System | Publisher | Scale | Input Type | Formula Transparency | Philippine Relevance |
|--------|-----------|-------|-----------|----------------------|---------------------|
| **Financial Health Network (FinHealth Score)** | FHN (US) | 0–100 | 8 survey indicators | Partially disclosed | Academic foundation — four-pillar structure |
| **CFPB Financial Well-Being Scale** | CFPB (US) | 0–100 | 10-question survey | Standardized table | Same scale concept; survey-based |
| **MindsBudget** | MindsBudget (web) | 0–100 | Uploaded bank statements | Component structure disclosed | Closest transaction-based model globally |
| **Wingman Money** | Wingman (Australia) | 0–100 | Linked bank accounts | Limited public disclosure | Closest commercial behavioral model |
| **BudgetPH / KindlyF** | KindlyF (Philippines) | 0–850 | User-entered transactions | Limited public disclosure | Only direct Philippine competitor with FHS |
| **Artha Engine** | Artha (India) | 0–100 | Income, debt, savings, investments | Weighted formula disclosed | Broader, investment-oriented |
| **SmartSpend (Full Mode)** | Lucid Frame (Philippines) | 0–100 | Recorded transactions + income | **Fully disclosed** | Offline, dual-mode, Filipino context |
| **SmartSpend (Lightweight Mode)** | Lucid Frame (Philippines) | 0–100 | Spending behavior + optional limits | **Fully disclosed** | For irregular-income / student users |

---

### 1.2 SmartSpend FHS Formula — Current (v2.9.42+)

The FHS is computed as four equally weighted components (25 pts each), with behavioral adjustments applied after.

#### Full Mode (income tracking ON)

**Component 1 — Savings Rate (25 pts)**
$$C_1 = 25 \times \min\!\left(1,\ \frac{\text{Savings Rate}}{0.20}\right)$$
$$\text{where Savings Rate} = \frac{\text{Monthly Income} - \text{Total Spent}}{\text{Monthly Income}}$$
Full 25 pts when saving ≥ 20% of income. Academic basis: Warren & Tyagi (2005) 50/30/20 rule.

**Component 2 — Overspend Control (25 pts)**  *(Updated v2.9.39 — one-off purchase nuance)*
$$C_2 = 25 \times \left(1 - \frac{\text{hardOverDays} + \text{softOverDays} \times 0.5}{\text{Active Days}}\right)$$
- **hardOverDays** = days with scattered multi-item overspend (full 1× penalty)
- **softOverDays** = days where a single large one-off item caused the overspend (0.5× reduced penalty — e.g., gadgets, concert tickets)

This nuance acknowledges that a planned large purchase is behaviorally different from habitual daily overspending.

**Component 3 — Budget Adherence (25 pts)** *(Updated v2.9.42 — essential category exemption)*
$$C_3 = 25 \times \frac{\text{On-Track Discretionary Categories}}{\text{Total Discretionary Budgets}}$$
- **Bills, Health, and Education** are excluded from the 40% concentration check and from the adherence penalty
- Rationale: A student whose tuition dominates spending should not lose budget adherence points for a necessary cost

If no budgets configured → full 25 pts (not penalized for not setting budgets).

**Component 4 — Logging Consistency (25 pts)**
$$C_4 = 25 \times \min\!\left(1,\ \frac{\text{Logged Days}}{\text{Active Days}}\right)$$
Current month only. Mid-month grace for late starters. Bulk-entry fairness cap.

**Full Mode Raw Score:**
$$\text{Raw FHS} = C_1 + C_2 + C_3 + C_4 \quad (0\text{–}100)$$

---

#### Lightweight Mode (income tracking OFF — for students, freelancers)

| Component | What it measures | Formula |
|-----------|-----------------|---------|
| **Spending Restraint** | vs self-set spending limit | $25 \times \max(0, 1 - \frac{\text{Ratio} - 0.8}{1.2})$ where Ratio = Spent/Limit |
| **Logging Consistency** | Same as Full Mode | $25 \times \min(1, \text{Logged}/\text{Active})$ |
| **Category Balance** | No single discretionary category > 40% of total | $25 \times \max(0, 1 - \frac{\text{TopRatio} - 0.4}{0.6})$ |
| **Habit Streak** | Consecutive logged days (full at 14 days) | $25 \times \min(1, \text{Streak}/14)$ |

> **Key design rationale:** Lightweight Mode allows SmartSpend to give a meaningful FHS to users without predictable income — addressing a critical gap for Filipino students and informal workers that no other reviewed system handles.

---

#### Behavioral Adjustments (Both Modes) *(Updated v2.9.42 — essential category exemptions)*

**Warning Decay** *(only fires for discretionary budget overruns)*
$$\text{Decay Penalty} = \min(\text{Decay Days}, 3) \times 5 \quad \text{(max −15 pts)}$$
Does NOT fire when only Bills, Health, or Education budgets are exceeded (medical emergency, tuition spike, utility bill).

**Gap Adjustment**
- Confirmed spending but forgot to log: $-3$ pts/day (max $-15$)
- Confirmed genuine no-spend days: $+2$ pts/day (max $+10$)

**Final Score:**
$$\text{Final FHS} = \max(0, \min(100, \text{Raw FHS} - \text{Decay} - \text{Gap Penalty} + \text{Gap Bonus}))$$

---

#### Score Classification (as implemented in code — `home_screen.dart`)

| Score | Label | Emoji |
|-------|-------|-------|
| 90–100 | Excellent | 👑 |
| 80–89 | Great | 🏆 |
| 70–79 | Good | ⭐ |
| 60–69 | Fair | 🌱 |
| < 60 | Needs Work | 📉 |

---

### 1.3 How SmartSpend's FHS Relates to Existing Systems

| Dimension | SmartSpend | Closest match |
|-----------|-----------|---------------|
| Scale | 0–100 | All reviewed systems |
| Input type | Recorded transactions (no survey, no bank API) | MindsBudget |
| Four-pillar structure | Spend, Overspend, Budget, Consistency | FinHealth Score (FHN) |
| Behavioral daily focus | Yes | Wingman Money |
| Philippine/Filipino context | Yes (only) | BudgetPH |
| Dual-mode (regular + irregular income) | Yes (unique) | No existing system |
| Fully documented formula | Yes (unique among commercial apps) | Artha Engine |
| Offline computation | Yes | MindsBudget |
| No bank API required | Yes | MindsBudget, BudgetPH |

**Recommended positioning for manuscript:**

> SmartSpend's Financial Health Score is a **Prototype Observed Financial Health Indicator** — computed deterministically from recorded transaction data, not from survey responses. Its design is informed by the Financial Health Network (FHN, 2018) four-pillar framework and the Commonwealth Bank of Australia–Melbourne Institute (CBA-MI, 2018) dual-scale model distinguishing *observed* (transaction-derived) from *reported* (survey-based) financial well-being indicators. It is not validated by the CFPB scale, which measures psychological states rather than behavioral transaction outcomes.

---

## Part 2 — AI / LLM Architecture: Current State (v2.9.49)

### 2.1 Multi-Provider Fallover Chain

SmartSpend uses **dynamic full-context injection** — not RAG — with an 8-provider automatic failover:

| Priority | Provider | Model ID | Daily Limit (Free) | Best For |
|---|---|---|---|---|
| 1 | Google AI Studio | `gemini-3.5-flash-lite` | ~500 req/day | Default — all tasks, low latency |
| 2 | Google AI Studio | `gemini-3.5-flash` | ~250 req/day | Complex queries, financial advice |
| 3 | Groq LPU | `openai/gpt-oss-120b` | 1,000 req/day | Best quality on Groq |
| 4 | Groq LPU | `qwen/qwen3.6-27b` | 1,000 req/day | Multimodal reasoning fallback |
| 5 | Groq LPU | `qwen/qwen3.8-27b` | 1,000 req/day | Newer Qwen fallback |
| 6 | Groq LPU | `openai/gpt-oss-20b` | 1,000 req/day | Lighter fallback |
| 7 | Groq LPU | `groq/compound-mini` | 250 req/day | Last Groq resort |
| 8 | Cerebras WSE | `openai/gpt-oss-120b` | 1M tokens/day | Token overflow, ~3,000 t/s |

> ⚠️ **Retired (return 404):** `gemini-3.1-flash-lite` (migrated Sep 10, 2026), `llama-4-scout`, `llama-3.3-70b`, `llama-3.1-8b` (all retired from Groq free/dev tier Feb–Aug 2026).

**Why Gemini 3.5 Flash-Lite as primary:**
- GA stable (released July 21, 2026) — migrated from 3.1 which began returning 404s
- Sub-second latency for expense parsing
- Native function calling and structured output
- 1M-token context window
- Best Filipino-English performance among free models tested
- ~500 requests/day free — sufficient for academic deployment

**Why context injection over RAG:**
Per-user data (50 expenses, 10 budgets, 5 goals) = ~1,000–5,000 tokens — fits in 0.5% of Gemini's 1M context window. RAG adds latency and fails on multi-hop queries like "Can I afford this given my GCash balance, clothing budget, and savings goal?" — which requires all data points simultaneously.

### 2.2 Task-Based Model Routing

| Tier | Use case | Model |
|------|----------|-------|
| `fast` | Expense parsing, simple Q&A | `gemini-3.5-flash-lite` |
| `smart` | Analysis, planning, complex queries | `gemini-3.5-flash` or `openai/gpt-oss-120b` |
| `financial_advice` | SSS/tax/debt strategy, investment advice | `gemini-3.5-flash` (best reasoning) |

### 2.3 34 Agentic Actions

SmartSpend implements 34 autonomous AI actions across 9 categories:

| Category | Actions |
|----------|---------|
| Expenses | `log_expense`, `update_expense`, `delete_expense`, `delete_by_date` |
| Income & Wallets | `set_income`, `add_income`, `set_wallet_balance`, `transfer_wallet` |
| Budgets | `set_budget` |
| Goals | `add_goal`, `update_goal`, `delete_goal` |
| Debts | `add_debt`, `update_debt` |
| Recurring | `add_recurring`, `delete_recurring` |
| Payment Plans | `add_installment_plan` |
| Analysis & Advisory | `plan_salary_split`, `analyze_goal_feasibility`, `suggest_debt_payoff`, `generate_monthly_plan`, `compare_periods`, `explain_fhs_breakdown`, `project_savings_timeline`, `detect_subscriptions`, `compute_contribution`, `suggest_idle_money`, `suggest_expense_cuts`, `simulate_what_if`, `create_debt_payment_plan`, `split_expense` |
| Settings | `set_spending_limit`, `add_insurance_policy`, `set_account_type` |

---

## Part 3 — Philippine Competitor Landscape (September 2026)

### 3.1 Full Competitor Matrix

| Feature | **SmartSpend v2.9.49** | **Agila v1.2.7** | **BudgetPH** | **GCash Pera Coach** | **PISO Budget** | **Sentimo** | **Lista PH** | **Kibo** |
|---------|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| **Platform** | Android | Android + iOS | Android / PWA | Android (inside GCash) | Android | Android | Android | Android |
| **Price** | Free | Free (cosmetic IAP) | Free | Free (GCash required) | Free | Free | Free | Free |
| **AI chat / agentic actions** | ✅ 34 actions | ⚠️ Chat logging only | ⚠️ Insights only | ✅ Q&A + literacy | ❌ | ❌ | ❌ | ⚠️ AI categorization |
| **Natural language / Taglish input** | ✅ Full Taglish | Unknown | ❌ | ✅ Taglish + Filipino | ❌ | ❌ | ❌ | ❌ |
| **Voice input** | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **OCR receipt scanning** | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| **Barcode scanning** | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Batch screenshot import (40+)** | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Financial Health Score (FHS)** | ✅ Dual-mode 0–100 | ❌ | ✅ Budget score 0–850 | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Offline mode** | ✅ Full | ✅ | ✅ | ❌ | ✅ | ❌ | ✅ | ✅ |
| **Cloud sync** | ✅ Firebase | ✅ Optional | ✅ | ✅ GCash | ❌ | ❌ | ❌ | ❌ |
| **GCash / Maya tracking** | ✅ Wallet + import | ❌ | ✅ CSV import | ✅ GCash balance | ❌ | ❌ | ❌ | ⚠️ Alerts |
| **SSS / PhilHealth / Pag-IBIG** | ✅ Tracker + AI | ❌ | ✅ Records | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Paluwagan tracker** | ✅ v2.9.35 | ❌ | ✅ Full | ❌ | ❌ | ❌ | ❌ | ❌ |
| **15th/30th payday cycle** | ❌ | ❌ | ✅ Core feature | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Gamification (badges/quests)** | ✅ 25 badges, 10 quests | ⚠️ Monthly Wrapped | ✅ XP/levels | ❌ | ❌ | ✅ KBoy mascot | ❌ | ❌ |
| **Business profile** | ❌ | ✅ Full (unique) | ❌ | ❌ | ❌ | ❌ | ✅ Freelance | ❌ |
| **Always free, no subscription** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Installment / BNPL plans** | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **App Lock (PIN + biometric)** | ✅ | ❌ | ❌ | ✅ GCash PIN | ❌ | ❌ | ❌ | ❌ |
| **RA 10173 PII redaction** | ✅ v2.9.42 | Unknown | Unknown | Unknown | N/A | Unknown | Unknown | Unknown |

---

### 3.2 SmartSpend's Competitive Position

**Where SmartSpend leads:**

| Advantage | Detail |
|-----------|--------|
| Only free Taglish agentic AI on Android | 34 autonomous actions vs insight-only AI in all competitors |
| Only app with batch screenshot import | 40+ platform types auto-detected — unique globally |
| Dual-mode FHS | Adapts to users without fixed income — no equivalent exists |
| Only fully offline + cloud sync + free | BudgetPH/PISO are offline-only; cloud apps require internet |
| Most gamification depth | 25 badges + 10 daily quests vs BudgetPH's simpler XP/levels |
| Fully documented FHS formula | Competitors either have no FHS or don't disclose their formula |
| RA 10173 PII redaction before LLM | Mobile numbers + reference numbers stripped before cloud processing |

**Gaps remaining (honest assessment):**

| Gap | Who has it | Priority |
|-----|-----------|----------|
| 15th/30th payday cycle budgeting | BudgetPH, PISO, SweldoWise | 🔥 High |
| Business profile (invoices, inventory) | **Agila** — this is Agila's strongest differentiator | 🟡 Post-capstone |
| Mascot / personality layer | Sentimo (KBoy carabao) | 🟢 Low |
| Safe-to-Spend number | BudgetPH | 🔥 High |

---

### 3.3 GCash Pera Coach — Critical Distinction

GCash Pera Coach (launched March 2026, developed with Microsoft) is frequently cited as a competitor. The critical distinction for panel Q&A:

| Aspect | GCash Pera Coach | SmartSpend |
|--------|-----------------|-----------|
| Function | Financial literacy coaching (teaches concepts) | Financial management (tracks and manages actual behavior) |
| Expense tracking | ❌ None | ✅ Full tracking with 34 agentic actions |
| Financial Health Score | ❌ | ✅ 0–100 with 4-component breakdown |
| Offline capability | ❌ | ✅ Full offline — SQLite on device |
| Multi-modal input | ❌ Text only | ✅ Voice, OCR, barcode, batch screenshots |
| Account type | Requires Fully Verified GCash | Any Android device |

**Summary:** Pera Coach teaches financial concepts. SmartSpend tracks and manages actual financial behavior. They solve fundamentally different problems.

---

## Part 4 — Global App Comparators

For panel context, SmartSpend should be positioned against international apps:

| App | Key strength | SmartSpend comparison |
|-----|-------------|----------------------|
| **YNAB** | Zero-based budgeting gold standard | ✅ SmartSpend: free, offline, AI — YNAB: $14.99/mo, US bank API |
| **Monarch Money** | AI Q&A from own data (July 2026) + Goals 3.0 | ✅ SmartSpend: 34 agentic actions vs Monarch's Q&A-only; free vs $9.99/mo |
| **Rocket Money + Rowan** | Agentic AI via SMS, bill cancellation | ✅ SmartSpend: similar agentic concept — Rowan US-only, requires bank API |
| **Copilot** | AI auto-categorization | ✅ SmartSpend: more actions — Copilot iOS-only, paid |
| **Wingman Money** | Behavioral FHS 0–100 (AU/NZ) | ✅ Validates SmartSpend's approach commercially — not available in PH, no offline |

---

## Part 5 — Correct FHS Theoretical Framework

For manuscript Chapter 1 and Chapter 3:

**What SmartSpend IS:**
> A **Prototype Observed Financial Health Indicator (FHI)** computed deterministically from recorded transaction data. Per the Commonwealth Bank of Australia–Melbourne Institute (CBA-MI, 2018) dual-scale model and UNSGSA (2021) guidelines, this is an *Observed* scale — distinct from *Reported* (survey-based) scales like the CFPB Financial Well-Being Scale.

**What SmartSpend is NOT:**
- Not validated by the CFPB scale (which measures psychological well-being states, not behavioral transaction outcomes)
- Not a credit score
- Not a financial diagnosis
- Not a replacement for professional financial advice

**Academic references:**
- Financial Health Network (FHN, 2018) — four-pillar structure (Spend, Save, Borrow, Plan)
- Commonwealth Bank of Australia – Melbourne Institute (CBA-MI, 2018) — Observed vs Reported FHI distinction
- UNSGSA (2021) — dual-scale guidelines for financial health indicators
- Sharma, Gaba & Sharma (2026, Atlantis Press PLS-SEM, N=656) — empirically validates nudge + gamification design: Budget Feedback Nudge β=0.28 (t=6.21, p<0.001), Gamified Rewards β=0.25 (t=5.89, p<0.001), R²=0.56

---

## Part 6 — Claims to Avoid in the Manuscript

Per the research dossier, these claims are not defensible and must be removed or softened:

| ❌ Remove | ✅ Replace with |
|-----------|----------------|
| "First Filipino-English agentic financial app" | "A novel integration of Taglish-aware AI with agentic financial management, not found in public review of current Philippine applications" |
| "Only offline financial tracker in the Philippines" | "Among current publicly available Philippine finance apps reviewed, SmartSpend provides offline-first local ledger storage with optional cloud sync" |
| "No Philippine app has AI money coaching" | "GCash Pera Coach provides AI financial literacy coaching; SmartSpend addresses the distinct need for agentic financial management" |
| "23 earnable badges" | **25 earnable badges** |
| "31 agentic actions" | **34 agentic actions** |
| "60 messages/day" | **150 messages/day across 8 providers** |
| "5 color themes" | **10 color themes** |
| "Gemini 3.1 Flash-Lite" | **Gemini 3.5 Flash-Lite** (migrated Sep 10, 2026) |
| Any LLaMA model in the fallback chain | **Retired — return 404. Current chain: Gemini → GPT-OSS 120B → Qwen3.6/3.8 → GPT-OSS 20B → Compound Mini → Cerebras** |

---

## Part 7 — Summary Table: SmartSpend vs. Closest Systems

| Criterion | SmartSpend | MindsBudget | Wingman Money | BudgetPH | FinHealth Score |
|-----------|:---------:|:-----------:|:-------------:|:--------:|:---------------:|
| Transaction-based (no survey) | ✅ | ✅ | ✅ | ✅ | ❌ (survey) |
| Fully documented formula | ✅ | Partial | ❌ | ❌ | Partial |
| Offline computation | ✅ | ✅ | ❌ | ✅ | N/A |
| No bank API required | ✅ | ✅ | ❌ | ✅ | N/A |
| Dual-mode (regular + irregular income) | ✅ | ❌ | ❌ | ❌ | ❌ |
| Philippine / Filipino context | ✅ | ❌ | ❌ | ✅ | ❌ |
| Behavioral adjustments (decay + gap) | ✅ | Unknown | Unknown | Unknown | ❌ |
| Essential category exemption | ✅ (v2.9.42) | Unknown | Unknown | Unknown | ❌ |
| Mobile-first, free, no subscription | ✅ | ❌ (web) | ❌ (paid) | ✅ | N/A |

---

*Document compiled September 12, 2026 by Kiro IDE.*  
*Based on: COMPARATIVE-RESEARCH-SMARTSPEND.docx (original by research team), SmartSpend source code v2.9.49, BENCHMARK.md, CAPSTONE_REFERENCE.md, FEATURE_BACKLOG.md.*  
*All SmartSpend feature statuses are PROJECT-REPORTED from code audit. Competitor features from public app-store listings and official product pages as of September 2026.*
