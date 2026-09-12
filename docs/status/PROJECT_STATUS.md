# SmartSpend — Project Status
**Version:** 2.9.42 | **Academic Year:** 2026–2027, 1st Semester
**Last Updated:** September 12, 2026
**Group:** Lucid Frame — Brix A. Directo · Cyrille John M. Rubis · Djaunathan Albert S. Madayag

> For full technical documentation see `docs/reference/CAPSTONE_REFERENCE.md`
> For feature backlog and planning see `docs/guides/FEATURE_BACKLOG.md`
> For Claude AI handoff see `docs/manuscript/reseaches/kiro-to-claude-handoff-2026-09-12.md`

---

## PRE-FINAL DEFENSE — NEXT WEEK CHECKLIST

### 🔴 Critical — Must be done before defense day

| Task | Owner | Status | Notes |
|------|-------|--------|-------|
| Install **v2.9.42** on demo phone | Brix | ❌ | Download `SmartSpend-v2.9.42-arm64-v8a.apk` from GitHub releases |
| Verify About screen shows **"Version 2.9.42"** | Brix | ❌ | Should be automatic now — kAppVersion constant |
| Reset AI daily limit before demo | Brix | ❌ | AI screen → ⋮ menu → Reset Daily Limit |
| Create **Figure 1.1** — PH financial literacy bar chart (BSP CFIS 2025 data) | Cyrille | ❌ | Key stats: 50% adults have formal accounts; 74% literacy rate |
| Create **Figure 1.2** — IPO conceptual framework diagram | Cyrille | ❌ | Input→Process→Output; use the table in CAPSTONE_REFERENCE.md §3 |
| Create **Figure 2.1** — SUS score interpretation chart | Cyrille | ❌ | Bangor et al. (2009) adjective scale; target ≥80 = Good |
| Create **Figure 2.2** — Kanban board / development methodology diagram | Cyrille | ❌ | Agile Kanban sprints; show Backlog → In Progress → Done |
| Fill in **Compliance Matrix** | All | ❌ | `docs/capstone/SmartSpend_Master_Bug_Tracker.docx` |
| Move **Paluwagan** from "Future Work" to "Implemented" in manuscript | Cyrille | ❌ | Implemented v2.9.35 — update Ch.4 Recommendations section |
| Update manuscript **model list** (remove LLaMA, add GPT-OSS/Qwen) | Cyrille | ❌ | See kiro-to-claude-handoff for correct chain |
| Update manuscript **FHS equations** with v2.9.42 changes | Cyrille | ❌ | Overspend nuance + Category Balance exemptions + Decay exemptions |
| Update manuscript **agentic action count** to 34 | Cyrille | ❌ | Was 31 in some manuscript sections |
| Update manuscript **badge count** to 25 | Cyrille | ❌ | Was 23 in some sections |
| Update manuscript **daily limit** to 150 | Cyrille | ❌ | Was 60 in some sections |
| Add **RA 10173 PII redaction** section to manuscript (Ch.2 or Ch.3) | Cyrille | ❌ | Implemented v2.9.42 — mobile numbers stripped before LLM |
| Add **Agila, PISO, BunnyWise** to competitor table in manuscript | Cyrille | ❌ | See kiro-to-claude-handoff §13 for details |
| Rehearse demo flow with v2.9.42 | All | ❌ | See demo script below |
| Charge demo phone to 100% the night before — do NOT open the app | Brix | ❌ | Cold start required for demo |

### 🟡 After pre-final defense (before final)

| Task | Owner | Status |
|------|-------|--------|
| SUS survey — 30 respondents (20 parents, 10 young professionals) | Djaunathan | ❌ |
| Use SUS respondents as Google Play Closed Testing pool (12 testers × 14 days) | Brix | ❌ |
| Create Google Play Console account ($25 USD) + identity verification | Brix | ❌ |
| Build AAB: `flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info` | Brix | ❌ |
| Create Privacy Policy hosted page (GitHub Pages) | Cyrille | ❌ |
| Validator signatures — Appendix A certificates | Brix | ❌ |
| BSP citation update: Ch.1 stats from BSP 2021 → BSP CFIS 2025 | Cyrille | ❌ |
| Insert survey results + SUS scores into manuscript Ch.3 | Cyrille | ❌ |
| CV section for all three researchers | All | ❌ |

