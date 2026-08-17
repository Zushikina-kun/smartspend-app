# SmartSpend — Capstone Defense Reviewer
**Version 2.9.2 | August 2026 | Lucid Frame**

> Quick-reference guide for the defense presentation. Read this before your pre-final and final defenses.

---

## What is SmartSpend?

SmartSpend is an **AI-assisted mobile financial tracking and advisory application** for Android. It helps everyday Filipino users — students, young professionals, and parents — track spending, manage budgets, and get personalized financial advice through conversational AI.

**Core concept:** User Input → AI Parsing → Autonomous Action → Local Database → Analytics & Insights

---

## What problem does it solve?

Most Filipinos don't track finances because traditional methods (spreadsheets, manual apps) are too tedious. SmartSpend removes friction — you say "I spent 85 pesos on lunch" and the app logs it automatically. No forms, no dropdowns, no manual entry required.

---

## Technology Stack

| What | Technology | Why |
|------|-----------|-----|
| App framework | Flutter (Dart) | Cross-platform, single codebase, near-native performance |
| AI/LLM | Multi-provider: Gemini 3.1 Flash-Lite (primary), Gemini 3.5 Flash, Groq LLaMA 3.3 70B, 8B, Cerebras | Auto-failover, always available, all free tier |
| Local database | SQLite via sqflite (v11, 20 tables) | Works offline, fast, no cost |
| Cloud sync | Firebase Firestore | Free tier, bidirectional sync, UID-scoped security rules |
| Authentication | Firebase Auth | Google Sign-In + email/password |
| OCR | Google ML Kit Text Recognition | On-device, no API key, works offline |
| Barcode | mobile_scanner + ML Kit | Live detection + gallery image detection |
| Smart Import | Unified 4-mode system | Live Camera, Single Photo, Batch Screenshots (40+ platforms), Paste Text |
| Notifications | flutter_local_notifications | Budget alerts, debt reminders, daily briefing |

---

## AI Architecture — Agentic AI with Context Injection

**What makes it Agentic:** The AI doesn't just answer — it takes **29 autonomous actions** on user data. Say "I spent 150 pesos on jeepney" → AI parses intent → writes directly to SQLite. Genuine agentic loop: **perceive → decide → act**.

**Multi-model routing:**
- `fast` tier → expense logging, simple queries → LLaMA 3.1 8B
- `smart` tier → analysis, planning → LLaMA 3.3 70B or Gemini 3.1 Flash-Lite
- `financial_advice` tier → SSS/tax/debt strategy → Gemini 3.5 Flash

**How context injection works:** Before every AI message, app queries SQLite and builds a context string with expenses, budgets, income, goals, debts, wallets, and recurring bills. Injected into the AI system prompt as the single source of truth.

**Why not RAG:** Per-user data (50 expenses, 8 budgets, 5 goals) fits entirely in one prompt. RAG is for thousands of documents. Our approach is a mobile-optimized alternative without vector search overhead.

**Architecture quote (for paper):**
> "SmartSpend implements a multi-provider agentic AI system using dynamic full-context injection from a local SQLite database, enabling autonomous financial data management without the infrastructure overhead of traditional RAG pipelines."

---

## The 29 AI Action Types

| Category | Actions |
|----------|---------|
| Expenses | log_expense, update_expense, delete_expense, delete_by_date |
| Income & Wallets | set_income, add_income, set_wallet_balance, transfer_wallet |
| Budgets | set_budget |
| Goals | add_goal, update_goal (amount + deadline), delete_goal |
| Debts | add_debt, update_debt (payment + due_date) |
| Recurring | add_recurring, delete_recurring |
| Payment Plans | add_installment_plan |
| Analysis | plan_salary_split, analyze_goal_feasibility, suggest_debt_payoff, generate_monthly_plan, compare_periods, explain_fhs_breakdown, project_savings_timeline, detect_subscriptions, compute_contribution, suggest_idle_money, suggest_expense_cuts, simulate_what_if, create_debt_payment_plan, split_expense |
| Account | set_account_type |

---

## Financial Health Score — Exact Formula

### Full Mode (income tracking ON) — 4 components × 25 pts = 100 max

**Component 1 — Savings Rate (25 pts)**
- Formula: 25 × min(1, savingsRate / 0.20)
- savingsRate = (income − totalSpent) / income
- Full 25 pts when saving ≥20% of income
- Example: income ₱6,600, spent ₱4,000 → 39% savings → 25 pts ✓

