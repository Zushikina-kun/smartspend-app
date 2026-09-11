# SmartSpend — Project Status
**Version:** 2.9.37 | **Academic Year:** 2026–2027, 1st Semester
**Last Updated:** September 10, 2026
**Group:** Lucid Frame — Brix A. Directo · Cyrille John M. Rubis · Djaunathan Albert S. Madayag

> For full technical documentation see `docs/reference/CAPSTONE_REFERENCE.md`

---

## PRE-FINAL DEFENSE — NEXT WEEK CHECKLIST

### 🔴 Critical — Must be done before defense day

| Task | Owner | Status |
|------|-------|--------|
| Install v2.9.37 on demo phone (About → Version 2.9.37) | Brix | ❌ |
| Create Figure 1.1 — PH financial literacy bar chart (BSP data) | Cyrille | ❌ |
| Create Figure 1.2 — IPO conceptual framework diagram | Cyrille | ❌ |
| Create Figure 2.1 — SUS score interpretation chart | Cyrille | ❌ |
| Create Figure 2.2 — Kanban board diagram | Cyrille | ❌ |
| Fill in Compliance Matrix (SmartSpend_Compliance_Matrix_PreFinal.docx) | All | ❌ |
| Move Paluwagan from "Future Work" to "Implemented" in manuscript | Cyrille | ❌ |
| Rehearse demo flow (see Demo Script below) | All | ❌ |
| Charge phone to 100% the night before — do NOT open the app | Brix | ❌ |

### 🟡 After pre-final defense (before final)

| Task | Owner | Status |
|------|-------|--------|
| SUS survey — 30 respondents (20 parents, 10 young professionals) | Djaunathan | ❌ |
| Validator signatures — Appendix A certificates | Brix | ❌ |
| BSP citation update: Ch.1 stats from BSP 2021 → BSP CFIS 2025 | Cyrille | ❌ |
| Insert survey results + SUS scores into manuscript Ch.3 | Cyrille | ❌ |
| CV section for all three researchers | All | ❌ |
| Apply Google Docs manuscript fixes from SmartSpend_Manuscript_Source.md | Cyrille | ❌ |

---

## DEMO SCRIPT — Pre-Final Defense

### Setup (night before)
1. Install `SmartSpend-v2.9.37-arm64-v8a.apk` from GitHub releases
2. Verify About screen: "Version 2.9.37"
3. Charge phone to 100%, do NOT open the app again until demo

### Opening (2 min)
- Open app cold → show Home screen with live data
- Point out: FHS score, spending card, Day-in-Review card (if after 6pm), AI Insights

### Core Demo Flow (10 min)
1. **AI Chat** — type "spent 90 for lunch and 30 for jeep" → show instant logging, Taglish support
2. **Smart Import** → show batch screenshot import (Steam receipt or Shopee)
3. **Manual Entry** — tap Log Expense → show choice sheet (AI/Manual/Batch/Voice/Round-Trip/Split/Afford?)
4. **Financial Health Score** — tap FHS card → show breakdown, components explanation
5. **Analytics** — show pie chart, 50/30/20, heatmap, budget envelope, By Tag
6. **Hub** — scroll through: Goals, Debts, Recurring, Paluwagan (NEW), Log Due Bills (NEW), Merchant Cleanup (NEW)
7. **Profile** — show FMS score, Score Breakdown, badges

### Panel Q&A Prep (key questions)
| Question | Answer |
|---|---|
| "GCash already has Pera Coach" | Pera Coach = literacy Q&A only. SmartSpend = 34 autonomous actions, offline SQLite, dual-mode FHS, gamification, batch import. Different problems. |
| "Your sample is too small" | N=30 purposive = correct for formative usability testing. Nielsen/Faulkner: 20-30 finds 90-95% of defects. Not a population study. |
| "CFPB validates your FHS?" | No. CFPB = 10-item subjective psychometric survey. Our FHS = objective transaction-derived indicator. Grounded in CBA-MI (2018) + UNSGSA (2021). |
| "What if the API goes down?" | 8-provider fallback: Gemini → GPT-OSS 120B → Qwen3.6 → Qwen3.8 → GPT-OSS 20B → Compound → Compound Mini → Cerebras. Manual/Batch/Catalog work 100% offline. |
| "Why not RAG?" | Per-user data fits in context window. 50 expenses ≈ 1,000–5,000 tokens. RAG adds latency + fails multi-hop queries. |
| "AI gives financial advice — legal?" | General guidance + education, not personalized licensed advice. Disclaimer in About + all AI responses. Consistent with Mint, YNAB, Cleo. |
| "How does FHS work?" | 4 components × 25pts = 100. Full: Savings Rate, Overspend Control, Budget Adherence, Logging Consistency. Lightweight: Spending Restraint, Consistency, Category Balance, Habit Streak. |
| "How many agentic actions?" | 34 — full list: log/update/delete expense, delete_by_date, set_income, add_income, set_wallet_balance, transfer_wallet, set_budget, add/update/delete goal, add/update debt, add/delete recurring, add_installment_plan, plan_salary_split, analyze_goal_feasibility, suggest_debt_payoff, generate_monthly_plan, compare_periods, explain_fhs_breakdown, project_savings_timeline, detect_subscriptions, compute_contribution, suggest_idle_money, suggest_expense_cuts, simulate_what_if, create_debt_payment_plan, split_expense, set_spending_limit, add_insurance_policy, set_account_type |

