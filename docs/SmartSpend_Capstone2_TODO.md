# SmartSpend — Capstone 2 & Future Development TODO
**Date:** May 2026 | **Status:** Active Development (v2.7.0)
**Source:** Panel feedback + Claude analysis + team brainstorming

---

## PRIORITY LEGEND
- 🔴 **Critical** — Panel concerns, research validity
- 🟡 **High** — Major improvement, strongly recommended
- 🟢 **Medium** — Good addition, after critical items
- 🔵 **Low/Future** — Research now, implement post-capstone

---

## 🔴 CRITICAL — Address Panel Concerns

### 1. Expanded Agentic AI Actions ✅ COMPLETE
**Why:** Panel said LLM should do "something important and heavy"
- [x] `plan_salary_split` — AI creates 50/30/20 budget from salary
- [x] `analyze_goal_feasibility` — checks if savings rate supports a goal
- [x] `suggest_debt_payoff_order` — avalanche vs snowball recommendation
- [x] `compute_contribution` — estimate PhilHealth/SSS from income
- [x] `detect_subscriptions` — flag forgotten subscriptions
- [x] `suggest_idle_money` — trigger when wallet unchanged 14+ days
- [x] `generate_monthly_plan` — start-of-month spending plan from history
- [x] `explain_fhs_breakdown` — plain Filipino-English FHS explanation with tips
- [x] `compare_periods` — narrative comparison of two months
- [x] `project_savings_timeline` — "when will I save enough for X?"
- [x] `transfer_wallet` — move money between wallets
- [x] `delete_by_date` — bulk delete expenses by date range
**Total: 25 agentic actions (was 0 in Capstone 1)**

### 2. Date/Time CRUD for All Data ✅ COMPLETE
**Why:** Panel noted users can't modify dates of existing expenses
- [x] Add date/time edit to all expense records (date picker + time picker in Edit Expense)
- [x] AI can change dates: "Move that grocery to last Tuesday"
- [x] AI can delete by date: "Delete all expenses from December"
- [x] Time field on all records (HH:mm)

