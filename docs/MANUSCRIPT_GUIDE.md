# SmartSpend — Manuscript Guide
**Version:** 2.9.7 | **August 2026** | **Lucid Frame**

> One document for all manuscript-related work.
> PART 1 = Paper revision guide (how to write each chapter, what to say).
> PART 2 = Fix-by-fix corrections to apply in Google Docs.
> The full revised manuscript is in: `docs/manuscript/SMARTSPEND_REVISED_MANUSCRIPT.md`

---
# PART 1 — PAPER GUIDE (How to Write Each Section)

**For:** Lucid Frame — Cyrille John M. Rubis (Documentation Lead)
**Date:** August 27, 2026 | **Academic Year:** 2026–2027, 1st Semester | **Version:** v2.9.7
**Purpose:** Source of truth for revising Chapters 1–5 of the capstone thesis paper

> ⚠️ Also see **`docs/CAPSTONE_REFERENCE.md`** — the most comprehensive single-file reference for capstone documentation, with all current numbers, quotes, and comparison tables.

---

## HOW TO USE THIS DOCUMENT
This is NOT a replacement for your paper. It is a **reference guide** — copy and adapt the content below into your paper's proper format (APA citations, school template, etc.).

Each section maps to a chapter in your paper. Use the exact numbers, technical descriptions, and justifications provided here — they are accurate to the actual built system.

---

## CHAPTER 1 — INTRODUCTION

### Title (Recommended)
**SmartSpend: An AI-Assisted Multi-Modal Personal Financial Management Application for Filipino Users Using Agentic Large Language Model Architecture**

### Background of the Study
Key statistics to cite:
- **BSP CFIS 2025:** Only 50% of Filipino adults have formal financial accounts (down from 56% in 2021)
- **BSP 2025:** 74% of Filipinos correctly answered basic financial literacy questions (up from 69% in 2021)
- **Flores (2025):** Filipino workers show a "come-what-may" attitude toward financial planning, relying on informal savings methods
- **PhilStar/NIQ 2026:** Filipino consumers are "spending wiser, saving smarter" but remain cautious despite income growth
- Only **28% of Filipinos** have life insurance (Insurance Commission, 2025)
- **44.4%** of medical spending in PH is out-of-pocket

### Problem Statement
No existing application combines:
1. Filipino-English (Taglish) AI input
2. Fully offline capability with cloud sync
3. A financial health scoring system
4. Multi-modal input (voice, OCR, barcode)
5. Philippine-specific financial knowledge (SSS, PhilHealth, Pag-IBIG, PH banks)

### Objectives
**General Objective:**
Design, develop, and evaluate SmartSpend — an AI-assisted mobile personal financial management application for Filipino users (parents 35-55 and young professionals 21-35) in La Union.

**Specific Objectives:**
1. Assess the existing financial management practices, common budgeting challenges, and expense tracking behaviors of the target population through structured surveys and interviews
2. Design and develop the SmartSpend mobile application, including system architecture, database structure, user interface, core functionalities, and AI integration using a multi-provider LLM API with agentic action architecture
3. Evaluate the usability of SmartSpend using the System Usability Scale (SUS) with a target score of 80+ (Good)

### Scope and Limitations
**In scope:**
- Android mobile application (Flutter/Dart)
- Manual expense input (text, voice, OCR, barcode)
- Local SQLite database with Firebase Firestore cloud sync
- AI-powered expense parsing and financial advice (29 agentic actions)
- Financial Health Score (4-component formula)
- Philippine-specific features (PH banks, SSS/PhilHealth/Pag-IBIG, BIR TRAIN Law)

**Out of scope:**
- iOS version (Android only for Capstone 2)
- Direct bank integration (BSP Open Finance API still in early pilot — UnionBank only as of July 2025)
- Real-time stock market data (planned post-capstone)
- AI model fine-tuning (context injection used instead)
- Professional financial advice (disclaimer required — see Section 17 of docs/BENCHMARK.md)

### Significance
- **Students/Young Professionals:** First app combining Taglish AI + offline capability + PH financial knowledge
- **Researchers:** Demonstrates viable agentic AI on free-tier APIs for academic projects
- **Filipino financial inclusion:** Addresses BSP's goal of expanding financial literacy without requiring bank accounts
- **Academic field:** Contributes evidence on context-injection architecture vs. RAG for personal finance AI

---

## CHAPTER 2 — REVIEW OF RELATED LITERATURE

### Theoretical Frameworks
1. **Behavioral Finance Theory** (Kahneman & Tversky, 1979; Thaler & Sunstein, 2008) — Loss aversion, nudge theory applied in SmartSpend's Impulse Pause mechanic and budget alert framing
2. **Financial Capability Framework** (BSP, 2021) — 4 components: knowledge, attitude, behavior, access. SmartSpend addresses all four.
3. **Technology Acceptance Model (TAM)** (Davis, 1989) — Perceived usefulness + ease of use → adoption. SUS evaluation measures this.
4. **50/30/20 Budgeting Rule** (Elizabeth Warren, 2005) — SmartSpend implements this as a built-in analytics tracker

### Related Applications
See `docs/BENCHMARK.md` for the full comparison table (14 apps, including BudgetPH and Alkansya AI).

**Summary for paper:**
| App | AI | Offline | Filipino Context | Free | PH-Specific |
|-----|----|---------|--------------------|------|-------------|
| YNAB | ❌ | ❌ | ❌ | ❌ $14.99/mo | ❌ |
| Monarch Money | ⚠️ Limited | ❌ | ❌ | ❌ $9.99/mo | ❌ |
| Copilot | ⚠️ Categorization | ❌ iOS only | ❌ | ❌ $10.99/mo | ❌ |
| Tarsi (PH) | ❌ | ✅ | ✅ Partial | ✅ | ✅ Partial |
| **BudgetPH** | ✅ Insights | ✅ | ✅ Full Filipino | ✅ | ✅ Full |
| **Alkansya AI** | ✅ Chat | ❌ | ✅ Filipino | ⚠️ Limited | ✅ Partial |
| **SmartSpend** | ✅ 29 actions | ✅ Full | ✅ Full Taglish+AI | ✅ Completely | ✅ Full |

**Key gap:** No existing app combines all six: Taglish AI + 29 agentic actions + offline + PH financial knowledge + free + multi-modal input. BudgetPH is the closest Filipino-first competitor but lacks voice input, OCR, barcode, and agentic AI.