**Component 2 — Overspend Control (25 pts)**
- Formula: 25 × (1 − overDays / activeDays)
- overDays = days where daily spending exceeded (income / daysInMonth)
- Example: 2 of 10 days exceeded → 25 × (8/10) = 20 pts

**Component 3 — Budget Adherence (25 pts)**
- Formula: 25 × (onBudgetCategories / totalBudgetCategories)
- No budgets set = full 25 pts (not penalized)
- Example: 3 of 4 budgets on track → 18.75 pts

**Component 4 — Logging Consistency (25 pts)**
- Formula: 25 × (loggedDays / activeDays) — scoped to current month only
- Example: logged 8 of 10 days this month → 20 pts

### Lightweight Mode (income tracking OFF) — different 4 components

| Component | Measurement | Max |
|-----------|------------|-----|
| Spending Restraint | vs user-set spending limit (or Want/Need ratio) | 25 |
| Logging Consistency | same formula as full mode | 25 |
| Category Balance | no single category > 40% of total | 25 |
| Habit Streak | consecutive logged days (full at 14 days) | 25 |

### Score Adjustments (applied on top)
- **Warning Decay:** budget exceeded + spending continues → −5 pts/day (max −15). Resets when budgets back on track.
- **Gap Adjustment:** unlogged days confirmed by user → −3 pts/day (spent but forgot) or +2 pts/day (genuinely no spending), max ±15/10

### Score Interpretation
| Score | Label |
|-------|-------|
| 90–100 | 👑 Excellent |
| 80–89 | 🏆 Great |
| 70–79 | ⭐ Good |
| 60–69 | 🌱 Fair |
| < 60 | 📉 Needs Work |

---

## Key Numbers to Remember

| Item | Value |
|------|-------|
| Version | 2.9.2 |
| Platform | Android (Flutter) |
| Database | SQLite version 11, 20 tables |
| AI providers | 5 (auto-failover) |
| Primary model | Gemini 3.1 Flash-Lite |
| Daily AI limit | 60 messages/user |
| AI agentic actions | 29 |
| Currencies supported | 57 |
| Screens | 36 |
| Services | 26 |
| Achievement badges | 23 |
| Daily quests | 10 rotating |
| Expense categories | 14 built-in + unlimited custom |
| Screenshot platforms detected | 40+ |
| PH banks in database | 20 banks + 5 e-wallets |
| Backup format | JSON version 9 |
| Build size | 44.7 MB (arm64-v8a, obfuscated) |
| GitHub | https://github.com/Zushikina-kun/smartspend-app |
| Group | Lucid Frame |
| School | Lorma Colleges — CCSE, BSIT 4th Year |
| Academic Year | 2026–2027, 1st Semester |

---

## Smart Import — Unified Camera System

One camera icon opens a 2×2 sheet:

| Mode | What it does |
|------|-------------|
| Live Camera | Barcode/QR live detection + receipt OCR shutter |
| Single Photo | Gallery pick → auto-detects barcode/receipt/screenshot and routes correctly |
| Batch Screenshots | Pick up to 10 screenshots → detects 40+ platform types → AI extracts per platform |
| Paste Text | Open bank import screen to paste GCash/BPI/Maya export |

**40+ platform types auto-detected:** Steam, Shopee, Lazada, GCash, Maya, GrabFood, Grab rides, App Store, Google Play, Netflix, BPI, BDO, Metrobank, UnionBank, GoTyme, TikTok Shop, Amazon, AliExpress, Shein, Spotify, and more.

---

## Panel Q&A — Key Answers

**Q: How does the FHS work?**
A: Four components, 25 points each, totaling 100. Full Mode: Savings Rate, Overspend Control, Budget Adherence, Logging Consistency. Lightweight Mode (no income): Spending Restraint, Consistency, Category Balance, Habit Streak. Plus two adjustments: Warning Decay (budget violations) and Gap Adjustment (verified unlogged days). Tap the score card on home for full breakdown.

**Q: Why two FHS modes?**
A: Not everyone has a fixed income — students, informal workers, freelancers. Lightweight Mode gives a meaningful FHS using only spending habits, without penalizing people for not entering income data.

**Q: What is Agentic AI?**
A: The AI doesn't just answer — it takes autonomous actions. "Spent 150 on lunch" → AI decides it's Food → writes to the database directly. Perceive → decide → act. SmartSpend has 29 such actions.

**Q: Why not RAG?**
A: RAG is for large knowledge bases (thousands of documents). Our per-user data is tiny — 50 expenses, 8 budgets — fits in one prompt. Direct context injection is faster, simpler, and appropriate for our use case.

