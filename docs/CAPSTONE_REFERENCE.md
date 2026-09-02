# SmartSpend — Capstone 2 Documentation Reference
**Version:** 2.9.8 | **Date:** August 27, 2026
**Academic Year:** 2026–2027, 1st Semester
**For:** Lucid Frame — Capstone 2 thesis paper, defense, and final documentation
**Maintained by:** Brix A. Directo (Lead Developer)

> This is the single source of truth for capstone 2 documentation.
> Copy numbers, descriptions, and justifications from here into your paper.
> All figures are accurate to the final build (v2.9.8).

---

## 1. SYSTEM OVERVIEW

**Full Title:** SmartSpend: An AI-Assisted Multi-Modal Personal Financial Management Application for Filipino Users Using Agentic Large Language Model Architecture

**Platform:** Android (Flutter/Dart)
**Version:** 2.9.8
**Build date:** August 11, 2026
**Package name:** com.lucidframe.smartspend_app
**Min SDK:** Android 5.0 (API 21)
**Target SDK:** Android 16 (API 36)
**APK size:** 44.7 MB (arm64-v8a release, split, obfuscated)

**Development team:** Lucid Frame
- Brix A. Directo — Lead Developer
- Cyrille John M. Rubis — UI/UX Designer & Documentation Lead
- Djaunathan Albert S. Madayag — Project Manager & QA Lead

**Institution:** Lorma Colleges, College of Computer Studies and Engineering (CCSE)
**Program:** Bachelor of Science in Information Technology (BSIT) — 4th Year, 1st Semester
**Academic Year:** 2026–2027, 1st Semester

---

## 2. RESEARCH CONTEXT

### Problem Statement
No existing application combines:
1. Filipino-English (Taglish) AI input and advice
2. Full offline capability with cloud sync
3. A financial health scoring system
4. Multi-modal input (voice, OCR, barcode, screenshots)
5. Philippine-specific financial knowledge (SSS, PhilHealth, Pag-IBIG, PH banks, BIR TRAIN Law)
6. Completely free — no subscription required

### Key Statistics for Background
- **BSP CFIS 2025:** Only 50% of Filipino adults have formal financial accounts (down from 56% in 2021); household access rose to 86%
- **BSP 2025:** 74% of Filipinos correctly answered basic financial literacy questions (up from 69% in 2021)
- **SWS March 2026:** Philippine financial inclusion reached 58% — 43% e-money accounts, 21% bank accounts
- **GCash:** 41.5 million monthly users (Bloomberg, 2026) — primary driver of financial inclusion
- **PSA PDESA 2025:** Philippine digital economy = ₱2.74 trillion (9.8% of GDP); digital economy employs 10.39M Filipinos
- **NielsenIQ 2026:** 99% of Filipinos shopped online in 6 months, but only 52% actively use mobile banking apps
- **Insurance Commission 2025:** Only 28% of Filipinos have life insurance
- **Flores 2025:** Filipino workers show "come-what-may" attitude toward financial planning
- **Juniper Research 2026:** Gamification boosts saving habits by 22%
- **EY April 2026:** 49% of global consumers used AI for savings/investment; 18% used it for budgeting
- **Plaid Spring 2026:** 60% of consumers expect AI to save them time; 58% expect it to reduce financial stress; AI personal finance market projected to reach **$3.7 billion by 2033**
- **99.5%** of Philippine businesses are MSMEs with limited access to financial tools

### Objectives
**General Objective:**
Design, develop, and evaluate SmartSpend — an AI-assisted mobile personal financial management application for Filipino users.

**Specific Objectives:**
1. Assess existing financial management practices and challenges of the target population through surveys and interviews
2. Design and develop the SmartSpend mobile application with AI integration using multi-provider LLM API with agentic action architecture
3. Evaluate usability using the System Usability Scale (SUS) — target score ≥80 (Good)

---

## 3. AI ARCHITECTURE

### Model Selection
SmartSpend uses a **multi-provider agentic AI system** with automatic failover:

| Priority | Provider | Model | Daily Limit | Best For |
|----------|----------|-------|-------------|----------|
| 1 | Google AI Studio | Gemini 3.1 Flash-Lite | 1,000/day FREE | Default — best quality/cost |
| 2 | Google AI Studio | Gemini 3.5 Flash | 250/day FREE | Complex financial queries |
| 3 | Groq | LLaMA 3.3 70B | 14,400/day FREE | High quality open-source |
| 4 | Groq | LLaMA 3.1 8B | 14,400/day FREE | Fast responses |
| 5 | Cerebras | LLaMA 3.1 70B | 1M tokens/day FREE | Backup |

