# SmartSpend — Research Basis & Academic References
## Theoretical Foundations for All Features and Functions
**Version:** 2.9.2 | **Group:** Lucid Frame | **AY:** 2026–2027, 1st Semester
**Purpose:** This document answers the question "where did you get the basis for this?" for every major feature. Use this when writing Chapter 2 (Review of Related Literature) and defending before the panel.

> **For Ma'am:** Every feature in SmartSpend is grounded in an existing framework, research, book, or validated standard — not made up. This document traces each one.

---

## PART 1 — FINANCIAL HEALTH SCORE (FHS)

### 1.1 What It Is (in plain terms)
SmartSpend's Financial Health Score is a single number from 0 to 100 that tells the user how well they are managing their finances. Higher = healthier. It is calculated from the user's own recorded data — no survey needed.

---

### 1.2 Existing Frameworks We Based It On

#### A. Financial Health Network — FinHealth Score® Framework
**Source:** Financial Health Network. (2021). *FinHealth Score Toolkit*. https://finhealthnetwork.org/tools/financial-health-score/

**What it says:** The FinHealth Score® measures financial health across **4 pillars** and **8 indicators**:

| Pillar | Indicators |
|--------|-----------|
| **Spend** | Spend less than income; pay bills on time |
| **Save** | Have a rainy day fund; save for long-term goals |
| **Borrow** | Have manageable debt; have a prime credit score |
| **Plan and Protect** | Have appropriate insurance; plan for retirement |

The framework was updated in 2026 to rename the fourth pillar from "Plan" to "Plan and Protect" (Financial Health Network, 2026).

**How SmartSpend uses this:** Our FHS is directly inspired by this framework — specifically the Spend and Save pillars. Our Savings Rate component (are you saving ≥20%?) maps to the Save pillar. Our Overspend Control component (are you spending less than income day-by-day?) maps to the Spend pillar.

**APA Citation:**
> Financial Health Network. (2021). *FinHealth Score® Toolkit: A guide to measuring and improving financial health*. https://finhealthnetwork.org/tools/financial-health-score/

> Financial Health Network. (2026). *From insight to impact: The next phase of financial health measurement*. https://finhealthnetwork.org/research/from-insight-to-impact-the-next-phase-of-financial-health-measurement/

---

#### B. UNSGSA Financial Health Measurement Framework
**Source:** United Nations Secretary-General's Special Advocate for Inclusive Finance for Development (UNSGSA). (2021). *Measuring financial health: A framework for practitioners*. https://www.unsgsa.org

**What it says:** The UNSGSA framework — used globally by financial inclusion advocates — defines financial health as the ability to:
1. Meet current financial obligations
2. Feel secure in the financial future
3. Make choices that allow enjoyment of life

It identifies key measurable behaviors: spending control, saving regularly, managing debt, and planning ahead.

**How SmartSpend uses this:** Our FHS is cited as being "informed by the UNSGSA framework" in Chapter 3. The four-component structure of our score (Savings Rate, Overspend Control, Budget Adherence, Logging Consistency) directly reflects the UNSGSA's emphasis on spending behavior, savings behavior, and consistency.

**APA Citation:**
> UNSGSA. (2021). *Measuring financial health: A framework for practitioners*. United Nations Secretary-General's Special Advocate for Inclusive Finance for Development. https://www.unsgsa.org

---

#### C. CFPB Financial Well-Being Scale
**Source:** Consumer Financial Protection Bureau. (2017). *CFPB Financial Well-Being Scale: Scale development technical report*. https://www.consumerfinance.gov/data-research/research-reports/financial-well-being-scale/

**What it says:** The CFPB Financial Well-Being Scale is the most validated academic instrument for measuring personal financial health. It produces a score from 0–100. Key finding: financial well-being is defined as a state where a person can:
- Meet obligations and have financial security
- Absorb financial shocks
- Be on track to meet financial goals
- Have freedom of choice

**Important distinction:** The CFPB Scale is survey-based (10 questions answered by the user about their feelings and behaviors). SmartSpend's FHS is computed from behavioral data — this is an important differentiator. When a panelist asks "what is your basis?", you say SmartSpend's FHS is a **behavioral computation** inspired by the CFPB's validated definition of financial well-being, but computed from transaction data rather than self-reported surveys.

