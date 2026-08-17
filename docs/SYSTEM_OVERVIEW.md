# SmartSpend — System Overview
## How the Application Works
**Version:** 2.9.2 | **Group:** Lucid Frame | **Academic Year:** 2026–2027, 1st Semester
**Prepared for:** Adviser Introduction & Panel Defense Reference

---

## WHAT IS SMARTSPEND?

SmartSpend is an **AI-assisted mobile financial tracking and advisory application** for Android. It helps Filipino users — parents and young professionals — automatically record, analyze, and manage their personal finances using natural language, voice, camera, and screenshots instead of manual forms.

**Core principle:**
> You just *tell* the app what you spent. It handles the rest.

---

## THE PROBLEM IT SOLVES

Most Filipinos do not track finances because:
- Manual apps require too much effort (forms, dropdowns, categories)
- No apps are designed for Filipino context (GCash, jeepney, Jollibee, SSS, Pag-IBIG)
- Apps give no meaningful feedback — just a list of expenses
- No free, offline-capable option with AI exists for the Philippine market

**SmartSpend's answer:** Remove the manual effort entirely using AI, and give users a score that makes their financial behavior visible and actionable.

---

## HOW THE SYSTEM WORKS — OVERVIEW DIAGRAM

```
╔══════════════════════════════════════════════════════════════════╗
║                        USER INPUTS                               ║
║                                                                  ║
║  🎙️ Voice     ✏️ Text      📷 Camera      📸 Screenshots         ║
║  "I spent    "lunch 85   Scan receipt   Shopee order            ║
║  85 jeepney"  pesos"     or barcode     Steam purchase          ║
╚══════════════════════╦═══════════════════════════════════════════╝
                       ║
                       ▼
╔══════════════════════════════════════════════════════════════════╗
║                    AI PROCESSING LAYER                           ║
║                                                                  ║
║  Multi-Model LLM (Gemini 3.1 Flash-Lite primary)                ║
║                                                                  ║
║  • Understands Filipino-English natural language                 ║
║  • Extracts: amount, category, date, merchant, want/need         ║
║  • Routes to correct action (log, update, analyze, advise)       ║
║  • 29 autonomous action types                                    ║
║  • Falls back to 4 other providers if rate limit hit             ║
╚══════════════════════╦═══════════════════════════════════════════╝
                       ║
                       ▼
╔══════════════════════════════════════════════════════════════════╗
║                   LOCAL DATABASE (SQLite)                        ║
║                                                                  ║
║  Stores everything ON DEVICE — works 100% offline               ║
║                                                                  ║
║  • Expenses (20+ fields per entry)                               ║
║  • Budgets per category                                          ║
║  • Savings goals                                                 ║
║  • Debts & payment plans                                         ║
║  • Wallet balances (GCash, Maya, BDO, BPI, 30+ banks)           ║
║  • Recurring bills & subscriptions                               ║
║  • Mood log, chat history, score history                         ║
║  SQLite v11 schema — 20 tables                                   ║
╚══════╦═══════════════════════════╦══════════════════════════════╝
       ║                           ║
       ▼                           ▼
╔══════════════╗         ╔═════════════════════════════════════════╗
║  ANALYTICS   ║         ║           CLOUD SYNC (Firebase)         ║
║  ENGINE      ║         ║                                          ║
║              ║         ║  • Auto-syncs to Firestore on save       ║
║  FHS Score   ║         ║  • Restores data on login / new device   ║
║  Charts      ║         ║  • UID-scoped security rules             ║
║  Summaries   ║         ║  • Works offline, syncs when online      ║
║  Forecasts   ║         ║  • Crashlytics for error reporting        ║
╚══════╦═══════╝         ╚═════════════════════════════════════════╝
       ║
       ▼
╔══════════════════════════════════════════════════════════════════╗
║                        USER OUTPUTS                              ║
║                                                                  ║
║  📊 Financial Health Score (0–100)                               ║
║  📈 Spending charts, trends, forecasts                           ║
║  🔔 Smart alerts (budget exceeded, bill due, FHS drop)           ║
║  🤖 AI advice ("You can save ₱500 if you cut food by 20%")       ║
║  📋 Weekly / monthly / yearly summaries                          ║
║  🏆 Achievements & daily quests                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

---

## THE 4 INPUT METHODS IN DETAIL

### 1. AI Chat (Text or Voice)
The user types or speaks naturally. The AI parses the message and takes action immediately.

```
User says:  "I spent 150 pesos on Jollibee"
               ↓