**Smart routing:**
- `fast` tier — expense logging, simple queries → LLaMA 3.1 8B
- `smart` tier — analysis, planning → LLaMA 3.3 70B or Gemini 3.1 Flash-Lite
- `financial_advice` tier — SSS/tax/debt strategy → Gemini 3.5 Flash (thinking-capable)

**Why not RAG:**
Per-user data (20-50 expenses, 5-10 budgets, 3-5 goals) fits entirely in the context window. Dynamic full-context injection gives the AI always-current data without vector search overhead.

**Architecture justification (for paper):**
> "SmartSpend implements a multi-provider agentic AI system using dynamic full-context injection from a local SQLite database, enabling autonomous financial data management without the infrastructure overhead of traditional RAG pipelines. The multi-provider routing architecture ensures continuous AI availability through automatic failover across five free-tier LLM providers, with task-based routing to match query complexity with model capability."

### Agentic Actions (31 total)
The AI autonomously executes these actions — writing directly to the database:

**Expense Management:** log_expense, update_expense, delete_expense, delete_by_date
**Income & Wallets:** set_income, add_income, set_wallet_balance, transfer_wallet
**Budgets & Limits:** set_budget
**Goals:** add_goal, update_goal, delete_goal
**Debts:** add_debt, update_debt
**Recurring:** add_recurring, delete_recurring
**Payment Plans:** add_installment_plan
**Analysis & Advisory:** plan_salary_split, analyze_goal_feasibility, suggest_debt_payoff, generate_monthly_plan, compare_periods, explain_fhs_breakdown, project_savings_timeline, detect_subscriptions, compute_contribution, suggest_idle_money, suggest_expense_cuts, simulate_what_if, create_debt_payment_plan, split_expense
**Settings & Limits:** set_spending_limit
**Insurance & Contributions:** add_insurance_policy
**Account:** set_account_type

**Total: 31 agentic actions** (was 0 in Capstone 1)

---

## 4. FINANCIAL HEALTH SCORE (FHS)

### Formula — Full Mode (income/wallet tracking ON)
Score = 4 components × 25 points each = 100 maximum

| Component | What it Measures | Formula |
|-----------|-----------------|---------|
| Savings Rate | Actual savings vs 20% income target | 25 × min(1, savingsRate / 0.20) |
| Overspend Control | Days where daily spending exceeded budget | 25 × (1 − overDays / activeDays) |
| Budget Adherence | % of category budgets on track | 25 × (onBudgetCategories / totalBudgetCategories) |
| Logging Consistency | Logged days / active days **this month** | 25 × (loggedDays / activeDays) |

### Formula — Lightweight Mode (income/wallet tracking OFF)
Used when user doesn't want to track income. Score adapts to spending habits only.

| Component | What it Measures | Formula |
|-----------|-----------------|---------|
| Spending Restraint | vs self-set spending limit (or Want/Need ratio if no limit set) | 25 × (1 − excess ratio) |
| Logging Consistency | Same formula as full mode | 25 × (loggedDays / activeDays) |
| Category Balance | No single category > 40% of total | Scales from 25 → 0 as concentration increases |
| Habit Streak | Consecutive logged days (max at 14 days) | 25 × (streak / 14) |

### Score Adjustments (applied after component sum)
1. **Warning Decay:** Budget exceeded + spending continues → −5 pts/day (max −15). Resets when budgets return to on-track.
2. **Gap Adjustment:** Unlogged days reviewed on startup.
   - User confirms spending but forgot to log → −3 pts/day (max −15)
   - User confirms no spending (clean days) → +2 pts/day (max +10)

**Final score = component sum + adjustments, clamped 0–100.**

### Score Interpretation
| Range | Label | Meaning |
|-------|-------|---------|
| 90–100 | 👑 Excellent | Elite financial habits |
| 80–89 | 🏆 Great | Strong financial control |
| 70–79 | ⭐ Good | On the right track |
| 60–69 | 🌱 Fair | Building momentum |
| < 60 | 📉 Needs Work | Focus on core habits |