**APA Citation:**
> Consumer Financial Protection Bureau. (2017). *Financial well-being scale: Scale development technical report*. CFPB. https://files.consumerfinance.gov/f/documents/201705_cfpb_financial-well-being-scale-technical-report.pdf

---

### 1.3 The SmartSpend FHS Formula — Exact Computation with Basis

#### Full Mode (Income Tracking ON)

**Component 1 — Savings Rate (25 pts)**
```
Score = 25 × min(1.0, savingsRate / 0.20)
savingsRate = (totalIncome − totalSpent) / totalIncome
```
**Basis:** The 20% savings target comes from the **50/30/20 budgeting rule** — allocate 20% of after-tax income to savings and debt repayment (Warren & Tyagi, 2005; widely cited in personal finance literature).

**Component 2 — Overspend Control (25 pts)**
```
Score = 25 × (1 − overDays / activeDays)
overDays = number of days this month where daily spending > (income ÷ daysInMonth)
```
**Basis:** Day-level spending discipline is derived from the FinHealth Score® Spend pillar — "spending less than income" as a measurable behavior (Financial Health Network, 2021).

**Component 3 — Budget Adherence (25 pts)**
```
Score = 25 × (onBudgetCategories / totalBudgetCategories)
```
**Basis:** Category-level budget tracking is a core feature of zero-based budgeting theory (Ramsey, 2003) and is validated by YNAB's research showing that users who set specific category budgets overspend 32% less.

**Component 4 — Logging Consistency (25 pts)**
```
Score = 25 × (loggedDays / activeDays)   [scoped to current month only]
```
**Basis:** Consistent financial tracking reduces discretionary spending by 10–20% (Mindfulsuite, 2026; behavioral finance research). The consistency component rewards the habit of tracking, which itself improves financial behavior (Thaler & Sunstein, 2008).

#### Lightweight Mode (Income Tracking OFF — for students, freelancers, informal workers)

| Component | Formula Basis |
|-----------|--------------|
| Spending Restraint | Spending vs user-set limit — budgeting behavior (Ramsey, 2003) |
| Logging Consistency | Same as Full Mode |
| Category Balance | No single category >40% — spending diversification principle |
| Habit Streak | Consecutive logging days — habit formation theory (Duhigg, 2012) |

**Basis for having two modes:** Not all Filipinos have fixed incomes — students, freelancers, and informal workers cannot meaningfully compute a savings rate. This dual-mode design is grounded in the Financial Health Network's acknowledgment that financial health metrics must adapt to diverse income structures (Financial Health Network, 2021).

#### Score Adjustments

**Warning Decay (−5 pts/day, max −15):**
**Basis:** Loss aversion theory (Kahneman & Tversky, 1979). People respond more strongly to the pain of a declining score than to the reward of a rising one. The decay mechanism makes the consequence of ignoring budget warnings tangible and persistent — translating abstract "you exceeded your budget" into a visible numeric consequence.

**Gap Adjustment (−3 or +2 pts/day):**
**Basis:** Behavioral honesty mechanism. When users confirm they genuinely had no spending on gap days, they receive a bonus. This is grounded in the principle of accurate self-monitoring from behavioral finance (Ariely, 2008).

---

### 1.4 Similar Apps with Financial Health Scores

| App | Their Score | How It Computes | Difference from SmartSpend |
|-----|-------------|-----------------|---------------------------|
| **Cleo** | "Health" score | Savings behavior + bill payment patterns | Survey + behavior hybrid; not formula-transparent |
| **BudgetPH** | Budget score (0–100) | Budget adherence + streak tracking | Simpler; fewer components; no Lightweight Mode |
| **Alkansya** (alkansya.online) | Financial Health Score | Spending patterns, net worth calculation | Web app only; formula not published |
| **Wingman Money** (Australia, 2026) | Financial Health Score / 100 | Daily behaviors + long-term wellbeing | Based on FinHealth Network framework; no offline mode |
| **CFPB Scale** | 0–100 | 10-question survey (subjective) | Survey-based vs SmartSpend's behavioral computation |
| **FinHealth Score®** | 0–100 | 8 behavioral indicators (Spend/Save/Borrow/Plan) | Institutional-level; requires external data feeds |
| **SmartSpend FHS** | 0–100 | 4 behavioral components computed from SQLite | Mobile-first, offline, real-time, dual-mode |