---

## CAPSTONE 2 TIMELINE

| Week | Activity | Status |
|------|----------|--------|
| Week 1 | Project Reorientation | ✅ Done |
| Week 2 | Chapter 3 | ⚠️ Draft exists, needs figures + model correction |
| Week 3 | Chapter 4 | ⚠️ Draft exists, needs survey data |
| Week 4 | Final software check | ✅ Done (v2.9.37 is stable) |
| **Week 5–6** | **Pre-Final Defense** | 🔴 **Next week** |
| Week 7 | Testing + SUS survey | ❌ Pending |
| Week 8–10 | Complete manuscript | ❌ Pending |
| Week 11–13 | Final Defense | ❌ Pending |
| Week 15–17 | Revisions + submission | ❌ Pending |

---

## APP STATUS — v2.9.37 (Current)

### AI System
- **Primary model**: Gemini 3.5 Flash-Lite (confirmed working, tested live)
- **Fallback chain**: 8 providers (Gemini Flash → Flash-Lite → GPT-OSS 120B → Qwen3.6 → Qwen3.8 → GPT-OSS 20B → Compound Mini → Cerebras)
- **Daily limit**: 150 messages (was 60)
- **Groq note**: LLaMA models retired Feb-Aug 2026; active models are GPT-OSS/Qwen/Compound family
- **Gemini note**: Migrated from 3.1 Flash-Lite (404 errors in prod) to 3.5 Flash-Lite (GA stable)

### Feature Count
- **Agentic actions**: 34
- **Input modalities**: 7 (text, voice, live camera, single photo, batch screenshots, paste text, manual form)
- **Hub tiles**: 22
- **Achievement badges**: 25 (23 original + No-Spend Day + No-Spend Streak)
- **Daily quests pool**: 10
- **Batch screenshot platforms**: 40+
- **Filipino catalog items**: 150+
- **Log choice sheet options**: 7 (AI/Manual/Batch/Voice/Round-Trip/Split/Afford?)

### New Features Since v2.9.19 (defense-relevant)
| Feature | Version | Where |
|---|---|---|
| Graceful AI failure UX (Retry/Switch/Log Manually) | 2.9.20 | AI chat |
| Manual entry overhaul (9 autocomplete features) | 2.9.32–33 | Add Expense screen |
| 150-item Filipino item catalog | 2.9.33 | Add Expense → browse icon |
| Merchant normalization + Merge tool | 2.9.34 | Hub → Merchant Cleanup |
| Log Due Bills checklist | 2.9.35 | Hub → Log Due Bills |
| Paluwagan tracker | 2.9.35 | Hub → Paluwagan Tracker |
| Budget envelope analytics | 2.9.35–36 | Analytics |
| Price trend chart per item | 2.9.35 | Edit Expense screen |
| Split Bill with auto-debt | 2.9.35 | Log choice sheet |
| Day-in-Review card (after 6pm) | 2.9.36 | Home screen |
| Spending heatmap (5-week) | 2.9.36 | Analytics |
| Budget rollover option | 2.9.36 | Budget screen (↪ icon) |
| Tags analytics (By Tag view) | 2.9.36 | Analytics |
| Afford This? calculator | 2.9.36 | Log choice sheet |
| Offline AI insight cache | 2.9.36 | Home → AI Insights |
| Clipboard SMS/bank nudge | 2.9.37 | AI screen banner |

---

## PEOPLE REFERENCE

| Name | Role | Appears On |
|---|---|---|
| **Directo, Brix A.** | Lead Developer | All author pages |
| **Rubis, Cyrille John M.** | UI/UX + Documentation | All author pages |
| **Madayag, Djaunathan Albert S.** | Project Manager + QA | All author pages |
| **Ellen F. Mangaoang, MIT** | Capstone Adviser | Title page, Approval sheet, Acknowledgement |
| **Shekiro R. Raposas** | Teacher-in-Charge | Title page, Acknowledgement |
| **Dr. Janelli M. Mendez, MIT** | Course Instructor | Acknowledgement only |
| **Jeoffrey B. Layco, MIS** | Dean of CCSE | Approval sheet |
| **Jopher F. Reyes, MIT** | Oral Committee Member | Approval sheet |
| **Gelo Ryann M. Carbonell** | Oral Committee Member | Approval sheet |
| **Johnny Flores Verzola, MTS** | Former Adviser (Capstone 1) | Acknowledgement only — NOT on title page |

**Birthdates (for CVs):**
- Brix A. Directo: September 4, 1999
- Cyrille John M. Rubis: August 26, 2005
- Djaunathan Albert S. Madayag: March 8, 2005