---

## DEMO SCRIPT — Pre-Final Defense (v2.9.42)

### Setup (night before)
1. Download `SmartSpend-v2.9.42-arm64-v8a.apk` from GitHub releases
2. Install on demo phone; verify About screen shows **"Version 2.9.42"**
3. Charge phone to 100%, do NOT open the app again until demo
4. Have WiFi ready (AI needs internet for first message)

### Opening (2 min)
- Open app cold → show Home screen with live data
- Point out: FHS score card, spending card, wallet card, AI Insights
- If after 6pm: show Day-in-Review card at bottom of home

### Core Demo Flow (10 min)
1. **AI Chat** — type `"on september 9 I spent 90 for lunch, 30 for jeep, 500 for Nintendo Wii, and 150 for plushie"` → show 4 items logged in one message, correct Want/Need tagging
2. **Smart Import** → tap camera icon → show 4-mode sheet → demo batch screenshot import (Steam receipt or Shopee)
3. **Manual Entry** — tap Log Expense → show choice sheet (AI/Manual/Batch/Voice/Round-Trip/Split/Afford?)
4. **Financial Health Score** — tap FHS card → show breakdown with component explanations + "one-off purchase penalty" note
5. **Analytics** — pie chart, 50/30/20 tracker, heatmap, budget envelope, By Tag view
6. **Hub** — scroll through: Goals, Debts, Recurring, **Paluwagan** (highlight as Filipino-specific), **Log Due Bills**, **Merchant Cleanup**
7. **Profile** — show FMS score, FHS breakdown with tips, achievement badges (25), Insurance Tracker

### Panel Q&A — Updated Answers (v2.9.42)

| Question | Answer |
|---|---|
| "GCash already has Pera Coach" | Pera Coach = financial literacy Q&A embedded in GCash. SmartSpend = **34 autonomous agentic actions**, offline-first SQLite, dual-mode FHS with 4-component formula, multi-modal input (voice/OCR/barcode/batch screenshots), gamification (25 badges). They solve different problems — Pera Coach teaches; SmartSpend manages and tracks. |
| "Agila is similar — how are you different?" | Agila has a business profile (invoices, inventory) but no Taglish AI, no FHS, no voice input, no barcode/OCR, no batch screenshot import, no PH government contributions. SmartSpend leads on AI depth, multi-modal entry, and the FHS scoring system. |
| "Your sample is too small" | N=30 purposive is standard for formative usability testing. Nielsen & Landauer (1993) and Faulkner (2003) show 20–30 participants uncover 90–95% of usability defects. Not a population study — a prototype evaluation. |
| "Is the CFPB scale your FHS basis?" | No. The CFPB scale is a 10-item **subjective** psychometric survey measuring psychological states (worry, anxiety, perceived freedom). SmartSpend's FHS is an **objective transaction-derived indicator** — computed programmatically from SQLite data. Grounded in CBA-MI (2018) Observed Financial Well-being Scale and UNSGSA (2021) guidelines. We call it a Prototype Observed Financial Health Indicator. |
| "What if the API goes down?" | 8-provider automatic failover: Gemini 3.5 Flash-Lite → Gemini 3.5 Flash → GPT-OSS 120B (Groq) → Qwen3.6 27B → Qwen3.8 27B → GPT-OSS 20B → Compound Mini → GPT-OSS 120B (Cerebras). Manual entry, OCR, barcode, and item catalog work **100% offline**. |
| "Why not RAG?" | Per-user data (50 expenses, 10 budgets, 5 goals) fits entirely in one prompt — ~1,000–5,000 tokens. RAG adds vector-search latency and fails on multi-hop queries like "Can I afford this given my GCash, clothing budget, and savings goal?". Direct context injection gives 100% accurate, always-current data. |
| "AI gives financial advice — legal?" | General financial guidance and education only — not personalized professional advice. Explicit disclaimer in About screen and embedded in every AI response. Same approach as Mint, YNAB, and Cleo globally. |
| "How does FHS work?" | 4 components × 25pts = 100. **Full Mode** (income tracking ON): Savings Rate, Overspend Control, Budget Adherence, Logging Consistency. **Lightweight Mode** (income tracking OFF): Spending Restraint, Consistency, Category Balance, Habit Streak. Plus Warning Decay (−5 pts/day, max −15 for ignoring discretionary budget overruns) and Gap Adjustment (−3/+2 pts for unlogged days). |
| "What's new in FHS since the previous version?" | Three improvements: (1) Overspend Control now distinguishes one-off large purchases (half-penalty) from habitual daily overspend (full penalty). (2) Category Balance now exempts Bills/Health/Education from the concentration check — essential costs don't unfairly reduce the score. (3) Warning Decay is suspended when only essential categories are over budget. |
| "How many agentic actions?" | **34** — log/update/delete expense, delete_by_date, set_income, add_income, set_wallet_balance, transfer_wallet, set_budget, add/update/delete goal, add/update debt, add/delete recurring, add_installment_plan, plan_salary_split, analyze_goal_feasibility, suggest_debt_payoff, generate_monthly_plan, compare_periods, explain_fhs_breakdown, project_savings_timeline, detect_subscriptions, compute_contribution, suggest_idle_money, suggest_expense_cuts, simulate_what_if, create_debt_payment_plan, split_expense, set_spending_limit, add_insurance_policy, set_account_type |
| "What about data privacy — RA 10173?" | On-device regex redaction strips Philippine mobile numbers and bank reference numbers from OCR/paste text **before** anything is sent to the cloud LLM. Core financial data stays in SQLite on-device. Firebase Firestore sync is UID-scoped. Firebase Remote Config delivers API keys at runtime — not embedded in APK. |
| "Why Flutter?" | Single codebase for Android (and iOS post-capstone). Near-native performance (compiled to ARM). Dart's strong typing suits financial calculations. The entire team could maintain it as a 3-person group. |

