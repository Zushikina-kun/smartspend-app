# Smart Spend — App Demo Script
**Version:** 2.5.0 | **Group:** Lucid Frame | **Presenter:** Brix A. Directo
**Estimated demo time:** 8–12 minutes

---

## BEFORE YOU START

**Setup checklist:**
- [ ] Install `app-arm64-v8a-release.apk` on Poco X6 Pro
- [ ] Log in with your account (not demo mode — use real data)
- [ ] Make sure you have at least a few expenses logged this month
- [ ] Have WiFi on (for AI and exchange rates)
- [ ] Brightness at max
- [ ] Screen timeout set to 5+ minutes

**Key talking points to weave in naturally:**
- "AI is the primary input method — not forms"
- "Context injection, not RAG — works offline-capable"
- "Designed specifically for Filipino users"
- "Agentic AI — it doesn't just answer, it acts"

---

## OPENING (30 seconds)

> "Smart Spend is an AI-assisted financial tracking and advisory app for Filipino users. The core idea is simple: instead of filling out forms, you just talk to the AI — and it handles everything else."

**Show:** Home screen with your real data visible.

> "This is the home screen. You can see your spending this month, upcoming bills, your Financial Health Score, and quick access to all major features."

---

## PART 1 — AI as the Primary Input (2 minutes)

**Tap the AI button (bottom nav bar)**

> "The AI screen is the heart of the app. You can log expenses three ways."

**Demo 1 — Voice input:**
> "First, voice. I'll just say what I spent."

Tap the mic button, say: *"Spent 30 pesos for jeepney fare"*

> "The AI parsed that, categorized it as Transportation, tagged it as a Need, and logged it — no form, no tapping through dropdowns."

**Demo 2 — Text input:**
Type: *"Bought Jollibee chicken joy for 149"*

> "Same thing with text. It knows Jollibee is Food, infers it's a Want since it's a fast food treat, and logs it."

**Demo 3 — Broader AI question:**
Type: *"How do I apply for SSS loan?"*

> "But the AI isn't just an expense recorder. It's a financial companion. It can answer questions about Philippine banking, government benefits, investments — anything money-related."

**Point out:** The AI response is warm and conversational, not robotic.

---

## PART 2 — Smart Scanner (1.5 minutes)

**Tap the camera icon in the AI screen**

> "For receipts and barcodes, we have the Smart Scanner."

**Show the live viewfinder briefly.**

> "It auto-detects barcodes in real time. For receipts, you switch to Receipt mode — the amber guide — and tap the shutter. ML Kit extracts the text, you review it, and send it to the AI."

**If you have a receipt handy:** scan it and show the review screen.

> "We also added a bank import feature. If you have your GCash transaction history, you paste the text here and the AI parses all your transactions at once — with their real dates preserved."

---

## PART 3 — Analytics (2 minutes)

**Tap Analytics tab**

> "The Analytics screen is where all that data becomes insight."

**Scroll slowly, pointing out:**

1. **Navigation chips** — "Quick links to Goals, Debts, Budgets, Import"
2. **Pie chart** — "Spending by category. Tap any slice to drill down into those transactions."
3. **50/30/20 tracker** — "This always uses this month's data. It compares your Needs, Wants, and Savings against the 50/30/20 rule."
4. **Health Score chart** — "30-day trend of your Financial Health Score."
5. **Market Insights card** — "Live PHP exchange rates — USD, EUR, GBP. Tap to expand for financial literacy tips."

> "The analytics are designed to answer the question every Filipino asks at the end of the month: 'Where did my money go?'"

---

## PART 4 — Financial Health Score (1 minute)

**Go back to Home, tap the FHS card**

> "The Financial Health Score is a 0–100 score based on four components — each worth 25 points."

**Show the breakdown dialog:**

> "Savings Rate — are you saving at least 20% of income? Overspend Control — how many days did you stay within your daily budget? Budget Adherence — are your category budgets on track? And Logging Consistency — are you recording regularly?"

> "This formula is based on our capstone paper's specification. It's income-relative — a student with ₱6,600 allowance and a professional with ₱50,000 salary are both measured fairly against their own income."

**Point to the "Ask AI to explain my score" link:**
> "And if you want a plain-language explanation, you just tap here and ask the AI."

---

## PART 5 — Behavioral Features (1 minute)