### Date-Awareness (Important Implementation Detail)
The FHS and all associated alerts are **current-period aware**:
- Budget alerts only fire for current-month expenses
- Daily limit alerts only fire for today's expenses
- Logging consistency only counts current-month logged days
- Historical (backdated) entries do not trigger any current-period alerts

---

## 5. TECH STACK

| Component | Technology | Details |
|-----------|-----------|---------|
| Framework | Flutter (Dart) | 3.x stable, Android target |
| Local DB | SQLite via sqflite | v11 schema, 20 tables |
| Cloud Sync | Firebase Firestore | Free Spark plan, real-time sync |
| Authentication | Firebase Auth | Email/password + Google Sign-In |
| Crash Reporting | Firebase Crashlytics | Automatic crash collection |
| API Security | Firebase Remote Config | API keys never in APK binary |
| App Check | Firebase App Check | Debug mode (monitoring); Play Integrity for Play Store |
| AI — Primary | Gemini 3.1 Flash-Lite (Google) | 1,000 req/day free, 1M context, best Filipino-English |
| AI — Fallback 1/2 | Gemini 3.5 Flash / Groq LLaMA 3.3 70B | Auto-failover when primary limit hit |
| AI — Fallback 3/4 | Groq LLaMA 3.1 8B / Cerebras LLaMA 3.1 | Speed fallbacks — up to 1,800 t/s |
| OCR | Google ML Kit Text Recognition | Latin script, EXIF-corrected |
| Barcode | ML Kit Barcode Scanning + MobileScanner | Live + gallery detection |
| Charts | fl_chart | Pie, bar, line, scatter |
| Voice Input | speech_to_text | en-PH locale |
| Exchange Rates | open.er-api.com | 57 currencies, cached 1hr |
| Push Notifications | flutter_local_notifications | 8 notification channels |
| Backup | share_plus (JSON v9) | Full data backup/restore |
| App Lock | local_auth | PIN + biometric, per-account |

---

## 6. INPUT MODALITIES (6 ways to log expenses)

| Method | Description | AI Used? |
|--------|-------------|---------|
| **AI Chat (text)** | Type in natural language — "spent 30 for jeep" | ✅ Yes — parses and logs |
| **Voice** | Tap mic, speak naturally, AI parses | ✅ Yes — speech-to-text + parsing |
| **Smart Import — Live Camera** | Live barcode/QR detection + receipt OCR | ✅ Yes — for parsing |
| **Smart Import — Single Photo** | Gallery pick; auto-detects barcode/receipt/screenshot | ✅ Yes — for parsing |
| **Smart Import — Batch Screenshots** | Pick up to 10 screenshots; 40+ platforms detected | ✅ Yes — platform-aware parser |
| **Smart Import — Paste Text** | Paste GCash/bank history; AI parses all rows | ✅ Yes — transaction parser |
| **Manual Entry** | Form with all fields; works fully offline | ❌ No AI needed |

### Smart Import — Platform Detection (40+ types)
The batch screenshot import auto-detects the source platform from OCR text and uses a dedicated AI extraction prompt per type:

**Gaming:** Steam, Google Play, App Store, Codashop, UniPin, Garena, Mobile Legends, Genshin Impact, Valorant, PlayStation Store, Xbox, Nintendo eShop, Epic Games

**PH Shopping:** Shopee, Lazada, Zalora, TikTok Shop, Carousell, FB Marketplace

**International:** Amazon, AliExpress, Shein, Temu, eBay, Etsy, Taobao, ASOS, Zalando, Wish

**Food Delivery:** GrabFood, Foodpanda, Shopee Food

**Rides:** Grab, Angkas, Lalamove, Maxim

**E-wallets:** GCash, Maya, GrabPay, ShopeePay, Coins.ph, PayPal, Wise

**Banks:** BPI, BDO, Metrobank, UnionBank, GoTyme, Tonik, SeaBank, RCBC

**Streaming:** Netflix, Spotify, YouTube Premium, Disney+, Viu, Vivamax