### Related Studies
- **Flores (2025)** — Financial freedom of Filipino workers: come-what-may attitude, informal savings, high debt without plan
- **ResearchGate (2024)** — Financial literacy and spending habits of Filipino senior high students: significant positive relationship between literacy and habits
- **BSP Financial Inclusion Survey (2025)** — E-wallet adoption driving financial inclusion; account ownership at 50%
- **Juniper Research (2026)** — Gamification boosts saving habits by 22%; users save 20% more on average when game mechanics present
- **Strivecloud (2026)** — Fintech gamification increases user retention and engagement

---

## CHAPTER 3 — METHODOLOGY

### Research Design
**Mixed methods descriptive-developmental approach:**
- **Qualitative:** Interviews to understand personal financial management experiences
- **Quantitative:** Survey questionnaires (Objective 1) + SUS questionnaire (Objective 3)
- **Developmental:** System built using Agile Kanban methodology

### System Architecture
```
User Input (Voice/OCR/Barcode/Text/AI Chat)
    ↓
Flutter Android App (UI Layer)
    ↓
Services Layer (AIChatService, DBService, ScoreService, etc.)
    ↓
SQLite Local DB ←→ Firebase Firestore (cloud sync)
    ↓
Multi-Model LLM API (Gemini 3.1 Flash-Lite → Gemini 3.5 Flash → Groq LLaMA 3.3 70B → Groq LLaMA 3.1 8B → Cerebras)
```

**AI Architecture:** Agentic AI with dynamic context injection (NOT RAG)
- Context injection = user's live financial data injected into system prompt before each message
- 29 action types parsed from AI response JSON
- Why not RAG: Per-user data is small enough to fit in prompt; vector search overhead unnecessary

### Financial Health Score (FHS) Formula
The FHS is a **4-component weighted formula** (25 points each, total 100):

| Component | Formula | Max Points |
|-----------|---------|------------|
| Savings Rate | 25 × min(1, savingsRate / 0.20) where savingsRate = (income − spent) / income | 25 |
| Overspend Control | 25 × (1 − overDays / activeDays) where overDays = days spending exceeded daily budget | 25 |
| Budget Adherence | 25 × (onBudgetCategories / totalBudgetCategories) | 25 |
| Logging Consistency | 25 × (loggedDays / activeDays) | 25 |

**Warning Decay:** If budget exceeded and spending continues next day → −5 pts/day (max −15 over 3 days)
**Empty state:** Returns 50 (neutral) — new users not penalized for having no data

### LLM Selection Justification
See `docs/BENCHMARK.md` for full benchmarking table.

**Summary for paper:**

Primary: **Gemini 3.1 Flash-Lite** (Google AI Studio)
- 1,000 requests/day FREE — sufficient for 60 req/user/day limit
- 1 million token context window
- Best reasoning quality among free models
- Filipino-English: excellent (multilingual training)
- Function calling: native support
- Replaces Gemini 2.5 Flash-Lite (deprecated — unavailable to new API users as of early 2026)

Fallback chain: Gemini 3.5 Flash → Groq LLaMA 3.3 70B → Groq LLaMA 3.1 8B → Cerebras LLaMA 3.1 70B

**Why not GPT-5.6/Claude Fable 5:** Require paid API keys — not viable for academic project with no budget.
**Why not self-hosted (Mistral/Phi-3):** Poor Filipino-English understanding; no reliable hosted free API.

**Architecture justification quote (use in paper):**
> "SmartSpend implements a multi-provider agentic AI system using dynamic full-context injection from a local SQLite database, enabling autonomous financial data management without the infrastructure overhead of traditional RAG pipelines. The multi-provider routing architecture ensures continuous AI availability through automatic failover across five free-tier LLM providers."

### Development Tools & Tech Stack
| Component | Technology | Version |
|-----------|-----------|---------|
| Framework | Flutter (Dart) | 3.x stable |
| Local DB | SQLite via sqflite | v11 (20 tables) |
| Cloud Sync | Firebase Firestore | Free Spark plan |
| Authentication | Firebase Auth (email + Google) | — |
| Crash Reporting | Firebase Crashlytics | — |
| AI APIs | Gemini 3.1 Flash-Lite (primary), Groq LLaMA 3.3 70B, Cerebras LLaMA 3.1 | — |
| OCR | Google ML Kit Text Recognition | Latin script |
| Barcode | mobile_scanner + Google ML Kit | — |
| Barcode Lookup | Open Food Facts API + local PH DB | Free, no key |
| Charts | fl_chart | — |
| Voice Input | speech_to_text (en-PH) | — |
| Exchange Rates | open.er-api.com | Free, 57 currencies |
| Push Notifications | flutter_local_notifications | — |
| API Security | Firebase Remote Config | API key not in APK |

### Data Collection Methods
1. **Pre-survey (Objective 1)** — Structured questionnaire on financial habits, budgeting practices, expense tracking behaviors of target population (n=30+)
2. **Think-aloud usability testing** — 3-5 users perform tasks while verbalizing thoughts
3. **SUS Questionnaire (Objective 3)** — 10-item scale, 1-5 Likert, post-demo; target score ≥80 (Good)
4. **Qualitative interviews** — 5-10 in-depth interviews on financial management experiences

### SUS Scoring
The System Usability Scale (Brooke, 1996; validated by Bangor et al., 2009):
- 10 questions (alternating positive/negative)
- Score calculation: odd items (score-1), even items (5-score), sum × 2.5
- Scale: 0-100, where ≥80 = Good, ≥68 = Above Average
- Target: **80 or above** (Good classification)
- **Validators:** Subject matter expert in financial management (survey content) + subject matter expert in IT (system and SUS evaluation) — credentials documented in Appendix A validation certificates, names optional

---

## CHAPTER 4 — RESULTS AND DISCUSSION

*(To be filled after data collection)*

### Template Structure:
1. **Pre-Survey Results** — financial habit profiles, common pain points, technology usage
2. **System Features Demonstration** — screenshots + feature descriptions referencing this document
3. **SUS Results** — score per respondent, mean score, classification
4. **Interview Findings** — themes from qualitative analysis
5. **FHS Validation** — does the formula correlate with user-reported financial health?

