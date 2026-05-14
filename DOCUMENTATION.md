# Smart Spend — Application Documentation

**Version:** 2.6.0
**Group:** Lucid Frame
**Platform:** Android (Flutter)
**Academic Year:** 2025–2026
**Last Updated:** May 14, 2026 (v2.6.0 — Session 12 final: AI action fallback, wallet auto-deduct, app settings, balance mode, daily quests, log allowance, tutorial replay fix, Google photo fallback, demo data updated)
**Build:** app-arm64-v8a-release.apk — 45.4 MB (May 14, 2026)

---

## 👥 Development Team

| Name | Role |
|------|------|
| Brix A. Directo | Lead Developer |
| Cyrille John M. Rubis | UI/UX Designer & Documentation Lead |
| Djaunathan Albert S. Madayag | Project Manager & QA Lead |

---

## 📌 Project Overview

**Smart Spend** is an AI-assisted mobile financial tracking and advisory application built with Flutter for Android. It enables users to automatically record expenses through multiple input methods (voice, OCR, barcode, manual text), analyze spending behavior, and receive personalized AI-generated financial insights and advice.

### Core Concept
> User Input → AI Parsing → Structured Data → Local Database → Analytics & Insights

Smart Spend is **not** a banking app. It does not process payments or transfer money. It is a smart recorder, analyzer, and financial advisor designed for everyday Filipinos — from students to business owners.

---

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Flutter UI Layer                       │
│  Screens: Home, Analytics, AI Chat, Profile, Budget,        │
│  Goals, Income, Debt, Recurring, Transactions, Currency     │
└──────────────────────────┬──────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────┐
│                      Services Layer                         │
│  LLMService  │  AIChatService  │  InsightService            │
│  DBService   │  CloudService   │  AuthService               │
│  VoiceService│  OCRService     │  ScoreService              │
│  CurrencyService │ TaxService  │  PredictService            │
│  ExportService   │ DemoService │  NotificationService       │
│  BackupService   │ EventBus    │  ThemeService              │
└──────┬────────────────────────────────┬─────────────────────┘
       │                                │
┌──────▼──────┐              ┌──────────▼──────────────────────┐
│   SQLite    │              │   Firebase (Firestore +          │
│  (Local DB) │              │   Auth + Crashlytics)           │
│  version 11 │              └──────────────────────────────────┘
└─────────────┘                         │
                              ┌──────────▼──────────┐
                              │   Groq API           │
                              │  (LLaMA 3.1 8B)      │
                              └──────────────────────┘
                                         │
                              ┌──────────▼──────────┐
                              │  open.er-api.com     │
                              │  (Exchange Rates)    │
                              └──────────────────────┘