---

## CAPSTONE 2 TIMELINE

| Week | Activity | Status |
|------|----------|--------|
| Week 1 | Project Reorientation | ✅ Done |
| Week 2 | Chapter 3 | ⚠️ Draft exists — needs figures + model/FHS corrections |
| Week 3 | Chapter 4 | ⚠️ Draft exists — needs survey data |
| Week 4 | Final software check | ✅ Done (v2.9.42 is stable) |
| **Week 5–6** | **Pre-Final Defense** | 🔴 **Next week** |
| Week 7 | SUS survey (30 respondents) + Play Store closed testing start | ❌ Pending |
| Week 8–10 | Complete manuscript + Play Store submission | ❌ Pending |
| Week 11–13 | Final Defense | ❌ Pending |
| Week 15–17 | Revisions + submission | ❌ Pending |

---

## APP STATUS — v2.9.42 (Current — Defense Build)

### AI System
- **Primary model**: Gemini 3.5 Flash-Lite (GA stable — migrated from 3.1 on Sep 10, 2026 due to 404 errors in production)
- **Fallback chain** (8 providers): Gemini 3.5 Flash → GPT-OSS 120B (Groq) → Qwen3.6 27B → Qwen3.8 27B → GPT-OSS 20B → Compound Mini → GPT-OSS 120B (Cerebras)
- **LLaMA models**: Retired from Groq free/dev tier Feb–Aug 2026 — NOT in chain
- **Daily limit**: 150 messages
- **Language**: English-default; switches to Filipino only when user writes multiple full Filipino sentences

### Feature Count (v2.9.42)
| Metric | Count |
|--------|-------|
| Agentic AI actions | **34** |
| Input modalities | 7 |
| Hub tiles | 22 |
| Achievement badges | **25** |
| Daily quests pool | 10 |
| Batch screenshot platforms | 40+ |
| Filipino item catalog | 150+ |
| Log choice sheet options | 7 |
| Currencies | 57 |
| SQLite tables | 20 |