**Physical Receipts:** Fast food (Jollibee, McDonald's, KFC, etc.), Grocery (SM, Robinsons, Puregold), Pharmacy (Mercury Drug, Watsons), Bookstore, Utility bills (Meralco, PLDT, Maynilad)

---

## 7. KEY FEATURES LIST (75+)

### AI & Smart Import
- 31 agentic AI actions (autonomous data management)
- Multi-provider LLM with automatic failback (5 providers)
- Task-based model routing (fast/smart/financial_advice tiers)
- Smart Import: Live Camera, Single Photo, Batch Screenshots, Paste Text
- Barcode detection from gallery images (product lookup)
- 40+ screenshot platform types auto-detected
- Time extraction from digital receipts (GCash, bank apps)
- Screenshot contrast enhancement for dark themes (Steam)
- Per-request observability traces (latency, tokens, retry count)

### Financial Tracking
- 14 expense categories (Food, Transport, Bills, Shopping, Entertainment, Gaming, Health, Education, Personal Care, Clothing, Gifts, Travel, Pets, Others)
- Custom categories (unlimited)
- 9 payment methods (Cash, GCash, Maya, GrabPay, ShopeePay, Debit, Credit, Bank Transfer, others)
- Want vs Need tagging on every expense
- Expense photo attachment
- Transaction tags (#hashtags, filterable)
- Auto-categorization rules (keyword → category)
- Price Memory (15%+ price increase alert)
- Split Expenses (AI auto-creates debt for other person's share)

### Financial Health Score
- 4-component FHS formula (Savings Rate, Overspend Control, Budget Adherence, Logging Consistency)
- Lightweight Mode FHS (Spending Restraint, Consistency, Category Balance, Habit Streak)
- Warning Decay system (−5pts/day for ignored budget warnings)
- Logging Gap Detection (asks about unlogged days, adjusts score accordingly)
- FHS history chart (30-day trend)
- FHS Component Breakdown with actionable tips
- Financial Health Certificate (shareable monthly score card)

### Budgets & Limits
- Category budgets (fixed ₱ or % of income)
- Budget pace indicators ("ahead/behind pace")
- Graduated budget alerts (50%, 80%, 100%)
- Multi-period spending limits (daily, weekly, monthly, yearly independently)
- Smart Daily Allowance (remaining budget ÷ days left)

### Savings & Investments
- Savings Goals with progress tracking
- Emergency Fund Auto-Calculator (3/6-month target from actual spending)
- Round-Up Savings (auto-saves spare change to nearest ₱10)
- Peso Cost Averaging Calculator (MP2, UITFs, stocks)
- Idle money detection + AI investment suggestions

### Debt Management
- Debt & lending tracker
- Payment plans (ShopeePayLater, GCash GLoan, etc.)
- Debt payment strategy (avalanche/snowball AI recommendation)

### Analytics
- Pie chart, bar chart, daily trend line
- 50/30/20 Needs/Wants/Savings tracker
- Month-over-month comparison
- Spending Personality card (10 types based on actual data)
- Financial Health Score trend (30-day)
- FHS Component Breakdown chart
- DTI (Debt-to-Income) Ratio card
- Emergency Fund progress
- Spending Forecast (3/6/12-month projection)
- Mood & Spending Correlation
- Market Insights (live PHP exchange rates)
- Micro-expense clustering

### Philippine-Specific Features
- PH Banks Database (20 banks, 5 e-wallets, government contributions, investment options)
- BIR Tax Breakdown (monthly SSS, PhilHealth, Pag-IBIG, BIR deductions, take-home)
- SSS/PhilHealth/Pag-IBIG contribution calculator (AI compute_contribution action)
- Insurance & Contributions Tracker (premium due dates, overdue alerts)
- BSP Open Finance awareness (OFxPERA architecture-ready)
- Philippine Financial Calendar awareness in AI

### Behavioral Finance
- Impulse Pause (reflection prompt for large Want expenses — current day only)
- Loss Aversion budget alerts ("₱X over Food = ₱X less toward your goal")
- Spending Streaks & Challenges
- Daily Quests (10 rotating, 4 shown per day)
- 23 Achievement Badges (7 categories)
- Daily Mood Check-In with spending correlation
- Weekly Behavioral Summary notification

### Security & Privacy
- Firebase Remote Config for API keys (never in APK)
- Firebase App Check (monitoring mode; Play Integrity for Play Store)
- Per-user AI rate limiting (60 messages/day)
- App Lock (PIN + biometric, per-account)
- Full data encryption via Firebase Auth + Firestore security rules
- Per-account data isolation (logout clears local DB)
- google-services.json excluded from git repository

### Accessibility
- 3 text size levels (Normal, Large, Extra Large)
- High Contrast Mode (black/white)
- Compact Mode (reduced visual density)
- Balance Mode (wallet total as primary display)

### Cloud & Sync
- Full Firestore sync (all user data)
- Last-write-wins conflict resolution
- Offline-first architecture (SQLite as primary, Firestore as backup)
- Full backup/restore via system share sheet (JSON v9 format)
- CSV export (expenses with all fields)

### Settings & Customization
- Track income & wallets toggle (Lightweight Mode)
- Wallet auto-deduct toggle
- Daily mood check-in toggle
- Impulse pause toggle
- Budget alerts toggle
- Balance mode toggle
- Round-up savings toggle
- Compact mode toggle
- 5 color themes + dark mode

---

## 8. DATABASE SCHEMA

**SQLite v11** — 20 tables:

| Table | Purpose |
|-------|---------|
| expenses | All expense records (20+ columns) |
| budgets | Category budget limits |
| settings | Key-value app settings |
| savings_goals | Savings targets with progress |
| income | Income entries |
| recurring | Recurring transactions (bills, subscriptions) |
| debts | Debt and lending tracker |
| score_history | Daily FHS snapshots |
| scan_history | Barcode scan records |
| installment_plans | Payment plan tracking |
| custom_categories | User-defined categories |
| category_rules | Auto-categorization keyword rules |
| mood_log | Daily mood check-ins |
| recurring_candidates | Auto-detected subscription patterns |
| conversation_summaries | Compressed AI chat history |
| wallets | Cash and e-wallet balances |
| user_profile | User information |
| chat_history | AI conversation messages |
| installments | Installment payment records |
| insurance_policies | Insurance policy tracker |

**New settings keys (v2.9.3+):**
- `income_wallet_mode` — true/false (Lightweight Mode)
- `limit_daily` / `limit_weekly` / `limit_monthly` / `limit_yearly` — spending limits
- `gap_penalty_days` / `gap_clean_days` — FHS gap adjustments
- `ai_request_trace` — observability traces (last 5)

---

## 9. COMPETITOR COMPARISON (for Chapter 2)

> For the full 14-app matrix see `docs/BENCHMARK.md`.

| Feature | SmartSpend | YNAB | Monarch | Copilot | Rocket Money | Tarsi (PH) | **BudgetPH** | **Alkansya AI** | **GCash Pera Coach** |
|---------|-----------|------|---------|---------|--------------|------------|-------------|----------------|---------------------|
| AI Chat (agentic) | ✅ 31 actions | ❌ | ❌ | ⚠️ Basic | ❌ | ❌ | ⚠️ Insights | ✅ Chat | ✅ Literacy Q&A |
| Filipino-English AI | ✅ Full Taglish | ❌ | ❌ | ❌ | ❌ | ✅ Partial | ❌ | ✅ | ✅ Multiple PH languages |
| Expense Tracking | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ (advisory only) |
| Voice Input | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| OCR Receipt | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ |
| Barcode Scan | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Batch Screenshots (40+ platforms) | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Offline Mode | ✅ Full | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ | ❌ | ❌ |
| Financial Health Score | ✅ Dual-mode | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ Simpler | ❌ | ❌ |
| PH Gov (SSS/PhilHealth/Pag-IBIG) | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ Records | ❌ | ❌ |
| Paluwagan tracker | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ Full | ❌ | ❌ |
| 15th & 30th payday cycle | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ |
| Gamification (badges/quests) | ✅ 23 badges | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ XP/levels | ❌ | ❌ |
| Free (no subscription) | ✅ Always | ❌ $14.99/mo | ❌ $9.99/mo | ❌ $10.99/mo | ⚠️ Limited | ✅ | ✅ | ⚠️ Limited | ✅ (GCash required) |
| Spending Limits (multi-period) | ✅ Daily/Wk/Mo/Yr | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ |
| Logging Gap Detection | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Insurance Tracker | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Round-Up Savings | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |

**SmartSpend unique advantages:**
- Only app with 31 agentic AI actions — AI takes real autonomous actions on user data
- Only app combining Taglish AI + offline + PH financial knowledge + free + multi-modal input
- Only app with batch screenshot import (40+ platform types auto-detected)
- Only app with dual-mode FHS (Full + Lightweight) + Logging Gap Detection

**BudgetPH gap SmartSpend should address (future):**
- Paluwagan tracker — uniquely Filipino rotating savings group feature
- 15th & 30th payday cycle — payday-aware budgeting reset

---

## 10. LLM SELECTION JUSTIFICATION (for Chapter 3)

### Primary choice: Gemini 3.1 Flash-Lite (Google AI Studio)
- 1,000 requests/day FREE — sufficient for 60 req/user/day cap
- 1 million token context window
- Best reasoning quality among free models
- Filipino-English: excellent (multilingual training)
- Function calling: native support
- Not deprecated (replaces Gemini 2.5 Flash-Lite which was retired from new API users in early 2026)

### Fallback: Groq LLaMA 3.3 70B
- 14,400 requests/day FREE
- ~315 tokens/second — near-instant responses
- Strong function calling and reasoning
- Used as Fallback 2 in the auto-failover chain (Primary is Gemini 3.1 Flash-Lite)

### Why not GPT-5.6/Claude Fable 5:
Require paid API keys — not viable for academic project without budget.

### Why not self-hosted (Mistral, Phi-3, Llama.cpp):
Poor Filipino-English understanding; no reliable hosted free API; mobile hardware insufficient for quality local inference.

### Architecture quote for paper:
> "SmartSpend uses dynamic full-context injection rather than RAG because per-user financial data is compact enough to fit within the model's context window, giving the AI always-current, complete data access without the latency and infrastructure overhead of vector similarity search."

---

## 11. PANEL Q&A PREPARATION

**Q: "GCash already has Pera Coach — why does SmartSpend still matter?"**
A: GCash Pera Coach (launched March 2026, developed with Microsoft) is an AI financial literacy coach embedded inside the GCash payments app. It provides Q&A and financial education. SmartSpend is fundamentally different: it is a dedicated financial management system with 31 autonomous agentic actions, expense tracking, dual-mode Financial Health Score, offline SQLite storage, gamification, batch screenshot import, and SSS/PhilHealth/BIR integration. Pera Coach teaches concepts; SmartSpend manages actual financial behavior. They solve different problems for different user needs.

**Q: "Your LLM should do something important and heavy."**
A: SmartSpend's AI executes 31 autonomous financial management actions — from splitting bills (auto-creating debt entries), to generating a 50/30/20 salary budget plan, explaining FHS drops in plain Filipino-English, detecting forgotten subscriptions, simulating "what if I save ₱500 more/month", and routing queries to the best model for the task. This is genuine agentic AI: perceive (full financial context from SQLite) → decide → act (writes to DB directly).

**Q: "Why not RAG?"**
A: RAG is for large knowledge bases (thousands of documents). A typical user has 20-50 expenses, 5-10 budgets, 3-5 goals — small enough for full context injection. Our approach gives faster, always-current data access without vector search overhead.

**Q: "What if the API goes down?"**
A: 5-provider automatic fallback: Gemini 3.1 Flash-Lite → Gemini 3.5 Flash → Groq LLaMA 3.3 70B → Groq LLaMA 3.1 8B → Cerebras. Manual expense entry via the form works fully offline without AI.

**Q: "Why no bank integration?"**
A: Philippine open banking (BSP Open Finance) only launched in pilot in July 2025 with UnionBank as the first participant. SmartSpend is architecturally ready for integration as the framework matures. Currently, users import via GCash/bank history text paste or batch screenshot import (40+ platforms).

**Q: "Your AI gives financial advice — isn't that illegal?"**
A: SmartSpend provides general financial guidance and education, not personalized financial advice. There is a legal distinction — personalized advice requires a licensed professional and fiduciary duty. The app explicitly disclaims this (About screen, AI responses). This approach is consistent with Mint, YNAB, and Cleo globally.

**Q: "How does the FHS formula work?"**
A: Four components, 25 points each, total 100. In full mode: Savings Rate (saving ≥20% of income), Overspend Control (days within daily budget), Budget Adherence (category budgets on track), Logging Consistency (regularity of entries this month). In Lightweight Mode (no income tracking): Spending Restraint (vs spending limit), Consistency, Category Balance, Habit Streak. Plus two score adjustments: Warning Decay (budget violations) and Gap Adjustment (verified clean/spent days).

**Q: "How is the score different from other apps?"**
A: Most apps show a static credit-score-like number. SmartSpend's FHS is computed in real-time from this month's actual data, adapts to whether the user tracks income or not, and incorporates user behavior (gap confirmations, budget responses) into the calculation. It also fires an alert when it drops 10+ points overnight.

---

## 12. SUS EVALUATION (for Chapter 3 & 4)

**Target:** ≥80 (Good classification per Bangor et al., 2009)

**Scale:**
- ≥85: Excellent
- 80–84: Good
- 68–79: Above Average
- 51–67: Below Average
- <51: Poor

**Process:**
1. Participant uses app (30 minutes guided exploration)
2. Completes 10-item SUS questionnaire (1-5 Likert)
3. Score = (odd-item scores − 1) + (5 − even-item scores), sum × 2.5

**Validators:** Subject matter expert in financial management (survey content validation) + subject matter expert in IT (system and SUS process validation) — credentials documented in validation certificates, name optional per evaluator preference.

---

## 13. FINANCIAL ADVICE DISCLAIMER

*Must appear in the paper and the app:*

> "SmartSpend provides general financial information and tracking tools for educational purposes only. This application is not a licensed financial advisor, investment advisor, insurance broker, or tax consultant. Nothing in this application constitutes personalized financial, investment, insurance, or tax advice. Users should consult a licensed financial professional before making significant financial decisions. SmartSpend is not liable for any financial losses resulting from actions taken based on information provided by this application."

**Philippine legal basis:**
- Securities and Exchange Commission (SEC-PH) — licenses investment advisors
- Insurance Commission (IC) — licenses insurance agents
- Bangko Sentral ng Pilipinas (BSP) — regulates financial products
- RA 11765 (Financial Products and Services Consumer Protection Act)

---

## 14. KEY REFERENCES (APA Format)

- Bangko Sentral ng Pilipinas. (2021). *2021 Financial Inclusion Survey*. BSP.
- Bangko Sentral ng Pilipinas. (2025). *Consumer Finance and Inclusion Survey (CFIS) 2025*. BSP.
- Bangor, A., Kortum, P., & Miller, J. (2009). Determining what individual SUS scores mean: Adding an adjective rating scale. *Journal of Usability Studies, 4*(3), 114–123.
- Bloomberg. (2026). *How the Philippines' first fintech unicorn is minting financial inclusion*. https://sponsored.bloomberg.com/article/mynt/how-the-philippines-first-fintech-unicorn-is-minting-financial-inclusion
- Brooke, J. (1996). SUS: A "quick and dirty" usability scale. In P. W. Jordan et al. (Eds.), *Usability Evaluation in Industry* (pp. 189–194). Taylor & Francis.
- Davis, F. D. (1989). Perceived usefulness, perceived ease of use, and user acceptance of information technology. *MIS Quarterly, 13*(3), 319–340.
- Deloitte. (2026). *Agentic AI boosts wealth management*. https://www.deloitte.com/us/en/insights/industry/financial-services/financial-services-industry-predictions/2026/agentic-ai-wealth-management-productivity.html
- Ernst & Young. (2026). *Nearly half of global consumers now use AI to guide savings and investment decisions*. https://www.ey.com/en_gl/newsroom/2026/04/nearly-half-of-global-consumers-now-use-ai-to-guide-savings-and-investment-decisions
- Financial Health Network. (2021). *FinHealth Score® Toolkit*. https://finhealthnetwork.org/tools/financial-health-score/
- Financial Health Network. (2026). *From insight to impact: The next phase of financial health measurement*. https://finhealthnetwork.org/research/from-insight-to-impact-the-next-phase-of-financial-health-measurement/
- Flores, M. (2025). Financial freedom of Filipino workers: Attitudes and practices. [Research study].
- GCash / Mynt. (2026). *GCash launches country's first AI financial coach* [Press release]. https://www.prnewswire.com/apac/news-releases/ph-fintech-gcash-launches-countrys-first-ai-financial-coach-embedded-in-e-wallet-to-strengthen-financial-literacy-302718569.html
- Insurance Commission Philippines. (2025). *Philippine Insurance Market Report 2025*.
- Juniper Research. (2026). *Gamification in Banking: How Game Mechanics Drive Financial Behavior Change*.
- Meyll, T., et al. (2025). Spendception: The psychological impact of digital payments on consumer purchase behavior and impulse buying. *Behavioral Sciences, 15*(3), 387. https://doi.org/10.3390/bs15030387
- NielsenIQ. (2026). *The new financial reality: How Filipino consumers are spending, saving, and banking in 2026*. https://nielseniq.com/global/en/insights/report/2026/the-new-financial-reality-how-filipino-consumers-are-spending-saving-and-banking-in-2026/
- Philippine Statistics Authority. (2021). *Family Income and Expenditure Survey (FIES) 2021*. PSA.
- Philippine Statistics Authority. (2025). *Philippine Digital Economy Satellite Account (PDESA) 2025*. PSA. https://psa.gov.ph
- Plaid. (2026). *State of intelligent finance report — Spring 2026*. https://plaid.com/blog/state-of-intelligent-finance-report-spring-2026/
- Springer. (2025). *Exploring the psychological and behavioral effects of mobile payment systems on consumer spending*. In *Lecture Notes in Networks and Systems*. https://link.springer.com/chapter/10.1007/978-3-031-84636-6_26
- Springer. (2026). *Digital nudges and financial inclusion: A study on behavioral interventions influencing rural consumers' adoption of formal financial services*. In *Lecture Notes in Networks and Systems*. https://link.springer.com/content/pdf/10.1007/978-3-032-00343-0_14.pdf
- Thaler, R. H., & Sunstein, C. R. (2008). *Nudge: Improving decisions about health, wealth, and happiness*. Yale University Press.
- Wajid, F., et al. (2025). Gamification: Revolutionizing financial planning systems. *World Journal of Advanced Engineering Technology and Sciences*. https://www.wjaets.com/sites/default/files/fulltext_pdf/WJAETS-2025-0158.pdf
- Warren, E., & Tyagi, A. W. (2005). *All your worth: The ultimate lifetime money plan*. Free Press.

---

## 15. VERSION HISTORY (for paper)

| Version | Date | Key Additions |
|---------|------|--------------|
| 1.0 (Capstone 1) | 2024–2025 | Basic expense tracking, manual entry |
| 2.0 | Jan 2026 | AI chat (first version), basic analytics |
| 2.5 | Mar 2026 | Multi-modal input (voice, OCR, barcode), wallet system |
| 2.6 | Apr 2026 | Release signing, Google Sign-In fix |
| 2.7 | May 2026 | 10 quests, DTI, Emergency Fund, PCA Calculator |
| 2.8 | Jun 2026 | 23 badges (up from 16), 31 AI actions, Insurance tracker, Bank comparison, split_expense |
| 2.9 | Jul 2026 | Lightweight Mode, Multi-period limits, Logging Gap Detection, Batch Screenshot Import |
| 2.9.1 | Jul 28, 2026 | Unified Smart Import, barcode-from-gallery, FHS dual-mode docs, security hardening, bug fixes |
| 2.9.2 | Aug 2026 | Full docs cleanup, BENCHMARK.md (14 apps, 13 LLMs), SYSTEM_OVERVIEW.md, 19 manuscript fixes, credential-based validator certificates, AY2026-2027 sweep |
| 2.9.3 | Aug 2026 | Per-section visibility toggles (10 new App Settings), RESEARCH_BASIS.md, APPLICATION_PIPELINE.md added |
| 2.9.4 | Aug 2026 | 6 bug fixes: FHS gap reload, subscription overlap, analytics score sync, limit card overlap, lightweight spending restraint cross-period, stale model names in about/ai screens |
| 2.9.5 | Aug 2026 | Weekly Category Card (High/Normal/Low vs usual), Financial Management Score, FHS trend, enriched breakdown dialog, 9 new research sources |
| 2.9.6 | Aug 2026 | App Settings fully rebuilt (DraggableScrollableSheet, scrollable), Lite Mode one-tap toggle, all grayed-out restrictions removed; docs sweep + research expansion (Parts 12–13 new sources, GCash Pera Coach competitor, EY/Plaid/PSA 2026 stats) |
| 2.9.7 | Aug 2026 | Comprehensive audit fixes (30+ issues); FMS + Weekly Category Card on Home+Analytics; FHS unmeasured label; recurring auto-add; ScanReviewScreen dedup fix; 30+ docs fixes across 9 files |
| 2.9.8 | Sep 2026 | AI coverage expansion: 31 agentic actions (added set_spending_limit + add_insurance_policy); Taglish triggers for all action types; budget routing to smart tier; set_budget fallback parser; auto-rules in context; multi-item logging typo resilience |

---

*SmartSpend v2.9.8 — Lucid Frame*
*Lorma Colleges, CCSE, BSIT, City of San Fernando, La Union — 2026–2027 (1st Semester)*
*Last updated: September 2, 2026*