```

---

## 📱 Features

### 1. Multi-Modal Expense Input

All input methods are accessible from the AI chat screen via 3 buttons in the input bar: Camera, Voice, and Manual Entry.

| Method | Description |
|--------|-------------|
| **Voice** | Tap the mic button — speak naturally, AI parses and logs automatically |
| **Smart Scanner** | Tap the camera button — live viewfinder auto-detects barcodes/QR; receipt mode toggle for tall receipts; shutter for OCR; gallery import available |
| **Manual Entry** | Tap the pencil button — opens a form with all fields pre-shown; date picker included; works fully offline without AI |
| **AI Chat (text)** | Type in plain language — AI parses and logs directly |

**Manual Entry form:** Item name, amount, category, payment method, shop, notes, date picker. AI can optionally pre-fill fields via the Analyze button, but the form is always usable without it.

**Smart Scanner pipeline:** Camera → Mode toggle (Barcode/Receipt) → Auto-detect (barcode or OCR) → Smart routing:
- **Barcode/QR** → Scan Review Screen → describe product → AI chat
- **Receipt with 3+ prices or "total"** → "Import Items" button → Import Receipt screen → AI parses items → review table → bulk import
- **Simple text/single item** → Scan Review Screen → AI chat

**Scanner features:**
- Live barcode/QR auto-detection with animated detection box
- Receipt mode toggle — switches guide from 260×260 square to 220×360 tall rectangle (amber color)
- Shutter button for receipt/document OCR with orientation fix
- Gallery import — barcode-first, falls back to OCR
- Barcode repeat detection — shows "[Scanned X times before]" if previously scanned
- OCR quality check — warns user if extracted text looks garbled
- Torch toggle
- **"Import Items" button** in Scan Review Screen — appears when 3+ price lines detected
- **Receipt import mode** in BankImportScreen — uses LLMService.parseReceipt() for item-level extraction
- Auto-parses when opened from OCR (no manual "Parse" tap needed)

All AI-parsed inputs pass through `LLMService.parseExpense()` which returns structured JSON:
`item_name`, `category`, `amount`, `date`, `shop_name`, `payment_method`, `confidence_score`

Low-confidence entries (< 0.7) are flagged with an orange dot on the expense tile.

---

### 2. AI Engine (Groq API — LLaMA 3.1 8B Instant)
- **Expense Parsing** — converts natural language to structured expense data
- **Spending Insights** — analyzes patterns and generates bullet-point insights on the dashboard
- **Financial Advice** — personalized tips based on income, spending, and predictions
- **AI Chat** — conversational assistant with full financial context injection

#### AI Architecture — Agentic AI with Context Injection

Smart Spend uses an **agentic AI architecture with dynamic context injection** — a lightweight, mobile-optimized alternative to full RAG (Retrieval-Augmented Generation).

**What makes it Agentic:**
The AI doesn't just answer questions — it autonomously executes actions on the user's data. It perceives the user's financial context, decides what action to take, and writes directly to the local SQLite database. This is genuine agentic behavior: perceive → decide → act.

**Why not full RAG:**
RAG (Retrieval-Augmented Generation) uses a vector database and embedding similarity search to retrieve relevant document chunks before each query. This is designed for large knowledge bases (thousands of documents). Smart Spend's per-user financial data (20 expenses, 8 budgets, 5 goals, etc.) is small enough to fit entirely in a single prompt — making RAG unnecessary overhead.

**What we use instead — Context Injection:**
Before every AI message, the app queries SQLite for the user's live financial data and injects it directly into the system prompt. This gives the AI complete, always-current context without vector search, embeddings, or a backend server. It works fully offline-capable (only the Groq API call requires internet).

**Accurate description for academic/technical audiences:**
> *"Smart Spend implements a context-aware agentic AI system using dynamic full-context injection from a local SQLite database, enabling autonomous financial data management without the infrastructure overhead of traditional RAG pipelines."*

#### AI Chat Capabilities
The AI has access to: last 10 expenses detailed + older summarized by category, budget status, monthly income, total spent, health score, savings goals, debts, recurring, and installments. Context is compressed to stay within the 8,192 token limit.

The AI executes **15 action types** directly — data is written to the DB immediately with green snackbar confirmation:

| Action | Example Trigger |
|--------|----------------|
| `log_expense` | "I spent 30 pesos for transport" |
| `set_budget` | "Set my food budget to ₱3000" |
| `set_income` | "My salary is ₱25000" |
| `add_goal` | "I want to save ₱50000 for a laptop" |
| `update_goal` | "I added 500 to my laptop fund" |
| `delete_goal` | "Remove my RTX 4060 Ti goal" |
| `add_income` | "I received my allowance of 1500 pesos" |
| `add_debt` | "I borrowed 500 from John" / "I lent 300 to Maria" |
| `update_debt` | "I paid 500 toward my debt to John" |
| `add_recurring` | "Add Netflix 299 pesos monthly subscription" |
| `delete_recurring` | "Cancel my Netflix subscription" |
| `set_account_type` | "I'm a student" |
| `update_expense` | "Change that Sting to Food category" / bulk rename |
| `delete_expense` | "Delete that wrong entry" (requires typing DELETE to confirm) |
| `add_installment_plan` | "I have a ShopeePayLater loan, ₱373/month for 3 months" |

- Actions execute immediately — green snackbar shown per action
- **Broader scope** — handles personal finance + Philippine banking, SSS/PhilHealth/Pag-IBIG, investments, price estimates, buying/selling advice
- **Filipino Financial Calendar** — aware of 13th month pay, school enrollment, Christmas spending, 11.11/12.12 sales
- **Conversation summarization** — every 10 messages, older history compressed to bullet points; reduces token usage 40–70%
- **Dynamic max_tokens** — 200 for logging, 400 for list/view, 600 for advice
- **Daily limit: 60 messages/day** — remaining count shown in appbar, resets at midnight (UTC)

---

### 3. Dashboard (Home Screen)
- Time-based greeting
- **"Log Expense" button** — top right, goes directly to AI screen
- **This Month's Spending** card — month-over-month comparison, income progress bar
- **Today's Spending** card — shows today's total and transaction count (hidden if zero)
- **Month-over-month insight** — green/orange sentence: "You're spending 12% less than last month — mostly on Food"
- **Recurring auto-log chips** — overdue bills shown as tappable chips; one tap logs and advances next date; no AI needed
- **Quick-log chips** — top 4 most frequent expenses as one-tap chips; zero friction for common expenses
- **Cash Flow card** — Income / Spent / Bills Due (next 30 days) / Remaining; upcoming bill preview; shortfall warning
- **Budget Alerts** — graduated thresholds: 50%, 80%, 100% — with loss aversion framing linking overspend to top savings goal
- **Overdue Recurring banner** — orange banner when bills/subscriptions are overdue or due today
- **Upcoming Debt banner** — red banner when a debt/lending payment is due within 7 days
- **Financial Health Score** card — tappable; shows full score breakdown with actionable tips + "Full Details →" link to Profile
- **AI Insights** — auto-generated spending analysis (cached, only refreshes when expense count changes)
- **Subscription Summary card** — purple card showing all active subscriptions, monthly total, and annual cost
- **Daily Mood Check-In** — 5-emoji widget (😞😕😐🙂😄); one tap per day; stored in mood_log table
- **Recent Transactions** — last 10 with edit/delete
- Pull-to-refresh, auto-refreshes via event bus
- **Demo Mode banner** — shown when using app without an account

---

### 4. Analytics Screen
- Period Filters: All Time, This Week, This Month, **Last Month**, This Year, **Pick Month** (year + month grid picker), **Payday Cycle** (user-defined salary cycle), Custom Date Range
- **Pie Chart** — spending by category (respects period filter); tap any legend item to drill down into that category's transactions
- **Bar Chart** — monthly trend (respects period filter); all chart colors are theme-aware
- **Daily Spending Trend** — line chart showing spending per day for the last 30 days; shows dots per day with filled area
- **Day-of-Week Heatmap** — 7-column color-intensity grid showing average spend per day of week; darker = higher; highest day highlighted
- **This Month vs Last Month** — category-by-category comparison table with up/down arrows
- **Period Comparison Tool** — pick any two months side by side; shows total, per-category breakdown, and % change with trend arrows
- Health Score Line Chart — 30-day history
- **FHS Component Breakdown** — each component with progress bar + contextual financial literacy tip when score < 12/25
- **Small Purchases Add Up** — groups small frequent purchases (≤₱200, 3+ times) with monthly total + annual projection
- Spending Prediction — projected next month
- **Long-Range Forecast** — 3/6/12-month cumulative spending projection using weighted daily rate
- **Monthly Plain-English Summary** — on-demand AI paragraph summarizing the period in natural language
- **Mood & Spending Correlation** — shows average spend on low-mood vs high-mood days (requires 5+ mood log entries)
- **50/30/20 Rule Tracker** — always uses this-month data regardless of period filter; shows Needs/Wants/Savings vs targets with color-coded bars and a verdict line ("On track ✓" or "Wants over by ₱X")
- **Wants vs Needs breakdown** — stacked bar showing user-tagged Want vs Need split; separate from 50/30/20 (which is automatic by category)
- **Tax & Savings Estimate** — shown for Employed / Business / Working Student / Freelancer only (PH BIR TRAIN Law)
- **Allowance/Budget/Pension Overview** — shown for Student / Unemployed / Pensioner / General instead of tax card
- Income dialog title adapts to account type
- AI Financial Advice — on-demand
- Pull-to-refresh, auto-refreshes on data change

---

### 5. Budget Management
- Set monthly budgets per category (built-in 8 + any custom categories)
- **Two budget modes per category:** Fixed ₱ amount OR % of income (auto-calculates from monthly income)
- Progress bars: theme primary → orange (80%+) → red (exceeded)
- Summary card: total budgeted, total spent, income (all in selected currency)
- **Time-aware context** — "Day X of Y — Z% of month elapsed" shown under summary card
- **Pace indicator** per budget — "⚠️ ahead of pace" or "✓ under pace" based on how much of the month has passed
- Budget alerts on dashboard and push notifications at 80%+
- Budget compliance factored into Financial Health Score
- AI can set budgets via chat (with confirmation)
- Over-income warning dialog when total budgets exceed income
- Pull-to-refresh

---

### 6. Financial Health Score (0–100)

The score uses a **4-component weighted formula** (25 pts each) based on the paper's specification. Score is calculated from **this month's expenses only** — consistent across Home, Analytics, and Profile screens.

- Tap the score card on Home for a full breakdown dialog with each component's contribution and actionable tips
- Score breakdown in Profile shows each factor with its point contribution

| Component | What it measures | Max pts |
|-----------|-----------------|---------|
| Savings Rate | Actual savings vs 20% of income target | 25 |
| Overspend Control | Days where spending stayed within daily budget | 25 |
| Budget Adherence | % of budget categories that stayed within limit | 25 |
| Logging Consistency | Regularity of expense entries vs active days | 25 |

**Warning Decay:** If a budget is exceeded and spending continues the next day, score loses 5 pts/day (max −15 pts over 3 days). Resets when budgets return to on-track. 3-tier escalation notifications fire on each decay day.

**Fallback:** If no income is set, partial credit is given for components that require income.

---

### 7. Transactions Screen
- Full searchable expense list
- Search with 300ms debounce
- Period Filters: All Time, Today, This Week, This Month, This Year
- Category Filters: All + 8 built-in + custom categories
- **Want/Need Filters:** "🏷️ Wants only" and "✅ Needs only" filter chips — mutually exclusive
- **Low Confidence filter** — shows only AI-logged entries with confidence < 0.7
- Summary bar: count + total for filtered results
- Edit/delete with Undo snackbar
- Export filtered results to CSV (includes Want/Need column)
- Add expense directly from this screen
- Long-press to multi-select; bulk delete with confirmation
- Pull-to-refresh

---

### 8. Savings Goals
- Name, target amount, already-saved amount
- Optional purpose/reason field
- Start date and deadline
- Contribution tracking with progress bar
- Days-left countdown / Overdue indicator
- Monthly contribution tip shown after saving
- "Goal reached! 🎉" on completion
- **Emergency Fund** — tap the shield icon in AppBar; auto-calculates 3 or 6-month target from actual spending; emergency goals shown with teal shield icon
- Pull-to-refresh

---

### 9. Income Tracking
- Log multiple sources — categories adapt to account type:
  - **Student:** Allowance, Freelance, Gift, Bonus, Others
  - **Unemployed:** Gift, Rental, Investment, Others
  - **Employed/Business/Working Student:** Salary, Allowance, Freelance, Business, Investment, Rental, Gift, Bonus, Others
- Date picker for backdating income entries
- Monthly and all-time totals
- Pull-to-refresh
- Income label adapts to account type (Income / Allowance / Budget)

---

### 10. Debt & Lending Tracker
- I Owe tab + Owed to Me tab
- Partial payment recording with progress bar
- Due date tracking with overdue alerts
- **Payment Plans tab** — track fixed monthly payment plans (ShopeePayLater, GCash GLoan, HomeCredit, Globe/Smart postpaid, etc.)
  - Add plan: title, provider, total amount, monthly payment (auto-computed from total ÷ months), number of months, due day of month, optional interest rate, start date
  - Shows: months paid / total, remaining balance, next due date, interest projection
  - **Log Payment** button — records expense + increments months_paid; celebration snackbar on full payoff
  - Active and Completed sections
- **Installment Tracker merged into Payment Plans** — accessible from Hub → Debts & Lending → Plans tab; tracks phones, gadgets, ShopeePayLater, GCash GLoan, HomeCredit, and any fixed monthly payment plan
- Debt total in Analytics/Profile now correctly shows only "I Owe" amounts as liabilities; "Owed to Me" shown separately as receivable
- Pull-to-refresh

---

### 11. Recurring Transactions
- Frequencies: daily, weekly, monthly, yearly
- Start date and next due date — both editable
- Days until next / Overdue / Today / Tomorrow
- **Log Now button** — records expense as expense entry, or income as income entry (advances next date)
- **Auto-notification on app open** — push notification for overdue or due-today recurring items
- Detail dialog shows human-readable next date, frequency, and start date
- Long-press to edit
- Pull-to-refresh
- **AI context** — recurring transactions visible to AI (up to 8, with due date labels)

---

### 12. Currency & Exchange Rates
- 34+ currencies (PHP, USD, EUR, GBP, JPY, SGD, AUD, CAD, BRL, KRW, CNY, and more)
- Live rates from open.er-api.com (free, no key)
- 1-hour cache with offline fallback
- All amounts stored in PHP, converted for display only
- Manual refresh button

---

### 13. User Profile & Cloud Sync
- First/last/middle name, email, birthdate, address, phone, profile photo (local only)
- Profile data synced to Firebase Firestore
- **Full data sync** — expenses, budgets, goals, income, recurring, debts, custom_categories, installment_plans, **wallets**, and **category_rules** all sync automatically
- On login: pulls cloud data → merges into local DB (last-write-wins for expenses), then pushes local → cloud
- Every write automatically pushes to Firestore in the background
- **On logout:** pushes all data to cloud first, then clears local DB — prevents data mixing between accounts
- **Demo mode isolation:** demo data is cleared automatically when a real account logs in; loading demo data from Profile never touches Firestore
- **Reset All Data:** clears all 14 local tables AND pushes empty state to Firestore — data does not resurrect on next login
- **Backup restore:** restoring a backup pushes all restored data to Firestore immediately
- **Setup sync:** account type, income, currency, and auto-created budgets/goals are pushed to Firestore at the end of onboarding
- **Net Worth card** — Assets (wallet balances) minus Liabilities (expenses + debts + installments); tap to add manual assets; students/unemployed see Remaining Balance instead
- Income card — tap to update amount and frequency (daily/weekly/bimonthly/monthly)
- Tax and savings estimates shown for employed/business/working_student only
- Score breakdown list with actionable tips per negative factor
- Pull-to-refresh

> **Note:** Profile photo is stored locally only — Firebase Storage requires Blaze plan (paid). Cross-device photo sync is a planned future feature.

---

### 14. Account Types

| Type | Income Label | Notes |
|------|-------------|-------|
| Employed | Monthly Income | Tax estimate shown in Analytics |
| Business Owner | Monthly Income | Tax estimate shown |
| Freelancer | Monthly Income | Project-based, flexible frequency |
| Working Student | Monthly Income | Both income & allowance |
| Student | Monthly Allowance | Allowance-based budgeting |
| Pensioner / Retiree | Monthly Pension | Health budget prioritized |
| Unemployed | Monthly Budget | No income tracking |
| General / Other | Monthly Income / Budget | Full flexibility, no assumptions |

Changeable from Profile → Account Type or via AI chat ("I'm a freelancer", "I'm a pensioner", etc.)

All account types get access to all features. The label, income categories, budget suggestions, and tax card visibility adapt automatically.

---

### 15. Authentication

| Method | Description |
|--------|-------------|
| Email/Password | Standard Firebase Auth |
| **Forgot Password** | Sends Firebase password reset email from login screen |
| Google Sign-In | OAuth via Firebase, links to existing account |
| Demo Mode | No account needed — loads sample data instantly |

**Session behavior:** Firebase Auth persists the session automatically. Users stay logged in until they explicitly log out. Logout pushes all data to Firestore, clears local DB, and signs out.

### 15a. App Lock (PIN + Biometric)
- Optional app-level lock — enabled from Profile → App Lock
- Requires a 4-digit PIN to set up; biometric auto-prompts if device supports it
- Lock screen appears on cold start and app resume **only when a user is logged in**
- **Grace period: 3 minutes** — brief interruptions (share sheets, camera, file pickers) do not trigger the lock; only triggers after 3+ minutes in background or full app close
- Never appears on login/register/onboarding screens (no session = no lock)
- "Not you? Log out" link on lock screen for account switching
- Disable from Profile → App Lock → confirm removal
- PIN stored as obfuscated value in SharedPreferences
- Uses device's native biometric system (`local_auth` with `biometricOnly: false`) — works with optical in-display fingerprint, face unlock, and device PIN/pattern as fallback

---

### 16. Demo Mode
- Accessible directly from the Login screen — **no account required**
- Loads realistic sample data modeled after a **Lorma Colleges BSIT student** in San Fernando, La Union
- Account type: Student | Monthly income: ₱6,600 (daily allowance ₱300 × 22 days)
- **~27 expenses** spread across this week, this month, and last month
- **This week:** Jollibee, jeepney fare, Globe load, canteen lunch, tricycle, notebook, Mang Inasal, Shopee USB hub
- **This month:** Tuition installment, SM grocery, Spotify, vitamins, capstone printing, haircut, Watsons medicine, Grab ride, Mobile Legends diamonds, 7-Eleven snacks, HomeCredit payment
- **Last month:** Jollibee, jeepney fares, tuition, grocery, Smart load, cinema ticket, 2× HomeCredit payments
- **Savings goals:** New Laptop (₱12K/₱35K), Emergency Fund (₱3.5K/₱10K), Graduation Trip (₱1.5K/₱8K)
- **Debts:** Borrowed ₱1,500 from Kuya Mark (₱500 paid) for capstone materials; Lent ₱200 to Trisha for fare
- **Recurring (4):** Tuition installment ₱3,500/mo, Spotify ₱129/mo, Monthly Allowance ₱6,600/mo (income), HomeCredit ₱4,104/mo
- **Payment Plans (2):**
  - HomeCredit — Poco F8 Ultra 16GB/512GB: ₱42,999 SRP → ₱73,878 total over 18 months → ₱4,104/month, 3 of 18 paid, due 15th
  - ShopeePay Later — Mechanical Keyboard: ₱1,680 over 3 months → ₱560/month, 0 of 3 paid, due 5th
- **Income entries:** Monthly Allowance ×2 months + Part-time encoding job ₱1,500
- **Budgets:** Food ₱2,000 | Transportation ₱600 | School ₱4,500 | Bills ₱300 | Entertainment ₱300 | Shopping ₱500 | Health ₱300 | Personal Care ₱200
- **Custom categories:** School, Personal Care, Allowance
- **Category rules:** Jollibee→Food, Mang Inasal→Food, Mercury Drug→Health, National Bookstore→School, HomeCredit→Bills
- **Scan history:** 5 barcode scans (Lucky Me, Cobra, Sting, Chippy)
- **Mood log:** 10 days of entries (enables Mood & Spending correlation card in Analytics)
- **Score history:** 14 days of realistic scores (72–83 range) for the health score chart
- **FHS target:** 65–80 range (realistic for a student with some over-budget days)
- Orange banner shown in app indicating demo mode with "Sign Up" shortcut
- Also accessible from Profile → Load Demo Data (for logged-in users)
- **Isolated from real accounts** — demo data is automatically cleared when a real account logs in next
- Does not affect any real account data

---

### 17. App Themes
5 color themes, each compatible with both light and dark mode:

| Theme | Color |
|-------|-------|
| Ocean Blue | #0066FF (default) |
| Sky Blue | #0099DD |
| Forest Green | #00875A |
| Royal Purple | #6B21A8 |
| Sunset Orange | #E65100 |

Change from Profile → App Theme. Dark mode toggle works independently with any theme.

---

### 18. Feature Tour (New User Tutorial)
- 5-step interactive tutorial shown automatically on first launch after setup
- Updated to reflect v2.3.0 UX: AI-centric input, Quick Access Hub, share-sheet backup
- Covers: AI as primary input, Hub navigation, budgets & emergency fund, analytics & 50/30/20, pro tips
- Back button from step 2 onwards, tappable page dots to jump to any step
- Fade animation between steps, step counter ("1 of 5")
- Only shows once; can be replayed from Profile → Replay Tutorial
- Demo mode users skip the tour

---

### 19. Backup & Restore
- **Backup** — exports all data as a timestamped JSON file (`SmartSpend_Backup_YYYYMMDD_HHmmss.json`) via the system share sheet
- User can save to phone storage, email, Google Drive, Dropbox, or any app they choose — no OAuth required
- **Restore** — tap "Restore from Backup" → pick a `.json` backup file from device storage → data is imported alongside existing data
- Data backed up: expenses, budgets (including percentage mode), goals, income, recurring, debts, scan history, installments, **payment plans**, custom categories, category rules, **mood log**
- Backup format: **v8** (v6 adds category_rules, v7 adds mood_log, v8 adds installment_plans)
- Profile → Backup Data / Restore from Backup
- No cloud account or internet connection required

---

### 19a. Import from Bank / GCash
AI-powered bulk import of transaction history from any bank or e-wallet.

**Supported sources:** GCash, Maya (PayMaya), BPI, BDO, UnionBank, Seabank, and any bank with a text-based export.

**Access:** Hub → "Import from Bank / GCash" or Profile → Data section

**How it works:**
1. User selects their source (GCash, Maya, BPI, etc.) — app shows source-specific instructions
2. User pastes raw transaction history text, or uses the Camera button to OCR a screenshot
3. Tap "Parse with AI" — `LLMService.parseTransactionHistory()` sends the text to Groq with a specialized prompt
4. AI extracts all debit/outgoing transactions, skipping credits, income transfers, and loan repayments
5. Review screen shows each transaction with: real date, time, description, amount, editable category dropdown, Want/Need toggle, checkbox
6. User selects which to import → bulk insert into `expenses` table with real transaction dates

**Key behaviors:**
- **Real dates preserved** — imported expenses use the actual transaction date (e.g. Apr 28), not today
- **Real times preserved** — GCash includes HH:MM timestamps; these are extracted and saved
- **Only debits imported** — credits/income are automatically skipped by the AI
- **OCR column reconstruction** — `_preprocessTransactionText()` detects separated-column OCR output and reconstructs rows using a balance-delta algorithm (if balance decreased → debit; if increased → credit). Tolerance: ±0.50 to handle OCR rounding errors.
- **Multi-format date normalization** — handles YYYY-MM-DD (GCash), MM/DD/YYYY (BPI/BDO), DD-Mon-YYYY (some banks) — all normalized before AI parsing
- **Document OCR mode** — Camera button uses `OCRService.scanDocument()` which returns raw OCR text with no receipt-specific cleaning and no 800-char truncation. Regular Smart Scanner still uses `scanReceipt()` — unchanged.
- **Date validation** — AI-returned dates validated with regex + `DateTime.tryParse()`; invalid dates fall back to today
- **PDF text recommended** — for GCash, copying text directly from the emailed PDF is more reliable than screenshot OCR for tabular data
- **Full synergy** — imported expenses appear in Analytics, AI context, Budget tracking, Bill Calendar, Transactions screen, Backup, CSV export, Health Score, and Achievements
- **Firestore sync** — `insertExpense` calls `CloudService.saveExpense` automatically
- **Notes field** — each imported expense gets "Imported from [Source]" in notes for traceability
- **AI daily limit** — cleared on logout so next user on same device gets a fresh 60 messages

**AI prompt behavior:**
- GCash: "Transfer from X to Y" where X is user = expense; where Y is user = income (skip)
- "Buy Load" → Bills category
- "Payment to [merchant]" → Shopping or Others
- "Send Money / Transfer to person" → Others
- GLoan repayments → skipped (debt payment, not regular expense)

---

### 20. Barcode Scanner
- Torch toggle, visual overlay guide frame
- Every scan saved to local scan history
- History screen: copy, delete, clear all
- After scan: dialog prompts user to describe the product before AI parsing
- Debounced — won't fire multiple times for same scan

---

### 21. Onboarding & Setup
- Splash Screen — animated logo
- Onboarding — 3-page walkthrough (first launch only)
- Setup Wizard — account type, income/allowance, currency
- PH minimum wage reference shown during setup
- No static placeholder data — app starts clean

---

### 22. Chat History
- All AI conversations saved to SQLite
- Browse from AI screen history button
- Day dividers between conversation groups
- Long-press to copy any message, copy icon on each bubble
- Clear all option
- Pull-to-refresh

---

### 23. Notifications
- **Weekly summary** (Sunday) — rolling 7-day window (past 7 complete days, not current calendar week)
- **Weekly Behavioral Summary** (Sunday) — savings rate, days over budget, logged days
- **Budget alerts** — graduated thresholds: 50%, 80%, 100%; with loss aversion framing linking overspend to top savings goal
- **Recurring due alerts** — push notification on app open for overdue, due-today, and due-in-3-days recurring items
- **Debt due alerts** — push notification for debts/lending due within 7 days or overdue (only unpaid)
- **Savings goal deadline alerts** — push notification when a goal deadline is within 7 days or passed
- **Anomaly detection** (Sunday) — fires when a category spends 2.5× above 4-week average; once per week
- **Category velocity alert** (monthly) — fires when a category grows >25% month-over-month; once per month
- **In-app banners** on Home screen for overdue recurring (orange) and upcoming debt payments (red)
- Powered by flutter_local_notifications
- **Requires notification permission** — app requests `POST_NOTIFICATIONS` on first launch (Android 13+)

---

### 24. Dark Mode
- Full dark mode throughout all screens
- Works with all 5 color themes
- Toggle in Profile → Dark Mode
- Persisted across restarts

---

### 25. Export
- CSV export via system share sheet
- **Filename includes date+time:** `SmartSpend_Expenses_YYYYMMDD_HHmmss.csv`
- Full columns: ID, Date, Time, Item Name, Category, Amount (PHP), **Want/Need**, Shop, Payment Method, Notes, AI Generated, Confidence Score
- Filtered export from Transactions screen
- Full export from Profile → Export to CSV

---

### 26. Crash Reporting
- Firebase Crashlytics
- Catches Flutter framework errors and async errors
- Reports in Firebase Console → Crashlytics

### 27. Debug Log Export
- Exports a comprehensive plain-text debug log for QA and troubleshooting
- **Filename includes date+time:** `smartspend_debug_YYYYMMDD_HHmmss.txt`
- Access from: AI screen → ⋮ menu → "Export Debug Log", or Profile → "Export Debug Log"
- **Contents (all moving parts):**
  - All settings (sensitive keys masked)
  - All expenses with Want/Need tag, AI flag, notes
  - Budgets, income entries, savings goals, debts, recurring transactions
  - **Payment Plans** — provider, monthly payment, months paid/total, remaining balance, due day
  - Custom categories and auto-categorization rules
  - Mood log (last 30 days with emoji)
  - Score history (last 30 days)
  - **FHS Score Breakdown** — each of the 4 components with points and reason for current month
  - **AI Context Summary** — account type, income, this month totals, Want/Need split, quiz challenge
  - **Notification State** — all rate-limit keys, level-up flags, decay state
  - Scan history (last 20 barcodes with timestamps)
  - AI chat history (last 200 messages, truncated at 200 chars each)
- Shared via system share sheet (email, WhatsApp, Drive, etc.)
- Sensitive keys are masked in the output

### 28. Custom Expense Categories
- Add your own categories beyond the built-in 8 (e.g. "School", "Church Offering", "Pets")
- Accessible from: Profile → Manage Categories, or Hub → Categories
- Built-in categories (Food, Transportation, Bills, Shopping, Entertainment, Health, Education, Others) are locked and cannot be deleted
- Custom categories appear in all dropdowns: Add Expense, Edit Expense, Budget, Recurring
- Rename or delete custom categories; deleted category's expenses move to "Others"
- Synced to Firestore; included in backup/restore
- AI is aware of custom categories and will use them when logging expenses

### 29. Expense Photo Attachment
- Attach a receipt photo to any expense (camera or gallery)
- Thumbnail shown in expense tile; tap to view full-screen
- Photo badge indicator (blue dot) on tile when photo is attached
- Local storage only (Firebase Storage requires Blaze plan)
- Photo path included in backup JSON; not synced to Firestore (device-specific paths)

### 30. Want vs Need Expense Tagging
- Tag any expense as "Need" (essential) or "Want" (discretionary) when logging or editing
- Default is Need (0) — existing expenses unaffected
- **AI-assisted tagging:** `LLMService.parseExpense()` now returns `is_want` based on item type (candy/chips/coffee shop = Want; groceries/medicine/fare = Need)
- **AI chat tagging:** When the AI logs an expense via chat, it includes `is_want` in the action based on context
- Analytics screen shows Wants vs Needs stacked bar with percentages
- **Transactions screen** has "🏷️ Wants only" and "✅ Needs only" filter chips
- **AI context** includes Want/Need totals and each expense is tagged [Want] or [Need] in the context string
- Feeds into 50/30/20 rule awareness and mood-spend correlation

### 31. Shake to Undo
- After the AI logs an expense, goal, debt, recurring item, or sets a budget — shake the phone within 60 seconds to undo
- Confirmation bottom sheet appears before reversing (not auto-undo)
- Undoable actions: log_expense, add_goal, add_income, add_debt, add_recurring, set_budget, update_expense, update_goal
- NOT undoable: delete_expense, set_income, set_account_type
- Undo buffer cleared on: new action, screen dispose, logout
- Shake threshold: 2.7g (firm shake, not accidental)

### 32. Daily Spending Limit
- Set a daily spending cap from Profile → Daily Spending Limit
- Home dashboard shows a progress bar for today's spending vs limit
- Push notification at 80% of limit and when exceeded
- Opt-in — hidden when limit is 0 or not set

### 33. Bill Due Date Calendar
- Monthly calendar view showing all financial events color-coded by type:
  - 🟠 Orange — Recurring bills due
  - 🟢 Green — Expected income
  - 🔴 Red — Debt payments due
  - 🩵 Teal — Savings goal deadlines
  - 🟣 Purple — Installment payment days
  - ⚫ Gray dot — Days with logged expenses
- **All days are tappable** — tap any day to see what you spent + upcoming events
- **Day detail sheet** shows:
  - Actual expenses logged that day (Want/Need dot, category, amount, daily total)
  - Tap any expense row → navigates directly to Edit Expense screen
  - Financial events (bills, debts, goals) with Log button
  - Financial Health Score badge for that day (green/orange/red)
- Score dots on each calendar day from score_history (green/orange/red)
- **Log Now** button on recurring bills/income — records instantly and advances next date
- Month navigation with prev/next arrows
- Empty state when no events exist for the month
- Accessible from Hub → Bill Calendar

### 34. Spending Streaks & Badges
- Tracks consecutive days with Financial Health Score ≥ 60 (Fair or better)
- Badge types: 🔥 streak, 💯 week on track, 🏆 30-day champion, 💰 ₱1K+ saved, 🎯 goal reached, 📅 active tracker
- Up to 3 badges shown as chips on the home dashboard
- Derived from existing score_history — no new table needed

### 35. SSS / PhilHealth / Pag-IBIG Presets
- Preset recurring templates for government contributions
- Accessible from Recurring Transactions → + icon in AppBar
- Presets: SSS (₱1,125/mo), PhilHealth (₱500/mo), Pag-IBIG (₱200/mo)
- Added as standard recurring bills; amounts editable after adding

### 36. Auto-Categorization Rules
- User-defined keyword → category mappings stored in `category_rules` table
- Accessible from Hub → Auto-Categorization Rules
- Rules are case-insensitive and use partial matching (e.g. "grab" matches "GrabFood", "Grab Car")
- User rules take priority over the built-in keyword list in both AI chat and manual entry
- CRUD: add, delete; keyword + category per rule
- AI context refreshes rules on every `setFullContext()` call

### 37. Period Comparison Tool
- Accessible in Analytics screen — collapsible section
- Pick any two months using a year + month grid picker
- Shows: total spending per period, per-category breakdown, % change, trend arrows (↑↓)
- Highlights the period with higher total spending

### 38. Last Month + Month Picker + Payday Cycle Filter
- **Last Month** chip — instant filter for the previous calendar month
- **Pick Month** chip — opens a year + month grid picker for any historical month
- **Payday Cycle** chip — user sets their payday date (1–28); filter shows expenses from that date last month to the day before this month; payday date stored in `settings` table as `payday_date`

### 39. Day-of-Week Spending Heatmap
- 7-column grid (Mon–Sun) in Analytics showing average daily spend per day of week
- Color intensity scales from light to dark based on relative spend; highest day highlighted with border
- Shows amount label inside each cell when non-zero

### 40. Long-Range Forecast (3/6/12 months)
- Extends `PredictService` with `predictLongRange()` method
- Uses weighted daily rate (60% current month pace + 40% historical average) × months
- Displayed as a 3-column card in Analytics below the next-month prediction

### 41. Financial Literacy Tips (Contextual)
- Shown inline in the FHS Component Breakdown card in Analytics
- Appears as a blue tip card below any component scoring < 12/25
- Four tips keyed to each component: savings_rate, overspend_control, budget_adherence, logging_consistency
- Hardcoded strings — no AI call needed

### 42. Daily Mood Check-In
- 5-emoji widget on home screen (😞😕😐🙂😄); one tap per day
- Stored in `mood_log` table (date UNIQUE, mood_score 1–5, note)
- Shows "Mood logged ✓" confirmation after tapping

### 43. Mood-Spend Correlation
- Shown in Analytics after 5+ mood log entries
- Computes average daily spending on low-mood days (score 1–2) vs high-mood days (score 4–5)
- Shows insight: "You spend ₱X more on low-mood days" with actionable suggestion

### 44. Impulse Pause Mechanic
- Triggers in `add_expense_screen.dart` when saving a Want-tagged expense above 2× category average
- Shows a dialog: "Was this planned?" with context (amount vs average)
- User can still save — it's a reflection prompt, not a block

### 45. Loss Aversion Budget Alerts
- `showBudgetAlert()` now links overspend to the user's top incomplete savings goal
- "₱800 over Food = ₱800 less toward your New Laptop goal"
- Falls back to standard percentage message if no goals exist
- Graduated thresholds: 50%, 80%, 100% (was 80% only)

### 46. Category Velocity Alert
- New `checkCategoryVelocity()` in `NotificationService`
- Runs once per month on app open; checks if any category grew >25% MoM
- Fires one notification for the most-growing category
- Rate-limited by `last_velocity_check` setting

### 47. Windfall Income Flag
- `is_windfall INTEGER DEFAULT 0` column added to `income` table
- Toggle in income add dialog: "Mark as windfall?" with amber star icon
- Windfall income is stored separately; AI and forecasts can treat it differently from regular income

### 48. Subscription Summary Card
- Purple card on home screen showing all active recurring expenses (monthly/weekly/yearly)
- Shows count, combined monthly cost, annual total, and up to 4 subscription chips
- Only shown when total monthly subscriptions ≥ ₱100

### 49. Micro-Expense Clustering Card
- Analytics card grouping small frequent purchases (≤₱200, appearing 3+ times)
- Shows per-item count and total, plus combined monthly total and annual projection
- Sorted by total descending; top 4 shown

### 50. Monthly Plain-English AI Summary
- New `LLMService.generateMonthlySummary()` method
- On-demand card in Analytics — tap "Generate" to get a 2–4 sentence paragraph
- Uses current period's expenses + income; adapts label to selected period (Last Month, Pick Month, etc.)

### 51. Trust-First Onboarding
- Income step in setup wizard now labeled "Optional"
- Button text changes to "Skip for now" when income field is empty
- Users can complete setup without entering income; prompted later from home screen

### 52. Category Summary Panels (Analytics)
- Expandable per-category cards in the Analytics screen, below the pie chart
- Each card shows: total amount, % of overall spending, budget progress bar with remaining/over amount
- On expand: transaction count, average per transaction, budget amount chips
- **4-week mini bar chart** — last 4 weeks of spending in that category; current week highlighted in full color
- **Top 3 items** — most-spent items in the category with horizontal progress bars showing their share
- All categories shown; sorted by spending amount (highest first)

### 53. Transaction Tags
- Custom `#hashtag` labels on any expense (up to 5 per expense)
- Added in Add Expense and Edit Expense screens — type a tag, tap Add or press Enter
- Tags shown as colored chips on expense tiles in all lists
- Tag filter chips in Transactions screen (auto-appear when any expense has tags)
- Search bar also matches tags
- Included in CSV export (Tags column) and backup/restore
- Use cases: `#capstone`, `#shared`, `#work`, `#monthly`

