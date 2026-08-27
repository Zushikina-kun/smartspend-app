# SmartSpend — Application Pipeline
## How the App Works, Start to Finish
**Version:** 2.9.4 | **Group:** Lucid Frame | **AY:** 2026–2027, 1st Semester
**For:** Anyone — adviser, panel, new team member, or user

---

## THE BIG PICTURE IN ONE SENTENCE

> A user tells the app what they spent → AI understands it → stores it → analyzes it → gives a financial health score and advice.

---

## FULL PIPELINE — STEP BY STEP

```
┌─────────────────────────────────────────────────────────────────────────┐
│  STEP 1 — USER OPENS THE APP                                            │
│                                                                         │
│  First time?          Returning user?          Just browsing?           │
│  ↓                    ↓                         ↓                       │
│  Register /           Login                     Demo Mode               │
│  Google Sign-In       (Google or email)         (no account needed)     │
│                       ↓                                                 │
│              App Lock screen appears                                    │
│              (PIN or biometric — once on cold start only)               │
└──────────────────────────────┬──────────────────────────────────────────┘
                               ↓
┌─────────────────────────────────────────────────────────────────────────┐
│  STEP 2 — USER ENTERS AN EXPENSE                                        │
│                                                                         │
│  User chooses any of 6 ways to input:                                   │
│                                                                         │
│  🎙️ VOICE          ✏️ TEXT            📷 CAMERA           📸 SCREENSHOTS │
│  Speaks naturally  Types naturally   Camera button       Pick from      │
│  "Spent 85 for     "lunch 85 pesos"  opens 4-mode sheet  gallery       │
│  jeepney"                            ↓                                  │
│                                   ┌──────────────────────────────┐      │
│                                   │  SMART IMPORT (4 modes)      │      │
│                                   │  1. Live Camera              │      │
│                                   │     → barcode/QR live detect │      │
│                                   │     → receipt OCR shutter    │      │
│                                   │  2. Single Photo             │      │
│                                   │     → auto-detects type      │      │
│                                   │     → barcode / screenshot   │      │
│                                   │     → receipt / bank history │      │
│                                   │  3. Batch Screenshots        │      │
│                                   │     → up to 10 images        │      │
│                                   │     → 40+ platforms detected │      │
│                                   │     → Shopee, Steam, GCash,  │      │
│                                   │       Lazada, BPI, etc.      │      │
│                                   │  4. Paste Text               │      │
│                                   │     → GCash history, BPI CSV │      │
│                                   │     → any bank export text   │      │
│                                   └──────────────────────────────┘      │
│                                                                         │
│  Also: 📝 Manual Form (no AI needed — works fully offline)              │
└──────────────────────────────┬──────────────────────────────────────────┘
                               ↓
┌─────────────────────────────────────────────────────────────────────────┐
│  STEP 3 — AI PROCESSES THE INPUT                                        │
│                                                                         │
│  Before every AI call, the app builds a CONTEXT PACKAGE from SQLite:   │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  CONTEXT INJECTED INTO EVERY AI MESSAGE                         │   │
│  │  • Last 10 expenses (detailed) + older ones (summarized)        │   │
│  │  • All budgets and their current status                          │   │
│  │  • Monthly income and total spent this month                    │   │
│  │  • Savings goals and progress                                   │   │
│  │  • Debts and payment plans                                      │   │
│  │  • Wallet balances (GCash, Maya, banks)                         │   │
│  │  • Current Financial Health Score                               │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                               ↓                                        │
│  This context + the user's message is sent to the LLM:                 │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  MULTI-MODEL LLM ROUTING                                         │   │
│  │                                                                  │   │
│  │  1st → Gemini 3.1 Flash-Lite   (1,000 free req/day)            │   │
│  │  2nd → Gemini 3.5 Flash        (if 1st hits limit)             │   │
│  │  3rd → Groq LLaMA 3.3 70B     (if 2nd hits limit)             │   │
│  │  4th → Groq LLaMA 3.1 8B      (if 3rd hits limit)             │   │
│  │  5th → Cerebras LLaMA 3.1     (last resort, fastest)          │   │
│  │                                                                  │   │
│  │  If ALL hit limits → manual entry still works offline           │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                               ↓                                        │
│  AI returns a structured JSON response:                                 │
│                                                                         │
│  Example: { "type": "log_expense", "amount": 85,                       │
│             "category": "Transportation", "merchant": "Jeepney",       │
│             "want_need": "Need", "confidence": 0.97 }                   │
│                                                                         │
│  The AI recognizes 29 action types — not just logging:                  │
│                                                                         │
│  📝 Expenses    → log, update, delete, delete by date                   │
│  💰 Income      → set income, log income entry                          │
│  💳 Wallets     → set balance, transfer between wallets                 │
│  📊 Budgets     → set or update category budget limits                  │
│  🎯 Goals       → add, update, delete savings goals                     │
│  💸 Debts       → add debt, record payment, update due date             │
│  🔁 Recurring   → add or delete recurring bills/subscriptions           │
│  📅 Plans       → add installment plan (ShopeePayLater, GLoan, etc.)    │
│  📈 Analysis    → salary split, goal check, debt strategy, what-if,    │
│                   FHS breakdown, subscription detection, and more       │
│  👤 Account     → change account type                                   │
└──────────────────────────────┬──────────────────────────────────────────┘
                               ↓
┌─────────────────────────────────────────────────────────────────────────┐
│  STEP 4 — DATA IS SAVED                                                 │
│                                                                         │
│  App reads the AI's JSON → executes the action → saves to SQLite        │
│                                                                         │
│  ┌──────────────────────────┐     ┌────────────────────────────────┐   │
│  │   SQLite (ON DEVICE)     │     │   Firebase Firestore (CLOUD)   │   │
│  │   Primary storage        │────▶│   Automatic backup             │   │
│  │   Works offline          │     │   Sync on save                 │   │
│  │   v11 schema, 20 tables  │     │   Restores on new device       │   │
│  │   Instant — no network   │     │   UID-scoped security rules    │   │
│  └──────────────────────────┘     └────────────────────────────────┘   │
│                                                                         │
│  User sees a green confirmation:                                        │
│  ✅ "Logged: Transportation — Jeepney ₱85.00"                           │
│                                                                         │
│  If AI confidence is low (<0.7): orange dot shown on expense tile       │
│  Shake phone within 60 seconds: undoes the last AI action               │
└──────────────────────────────┬──────────────────────────────────────────┘
                               ↓
┌─────────────────────────────────────────────────────────────────────────┐
│  STEP 5 — ANALYTICS ENGINE UPDATES                                      │
│                                                                         │
│  After every save, the app recalculates everything:                     │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  FINANCIAL HEALTH SCORE (FHS) — 0 to 100                        │   │
│  │                                                                  │   │
│  │  FULL MODE (income tracking ON):                                │   │
│  │  ┌────────────────────────────┬────────────┐                   │   │
│  │  │ Component                  │ Max Points │                   │   │
│  │  ├────────────────────────────┼────────────┤                   │   │
│  │  │ Savings Rate               │    25      │                   │   │
│  │  │ (saving ≥20% of income?)   │            │                   │   │
│  │  ├────────────────────────────┼────────────┤                   │   │
│  │  │ Overspend Control          │    25      │                   │   │
│  │  │ (days within daily budget) │            │                   │   │
│  │  ├────────────────────────────┼────────────┤                   │   │
│  │  │ Budget Adherence           │    25      │                   │   │
│  │  │ (categories on track?)     │            │                   │   │
│  │  ├────────────────────────────┼────────────┤                   │   │
│  │  │ Logging Consistency        │    25      │                   │   │
│  │  │ (logging every day?)       │            │                   │   │
│  │  └────────────────────────────┴────────────┘                   │   │
│  │                                                                  │   │
│  │  LIGHTWEIGHT MODE (income tracking OFF):                        │   │
│  │  Same structure but components are: Spending Restraint,         │   │
│  │  Logging Consistency, Category Balance, Habit Streak            │   │
│  │                                                                  │   │
│  │  ADJUSTMENTS on top of both modes:                              │   │
│  │  − Warning Decay: −5 pts/day if budget warning ignored (max−15) │   │
│  │  + Gap Bonus: +2 pts/day for confirmed no-spend days (max +10)  │   │
│  │  − Gap Penalty: −3 pts/day for unlogged spending (max −15)      │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  Also updates:                                                          │
│  📊 Pie chart, bar chart, 50/30/20 tracker                              │
│  📈 FHS trend line (30 days), period comparison                         │
│  📅 Day-of-week heatmap, long-range forecast (3/6/12 months)            │
│  💸 Spending personality card, DTI ratio, emergency fund calc           │
│  🔔 Budget alerts (80% warning, 100% exceeded)                          │
└──────────────────────────────┬──────────────────────────────────────────┘
                               ↓
┌─────────────────────────────────────────────────────────────────────────┐
│  STEP 6 — USER GETS FEEDBACK                                            │
│                                                                         │
│  The app surfaces insights in multiple ways:                            │
│                                                                         │
│  🏠 HOME SCREEN                                                          │
│     • FHS score card with color badge (👑 Excellent → 📉 Needs Work)   │
│     • Monthly spending summary + income progress bar                    │
│     • Wallet balances (Cash, GCash, Maya, banks)                        │
│     • Spending limit progress bar                                       │
│     • Upcoming bills chip row                                           │
│     • Daily quests + streak counter                                     │
│     • Quick access 9-grid (Goals, Debts, Budgets, etc.)                 │
│                                                                         │
│  🤖 AI CHAT (ongoing conversation)                                       │
│     • User can ask anything: "How much did I spend on food?"            │
│     • AI explains score: "Your FHS dropped because..."                  │
│     • General advice: "How do I apply for SSS loan?"                    │
│     • Filipino-English (Taglish): "Magkano na nagastos ko ngayong buwan?"│
│                                                                         │
│  🔔 SMART STARTUP ALERTS (shown once per day on app open)               │
│     • Overdue bills                                                     │
│     • Budget exceeded                                                   │
│     • Debt payment due soon                                             │
│     • FHS dropped 10+ points overnight                                  │
│     • Idle money (wallet unchanged 14+ days, >₱5,000)                  │
│     • Income vs spending anomaly                                        │
│                                                                         │
│  📊 ANALYTICS TAB                                                        │
│     • All charts, FHS breakdown, behavior analysis                      │
│     • "Ask AI to explain my score" link                                 │
│                                                                         │
│  🏆 GAMIFICATION                                                         │
│     • 23 achievement badges (Savings Starter, Wallet Wizard, etc.)     │
│     • 10 rotating daily quests with progress bar                       │
│     • Spending streaks                                                  │
│     • Impulse Pause — reflects before confirming large Want purchases   │
└──────────────────────────────┬──────────────────────────────────────────┘
                               ↓
┌─────────────────────────────────────────────────────────────────────────┐
│  STEP 7 — NEXT APP OPEN (STARTUP CHECKS)                                │
│                                                                         │
│  Every time the user opens the app, background checks run:              │
│                                                                         │
│  1. Logging Gap Check                                                   │
│     "Were there days since your last session with no expenses logged?"  │
│     User answers: "Yes, I spent" → −3 pts to FHS                       │
│                   "No, clean days" → +2 pts to FHS                     │
│     → Makes FHS reflect reality, not just silence                       │
│                                                                         │
│  2. Startup Alerts (see Step 6 — shown as modal cards)                  │
│                                                                         │
│  3. What's New screen (shown once after each app version update)        │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## TECHNOLOGY FLOW — HOW THE PIECES CONNECT

```
USER'S PHONE
│
├── Flutter App (UI + Logic)
│   ├── 36 screens
│   ├── 26 services
│   └── Event Bus (real-time refresh between screens)
│
├── SQLite Database (on-device, offline-first)
│   ├── 20 tables (expenses, budgets, goals, debts, wallets, etc.)
│   └── SQLite v11 schema
│
└── [when internet available]
    │
    ├── Firebase Firestore ──── auto-sync all user data
    ├── Firebase Auth ────────── login (email + Google OAuth)
    ├── Firebase Crashlytics ─── automatic crash reports
    ├── Firebase App Check ───── verifies only real signed APKs
    ├── Firebase Remote Config ── API key fetched at runtime (never in APK)
    │
    ├── Gemini API (Google) ─── primary AI, 1,000 free req/day
    ├── Groq API ──────────── fallback AI (LLaMA 3.3 70B / 3.1 8B)
    ├── Cerebras ──────────── last-resort AI fallback
    │
    ├── Google ML Kit ──────── OCR (receipt text extraction, on-device)
    ├── MobileScanner ──────── barcode/QR detection (on-device)
    ├── Open Food Facts API ─── barcode product lookup
    └── open.er-api.com ─────── live exchange rates (57 currencies)