**Key academic advantage of SmartSpend:** Unlike Cleo and BudgetPH which use proprietary or opaque formulas, SmartSpend's FHS formula is fully documented, traceable to academic frameworks (UNSGSA, FinHealth Network, CFPB), and computable entirely from user-generated transaction data — no surveys, no bank connectivity, no external data required.

---

## PART 2 — LLM / AI ENGINE

### 2.1 Why Use an LLM for a Finance App?

**Research Basis:**
The use of large language models in financial applications is supported by a growing body of academic literature:

> Liu, X., et al. (2023). *FinGPT: Open-source financial large language models*. arXiv:2306.06031. https://arxiv.org/abs/2306.06031

> Yang, H., et al. (2023). *FinGPT: Democratizing internet-scale data for financial large language models*. arXiv:2307.10485. https://arxiv.org/abs/2307.10485

> Li, Y., et al. (2024). *A survey of large language models for financial applications*. arXiv:2406.11903. https://arxiv.org/abs/2406.11903

> Li, Z., et al. (2024). *Large language models in finance (FinLLMs)*. Neural Computing and Applications. https://doi.org/10.1007/s00521-024-10495-6

> Hean, O., Saha, U., & Saha, B. (2025). Can AI help with your personal finances? *Applied Economics*. https://doi.org/10.1080/00036846.2025.2450384

**Key finding from literature:** LLMs can reduce manual effort in financial data entry, improve categorization accuracy for multilingual (including Filipino-English) inputs, and enable conversational financial guidance at scale without the cost of human advisers (Li et al., 2024; Hean et al., 2025).

---

### 2.2 LLMs Specifically Designed for Financial Use

| Model | What It Is | Free? | Relevance to SmartSpend |
|-------|-----------|-------|------------------------|
| **FinGPT** (Liu et al., 2023) | Open-source LLM fine-tuned on financial data from 34+ sources. Uses LoRA for efficient fine-tuning. | ✅ Open-source, self-hostable | Academic citation for "LLM for finance." Not used in SmartSpend (self-hosting not viable on free cloud) |
| **BloombergGPT** (Wu et al., 2023) | First domain-specific financial LLM. Trained on Bloomberg's proprietary financial data. | ❌ Closed-source | Establishes that domain-specific FinLLMs outperform general LLMs on financial tasks — justifies our careful model selection |
| **LLM Pro Finance Suite** (arxiv:2511.08621, 2025) | 5 instruction-tuned LLMs (8B–70B) for multilingual financial tasks | ❌ Research only | Demonstrates that financial LLMs perform better on multilingual (including Filipino-context) tasks vs general LLMs |
| **Gemini 3.1 Flash-Lite** | Google's general-purpose multilingual LLM | ✅ 1,000 req/day free | **SmartSpend's primary model** — selected for Filipino-English accuracy, free tier, and 1M token context window |
| **Groq LLaMA 3.3 70B** | Meta's open-weight LLM on Groq's LPU hardware | ✅ ~14,400 req/day free | SmartSpend's fallback 2 — fastest open-source inference |

**Why not FinGPT for SmartSpend?**
FinGPT is trained on financial market data (stock prices, news, trading signals) — optimized for enterprise financial analysis, not consumer personal finance chat. SmartSpend needs Filipino-English conversational capability and expense parsing, which general multilingual LLMs (Gemini, LLaMA) handle better. This distinction is important for the panel.

---

### 2.3 Agentic AI Architecture

**Research Basis:**

> World Economic Forum. (2024). *How agentic AI will transform financial services*. https://www.weforum.org/stories/2024/12/agentic-ai-financial-services-autonomy-efficiency-and-inclusion/

> IBM. (2025). *Agentic AI in financial services: Navigating innovation*. https://www.ibm.com/think/insights/agentic-ai-financial-services-ethical-adoption

> Davenport, T. H., & Mittal, N. (2022). *All-in on AI: How smart companies win big with artificial intelligence*. Harvard Business Review Press.

