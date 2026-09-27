# SmartSpend — Panel Q&A Reviewer
**For:** Pre-Finals Defense, Tuesday September 29, 2026
**Purpose:** Practice answering tough panel questions confidently

---

## CATEGORY 1: "What is this app and why does it matter?"

**Q: What problem does SmartSpend solve?**
> Most Filipinos don't track their finances because it's tedious — you have to manually open an app, fill forms, pick categories, remember amounts. SmartSpend removes all that friction. You just talk to it naturally: "I spent 60 for lunch and 30 for jeep" and it logs both expenses automatically. For Filipino students and young professionals who already spend most of their time on their phones, this lowers the barrier to building a financial habit.

**Q: Who is your target user?**
> Two primary groups: (1) Filipino college students who receive irregular allowances and need to track spending without a salary-based system — our app handles this with the allowance cycle and student account type. (2) Young working professionals aged 21–35 who earn a salary but have never tracked their finances before. We designed for mobile-first, AI-assisted entry so it fits into their existing phone habits.

**Q: How is this different from existing apps like BudgetPH or PISO?**
> Three main differences:
> 1. **AI with 34 agentic actions** — BudgetPH and PISO have no AI at all. You log manually. We log via natural language, voice, OCR, and screenshots.
> 2. **Batch screenshot import** — You can import from 40+ platforms (Shopee, GCash, Steam, bank apps) without typing anything. Unique to SmartSpend.
> 3. **Financial Health Score** — We give you one 0–100 score that measures your financial behavior across 4 dimensions. Other apps just show you your balance and spending history.

---

## CATEGORY 2: "How does the Financial Health Score work?"

**Q: Explain the FHS formula simply.**
> The score has 4 equal parts, 25 points each, totaling 100:
>
> - **Savings Rate (25 pts):** Are you saving 20% of your income? Full points if yes, scales down proportionally below that. Formula: `25 × min(1, actual_savings_rate / 0.20)`
>
> - **Overspend Control (25 pts):** How many days did you stay within your daily budget? Formula: `25 × (days_within_budget / days_elapsed)`
>
> - **Budget Adherence (25 pts):** Of the categories you've budgeted, how many are still on track? Formula: `25 × (categories_on_track / total_budgeted_categories)`. If you haven't set any budgets, you get full 25 points — we don't penalize new users.
>
> - **Logging Consistency (25 pts):** How regularly are you logging expenses? Formula: `25 × (days_you_logged / days_elapsed_this_month)`
>
> The total is clamped between 0 and 100. A score above 80 is excellent.

**Q: What happens when someone doesn't have an income? Like a student?**
> We have two modes. In **Full Mode**, the FHS uses all 4 components including Savings Rate — which requires income data. In **Lightweight Mode** (which students can enable), we swap the income-dependent components with spending-habit-based ones: Spending Restraint, Logging Consistency, Category Balance, and Habit Streak. This way students get a meaningful score without needing to enter a salary.

**Q: Why 20% savings target specifically?**
> The 20% rule comes from the 50/30/20 budgeting framework — 50% needs, 30% wants, 20% savings. It's widely recognized in personal finance literature and cited in BSP financial literacy recommendations. We used it as the benchmark so users have a clear, researched goal rather than an arbitrary number.

**Q: How does the score handle gaps in logging? If I forget to log for 3 days?**
> We have a Logging Gap Detection system. When the app detects days where you didn't log but your wallet balance changed (suggesting you did spend), it asks: "Did you have transactions on those days?" If you confirm you did, it applies a small penalty to the Logging Consistency component. If you confirm it was a genuine no-spend day, it actually gives a small bonus. This makes the score more accurate and more honest than just ignoring missing days.

---

## CATEGORY 3: "How does the AI work?"

**Q: Is the AI safe? Does it access our financial data?**
> The AI receives only the text you type and a summarized context of your expenses — categories and amounts, no names or personal identifiers. We also redact mobile numbers before sending anything to the AI. The actual expense data is stored locally on the device in an SQLite database — it never leaves the phone except for the Firebase sync which is encrypted. We comply with RA 10173 (Data Privacy Act).