AI extracts: amount=150, category=Food, merchant=Jollibee, type=Want
               ↓
AI writes directly to SQLite database
               ↓
User sees:  ✅ "Logged: Food — Jollibee ₱150.00"
```

The AI can also answer questions beyond just logging:
- "How much did I spend on food this month?" → pulls from DB, summarizes
- "Can I afford a ₱5,000 laptop?" → checks budget, goals, spending rate
- "How do I apply for SSS loan?" → general PH financial knowledge

### 2. Smart Camera (4 modes)
One camera button opens a choice of 4 import methods:

| Mode | How it works |
|------|-------------|
| **Live Camera** | Point at barcode/QR → live detection → product lookup via AI |
| **Single Photo** | Pick one image → app auto-detects if it's a barcode, receipt, or app screenshot → routes correctly |
| **Batch Screenshots** | Pick up to 10 screenshots → each OCR'd and analysed by a platform-specific AI prompt (40+ platforms: Shopee, Steam, GCash, Grab, etc.) |
| **Paste Text** | Paste GCash history, BPI statement, or any transaction text → AI parses all entries at once |

### 3. Manual Entry
Standard form with AI-assisted category suggestions based on item name.

### 4. Bank/Wallet Import
Paste raw transaction history from GCash, Maya, BDO, BPI, or any bank's export — AI parses dates, amounts, and merchants automatically.

---

## THE FINANCIAL HEALTH SCORE (FHS) — CORE ACADEMIC CONTRIBUTION

The FHS is a single number from 0 to 100 that represents how well the user is managing their finances in the current month. It is computed entirely from the user's own recorded data — no external benchmarks or bank connections needed.

### Full Mode (when income tracking is ON)

```
FHS = 25pts + 25pts + 25pts + 25pts
       │        │        │        │
       │        │        │        └── Logging Consistency
       │        │        │            (how many days you logged expenses)
       │        │        │
       │        │        └─────────── Budget Adherence
       │        │                     (% of category budgets on track)
       │        │
       │        └──────────────────── Overspend Control
       │                              (days stayed within daily budget)
       │
       └───────────────────────────── Savings Rate
                                      (actual savings vs 20% target)
