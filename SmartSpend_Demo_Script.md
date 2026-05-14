# Smart Spend — App Demo Script
**Version:** 2.6.0 | **Group:** Lucid Frame | **Presenter:** Brix A. Directo
**Estimated demo time:** 8–12 minutes

---

## BEFORE YOU START

**Setup checklist:**
- [ ] Install `app-arm64-v8a-release.apk` on Poco X6 Pro
- [ ] Log in with your Google account (not demo mode — use real data)
- [ ] Make sure you have expenses logged this month + wallet balances set
- [ ] Have WiFi on (for AI and exchange rates)
- [ ] Brightness at max, screen timeout 5+ minutes

**Key talking points to weave in naturally:**
- "AI is the primary input method — not forms"
- "Context injection, not RAG — no backend server needed"
- "Designed specifically for Filipino users"
- "Agentic AI — it doesn't just answer, it acts on your data"
- "Serverless architecture — zero hosting costs"

---

## OPENING (30 seconds)

> "Smart Spend is an AI-assisted financial tracking and advisory app for Filipino users. Instead of filling out forms, you just talk to the AI — and it handles everything."

**Show:** Home screen — point out the key elements visible:
- Financial Health Score (top)
- Wallet balance card (shows Cash on Hand + GCash totals)
- Daily spending limit progress bar
- Quick Access 9-grid (Analytics, Calendar, Goals, Debts, Wallets, Budgets, Import, Recurring, Achievements)

> "The home screen gives you everything at a glance — your score, your cash, today's spending, and shortcuts to every feature."

---

## PART 1 — AI as the Primary Input (2 minutes)

**Tap the AI button (bottom nav bar)**

> "The AI screen is the heart of the app. You can log expenses three ways."

**Demo 1 — Voice input:**
Tap the mic button, say: *"Spent 30 pesos for jeepney fare"*

> "The AI parsed that, categorized it as Transportation, tagged it as a Need, and logged it. Notice the wallet card — Cash on Hand just went down by ₱30 automatically."

**Demo 2 — Text input:**
Type: *"Bought Jollibee chicken joy for 149"*

> "Same thing with text. It knows Jollibee is Food, infers it's a Want, and logs it. The wallet deducts again."

**Demo 3 — Wallet update:**
Type: *"My GCash is 500 pesos"*

> "The AI also manages your wallet balances. I just told it my GCash balance and it updated instantly — no forms needed."

**Demo 4 — Broader question:**
Type: *"How do I apply for SSS loan?"*

> "The AI isn't just an expense recorder. It's a financial companion — it answers questions about Philippine banking, SSS, PhilHealth, investments, prices."

---

## PART 2 — Smart Scanner (1 minute)

**Tap the camera icon in the AI screen**

> "For receipts and barcodes, we have the Smart Scanner."

**Show the live viewfinder briefly, toggle Receipt mode.**

> "It auto-detects barcodes in real time. For receipts, switch to Receipt mode and tap the shutter."

**If you have a receipt:** scan it → show the "Import Items" button.

> "If the receipt has multiple items, the app detects that and shows 'Import Items'. It routes to the Import screen where the AI extracts each item individually — with categories and Want/Need tags — and you review before importing."

---

## PART 3 — Wallets & Settings (1.5 minutes)

**Tap the Wallet card on Home screen (or go to Profile → tap Net Worth card)**

> "The Wallet system tracks your actual cash across all accounts."

**Show the Wallets sheet:**
> "Cash on Hand, GCash, Maya, BDO, BPI — 30+ Philippine banks and e-wallets. Tap any wallet to update its balance. Or just tell the AI — 'my GCash is 500'."

**Point to the Log Allowance button:**
> "This blue button is for students with irregular allowances. Tap it when you receive your allowance — it adds to Cash on Hand and logs as income. Long-press for a custom amount if you got 2-3 days' worth at once. It doesn't change your monthly income setting — just your actual cash."

**Go to Profile → App Settings:**
> "Users can customize their experience with these toggles."

**Show each toggle briefly:**
> "Auto-deduct wallets — when you log an expense, the matching wallet goes down automatically. Mood check-in — show or hide the daily mood prompt. Impulse pause — adds a confirmation step for large Want purchases. Budget alerts — notifications at 80% and 100%."

**Toggle Balance Mode ON, show the Profile card change:**
> "And here's Balance Mode. Let me show the difference."

**Explain the two modes:**
> "Normal mode shows 'Remaining Balance' — that's your monthly income minus what you've spent. It answers: 'How much of my allowance is left?'"

> "Balance Mode shows 'Total Cash Available' — that's the sum of all your wallets. It answers: 'How much money do I actually have right now?'"

> "Normal mode is better for budgeting against income. Balance mode is better for students who get irregular allowances or freelancers who want to track actual cash on hand."

