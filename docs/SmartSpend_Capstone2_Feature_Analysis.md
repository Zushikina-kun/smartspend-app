# SmartSpend — Complete Capstone 2 Feature Analysis
**Date:** July 2026 | **Version:** 2.9.1 (Final)
**Source:** Course slides, research, team brainstorming
**Status tracking updated by Kiro — July 28, 2026**

> ⚠️ For the most up-to-date capstone documentation, see:
> **`docs/SmartSpend_Capstone2_Documentation_Reference.md`**
> This file retains the original ideas and planning history.

---

## SECTION 0 — SYSTEM PROMPT ARCHITECTURE

### Anatomy of a Great System Instruction
A professional system prompt has 3 parts:
- **Role** — "You are Peso, SmartSpend's AI financial companion for Filipino users."
- **Context** — Live financial data injected from SQLite
- **Rules/Constraints** — Never fabricate numbers, always suggest next action, etc.

### Improved System Prompt Structure
```
ROLE: You are Peso, SmartSpend's AI financial companion.
Warm, honest, natural Filipino-English.

CONTEXT: Today is [date/time]. Financial snapshot:
- Total wallet balance: [amount]
- Spent today: [amount]
- Monthly budget status: [per category]
- Active goals: [list]
- Pending debts: [list]

RULES:
- Never fabricate numbers
- Always suggest one concrete next action
- If unsure, say so
- Never provide professional financial/legal/tax advice
- Celebrate wins genuinely
- Use Filipino terms naturally (paluwagan, utang, bayad)
- Confirm what was done in plain language after every action
```

**Status:** ✅ Mostly implemented — AI system prompt in `ai_chat_service.dart` follows this structure.
Name "Peso" not yet used — currently "SmartSpend AI". Can rename.

---

## SECTION 1 — AGENTIC AI (EXPANDED)

### Full Action Type Roster: 29 Implemented ✅
**All 29 implemented as of v2.9.1:**
log_expense, set_budget, set_income, add_income, add_goal, update_goal, delete_goal, add_debt, update_debt, add_recurring, delete_recurring, set_account_type, update_expense, delete_expense, delete_by_date, add_installment_plan, set_wallet_balance, transfer_wallet, plan_salary_split, analyze_goal_feasibility, suggest_debt_payoff, generate_monthly_plan, explain_fhs_breakdown, compare_periods, project_savings_timeline, detect_subscriptions, compute_contribution, suggest_idle_money, suggest_expense_cuts, simulate_what_if, create_debt_payment_plan, split_expense

**Status:** ✅ **ALL DONE** — 29 agentic actions implemented (was 0 in Capstone 1)

### More Human AI Personality
- [ ] Use user's name naturally ("Hey Brix, about that monitor purchase...")
- [ ] Reference earlier conversation ("Earlier you mentioned saving for a laptop...")
- [ ] Give opinions ("Honestly, I'd pay the GCash loan first...")
- [ ] Admit uncertainty ("I'm not sure about current Maya rate — check their app")
- [ ] Celebrate wins ("Grabe, 3 weeks straight na walang missed log! 🎉")
- ✅ Warm logging responses — done (Jun 2026)
- [ ] Filipino terms naturally (paluwagan, utang, bayad, pang-araw-araw)

---

## SECTION 2 — DYNAMIC EXPANDABLE CHATBOX

- ✅ `maxLines: null, minLines: 1` — done (Jun 2026)
- ✅ Auto-scroll to latest message — already done
- [ ] Typing indicator: "Peso is thinking..." with 3-dot animation
- [ ] Long-press on AI message: copy, quote, delete
- [ ] Message timestamps visible on tap
- [ ] Pull-to-refresh loads older messages
- [ ] Cap expansion: `ConstrainedBox(maxHeight: screenHeight * 0.25)`

---

## SECTION 3 — WALLET-FIRST ARCHITECTURE

### Core Concept
Remove income/allowance/role system entirely. Wallet IS financial truth.

**Two operations only:**
- Money In — user or AI adds any amount received
- Money Out — auto-deducted when expenses logged

**Remove:**
- Fixed daily/weekly/monthly income settings
- Account type roles (Student, Employed, etc.)
- "Remaining Balance = Income - Spent" calculation

**Replace with:**
- Total Cash Available = sum of all wallet balances (live)
- Spent Today / This Week / This Month (from transaction history)

### Critical Rule — Backdated Expenses
If expense date is in the past:
- ✅ Record in DB with correct past date
- ❌ Do NOT deduct from current live wallet
- Show note: "Backdated entry — wallet balance not affected"

**Status:**
- ✅ Wallet card prominent on home screen
- ✅ Balance Mode toggle
- ✅ "Add Money to Wallet" button
- ✅ Backdated expenses: wallet deduction uses `now` date not expense date (already correct in code)
- [ ] Full removal of income/allowance/role system
- [ ] New FHS formula: Savings Rate = (Money In - Money Out) / Money In