**Q: What happens when the AI is down or the internet is slow?**
> The app has an 8-provider fallback chain. If Gemini fails, it automatically switches to our Groq models, then to Cerebras. Each provider has a separate daily limit. The app tracks which provider it's currently on and persists that choice across restarts. If all 8 providers fail or hit their limits, all manual entry features still work 100% offline — you can still log, view, and analyze without internet.

**Q: How do you prevent the AI from making mistakes?**
> Three layers: (1) **Auto-categorization evidence threshold** — if an item has been logged 10 times as Food, the AI can't reclassify it as Others based on one uncertain response. (2) **Action allowlist** — import and OCR flows can only trigger expense-logging actions, not delete or modify account settings. (3) **Confidence score** — every AI-logged expense gets a confidence score 0–1. Entries below 70% show a "Review" badge so users know to double-check.

**Q: Who pays for the AI? It must cost money.**
> We use free tiers from multiple providers. Gemini 3.5 Flash-Lite (primary) is free via Google AI Studio. Groq and Cerebras provide free API access. We enforce a 150 messages/day limit per user across all providers, which costs us nothing for a research project. For production scaling, the architecture supports moving to Firebase Remote Config for key management — which we've already implemented.

---

## CATEGORY 4: "Technical implementation"

**Q: Why Flutter and not native Android or React Native?**
> Flutter gives us a single codebase that can target Android, iOS, and web. For our capstone scope (Android only), it also gave us access to ML Kit for OCR and barcode scanning — both first-party Google packages with excellent Flutter support. Dart is also faster to iterate in than Kotlin for UI work, which mattered given our 1-semester timeline.

**Q: How does the batch screenshot import work?**
> The user selects multiple screenshots from their gallery. The app sends each through Google ML Kit's text recognition (runs on-device, no internet needed). The extracted text goes to the AI with a structured prompt: "This is an e-commerce receipt — extract item name, amount, date, merchant." The AI returns JSON which we parse and display for user confirmation before saving. We support 40+ platforms because we've built keyword detection for their specific receipt formats.

**Q: How is data stored? Is it secure?**
> Primary storage is SQLite on-device (20 tables). We also sync to Firebase Firestore for cloud backup. API keys are NOT stored in the APK — they're fetched from Firebase Remote Config at app startup. The app uses Firebase App Check to prevent unauthorized API access. For local security, users can set a PIN or biometric lock.

**Q: What is your database schema version and how many tables?**
> Schema version 11, 20 tables. Key tables: expenses, income, budgets, wallets, savings_goals, debts, recurring, installments, insurance_policies, paluwagan, chat_history, score_history. We use a migration pattern — each schema upgrade is handled in the `onUpgrade` callback so existing user data is preserved.

---

## CATEGORY 5: "Research and methodology"

**Q: What is your research methodology?**
> We used an Agile Kanban development methodology — tasks moved through Backlog → In Progress → Done in sprints. For evaluation, we will use the System Usability Scale (SUS) with 30 respondents (20 parents, 10 young professionals) after the defense. The SUS is a standardized 10-item questionnaire that produces a 0–100 score; we're targeting above 80 which maps to "Good" on the Bangor et al. (2009) adjective scale.

**Q: What makes this a capstone contribution? What's new?**
> Three novel contributions: (1) The **dual-mode FHS** — a Financial Health Score that adapts its formula based on whether the user tracks income or not. No other Filipino finance app has a similar scoring system. (2) **Multi-modal AI input** with 34 agentic actions in Taglish — combining voice, OCR, barcode, and screenshot import in one app. (3) The **8-provider AI fallback chain** — a resilience architecture for maintaining AI availability across multiple free-tier providers, which is a practical solution for apps that can't afford paid AI subscriptions.

**Q: How is this different from just using ChatGPT to track expenses?**
> ChatGPT is a conversational AI without persistent data. Every time you close it, context is lost. SmartSpend maintains a complete financial database on your device — 218 expenses, 5 wallets, 3 savings goals in our test account. The AI doesn't just chat, it executes 34 types of actions: it actually saves to the database, updates wallet balances, sends notifications, calculates scores. ChatGPT can't do any of that. Also, ChatGPT Finance (US-only, requires a bank link via Plaid) — not available in the Philippines.