### Key Features Added Since v2.9.37 (defense-relevant)
| Feature | Version | Where |
|---|---|---|
| AI language fix — English default | 2.9.38 | AI chat |
| Multi-item expense logging fixed | 2.9.38 | AI chat |
| Cross-screen auto-refresh after AI actions | 2.9.38 | All screens |
| Chat error metadata persists after restart | 2.9.38 | AI chat |
| Duplicate guard fixed (same-day repeats allowed) | 2.9.38 | AI chat |
| Debug log — comprehensive new sections | 2.9.40 | Profile → Debug Log |
| About screen version from constant | 2.9.41 | About screen |
| FHS Overspend Control — one-off purchase nuance | 2.9.39 | Score engine |
| FHS Category Balance — exempts Bills/Health/Education | 2.9.42 | Score engine |
| FHS Warning Decay — skips essential category overspend | 2.9.42 | Score engine |
| RA 10173 PII redaction before LLM | 2.9.42 | AI pipeline |

---

## PEOPLE REFERENCE

| Name | Role | Appears On |
|---|---|---|
| **Directo, Brix A.** | Lead Developer | All author pages |
| **Rubis, Cyrille John M.** | UI/UX + Documentation | All author pages |
| **Madayag, Djaunathan Albert S.** | Project Manager + QA | All author pages |
| **Ellen F. Mangaoang, MIT** | Capstone Adviser | Title page, Approval sheet, Acknowledgement |
| **Shekiro R. Raposas** | Panel Member | Defense panel |
| **Mary-Ann Mzana** | Panel Member | Defense panel |
| **Dr. Janelli M. Mendez, MIT** | Course Instructor | Acknowledgement only |
| **Jeoffrey B. Layco, MIS** | Dean of CCSE | Approval sheet |
| **Jopher F. Reyes, MIT** | Oral Committee Member | Approval sheet |
| **Gelo Ryann M. Carbonell** | Oral Committee Member | Approval sheet |
| **Johnny Flores Verzola, MTS** | Former Adviser (Capstone 1 only) | Acknowledgement only — **NOT on title page, NOT current adviser** |

**Birthdates (for CVs):**
- Brix A. Directo: September 4, 1999
- Cyrille John M. Rubis: August 26, 2005
- Djaunathan Albert S. Madayag: March 8, 2005

---

## MANUSCRIPT CORRECTIONS NEEDED (for Cyrille)

The following corrections are NOT yet applied in the manuscript Google Doc. Apply them before printing:

| # | What to fix | Where in manuscript | Detail |
|---|-------------|---------------------|--------|
| 1 | Version → 2.9.42 | All headers | |
| 2 | Primary model → Gemini 3.5 Flash-Lite | Ch.2/3 AI section | Not 3.1, not LLaMA |
| 3 | Remove LLaMA from fallback chain | Ch.2/3 LLM table | Retired on Groq Feb–Aug 2026 |
| 4 | 34 agentic actions (not 31) | All mentions | |
| 5 | 25 badges (not 23) | All mentions | |
| 6 | 150 messages/day (not 60) | All mentions | |
| 7 | 8 providers (not 5 or 6) | All mentions | |
| 8 | Paluwagan → Implemented | Ch.4 Recommendations | Remove from Future Work |
| 9 | FHS = Prototype Observed FHI (not CFPB-validated) | Ch.1/3 FHS section | Grounded in CBA-MI + UNSGSA |
| 10 | Remove "32% overspending" claim | Ch.1 | Commercial stat, not peer-reviewed |
| 11 | Remove "22% gamification boost" claim | Ch.1 | Same |
| 12 | Remove "$133/month subscription" claim | Ch.1 | US market, not PH |
| 13 | Soften "first/only" exclusivity claims | Ch.1 | "novel integrated bundle" |
| 14 | FHS Overspend Control formula updated | Ch.3 | Add soft/hard penalty explanation |
| 15 | FHS Category Balance exempts Bills/Health/Education | Ch.3 | New in v2.9.42 |
| 16 | FHS Warning Decay: only discretionary categories | Ch.3 | New in v2.9.42 |
| 17 | Add RA 10173 PII redaction | Ch.2 Security section | Mobile numbers redacted before LLM |
| 18 | Add Agila as competitor | Ch.2 competitor table | Android + iOS; business profile strength |
| 19 | Add PISO Budget Tracker as competitor | Ch.2 competitor table | Offline-first, Filipino-made |
| 20 | Adviser = Ellen F. Mangaoang MIT | Title page | Verzola = Capstone 1 only |