### 54. Subscription Auto-Detection
- Runs once per day in background — scans last 90 days of expenses
- Detects descriptions appearing 2+ times at consistent weekly/biweekly/monthly intervals
- Skips items already in the Recurring Transactions list
- Shows a teal prompt card on Home: "Recurring pattern detected — want to track it?"
- [Dismiss] permanently hides that suggestion; [Add Recurring] opens Recurring screen
- Stored in `recurring_candidates` table

### 55. Market Insights (Analytics)
- Card in Analytics screen (below Monthly Summary, before AI Advice)
- Shows live PHP exchange rates: USD, EUR, GBP, JPY, SGD, AUD
- Auto-fetches fresh rates from open.er-api.com when cached rates are >1 hour old
- Tap to expand: 6 financial literacy tips (inflation, 50/30/20, emergency funds, credit cards, etc.)
- Falls back to cached rates if offline

### 56. Spending Personality
- Computed from current month's expense data — no AI call needed
- Shows as a card on Home screen between FHS/Budgets row and AI Insights
- 10 possible labels: Foodie Spender, Consistent Saver, Entertainment Lover, Shopaholic, Commuter, Invested Learner, Disciplined Spender, Impulse Buyer, Smart Budgeter, Balanced Spender
- Each includes a brief actionable tip
- Updates automatically when expense data changes