**What agentic AI means:** Unlike traditional AI that only answers questions, agentic AI systems can perceive context, make decisions, and take autonomous actions (WEF, 2024; IBM, 2025). SmartSpend's AI perceives the user's full financial context from SQLite, decides the correct action type (from 29 options), and writes directly to the database — a genuine perceive → decide → act loop.

**Why Context Injection (not RAG):**
Per-user financial data in SmartSpend (~20–50 expenses, 5–10 budgets, 3–5 goals) fits entirely within the LLM's context window. Retrieval-Augmented Generation (RAG) is designed for large knowledge bases (thousands of documents) and adds vector search overhead unnecessary for small per-user datasets (Davenport & Mittal, 2022; Li et al., 2024).

---

### 2.4 Multi-Modal Input (Voice, OCR, Barcode, Screenshots)

**Research Basis:**

> IJERT. (2026). *AI-driven personal finance assistant with voice, OCR, and chatbot*. International Journal of Engineering Research and Technology. https://www.ijert.org/ai-driven-personal-finance-assistant-with-voice-ocr-and-chatbot-ijertv15is040439

> Beancount.io. (2026). *AI receipt scanning apps in 2026: The OCR-to-LLM shift*. https://beancount.io/blog/2026/07/10/ai-receipt-scanning-expense-apps-ocr-hallucination-guide

**Key finding:** Multi-modal input (voice + OCR + screenshots) significantly reduces the manual effort barrier that causes users to abandon expense tracking apps after initial use (Stefanov et al., 2024; IJERT, 2026). This directly addresses the BSP finding that Filipinos cite "too much manual effort" as their primary reason for not using financial tracking tools (BSP, 2021).

---

## PART 3 — 50/30/20 BUDGETING RULE

**Source:** Warren, E., & Tyagi, A. W. (2005). *All your worth: The ultimate lifetime money plan*. Free Press / Simon & Schuster.

**What it says:** Allocate after-tax income as follows:
- **50% Needs** — rent, utilities, food, transport, minimum debt payments
- **30% Wants** — dining out, entertainment, shopping, hobbies
- **20% Savings/Debt** — emergency fund, retirement, extra debt repayment

**How SmartSpend uses it:** The 50/30/20 tracker in the Analytics screen shows the user's actual spending distribution compared to this recommended allocation. Every expense is tagged as Need or Want by the AI, enabling real-time 50/30/20 monitoring.

**APA Citation:**
> Warren, E., & Tyagi, A. W. (2005). *All your worth: The ultimate lifetime money plan*. Free Press.

---

## PART 4 — GAMIFICATION (BADGES, DAILY QUESTS, STREAKS)

**Research Basis:**

> Bitrián, P., Buil, I., & Catalán, S. (2021). Making finance fun: The gamification of personal financial management apps. *International Journal of Bank Marketing, 39*(7), 1310–1332. https://doi.org/10.1108/IJBM-09-2020-0491

> Juniper Research. (2026). *Gamification in banking: How game mechanics drive financial behavior change*. [Research report]

> Strivecloud. (2026). *Fintech app gamification: Data shows 22% boost in saving habits*. https://strivecloud.io/blog/mobile-app-gamification-fintech

**Key findings:**
- Gamification in personal finance apps boosts saving habits by **22%** and increases average user savings by **20%** (Juniper Research, 2026; Strivecloud, 2026)
- Achievement badges and streak mechanics reward consistent logging behavior, creating positive habit loops (Bitrián et al., 2021)
- Gamified elements are most effective when tied to real financial behaviors (deposits, bill payments, logging) rather than balances alone (Trophy.so, 2026)

**How SmartSpend uses it:**
- **23 achievement badges** — reward specific financial milestones (first savings goal, 7-day streak, first debt payment, etc.)
- **10 rotating daily quests** — modeled after gacha game daily quests to encourage daily app engagement and consistent logging
- **Streak tracking** — consecutive days of logging, directly tied to the Logging Consistency FHS component

---

## PART 5 — BEHAVIORAL FINANCE (IMPULSE PAUSE, LOSS AVERSION, NUDGE THEORY)

