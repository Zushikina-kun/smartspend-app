# Smart Spend — Capstone Defense Reviewer
**Version 2.7.0 | May 20, 2026 | Lucid Frame**

---

## What is Smart Spend?

Smart Spend is an **AI-assisted mobile financial tracking and advisory application** for Android. It helps users record expenses, manage budgets, track debts and savings goals, and get personalized financial advice — all through natural language conversation with an AI assistant.

**Core concept:** User Input → AI Parsing → Structured Data → Local Database → Analytics & Insights

---

## What problem does it solve?

Most Filipinos — especially students and young professionals — don't track their finances because traditional methods (spreadsheets, manual apps) are too tedious. Smart Spend removes that friction by letting users just *talk* to the app the way they'd talk to a friend. You say "I spent 85 pesos on lunch" and the app logs it — no forms, no dropdowns, no manual entry required.

---

## Technology Stack

| What | Technology | Why |
|------|-----------|-----|
| App framework | Flutter (Dart) | Cross-platform, single codebase, near-native performance |
| AI/LLM | Large Language Model (LLM) API — LLaMA 3.1 8B | Fast inference, understands Filipino English, free tier for academic use |
| Local database | SQLite via sqflite (v11) | Works offline, fast, no cost, stores all financial data on-device |
| Cloud sync | Firebase Firestore | Free tier, bidirectional sync, user-level security rules |
| Authentication | Firebase Auth | Google Sign-In + email/password |
| OCR | Google ML Kit Text Recognition | On-device, no API key, works offline |
| Barcode | mobile_scanner + ML Kit | Live detection + image-based scanning |
| Notifications | flutter_local_notifications | Budget alerts, debt reminders, daily briefing |

> **Note for defense:** We refer to the AI as "LLM API" in documents to stay technology-agnostic. The specific model is LLaMA 3.1 8B Instant — an open-source model by Meta, accessed via Groq's inference API.

---

## AI Architecture — Agentic AI with Context Injection

**What makes it Agentic:**
The AI doesn't just answer questions — it takes **autonomous actions** on the user's data. When you say "I spent 150 pesos on jeepney," the AI parses that, decides it's a Transportation expense, and writes it directly to the SQLite database. No confirmation needed. This is genuine agentic behavior: **perceive → decide → act**.

**How context injection works:**
Before every single AI message, the app runs a database query and builds a context string containing:
- Your last 50 expenses (recent 20 in detail, older ones summarized by category)
- All your budget limits and how much you've spent per category
- Your monthly income/allowance
- Your savings goals and current progress
- Your debts and lending records
- Your recurring bills and their due dates
- Your installment balances

This entire context is injected into the AI's system prompt before it processes your message. The AI always uses this live data — it cannot make up numbers that aren't in the database.

**Why not RAG (Retrieval-Augmented Generation)?**
RAG uses a vector database and embedding similarity search to find relevant document chunks. It's designed for large knowledge bases with thousands of documents. Our per-user financial data (50 expenses, 8 budgets, 5 goals, etc.) is small enough to fit entirely in one prompt — making RAG unnecessary overhead. Our approach is a **lightweight, mobile-optimized alternative** that achieves the same goal without the infrastructure complexity.

**The 11 AI action types:**

| Action | What it does | Example trigger |
|--------|-------------|----------------|
| `log_expense` | Writes a new expense to the DB | "I spent 30 pesos for jeepney" |
| `set_budget` | Creates or updates a category budget | "Set my food budget to 2000 pesos" |
| `set_income` | Updates monthly income/allowance | "My allowance is 6600 pesos" |
| `add_goal` | Creates a new savings goal | "I want to save 35000 for a laptop" |
| `update_goal` | Adds contribution to a goal | "I added 500 to my laptop fund" |
| `add_income` | Logs a one-time income entry | "I received my allowance" |
| `add_debt` | Records money owed or lent | "I borrowed 500 from Kuya Mark" |
| `add_recurring` | Creates a recurring bill/income | "Add Netflix 299 pesos monthly" |
| `set_account_type` | Changes account type | "I'm a student" |
| `update_expense` | Edits an existing expense | "Change that Sting to Food category" |
| `delete_expense` | Removes an expense (requires typing DELETE) | "Delete the wrong entry: DELETE" |

---

## Financial Health Score — Exact Formula

**Where to find it:** Home screen (tap the score card) → full breakdown. Also in Profile screen.

**What it measures:** How well you're managing your money this month, based on 4 equally-weighted components.

### The 4 Components (25 pts each)