> "Both modes use the same data — same expenses, same FHS score, same budgets. The only difference is what number you see on the Profile card. No logic changes."

---

## PART 4 — Analytics (1.5 minutes)

**Tap Analytics tab**

> "Analytics is where all that data becomes insight."

**Scroll slowly, pointing out:**
1. **Navigation chips** — "Quick links to Goals, Debts, Budgets, Wallets, Calendar, Import"
2. **Pie chart** — "Spending by category — 14 categories including Gaming, Personal Care, Travel, Pets"
3. **50/30/20 tracker** — "Compares your Needs, Wants, and Savings against the 50/30/20 rule"
4. **Market Insights** — "Live PHP exchange rates with a note about remittance center rate differences"
5. **Spending Personality** — "Labels your spending style based on actual data — no AI call needed"

> "The analytics answer: 'Where did my money go?' — the question every Filipino asks at month-end."

---

## PART 5 — Financial Health Score (1.5 minutes)

**Go back to Home, tap the FHS card**

> "The Financial Health Score is our core metric — 0 to 100, calculated from four equal components."

**Show the breakdown dialog, explain each:**

> "Component 1: Savings Rate — 25 points. Are you saving at least 20% of your income? If your income is ₱6,600 and you spent ₱4,000, you saved 39% — full 25 points."

> "Component 2: Overspend Control — 25 points. How many days did you stay within your daily budget? If you set ₱250/day and exceeded it on 2 of 10 days, you get about 20 points."

> "Component 3: Budget Adherence — 25 points. What percentage of your category budgets are on track? All 8 budgets within limit = full 25."

> "Component 4: Logging Consistency — 25 points. Are you recording expenses regularly? Logged 8 of 10 days = 20 points."

> "The formula is income-relative. A student with ₱6,600 allowance and a professional with ₱50,000 salary are both measured fairly against their own income — not a fixed standard."

> "There's also a Warning Decay system — if a budget is exceeded and you keep spending in that category, the score drops 5 points per day for up to 3 days. This incentivizes corrective action."

**Point to "Ask AI to explain my score":**
> "And if the panel wants a plain-language explanation, tap here — the AI explains exactly why the score is what it is and what to improve."

---

## PART 6 — Behavioral Features (1 minute)

**Show Home screen, scroll to Daily Quests card:**
> "We built a gamification layer inspired by gacha games. These are Daily Quests — 4 rotating challenges that change each day."

**Point out the progress bar and streak:**
> "There's a progress bar showing how many you've completed, and a streak counter. Today I've done 2 of 4. My streak is [X] days — that means I've logged expenses every day for [X] days straight."

> "The quests vary — log an expense, stay under daily budget, avoid Want spending, log 3+ items. They rotate so it doesn't get repetitive."

**Show the mood check-in:**
> "There's also a daily mood check-in. In Analytics, there's a Mood & Spending Correlation card that shows if you spend more on bad days."

**Show Spending Personality card:**
> "Based on your data, it labels your style — Foodie Spender, Consistent Saver, etc."

**Mention briefly:**
> "Plus impulse pause for large Want purchases, subscription auto-detection, and 16 achievement badges in Hub → Achievements."

---

## PART 7 — Architecture & Filipino Context (1 minute)

> "The architecture is fully serverless — no backend. Flutter on the client, Firebase for auth and sync, Groq API for AI, SQLite for local storage. Zero hosting costs."

> "We use context injection instead of RAG — the user's financial data is injected directly into each AI prompt. More efficient for small, structured data."

> "Everything is Filipino-first. The AI understands jeepney, tricycle, GCash, ShopeePayLater, Jollibee, siomai. It knows about 13th month pay, school enrollment season, 11.11 sales. The categories include Filipino-specific ones. Payment methods include GCash, Maya, GrabPay, ShopeePay."

---

## CLOSING (30 seconds)

> "Smart Spend demonstrates that a mobile-first, AI-powered financial assistant can be built entirely on free-tier services — no paid cloud, no backend server — and still deliver real-time, personalized financial guidance."

> "The goal is to make financial literacy accessible to every Filipino. You don't need to know what a budget is — you just tell it what you spent."

---

## PANEL Q&A — QUICK ANSWERS

**"Why not use a banking API to auto-import?"**
> "Philippine banks don't have open banking APIs. We built manual import instead — paste GCash/bank history, AI parses it. Works with any bank."

**"How do you handle AI mistakes?"**
> "Every AI-logged expense has a confidence score. Low-confidence gets an orange dot. Users can edit or delete. There's also shake-to-undo within 60 seconds. Plus a fallback parser — if the AI says 'Logged' but forgets the ACTION line, the app auto-generates it."