### 57. AI as Broader Financial Companion
- System prompt redesigned: warmer, conversational, Filipino-friendly tone
- Covers beyond expense logging: Philippine banking (GCash, Maya, BDO, BPI), SSS/PhilHealth/Pag-IBIG, investments (MP2, time deposits, stocks, crypto basics), price estimates, buying/selling advice, negotiation
- Filipino Financial Calendar awareness: school enrollment (May–July), 13th month pay (Nov–Dec), Christmas spending spike, 11.11/12.12 sales, post-holiday recovery (Jan)
- Proactive budget alerts: after logging via AI, fires orange snackbar at 80% budget, red at 100%
- Dynamic max_tokens: 200 for logging, 400 for list/view, 600 for advice

### 58. Conversation Summarization
- Every 10 messages, AI summarizes older conversation into 3–5 bullet points
- Summary stored in `conversation_summaries` SQLite table
- Subsequent API calls send: system prompt + summary + last 4 messages (instead of full history)
- Reduces token usage 40–70% for long conversations
- Full chat history still visible in UI — only what AI reads internally is compressed
- Summary cleared on logout and explicit chat clear

### 59. Import from Bank / GCash (see section 19a for full details)
- Entry points: Hub → "Import from Bank / GCash" + Profile → Data section
- Supports: GCash, Maya, BPI, BDO, UnionBank, Seabank, any text-based export
- CSV file picker button added (pick .csv/.txt directly from device)
- OCR document mode: bypasses receipt cleaning for transaction history tables
- Auto-detects transaction history from regular scanner — offers Import screen
- Real dates and times preserved from original transaction history

### 60. Quick Access Portals (Home Screen)
- 9-card grid (3×3) on Home screen: Analytics, Bill Calendar, Goals, Debts & Plans, My Wallets, Budgets, Import, Recurring, Achievements
- Each card shows icon, name, and brief description
- InfoButton explains all 9 portals
- Separate from the Hub (which shows all features)
- Wallet card always visible on home screen — shows "tap to set up" when balances are ₱0

### 61. Wallet Balances
- Track liquid money across all accounts: Cash on Hand, GCash, Maya, GrabPay, ShopeePay, Coins.ph, Lazada Wallet, TikTok Shop Wallet, PayPal, Wise
- 17 Philippine banks: BDO, BPI, Metrobank, Landbank, PNB, RCBC, Security Bank, Chinabank, UnionBank, EastWest, PSBank, Maybank, GoTyme, Tonik, UNObank, UnionDigital, Seabank
- Remittance centers: Cebuana Lhuillier, M Lhuillier, Palawan Pawnshop, Western Union, LBC, Tambunting, USSC
- Accessible from: Home wallet card, Home 9-grid portal, Hub → My Wallets, Profile → tap net worth card, Analytics nav chips
- AI action: `set_wallet_balance` — say "my GCash is ₱500" → updates automatically
- Creates new wallet if name not found, assigns correct icon automatically
- Wallet total used as liquid assets in net worth calculation
- Separate from income — does NOT affect FHS score, budgets, or 50/30/20
- Resets to ₱0 on logout (per-account)
- `wallets` table created via `_ensureColumns` (no version bump)

### 62. Firebase App Check (Play Integrity)
- Integrated via `firebase_app_check` package
- Uses Play Integrity API for Android attestation
- Initialized in `main.dart` before any Firebase calls
- SHA-256 fingerprint registered: `0E:F3:30:F9:45:F2:0D:57:59:2C:AB:9E:D4:57:24:FF:76:B0:D4:87:5A:DB:0B:B2:06:36:32:94:98:38:CE:4C`
- Status: Monitoring mode (metrics visible for Firestore + Auth, enforcement deferred to production)
- Reason for not enforcing: sideloaded APK during academic phase; enforcement will be activated before Play Store submission

---

## 🗄️ Database Schema (SQLite — version 11)

> All amounts stored in PHP internally. `updated_at` on expenses enables last-write-wins cloud sync. `time` uses HH:mm:ss for AI-logged entries (prevents batch duplicate blocking) and HH:mm for manual entries. `photo_path` is local file path only (not synced to Firestore). `is_want` defaults to 0 (Need). New tables added via `_ensureColumns()` — no version bump required (CREATE TABLE IF NOT EXISTS).

**New tables added this version (auto-created on app open):**
- `category_rules` — user-defined keyword → category mappings
- `mood_log` — daily mood check-in entries (one per day)
- `installment_plans` — Payment Plans tab (ShopeePayLater, GCash GLoan, etc.)
- `recurring_candidates` — auto-detected subscription patterns
- `conversation_summaries` — compressed AI chat history for token efficiency
- `wallets` — wallet balances (Cash on Hand, GCash, Maya, banks, remittance centers)

**New columns added this version:**
- `income.is_windfall` — marks one-time unexpected income (0/1)
- `expenses.tags` — comma-separated custom tags (e.g. `#capstone,#shared`)