```

---

## SECURITY PIPELINE

```
How the API key is protected:

  APK is installed on phone
        ↓
  App starts → requests API key from Firebase Remote Config
        ↓
  Firebase App Check validates: "Is this a real signed APK?"
        ↓  YES                        ↓  NO (modified/fake APK)
  Key is returned               Request is rejected
        ↓
  Key used for this session (never stored on device long-term)
        ↓
  Per-user rate limit: 60 AI messages/day enforced in-app
```

---

## DATA FLOW — WHAT HAPPENS TO A USER'S DATA

```
User logs expense
      ↓
Saved to SQLite (instant, on-device, works offline)
      ↓
[If internet available] → Auto-pushed to Firestore
      ↓
FHS recalculated → Charts updated → Alerts checked
      ↓
Next login on different device → Firestore data pulled down → merged into SQLite
```

**Privacy:** Only anonymized expense text + financial summary is sent to the AI — no names, no account numbers, no passwords.

---

## USER JOURNEY — A TYPICAL PARENT (35–55) USING SMARTSPEND

```
Monday morning
│
├── Opens app → App Lock (PIN, just once)
├── Startup alert: "Meralco bill due in 2 days — ₱1,850"
├── Logs weekend groceries: "SM grocery ₱2,300"
│     → AI logs: Food ₱2,300, Need
├── Checks home screen: FHS 74/100 (⭐ Good)
│     → "Budget adherence dropped — Food is at 87%"
└── Taps AI: "How much have I spent on food this month?"
      → "₱4,200 so far — ₱800 left in your Food budget"