### Key Numbers to Report (from v2.9.7 final build)
- **29 AI agentic actions** implemented
- **5 LLM providers** with automatic failover + task-based routing (fast/smart/financial_advice)
- **23 achievement badges** + 10 daily quests
- **14 expense categories**, **9 payment methods**, **57 currencies**
- **20 PH banks** in comparison database
- **6 input modalities**: AI chat (text), voice, live camera, single photo (auto-detect), batch screenshots (40+ platforms), paste text — plus manual form entry (no AI required)
- **7 startup alert conditions** (plus gap detection, income sanity, balance discrepancy)
- **4-component FHS formula** — Full Mode and Lightweight Mode variants
- **FHS adjustments**: Warning Decay (−5/day) + Gap Adjustment (−3/+2 per day)
- **40+ screenshot platforms** detected automatically in batch import

---

## CHAPTER 5 — CONCLUSIONS AND RECOMMENDATIONS

### Conclusions Template
1. **Objective 1 met:** Pre-survey revealed [X findings about financial habits] — SmartSpend addresses [specific pain points]
2. **Objective 2 met:** SmartSpend was successfully developed with 29 AI actions, multi-model LLM routing, and Philippine-specific financial features
3. **Objective 3 met:** SUS score of [X]/100 classified as [classification] — meets/exceeds target of 80+

### Recommendations
1. Implement BSP Open Finance API integration as the PH open banking framework matures (UnionBank pilot live since July 2025)
2. Expand to iOS for wider coverage
3. Add Business Mode for MSME users (99.5% of PH businesses are MSMEs)
4. Develop offline AI capability when internet is unavailable
5. Partner with BSP/FinTech Alliance Philippines for official financial literacy endorsement

---

## FINANCIAL ADVICE DISCLAIMER (Must appear in paper and app)

> "SmartSpend provides general financial information and tracking tools for educational purposes only. This application is not a licensed financial advisor, investment advisor, insurance broker, or tax consultant. Nothing in this application constitutes personalized financial, investment, insurance, or tax advice. Users should consult a licensed financial professional before making significant financial decisions. SmartSpend is not liable for any financial losses resulting from actions taken based on information provided by this application."

**Philippine legal basis:**
- Securities and Exchange Commission (SEC-PH) — licenses investment advisors
- Insurance Commission (IC) — licenses insurance agents
- Bangko Sentral ng Pilipinas (BSP) — regulates financial products
- RA 11765 (Financial Products and Services Consumer Protection Act) — holds financial entities liable for misleading guidance

---

## FREQUENTLY ASKED PANEL QUESTIONS

**Q: "Your LLM should do something important and heavy — what does it do?"**
A: SmartSpend's AI executes 29 autonomous financial management actions — from splitting bills with auto-debt creation, to generating a 50/30/20 salary budget plan, explaining why your Financial Health Score dropped, detecting forgotten subscriptions, simulating what-if savings scenarios, and routing to the best-quality model for each task type. The AI perceives the user's complete financial context (expenses, wallets, budgets, goals, debts, mood, insurance) from the SQLite database and autonomously writes changes back — this is genuine agentic AI behavior: perceive → decide → act.

**Q: "Why not use RAG?"**
A: RAG (Retrieval-Augmented Generation) is designed for large knowledge bases (thousands of documents). A typical SmartSpend user has 20-50 expenses, 5-10 budgets, 3-5 goals — small enough to inject entirely into the system prompt. Our context injection approach gives the AI complete, always-current data without vector search overhead, making it faster and simpler for mobile deployment.

**Q: "Can users modify dates?"**
A: Yes — both through the UI (date picker + time picker in Edit Expense) and via AI chat ("move that grocery to last Tuesday"). All expense fields are fully editable.

**Q: "What if the LLM API goes down?"**
A: SmartSpend implements a 5-provider automatic fallback: Gemini 3.1 Flash-Lite → Gemini 3.5 Flash → Groq LLaMA 3.3 70B → Groq LLaMA 3.1 8B → Cerebras LLaMA 3.1. If all models hit daily limits, manual expense entry via the + button still works without AI.

**Q: "Why no bank integration?"**
A: Philippine open banking (BSP Open Finance) only launched in pilot in July 2025 with UnionBank as the first participant. SmartSpend's architecture is designed for integration as the framework matures. Currently, users can import GCash/bank history via text paste or OCR screenshot.

**Q: "Your AI gives financial advice — isn't that illegal?"**
A: SmartSpend provides general financial guidance and education — not personalized financial advice. There is a legal distinction. Personalized advice requires a licensed professional and fiduciary duty. The app explicitly disclaims this (in About screen, AI responses, and the paper). This approach is consistent with every major financial app globally — Mint, YNAB, Cleo — and is the legally correct design.

**Q: "How does the FHS formula work?"**
A: Four components, 25 points each: (1) Savings Rate — are you saving ≥20% of income? (2) Overspend Control — how many days did daily spending exceed budget? (3) Budget Adherence — what percentage of category budgets stayed within limits? (4) Logging Consistency — how regularly are you recording expenses? This formula is documented in the paper's Chapter 3 and directly implemented in the app's `ScoreService` class.

---

## KEY REFERENCES (APA Format Templates)

- Bangko Sentral ng Pilipinas. (2025). *Consumer Finance and Inclusion Survey (CFIS) 2025*. BSP.
- Bangko Sentral ng Pilipinas. (2026). BSP readies 2026 national financial literacy strategy. Retrieved from MSN Philippines.
- Bangor, A., Kortum, P., & Miller, J. (2009). Determining what individual SUS scores mean: Adding an adjective rating scale. *Journal of Usability Studies, 4*(3), 114-123.
- Brooke, J. (1996). SUS: A "quick and dirty" usability scale. In P. W. Jordan et al. (Eds.), *Usability Evaluation in Industry* (pp. 189-194). Taylor & Francis.
- Davis, F. D. (1989). Perceived usefulness, perceived ease of use, and user acceptance of information technology. *MIS Quarterly, 13*(3), 319-340.
- Flores, M. (2025). Financial freedom of Filipino workers. [Research study on Filipino financial planning attitudes].
- Insurance Commission Philippines. (2025). Philippine insurance market report.
- Juniper Research. (2026). Gamification in banking apps: How game mechanics drive financial behavior change.
- Thaler, R. H., & Sunstein, C. R. (2008). *Nudge: Improving decisions about health, wealth, and happiness*. Yale University Press.
- Warren, E., & Tyagi, A. W. (2005). *All your worth: The ultimate lifetime money plan*. Free Press.

