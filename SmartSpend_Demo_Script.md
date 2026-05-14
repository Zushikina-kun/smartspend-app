# 🎤 SmartSpend Demo Script
**v2.6.0 | Lucid Frame | May 15, 2026**
**Time: ~9 min demo + 3-4 min Q&A**

---

## 📋 PRE-DEMO CHECKLIST
- [ ] APK installed (arm64, 45.4 MB)
- [ ] Logged in with Google
- [ ] WiFi ON
- [ ] Brightness MAX
- [ ] Screen timeout 5+ min
- [ ] AI messages available (check count in app bar)
- [ ] Wallet balances set

---

## 🟢 OPENING — 30 sec

📱 **SHOW:** Home screen

🗣️ **SAY:**
> "Smart Spend is an AI-assisted financial tracking app for Filipino users. Instead of filling out forms, you just talk to the AI — and it handles everything."

👆 **POINT TO:**
- Financial Health Score (top)
- Wallet balance card
- Daily limit bar
- 9-grid Quick Access

---

## 🤖 PART 1 — AI Input — 2 min

📱 **TAP:** AI button (bottom nav)

### Demo 1: Voice
🗣️ **SAY:** "First, voice input."

👆 **TAP** mic → speak: *"Spent 30 pesos for jeepney fare"*

🗣️ **SAY:**
> "Parsed it, categorized as Transportation, tagged as Need, logged it. Wallet went down by ₱30 automatically."

### Demo 2: Text
⌨️ **TYPE:** `Bought Jollibee chicken joy for 149`

🗣️ **SAY:**
> "Same with text. Knows Jollibee is Food, infers it's a Want, logs it."

### Demo 3: Wallet update
⌨️ **TYPE:** `My GCash is 500 pesos`

🗣️ **SAY:**
> "The AI also manages wallet balances. Updated instantly — no forms."

### Demo 4: Broader question
⌨️ **TYPE:** `How do I apply for SSS loan?`

🗣️ **SAY:**
> "Not just an expense recorder — it's a financial companion. Banking, SSS, PhilHealth, investments, prices."

---

## 📷 PART 2 — Scanner — 1 min

📱 **TAP:** Camera icon in AI screen

🗣️ **SAY:**
> "Smart Scanner — auto-detects barcodes in real time. For receipts, switch to Receipt mode."

👆 **SHOW:** Toggle receipt mode (amber guide)

🗣️ **SAY:**
> "If a receipt has multiple items, 'Import Items' button appears — routes to Import screen where AI extracts each item individually."

---

## 💵 PART 3 — Wallets & Settings — 1.5 min

📱 **TAP:** Wallet card on Home

🗣️ **SAY:**
> "Wallet system tracks actual cash — Cash on Hand, GCash, Maya, 30+ PH banks."

👆 **SHOW:** Wallets sheet (balances visible)

📱 **TAP:** Log Allowance button

🗣️ **SAY:**
> "This is for students with irregular allowances. Tap when you receive money — adds to Cash on Hand, logs as income. Long-press for custom amount."

📱 **GO TO:** Profile → App Settings

🗣️ **SAY:**
> "Users customize their experience. Auto-deduct wallets, mood, impulse pause, budget alerts."

👆 **TOGGLE** Balance Mode ON → show Profile card change

🗣️ **SAY:**
> "Normal mode: 'How much allowance is left?' Balance mode: 'How much cash do I actually have?' Same data, different perspective. No logic changes."

---

## 📊 PART 4 — Analytics — 1.5 min

📱 **TAP:** Analytics tab

🗣️ **SAY:**
> "Where all that data becomes insight."

👆 **SCROLL** slowly, point to:
1. **Nav chips** — "Goals, Debts, Budgets, Wallets, Calendar, Import"
2. **Pie chart** — "14 categories including Gaming, Personal Care, Travel, Pets"
3. **50/30/20** — "Needs vs Wants vs Savings against the rule"
4. **Market Insights** — "Live PHP exchange rates"
5. **Spending Personality** — "Labels your style from actual data"

🗣️ **SAY:**
> "Answers the question every Filipino asks: 'Where did my money go?'"

---

## 🏥 PART 5 — FHS — 1.5 min

📱 **TAP:** FHS card on Home

🗣️ **SAY:**
> "Financial Health Score — 0 to 100, four components, 25 points each."