Wednesday
├── Takes a photo of Puregold receipt (3 items)
│     → Smart Import detects receipt → routes to import screen
│     → AI extracts 3 items separately
│     → User reviews, taps Import
└── Completes daily quest: "Log 3 expenses today" ✅ +XP

Saturday
├── Opens batch screenshot import
│     → Picks 5 Shopee screenshots from gallery
│     → App detects Shopee → extracts 5 orders with amounts, dates
│     → User reviews, imports all 5 at once
└── FHS updates: Logging Consistency now 100% for the week
```

---

## USER JOURNEY — A YOUNG PROFESSIONAL (21–35)

```
Payday (15th of the month)
│
├── Types: "My GCash is 8,500"
│     → AI updates GCash wallet to ₱8,500
├── Types: "Plan my salary — 40K/month"
│     → AI runs salary split: ₱20K needs, ₱12K wants, ₱8K savings
│     → Sets budgets automatically
└── FHS resets for the new period

Daily commute
├── Says via voice: "Spent 34 pesos for jeepney"
│     → AI logs: Transportation ₱34, Need
├── App shows: "Daily limit 82% used (₱574 of ₱700)"
└── Impulse pause triggers when buying new game:
      "This is tagged as Want and costs ₱1,299.
       Your Food budget is at 91%. Still proceed?"