```sql
expenses (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  item_name TEXT NOT NULL,
  category TEXT NOT NULL,
  amount REAL NOT NULL,
  date TEXT NOT NULL,
  time TEXT,                          -- HH:mm:ss for AI-logged, HH:mm for manual
  payment_method TEXT DEFAULT 'Cash',
  shop_name TEXT,
  location TEXT,
  notes TEXT,
  ai_generated INTEGER DEFAULT 1,
  confidence_score REAL DEFAULT 1.0,
  updated_at TEXT,                    -- ISO timestamp for last-write-wins sync
  photo_path TEXT,                    -- Local file path for attached receipt photo
  is_want INTEGER DEFAULT 0           -- 0 = Need, 1 = Want
)

budgets (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  category TEXT UNIQUE,
  amount REAL,
  is_percentage INTEGER DEFAULT 0,    -- 0 = fixed ₱, 1 = % of income
  percentage_value REAL DEFAULT 0     -- % value when is_percentage = 1
)

custom_categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  icon TEXT
)

savings_goals (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  purpose TEXT,           -- Optional reason/description
  target_amount REAL NOT NULL,
  current_amount REAL DEFAULT 0,
  start_date TEXT,
  deadline TEXT,
  icon TEXT,
  color INTEGER,
  created_at TEXT NOT NULL
)

income (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  amount REAL NOT NULL,
  category TEXT DEFAULT 'Salary',
  date TEXT NOT NULL,
  is_recurring INTEGER DEFAULT 0,
  is_windfall INTEGER DEFAULT 0,      -- 1 = one-time unexpected income (bonus, gift)
  notes TEXT
)

recurring (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  amount REAL NOT NULL,
  category TEXT NOT NULL,
  frequency TEXT DEFAULT 'monthly',
  next_date TEXT NOT NULL,
  start_date TEXT,        -- When this recurring item started
  is_expense INTEGER DEFAULT 1,
  notes TEXT
)

debts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  person TEXT NOT NULL,
  amount REAL NOT NULL,
  paid_amount REAL DEFAULT 0,
  type TEXT DEFAULT 'owe',
  due_date TEXT,
  interest_rate REAL,     -- Optional interest rate
  notes TEXT,
  created_at TEXT NOT NULL
)

chat_history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  role TEXT NOT NULL,
  message TEXT NOT NULL,
  timestamp TEXT NOT NULL
)

user_profile (
  uid TEXT PRIMARY KEY,
  first_name TEXT,
  last_name TEXT,
  middle_name TEXT,
  email TEXT,
  birthdate TEXT,
  address TEXT,
  phone TEXT,
  photo_url TEXT
)

settings (
  key TEXT PRIMARY KEY,
  value TEXT
)

score_history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  score INTEGER NOT NULL,
  date TEXT NOT NULL
)

scan_history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  barcode TEXT NOT NULL,
  scanned_at TEXT NOT NULL
)

installments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  total_amount REAL NOT NULL,
  monthly_payment REAL NOT NULL,
  months_total INTEGER NOT NULL,
  months_paid INTEGER DEFAULT 0,
  interest_rate REAL DEFAULT 0,
  start_date TEXT NOT NULL,
  notes TEXT
)

category_rules (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  keyword TEXT NOT NULL,              -- Lowercase, partial match
  category TEXT NOT NULL,             -- Target category name
  created_at TEXT NOT NULL
)

mood_log (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date TEXT NOT NULL UNIQUE,          -- One entry per day (YYYY-MM-DD)
  mood_score INTEGER NOT NULL,        -- 1 (worst) to 5 (best)
  note TEXT                           -- Optional context note
)
```

### Key Settings Keys
| Key | Purpose |
|-----|---------|
| `monthly_income` | Declared monthly income/allowance (always stored as monthly equivalent) |
| `account_type` | employed / student / unemployed / business / working_student / freelancer / pensioner / general |
| `income_frequency` | daily / weekly / bimonthly / monthly (used for display, conversion done on save) |
| `setup_done` | Whether setup wizard completed |
| `currency` | ISO currency code (e.g. PHP, USD) |
| `dark_mode` | true/false (device-wide) |
| `app_theme` | blue / light_blue / green / purple / orange (device-wide) |
| `payday_date` | Day of month user gets paid (1–28); used for Payday Cycle filter |
| `manual_assets` | User-entered total asset value for net worth calculation |
| `daily_limit` | Daily spending cap; 0 = disabled |
| `last_weekly_notif` | Date key preventing duplicate weekly summary notifications |
| `last_anomaly_check` | Date key preventing duplicate anomaly detection notifications |
| `last_velocity_check` | Month key preventing duplicate category velocity notifications |
| `last_daily_briefing` | Date key preventing duplicate morning briefing notifications |
| `warning_decay_days` | Current decay counter (0–3) for FHS penalty |
| `last_decay_check` | Date key for once-per-day decay check |
| `quiz_challenge` | Onboarding quiz answer (debt / overspending / saving / tracking) |

---

## 📶 Online vs Offline Capabilities

| Feature | Needs Internet? | Needs AI? |
|---------|----------------|-----------|
| Manual entry form | ❌ No | ❌ No |
| Barcode/QR scanning | ❌ No (on-device ML Kit) | ❌ No |
| OCR receipt scanning | ❌ No (on-device ML Kit) | ❌ No |
| Quick-log chips | ❌ No | ❌ No |
| Recurring auto-log | ❌ No | ❌ No |
| Recurring Log All Due | ❌ No | ❌ No |
| All analytics & charts | ❌ No | ❌ No |
| Financial Health Score | ❌ No | ❌ No |
| Budgets, Goals, Debts | ❌ No | ❌ No |
| Custom categories | ❌ No | ❌ No |
| Photo attachment | ❌ No | ❌ No |
| Want vs Need tagging | ❌ No | ❌ No |
| Daily spending limit | ❌ No | ❌ No |
| Bill calendar | ❌ No | ❌ No |
| Streaks & badges | ❌ No | ❌ No |
| Shake to undo | ❌ No | ❌ No |
| Voice input | ✅ Yes (Google speech API) | ❌ No |
| AI chat & advice | ✅ Yes | ✅ Yes |
| Cloud sync (Firebase) | ✅ Yes | ❌ No |
| Currency exchange rates | ✅ Yes | ❌ No |

The app shows an offline banner when there's no internet. All core tracking features work offline. AI features degrade gracefully — no crashes, just unavailable.

---

## 🔧 Technology Stack

| Component | Technology |
|-----------|-----------|
| Framework | Flutter 3.x (Dart) |
| AI / LLM | Groq API — llama-3.1-8b-instant |
| Local Database | SQLite via sqflite (v10) |
| Cloud Database | Firebase Firestore — Spark plan (full bidirectional sync) |
| Authentication | Firebase Auth (email + Google OAuth) |
| Crash Reporting | Firebase Crashlytics |
| OCR | Google ML Kit Text Recognition + image orientation fix (image package) |
| Barcode/QR | mobile_scanner (live detection) + google_mlkit_barcode_scanning (image-based detection) |
| Charts | fl_chart |
| Voice Input | speech_to_text |
| Barcode Scanner | mobile_scanner |
| Exchange Rates | open.er-api.com (free, no key) |
| Markdown Rendering | flutter_markdown |
| Export | csv + share_plus |
| Notifications | flutter_local_notifications |
| Google Sign-In | google_sign_in |
| Biometric Auth | local_auth (used for App Lock biometric unlock) |
| Backup | System share sheet — save JSON to phone, Drive, email, etc. (includes installments, custom categories) |
| File Picker | file_picker (for restore — pick backup .json from device) |
| Shake Detection | shake (for Shake to Undo feature on AI screen) |
| State Management | setState + AppEventBus |

---

## 📂 Project Structure

```
lib/
├── main.dart                      # App entry, Firebase init, Crashlytics, app lifecycle observer (lock)
├── models/
│   ├── expense.dart               # Expense data model (includes updatedAt for sync)
│   ├── budget.dart                # Budget data model
│   └── user_profile.dart          # User profile model
├── screens/
│   ├── splash_screen.dart         # Animated splash with onboarding + app lock check
│   ├── app_lock_screen.dart       # PIN + biometric lock screen (shown on resume if lock enabled)
│   ├── pin_setup_screen.dart      # 4-digit PIN setup flow
│   ├── onboarding_screen.dart     # 3-page first-launch walkthrough
│   ├── setup_screen.dart          # Account type + income + currency setup wizard
│   ├── login_screen.dart          # Email/password + Google + Demo Mode
│   ├── register_screen.dart       # Firebase registration → setup wizard
│   ├── home_screen.dart           # Dashboard + bottom nav (Home/Analytics/AI/Hub/Profile) + feature tour
│   ├── analytics_screen.dart      # Charts, predictions, tax, AI advice
│   ├── ai_screen.dart             # AI chat with voice input + history
│   ├── profile_screen.dart        # User stats, settings, theme picker, app lock, navigation hub
│   ├── add_expense_screen.dart    # Multi-modal expense input
│   ├── edit_expense_screen.dart   # Edit existing expense
│   ├── budget_screen.dart         # Budget management per category
│   ├── savings_goals_screen.dart  # Savings goal tracking with contributions
│   ├── income_screen.dart         # Income logging (categories adapt to account type)
│   ├── debt_screen.dart           # Debt & lending tracker
│   ├── recurring_screen.dart      # Recurring transactions with Log Now
│   ├── transactions_screen.dart   # Full transaction list with search & filters
│   ├── currency_screen.dart       # Currency selection + live exchange rates
│   ├── chat_history_screen.dart   # Past AI conversations
│   ├── barcode_screen.dart        # Barcode scanner + scan history
│   ├── scan_review_screen.dart    # Scan review screen (OCR/barcode result editing before AI send)
│   ├── smart_camera_screen.dart   # Smart Scanner (live viewfinder, auto barcode+OCR detection, Scan Review inlined)
│   ├── help_screen.dart           # Help & Guide screen (searchable, expandable, 13 sections with examples)
│   └── about_screen.dart          # App info, team (Lucid Frame logo), features
├── services/
│   ├── db_service.dart            # SQLite CRUD — single source of truth (v10)
│   ├── cloud_service.dart         # Firestore sync + settings push/pull
│   ├── auth_service.dart          # Firebase Auth + Google Sign-In
│   ├── app_lock_service.dart      # App lock: PIN storage, biometric auth, enable/disable
│   ├── backup_service.dart        # Google Drive backup & restore
│   ├── event_bus.dart             # Global event bus for real-time UI refresh
│   ├── llm_service.dart           # Groq API (expense parsing + insights + advice)
│   ├── ai_chat_service.dart       # Groq API (conversational chat + 9 action types)
│   ├── insight_service.dart       # Wrapper for LLM dashboard insights (passes actual total)
│   ├── score_service.dart         # Financial health score (income-relative, this-month only)
│   ├── predict_service.dart       # Monthly spending prediction (3+ days required)
│   ├── tax_service.dart           # PH BIR TRAIN Law tax estimation
│   ├── currency_service.dart      # Exchange rates + formatting (34+ currencies, PHP no decimals)
│   ├── ocr_service.dart           # Google ML Kit OCR (Latin script, max quality)
│   ├── voice_service.dart         # Speech-to-text (en_PH / en_US, 2s pause)
│   ├── export_service.dart        # CSV export + share (11 columns)
│   ├── demo_service.dart          # Sample data loader
│   ├── debug_service.dart         # Full debug log export as .txt (AI screen + Profile)
│   ├── notification_service.dart  # Weekly summary + budget alert notifications
│   └── theme_service.dart         # 5 color themes + dark mode toggle
└── widgets/
    ├── expense_tile.dart           # Expense list item (edit/delete/undo/confidence dot)
    ├── feature_tour.dart           # 5-step tutorial (fixed navigation, fade animation)
    └── action_button.dart          # Circular action button
```

---

## 🚀 Setup & Running

### Prerequisites
- Flutter SDK 3.x
- Android Studio or VS Code with Flutter extension
- Android device or emulator (API 21+, recommended API 30+)
- Firebase project with Firestore + Auth + Crashlytics enabled
- Groq API key (free at console.groq.com)

### Steps
```bash
# 1. Install dependencies
flutter pub get

# 2. Run in debug mode
flutter run

# 3. Build release APK (split by architecture — recommended for QA)
flutter build apk --release --split-per-abi
# arm64-v8a (42MB) — most modern phones
# armeabi-v7a (34MB) — older phones
# x86_64 (45MB) — emulators

# 4. Build App Bundle (for Play Store)
flutter build appbundle --release
```

### Configuration Files
| File | Purpose |
|------|---------|
| `android/app/google-services.json` | Firebase config (re-download after adding SHA-1) |
| `lib/services/llm_service.dart` | Groq API key (`_groqKey`) |
| `lib/services/ai_chat_service.dart` | Groq API key (`_apiKey`) |

---

## 🔑 Google Sign-In & Drive Backup Setup