---

*SmartSpend — Lucid Frame | Lorma Colleges CCSE BSIT 2026–2027 (1st Semester)*
*Compiled June 2026 — For use in Capstone 2 thesis paper revision*


---

# PART 2 — FIX GUIDE (Apply These in Google Docs)

> NOTE: All 19 fixes are already applied in `docs/manuscript/SMARTSPEND_REVISED_MANUSCRIPT.md`. Copy the corrected text from there into your Google Docs version.

**Apply these fixes one by one in your Google Docs. Each fix shows exactly what to find (CTRL+F) and what to replace it with.**

---

## FIX 1 — Achievement Badges count
**Where:** Chapter 1, Purpose and Description section
**How to find it (CTRL+F):** `16 achievement badges`

**CURRENT TEXT (find this):**
> A gamification layer featuring 16 achievement badges and spending streak tracking further reinforces positive financial habits

**REPLACE WITH:**
> A gamification layer featuring 23 achievement badges and spending streak tracking further reinforces positive financial habits

---

## FIX 2 — Backup version number (first occurrence)
**Where:** Chapter 2, Software Methodology / Development Phase description
**How to find it (CTRL+F):** `version 8 format`

**CURRENT TEXT (find this):**
> All financial data — including expenses, budgets, savings goals, income, recurring transactions, debts, wallet balances, mood log, and installment plans — is exported as a structured JSON file (version 8 format) that can be shared via any installed application or saved to local storage.

**REPLACE WITH:**
> All financial data — including expenses, budgets, savings goals, income, recurring transactions, debts, wallet balances, mood log, and installment plans — is exported as a structured JSON file (version 9 format) that can be shared via any installed application or saved to local storage.

---

## FIX 3 — API key security statement
**Where:** Chapter 2, Scope and Limitations section
**How to find it (CTRL+F):** `The LLM API key is embedded within the application package`

**CURRENT TEXT (find this):**
> The LLM API key is embedded within the application package as part of the free-tier academic deployment. To mitigate potential misuse, the system enforces a daily interaction limit of 60 AI requests per user, which resets automatically. A backend proxy server for secure API key management is planned as a post-capstone enhancement to align with production-level security practices.

**REPLACE WITH:**
> The LLM API key is not embedded within the application package. Instead, it is fetched securely at runtime via Firebase Remote Config, ensuring the key is never stored in the APK binary or exposed in the source code repository. To mitigate potential misuse, the system enforces a daily interaction limit of 60 AI requests per user, which resets automatically. A backend proxy server for fully server-side API key management is planned as a post-capstone enhancement to further align with production-level security practices.

---

## FIX 4 — Multi-wallet system status
**Where:** Chapter 2, Done/Review Phase (last paragraph of Software Methodology section)
**How to find it (CTRL+F):** `A multi-wallet system enabling separate tracking`

**CURRENT TEXT (find this):**
> A multi-wallet system enabling separate tracking of GCash, Maya, and bank balances requires significant database schema extensions and is targeted for future development.

**REPLACE WITH:**
> A multi-wallet system enabling separate tracking of GCash, Maya, and bank balances has been fully implemented in the current version. The system supports 30+ Philippine banks and e-wallets (GCash, Maya, GrabPay, ShopeePay, BDO, BPI, Metrobank, and more), with automatic balance deduction upon expense logging and wallet-to-wallet transfer functionality.

---

## FIX 5 — App Lock description in Technical Background
**Where:** Chapter 1, Technical Background section (near the end, under Firebase Authentication)
**How to find it (CTRL+F):** `biometric authentication (fingerprint or face unlock) as a convenience layer after the user's first successful login`

**CURRENT TEXT (find this):**
> Firebase Authentication will support secure login methods including email/password, Google Sign-In via OAuth 2.0, and biometric authentication (Google, 2024a).

*(Note: the app lock description appears again in local_auth section)*

**Also find (CTRL+F):** `biometric authentication (fingerprint or face unlock) as a login option after the user's first successful login`

**CURRENT TEXT (find this exact sentence):**
> The local\_auth package will enable biometric authentication (fingerprint or face unlock) as a login option after the user's first successful login, using the device's enrolled biometrics with a PIN fallback (The Flutter Authors, 2013).

**REPLACE WITH:**
> The local\_auth package enables biometric authentication (fingerprint or face unlock) as a security option during application startup. The lock screen appears only on cold start when a PIN is configured, and does not interrupt the user during normal use. This approach mirrors the authentication behavior of major Filipino financial applications such as GCash and Maya, where users authenticate once on open and are not repeatedly prompted during the session.

---

## FIX 6 — Financial Health Score — add Lightweight Mode
**Where:** Chapter 1, Technical Background section, Financial Health Score paragraph
**How to find it (CTRL+F):** `four equally weighted components: Savings Rate, Overspend Control, Budget Adherence, and Logging Consistency`

**CURRENT TEXT (find this):**
> SmartSpend introduces a Financial Health Score ranging from 0 to 100 that provides users with a single, interpretable indicator of their budgeting behavior. The score is computed from four equally weighted components: Savings Rate, Overspend Control, Budget Adherence, and Logging Consistency — each contributing 25% to the total score. The detailed formula, component weights, and consequence mechanism are fully documented in Chapter 3: Results and Discussion.

**REPLACE WITH:**
> SmartSpend introduces a Financial Health Score ranging from 0 to 100 that provides users with a single, interpretable indicator of their budgeting behavior. The score operates in two modes depending on the user's settings. In **Full Mode** (income tracking enabled), it is computed from four equally weighted components: Savings Rate, Overspend Control, Budget Adherence, and Logging Consistency — each contributing 25% to the total score. In **Lightweight Mode** (income tracking disabled), the four components are: Spending Restraint (vs. a user-defined spending limit), Logging Consistency, Category Balance (preventing any single category from dominating spending), and Habit Streak (consecutive days of expense logging). This dual-mode design makes the system usable for individuals who do not have a fixed income, such as students and informal workers, without penalizing them for not setting income data. The detailed formula, component weights, and consequence mechanism are fully documented in Chapter 3: Results and Discussion.

---

## FIX 7 — Table 1.2 Feature Comparison (add missing features)
**Where:** Chapter 1, after the feature comparison table
**How to find it (CTRL+F):** `General financial Q&A`

**In the table, find the last row which says:**
> | General financial Q&A | No | No | No | No | Yes |