**Research Basis:**

> Kahneman, D., & Tversky, A. (1979). Prospect theory: An analysis of decision under risk. *Econometrica, 47*(2), 263–292.

> Thaler, R. H., & Sunstein, C. R. (2008). *Nudge: Improving decisions about health, wealth, and happiness*. Yale University Press.

> Davis, F. D. (1989). Perceived usefulness, perceived ease of use, and user acceptance of information technology. *MIS Quarterly, 13*(3), 319–340.

**Loss Aversion (Impulse Pause feature):**
Kahneman & Tversky (1979) established that losses feel approximately twice as painful as equivalent gains feel pleasurable. SmartSpend's Impulse Pause mechanic — which pauses and asks "Are you sure? This affects your savings goal by ₱X" — deliberately frames large Want purchases in terms of loss (what you lose from your goals) rather than gain (what you get from the purchase). This is a direct application of loss aversion theory to trigger more deliberate financial decisions.

**Nudge Theory (Startup Alerts, Warning Decay):**
Thaler & Sunstein (2008) introduced nudge theory — small design interventions that guide behavior without restricting choice. SmartSpend's startup alerts (overdue bill reminders, FHS drop notifications) and the Warning Decay system (score decreases when budget warnings are ignored) are nudges: they preserve user freedom but make financially responsible behavior the path of least resistance.

**Technology Acceptance Model (Demo Mode, Multiple Input Methods):**
Davis (1989) established that technology adoption is driven by **perceived usefulness** and **perceived ease of use**. SmartSpend addresses both: the AI removes manual effort (ease of use) and the FHS provides actionable insight (usefulness). The Demo Mode specifically addresses the adoption barrier by letting users experience value before committing to registration.

---

## PART 6 — TARGET POPULATION BASIS

### Parents (Ages 35–55) as Primary Target

**Research Basis:**
> Bangko Sentral ng Pilipinas. (2021). *2021 Financial Inclusion Survey*. BSP. https://www.bsp.gov.ph

> Philippine Statistics Authority. (2021). *Family Income and Expenditure Survey (FIES) 2021*. PSA. https://www.psa.gov.ph

**Key findings:**
- Parents aged 35–55 are the primary household financial decision-makers in Filipino families but have the **lowest rate of structured budgeting** among all adult demographics (BSP, 2021)
- Many households in this age group spend beyond monthly income, with food, transportation, and utilities consistently outpacing savings (PSA FIES, 2021)
- Filipino adults in this demographic lack access to formal financial tools, citing manual effort and language barriers (BSP, 2021)

### Young Professionals (Ages 21–35) as Secondary Target

**Research Basis:**
> Flores, C. A. R. (2025). Financial freedom of Filipinos in personal finance management. *Pantao: The International Journal of the Humanities and Social Sciences, 4*(1). https://pantaojournal.com/2025/01/27/v4-i1-7/

**Key findings:**
- Filipino workers — including young professionals — show a "come-what-may" attitude toward financial planning, relying on informal savings methods and high debt without structured plans (Flores, 2025)
- The 21–35 age range aligns with BSP's classification of early-career workers beginning to establish independent financial management habits (BSP, 2021; PSA, 2021)

---

## PART 7 — OFFLINE-FIRST ARCHITECTURE

**Research Basis:**
> Bangko Sentral ng Pilipinas. (2021). *2021 Financial Inclusion Survey*. BSP.

**Basis:** BSP (2021) documents that many Filipinos — particularly in provincial areas like La Union — face intermittent internet access. A financial tracking app that requires constant internet connectivity would be inaccessible to a significant portion of the target population. SmartSpend's offline-first SQLite architecture ensures full functionality without internet, with Firebase sync when connectivity is available.

---

## PART 8 — PHILIPPINE FINANCIAL CONTEXT

### Why No Bank Integration?
> Bangko Sentral ng Pilipinas. (2025). *BSP Open Finance Framework (OFxPERA)*. BSP.

**Basis:** The Philippine open banking framework (OFxPERA) only launched in pilot in July 2025 with UnionBank as the first participant. No public API exists for most PH banks. SmartSpend is designed to integrate when the framework matures — the architecture is ready.