### SHA-1 Fingerprint (debug)
```cmd
"C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

**Debug SHA-1 for this project:**
```
41:B5:40:C1:57:C5:EF:B9:36:DF:5E:F6:C3:B0:F9:5F:72:AE:1C:2B
```

### Firebase Console Steps
1. Project Settings → Android app → Add fingerprint → Save
2. Download new google-services.json → replace android/app/google-services.json
3. Authentication → Sign-in method → Google → Enable
4. Crashlytics → Enable

### Google Cloud Console
1. APIs & Services → Library → Google Drive API → Enable

---

## 🔐 Security & Privacy

### Firebase Auth
- Email/password + Google OAuth + Biometric convenience layer
- Account linking — Google can be linked to existing email/password account
- Logout clears Firebase + Google Sign-In sessions
- Demo mode runs without any Firebase auth (null user handled gracefully)

### Firebase App Check
- Play Integrity API integrated via `firebase_app_check` package
- Initialized in `main.dart` before any Firebase calls
- SHA-256 fingerprint registered in Firebase Console
- Status: **Monitoring mode** — metrics visible for both Firestore and Authentication
- Enforcement deferred to production (post-capstone) to avoid blocking sideloaded APKs during academic testing

### Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null
                         && request.auth.uid == userId;
    }
  }
}
```

### Privacy Considerations

| Concern | Current State | Future Plan |
|---------|--------------|-------------|
| Local data | Stored in SQLite on-device only | Add SQLite encryption (sqlcipher) post-capstone |
| Cloud data | Firebase Firestore with user-level security rules | Already secure |
| AI data | Financial context sent to Groq API per message; Groq does not train on API data per their policy | Backend proxy to hide API key post-capstone |
| API key | Hardcoded in APK (mitigated by 60-msg/day cap) | Move to backend proxy post-capstone |
| OCR/Barcode | Processed entirely on-device by ML Kit; no data leaves device | Already private |
| Debug log | Contains all financial data; only exported on explicit user action; API keys masked | Acceptable for capstone |

**For defense:** *"User financial data is stored locally on-device and synced to Firebase Firestore with user-level security rules. AI processing sends anonymized financial context to a third-party LLM API which does not retain or train on user data. For production deployment, a backend proxy would be implemented to prevent direct API key exposure."*

### Data Storage & Sync
- All financial data stored locally in SQLite (on-device) AND synced to Firestore
- **What syncs:** expenses, budgets, goals, income, recurring transactions, debts, custom categories, **installments**, key settings
- **Settings synced:** `monthly_income`, `account_type`, `income_frequency`, `currency`, `setup_done` — pushed to Firestore on logout, restored on login
- **Sync direction:** bidirectional — on login, pulls cloud → merges local (last-write-wins for expenses via `updated_at`), then pushes local → cloud
- **Real-time writes:** every insert/update/delete pushes to Firestore in the background
- **Event bus:** all writes fire `AppEvent` so all screens auto-refresh
- **Account isolation:** on logout, all local financial data is cleared after a final cloud push; chat history is preserved
- **Demo isolation:** `was_demo_mode` flag ensures demo data is cleared before pulling a real account's cloud data on next login
- **Expense sort order:** `date DESC, id DESC` — newest entries always appear first
- **Google Drive backup:** uses `drive.file` scope; creates visible "Smart Spend Backups" folder in user's Drive root. **Requires Drive API enabled in Google Cloud Console and `drive.file` scope added to OAuth consent screen.**
- Profile photo stored locally only (Firebase Storage requires Blaze paid plan)

---

## 📊 Financial Health Score Formula

The FHS uses a **4-component weighted formula** (25 points each, total 100):

```
Component 1 — Savings Rate (25 pts)
  Measures: actual savings vs 20% of income target
  Formula:  25 × min(1, savingsRate / 0.20)
  savingsRate = (income − totalSpent) / income
  Full 25 pts when saving ≥20% of income; scales proportionally below that
  If no income set: partial credit based on spending level

Component 2 — Overspend Control (25 pts)
  Measures: proportion of logged days where spending stayed within daily budget
  Formula:  25 × (1 − overDays / activeDays)
  dailyBudget = monthlyIncome / daysInMonth
  overDays = days where daily spending exceeded dailyBudget
  Full 25 pts when no days exceeded; 0 pts when every day exceeded
  If no income set: 20 pts (partial credit)

Component 3 — Budget Adherence (25 pts)
  Measures: percentage of budget categories that stayed within limit
  Formula:  25 × (onBudgetCategories / totalBudgetCategories)
  Full 25 pts when all budgets on track; 0 pts when all exceeded
  If no budgets set: 25 pts (not penalized for not having budgets)

Component 4 — Logging Consistency (25 pts)
  Measures: regularity of expense entries vs active days in period
  Formula:  25 × (loggedDays / activeDays)
  activeDays = days elapsed this month (clamped to 1–daysInMonth)
  loggedDays = unique days with at least one expense logged
  Full 25 pts when logging every day; scales proportionally

Final score = sum of 4 components, clamped 0–100.
```

### Warning Decay System
If a budget is exceeded and spending continues the next day, the score loses 5 pts/day (max 3 days = −15 pts total). Resets when all budgets return to on-track.

**3-tier escalation notifications:**
- Day 1: Gentle nudge — "Budget tip: consider adjusting spending"
- Day 2: Strong alert — spending comparison summary, mentions FHS impact
- Day 3: Critical warning — projected monthly overspend figure, −15 pts penalty noted

### Score Ranges
- 🟢 **80–100** = Good
- 🟡 **60–79** = Fair
- 🔴 **0–59** = Needs Attention

Tap the score card on the home screen to see the full breakdown with each component's contribution.

---

## 🤖 AI Integration Details

### Model
- Provider: Groq (groq.com)
- Model: llama-3.1-8b-instant
- Temperature: 0.3 (instruction-following mode)
- Max tokens: 1500 per response
- **Daily cap:** 60 messages/user/day (stored in SharedPreferences, resets at midnight)

### Expense Parsing
Input: natural language string
Output JSON:
```json
{
  "item_name": "Jollibee Chickenjoy",
  "category": "Food",
  "amount": 149,
  "date": "2026-04-18",
  "shop_name": "Jollibee",
  "payment_method": "Cash",
  "confidence_score": 0.95
}
```

### Chat Context
Every message includes: monthly income (shows "Not set" if 0), total spent, last 20 expenses (item, category, amount, date, shop), budget status per category, health score, savings goals (up to 5), debts/lending (up to 5), and recurring transactions (up to 8 with due date status).

### Language Detection
Responds in the user's language. Filipino/Tagalog mode requires multiple distinctive Filipino words (e.g. `naman`, `kasi`, `yung`, `paano`, `magkano`, `gusto`, `hindi`, `pera`). Short ambiguous words (`na`, `sa`, `ba`) alone do not trigger Filipino mode. Default is English when in doubt.

### Token Limit
`max_tokens: 2000` — increased from 1500 to prevent ACTION lines being truncated. Parser also attempts to recover truncated JSON by closing incomplete braces.

### Action Parsing
AI appends `ACTION:{...}` lines. Parsed via robust dotAll regex (handles multi-line JSON and markdown bold wrapping), executed against DB immediately, green snackbar shown per action, errors shown as red snackbars. Duplicate actions are deduplicated by JSON content.

### AI CRUD Coverage
| Operation | Supported Actions |
|-----------|------------------|
| **Create** | `log_expense`, `add_goal`, `add_income`, `add_debt`, `add_recurring`, `add_installment_plan` |
| **Read** | Full context — expenses, budgets, income, score, goals, debts, wallets |
| **Update** | `set_budget`, `set_income`, `set_account_type`, `update_goal`, `update_expense`, `update_debt`, `set_wallet_balance` |
| **Delete** | `delete_expense` (requires DELETE confirmation), `delete_goal`, `delete_recurring` |

**Correction behavior:** When the user asks to fix a wrong category or amount, the AI uses `update_expense` to edit the existing entry in-place. For deletion, the AI requires the user to type **DELETE** as confirmation before proceeding. If the AI cannot identify the correct entry, it tells the user to delete manually from the Transactions screen.

### Category Normalization
Both `AIChatService` and `LLMService` use comprehensive Filipino-aware category normalization covering 100+ keywords across **14 built-in categories:**
- **Food:** candy, chips, biscuit, chocolate, ice cream, noodles, pizza, burger, shawarma, siomai, fishball, kwek-kwek, isaw, balut, taho, halo-halo, pansit, adobo, sinigang, silog variants, lomi, lugaw, goto, champorado, Ministop, Family Mart, Greenwich, Goldilocks, Red Ribbon, Starbucks, Dunkin, supermarket, wet market
- **Food delivery (checked BEFORE transport):** GrabFood, Grab Food, Foodpanda, Shopee Food
- **Transportation:** tricycle, trike, pedicab, UV Express, P2P, TNVS, Lalamove, parking, pasada
- **Bills:** WiFi, DITO, mortgage, SSS, PhilHealth, Pag-IBIG
- **Shopping:** Lazada, Shopee, gadgets, appliances, accessories, SM, Ayala, Robinsons
- **Entertainment:** movie, cinema, concert, arcade, bar, videoke, karaoke, event, ticket
- **Gaming:** Steam, Mobile Legends, MLBB, CODM, Roblox, Genshin, Valorant, Dota, top-up, Codashop, UniPin, Xbox, PlayStation, Nintendo, esports
- **Health:** dental, dentist, glasses, eyeglasses, Mercury Drug, Watsons, Rose Pharmacy
- **Education:** notebook, uniform, tuition, books, school supplies, course, training
- **Personal Care:** haircut, salon, barbershop, nail, spa, massage, shampoo, soap, toothpaste, deodorant, lotion, hygiene
- **Clothing:** shirt, pants, jeans, dress, shoes, sneakers, jacket, hoodie, ukay, fashion
- **Gifts:** pasalubong, present, souvenir, donation, charity
- **Travel:** hotel, airfare, airline, flight, Cebu Pacific, AirAsia, resort, tour, Airbnb, hostel
- **Pets:** pet food, dog food, cat food, veterinary, Pedigree, Whiskas
- User-defined rules take priority over all built-in keywords

### AI Language Behavior
- **Default language: English** — always responds in English unless overridden
- Switches to Filipino/Tagalog only if: (1) user writes a full sentence or multiple sentences clearly in Filipino, OR (2) user explicitly demands it ("speak Filipino", "mag-Tagalog ka")
- Taglish (few Filipino words in an English sentence) stays in English
- Once a language is set by explicit demand, it persists until changed again
- Social messages ("thanks", "ok", "next") get a short acknowledgment only — no ACTION lines triggered
- Language change requests ("speak English only") are acknowledged without triggering any data writes

---

## 💱 Currency System
- Base: PHP (Philippine Peso)
- All amounts stored in PHP, converted for display via CurrencyService.format()
- Rates from open.er-api.com, cached 1 hour, offline fallback
- **57 currencies supported** (expanded from 35)
- Includes all major Southeast Asian currencies: PHP, SGD, MYR, IDR, THB, VND, MMK, KHR, LAK, BND, MOP
- Middle East: SAR, AED, KWD, QAR, BHD, OMR, ILS
- Eastern Europe: CZK, PLN, HUF, UAH, RON, HRK, BGN
- Latin America: BRL, MXN, CLP, COP, PEN
- South Asia: INR, PKR, BDT, LKR, NPR
- Note: Rates shown are mid-market (interbank). Actual cashout rates vary by provider — banks typically 3–5% below mid-market, remittance centers ₱0.50–₱2.00/USD below mid-market, digital banks closest to mid-market

---

## 🎨 Theme System
- 5 color themes: Ocean Blue, Sky Blue, Forest Green, Royal Purple, Sunset Orange
- Each theme generates both light and dark ColorScheme via Material 3 ColorScheme.fromSeed()
- Theme + dark mode stored in SharedPreferences
- Applied at app root via ThemeService (ChangeNotifier)

---

## 🔮 Known Limitations & Deferred Features