**ADD these new rows AFTER "General financial Q&A"** (insert before the closing line of the table):

| Feature | Tarsi | YNAB | Monarch | Copilot | SmartSpend |
|---|---|---|---|---|---|
| Batch screenshot import (40+ platforms) | No | No | No | No | Yes |
| Multi-period spending limits (daily/weekly/monthly/yearly) | No | No | No | No | Yes |
| Lightweight Mode (no income required) | No | No | No | No | Yes |
| Logging gap detection with FHS adjustment | No | No | No | No | Yes |
| AI model selector (5 LLM providers) | No | No | No | No | Yes |

*(In Google Docs, place your cursor at the end of the last row and press Tab to add new rows, then type the content above)*

---

## FIX 8 — Backup version in Technical Background (second occurrence if present)
**Where:** Chapter 1 or 2, Backup and Restore section
**How to find it (CTRL+F):** `version 8`

If you find any other occurrence of "version 8" referring to the backup format, change it to **version 9**.

---

## FIX 9 — Update the gamification count in Purpose and Description beneficiaries section
**Where:** Chapter 1, Beneficiaries / Purpose and Description
**How to find it (CTRL+F):** `16 achievement badges`

*(This may be a second occurrence — replace it with 23 achievement badges just like Fix 1)*

---

## FIX 10 — Input methods count (optional upgrade)
**Where:** Chapter 1, Project Context / Purpose and Description
**How to find it (CTRL+F):** `voice input, receipt OCR, barcode, and manual text as input methods`

**CURRENT TEXT:**
> supports voice, receipt OCR, barcode, and manual text as input methods

**REPLACE WITH (optional — adds the newer Smart Import feature):**
> supports voice, receipt OCR, barcode scanning, manual text, AI chat, and a unified Smart Import system — including batch screenshot import that automatically detects 40+ platform types (GCash, Shopee, Steam, Lazada, GrabFood, and more) — as input methods

---

---

## FIX 11 — Account types: clarify they are flexible adaptive labels, not rigid classifications
**Panel recommendation #12:** "Make it general — remove rigid account type classifications"
**Where:** Chapter 1, Technical Background section OR Purpose and Description section
**How to find it (CTRL+F):** `account type`

**Context:** The panel wanted the app to feel general-purpose, not restricted. SmartSpend already does this — the 8 account types are adaptive labels that change UI copy (e.g., "allowance" vs "salary"), not hard restrictions. The manuscript just never explains this clearly.

**Find any sentence that describes account types (likely near the Setup/Onboarding section) and ADD this clarification right after it:**

> The account type selection serves as an adaptive label that personalizes the language and default suggestions within the application. For example, users who select "Student" will see "allowance" instead of "salary," and budget suggestions are adjusted to reflect a student's typical spending context. Users may change their account type at any time from the profile settings. This design ensures that the system is accessible and meaningful to a wide range of users — from students to employed adults, business owners, freelancers, and retirees — without restricting any features based on the selected type.

*(If there is no existing mention of account types in the manuscript body, add this paragraph at the end of the Purpose and Description section, before the Beneficiaries heading.)*

---

## FIX 12 — Reframe target population: Parents as PRIMARY, young professionals as secondary
**Panel recommendations #13 and #14:** "Who is really the best target population?" / "Consider parents as the primary target"
**Where:** Chapter 1, Statement of Objectives AND Chapter 2, Population and Locale

**PART A — Statement of Objectives**
**How to find it (CTRL+F):** `parents aged 35 to 55 and young professionals aged 21 to 35`

**CURRENT TEXT (find this — it appears in the Objectives paragraph):**
> This study aims to design, develop, and evaluate SmartSpend, an AI-assisted mobile financial tracking and advisory application for personal financial management among parents aged 35 to 55 and young professionals aged 21 to 35 in La Union, Philippines.

**REPLACE WITH:**
> This study aims to design, develop, and evaluate SmartSpend, an AI-assisted mobile financial tracking and advisory application for personal financial management, with a primary focus on parents aged 35 to 55 as the main target population, and young professionals aged 21 to 35 as a secondary demographic, in La Union, Philippines.

**PART B — Population and Locale**
**How to find it (CTRL+F):** `The target population consists of parents and young professionals`

**CURRENT TEXT (find this):**
> The target population consists of parents and young professionals who are actively involved in managing personal or household finances.

**REPLACE WITH:**
> The primary target population of this study consists of parents aged 35 to 55 who serve as the principal household financial decision-makers in Filipino families. Based on the 2021 BSP Financial Inclusion Survey, this demographic group manages the majority of household budgeting, bill payments, and daily financial decisions, yet exhibits the lowest rates of formal financial account ownership and structured budgeting behavior among all adult demographics (Bangko Sentral ng Pilipinas, 2021). A secondary population of young professionals aged 21 to 35 is also included, representing working individuals who independently manage their own income and expenses and represent a growing segment of digital financial tool users in the Philippines.

---

## FIX 13 — Add explicit respondent screening criteria
**Panel recommendation #15:** "Proper respondents — define specific screening criteria"
**Where:** Chapter 2, Population and Locale section
**How to find it (CTRL+F):** `The researchers will utilize purposive sampling`

**CURRENT TEXT (find this):**
> The researchers will utilize purposive sampling in selecting participants. This method allows the intentional selection of individuals who have relevant experience in budgeting, expense tracking, and financial decision-making. This approach ensures that the collected data is meaningful and directly aligned with the objectives of the study by selecting participants based on their relevance to the research variables.

**REPLACE WITH:**
> The researchers will utilize purposive sampling in selecting participants. This method allows the intentional selection of individuals who have relevant experience in budgeting, expense tracking, and financial decision-making, ensuring that the collected data is meaningful and directly aligned with the research objectives.
>
> **Inclusion criteria for parent respondents (n=20):**
> - Aged 35 to 55 years old
> - Currently serving as a primary household financial manager (responsible for budgeting, bill payments, and daily expense decisions)
> - Resident of San Fernando City or surrounding municipalities in La Union
> - Owns or has regular access to an Android smartphone
>
> **Inclusion criteria for young professional respondents (n=10):**
> - Aged 21 to 35 years old
> - Currently employed or self-employed with independent management of personal income and expenses
> - Resident of or working in San Fernando City, La Union
> - Owns or has regular access to an Android smartphone
>
> Individuals who do not meet the age range, do not actively manage personal or household finances, or do not have access to an Android device are excluded from the study.