**Component 1 — Savings Rate (25 pts)**
- Measures: are you saving at least 20% of your income?
- Formula: 25 × min(1, savingsRate / 0.20)
- savingsRate = (income − totalSpent) / income
- Full 25 pts when saving ≥20%; scales down proportionally below that
- Example: income ₱6,600, spent ₱4,000 → savingsRate = 39% → 25 × min(1, 39/20) = 25 pts ✓

**Component 2 — Overspend Control (25 pts)**
- Measures: how many days did you stay within your daily budget?
- Formula: 25 × (1 − overDays / activeDays)
- dailyBudget = monthlyIncome / daysInMonth
- Full 25 pts when no days exceeded; 0 pts when every day exceeded
- Example: 2 of 10 logged days exceeded daily budget → 25 × (1 − 2/10) = 20 pts

**Component 3 — Budget Adherence (25 pts)**
- Measures: what % of your budget categories stayed within limit?
- Formula: 25 × (onBudgetCategories / totalBudgetCategories)
- Full 25 pts when all budgets on track; 0 pts when all exceeded
- If no budgets set: 25 pts (not penalized)
- Example: 3 of 4 budgets on track → 25 × (3/4) = 18.75 pts

**Component 4 — Logging Consistency (25 pts)**
- Measures: how regularly are you logging expenses?
- Formula: 25 × (loggedDays / activeDays)
- activeDays = days elapsed this month
- Full 25 pts when logging every day; scales proportionally
- Example: logged 8 of 10 days → 25 × (8/10) = 20 pts

### Warning Decay System
If a budget is exceeded and spending continues the next day, the score loses 5 pts/day (max 3 days = −15 pts total). Resets when all budgets return to on-track.

3-tier escalation notifications:
- Day 1: Gentle nudge
- Day 2: Strong alert with spending comparison
- Day 3: Critical warning with projected monthly overspend

### Practical Example with Demo Data
- Income: ₱6,600 | Spent: ~₱4,100
- Savings Rate: (6600−4100)/6600 = 38% → 25 pts ✓
- Overspend Control: assume 1 of 8 days over → 25 × (7/8) = 21.9 pts
- Budget Adherence: 6 of 8 budgets on track → 25 × (6/8) = 18.75 pts
- Logging Consistency: logged 8 of 10 days → 25 × (8/10) = 20 pts
- **Total: ~86 pts (Good 🟢)**

---

## Want vs Need Tagging — How It Works

**Where to use it:** When adding or editing any expense, there's a **Need / Want toggle** (two chips below the category dropdown).

**What it means:**
- **Need** = essential spending you can't avoid (food, transport, bills, medicine, tuition)
- **Want** = discretionary spending you chose to do (Shopee, cinema, Jollibee when you could cook)

**How to tag:**
1. Tap the AI button or Manual Entry (pencil icon)
2. Fill in the expense details
3. Below the Category dropdown, tap either **Need** or **Want**
4. Save — the tag is stored with the expense

**Where to see the result:**
Analytics screen → scroll down past the 50/30/20 tracker → **Wants vs Needs** stacked bar chart shows the split for the current period.

*Example: ₱3,200 Needs (72%) vs ₱1,200 Wants (28%) — you can immediately see how much of your spending was discretionary.*

**Default:** All existing expenses default to Need (0) — nothing breaks if you don't tag.

---

## 50/30/20 Rule — How It Works

**Where:** Analytics screen → 50/30/20 Rule Tracker card. Always uses this month's data regardless of the period filter.