```

### Lightweight Mode (when income tracking is OFF)
For students, freelancers, informal workers — no income required.

```
FHS = Spending Restraint + Logging Consistency + Category Balance + Habit Streak
```

### Score Adjustments (applied on top)
- **Warning Decay:** −5 pts/day (max −15) if budget warning is ignored and spending continues
- **Gap Adjustment:** +2 pts for confirmed no-spend days, −3 pts for unlogged spending days

### Score Interpretation
| Score | Rating |
|-------|--------|
| 90–100 | 👑 Excellent |
| 80–89 | 🏆 Great |
| 70–79 | ⭐ Good |
| 60–69 | 🌱 Fair |
| Below 60 | 📉 Needs Work |

---

## THE 29 AI ACTIONS — WHAT THE AI CAN DO AUTONOMOUSLY

The AI doesn't just answer questions — it takes real actions directly on the user's data. Every action writes to the local SQLite database.

| Category | Actions |
|----------|---------|
| **Expenses** | Log, update (fix amount/category/name/date), delete, delete by date range |
| **Income & Wallets** | Set monthly income, log income entry, set wallet balance, transfer between wallets |
| **Budgets** | Set or update category budget limits |
| **Goals** | Add savings goal, update goal (amount + deadline), delete goal |
| **Debts** | Add debt/lending, record payment, update due date |
| **Recurring** | Add recurring bill/subscription, delete recurring |
| **Payment Plans** | Add installment plan (ShopeePayLater, GCash GLoan, etc.) |
| **Analysis** | Split salary (50/30/20), analyze goal feasibility, suggest debt payoff strategy, generate monthly plan, compare two time periods, explain FHS breakdown, project savings timeline, detect subscriptions, compute SSS/PhilHealth/Pag-IBIG contributions, suggest idle money usage, suggest expense cuts, simulate what-if scenario, create debt payment plan, split shared expense |
| **Account** | Change account type |

---

## TECHNOLOGY STACK — SIMPLE EXPLANATION

| What | Technology | Why |
|------|-----------|-----|
| App framework | Flutter (Dart) | One codebase for all Android phones, near-native speed |
| AI engine | Gemini 3.1 Flash-Lite + 4 fallbacks | Free tier, fast, understands Filipino-English |
| Local storage | SQLite (offline-first) | Works with no internet, instant access |
| Cloud sync | Firebase Firestore | Free tier, real-time sync across devices |
| Login | Firebase Auth | Google Sign-In + email/password |
| Camera/OCR | Google ML Kit | On-device, no extra API key needed |
| Barcode | ML Kit + MobileScanner | Live detection + gallery image support |
| Crash reports | Firebase Crashlytics | Automatic error logging |
| API security | Firebase Remote Config | API key never stored in the APK |

**Architecture:** Fully serverless — no backend server. All logic runs on the phone + Firebase + third-party APIs. Zero hosting costs.

---

## DATA FLOW — END TO END

```
1. USER INPUT
   └─ Voice / Text / Camera / Screenshot / Paste

2. INPUT PROCESSING
   ├─ Voice → Speech-to-Text (on-device, en-PH locale)
   ├─ Camera → ML Kit OCR (on-device, no API needed)
   ├─ Screenshot → OCR + platform detection (40+ types)
   └─ Text → sent directly to AI

3. AI CONTEXT INJECTION
   └─ Before every AI call, app queries SQLite and builds a
      context string: current expenses, budgets, income, goals,
      debts, wallets. Injected into the AI system prompt.
      → AI always "knows" the user's financial situation.

4. AI PROCESSING
   └─ Returns structured JSON: action_type + parameters
      Example: {"type":"log_expense","amount":150,"category":"Food",...}

5. ACTION EXECUTION
   └─ App reads the JSON → executes the correct database operation
      → shows confirmation to user → syncs to Firebase

6. ANALYTICS & FEEDBACK
   └─ FHS recalculated → charts updated → alerts checked
      → startup briefing prepared for next app open
