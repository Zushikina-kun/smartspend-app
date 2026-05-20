# SmartSpend — Capstone 2 & Future Development TODO
**Date:** May 2026 | **Status:** Planning & Research
**Source:** Panel feedback + Claude analysis + team brainstorming

---

## PRIORITY LEGEND
- 🔴 **Critical** — Panel concerns, research validity
- 🟡 **High** — Major improvement, strongly recommended
- 🟢 **Medium** — Good addition, after critical items
- 🔵 **Low/Future** — Research now, implement post-capstone

---

## 🔴 CRITICAL — Address Panel Concerns

### 1. Expanded Agentic AI Actions
**Why:** Panel said LLM should do "something important and heavy"
- [ ] `plan_salary_split` — AI creates 50/30/20 budget from salary
- [ ] `analyze_goal_feasibility` — checks if savings rate supports a goal
- [ ] `suggest_debt_payoff_order` — avalanche vs snowball recommendation
- [ ] `compute_insurance_premium` — estimate PhilHealth/SSS from income
- [ ] `detect_subscription_charges` — flag forgotten subscriptions
- [ ] `suggest_idle_money_actions` — trigger when wallet unchanged 14+ days
- [ ] `generate_monthly_plan` — start-of-month spending plan from history
- [ ] `explain_fhs_breakdown` — plain Filipino-English FHS explanation with tips
- [ ] `compare_periods` — narrative comparison of two months
- [ ] `project_savings_timeline` — "when will I save enough for X?"

### 2. Date/Time CRUD for All Data
**Why:** Panel noted users can't modify dates of existing expenses
- [ ] Add date/time edit to all expense records
- [ ] AI can change dates: "Move that grocery to last Tuesday"
- [ ] AI can delete by date: "Delete all expenses from December"
- [ ] Time field on all records (HH:mm)

### 3. LLM Comparative Analysis (Full Table for Ch3)
**Why:** Panel specifically asked for this
- [ ] Full benchmarking table with all models (GPT-4o, Claude, Gemini, LLaMA, Mistral, Phi-3, Gemma)
- [ ] Criteria: multilingual %, tool use %, reasoning %, speed, context window, Filipino-English accuracy
- [ ] Selection justification framework
- [ ] Fallback plan documented

### 4. Insurance Feature
**Why:** Huge PH market gap; panel will likely ask
- [ ] Insurance Tracker screen (log policies, premiums, due dates)
- [ ] Premium reminders
- [ ] PhilHealth/SSS/Pag-IBIG contribution tracker
- [ ] AI insurance Q&A
- [ ] Coverage gap analysis (Phase 2)
- [ ] Disclaimer: tracking/education only, not sales

### 5. Wallet-First Architecture (Simplified)
**Why:** Panel confused by income/allowance role system
- [ ] Everything centers on wallet balance as source of truth
- [ ] Remove fixed income roles (student/employed/etc.)
- [ ] Money IN = user tells app any money received
- [ ] Money OUT = expense deducted from wallet
- [ ] FHS Savings Rate = savings / total received this period
- [ ] Works equally for all user types

---

## 🟡 HIGH — Major Improvements

### 6. Pop-up Reminders / On-Open Alerts
- [ ] Modal card on app open if: bills overdue, budget exceeded, debt due, FHS dropped 10+
- [ ] Smart timing (don't repeat same day)
- [ ] Dismissible but persistent

### 7. Idle/Sleeping Money Insights
- [ ] Detect wallet unchanged 14+ days AND amount > 1-month average
- [ ] AI suggests: MP2, time deposits, high-interest savings, T-bills
- [ ] Personalized by amount, account type, FHS, existing debts
- [ ] Disclaimer included

### 8. User Research (Academic Strengthening)
- [ ] Pre-survey administered (Objective 1)
- [ ] Think-aloud usability testing (3-5 users)
- [ ] Post-survey SUS (30 respondents)
- [ ] Qualitative interviews (5-10 in-depth)

### 9. Remove Bloat / Simplify
- [ ] Evaluate account type system for removal
- [ ] Simplify FHS explanation
- [ ] Reduce Analytics to 3-4 key charts + "More" section
- [ ] Make AI chat the #1 primary interface
- [ ] Strengthen wallet system prominence

---

## 🟢 MEDIUM — Good Additions

### 10. Philippine Banks Database
- [ ] Static JSON with 20 most common PH banks
- [ ] Account types, minimum balance, interest rates, fees
- [ ] How to open (online vs branch), requirements
- [ ] AI fallback for banks not in database
- [ ] Bank comparison screen

### 11. Market Insights & Global Happenings
- [ ] PSEi daily summary
- [ ] Inflation context (CPI)
- [ ] Fuel price trends (DOE data)
- [ ] AI global event impact analysis
- [ ] Disclaimer: general awareness only

### 12. UI/UX Improvements
- [ ] Larger text option (16/18/20sp)
- [ ] High contrast mode
- [ ] Compact vs Comfortable mode
- [ ] Cleaner minimalist aesthetic
- [ ] One-handed use optimization
- [ ] Mascot character (Filipino-themed)

### 13. Financial App Comparison (Expanded)
- [ ] Full table: SmartSpend vs Cleo, Copilot, Monarch, Rocket Money, Wally, YNAB, Monefy, GCash, Tarsi, Lista, Bright Money
- [ ] Unique value matrix documented

---

## 🔵 LOW / FUTURE

### 14. AI Fine-Tuning / Knowledge Base
- [ ] Build Philippine Financial Knowledge Base (PFKB)
- [ ] SSS rules, PhilHealth tables, BIR guidelines, insurance types
- [ ] Inject as context alongside user data
- [ ] Research: OpenAI fine-tuning vs RAG vs structured KB injection

### 15. Additional Features
- [ ] Debt-to-Income Ratio tracking (BSP recommends <30%)
- [ ] Emergency Fund Calculator (3-6 months of actual expenses)
- [ ] QR Code bill payment guide
- [ ] Financial Health Certificate (shareable report card)
- [ ] Peso Cost Averaging Calculator
- [ ] Multi-language UI (Filipino, Bisaya/Cebuano)
- [ ] OCR for Philippine IDs

---

## IMPLEMENTATION TIMELINE

| Feature | Capstone 1 (Done) | Capstone 2 | Post-Capstone |
|---|---|---|---|
| Expanded AI actions | — | Add 10 new | Continuous |
| Date/time CRUD | — | Fix immediately | — |
| LLM comparison table | Document for Ch3 | Full benchmarking | — |
| Insurance tracker | Research/design | Phase 1 | Phase 2 |
| Wallet-first architecture | Design | Implement | Migrate |
| Pop-up reminders | Improve existing | — | — |
| Idle money insights | — | Add to AI | Expand |
| Remove bloat | Identify | Simplify | — |
| PH banks database | — | Static JSON | Live API |
| Market insights | AI-only (prompt) | Public APIs | Real-time |
| UI accessibility | Minor tweaks | Full redesign | — |
| Fine-tuning / PFKB | Research | Build PFKB | Fine-tune |

---

*SmartSpend — Lucid Frame | Lorma Colleges CCSE BSIT 2025-2026*