**The rule:** A popular personal finance guideline that says:
- **50%** of income → Needs (Food, Transportation, Bills, Health)
- **30%** of income → Wants (Shopping, Entertainment, and anything not essential)
- **20%** of income → Savings (what's left after spending)

**How the app calculates it:**
1. Takes your declared monthly income
2. Categorizes your this-month expenses: Food/Transport/Bills/Health = Needs; everything else = Wants
3. Savings = Income − Total Spent
4. Shows each as a progress bar vs the target
5. Gives a verdict: "On track ✓" or "Wants over by ₱X"

*Example: Income ₱6,600 → Needs target ₱3,300 (50%), Wants target ₱1,980 (30%), Savings target ₱1,320 (20%)*

---

## Cash Flow Forecast — How It Works

**Where:** Home screen → Cash Flow card (shows when income is set).

**Formula:** Income − Spent this month − Upcoming bills (next 30 days) = Projected remaining

**How it calculates upcoming bills:**
- Looks at all recurring transactions where `next_date` is within the next 30 days
- Sums their amounts
- Subtracts from remaining balance

**Shortfall warning:** If the projected remaining goes negative, a red warning appears.

*Example: Income ₱6,600 − Spent ₱2,500 − Bills due ₱3,629 (tuition + Spotify) = ₱471 remaining*

---

## Budget % of Income Mode — How It Works

**Where:** Hub → Budgets → tap + Add Budget or edit existing → toggle between **Fixed ₱** and **% of income**.

**What it does:** Instead of typing a fixed peso amount, you set a percentage. The app automatically calculates the budget from your monthly income.

*Example: Set Food to 30% → income ₱6,600 → Food budget = ₱1,980 automatically. If you update your income later, the budget updates too.*

**Why it's useful:** Follows the 50/30/20 rule naturally — you can set Food + Transport + Bills to 50% total, Shopping + Entertainment to 30%, and the math works out automatically.

---

## Daily Spending Limit — How It Works

**Where to set it:** Profile → Daily Spending Limit → enter your daily cap (e.g. ₱300).

**How it works:**
1. Every time you log an expense, the app sums all expenses for today
2. Compares today's total to your daily limit
3. Home screen shows a progress bar: today's spending / daily limit
4. Push notification fires at 80% of limit
5. Another notification fires when you exceed it

**Hidden when:** Limit is 0 or not set — it's opt-in.

---

## Streaks & Badges — How They're Calculated

**Where:** Home screen → Achievements row (appears when you've earned at least one badge).

**How streaks work:**
The app looks at your Financial Health Score history (stored daily in the database). It counts consecutive days where your score was 60 or above (Fair or better). That's your streak.

**Badge types and conditions:**

| Badge | Condition |
|-------|-----------|
| 🔥 X-day streak | X consecutive days with score ≥ 60 (starts at 3 days) |
| 💯 Week on track | 7+ consecutive days with score ≥ 60 |
| 🏆 30-day champion | 30+ consecutive days with score ≥ 60 |
| 💰 ₱1K+ saved | Any savings goal has ₱1,000+ contributed |
| 🎯 Goal reached | Any savings goal is 100% funded |
| 📅 Active tracker | Logged at least one expense today AND have 7+ days of history |

---

## Bill Calendar — How It Works

**Where:** Hub → Bill Calendar.

**What it shows:** A monthly calendar grid where days with recurring bills due are highlighted in orange with a dot. The dot count shows how many bills are due that day.

**How it determines which days to highlight:**
- Looks at all recurring transactions in your database
- For each one, checks if `next_date` falls in the currently displayed month
- Plots it on that day

**Tap any highlighted day** → bottom sheet shows the bill name, category, frequency, and amount.

**Month navigation:** Left/right arrows to browse past and future months.

---

## Shake to Undo — How It Works

**Where:** AI screen only (the shake detector is only active there).

**How it works:**
1. After the AI successfully logs an expense, creates a goal, adds a debt, etc. — the action is stored in memory with a 60-second timer
2. If you shake the phone firmly within 60 seconds, a confirmation sheet appears
3. Tap "Undo" → the action is reversed in the database
4. The undo buffer is cleared after: 60 seconds pass, a new action is taken, you leave the AI screen, or you log out

**What can be undone:** log_expense, add_goal, add_income, add_debt, add_recurring, set_budget, update_expense, update_goal

**What cannot be undone:** delete_expense, set_income, set_account_type (these are considered intentional)

**Shake threshold:** 2.7g — firm shake, not accidental movement.

---

## Custom Categories — How It Works

**Where to manage:** Profile → Manage Categories, or Hub → Categories.

**How it works:**
- Built-in 8 categories (Food, Transportation, Bills, Shopping, Entertainment, Health, Education, Others) are locked — cannot be deleted or renamed
- You can add your own (e.g. "School", "Church Offering", "Pets", "Org Fees")
- Custom categories appear in all dropdowns: Add Expense, Edit Expense, Budget, Recurring
- The AI is aware of your custom categories — you can say "Log ₱200 for org fee under School" and it will use your custom School category
- Custom categories sync to Firestore and are included in backup/restore

---

## Expense Photo Attachment — How It Works

**Where:** Add Expense screen or Edit Expense screen → "Attach receipt photo" button at the bottom of the form.

**How it works:**
1. Tap the button → choose Camera (take a new photo) or Gallery (pick existing)
2. Photo is saved to the device's local storage
3. The file path is stored in the expense record in the database
4. The expense tile in the transaction list shows a thumbnail of the photo
5. Tap the thumbnail → full-screen view

**Important:** Photos are stored locally only. They are NOT synced to Firestore (file paths are device-specific). They ARE included in the JSON backup file.

---

## Net Worth — How It's Calculated

**Where:** Profile screen → Net Worth card.

**Formula:**
```
Net Worth = Total Income Logged + Manual Assets − Total Expenses − Outstanding Debts − Installment Remaining Balances
```

**Each component:**
- **Total Income Logged** — sum of all income entries in the database
- **Manual Assets** — tap the Net Worth card → add savings account balance, cash on hand, investments, property value (anything not tracked in the app)
- **Total Expenses** — sum of all expense entries ever logged
- **Outstanding Debts** — sum of (amount − paid_amount) for all debt entries
- **Installment Remaining Balances** — sum of (months remaining × monthly payment) for all installments

---

## SSS / PhilHealth / Pag-IBIG Presets — How to Use

**Where:** Hub → Recurring Transactions → tap the **+** icon in the top AppBar (not the FAB).

**What appears:** A popup menu with three presets:
- SSS Contribution — ₱1,125/month
- PhilHealth Contribution — ₱500/month
- Pag-IBIG Contribution — ₱200/month

**Tap any preset** → it's added instantly as a monthly recurring bill. Long-press it afterward to edit the amount to match your actual contribution bracket.

---

## Questions Your Panel Might Ask

**Q: How does the Financial Health Score work?**
A: It uses a 4-component weighted formula — 25 points each, totaling 100. Component 1 is Savings Rate: are you saving at least 20% of your income? Component 2 is Overspend Control: how many days did you stay within your daily budget? Component 3 is Budget Adherence: what percentage of your budget categories stayed within limit? Component 4 is Logging Consistency: how regularly are you logging expenses? Each component scales proportionally — you don't just get full points or zero, it's a gradient. There's also a warning decay system: if you ignore a budget warning and keep spending in that category, the score loses 5 points per day for up to 3 days. Tap the score card on the home screen to see the exact breakdown.

**Q: Who is this app for? Is it only for students?**
A: No — it's for anyone. The app has 8 account types: Employed, Business Owner, Freelancer, Working Student, Student, Pensioner/Retiree, Unemployed, and General/Other. Each type adapts the app's labels, income categories, budget suggestions, and which analytics cards are shown. A student sees "Allowance", a pensioner sees "Pension", a freelancer gets project-based frequency options. The General/Other type gives full flexibility for anyone who doesn't fit a specific category.

**Q: How does Want vs Need tagging work?**
A: When you add or edit any expense, there's a Need/Want toggle below the category dropdown. You choose which one applies. The Analytics screen then shows a stacked bar chart breaking down your spending into Needs vs Wants with percentages. It's separate from the 50/30/20 tracker — that one uses category-based classification, while Want/Need is user-defined per expense.

**Q: What's the difference between the 50/30/20 tracker and the Want/Need breakdown?**
A: The 50/30/20 tracker automatically classifies categories — Food, Transport, Bills, Health are always Needs; Shopping, Entertainment are always Wants. The Want/Need breakdown is manual — you decide per expense. They complement each other: 50/30/20 gives a quick automatic view, Want/Need gives a more nuanced personal view.

**Q: How does the Cash Flow Forecast work?**
A: It takes your monthly income, subtracts what you've already spent this month, then subtracts all recurring bills due in the next 30 days. The result is your projected remaining balance. If it goes negative, a shortfall warning appears.

**Q: How does the AI know my financial data?**
A: Before every AI message, the app queries the local SQLite database and builds a context string with your last 50 expenses, all budget limits and spending, income, goals, debts, and recurring bills. This is injected into the AI's system prompt. The AI uses this as its single source of truth — it cannot hallucinate numbers that aren't in the database.

**Q: What is Agentic AI?**
A: Agentic AI means the AI doesn't just answer questions — it takes autonomous actions. In Smart Spend, when you say "I spent 150 pesos on lunch," the AI parses the intent, decides it's a Food expense, and writes it directly to the database without you filling any form. It perceives your intent, decides what to do, and acts on it. That's the agentic loop: perceive → decide → act.

**Q: Why Flutter and not native Android?**
A: Flutter lets us write one codebase that works on both Android and iOS. For a 3-person team, this is significantly more efficient. Performance is near-native because Flutter compiles to native ARM code, not interpreted bytecode.

**Q: Why use an LLM API and not build your own AI?**
A: Training a custom NLP model for expense parsing would require thousands of labeled Filipino expense descriptions, GPU compute resources, and months of training — all beyond the scope of a capstone. Using a pre-trained LLM API lets us focus on the application logic and user experience while still delivering genuine AI capabilities. The model (LLaMA 3.1 8B) is open-source and was trained by Meta on multilingual data including Filipino English.

**Q: Is the data secure?**
A: Data is stored locally in SQLite on the device. Cloud sync uses Firebase Firestore with security rules that only allow the authenticated user to read/write their own data. The app also has PIN + biometric lock. The AI API has a 60-message daily cap to prevent abuse of the shared key.

**Q: What happens when there's no internet?**
A: All core features work offline — manual expense logging, viewing transactions, all analytics, budgets, goals, debts, recurring. Only AI chat and cloud sync require internet. The app shows an offline banner when disconnected and degrades gracefully — no crashes.

**Q: What's the difference between your app and GCash or a bank app?**
A: GCash and bank apps handle actual money movement — transfers, payments, top-ups. Smart Spend is a tracker and advisor — it doesn't touch your money. It helps you understand and manage your spending behavior across all your accounts and payment methods in one place, regardless of whether you pay by cash, GCash, card, or any other method.

**Q: What are the limitations?**
A: The AI has a 60-message daily limit (shared API key for academic use). Receipt OCR accuracy depends on photo quality and lighting. The app is currently Android-only. Profile photos don't sync across devices (Firebase Storage requires a paid plan). Real-time cross-device sync requires Cloud Functions (also paid plan).

**Q: Does it use RAG?**
A: No. RAG (Retrieval-Augmented Generation) is designed for large knowledge bases with thousands of documents requiring vector similarity search. Our per-user financial data — 50 expenses, 8 budgets, a few goals — is small enough to fit entirely in a single prompt. We use direct context injection instead, which is simpler, faster, and more appropriate for our use case.

---

## Demo Script (Practice This)

### Opening (30 seconds)
"Smart Spend is an AI-assisted financial tracking app. Instead of filling forms, you just tell it what you spent — like talking to a friend. Let me show you."

### Demo Flow
1. **Load demo data** — Profile → Load Demo Data (or Try Demo from login)
2. **Show home screen** — point out: this month's spending, cash flow card, health score
3. **Log an expense via AI** — type "I spent 85 pesos for lunch at the canteen" → show it log instantly
4. **Show the health score breakdown** — tap the score card, explain each factor
5. **Show analytics** — pie chart, 50/30/20 tracker, explain the rule
6. **Show Want/Need** — go to Add Expense, show the Need/Want toggle, explain it
7. **Show the scanner** — open camera, scan a barcode, show the review screen
8. **Show Hub** — tap Hub, explain each tile briefly
9. **Show Bill Calendar** — Hub → Bill Calendar, explain the orange dots
10. **Reset AI limit** before presenting — AI screen → ⋮ → Reset Daily Limit

### If asked about a feature you're unsure about
"That's handled by [feature name]. Let me show you — [navigate to it]. The logic is [explain from this document]."

---

## Things to Practice Before the Defense

1. **Know the health score formula cold** — 4 components × 25 pts: Savings Rate, Overspend Control, Budget Adherence, Logging Consistency
2. **Know the 50/30/20 rule** — 50% Needs, 30% Wants, 20% Savings
3. **Know the difference** between 50/30/20 (automatic by category) and Want/Need (manual per expense)
4. **Know the AI architecture** — context injection, not RAG, agentic behavior
5. **Know the offline capabilities** — everything except AI chat and cloud sync works offline
6. **Know the new features** — Spending Forecast (home), FHS Component Breakdown (Analytics), Onboarding Quiz (setup), Weekly Behavioral Summary + Anomaly Detection (Sunday notifications)
7. **Reset AI limit** before presenting (AI screen → ⋮ → Reset Daily Limit)
8. **Load demo data** if starting fresh (Profile → Load Demo Data) — shows 14 days of score history, realistic FHS ~77
9. **Know your team roles** — Brix: Lead Developer, Cyrille: UI/UX Designer & Documentation Lead, Djaunathan: Project Manager & QA Lead

---

## Key Numbers to Remember

| Item | Value |
|------|-------|
| Version | 2.4.0 |
| Platform | Android (Flutter) |
| Database | SQLite version 11 |
| AI model | LLaMA 3.1 8B Instant (Meta, open-source) |
| Daily AI limit | 60 messages |
| Currencies supported | 34+ |
| AI action types | 11 |
| Screens | 37+ |
| Services | 22+ |
| Help sections | 25 |
| Features listed in About | 36 |
| Group | Lucid Frame |
| School | Lorma Colleges — CCSE, BSIT |
| Location | City of San Fernando, La Union |
| Academic Year | 2025–2026 |
| Last build | May 3, 2026 — 5:59 PM (44.72 MB arm64-v8a) |

---

*You built something genuinely impressive. The key to a good defense is not memorizing everything — it's understanding the logic well enough to explain it in your own words. Read this once a day until the defense. 🎯*