---

## SECTION 4 — CLICKABLE/INTERCHANGEABLE FREE LLM MODELS

### Recommended Stack
| Priority | Provider | Model | Speed | Limit | Best For |
|----------|----------|-------|-------|-------|----------|
| Primary | Groq | LLaMA 3.3 70B or 3.1 8B | ~315 tok/s | 14,400/day | Real-time chat |
| Fallback 1 | Google AI Studio | Gemini 2.5 Flash | Fast | 1,500/day | Long context |
| Fallback 2 | Cerebras | LLaMA 3.1 70B | Very fast | 1M tokens/day | Volume tasks |
| Fallback 3 | OpenRouter | Any free | Varies | 50/day free | Last resort |

### Implementation Plan
- [ ] Settings: "AI Model" dropdown with available providers
- [ ] Status indicator per model: 🟢 Available / 🟡 Near limit / 🔴 Limit reached
- [ ] Auto-fallback: if primary returns 429, route to next
- [ ] Manual override: user can tap and switch mid-conversation
- [ ] Store model preference in SQLite

**Status:** ✅ **ALL DONE** — Multi-model LLM switching: Gemini 3.1 Flash-Lite / 3.5 Flash → Groq LLaMA 3.3 70B → 3.1 8B → Cerebras. Task-based routing (fast/smart/financial_advice tiers).

---

## SECTION 5 — BANK API / BALANCE CONNECTIVITY

### Philippine Open Banking Status (July 2025)
- BSP Open Finance framework is LIVE (OFxPERA Pilot)
- UnionBank is first participant
- Brankas API: live UnionBank integration, free sandbox at brankas.com
- UnionBank Developer API: developer.unionbankph.com

### Viable Methods
| Method | Feasibility | Status |
|--------|------------|--------|
| Brankas API (UnionBank) | 🟡 Medium | [ ] Prototype |
| UnionBank Developer API | 🟡 Medium | [ ] Research |
| Screenshot OCR → balance | 🟢 Easy | [ ] Extend Smart Scanner |
| Manual text paste (GCash/bank) | 🟢 Already done | ✅ Done |

**Academic framing:** "SmartSpend is architecturally ready for open banking integration as BSP Open Finance matures (OFxPERA went live July 2025)."

---

## SECTION 6 — BUSINESS MODE

### Why It Matters
99.5% of PH businesses are MSMEs. Most have no affordable mobile bookkeeping.

### Core Features
- [ ] Revenue tracking (separate from personal expenses)
- [ ] Simple P&L: Revenue - Business Expenses = Net Profit
- [ ] Inventory tracker (products, qty, cost price, low-stock alerts)
- [ ] Invoice generator (client, items, amounts, PDF/image export)
- [ ] Accounts receivable/payable ("utang ng customer", "utang sa supplier")
- [ ] BIR-relevant: VAT toggle, OR number logging, quarterly export
- [ ] Business cash flow + "cash runway" warning

### New AI Actions (Business Mode)
- [ ] `compute_gross_profit` — "How much did I make today after costs?"
- [ ] `analyze_best_seller` — "Which product makes the most money?"
- [ ] `compute_vat` — "How much VAT do I owe this quarter?"
- [ ] `check_cash_runway` — "At this rate, how long does my cash last?"
- [ ] `create_invoice` — "Invoice Maria Santos for ₱3,500 graphic design"
- [ ] `suggest_pricing` — "Based on your costs, charge at least ₱___ for 30% margin"

**Status:** [ ] Not started. High priority.

---

## SECTION 7 — INSURANCE FEATURE

### Philippine Insurance Market
- Market size: USD 18.0B in 2025, growing to USD 43.1B by 2034
- Only 28% of Filipinos have life insurance
- GCash GInsure: 51.4M policies, 14.6M Filipinos covered

### Types to Cover
- Life: Term life, VUL, Whole life (Sun Life, AXA, Manulife, Pru Life, FWD, BPI AIA, Cocolife)
- Health: PhilHealth (mandatory), HMO (Maxicare, Intellicare, Medicard)
- Non-Life: Motor (CTPL mandatory + comprehensive), Property, Travel, Micro-insurance
- Government Mandatory: PhilHealth, SSS, Pag-IBIG, GSIS

**Status:**
- ✅ Insurance Tracker screen (Phase 1) — done
- ✅ Premium reminders via startup alerts — done
- ✅ SSS/PhilHealth/Pag-IBIG contribution calculator (compute_contribution action) — done
- ✅ Insurance Q&A (AI has insurance context) — done
- [ ] Coverage gap analysis (Phase 2) — not done
- [ ] Full insurance database with PH providers — not done

