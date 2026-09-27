# SmartSpend — Pre-Finals Defense Demo Script
**Version:** 2.9.65 | **Date:** Tuesday, September 29, 2026
**Group:** Lucid Frame — Brix Directo · Cyrille Rubis · Djaunathan Madayag

---

## BEFORE YOU WALK IN

**Phone setup (night before):**
1. Install `SmartSpend-v2.9.65-arm64-v8a.apk` from GitHub releases
2. Open app → Settings → Quick Presets → **Lite Mode OFF**
3. Settings → AI MODEL → **Auto (Recommended)** selected
4. AI screen → ⋮ → **Reset Daily Limit**
5. Charge to 100%, **do not open the app again** until demo
6. Have WiFi ready — AI needs internet for the first message

---

## OPENING STATEMENT (30 seconds, memorize this)

> *"Good morning/afternoon. We are Lucid Frame — Brix, Cyrille, and Djaunathan.*
>
> *SmartSpend is an AI-assisted personal finance tracker for Android, designed specifically for everyday Filipinos. The problem we're solving is simple: most Filipinos know they should track their money, but they don't — because it's too tedious. SmartSpend removes that friction. You just talk to the app, and it handles the rest.*
>
> *Our app uses a free, multi-model AI system with 34 automatic actions — it can log expenses, set budgets, track debts, and give financial advice, all from a single chat message. It also gives you a Financial Health Score — a single number from 0 to 100 that tells you how well you're managing your money this month."*

---

## DEMO FLOW (10 minutes total)

### Step 1 — Cold Start Impression (30 seconds)
- Open the app (cold start — makes it feel snappy)
- Let the panel see the Home screen for 3 seconds
- Say: *"This is the main dashboard. The big number at the top is this month's spending. Below it is the Financial Health Score. Everything updates in real time as you log expenses."*

---

### Step 2 — AI Logging — The Core Feature (2 minutes)
This is the most impressive thing. Do it first.

- Tap the **AI chat button** (bottom nav bar)
- Type: **"I spent 60 for lunch and 30 for jeep"**
- Watch it log 2 expenses at once
- Say: *"I just logged 2 expenses in one sentence. The AI understood the items, amounts, categories, and dates — all without me filling any form. This is what we call an agentic action — 34 types in total, from logging expenses to setting budgets to computing savings."*

**If panel asks how it works:**
> *"The message goes to our AI engine — Gemini 3.5 Flash-Lite by default — which parses the natural language into structured data. The AI returns a JSON action like `{type: 'log_expense', item: 'lunch', amount: 60, category: 'Food'}` which our app then executes automatically. The user just types naturally in Filipino, English, or Taglish."*

---

### Step 3 — Financial Health Score (2 minutes)
- Go back to Home
- Tap the **FHS score card** (the circular progress or score number)
- Show the breakdown dialog
- Say: *"This is the Financial Health Score. It's a 4-component formula — let me explain each one briefly."*

**Script for FHS explanation:**

> *"The score has 4 equal components, 25 points each:*
>
> *1. **Savings Rate** — Are you saving at least 20% of your income? If yes, full 25 points. If you're saving 10%, you get about 12 points.*
>
> *2. **Overspend Control** — On how many days did your spending stay within your daily budget? If you never went over, 25 points. If you went over every day, 0 points.*
>
> *3. **Budget Adherence** — Of all the category budgets you've set, how many are still on track? If all 5 budgets are within limit, 25 points.*
>
> *4. **Logging Consistency** — How regularly are you logging? If you log every day this month, 25 points. If you only log half the days, you get about 12 points.*
>
> *Add them up and you get your score out of 100. Anything above 80 is excellent, 60-79 is good, below 60 needs attention."*

---

### Step 4 — Smart Import — The Technical Showcase (2 minutes)
This shows technical depth.

- Tap **Log Expense** button on home
- Tap **Batch Screenshots** (or Smart Import)
- Show the import sheet
- Say: *"Beyond typing, we support 7 input methods. The most unique is batch screenshot import — you can import receipts from 40+ platforms: Shopee, Lazada, GCash, Steam, even Jollibee. The app uses OCR and ML Kit to read the text, then AI structures it into expense records."*

**If you have a Shopee screenshot ready:** show the actual import working.

---

### Step 5 — Analytics (1 minute)
- Tap **Analytics** tab
- Show the pie chart and 50/30/20 tracker
- Say: *"Analytics gives you a breakdown of where your money goes — by category, by want vs need, and by the 50/30/20 rule. You can also see your Debt-to-Income ratio and emergency fund calculator here."*

---

### Step 6 — Safe-to-Spend & Wallet (1 minute)
- Go back to Home, scroll to the **Safe to Spend** card
- Say: *"This is our competitive differentiator vs BudgetPH, our closest Filipino competitor. It tells you exactly how much you can safely spend before your next paycheck, after reserving upcoming bills, savings goal contributions, and overdue debts. One number, no guesswork."*

---

### Step 7 — Settings / User Control (30 seconds)
- Go to Settings → Quick Presets → toggle **Lite Mode ON** briefly, then back OFF
- Say: *"For new users who might feel overwhelmed, one tap enables Lite Mode — hides all 14 optional sections and shows only the essentials. As they get comfortable, they can turn features back on individually."*

---

### Step 8 — Closing Statement (30 seconds)

> *"To summarize: SmartSpend is the only free Filipino-English AI finance app on Android that supports 34 automatic actions, batch screenshot import from 40+ platforms, a dual-mode Financial Health Score, and features designed for students and young professionals in the Philippine context — like allowance tracking, paluwagan, SSS contributions, and payday cycle awareness.*
>
> *We built this using Flutter, Firebase, SQLite, and a 8-provider AI fallback chain so the app works even when individual providers hit their daily limits. Thank you."*

---

## WHEN THINGS GO WRONG

**AI doesn't respond:**
> *"The AI requires internet. Let me show you the manual entry instead — it works 100% offline."*
→ Tap Log Expense → Manual Form → fill it out

**App crashes or freezes:**
> *"Let me restart — the cold start is actually a better demo anyway."*
→ Force close, reopen

**Panel asks something you don't know:**
> *"That's a great question — I'll need to check the exact implementation detail, but the general approach is..."*
→ Never say "I don't know" alone. Always bridge to what you DO know.

---

## ROLE SPLIT (suggestion)

| Who | Does what |
|-----|-----------|
| **Brix** | Drives the phone demo, explains technical implementation, AI/FHS questions |
| **Cyrille** | Explains the research background, problem statement, competitor comparison |
| **Djaunathan** | Handles methodology questions, testing, SUS survey plan, project management |

---