---

## CATEGORY 6: "Hard questions / challenges"

**Q: What are the limitations of your app?**
> Honest answer: (1) The AI works best with clear, structured input — very ambiguous messages sometimes produce wrong categories. We've mitigated this with the evidence threshold but it's not perfect. (2) We don't have a Play Store release yet — that requires Google's 14-day closed testing with 12 testers. (3) No iOS version yet — Flutter supports it but we'd need a Mac with Xcode. (4) The FHS formula hasn't been validated with actual user data yet — that's what the SUS survey and post-defense testing will address.

**Q: How do you handle RA 10173 (Data Privacy Act)?**
> We've implemented four measures: (1) PII redaction before sending to AI — mobile numbers and email patterns are stripped from messages. (2) The app includes a one-time AI advice disclaimer clarifying we're not a licensed financial adviser (RA 11765 compliance). (3) Data stored locally by default — Firestore sync is user-controlled. (4) The privacy policy discloses what data is collected, how it's stored, and user rights. We plan to host the privacy policy page as a prerequisite for Play Store submission.

**Q: If the AI has a daily limit of 150 messages, what happens after that?**
> The app shows a clear message that the daily limit has been reached and resets at midnight UTC. All manual entry features remain fully functional — Log Expense, Edit, Budgets, Analytics, and all Hub tools work without AI. The limit is per user, per day. At 150 messages spread across 8 providers, the total API capacity is ~1,200 per day across all our users — sufficient for a research prototype. For production scaling, paid API tiers would be used.

---

## QUICK FACTS — memorize these numbers

| Metric | Value |
|--------|-------|
| Version | 2.9.65 |
| Platform | Android (Flutter/Dart) |
| AI providers | 8 (Gemini, 5 Groq models, Cerebras) |
| Agentic actions | 34 |
| Input modalities | 7 (voice, text, camera, batch screenshots, barcode, OCR, share intent) |
| Achievement badges | 25 |
| Daily AI message limit | 150/day |
| Color themes | 10 |
| Hub tiles | 26 |
| Currencies supported | 57 |
| Batch screenshot platforms | 40+ |
| PH banks in database | 20 + 5 e-wallets |
| SQLite tables | 20 |
| FHS components | 4 × 25 pts = 100 |
| FHS "Good" threshold | ≥80 (Bangor et al. adjective scale) |
| Savings rate target | 20% of income |

---

## PHRASES TO AVOID / USE INSTEAD

| Don't say | Say instead |
|-----------|-------------|
| "I don't know" | "Let me clarify that — what we implemented is..." |
| "It's complicated" | "The way it works is simple — ..." |
| "We didn't have time to..." | "That's on our post-capstone roadmap — specifically..." |
| "It sometimes doesn't work" | "There's an edge case we handle by..." |
| "The AI decides" | "The AI parses the text and returns a structured action, which the app executes" |
| "It just works" | Explain HOW it works |
| "We copied from..." | "We were inspired by [app] but our implementation is different because..." |

---

## ONE-LINE ANSWERS (for rapid-fire questions)

- **"What is SmartSpend?"** → "An AI-powered expense tracker for Filipinos that lets you log spending by just talking to it."
- **"What is the FHS?"** → "A 0–100 score measuring your savings rate, spending control, budget adherence, and logging consistency — 25 points each."
- **"Why AI?"** → "To eliminate the manual data entry barrier that stops most people from tracking finances."
- **"What database?"** → "SQLite locally, Firebase Firestore for cloud sync."
- **"How many users tested it?"** → "SUS survey with 30 respondents is planned post-defense."
- **"Is it on the Play Store?"** → "Not yet — Play Store requires 14-day closed testing which we're scheduling post-defense."
- **"What's your team's role split?"** → "Brix: lead developer and system architect. Cyrille: UI/UX and documentation. Djaunathan: project management and QA."

---

*Compiled by Kiro, September 2026. Practice these out loud — the smoother you say them, the more confident you'll appear.*