### Why GCash, Maya, SSS, PhilHealth, Pag-IBIG, BIR?
> Insurance Commission Philippines. (2025). *Philippine Insurance Market Report 2025*.

**Basis:** These are the dominant financial services used by everyday Filipinos — GCash and Maya have replaced traditional bank accounts for millions (BSP, 2021). SSS, PhilHealth, and Pag-IBIG are mandatory government contributions. SmartSpend's inclusion of these as first-class features — not afterthoughts — is what makes it Filipino-first rather than a translated Western app.

---

## SUMMARY TABLE — FEATURE → RESEARCH BASIS

| Feature | Research Basis | Key Citation |
|---------|---------------|-------------|
| Financial Health Score | FinHealth Score® Framework, UNSGSA, CFPB Scale | Financial Health Network (2021), UNSGSA (2021), CFPB (2017) |
| Savings Rate (20% target) | 50/30/20 Budgeting Rule | Warren & Tyagi (2005) |
| Overspend Control component | FinHealth Spend pillar | Financial Health Network (2021) |
| Logging Consistency component | Behavioral tracking reduces spending 10–20% | Mindfulsuite (2026), Thaler & Sunstein (2008) |
| Lightweight Mode (no income tracking) | Financial health metrics must adapt to diverse income structures | Financial Health Network (2021) |
| Warning Decay | Loss aversion — consequences make warnings real | Kahneman & Tversky (1979) |
| 50/30/20 tracker in Analytics | Warren's budgeting rule | Warren & Tyagi (2005) |
| AI chat — LLM for finance | LLMs reduce manual effort and improve financial behavior | Hean et al. (2025), Li et al. (2024), Liu et al. (2023) |
| Agentic AI (29 actions) | Agentic AI in financial services | WEF (2024), IBM (2025), Davenport & Mittal (2022) |
| Multi-modal input (voice, OCR, barcode) | Multi-modal reduces adoption friction | Stefanov et al. (2024), IJERT (2026) |
| Gamification (badges, quests, streaks) | Gamification boosts saving habits by 22% | Bitrián et al. (2021), Juniper Research (2026) |
| Impulse Pause mechanic | Loss aversion + nudge theory | Kahneman & Tversky (1979), Thaler & Sunstein (2008) |
| Demo Mode | Technology Acceptance Model — reduce adoption friction | Davis (1989) |
| Target population: parents 35–55 | Primary financial decision-makers with lowest literacy | BSP (2021), PSA FIES (2021) |
| Target population: young professionals 21–35 | "Come-what-may" attitude, informal savings | Flores (2025) |
| Offline-first architecture | Intermittent internet in provincial Philippines | BSP (2021) |
| Filipino context (GCash, SSS, etc.) | Dominant PH financial services; no open banking yet | BSP (2021, 2025), Insurance Commission (2025) |
| Budget Adherence component | Zero-based budgeting research | Ramsey (2003), YNAB usability studies |
| Subscription auto-detection | Awareness reduces unwanted recurring expenses | Rocket Money, Monarch Money research |

---

## FULL APA REFERENCE LIST (for manuscript bibliography)

Ariely, D. (2008). *Predictably irrational: The hidden forces that shape our decisions*. HarperCollins.

Bangko Sentral ng Pilipinas. (2021). *2021 Financial Inclusion Survey*. BSP. https://www.bsp.gov.ph/Inclusive-Finance/Financial-Inclusion-Surveys/2021-FIS-Report.pdf

Bangko Sentral ng Pilipinas. (2025). *Consumer Finance and Inclusion Survey (CFIS) 2025*. BSP.

Bangor, A., Kortum, P., & Miller, J. (2009). Determining what individual SUS scores mean: Adding an adjective rating scale. *Journal of Usability Studies, 4*(3), 114–123.

Bitrián, P., Buil, I., & Catalán, S. (2021). Making finance fun: The gamification of personal financial management apps. *International Journal of Bank Marketing, 39*(7), 1310–1332. https://doi.org/10.1108/IJBM-09-2020-0491

Brooke, J. (1996). SUS: A "quick and dirty" usability scale. In P. W. Jordan, B. Thomas, B. A. Weerdmeester, & I. L. McClelland (Eds.), *Usability evaluation in industry* (pp. 189–194). Taylor & Francis.