### Current Limitations
| Area | Limitation |
|------|-----------|
| Profile Photo | Stored as local file path — Firebase Storage requires Blaze (paid) plan; cross-device photo sync is a planned future feature |
| AI Model | Shared Groq API key — daily cap of 60 messages mitigates abuse; for production, use a backend proxy |
| OCR Accuracy | ML Kit may struggle with handwritten or low-quality receipts |
| Offline AI | All AI features require internet |
| Anonymous Login | Demo mode is local-only; no Firebase anonymous auth |
| Firestore Sync | Last-write-wins on expenses via `updated_at`; full CRDT conflict resolution is a future feature |

### Deferred Features (Planned)
| Feature | Status | Reason |
|---------|--------|--------|
| Per-user SQLite isolation | ✅ Mitigated — logout clears local DB, demo flag prevents bleed | Full row-level tagging deferred |
| API proxy for Groq key | ✅ Mitigated — 60 msg/day cap limits abuse | Backend proxy deferred |
| True conflict resolution (CRDT) | ✅ Mitigated — last-write-wins on `updated_at` | Full CRDT deferred post-capstone |
| Spending comparison by category | ✅ Implemented — this month vs last month table in Analytics | — |
| Budget time-aware progress bars | ✅ Implemented — pace indicator + month elapsed hint | — |
| Pie chart drilldown | ✅ Implemented — tap legend item to see transactions | — |
| Income frequency editable post-setup | ✅ Implemented — frequency selector in Profile income dialog | — |
| Health score income-relative thresholds | ✅ Implemented — income-ratio base score | — |
| Theme color consistency (all screens) | ✅ Implemented — all hardcoded blues replaced with theme primary | — |
| App-lock / biometric re-auth on resume | ✅ Implemented — PIN + biometric lock screen, lifecycle-aware | — |
| SQLite encryption | ⏸️ Deferred | Requires additional native plugin |
| Firebase Storage for profile photos | ⏸️ Deferred | Requires Blaze (paid) plan |
| Cloud Functions for scheduled tasks | ⏸️ Deferred | Requires Blaze (paid) plan |

### Recommended Future Improvements
1. Firebase Storage (Blaze plan) for profile photo sync across devices
2. Backend proxy for Groq API key security
3. Firebase Anonymous Auth for persistent guest accounts
4. SQLite encryption via sqlcipher
5. Pinch-to-zoom on OCR/barcode scanner
6. Recurring auto-log via background task (WorkManager)
7. **Full agentic AI** — autonomous bill payment via GCash/Maya Open Finance API or PayMongo (requires BSP compliance + business registration)
8. Soft-delete mechanism for proper cross-device sync
9. Typed models for SavingsGoal, Debt, Income tables
10. AI savings plan advisor — budget cut suggestions to reach savings goals

> See `FINAL_STATUS.md` → Future Roadmap & Wishlist for detailed blockers and implementation plans for each item.

---

## ⚠️ Disclaimers

- Tax estimations use simplified PH BIR TRAIN Law brackets — not official tax advice
- AI-generated insights are based on user-provided data — not professional financial advice
- Exchange rates from free public API — may have slight delays
- This is an academic capstone project — not intended for production financial use
- Minimum wage references are approximate

---

## 📄 License

Developed as a capstone requirement for academic year 2025–2026.
All rights reserved by **Lucid Frame**, 2026.

---

*Smart Spend — Spend Smart, Live Better.*

---

## 📋 Pending Work & Roadmap

*Last updated: May 3, 2026. Prioritized for next development session.*

### 🔴 HIGH — Next Session Priority

| # | Item | Effort | Description |
|---|---|---|---|
| BC-1 | Bill Calendar — unified financial timeline | Medium | Add debt due dates, goal deadlines, installment payment days, income expected dates, payday marker — all color-coded by type |
| BC-2 | Bill Calendar mini-card on home screen | Low | Show next 3 upcoming financial events with dates and type |
| BC-3 | Bill Calendar → Log Now shortcut | Low | Tap a bill on calendar to log it directly |
| GM-1 | Daily Challenges card on home screen | Medium | 3 daily tasks (log 2 expenses, stay under budget, check score) — highest retention mechanic |
| GM-2 | Expanded badge system + Achievements screen | Medium | 16 badges, dedicated screen in Profile, locked badges shown as silhouettes |
| GM-3 | Logging streak (separate from score streak) | Low | Consecutive days with ≥1 expense logged |
| UX-1 | Empty state guidance on all screens | Low | Budgets/Goals/Debts/Recurring empty screens should suggest an action |
| CF-1 | Confidence score filter in Transactions | Low | "Show low-confidence only" chip — data already in DB |
| **FC-3** | **AI tags Want/Need during logging** | Low | Add is_want inference to AI action parser — makes 50/30/20 accurate (currently all AI entries default to Need) |
| **NI-4** | **quiz_challenge setting actually used** | Medium | Onboarding answer (debt/overspending/saving/tracking) stored but never referenced — should influence home cards, AI advice, analytics emphasis |
| **FC-1** | **Mood → AI context injection** | Low | Pass today's mood score + note to AIChatService.setFullContext — AI adjusts tone based on mood |
| **NI-2** | **Goal pace indicator** | Low | "You need ₱X/month to reach this by deadline — you're ₱Y/month behind" — all fields already stored |

### 🟠 MEDIUM — Before Defense

| # | Item | Effort | Description |
|---|---|---|---|
| PM-1 | Payment method breakdown in Analytics | Low | Pie/bar chart by Cash/GCash/Card — data already in DB |
| SM-1 | Top merchants card in Analytics | Low | "You've been to Jollibee 12 times" — shop_name already in DB |
| SH-1 | FHS Score history annotations | Medium | Why did score drop on specific days — markers on line chart |
| GM-4 | Savings goal milestone celebrations | Low | Confetti animation at 25/50/75/100% |
| GM-5 | Level/rank system on Profile | Medium | 8 levels (Beginner → Money Master), XP bar |
| GM-6 | "Financial Health Level Up" notification | Low | Push notif when FHS crosses 60/70/80/90 for first time |
| IN-1 | Income analytics — breakdown by category + trend | Medium | Income screen is just a list — add a chart |
| DT-1 | Debt interest projection | Low | "At this rate you'll pay ₱X in interest" — field already stored |
| RC-1 | Recurring total cost calculation | Low | "Paying Netflix for 8 months = ₱2,392 total" — start_date stored |
| RC-2 | Recurring → Budget auto-suggest | Low | When adding recurring expense, offer to create matching budget |
| IN-2 | Installment → Recurring link | Low | Offer to create recurring payment reminder when adding installment |
| NT-1 | Notes search in Transactions | Low | Notes field stored but never searchable |
| NT-2 | Notes visible in AI context | Low | AI can't see expense notes — add to context |
| UX-2 | Shareable financial summary card | Low | "This month: spent ₱8,200, saved ₱1,800, FHS 74" via share_plus |
| UX-3 | Goal contribution suggestion from income | Low | When logging income: "Allocate 20% to your New Laptop goal?" |
| UX-4 | Emergency Fund prompt for users without one | Low | Home screen card: "You don't have an emergency fund. Start one?" |
| **UD-7** | **mood_log.note field exposed** | Low | Optional one-line "what's going on?" text when logging mood |
| **FC-5** | **Windfall flag actually used in FHS/forecast** | Low | Verify PredictService and FHS savings rate exclude windfall income from baseline |
| **FC-6** | **Category rules show match count** | Low | Show "triggered 8 times, last: May 3" per rule |
| **BT-1** | **Quick-log chips show spend trend** | Low | "↑ ₱20 more than usual" indicator on each chip |
| **BT-2** | **FHS decay visible on score card** | Low | Show amber indicator when decay is active |
| **BT-4** | **AI limit shows reset countdown** | Low | "Resets in 4h 22m" instead of just remaining count |
| **BT-5** | **Recurring Log Now pre-fills amount** | Low | Variable bills need editable amount before confirming |
| **NI-1** | **"Where did my money go?" focused AI card** | Low | 1-sentence cached AI answer on home |
| **NI-6** | **"I'm done spending today" toggle** | Low | Voluntary commitment mode with warning if expense logged after |
| **NI-7** | **Recurring income gets special home card** | Low | is_expense=0 recurring shown as "Your allowance is due — log it?" |
| **UD-4b** | **Auto-rule from correction** | Medium | When user edits AI-parsed category, auto-create a category_rule |
| **NI-3** | **AI fuzzy duplicate detector** | Medium | Before logging, check if similar item exists in last 2 hours |
| **BT-3** | **50/30/20 tracker respects period filter** | Medium | Currently always shows this-month data regardless of selected period |
| **BT-6** | **Anomaly detection on-log** | Medium | After each AI expense log, check if anomalous — fire immediately, not just Sunday |
| **NI-5** | **Net worth trend sparkline** | Medium | Daily/weekly net worth snapshot + sparkline on Profile card |

### 🟡 LOW — Nice to Have

| # | Item | Effort | Description |
|---|---|---|---|
| GM-7 | Weekly challenge system | Medium | Monday challenge: "Spend less than ₱500 on Food this week" |
| GM-8 | Spending Challenge Mode | Medium | User sets personal monthly challenge with win/lose result |
| GM-9 | "Better than last month" comparison | Low | "You spent ₱800 less than last month — best month yet! 🏆" |
| UX-5 | What's New / changelog screen | Low | One-time dialog after update showing new features |
| UX-6 | Time-of-day spending analysis | Low | "You spend most between 12–1 PM" — time field already stored |
| UX-7 | AI proactive check-in on app open | Medium | "You haven't logged in 2 days — want to catch up?" |
| UX-8 | Bulk actions in Transactions | Medium | Long-press → select multiple → bulk delete/recategorize |
| UX-9 | Tax estimate surfaced in Profile | Low | Currently hidden in Analytics — show as card in Profile |
| UX-10 | Swipe to delete/edit on expense tiles | Low | Standard mobile UX — swipe left to delete, right to edit |
| UX-11 | Haptic feedback on key actions | Low | Light vibration on expense logged, badge earned, goal reached |
| UX-12 | Expense tile long-press menu | Low | Add "Duplicate", "Change category", "Add note" options |
| WN-1 | "Review untagged expenses" prompt | Low | Nudge to tag Want/Need on untagged expenses |
| WN-2 | Want/Need insight notification | Low | Alert when Want spending is unusually high |
| SH-2 | Scan history connected to expenses | Medium | "This barcode was logged 3 times" |
| SC-1 | Score history + mood on Bill Calendar | Medium | Show score drops and mood dots on calendar |
| CC-1 | Custom category grouping for 50/30/20 | Medium | Let users assign custom categories to Needs/Wants/Savings |
| **UD-9** | **Installment payoff date + total interest** | Low | "Payoff: March 2027 · Total interest: ₱X" — all fields already stored |
| **FC-2** | **Score history dots on Bill Calendar** | Medium | Color-coded score dots per day — turns calendar into financial journal |

### 🔵 Capstone 2 / Post-Defense

| # | Item | Notes |
|---|---|---|
| 5 | CSV/Bank import (GCash, Maya, BDO, BPI) | High effort — packages already in pubspec |
| K | ~~Multi-wallet system (GCash/Cash/Bank/Savings)~~ | ✅ **DONE** — Wallet Balances feature implemented (section 61) |
| L | Backend API proxy for Groq key | Pre-Play Store requirement |
| M | DB indexes for performance at scale | Low urgency — needed at 1000+ expenses |

### Underutilized Features (Data Exists, Not Displayed)

| Field | Where Stored | Currently Used | Potential |
|---|---|---|---|
| `confidence_score` | expenses table | Orange dot on tile | Filter, accuracy analytics, feedback loop |
| `payment_method` | expenses table | Shown in tile | Analytics breakdown by payment type |
| `shop_name` | expenses table | Shown in tile | Top merchants chart, merchant-based rules |
| `time` | expenses table | Shown in tile | Time-of-day spending analysis |
| `notes` | expenses table | Shown in tile | Search, AI context |
| `is_want` | expenses table | 50/30/20 tracker | AI tagging, Want spending alerts |
| `interest_rate` | debts table | Not displayed | Interest projection, payoff strategy |
| `start_date` | recurring table | Not displayed | Total cost calculation ("8 months = ₱X") |
| `score_history` | score_history table | Line chart only | Annotations, calendar dots, mood correlation |
| `scan_history` | scan_history table | History screen | Link to expenses, quick-log suggestions |
| `income.category` | income table | List only | Income breakdown chart, trend |