**Q: What if the API goes down?**
A: Five-provider automatic failover — Gemini 3.1 Flash-Lite → Gemini 3.5 Flash → Groq LLaMA 3.3 70B → LLaMA 3.1 8B → Cerebras. Manual entry via form works fully offline with zero AI.

**Q: Why Flutter?**
A: Single codebase for Android and iOS, near-native performance (compiles to ARM), efficient for a 3-person team.

**Q: Is the data secure?**
A: SQLite on device + Firebase Firestore with UID-scoped security rules. API key fetched via Firebase Remote Config — never in the APK binary. App Lock with PIN + biometric. 60-message daily rate limit per user.

**Q: What happens offline?**
A: All core features work — manual expense logging, all analytics, budgets, goals, debts, recurring. Only AI chat and cloud sync need internet. App shows offline banner gracefully.

**Q: vs GCash / bank apps?**
A: They handle actual money movement. SmartSpend is a tracker and advisor — doesn't touch your money. Tracks all payment methods (cash, GCash, card, etc.) in one place.

**Q: How does SmartSpend compare to BudgetPH?**
A: BudgetPH is the closest Filipino-context competitor — it has a paluwagan tracker, 15th/30th payday cycle awareness, and a simpler budget score. SmartSpend leads on AI depth (29 agentic actions vs insights-only), multi-modal input (voice, OCR, barcode, batch screenshots), offline-first architecture, and gamification (23 badges vs basic XP/levels). BudgetPH leads on paluwagan and payday cycle features — both are on SmartSpend's post-capstone roadmap.

**Q: Why doesn't SmartSpend have a paluwagan tracker?**
A: Paluwagan is on the post-capstone roadmap as the highest-priority Filipino-specific feature. The core system architecture supports it — it would use the existing debt/recurring infrastructure with a new rotating-round tracking layer. It was deprioritized during Capstone 2 to focus on the AI agentic system and Financial Health Score, which are the primary academic contributions. BudgetPH currently has this feature.

**Q: Why is the validator's name optional on the certificate?**
A: The validation certificates use a credential-based approach — the validator's qualifications (educational background, occupation, years of experience) establish their credibility, not their name. This is academically sound: what matters is that the validator is qualified, not who they are personally. The format complies with ethical research standards on participant and collaborator privacy. If the validator chooses to disclose their name, the optional field is available.

**Q: Is it only for students?**
A: No. 8 account types: Employed, Business Owner, Freelancer, Working Student, Student, Pensioner/Retiree, Unemployed, General/Other. Each adapts labels and features.

**Q: Financial advice disclaimer?**
A: SmartSpend provides general financial information for educational purposes only, not personalized professional advice. Consistent with how Mint, YNAB, and Cleo operate globally.

---

## Demo Script (Practice This)

### Opening (30 sec)
"SmartSpend is an AI-assisted financial tracker. Instead of filling forms, you just tell it what you spent. Let me show you."

### Demo Flow (8–9 min)
1. **Show home screen** — FHS score card, spending summary, wallet card
2. **Log via AI** — "I spent 85 pesos for lunch at the canteen" → shows instant logging
3. **Show FHS breakdown** — tap score card, explain each component
4. **Show Smart Import** — tap camera icon, show 4-mode sheet, demo batch screenshots
5. **Show Analytics** — pie chart, 50/30/20, FHS component chart
6. **Show Budgets** — category limits with pace indicators
7. **Show Settings** — AI model selector, lightweight mode toggle, spending limits
8. **Show Hub** — quick access to all features
9. **Show Achievements** — badge grid

### Before presenting:
- [ ] Reset AI limit: AI screen → ⋮ → Reset Daily Limit
- [ ] Load demo data if needed: Profile → Load Demo Data

---

## Things to Know Cold

1. **FHS formula** — 4 components × 25 pts, two modes (full + lightweight), two adjustments (decay + gap)
2. **29 AI actions** — can list at least 5 examples from memory
3. **Multi-model routing** — fast/smart/financial_advice tiers, 5 providers
4. **Smart Import** — 4 modes, 40+ platforms
5. **Offline capability** — everything except AI chat and sync
6. **Team roles** — Brix: Lead Developer | Cyrille: UI/UX & Documentation | Djaunathan: PM & QA

---

*SmartSpend v2.9.2 — Lucid Frame | Lorma Colleges CCSE BSIT 2026–2027 (1st Sem)*
*You built something genuinely impressive. Know the logic, not the memorization. 🎯*