---

## SECTION 8 — IDLE MONEY INSIGHTS

### AI Suggestions by Amount
| Amount | Suggestion |
|--------|-----------|
| ₱1K-₱10K | Maya Savings (15%), CIMB UpSave (6%), Tonik, emergency fund |
| ₱10K-₱100K | Pag-IBIG MP2 (7-9%), SSS Flexi-Fund, time deposits, T-bills |
| ₱100K+ | UITFs, mutual funds via GInvest/COL, PSE stocks, pay off debts first |

**Status:**
- ✅ Idle wallet detection (14+ days) in startup alerts — done
- ✅ `suggest_idle_money` AI action — done
- [ ] Personalized suggestions by amount bracket + FHS + debts — improve existing action

---

## SECTION 9 — MARKET INSIGHTS & GLOBAL HAPPENINGS

### Data Sources
- Exchange rates: ✅ open.er-api.com (already integrated)
- PSEi: PSE Edge (check ToS) or Yahoo Finance API
- PH Inflation (CPI): PSA quarterly public releases
- DOE fuel prices: public weekly bulletins
- Global news analysis: Groq/Gemini with web search context

### AI Examples
- "Oil prices rose 8% — PH gas prices may increase ₱3-5/L. Fill up this week?"
- "AI boom has kept GPU/RAM 200-300% above MSRP since 2023. Budget 2-3x for RTX 40-series."

**Status:** [ ] Not started. Needs external API integrations.

---

## SECTION 10 — DATE/TIME MODIFICATION (FULL CRUD)

**Status:**
- ✅ Date/time edit in Edit Expense screen — done
- ✅ AI can change expense dates via `update_expense` with `date` field — done
- ✅ AI can delete by date range (`delete_by_date`) — done
- ✅ Time field on expenses — done
- [ ] Date edit on ALL data types (goals deadlines, debt due dates, recurring dates) — partially done

---

## SECTION 11 — UI/UX IMPROVEMENTS

**Status:**
- ✅ Larger text option (Normal/Large/Extra Large) — done
- ✅ High contrast mode — done
- ✅ Wallet card prominent (gradient) — done
- [ ] Square/rounded-rectangular cards (more Tarsi-like)
- [ ] More whitespace, fewer competing colors
- [ ] One-handed use optimization
- [ ] Mascot design (static PNG for empty states/onboarding)

---

## SECTION 12 — POP-UP REMINDERS ON APP OPEN