---

## 🎤 Defense Script — How to Explain Smart Spend

*Use this as a guide when presenting or defending the app. Adapt to your audience.*

---

### Opening (30 seconds)

> "Smart Spend is an AI-powered personal finance app for Android, built specifically for everyday Filipinos — students, employees, freelancers, and business owners. The core idea is simple: instead of manually filling out spreadsheets or forms, you just talk to the app in plain language and it handles everything automatically."

---

### The Problem We're Solving (1 minute)

> "Most Filipinos don't track their spending — not because they don't want to, but because existing tools are too complicated or time-consuming. You have to open an app, find the right category, type in the amount, pick a date — it's friction. So people give up after a week.
>
> Smart Spend removes that friction entirely. You just say 'I spent 150 pesos on Jollibee' and the app logs it, categorizes it as Food, and updates your budget — all in one step."

---

### How It Works — The Pipeline (2 minutes)

> "The app has four ways to log an expense:
>
> 1. **AI Chat** — type or speak naturally. 'Bought chips for 25 pesos' → logged instantly.
> 2. **Voice Input** — tap the mic, speak, done.
> 3. **Smart Scanner** — point at a barcode or receipt. The camera reads it automatically.
> 4. **Manual Entry** — traditional form for when you want full control.
>
> Under the hood, all text input goes through our AI engine — Groq's LLaMA 3.1 8B model. It extracts the item name, amount, category, date, and payment method from whatever you typed. It also decides if the expense is a Want or a Need, which feeds into our budgeting analysis."

---

### Key Features Walkthrough (3–5 minutes)

**Financial Health Score:**
> "The app calculates a score from 0 to 100 every time you log an expense. It has four components: Savings Rate, Overspend Control, Budget Adherence, and Logging Consistency — each worth 25 points. This gives users a single number that tells them how well they're managing their money this month."

**Analytics:**
> "The Analytics screen shows spending by category as a pie chart, monthly trends as a bar chart, and a day-of-week heatmap. There's also a 50/30/20 Rule tracker that automatically classifies your spending into Needs, Wants, and Savings and compares it to the recommended targets. The Category Breakdown table shows each category with its amount, percentage, and budget progress bar."

**Bill Calendar:**
> "The Financial Calendar is one of our most useful features. It shows all your upcoming financial events on a single calendar — recurring bills, debt due dates, savings goal deadlines, and payment plan due dates — all color-coded. You can tap any day to see what you spent that day and what events are coming up. Tapping an expense row takes you directly to edit it."

**Payment Plans:**
> "We have a Payment Plans tab in the Debts screen for services like ShopeePayLater, GCash GLoan, and HomeCredit. You add the plan once, and the app tracks your monthly payments, shows the next due date, calculates remaining balance, and even shows projected interest. Payments appear on the Bill Calendar automatically."

**Behavioral Features:**
> "Beyond tracking, Smart Spend has behavioral nudges. The Impulse Pause mechanic shows a reflection prompt when you try to log a large Want expense — it doesn't block you, it just makes you think. The Mood Check-In lets you log how you're feeling each day, and the app correlates your mood with your spending patterns over time."

---

### Technical Architecture (for technical audiences)

> "The app is built with Flutter for Android. Data is stored locally in SQLite and synced to Firebase Firestore. The AI uses Groq's API with LLaMA 3.1 8B Instant — we chose this because it's fast, free-tier friendly, and handles Filipino context well.
>
> The AI architecture is what we call 'context injection' — before every message, we query the local database and inject the user's complete financial context into the system prompt. This gives the AI full awareness of the user's expenses, budgets, goals, and debts without needing a vector database or RAG pipeline. It's lightweight, works offline-capable, and gives accurate, personalized responses."

---

### What Makes It Different (1 minute)

> "Most finance apps are passive — they show you charts after the fact. Smart Spend is active. The AI doesn't just record data, it acts on it. It can set budgets, create goals, log debts, and give advice — all from a single chat message.
>
> We also designed it specifically for Filipino users — the AI understands Filipino food brands, local transport terms like jeepney and tricycle, and Filipino financial services like GCash, ShopeePayLater, and SSS contributions."

---

### Academic Contribution

> "From a research perspective, Smart Spend demonstrates that a context-injection agentic AI architecture can replace traditional RAG pipelines for personal finance applications on mobile devices. The system achieves real-time, personalized financial advice without a backend server, vector database, or cloud compute — running entirely on a free-tier Firebase + Groq API stack."

---

### Closing

> "Smart Spend is designed to make financial literacy accessible to every Filipino, regardless of their background or technical skill. You don't need to know what a budget is to use it — you just need to tell it what you spent."

---

---

## 🗺️ Complete Feature Status & Roadmap

### ✅ Fully Implemented (v2.5.0)

All features listed in sections 1–62 of this document are fully built and working in the current build. Key highlights:
- **16 AI action types:** log_expense, set_budget, set_income, add_income, add_goal, update_goal, add_debt, update_debt, add_recurring, delete_recurring, set_account_type, update_expense, delete_expense, add_installment_plan, delete_goal, set_wallet_balance
- **62+ features** across all screens
- **Wallet Balances** — Cash on Hand, GCash, Maya, 17 PH banks, remittance centers (section 61)
- **Firebase App Check** — Play Integrity integrated, monitoring mode (section 62)
- **14 built-in categories** — added Gaming, Personal Care, Clothing, Gifts, Travel, Pets
- **9 payment methods** — Cash, GCash, Maya, GrabPay, ShopeePay, Debit Card, Credit Card, Bank Transfer, Others
- **57 currencies** supported
- Full Firestore sync including Payment Plans and Wallet Balances
- Weekly notifications fixed (was using wrong week key)
- 2 Crashlytics crashes fixed (analytics firstWhere null, shake MissingPluginException)
### ⬜ Deferred to Capstone 2

These features were planned but deferred because they require significant architectural changes, new packages, or are lower priority than defense-critical items.

| Feature | Why Deferred | Estimated Effort | When |
|---------|-------------|-----------------|------|
| ~~**Multi-wallet system** (GCash/Cash/Bank/Savings)~~ | ✅ **DONE** — Wallet Balances feature tracks Cash on Hand, GCash, Maya, 17 banks, remittance centers. Note: this is balance tracking, not full multi-wallet with transfers. | — | Implemented v2.5.0 |
| **Transfer transactions** (Cash → GCash top-up) | Needs wallet system first. New transaction type that must be excluded from expense analytics. | High | After wallet system |
| **Spending heatmap calendar** | Custom Flutter widget showing daily spend intensity by color. No DB needed but significant UI work. | Medium | Capstone 2 |
| **Debt payment timeline** | Visual payoff projection chart per debt. Data exists, just needs visualization. | Medium | Capstone 2 |
| **PDF export (monthly summary)** | Needs `pdf` + `printing` packages (~2MB APK increase). Clean printable report for parents/employers. | Medium | Capstone 2 |
| **Quick-log chip customization** | Let users pin specific expenses as permanent quick-log chips. Currently auto-derived from history. | Low | Capstone 2 |
| **AI conversation export** | Export full chat history as text file via share_plus. Data already in DB. | Low | Capstone 2 |
| **Investment tracking** (MP2, stocks, crypto) | New wallet type with manual balance updates. No live price feeds in v1. | Low (after wallet) | Capstone 2 |
| **FHS trend annotations** | Markers on score history chart showing what caused drops. | Low | Capstone 2 |
| **Biometric lock for sensitive screens** | Per-screen biometric re-auth for Debts/Net Worth. App-level lock already exists. | Low | Capstone 2 |
| **Google profile picture as default avatar** | Fetch `user.photoURL` from Firebase Auth on Google Sign-In. Low effort, medium value. | Low | Before Play Store |

---

### 🚫 Blocked / Post-Capstone

These features cannot be implemented before the defense due to external dependencies, paid services, or architectural risks.

| Feature | Reason Blocked | Can It Be Done Later? |
|---------|---------------|----------------------|
| **SQLite encryption** | SQLCipher requires native plugin + full DB migration. Breaking change to v11 schema. All existing user data would need re-encryption. | Yes, post-capstone with DB v12 |
| **Profile photo cross-device sync** | Firebase Storage requires Blaze (paid) plan at ~$25/month. Photos are stored locally only by design. | Yes, if budget allows |
| **Cloud Functions & scheduled tasks** | Firebase Blaze plan required. Currently using client-side triggers (app open = check). | Yes, with paid Firebase |
| **Backend API proxy (hide Groq key)** | Needs a backend server (Node.js/Python). Currently key is in APK, mitigated by 60 msg/day cap. Required before Play Store submission. | Yes, post-capstone |
| **Bank notification auto-parsing** | `BIND_NOTIFICATION_LISTENER_SERVICE` is flagged as sensitive by Google Play. Requires manual user setup in Android Settings → Notification Access. Notification formats change frequently. | Unlikely for Play Store |
| **Agentic bill payment** (GCash/Maya) | Requires BSP (Bangko Sentral ng Pilipinas) license for payment processing. GCash/Maya APIs are not publicly available. PCI-DSS compliance required. | Blocked indefinitely |
| **Offline AI mode** | Would need a local LLM model. Smallest viable models (Llama 3.2 1B) require ~2GB storage and significant RAM. Not feasible on budget phones. | Possible post-capstone with quantized models |
| **Soft-delete for sync resurrection** | Requires `deleted_at` column on all tables — major schema migration. Edge case: item deleted on Device A reappears when Device B syncs. | Yes, with DB v12 planning |
| **Privacy policy** | Required for Google Play publishing. Not needed for academic defense. | Yes, before Play Store submission |
| **Data anonymization** | Required for formal data collection beyond academic use. IRB/ethics board approval needed. | Yes, post-capstone |
| **True single-screen receipt capture** | mobile_scanner v5 has breaking API changes from v3.5.7 we use. Upgrade would require significant refactoring. | Yes, when v5 is stable |
| **AI voice response / TTS** | flutter_tts sounds robotic. Cloud TTS (Google/ElevenLabs) has per-character cost. Groq has no TTS endpoint. | Yes, with cloud TTS budget |
| **Email receipt parsing** | Gmail API requires Google app verification for production apps. IMAP requires user password (security risk). | Yes, post-capstone with Gmail OAuth |
| **Shared/family wallets** | Multi-user Firestore architecture + invite system + conflict resolution. Major backend changes. | Yes, future v3+ |

---

### 🔒 Known Limitations (for Defense Q&A)

These are intentional design decisions or platform constraints — not bugs.

| Limitation | Explanation | Mitigation in Place |
|-----------|-------------|-------------------|
| Groq API key in APK | Free-tier key exposed in compiled code | 60 msg/day cap limits abuse; backend proxy planned post-capstone |
| 429 rate limit errors | Groq free tier limits rapid-fire requests (~3 req/sec) | Friendly error message; wait 2–3 seconds between messages |
| Profile photo local-only | Firebase Storage requires paid plan | Photos stored on device; sync planned post-capstone |
| Offline AI | Groq API requires internet | Manual entry works fully offline; AI features degrade gracefully with friendly errors |
| Last-write-wins sync | No CRDT conflict resolution | Acceptable for single-user app; multi-device edge cases documented |
| SQLite not encrypted | SQLCipher migration too risky pre-defense | Data behind Firebase Auth + app lock PIN |
| 60 AI messages/day | Shared API key protection | Resets at midnight UTC; Reset Daily Limit option in ⋮ menu |
| App Check not enforced | Sideloaded APK during academic phase | App Check integrated + monitoring; enforcement deferred to production |

---

*Smart Spend v2.5.0 — Lucid Frame*
*Brix A. Directo · Cyrille John M. Rubis · Djaunathan Albert S. Madayag*
*Lorma Colleges — CCSE, BSIT — City of San Fernando, La Union — 2025–2026*