**"What about data privacy?"**
> "All data stays on-device in SQLite. Only the financial summary goes to Groq's API — not raw personal data. The API key is rate-limited to 60 messages/day. Firebase App Check is integrated for Firestore protection."

**"Is the FHS formula from literature?"**
> "Yes — 4-component weighted formula from our capstone paper. Each maps to a measurable behavior: savings rate, overspend control, budget adherence, logging consistency."

**"What's the difference from GCash analytics?"**
> "GCash shows what you spent. Smart Spend tells you what it means — your health score, where you're overspending, what to do about it. It covers all payment methods, not just GCash. And the AI gives personalized advice."

**"Do you have a backend?"**
> "No — fully serverless. Firebase handles auth and sync, Groq handles AI, everything else runs on-device. Zero hosting costs, zero server maintenance."

**"What's next?"**
> "Post-capstone: full cash-on-hand tracking mode with income auto-calculation from wallet changes, transfer between wallets, notification listener for auto-parsing GCash payments, and a backend proxy to secure the API key for Play Store deployment."

**"What's the difference between Normal Mode and Balance Mode?"**
> "Normal mode tracks income minus expenses — 'how much of my allowance is left.' Balance mode tracks wallet totals — 'how much cash do I actually have.' Normal is better for fixed-income budgeting. Balance is better for irregular income or students who just want to know their actual cash. Both use the same underlying data."

---

## DEMO FLOW SUMMARY

```
Home (score + wallet + daily limit + 9-grid) →
AI (voice + text + wallet update + broader question) →
Scanner (receipt → Import Items) →
Wallets + Settings (balance mode demo + comparison) →
Analytics (pie + 50/30/20 + market + personality) →
FHS (breakdown + explain) →
Behavioral (mood + impulse + badges) →
Architecture + Filipino context →
Closing
```

**Total: ~9 minutes. Leave 3–4 minutes for Q&A.**

**If panel wants to try it themselves:**
> "You can try Demo Mode — just tap 'Skip' on the login screen. It loads pre-populated data modeled after a BSIT student at Lorma Colleges. All features work — wallets, AI, analytics, everything. No account needed."

---

## BONUS — Features Not in Main Demo (show if asked)

**Payment Plans (ShopeePayLater, HomeCredit):**
- Hub → Debts & Lending → "Plans" tab
- Shows: monthly payment, months paid/total, remaining balance, due day
- "Log Payment" button records expense + increments months paid
> "This tracks installment plans like ShopeePayLater or HomeCredit. It shows how much you've paid, what's remaining, and when the next payment is due."

**Bill Calendar:**
- Home 9-grid → Bill Calendar
- Shows all upcoming bills, debts, installments, and income on a monthly calendar
- Gray dots on days with logged expenses, colored dots for events
> "Every financial event on one calendar — bills, debts, goals, installments. Tap any day to see details."

**Transaction Tags:**
- Add Expense → Tags field (type #capstone, #shared, etc.)
- Transactions screen → filter chips by tag
> "You can tag expenses with custom labels like #capstone or #shared, then filter by tag in the Transactions screen."

**Achievements (16 badges):**
- Home 9-grid → Achievements
- Shows earned (colored) and locked (silhouette) badges
- Examples: First Step, 3-Day Streak, Week Warrior, Saver, Budget Boss, AI Power User, Impulse Control
> "16 earnable badges — some are easy like logging your first expense, others take consistency like a 30-day streak."

**Bank/GCash Import:**
- Hub → Import from Bank / GCash
- Paste transaction history text → Parse with AI → review table → bulk import
- Supports: GCash, Maya, BPI, BDO, Metrobank, Landbank, RCBC, GoTyme, Tonik, and more
> "Paste your GCash or bank transaction history — the AI parses all rows at once with real dates preserved. You review before importing."

**Shake to Undo:**
- After any AI action, shake the phone within 60 seconds
- Shows confirmation sheet → tap Undo → reverses the action
> "Made a mistake? Shake your phone within 60 seconds to undo the last AI action."

**Recurring Transactions:**
- Hub → Recurring Transactions
- Bills, subscriptions, income — with frequency and next due date
- "Log All Due" button logs all overdue items at once
> "Track monthly bills and subscriptions. The app alerts you when they're due and can log them all with one tap."

**Debts & Lending:**
- Hub → Debts & Lending
- Two types: money you owe, money others owe you
- Track partial payments, due dates
> "Track who owes you and who you owe. Log partial payments as you go."

**Custom Categories + Auto-Rules:**
- Profile → Manage Categories (add custom ones)
- Profile → Auto-Categorization Rules (keyword → category)
> "You can add custom categories and set rules like 'cobra' → Food so the AI always categorizes it correctly."

---

*Smart Spend v2.6.0 — Lucid Frame — Lorma Colleges CCSE BSIT 2025–2026*