---

## FIX 14 — Add citation justifying the young professional 21–35 age range
**Panel recommendation #16:** "For respondents, there should be studies and references to support why you chose them"
**Where:** Chapter 2, Population and Locale section — the paragraph that defines young professionals
**How to find it (CTRL+F):** `young professionals are defined as working individuals aged 21 to 35`

**CURRENT TEXT (find this):**
> For the purposes of this research, parents are defined as adults aged 35 to 55 who act as primary household financial managers, while young professionals are defined as working individuals aged 21 to 35 who manage their own income and expenses.

**REPLACE WITH:**
> For the purposes of this research, parents are defined as adults aged 35 to 55 who act as primary household financial managers. According to the 2021 BSP Financial Inclusion Survey, this age group represents the principal financial decision-makers in Filipino households and is among the demographics with the lowest rates of structured budgeting despite having the highest household financial responsibility (Bangko Sentral ng Pilipinas, 2021). Young professionals are defined as working individuals aged 21 to 35 who independently manage their own income and expenses. This age range aligns with the classification used by the BSP Financial Inclusion Survey and the Philippine Statistics Authority's Labor Force Survey, which identify 20–35 year-olds as early-career workers who are entering the formal workforce and beginning to establish independent financial management habits (Bangko Sentral ng Pilipinas, 2021; Philippine Statistics Authority, 2021).

---

## FIX 15 — ~~Name Benjie G. Bucasas explicitly as technical/system validator~~
> ⚠️ **NOTE: Fix 15 is PARTIALLY SUPERSEDED by Fix 19.**
> Fix 19 changed the approach to credential-based, optional-name validation certificates.
> **Only apply Fix 15 Part A (Table 2.1 label change) — do NOT apply Fix 15 Part B (adding the name explicitly).**
> The certificate itself is handled by Fix 19 with the optional-name format.

**Panel recommendation #26:** "Experts must validate the system itself, not just the questionnaire"
**Where:** Chapter 2, Population and Locale section — the validators table (Table 2.1) ONLY
**How to find it (CTRL+F):** `Technical Reviewer (SUS Process)`

**PART A — Apply this: In Table 2.1, find:**
> | Technical Reviewer (SUS Process) | 1 |

**REPLACE WITH:**
> | Technical Validator (System & SUS Process) | 1 |

**PART B — SKIP THIS PART** *(superseded by Fix 19 — the paragraph should use credential-based language, not a specific name)*

**PART C — Find the paragraph that describes the technical validator's role:**
**How to find it (CTRL+F):** `The System Usability Scale (SUS) evaluation process will be reviewed by a subject matter expert`

**REPLACE WITH (credential-based version):**
> The System Usability Scale (SUS) evaluation process and the overall technical functionality of the SmartSpend system will be reviewed by a subject matter expert in information technology, whose qualifications are documented in the Technical Validation Certificate (Appendix A). This expert validation covers both the correctness of the SUS evaluation process and an independent assessment of the system's core technical features.

---

## FIX 16 — Strengthen the Data Gathering procedure with specific steps
**Panel recommendation #27:** "Data gathering tools and procedures — specify step by step"
**Where:** Chapter 2, Data Gathering Tools and Procedure section
**How to find it (CTRL+F):** `For the first objective, data will be gathered through survey questionnaires and interviews`

**CURRENT TEXT (find the opening of this section):**
> For the first objective, data will be gathered through survey questionnaires and interviews. The survey questionnaire will be used to collect quantitative data regarding the financial management practices, budgeting challenges, and expense tracking behaviors of parents and young professionals.

**ADD the following paragraph immediately AFTER the full Data Gathering section (after the last paragraph about SUS), as a new sub-section:**

> **Step-by-Step Data Gathering Procedure**
>
> *Step 1 — Questionnaire Preparation and Validation (Objective 1):*
> The survey questionnaire will be drafted by the research team and submitted to Susan C. Arquisal for content validation. Revisions will be made based on her feedback before distribution.
>
> *Step 2 — Respondent Identification and Consent (Objective 1):*
> Thirty (30) respondents will be identified using purposive sampling based on the defined inclusion criteria. Each respondent will be given a consent form explaining the purpose of the study, their rights, and the confidentiality of their responses. Signed consent forms will be collected before questionnaire distribution.
>
> *Step 3 — Survey Distribution and Collection (Objective 1):*
> The validated questionnaire will be distributed in printed form to the 20 parent respondents and 10 young professional respondents in San Fernando City, La Union. Respondents will complete the survey independently. Interviews will be conducted with selected respondents to gather supplementary qualitative insights.
>
> *Step 4 — LLM Technical Benchmarking (Objective 2):*
> A comparative evaluation of candidate LLM APIs will be conducted by the lead developer using a standardized set of Filipino-English expense parsing prompts. Response latency, accuracy, context window, and cost will be recorded and tabulated in Table 2.2 (Chapter 3).
>
> *Step 5 — System Demonstration and SUS Evaluation (Objective 3):*
> Following system development, each respondent will be given a live demonstration of the SmartSpend application using the built-in Demo Mode. After the demonstration, respondents will independently complete the 10-item SUS questionnaire. The process will be overseen by Benjie G. Bucasas to ensure proper administration.
>
> *Step 6 — Data Tabulation and Analysis:*
> Survey responses will be tallied and analyzed for frequency and percentage. SUS scores will be computed per respondent and averaged to produce a final SUS score, which will be interpreted against the Bangor et al. (2009) adjective scale.

---

## FIX 17 — Table 1.2 Feature Comparison (add BudgetPH and Alkansya AI as new app columns)
**Panel recommendation #6 + new Filipino competitor research**
**Where:** Chapter 1, Table 1.2 — Feature Comparison of SmartSpend with Existing Financial Applications
**How to find it (CTRL+F):** `Table 1.2. Feature Comparison`

**Context:** Two Filipino-first competitors now exist that the panel should see compared — BudgetPH (budget.kindlyf.com) and Alkansya AI. Both launched in 2025–2026 and target Filipino users.

**Current table header (find this):**
> | Feature | Tarsi | YNAB | Monarch | Copilot | SmartSpend |

**REPLACE the entire Table 1.2 with this expanded version** (add two new columns and four new rows):