👆 **SHOW** breakdown, explain each:

🗣️ **SAY:**
> "Savings Rate — saving 20%+ of income? Full 25.
> Overspend Control — how many days under daily budget? Full 25.
> Budget Adherence — all categories within limit? Full 25.
> Logging Consistency — recording every day? Full 25."

> "Income-relative — a student with ₱6,600 and a professional with ₱50,000 are both scored fairly."

> "Warning Decay: if you ignore a budget warning, score drops 5 pts/day for 3 days."

👆 **POINT TO:** "Ask AI to explain my score" link

---

## 🎮 PART 6 — Gamification — 1 min

📱 **SHOW:** Home screen → scroll to Daily Quests

🗣️ **SAY:**
> "Gamification layer — Daily Quests. 4 rotating challenges, progress bar, streak counter. Inspired by gacha game dailies."

👆 **SHOW:** Mood check-in widget

🗣️ **SAY:**
> "Daily mood check-in. Analytics shows mood-spending correlation."

👆 **SHOW:** Spending Personality card

🗣️ **SAY:**
> "Spending Personality — computed from data, no AI call. Plus 16 achievement badges, impulse pause, subscription auto-detection."

---

## 🏗️ PART 7 — Architecture — 1 min

🗣️ **SAY:**
> "Fully serverless — no backend. Flutter client, Firebase for auth and sync, Groq API for AI, SQLite for local storage. Zero hosting costs."

> "Context injection, not RAG — user's financial data injected directly into each AI prompt. Simpler, faster, no vector database needed."

> "Filipino-first — AI understands jeepney, GCash, ShopeePayLater, Jollibee, siomai, 13th month pay, 11.11 sales."

---

## 🎬 CLOSING — 30 sec

🗣️ **SAY:**
> "Smart Spend demonstrates that an AI-powered financial assistant can be built entirely on free-tier services — no paid cloud, no backend — and still deliver personalized financial guidance."

> "The goal: make financial literacy accessible to every Filipino. You don't need to know what a budget is — just tell it what you spent."

---

## 🙋 Q&A QUICK ANSWERS

| Question | One-liner |
|----------|-----------|
| "Why not bank API?" | PH has no open banking APIs. We built manual import instead. |
| "AI mistakes?" | Human-in-the-loop + confidence score + shake-to-undo 60 sec. |
| "Data privacy?" | No PII to API. Only expense text + anonymized summary. |
| "FHS from literature?" | UNSGSA framework. 4 components × 25 pts. Income-relative. |
| "vs GCash analytics?" | GCash shows what you spent. We tell you what it means + what to do. |
| "Backend?" | No. Fully serverless. Zero hosting costs. |
| "What's next?" | Cash-on-hand mode, wallet transfers, backend proxy, Play Store. |
| "Normal vs Balance Mode?" | Normal = allowance left. Balance = actual cash. Same data, display only. |
| "Context injection vs RAG?" | Small structured data fits in one prompt. RAG is overkill. |

---

## 📦 BONUS — If Panel Asks (show if needed)

| Feature | Where to find it |
|---------|-----------------|
| Payment Plans | Hub → Debts → Plans tab |
| Bill Calendar | Home 9-grid → Bill Calendar |
| Transaction Tags | Add Expense → Tags field |
| Achievements | Home 9-grid → Achievements |
| Bank Import | Hub → Import from Bank |
| Shake to Undo | Shake phone within 60 sec |
| Recurring | Hub → Recurring Transactions |
| Debts | Hub → Debts & Lending |
| Custom Categories | Profile → Manage Categories |
| Auto-Rules | Profile → Auto-Categorization Rules |
| Demo Mode | Login screen → Skip button |

---

## 🔄 FLOW SUMMARY
```
Home (score + wallet + limit + 9-grid)
  → AI (voice + text + wallet + question)
  → Scanner (receipt → Import Items)
  → Wallets + Settings (balance mode)
  → Analytics (pie + 50/30/20 + market + personality)
  → FHS (breakdown + decay + explain)
  → Gamification (quests + mood + badges)
  → Architecture (serverless + context injection + Filipino)
  → Closing
```

---

*SmartSpend v2.6.0 — Lucid Frame — Lorma Colleges CCSE BSIT 2025–2026*