Consumer Financial Protection Bureau. (2017). *Financial well-being scale: Scale development technical report*. CFPB. https://files.consumerfinance.gov/f/documents/201705_cfpb_financial-well-being-scale-technical-report.pdf

Creswell, J. W., & Plano Clark, V. L. (2011). *Designing and conducting mixed methods research*. Sage Publications.

Davenport, T. H., & Mittal, N. (2022). *All-in on AI: How smart companies win big with artificial intelligence*. Harvard Business Review Press.

Davis, F. D. (1989). Perceived usefulness, perceived ease of use, and user acceptance of information technology. *MIS Quarterly, 13*(3), 319–340.

Dwivedi, Y. K., et al. (2021). Artificial intelligence (AI): Multidisciplinary perspectives on emerging challenges, opportunities, and agenda for research, practice and policy. *International Journal of Information Management, 57*, 101994. https://doi.org/10.1016/j.ijinfomgt.2019.08.002

Financial Health Network. (2021). *FinHealth Score® Toolkit*. https://finhealthnetwork.org/tools/financial-health-score/

Financial Health Network. (2026). *From insight to impact: The next phase of financial health measurement*. https://finhealthnetwork.org/research/from-insight-to-impact-the-next-phase-of-financial-health-measurement/

Flores, C. A. R. (2025). Financial freedom of Filipinos in personal finance management. *Pantao: The International Journal of the Humanities and Social Sciences, 4*(1). https://pantaojournal.com/2025/01/27/v4-i1-7/

Hean, O., Saha, U., & Saha, B. (2025). Can AI help with your personal finances? *Applied Economics*. https://doi.org/10.1080/00036846.2025.2450384

IBM. (2025). *Agentic AI in financial services: Navigating innovation*. https://www.ibm.com/think/insights/agentic-ai-financial-services-ethical-adoption

Insurance Commission Philippines. (2025). *Philippine Insurance Market Report 2025*.

Juniper Research. (2026). *Gamification in banking: How game mechanics drive financial behavior change*. [Research report].

Kahneman, D., & Tversky, A. (1979). Prospect theory: An analysis of decision under risk. *Econometrica, 47*(2), 263–292.

Li, Y., et al. (2024). *Large language models in finance (FinLLMs)*. Neural Computing and Applications. https://doi.org/10.1007/s00521-024-10495-6

Li, Z., et al. (2024). *A survey of large language models for financial applications*. arXiv:2406.11903. https://arxiv.org/abs/2406.11903

Liu, X., et al. (2023). *FinGPT: Open-source financial large language models*. arXiv:2306.06031. https://arxiv.org/abs/2306.06031

OpenAI. (2023). *GPT-4 system card*. https://openai.com/research/gpt-4-system-card

Philippine Statistics Authority. (2021). *Family Income and Expenditure Survey (FIES) 2021*. PSA. https://www.psa.gov.ph

Stefanov, T., Stefanova, M., & Varbanova, S. (2024). Personal finance management application. *TEM Journal, 13*(3), 2066–2075. https://doi.org/10.18421/TEM133-34

Thaler, R. H., & Sunstein, C. R. (2008). *Nudge: Improving decisions about health, wealth, and happiness*. Yale University Press.

UNSGSA. (2021). *Measuring financial health: A framework for practitioners*. https://www.unsgsa.org

Warren, E., & Tyagi, A. W. (2005). *All your worth: The ultimate lifetime money plan*. Free Press.

World Economic Forum. (2024). *How agentic AI will transform financial services*. https://www.weforum.org/stories/2024/12/agentic-ai-financial-services-autonomy-efficiency-and-inclusion/

Yang, H., et al. (2023). *FinGPT: Democratizing internet-scale data for financial large language models*. arXiv:2307.10485. https://arxiv.org/abs/2307.10485

---

*SmartSpend v2.9.2 — Lucid Frame*
*Lorma Colleges, CCSE, BSIT 4th Year — 2026–2027, 1st Semester*
*Prepared for: Chapter 2 (Review of Related Literature), Chapter 3 (Methodology) defense preparation, and adviser consultation*