| Feature | Tarsi | YNAB | Monarch | Copilot | BudgetPH | Alkansya AI | SmartSpend |
|---------|-------|------|---------|---------|----------|-------------|-----------|
| Offline mode | Yes | No | No | No | Yes | No | Yes |
| LLM chat assistant | No | No | No | No | No (insights only) | Yes (basic) | Yes |
| Financial Health Score | No | No | No | No | Yes (simpler) | No | Yes (0–100) |
| OCR receipt scanning | Yes | No | No | No | No | No | Yes |
| Voice input (en-PH) | No | No | No | No | No | No | Yes |
| Spending behavior analysis | No | No | No | No | No | No | Yes |
| Bank synchronization | No | Yes | Yes | Yes | CSV import | No | No |
| Free tier (Android) | Yes | No | No | No | Yes (PWA) | Limited | Yes |
| General financial Q&A | No | No | No | No | No | Yes | Yes |
| Market price estimates | No | No | No | No | No | No | Yes |
| Financial product guidance | No | No | No | No | No | No | Yes |
| Batch screenshot import (40+ platforms) | No | No | No | No | No | No | Yes |
| Multi-period spending limits | No | No | No | No | Yes | No | Yes |
| Filipino-English AI (Taglish) | No | No | No | No | No | Yes | Yes |
| Paluwagan tracker | No | No | No | No | Yes | No | No |
| 15th & 30th payday cycle | No | No | No | No | Yes | No | No |

*(In Google Docs, add two new columns "BudgetPH" and "Alkansya AI" before the SmartSpend column. Add the new rows at the bottom of the table.)*

**Caption update:**
> **Table 1.2. Feature Comparison of SmartSpend with Existing Financial Applications (including Filipino-context apps)**

---