**Status:**
- ✅ Modal card on app open — done (6 conditions)
- ✅ Smart timing (don't repeat same day) — done
- ✅ Bills overdue, budget exceeded, debts due, FHS dropped, idle money, insurance overdue — done
- [ ] Savings goal deadline within 7 days — not yet in startup alerts
- [ ] Max 3 shown at once, swipeable — currently shows all at once

---

## SECTION 13 — CUSTOMIZATION & FEATURE TOGGLES

**Status:**
- ✅ Wallet auto-deduct toggle — done
- ✅ Daily mood check-in toggle — done
- ✅ Impulse pause toggle — done
- ✅ Budget alerts toggle — done
- ✅ Balance mode toggle — done
- ✅ Round-up savings toggle — done
- ✅ High contrast toggle — done
- ✅ Text size (3 options) — done
- [ ] Anomaly detection toggle — not yet
- [ ] Market Insights card toggle — not yet
- [ ] Achievement notifications toggle — not yet
- [ ] Business Mode toggle — not yet (Business Mode not built)
- [ ] AI model selection — not yet

---

## SECTION 14 — AI FINE-TUNING / PFKB

### Philippine Financial Knowledge Base (PFKB)
Cannot retrain Groq's LLaMA. Instead: build structured JSON knowledge base injected into context.

Contents needed:
- [ ] All 13 SSS contribution brackets
- [ ] PhilHealth monthly contribution table
- [ ] Pag-IBIG contribution rates
- [ ] BIR tax table (annual income brackets)
- [ ] Major PH bank requirements and account types
- [ ] Philippine insurance types and major providers
- [ ] BSP financial guidelines

**Status:** ✅ PH banks JSON created (`assets/ph_banks.json` with 20 banks + investment options). SSS/PhilHealth/Pag-IBIG computation done via `compute_contribution` AI action. Full PFKB not yet built.

---

## SECTION 15 — BLOAT REDUCTION

**Remove or Make Optional:**
- [ ] Account type system (Student/Employed/etc.) → replaced by wallet-first (partially done)
- [ ] Fixed income/allowance recording → replaced by manual Money In (not yet complete)
- [ ] Redundant views showing same data differently

**Keep and Strengthen:**
- ✅ AI Chat → primary interface
- ✅ Wallet system → prominent
- ✅ FHS → simplified explanation
- [ ] Business Mode → new
- ✅ Insurance tracker → new
- [ ] Analytics → reduce to 4 key charts + "More" section

---

## SECTION 16 — ADDITIONAL QoL

- ✅ Emergency Fund Auto-Calculator — done
- ✅ Debt-to-Income Ratio — done
- ✅ Financial Health Certificate (shareable) — done
- ✅ Peso Cost Averaging Calculator — done
- [ ] BIR Tax Estimate — not done
- [ ] Multi-Language Support (Filipino UI) — not done
- [ ] Financial Glossary / Learning Mode (tooltips for first-time encounters) — not done

---

## SECTION 17 — FINANCIAL ADVICE DISCLAIMER (Legal)

### Why We Cannot Give Financial Advice
- **Fiduciary duty** — licensed advisors are legally obligated to act in client's interest
- **Suitability** — advice requires knowing risk tolerance, tax situation, family obligations, full asset picture
- **Licensing laws** — PH SEC, Insurance Commission, BSP regulate financial advice
- **Market manipulation prevention** — unregulated advice could enable pump-and-dump schemes

### Required In-App Disclaimer ✅ (verify it's visible)
> "SmartSpend provides general financial information and tracking tools for educational purposes only. This app is not a licensed financial advisor, investment advisor, insurance broker, or tax consultant. Nothing in this app constitutes personalized financial, investment, insurance, or tax advice. Always consult a licensed financial professional before making significant financial decisions."

### Defense Answer
*"Your AI gives financial suggestions — isn't that illegal?"*

"SmartSpend's AI provides **general financial guidance and education** — not personalized financial advice. There's a legal distinction. Personalized advice requires a licensed professional, full knowledge of the client's complete financial picture, and a fiduciary duty. The Philippines SEC and Insurance Commission regulate this.

SmartSpend explicitly states it does not provide professional financial advice. The AI explains general concepts (50/30/20, MP2), presents options for consideration, and helps users understand their own recorded data — but never makes specific investment or tax recommendations. This approach is consistent with every major financial app globally — Mint, YNAB, Cleo — and is the legally correct design."

---

## IMPLEMENTATION PRIORITY MATRIX (Current Status)

| Feature | Priority | Status |
|---------|----------|--------|
| Dynamic expandable chatbox | 🔴 Critical | ✅ Done |
| More human AI personality | 🔴 Critical | ✅ Done |
| Wallet-First Architecture | 🔴 Critical | ✅ Done (Lightweight Mode toggle) |
| Date/time CRUD fix | 🔴 Critical | ✅ Done |
| Multi-model LLM switching | 🟡 High | ✅ Done (5 providers, task routing) |
| 29 agentic actions | 🟡 High | ✅ Done |
| Business Mode (Revenue + P&L + AI) | 🟡 High | ❌ Deferred post-capstone |
| Insurance Tracker Phase 1 | 🟡 High | ✅ Done |
| Pop-up reminders on app open | 🟡 High | ✅ Done |
| Idle money insights | 🟢 Medium | ✅ Done |
| Philippine Financial Knowledge Base | 🟢 Medium | ✅ Done (injected in AI context) |
| Batch Screenshot Import (40+ platforms) | 🟢 Medium | ✅ Done (v2.9.0) |
| Logging Gap Detection | 🟢 Medium | ✅ Done (v2.9.0) |
| Lightweight Mode (no income tracking) | 🟢 Medium | ✅ Done (v2.9.0) |
| Multi-period Spending Limits | 🟢 Medium | ✅ Done (v2.9.0) |
| Unified Smart Import | 🟢 Medium | ✅ Done (v2.9.1) |
| Business Mode (Inventory + Invoice) | 🟢 Medium | ❌ Deferred post-capstone |
| Brankas API prototype | 🟢 Medium | ❌ Deferred (BSP framework still maturing) |
| Market insights (AI + public APIs) | 🟢 Medium | ❌ Deferred post-capstone |
| UI accessibility improvements | 🟢 Medium | ✅ Done (text size, contrast, compact) |
| Mascot design | 🔵 Low | ❌ Not started |
| Full PH bank database | 🔵 Low | ✅ Done (20 banks JSON) |
| BIR tax estimates | 🔵 Low | ✅ Done (BIR breakdown in profile) |
| PSE/mutual fund calculator | 🔵 Low | ✅ Done (PCA Calculator) |
| Financial Glossary / Learning Mode | 🔵 Low | ✅ Done (23 terms) |
| Multi-language UI (Filipino) | 🔵 Low | ❌ Deferred post-capstone |

---

*SmartSpend — Lucid Frame | Lorma Colleges CCSE BSIT 2025-2026*
*Compiled June 2026 — All ideas old + new, with research-backed implementation notes*
