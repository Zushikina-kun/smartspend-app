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

## PART 3 — Wallets & Settings (1 minute)

**Tap the Wallet card on Home screen (or go to Profile → tap Net Worth card)**

> "The Wallet system tracks your actual cash across all accounts."

**Show the Wallets sheet:**
> "Cash on Hand, GCash, Maya, BDO, BPI — 30+ Philippine banks and e-wallets. Tap any wallet to update its balance. Or just tell the AI."

**Go to Profile → App Settings:**
> "Users can customize their experience. Auto-deduct wallets, mood check-in, impulse pause, budget alerts — all toggleable. There's also Balance Mode which shows your total cash instead of income-based remaining."

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

## PART 5 — Financial Health Score (1 minute)

**Go back to Home, tap the FHS card**

> "The Financial Health Score is 0–100, based on four components — each worth 25 points."

**Show the breakdown:**
> "Savings Rate, Overspend Control, Budget Adherence, and Logging Consistency. It's income-relative — a student with ₱6,600 and a professional with ₱50,000 are both measured fairly."

**Point to "Ask AI to explain my score":**
> "Tap here and the AI explains in plain language why your score is what it is."

---

## PART 6 — Behavioral Features (1 minute)

**Show Home screen, scroll to mood check-in:**
> "Daily mood check-in tracks how you feel. In Analytics, there's a Mood & Spending Correlation card that shows if you spend more on bad days."

**Show Spending Personality card:**
> "Based on your data, it labels your style — Foodie Spender, Consistent Saver, etc. Each comes with a tip."

**Mention briefly:**
> "There's also impulse pause — large Want expenses get a confirmation dialog. Subscription auto-detection finds recurring patterns. And 16 achievement badges for consistent tracking."

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
> "Post-capstone: full cash-on-hand tracking mode, transfer between wallets, notification listener for auto-parsing GCash payments, and a backend proxy to secure the API key for Play Store deployment."

---

## DEMO FLOW SUMMARY

```
Home (score + wallet + daily limit + 9-grid) →
AI (voice + text + wallet update + broader question) →
Scanner (receipt → Import Items) →
Wallets + Settings (balance mode) →
Analytics (pie + 50/30/20 + market + personality) →
FHS (breakdown + explain) →
Behavioral (mood + impulse + badges) →
Architecture + Filipino context →
Closing
```

**Total: ~8 minutes. Leave 4 minutes for Q&A.**

---

*Smart Spend v2.6.0 — Lucid Frame — Lorma Colleges CCSE BSIT 2025–2026*