**Show Home screen, scroll to mood check-in**

> "We also built a behavioral layer. The daily mood check-in tracks how you feel each day."

**Show the Spending Personality card:**
> "Based on your actual spending data, the app labels your spending style. Right now it says I'm a [read the label]. Each personality comes with a specific tip."

**Mention briefly:**
> "There's also an impulse pause mechanic — if you log a large Want expense, the app asks 'Was this planned?' to encourage reflection before confirming. And the subscription auto-detection finds recurring patterns in your history and suggests adding them as tracked bills."

---

## PART 6 — Data & Sync (30 seconds)

> "All data is stored locally in SQLite — the app works fully offline. When you're online, it syncs to Firebase Firestore automatically. Backup and restore is available via the share sheet — no cloud account needed."

**Mention briefly:**
> "We use Groq's LLaMA 3.1 8B Instant model for the AI — it's fast, free-tier, and runs entirely through API calls. The app uses a context injection architecture instead of RAG — the user's financial data is injected directly into each prompt, which is more efficient for the small, structured data we're working with."

---

## PART 7 — Filipino Context (30 seconds)

> "Everything is designed for Filipino users specifically. The AI understands jeepney, tricycle, GCash, ShopeePayLater, Jollibee, siomai — all the local context. It knows about SSS, PhilHealth, Pag-IBIG. It's aware of the 13th month pay season, school enrollment months, and the 11.11 and 12.12 sales."

> "The demo mode even loads data modeled after a Lorma Colleges BSIT student — so the panel can try it without needing an account."

---

## CLOSING (30 seconds)

> "Smart Spend demonstrates that a mobile-first, AI-powered financial assistant can be built on a free-tier stack — no paid cloud services, no backend server — and still deliver real-time, personalized financial guidance."

> "The goal isn't to replace financial advisors. It's to make basic financial literacy and tracking accessible to every Filipino, regardless of their background. You don't need to know what a budget is to use it — you just need to tell it what you spent."

---

## PANEL Q&A — QUICK ANSWERS

**"Why not use a banking API to auto-import transactions?"**
> "Philippine banks don't have open banking APIs yet. We built a manual import feature instead — users paste their GCash or bank transaction history and the AI parses it. It's not automatic, but it works with any bank or e-wallet."

**"How do you handle the AI making mistakes?"**
> "Every AI-logged expense is flagged with an AI badge and a confidence score. Low-confidence entries get an orange dot. Users can edit or delete any entry. The AI also has a shake-to-undo feature — shake the phone within 60 seconds to reverse the last action."

**"What about data privacy?"**
> "All financial data stays on the device in SQLite. The only data that leaves the device is the AI prompt — which contains the user's financial summary, not raw personal data. The Groq API key is rate-limited to 60 messages per day as a mitigation."

**"Is the Financial Health Score formula from literature?"**
> "Yes — it's based on the 4-component weighted formula specified in our capstone paper. Each component maps to a measurable financial behavior: savings rate, overspend control, budget adherence, and logging consistency."

**"What's the difference between this and GCash's built-in analytics?"**
> "GCash shows you what you spent. Smart Spend tells you what it means — whether you're on track, where you're overspending, what your financial health score is, and what to do about it. It also covers all payment methods, not just GCash."

**"Can it predict future spending?"**
> "Yes — the Long-Range Forecast in Analytics projects 3, 6, and 12-month cumulative spending based on your current pace. There's also a monthly prediction card and a Spending Forecast on the home screen that warns which budget categories will be exceeded by month-end."

**"What's next for the app?"**
> "Post-capstone, we're planning a multi-wallet system to track GCash, Maya, and bank balances separately, a notification listener to auto-parse GCash payment notifications, and a backend proxy to properly secure the API key for production deployment."

---

## DEMO FLOW SUMMARY (for quick reference)

```
Home screen (overview) → AI screen (voice + text + broader question) →
Smart Scanner (brief) → Analytics (pie + 50/30/20 + market insights) →
FHS card (breakdown + explain link) → Spending Personality →
Behavioral features (mood + impulse) → Closing statement
```

**Total: ~8 minutes. Leave 4 minutes for Q&A.**

---

*Smart Spend v2.5.0 — Lucid Frame — Lorma Colleges CCSE BSIT 2025–2026*
