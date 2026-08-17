# SmartSpend — Capstone 2 Paper Revision Guide
**For:** Lucid Frame — Cyrille John M. Rubis (Documentation Lead)
**Date:** August 11, 2026 | **Academic Year:** 2026–2027, 1st Semester | **Version:** v2.9.2
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

**Why not GPT-4o/Claude 3.5:** Require paid API keys — not viable for academic project with no budget.
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

### Key Numbers to Report (from v2.9.2 final build)
- **29 AI agentic actions** implemented
- **5 LLM providers** with automatic failover + task-based routing (fast/smart/financial_advice)
- **23 achievement badges** + 10 daily quests
- **14 expense categories**, **9 payment methods**, **57 currencies**
- **20 PH banks** in comparison database
- **7 input modalities**: text chat, voice, live camera, single photo (auto-detect), batch screenshots (40+ platforms), paste text, manual form
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