End of month
├── Opens Financial Health Certificate
│     → Shareable score card: FHS 81/100 🏆 Great
├── Asks AI: "What if I save ₱500 more per month?"
│     → "In 12 months you'd have ₱6,000 extra toward your laptop goal"
└── Achievement unlocked: 🏅 "Salary Splitter" — first time using plan_salary_split
```

---

## KEY NUMBERS (v2.9.2)

| What | How many |
|------|---------|
| AI agentic action types | 29 |
| App screens | 36 |
| Backend services | 26 |
| SQLite tables | 20 |
| LLM providers (auto-failover) | 5 |
| Achievement badges | 23 |
| Daily quests (rotating) | 10 |
| Expense categories | 14 built-in + unlimited custom |
| PH banks in database | 20 banks + 5 e-wallets |
| Screenshot platform types detected | 40+ |
| Currencies supported | 57 |
| Free tier AI limit | 60 messages/user/day |
| APK size (arm64-v8a) | 44.7 MB |

---

## WHAT MAKES SMARTSPEND DIFFERENT

| Traditional expense app | SmartSpend |
|------------------------|-----------|
| Fill out a form for every expense | Just say or type it naturally |
| Shows a list of transactions | Shows a Financial Health Score + explanation |
| No AI — passive recording only | 29 AI actions — actively manages your data |
| Only works with internet + bank API | Works 100% offline, no bank login needed |
| English only | Filipino-English (Taglish) understood natively |
| Manual receipt entry | OCR + batch screenshot import (40+ platforms) |
| Free OR useful — rarely both | Free, offline, AI-powered, Filipino-first |

---

*SmartSpend v2.9.2 — Lucid Frame*
*Lorma Colleges, CCSE, BSIT 4th Year — 2026–2027, 1st Semester*
*Brix A. Directo · Cyrille John M. Rubis · Djaunathan Albert S. Madayag*
*Teacher-in-Charge: Janelli M. Mendez, DIT | Capstone Adviser: Johnny Verzola, MTS (reassignment pending)*