## FIX 18 — Table 2.2 LLM Comparison (expand from 4 models to current 13-model benchmark)
**Panel recommendation #10 — "Comparative analysis of LLMs"**
**Where:** Chapter 3 draft (or Chapter 2 if it's currently placed there), Table 2.2
**How to find it (CTRL+F):** `Table 2.2. Comparative Evaluation of LLM APIs`

**Context:** The manuscript currently shows only 4 models (Groq/LLaMA 3.1, Gemini 2.0 Flash, GPT-4o, Mistral). The actual benchmarked selection now covers 13 models. The full benchmark is in `docs/BENCHMARK.md`.

**REPLACE the current Table 2.2 with this expanded version:**

**Table 2.2. Comparative Evaluation of LLM APIs for SmartSpend Integration**

| LLM / Model | Provider | Context Window | Speed (t/s) | Filipino-English | Tool Use / JSON | Free Tier | Selected? |
|-------------|----------|---------------|-------------|-----------------|----------------|-----------|-----------|
| **Gemini 3.1 Flash-Lite** | Google | 1,000,000 | ~400–600 | ★★★★★ Excellent | ★★★★★ | ✅ 1,000 req/day | ✅ **PRIMARY** |
| **Gemini 3.5 Flash** | Google | 1,000,000 | ~200–400 | ★★★★★ Excellent | ★★★★★ | ✅ 250 req/day | ✅ Fallback 1 |
| **LLaMA 3.3 70B** | Groq LPU | 128,000 | ~315 | ★★★★☆ Good | ★★★★★ | ✅ 14,400 req/day | ✅ Fallback 2 |
| **LLaMA 3.1 8B** | Groq LPU | 8,192 | ~800 | ★★★★☆ Good | ★★★★☆ | ✅ 14,400 req/day | ✅ Fallback 3 |
| **LLaMA 3.1 70B** | Cerebras WSE | 128,000 | ~1,800 | ★★★★☆ Good | ★★★★☆ | ✅ 1M tokens/day | ✅ Fallback 4 |
| GPT-4o | OpenAI | 128,000 | ~80–120 | ★★★★★ Excellent | ★★★★★ | ❌ Paid only | ❌ Cost |
| GPT-4o Mini | OpenAI | 128,000 | ~120 | ★★★★☆ Good | ★★★★★ | ❌ No free tier | ❌ Cost |
| Claude 3.5 Sonnet | Anthropic | 200,000 | ~70–100 | ★★★★★ Excellent | ★★★★★ | ❌ Paid only | ❌ Cost |
| Gemini 2.0 Flash | Google | 1,000,000 | ~150 | ★★★★☆ Good | ★★★★☆ | ⚠️ 15 req/min | ❌ Superseded |
| Mistral 7B | Mistral AI | 32,000 | ~600 | ★★★☆☆ Fair | ★★★☆☆ | ✅ Self-host | ❌ Poor Filipino |
| Phi-3 Mini 3.8B | Microsoft | 4,096 | ~900 | ★★☆☆☆ Poor | ★★☆☆☆ | ✅ Local | ❌ Too small |
| Gemma 2 9B | Google | 8,192 | ~500 | ★★★☆☆ Fair | ★★★☆☆ | ✅ Local | ❌ No hosted API |
| Mixtral 8x7B | Mistral/Groq | 32,000 | ~400 | ★★★☆☆ Fair | ★★★★☆ | ✅ Groq | ❌ Poor Filipino |

**Selection criteria used (weighted):**
1. Filipino-English accuracy (25%) — ability to parse Taglish expense descriptions
2. Speed / Latency (20%) — response time for real-time mobile interaction (<3 seconds)
3. Tool use / JSON reliability (20%) — consistent structured output for agentic actions
4. Free tier availability (15%) — no cost for academic deployment
5. Context window (10%) — fits user's full financial data injection
6. Financial reasoning quality (10%) — accuracy on PH financial advisory queries

**Why Gemini 3.1 Flash-Lite was selected as primary:**
> Gemini 3.1 Flash-Lite offers the highest free request quota (1,000 req/day) among all evaluated models, combined with excellent Filipino-English understanding from Google's multilingual training, native function calling support, and a 1-million token context window. This makes it the optimal primary model for an academic mobile deployment serving up to 60 requests per user per day without cost.

**Why not GPT-4o or Claude:**
> Both require paid API keys with no sufficient free tier for sustained academic use. Their quality advantage does not justify the cost barrier for a capstone study.

---

---

## FIX 19 — Validation certificates: credential-based, optional name
**Approach:** Validators establish credibility through qualifications (degree, occupation, years of experience), not by required name disclosure. Name field is optional.

**PART A — Appendix A: Survey Content Validation Certificate**
**How to find it (CTRL+F):** `CONTENT VALIDATION CERTIFICATE`

**REPLACE the entire certificate block with:**

> **CONTENT VALIDATION CERTIFICATE — SURVEY QUESTIONNAIRE**
>
> This survey questionnaire has been reviewed for content validity and is deemed appropriate and relevant to the financial management experiences of the target population.
>
> Educational Background : ________________________________
> *(e.g., BS Commerce, BS Accountancy, BS Business Administration, or equivalent)*
>
> Occupation : ________________________________
> *(e.g., Business Owner, Financial Officer, Accountant, Financial Adviser, etc.)*
>
> Years of Experience : _____ years in financial management and/or business operations
>
> Signature : _______________________________
>
> Name *(optional)* : _______________________________
>
> Date : _______________________________

**PART B — Add a second certificate block immediately after the first (for the technical validator)**

> **TECHNICAL VALIDATION CERTIFICATE — SYSTEM AND SUS EVALUATION**
>
> The SmartSpend system and its usability evaluation process have been reviewed by a subject matter expert in Information Technology to ensure technical soundness and proper SUS administration.
>
> Educational Background : ________________________________
> *(e.g., BS Information Technology, BS Computer Science, or equivalent)*
>
> Occupation : ________________________________
> *(e.g., Software Developer, IT Instructor, Systems Analyst, IT Professional, etc.)*
>
> Years of Experience : _____ years in IT / software development and/or usability evaluation
>
> Signature : _______________________________
>
> Name *(optional)* : _______________________________
>
> Date : _______________________________

**PART C — Population and Locale section**
**How to find it (CTRL+F):** `The survey questionnaire will be reviewed by Susan C. Arquisal`

**REPLACE with:**
> The survey questionnaire will be reviewed by a subject matter expert in financial management and business operations, prior to distribution. The expert's qualifications — including educational background, occupation, and years of experience in financial management — will be documented in the Content Validation Certificate (Appendix A). This credential-based validation approach ensures that the questions are appropriate, relevant, and grounded in the actual financial management experiences of the target population, while respecting the evaluator's privacy preferences regarding name disclosure.

**PART D — Data Gathering section**
**How to find it (CTRL+F):** `survey was validated by a Content Validator (Susan C. Arquisal)`

**REPLACE with:**
> The survey questionnaire will be subjected to content validation by a subject matter expert in financial management and business operations, whose qualifications are documented in the Content Validation Certificate (Appendix A).

**PART E — Step-by-Step Data Gathering (Fix 16, Step 1)**
Update the first step to remove Susan's name:
> *Step 1 — Questionnaire Preparation and Validation (Objective 1):*
> The survey questionnaire will be drafted by the research team and submitted to a subject matter expert in financial management for content validation. The expert's credentials (educational background, occupation, years of experience) will be recorded in the Content Validation Certificate. Revisions will be made based on their feedback before distribution.

---

## SUMMARY CHECKLIST

Use this to track your progress in Google Docs:

- [ ] Fix 1 — "16 achievement badges" → "23 achievement badges"
- [ ] Fix 2 — "version 8 format" → "version 9 format" (backup)
- [ ] Fix 3 — API key security statement (not in APK, uses Remote Config)
- [ ] Fix 4 — Multi-wallet "future" → "fully implemented"
- [ ] Fix 5 — App lock description (cold-start only, like GCash/Maya)
- [ ] Fix 6 — FHS section (add Lightweight Mode explanation)
- [ ] Fix 7 — Table 1.2 (add 5 new rows for newer features)
- [ ] Fix 8 — Any other "version 8" backup references → version 9
- [ ] Fix 9 — Any second occurrence of "16 achievement badges" → 23
- [ ] Fix 10 — (Optional) Input methods list — add Smart Import
- [ ] Fix 11 — Account types: add clarification they are flexible adaptive labels
- [ ] Fix 12 — Reframe target population: parents PRIMARY, young professionals secondary (2 spots)
- [ ] Fix 13 — Add explicit respondent screening/inclusion criteria
- [ ] Fix 14 — Add citations justifying the 21–35 young professional age range
- [ ] Fix 15 — Table 2.1 label only: "Technical Reviewer" → "Technical Validator (System & SUS Process)" *(Part A only — Part B superseded by Fix 19)*
- [ ] Fix 16 — Add step-by-step data gathering procedure sub-section
- [ ] Fix 17 — Table 1.2 (add BudgetPH and Alkansya AI as new app columns)
- [ ] Fix 18 — Table 2.2 (expand LLM comparison from 4 to 13 models)
- [ ] Fix 19 — Replace named validation certificates with credential-based optional-name format (5 spots: Appendix A ×2, Population section, Data Gathering section, Fix 16 Step 1)

---

## NOTES FOR CHAPTER 3 (when you write it)

These things from the actual app should be in Chapter 3:

1. **LLM selection justification** — Primary: Gemini 3.1 Flash-Lite (1,000/day FREE, 1M context, Filipino-English excellent). Fallback chain: Gemini 3.5 Flash → Groq LLaMA 3.3 70B → Groq LLaMA 3.1 8B → Cerebras LLaMA 3.1. Reason for NOT using GPT-4o: paid only, not viable for academic deployment.

2. **FHS formula** — Both modes. Use the exact tables from `docs/CAPSTONE_REFERENCE.md` Section 4.

3. **Architecture quote** (ready to paste into paper):
   > "SmartSpend implements a multi-provider agentic AI system using dynamic full-context injection from a local SQLite database, enabling autonomous financial data management without the infrastructure overhead of traditional RAG pipelines. The multi-provider routing architecture ensures continuous AI availability through automatic failover across five free-tier LLM providers, with task-based routing to match query complexity with model capability."

4. **Why not RAG** — per-user data (20-50 expenses, 5-10 budgets, 3-5 goals) fits entirely in the model's context window. No vector search needed.

5. **29 agentic actions** — list is in `docs/CAPSTONE_REFERENCE.md` Section 3.

---

*Fix guide prepared by Kiro — based on comparing the manuscript against the actual v2.9.7 build — all fixes now applied in docs/manuscript/SMARTSPEND_REVISED_MANUSCRIPT.md*
*For questions: refer to `docs/CAPSTONE_REFERENCE.md` for all accurate numbers*


---

*SmartSpend v2.9.7 — Lucid Frame | Lorma Colleges CCSE BSIT 2026–2027*