```

---

## KEY FEATURES AT A GLANCE

| Feature | Description |
|---------|-------------|
| 29 AI actions | Full autonomous financial management via chat |
| Financial Health Score | 0–100 score, dual mode (Full + Lightweight) |
| Smart Import | 4-mode camera: Live, Single Photo, Batch (40+ platforms), Paste Text |
| Wallet Balances | Track Cash, GCash, Maya, BDO, BPI, 30+ PH banks |
| Multi-period Spending Limits | Daily / weekly / monthly / yearly caps |
| Logging Gap Detection | Startup check — confirms no-spend days for accurate FHS |
| Budget Management | Per-category limits with pace indicators |
| Savings Goals | With emergency fund auto-calculator |
| Debt & Lending Tracker | With payment plans (ShopeePayLater, GLoan, etc.) |
| Insurance & Contributions | SSS, PhilHealth, Pag-IBIG, private insurance |
| Gamification | 23 achievement badges, 10 daily quests, streak tracking |
| Mood Tracking | Daily check-in with spending correlation in Analytics |
| Offline-first | 100% works with no internet — syncs when back online |
| Demo Mode | Full app with pre-loaded Filipino sample data — no sign-up needed |
| App Lock | PIN + biometric, cold-start only (like GCash/Maya) |
| 5 AI providers | Auto-failover: Gemini 3.1 → Gemini 3.5 → Groq LLaMA 3.3 → LLaMA 3.1 → Cerebras |
| Filipino-first | Understands jeepney, GCash, Jollibee, SSS, siomai, 11.11 sales |
| Multi-currency | 57 currencies, live exchange rates |

---

## WHO IT IS FOR

| User Type | Age | How They Use It |
|-----------|-----|----------------|
| **Parents** (Primary) | 35–55 | Track household expenses, manage family budget, monitor bills, get SSS/PhilHealth guidance |
| **Young Professionals** (Secondary) | 21–35 | Track personal income and expenses, set savings goals, manage debt |
| Demo / Evaluators | Any | Explore full features using realistic Filipino sample data without registering |

**Research basis:** BSP Financial Inclusion Survey 2021 — parents aged 35–55 are the primary household financial decision-makers in the Philippines, yet have the lowest rate of structured budgeting among all adult demographics.

---

## PROJECT STATUS

| Item | Status |
|------|--------|
| System development | ✅ Complete — v2.9.2 |
| All 20 modules | ✅ Implemented and tested |
| GitHub repository | ✅ Public — github.com/Zushikina-kun/smartspend-app |
| Release APK | ✅ Available — v2.9.2 (arm64-v8a: 44.7 MB) |
| Chapters 1 & 2 | ✅ Complete in manuscript |
| Panel recommendations (29) | ✅ 21 done / 7 ready to apply in Google Docs / 2 physical action pending |
| Pre-final defense readiness | ✅ Confirmed by teacher-in-charge |
| SUS evaluation | ⏳ Pending — Week 7 after pre-final defense |
| Chapters 3–5 | ⏳ In progress |

---

## COMPARISON TO EXISTING APPS

> For the full 14-app feature matrix see `docs/BENCHMARK.md`.

| Feature | Tarsi | YNAB | Monarch | Copilot | BudgetPH | Alkansya AI | **SmartSpend** |
|---------|-------|------|---------|---------|----------|-------------|---------------|
| Offline mode | ✅ | ❌ | ❌ | ❌ | ✅ | ❌ | ✅ |
| AI chat assistant | ❌ | ❌ | ❌ | ⚠️ Basic | ⚠️ Insights | ✅ Chat | ✅ **29 actions** |
| Financial Health Score | ❌ | ❌ | ❌ | ❌ | ✅ Simpler | ❌ | ✅ 0–100 dual-mode |
| Filipino-English AI | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ Full Taglish |
| Batch screenshot import | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ 40+ platforms |
| Voice input (en-PH) | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| OCR receipt scanning | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| PH banks / GCash / SSS | ❌ | ❌ | ❌ | ❌ | ⚠️ Partial | ❌ | ✅ Full |
| Paluwagan tracker | ❌ | ❌ | ❌ | ❌ | ✅ Full | ❌ | ❌ |
| 15th & 30th payday cycle | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ |
| Free (no subscription) | ✅ | ❌ $15/mo | ❌ $10/mo | ❌ $11/mo | ✅ | ⚠️ Limited | ✅ |
| Gamification | ❌ | ❌ | ❌ | ❌ | ✅ XP/levels | ❌ | ✅ 23 badges |
| Works without bank API | ✅ | ❌ | ❌ | ❌ | ✅ | ❌ | ✅ |

**SmartSpend leads:** Only app with 29 agentic AI actions + offline + Filipino-English + free + multi-modal input.
**Closest Filipino competitor:** BudgetPH — strong on paluwagan, 15th/30th cycle, and budget scoring, but no voice/OCR/barcode/agentic AI.

---

*SmartSpend v2.9.2 — Lucid Frame*
*Lorma Colleges, CCSE, BSIT 4th Year — 2026–2027, 1st Semester*
*Brix A. Directo · Cyrille John M. Rubis · Djaunathan Albert S. Madayag*
*Capstone Adviser: Johnny Verzola, MTS (reassignment pending)*
*Teacher-in-Charge: Janelli M. Mendez, DIT*