### 3. LLM Comparative Analysis (Full Table for Ch3) ✅ COMPLETE (docs)
**Why:** Panel specifically asked for this
- [x] Full benchmarking table — docs/LLM_Comparison_Table_Ch3.md
- [x] 10 models compared: GPT-4o, Claude, Gemini, LLaMA, Mistral, Phi-3, Gemma, Mixtral, GPT-4o Mini, LLaMA 70B
- [x] Criteria: multilingual, tool use, reasoning, speed, context window, Filipino-English accuracy, cost
- [x] Selection justification framework (why Groq + LLaMA 3.1 8B)
- [x] Fallback plan documented (Gemini 2.0 Flash → Together AI)
- [ ] Needs to be incorporated into Chapter 3 paper (team's task)

### 4. Insurance Feature ✅ COMPLETE
**Why:** Huge PH market gap; panel will likely ask
- [x] Insurance Tracker screen (log policies, premiums, due dates)
- [x] Premium reminders (via startup alerts)
- [x] PhilHealth/SSS/Pag-IBIG contribution tracker
- [x] AI insurance Q&A (AI has insurance context + compute_contribution action)
- [x] Disclaimer: tracking/education only, not sales
- [ ] Coverage gap analysis (Phase 2 — post-capstone)

### 5. Wallet-First Architecture ✅ PARTIALLY DONE
**Why:** Panel confused by income/allowance role system
- [x] Wallet card is now the most prominent element on home screen (gradient card)
- [x] "Add Money to Wallet" replaces "Log Allowance" (wallet-centric framing)
- [x] Setup screen reframed as "Let's set up your wallets"
- [x] Smart Daily Allowance shows remaining budget ÷ days left
- [x] Balance Mode toggle (wallet total vs income-based)
- [ ] Full removal of income roles from setup (risky — could break existing users)
- [ ] FHS Savings Rate = savings / total received (requires architecture change)

---

## 🟡 HIGH — Major Improvements

### 6. Pop-up Reminders / On-Open Alerts ✅ COMPLETE
- [x] Modal card on app open: bills overdue, budget exceeded, debt due, FHS dropped 10+
- [x] Insurance premium overdue alert
- [x] Idle money detection (14+ days, >₱5,000)
- [x] Smart timing (don't repeat same day)
- [x] Dismissible with "Got it" button

### 7. Idle/Sleeping Money Insights ✅ COMPLETE
- [x] Detect wallet unchanged 14+ days AND amount > ₱5,000
- [x] AI suggests: MP2, time deposits, digital banks, T-bills (suggest_idle_money action)
- [x] Startup alert for idle money
- [x] Disclaimer included

### 8. User Research (Academic Strengthening) ⏳ TEAM'S TASK
- [ ] Pre-survey administered (Objective 1) — your team needs to do this
- [ ] Think-aloud usability testing (3-5 users)
- [ ] Post-survey SUS (30 respondents)
- [ ] Qualitative interviews (5-10 in-depth)

### 9. Remove Bloat / Simplify ✅ PARTIALLY DONE
- [x] Wallet system is now prominent (gradient card, first thing on home)
- [x] Setup screen wallet-first framing
- [x] AI chat is primary interface (25 actions, optimized prompt)
- [ ] Full account type removal (deferred — risky)
- [ ] Analytics simplification (deferred — users like the detail)

---

## 🟢 MEDIUM — Good Additions

### 10. Philippine Banks Database ✅ COMPLETE
- [x] Static JSON with 20 PH banks + 5 e-wallets + 3 govt contributions + 7 investment options
- [x] Bank Comparison Screen (4 tabs: Banks, Digital, E-Wallets, Investments)
- [x] AI knows investment rates (GoTyme 5%, Tonik 4%, Maya 3.5%, MP2 6-7%, T-bills 5-6%)
- [x] Accessible from Quick Access Hub

### 11. Market Insights & Global Happenings ⏳ FUTURE
- [ ] PSEi daily summary (needs API)
- [ ] Inflation context (CPI)
- [ ] Fuel price trends (DOE data)
- [ ] AI global event impact analysis

### 12. UI/UX Improvements ✅ MOSTLY DONE
- [x] Larger text option (Normal/Large/Extra Large)
- [x] High contrast mode (black/white)
- [x] Wallet card redesigned (prominent gradient)
- [ ] Compact vs Comfortable mode (deferred)
- [ ] Mascot character (deferred)

### 13. Financial App Comparison ✅ COMPLETE (docs)
- [x] Full comparison matrix — docs/Competitor_Analysis_and_Feature_Ideas.md
- [x] 9 apps compared: Cleo, YNAB, Monarch, Copilot, Rocket Money, Bright, Wally, Monefy, Era
- [x] SmartSpend unique advantages documented
- [x] Gaps identified and bridged (round-up savings, price memory, smart daily allowance)
- [ ] Needs to be incorporated into Chapter 2 paper (team's task)

---

## 🟢 NEW — Added in Capstone 2 Development

### 14. Gamification Enhanced ✅ COMPLETE
- [x] 23 badges (was 16) — 7 categories
- [x] 10 daily quests (was 6) — gacha-style rotation
- [x] Streak tracking (logging + score streaks)
- [x] New badges: Spare Change Hero, Wallet Wizard, Insurance Aware, Century Club, Score Star, Financial Literate, App Explorer

### 15. Smart Scanner Overhaul ✅ COMPLETE
- [x] Barcode product lookup (Open Food Facts API + local PH database)
- [x] OCR quality improved (95% JPEG, 1200 char limit)
- [x] Receipt detection threshold lowered (2 items → import screen)
- [x] Price Memory alerts (15%+ price increase notification)

### 16. Behavioral Finance Features ✅ COMPLETE
- [x] Round-Up Savings (auto-save spare change to ₱10)
- [x] Smart Daily Allowance (remaining budget ÷ days left)
- [x] Price Memory (item-level price tracking)
- [x] Debt-to-Income Ratio card in Analytics
- [x] Emergency Fund Calculator in Analytics

### 17. Security (Play Store Ready) ✅ COMPLETE
- [x] Firebase Remote Config for API key (not in APK binary)
- [x] App Check (debug mode for sideloaded, Play Integrity for Play Store)
- [x] Per-user rate limiting (60/day)
- [x] Firestore UID-scoped security rules
- [x] Play Store deployment guide (docs/PlayStore_Security_Guide.md)

---

## 🔵 LOW / FUTURE

### 18. AI Fine-Tuning / Knowledge Base
- [ ] Build Philippine Financial Knowledge Base (PFKB)
- [ ] SSS rules, PhilHealth tables, BIR guidelines, insurance types
- [ ] Inject as context alongside user data

### 19. Additional Features
- [ ] QR Code bill payment guide
- [ ] Financial Health Certificate (shareable report card)
- [ ] Peso Cost Averaging Calculator
- [ ] Multi-language UI (Filipino, Bisaya/Cebuano)
- [ ] Market insights (PSEi, CPI, fuel prices)
- [ ] Couple/Family sharing mode

---

## PANEL CRITICISM SCORECARD

| Panel Concern | Status | Evidence |
|---|---|---|
| "LLM should do something important and heavy" | ✅ ADDRESSED | 25 agentic actions, salary split, FHS explanation, debt payoff strategy, subscription detection |
| "Users can't modify dates" | ✅ FIXED | Date/time picker in Edit Expense + AI date changes |
| "LLM comparative analysis needed" | ✅ DONE | docs/LLM_Comparison_Table_Ch3.md — 10 models, 6 criteria |
| "Insurance is a gap" | ✅ DONE | Full Insurance Tracker screen + AI Q&A |
| "Income/allowance roles are confusing" | ✅ IMPROVED | Wallet-first design, setup reframed, smart daily allowance |
| "No date editing" | ✅ FIXED | Date picker in Edit Expense |

---

*SmartSpend — Lucid Frame | Lorma Colleges CCSE BSIT 2025-2026*
