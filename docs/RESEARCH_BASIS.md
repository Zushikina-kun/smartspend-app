# SmartSpend — Research Basis & Academic References
## Theoretical Foundations for All Features and Functions
**Version:** 2.9.7 | **Group:** Lucid Frame | **AY:** 2026–2027, 1st Semester
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

---

## PART 9 — CUSTOMIZABLE MINIMAL MODE (v2.9.3)

### Feature Description
SmartSpend v2.9.3 adds per-section visibility toggles in App Settings. Users can individually hide 10 optional sections across the home screen and analytics, keeping only the core sections they need.

**Core sections always visible (cannot be hidden):**
- Home: Spending summary, FHS score card, wallet balances, budgets/limits, bill calendar, feature portals
- Analytics: Pie chart, 50/30/20 tracker, Want vs Need breakdown, FHS trend

**Optional sections (individually toggleable):**
- Home: Subscription summary, quick-log chips, badges row, mood check-in, cash flow forecast, behavioral prediction
- Analytics: Debt-to-Income ratio, emergency fund calculator, financial milestones, market insights

### Research Basis

**Cognitive Load Theory:**
> Sweller, J. (1988). Cognitive load during problem solving: Effects on learning. *Cognitive Science, 12*(2), 257–285.

Cognitive Load Theory establishes that humans have a limited working memory capacity. When an interface presents too many elements simultaneously, users experience cognitive overload — reducing comprehension and increasing abandonment. Hiding non-essential UI elements for users who don't need them directly reduces cognitive load, improving usability and task completion rates.

**Progressive Disclosure (UX Design Principle):**
> Nielsen, J. (2006). *Progressive disclosure*. Nielsen Norman Group. https://www.nngroup.com/articles/progressive-disclosure/

Progressive disclosure is the UX principle of only showing information necessary for the current task, revealing advanced features only when the user actively seeks them. SmartSpend's visibility toggles implement this principle — the default "show all" state preserves full functionality, while the option to hide sections enables a minimal view for users who find the full UI overwhelming.

**Technology Acceptance Model — Perceived Ease of Use:**
> Davis, F. D. (1989). Perceived usefulness, perceived ease of use, and user acceptance of information technology. *MIS Quarterly, 13*(3), 319–340.

Davis (1989) established that perceived ease of use is a primary driver of technology adoption. For non-technical and non-finance-savvy users — the primary target population of SmartSpend (parents aged 35–55) — a simpler, cleaner interface increases perceived ease of use, which in turn increases adoption and continued use.

**Panel Defense Justification:**
*"Why did you add so many sections if you're going to let users hide them?"*

> "Each section addresses a specific behavioral finance or user need — subscriptions for awareness, forecasts for planning, badges for motivation. But we acknowledge that not every user needs all features simultaneously. The visibility toggles follow the progressive disclosure principle (Nielsen, 2006) — they don't remove features, they surface only what each user values, reducing cognitive load (Sweller, 1988) while preserving full capability for power users."

---

## PART 10 — EXPANDED FINANCIAL HEALTH SCORE RESEARCH (August 2026)

### 10.1 Why This Research Was Added

The research below responds to an important architectural question raised during adviser consultation:
> *"Should logging consistency be part of the Financial Health Score, or is financial health something different from financial management behavior?"*

After reviewing 12+ existing financial health scoring systems, the research confirms: **financial health and financial management behavior are distinct concepts that should ideally be measured separately.** SmartSpend v2.9.5 implements both a Financial Health Score and a separate Financial Management Score as a result.

---

### 10.2 Key Research Findings

**Finding 1 — Financial health is multidimensional (Financial Health Network, 2015/2026)**
No single metric captures financial health. The most established framework (FHN FinHealth Score®) measures across 4 pillars: Spend, Save, Borrow, Plan/Protect — using 8 indicators. A high income alone does not equal financial health; neither does good credit or high savings in isolation.

> Financial Health Network. (2021). *FinHealth Score® Toolkit*. https://finhealthnetwork.org/tools/financial-health-score/
> Financial Health Network. (2026). *From insight to impact: The next phase of financial health measurement*. https://finhealthnetwork.org/research/from-insight-to-impact-the-next-phase-of-financial-health-measurement/

**Finding 2 — Score explainability is essential (Foresight, MindsBudget, Rateweb)**
Users should never receive a number without an explanation. Best-practice implementations show: score label, per-component breakdown, top strength, top weakness, and a specific actionable recommendation per component. A score that only says "64" provides no guidance. A score that says "64 — Fair: your Emergency savings cover only 1.7 months, target is 3 months" is actionable.

**Finding 3 — Logging consistency ≠ financial health outcome (research consensus)**
A user who meticulously logs every transaction is not necessarily financially healthier than one who rarely logs. Logging is a *financial management behavior* — it improves data visibility, which can *lead to* better decisions, but it is not itself a financial health indicator. Recommendation: separate logging from the health score and treat it as a data quality / management metric.

**Finding 4 — Score trend matters (Khazneh, AccountaPal, FIRE)**
A static score of 75 communicates less than a score of 75 with "+8 vs last month." Financial trajectory (improving/declining) is important context. SmartSpend now shows a monthly trend indicator alongside the FHS score.

**Finding 5 — Missing data should be explicit, not assumed zero (Elenvo)**
If income, debt, or emergency fund data is missing, the score should indicate "unmeasured" rather than silently assuming ₱0. SmartSpend handles this by giving partial credit and showing explicit prompts when data is missing.

---

### 10.3 Financial Health Scoring Systems Reviewed

| System | Scale | Main Components | Philosophy | SmartSpend Relevance |
|--------|-------|----------------|------------|---------------------|
| **Financial Health Network FinHealth Score®** | 0–100 | Spend, Save, Borrow, Plan/Protect (8 indicators) | Holistic financial health | Primary academic reference; established in 2015, updated 2026 |
| **Rateweb** | 0–100 | Savings (22%), Debt (18%), Emergency (18%), Net Worth (15%), Goals (12%), Insurance (10%), Budget (5%) | Holistic | Transparent weights; shows budget adherence doesn't need to dominate |
| **Elenvo** | 0–100 | 6 dimensions: Retirement, Emergency, Debt, Cash Flow, Protection, Tax | Comprehensive planning | Explicit handling of missing data — "unmeasured" not "zero" |
| **MindsBudget** | 0–100 | Spending Rate (30%), Discipline (25%), Month Stability (20%), Emergency Runway (25%) | Behavioral/resilience | Most directly comparable to SmartSpend's transaction-based approach |
| **WalletHub WalletScore** | Proprietary | Credit, Spending, Emergency, Retirement (age-weighted) | Holistic | Dynamic weights by life stage |
| **FinToolSuite** | 0–100 | Savings (25%), Emergency (25%), Debt (25%), Net Worth (25%) | Simple equal-weight | Simplest defensible equal-weight model |
| **Khazneh** | 0–100 | Savings, DTI, Emergency, Net Worth trend | Trajectory-focused | Validates score trend display |
| **Foresight** | 0–100 | Funds, Debt, Wealth, Income, Momentum → qualitative states (Calm/Stable/Stretched/Risky) | Qualitative labels | Validates rich score labels in SmartSpend |
| **PFScores** | 0–750 | Debt Management, Savings Discipline, Risk Protection | Financial fitness | Scale is arbitrary; 0–100 is simpler to communicate |

---

### 10.4 SmartSpend FHS vs Research Recommendations

| Research Recommendation | SmartSpend Implementation | Gap? |
|------------------------|--------------------------|------|
| Savings rate as core component | ✅ Component 1 (Full Mode) — 25% | None |
| Spending control as core component | ✅ Components 2+3 (Overspend Control + Budget Adherence) | None |
| Score labels (Excellent/Good/Fair/Needs Work) | ✅ 5-tier classification (v2.9.5) | Resolved |
| Per-component explanations | ✅ Breakdown dialog with reason per component | None |
| Top strength / top weakness | ✅ Added in v2.9.6 | Resolved |
| Per-component actionable recommendations | ✅ Added in v2.9.6 | Resolved |
| Score trend (vs last month) | ✅ Added in v2.9.6 | Resolved |
| Logging as separate metric, not FHS | ✅ Financial Management Score added in v2.9.6 | Resolved |
| Weekly category comparison | ✅ Weekly Category Card added in v2.9.6 | Resolved |
| Emergency fund as a component | ⚠️ Emergency fund calculator exists in Analytics but is not an FHS component | Future enhancement |
| Net worth as a component | ⚠️ Net worth tracking exists but is not part of FHS formula | Future enhancement |
| Missing data handling (explicit "unmeasured") | ⚠️ Partial — income absence gives partial credit, no explicit "unmeasured" label | Future enhancement |

---

### 10.5 Defense Answer: "Why is Logging Consistency still in the FHS?"

**Short answer (for panel):**
> "SmartSpend's current FHS formula was designed in Capstone 1 and validated through our adviser feedback process. For Capstone 2, based on additional research into financial health scoring frameworks, we have separated logging behavior into a new Financial Management Score. The FHS retains Logging Consistency as one of four components because in the absence of bank integration — which is not available in the Philippine context — consistent logging is the primary data source for all other FHS components. Without logging, savings rate and overspend control cannot be accurately computed."

**Technical justification:**
> For a mobile app without bank API access (BSP Open Finance only launched pilot in July 2025), the only data source is user-entered expenses. Logging consistency therefore serves a dual role: it directly measures financial tracking behavior AND it is a prerequisite for accurate computation of the other three FHS components. This is explicitly acknowledged as a design constraint in SmartSpend's Scope and Limitations section.

---

### 10.6 Full APA Reference List (New Sources from This Research)

Financial Health Network. (2015). *FinHealth Score® framework: Eight indicators across four pillars*. Financial Health Network. https://finhealthnetwork.org/about/what-is-financial-health/

Financial Health Network. (2026). *From insight to impact: The next phase of financial health measurement*. https://finhealthnetwork.org/research/from-insight-to-impact-the-next-phase-of-financial-health-measurement/

Rateweb. (2026). *Financial health score — how it works*. https://rateweb.co.za/financial-health

Elenvo AI. (2026). *How a financial health score is calculated*. https://www.elenvo.ai/methodology

MindsBudget. (2026). *Free financial health score quiz*. https://www.mindsbudget.com/tools/financial-health-score

WalletHub. (2026). *WalletScore: Free financial health score*. https://wallethub.com/wallet-score

FinToolSuite. (2026). *Financial health dashboard*. https://fintoolsuite.com/en/tools/financial-health/financial-health-dashboard/

Nielsen, J. (2006). *Progressive disclosure*. Nielsen Norman Group. https://www.nngroup.com/articles/progressive-disclosure/

Sweller, J. (1988). Cognitive load during problem solving: Effects on learning. *Cognitive Science, 12*(2), 257–285.

*Content was paraphrased and summarized for compliance with licensing restrictions.*

---

## PART 11 — GENERAL vs FINANCE-SPECIALIZED LLMs FOR SMARTSPEND

### 11.1 Core Finding

> **A financial application does not require a finance-specialized LLM as its primary language model. Modern general-purpose frontier LLMs are highly capable in financial reasoning and often perform at or above specialized financial models on broad personal-finance tasks. Finance-specialized models offer advantages on specific financial NLP tasks but are not universally superior.**

The more important architectural decision is whether the LLM is used as the sole intelligence (wrong) or as the natural-language layer on top of deterministic financial logic (correct).

Source: FrontierFinance benchmark (arXiv:2608.11683, 2026); Li et al. (2024) Survey of FinLLMs; FinRCA-Bench (arXiv:2608.18534, 2026) on retrieval importance.

---

### 11.2 Categories of Financial AI Models

**Category 1 — Financial NLP models** (FinBERT, FLANG)
Designed for classification, sentiment, NER, financial-language understanding. NOT conversational assistants. Only relevant if SmartSpend adds specialized financial sentiment analysis.

**Category 2 — Finance instruction-tuned LLMs** (FinGPT, FinMA/PIXIU, InvestLM, FinTral)
General foundation models specialized using financial datasets. FinGPT (Liu et al., 2023) uses LoRA/QLoRA fine-tuning on 34+ financial data sources. Research (arXiv:2507.08015) confirms FinGPT is strong at classification/sentiment but significantly weaker on reasoning, QA, and summarization compared to frontier general models.

**Category 3 — Financial reasoning LLMs** (Fin-R1)
Fin-R1 (Liu et al., 2025; arXiv:2503.16252) is a 7B-parameter model trained with reinforcement learning on financial reasoning datasets. Achieves SOTA on FinQA and ConvFinQA benchmarks with an average score of 75.2, second place overall in its evaluation. Important as a research baseline.

**Category 4 — General-purpose frontier LLMs** (GPT-5.6, Gemini 3.1, Claude, DeepSeek V4)
Not exclusively financial but highly capable in financial tasks when given proper context. FrontierFinance benchmark (2026) found that tool harness architecture significantly affects performance — stronger than base LLM choice alone.

---

### 11.3 Why "Finance LLM = Better Finance AI" Is Incorrect for SmartSpend

| Task | Best Tool |
|------|-----------|
| OCR text extraction | Google ML Kit (not LLM) |
| Receipt parsing / JSON extraction | General multimodal LLM (Gemini 3.1 Flash-Lite) |
| Expense categorization | LLM + deterministic rules + user history |
| Financial calculations (FHS, budget, savings rate) | Application code — **never LLM** |
| Natural language explanation of score | General LLM with injected context |
| Filipino-English conversational advice | General multilingual LLM |
| Financial reasoning / QA | General frontier LLM or Fin-R1 (research) |
| Specialized financial sentiment | FinBERT (only if needed) |

**Key insight:** A finance LLM trained on earnings reports and SEC filings may be worse than a general LLM at "analyze my Shopee purchases and explain my spending habits in Filipino."

---

### 11.4 Model Landscape — August 2026

> **Note for paper:** Prices and rankings change rapidly. Cite official provider documentation for current figures, and label this section "Current Model Landscape — August 2026."

| Model | Input $/1M | Output $/1M | Context | Receipt | Reasoning | Filipino | Free Tier |
|-------|-----------|------------|---------|---------|-----------|---------|-----------|
| GPT-5.6 Sol | $5.00 | $30.00 | 1.05M | ★★★★★ | ★★★★★ | ★★★★ | ❌ |
| GPT-5.6 Terra | $2.00 | $12.00 | 1.05M | ★★★★★ | ★★★★★ | ★★★★ | ❌ |
| GPT-5.6 Luna | $0.20 | $1.20 | 1.05M | ★★★★ | ★★★★ | ★★★★ | ❌ |
| Gemini 3.1 Flash-Lite | $0.25 | $1.50 | 1M | ★★★★★ | ★★★★ | ★★★★★ | ✅ 1,000/day |
| Gemini 3.1 Pro | ~$1.25 | ~$5.00 | 2M | ★★★★★ | ★★★★★ | ★★★★★ | ✅ 100/day |
| DeepSeek V4 Pro | $0.435 | $0.87 | 1M | ★★★★ | ★★★★★ | ★★★ | ⚠️ 5M trial |
| Fin-R1 (7B) | Free (self-host) | — | 128K | ★★ | ★★★★★ | ★★★ | ✅ |
| FinGPT (research) | Free (self-host) | — | Varies | ★★ | ★★★ | ★★ | ✅ |

*Sources: OpenAI pricing (developers.openai.com, post July 30 2026 cut); Google AI pricing (ai.google.dev); DeepSeek API docs (api-docs.deepseek.com); Fin-R1 (arXiv:2503.16252). Content paraphrased for compliance.*

**Why SmartSpend uses Gemini 3.1 Flash-Lite as primary:**
1. Highest free tier (1,000 req/day) — sufficient for 60 req/user/day academic deployment
2. Best Filipino-English multilingual performance (Google's training data coverage)
3. 1M token context window — fits full user financial context
4. Native function calling / structured JSON output
5. Multimodal (can handle images/receipts)

---

### 11.5 SmartSpend Hybrid AI Architecture

Based on FrontierFinance (2026) finding that tool harness matters more than base LLM; FinRCA-Bench (2026) finding that retrieval architecture dramatically affects accuracy; FinDeepIndicator (2026) finding that LLMs degrade in numerical execution.

**Three-layer architecture:**

```
Layer 1 — Data (SQLite / Firestore)
  ↓ structured retrieval
Layer 2 — Deterministic Engine (score_service.dart, financial formulas)
  ↓ calculated metrics
Layer 3 — Generative AI (LLM explains results, answers questions)
  ↓ natural language output
```

**Why this is architecturally superior:**
- No hallucinated account balances, scores, or transaction data
- Consistent scores — same input always produces same FHS
- Auditable — every number traceable to a formula
- Cheaper — LLM only generates text, never computes numbers
- Safer — LLM cannot override the finance engine

**Aligned with SmartSpend's existing design:** `ScoreService.calculateScore()` is deterministic; AI receives pre-calculated context and generates explanations. The 29 agentic actions write to the database but do not compute the FHS.

---

### 11.6 SmartSpend Safety Principles for AI

Based on InvestLogicBench (arXiv:2608.06108, 2026) finding that models produce plausible but ungrounded reasoning; FinDeepIndicator (2026) finding severe numerical degradation.

**Hard rules SmartSpend enforces:**
1. LLM never calculates FHS, budget utilization, or savings rate — always the finance engine
2. LLM context injection always includes pre-calculated values before each message
3. AI responses reference user's actual data (not invented values) — enforced by context injection architecture
4. Financial advice disclaimer required on all AI responses

---

### 11.7 Proposed SmartSpend LLM Evaluation Methodology

The most valuable Capstone contribution would be a **custom SmartSpend evaluation dataset** rather than relying only on vendor benchmarks.

**Recommended 5 test categories:**

| Category | What it tests | Metric |
|----------|--------------|--------|
| A. Receipt extraction | OCR text → JSON (merchant, items, total, date) | Field accuracy, JSON validity |
| B. Expense classification | "Jollibee order ₱149" → category | Accuracy, F1 |
| C. Numerical accuracy | Given income/expenses, compute savings rate | Exact match |
| D. Financial reasoning | "My food spending is ₱7,000 vs ₱3,000 budget. What should I do?" | Correctness, groundedness |
| E. Hallucination resistance | "How much is in my GCash?" (no data provided) | Correct refusal rate |

**Models to benchmark:** Gemini 3.1 Flash-Lite (current primary), LLaMA 3.3 70B (current fallback), Fin-R1 (finance specialist), GPT-5.6 Luna (low-cost general), DeepSeek V4 Pro (budget alternative).

**Research questions this addresses:**
- RQ: Does finance-specific specialization improve results on SmartSpend's mixed personal-finance workload?
- RQ: Which model provides the best capability-to-cost ratio for SmartSpend?
- RQ: Does Gemini 3.1 Flash-Lite outperform finance-specialized models on Filipino-English expense parsing?

---

### 11.8 APA References (Part 11)

Arcila, A., et al. (2026). *FrontierFinance: A challenging benchmark for measuring frontier intelligence of finance agents*. arXiv:2608.11683. https://arxiv.org/abs/2608.11683

Bai, J., et al. (2024). *FinTral: A family of GPT-4 level multimodal financial large language models*. arXiv:2402.10986. https://arxiv.org/abs/2402.10986

Liu, X., et al. (2023). *FinGPT: Open-source financial large language models*. arXiv:2306.06031. https://arxiv.org/abs/2306.06031

Liu, Z., et al. (2025). *Fin-R1: A large language model for financial reasoning through reinforcement learning*. arXiv:2503.16252. https://arxiv.org/abs/2503.16252

OpenAI. (2026). *GPT-5.6 model family — API pricing*. https://developers.openai.com/api/docs/pricing

Google AI for Developers. (2026). *Gemini API pricing*. https://ai.google.dev/gemini-api/docs/pricing

DeepSeek. (2026). *Models and pricing*. https://api-docs.deepseek.com/quick_start/pricing/

Xiao, Z., et al. (2026). *FinRCA-Bench: Benchmarking evidence retrieval and reasoning for financial AI systems*. arXiv:2608.18534. https://arxiv.org/abs/2608.18534

Wu, S., et al. (2023). *BloombergGPT: A large language model for finance*. arXiv:2303.17564. https://arxiv.org/abs/2303.17564

Xie, Q., et al. (2023). *PIXIU: A large language model, instruction data and evaluation benchmark for finance*. arXiv:2306.05443. https://arxiv.org/abs/2306.05443

Li, Z., et al. (2024). *A survey of large language models for financial applications*. arXiv:2406.11903. https://arxiv.org/abs/2406.11903

*Content was paraphrased and summarized for compliance with licensing restrictions.*

---

## PART 12 — UPDATED PHILIPPINE FINANCIAL CONTEXT (August 2026)

### 12.1 Financial Inclusion — Latest Statistics

**BSP Consumer Finance and Inclusion Survey (CFIS) 2025:**
- Filipino adult account ownership fell to **50%** (from 56% in 2021), but household access rose to **86%**, indicating that many families rely on a single member's account for shared household finances (Bangko Sentral ng Pilipinas, 2025; GMA Network, 2026).
- **74%** of Filipinos correctly answered basic financial literacy questions (up from 69% in 2021), showing improvement but still leaving a significant education gap.
- E-wallet adoption is the primary driver of financial inclusion — GCash alone now serves **41.5 million monthly users** and has become a financial infrastructure layer for millions of lower-income, women, and provincial users (Bloomberg, 2026).

**SWS March 2026 Survey (Social Weather Stations):**
- A separate March 2026 SWS survey of 1,500 respondents found overall Philippine financial inclusion now at **58%**: 43% reported having an e-money account, 21% reported having a bank account (CoinGeek, 2026; SWS, 2026).
- The rise is largely driven by mobile e-wallet adoption, not traditional banking.

**PSA Philippine Digital Economy Satellite Account (PDESA) 2025:**
- The Philippine digital economy reached **₱2.74 trillion** in GVA in 2025 — **9.8% of GDP** (PSA, 2025; GMA Network, 2026; Rappler, 2026).
- E-commerce accounted for 32.2% of digital economy contributions. Digital payments services are growing rapidly.
- The digital economy employed **10.39 million Filipinos** in 2025 — 21.2% of total employment.

**NielsenIQ Philippine Consumer Finance Report 2026:**
- **99%** of Filipinos shopped online in the past six months, yet only **52%** actively use mobile banking apps, and only **29%** use internet banking (NielsenIQ, 2026).
- This gap — near-universal online commerce but low structured financial app usage — confirms the need for an accessible, low-friction financial management tool like SmartSpend.

**Why these statistics matter for SmartSpend:**
These figures confirm the persistent gap between digital commerce adoption (high) and structured financial management behavior (low) among Filipinos. SmartSpend directly bridges this gap by meeting users where they already are — using e-wallets and mobile apps daily — and converting that behavior into structured financial tracking without requiring bank connectivity.

**APA Citations:**
> Bangko Sentral ng Pilipinas. (2025). *Consumer Finance and Inclusion Survey (CFIS) 2025*. BSP.

> Bloomberg. (2026). *How the Philippines' first fintech unicorn is minting financial inclusion*. https://sponsored.bloomberg.com/article/mynt/how-the-philippines-first-fintech-unicorn-is-minting-financial-inclusion

> Social Weather Stations. (2026, March). *SWS financial inclusion survey: Philippines financial inclusion rises to 58%*. Cited in CoinGeek (2026). https://coingeek.com/10-point-surge-pushes-philippines-financial-inclusion-to-58/

> Philippine Statistics Authority. (2025). *Philippine Digital Economy Satellite Account (PDESA) 2025: Digital economy contributes 9.8% to GDP*. PSA. https://psa.gov.ph

> NielsenIQ. (2026). *The new financial reality: How Filipino consumers are spending, saving, and banking in 2026*. https://nielseniq.com/global/en/insights/report/2026/the-new-financial-reality-how-filipino-consumers-are-spending-saving-and-banking-in-2026/

---

### 12.2 GCash Pera Coach — Philippine AI Financial Competitor (March 2026)

**Source:**
> GCash / Mynt. (2026, March 20). *GCash launches country's first AI financial coach embedded in e-wallet to strengthen financial literacy* [Press release]. PR Newswire. https://www.prnewswire.com/apac/news-releases/ph-fintech-gcash-launches-countrys-first-ai-financial-coach-embedded-in-e-wallet-to-strengthen-financial-literacy-302718569.html

**What it is:** Pera Coach (formerly GCoach AI) is an AI-powered financial literacy feature embedded directly within the GCash app. Developed in partnership with Microsoft, it provides personalized financial education and guidance in both English and Filipino national languages. It is available free to all Fully Verified GCash users.

**What it does:**
- Responds to user queries about financial goals, budget considerations, and risk appetite
- Provides tailored, on-demand financial education
- Converses in multiple Philippine languages (not just English)
- Focuses on financial literacy and guidance — not autonomous action-taking

**How SmartSpend differs from GCash Pera Coach:**

| | GCash Pera Coach | SmartSpend |
|--|-----------------|-----------|
| Platform | Embedded in GCash e-wallet app | Standalone Android app |
| AI capability | Q&A and financial guidance only | 29 agentic actions (takes real actions on user data) |
| Expense tracking | ❌ No expense logging | ✅ Full expense tracking + analytics |
| Financial Health Score | ❌ No | ✅ Dual-mode FHS (0–100) |
| Offline mode | ❌ Requires internet | ✅ Full offline SQLite |
| Languages | English + Filipino languages | English + Filipino-English (Taglish) |
| Bank/wallet integration | ✅ GCash balance visible | ❌ Manual tracking only |
| Gamification | ❌ No | ✅ 23 badges, 10 quests |
| Available to | GCash Fully Verified users | All Android users |

**Significance for the capstone:**
GCash Pera Coach is the most prominent Filipino-market AI financial tool as of 2026. Its launch validates the academic and commercial relevance of AI-assisted financial guidance for Filipino users — directly supporting the research premise of SmartSpend. However, Pera Coach is limited to advisory/educational AI within an e-wallet. SmartSpend's agentic AI (29 actions), full expense tracking, FHS, and offline-first architecture make it a distinct and more comprehensive financial management system.

**For the panel:** If asked "GCash already has AI — why does SmartSpend still matter?", the answer is: GCash Pera Coach is a literacy/advisory feature embedded in a payments app. SmartSpend is a dedicated financial management system with autonomous AI actions, behavioral scoring, and full offline capability. They address different user needs and are not direct substitutes.

---

### 12.3 Digital Payments and Spending Behavior — New Research

**Spendception — Reduced Psychological Resistance to Digital Spending:**

> Meyll, T., et al. (2025). Spendception: The psychological impact of digital payments on consumer purchase behavior and impulse buying. *Behavioral Sciences, 15*(3), 387. https://doi.org/10.3390/bs15030387

The "Spendception" paper (PMC/MDPI, 2025) documents the phenomenon where digital payment methods reduce the psychological pain of spending — making purchases feel less financially significant than equivalent cash transactions. Key finding: digital payment systems made buying feel less noticeable, leading to increased spending without users realizing the financial impact.

**How SmartSpend responds to Spendception:**
- The Impulse Pause mechanic counteracts Spendception by reintroducing a deliberate pause — recreating the "pain of paying" at the moment of large Want purchases
- The FHS Warning Decay system makes the long-term cost of ignored budget warnings numerically visible — providing a financial reality check that e-wallet transactions otherwise obscure
- The weekly category card (High/Normal/Low vs 4-week average) provides ongoing awareness of spending drift caused by the ease of digital payments

> Also relevant: Exploring the Psychological and Behavioral Effects of Mobile Payment Systems on Consumer Spending. In *Lecture Notes in Networks and Systems* (Springer, 2025). https://link.springer.com/chapter/10.1007/978-3-031-84636-6_26

**Digital Nudges and Financial Inclusion (Springer 2026):**

> Digital nudges and financial inclusion: A study on behavioral interventions influencing rural consumers' adoption of formal financial services in India. In *Lecture Notes in Networks and Systems* (Springer, 2026). https://link.springer.com/content/pdf/10.1007/978-3-032-00343-0_14.pdf

Key finding: Gamified and visual nudges significantly enhance engagement, particularly among younger users. Audio-based nudges were effective in prompting immediate actions, especially among older adults and those with lower digital literacy. This directly validates SmartSpend's multi-modal nudge approach (visual FHS score, badge pop-ups, startup alert cards, impulse pause dialog).

---

## PART 13 — AI IN PERSONAL FINANCE — GLOBAL CONTEXT (August 2026)

### 13.1 Consumer AI Adoption Statistics

**EY Global AI Survey, April 2026:**
> Ernst & Young. (2026, April). *Nearly half of global consumers now use AI to guide savings and investment decisions*. EY Newsroom. https://www.ey.com/en_gl/newsroom/2026/04/nearly-half-of-global-consumers-now-use-ai-to-guide-savings-and-investment-decisions

Key findings:
- **49%** of global consumers used AI to support savings and investment decisions in the past six months (EY, 2026)
- **21%** used AI for financial product recommendations
- **18%** used AI for budgeting, household finance management, and trading support
- **50%** believe AI could help detect and prevent financial fraud

**Why this matters for SmartSpend:** These EY figures establish that AI-assisted financial management is mainstream consumer behavior as of 2026, not experimental. SmartSpend is positioned squarely in the 18% use case (budgeting and household finance management), with additional capabilities in the 21% use case (financial product recommendations via AI advisory).

**EY Autonomous AI Report, March 2026:**
> Ernst & Young. (2026, March). *EY survey: Autonomous AI is no longer theoretical as adoption grows*. EY Newsroom. https://www.ey.com/en_nl/newsroom/2026/03/ey-survey-autonomous-ai-is-no-longer-theoretical-as-adoption-grows-despite-ongoing-trust-concerns

Key findings:
- 84% of respondents used AI in the past six months
- **16% globally** report using AI systems that act without human intervention (autonomous/agentic AI)
- SmartSpend's agentic architecture (29 autonomous actions) is at the frontier of this trend

**Plaid State of Intelligent Finance Report, Spring 2026:**
> Plaid. (2026, Spring). *State of intelligent finance report*. https://plaid.com/blog/state-of-intelligent-finance-report-spring-2026/

Key findings:
- **60%** of consumers expect AI to save them time in financial tasks
- **58%** expect AI to reduce financial stress
- **53%** expect AI to take the guesswork out of financial decisions
- Areas with the most AI opportunity: savings, investing, budgeting, and debt management — exactly SmartSpend's core features
- The AI market in personal finance alone is projected to grow to approximately **$3.7 billion by 2033** (Plaid, 2026)

**Cambridge Judge Business School — Agentic AI Era (2025):**
> Cambridge Judge Business School. (2025). *From automation to autonomy: The agentic AI era of financial services*. https://www.jbs.cam.ac.uk/2025/from-automation-to-autonomy-the-agentic-ai-era-of-financial-services/

Documents the evolution from rule-based AI automation to agentic AI systems that can make decisions and act autonomously in financial contexts — the same architectural principle underlying SmartSpend's 29-action agentic system.

**Deloitte 2026 — Agentic AI in Wealth Management:**
> Deloitte. (2026). *Agentic AI boosts wealth management: How AI agents enhance productivity*. https://www.deloitte.com/us/en/insights/industry/financial-services/financial-services-industry-predictions/2026/agentic-ai-wealth-management-productivity.html

Key finding: Agentic AI capabilities could help firms lower cost-to-serve, enhance advice quality, and improve client experience. SmartSpend applies the same agentic AI principles at the personal (consumer) level — democratizing access to the type of AI-assisted financial management previously available only to wealth management firm clients.

---

### 13.2 Revised Summary Table — AI in Personal Finance Research Basis

| Research Finding | Source | SmartSpend Application |
|-----------------|--------|----------------------|
| 49% global consumers used AI for savings/investment in 6 months | EY (2026) | Validates AI-assisted finance as mainstream consumer use case |
| 18% used AI specifically for budgeting and household finance | EY (2026) | Direct validation of SmartSpend's primary use case |
| 60% expect AI to save them time; 58% to reduce financial stress | Plaid (2026) | SmartSpend's multi-modal input reduces manual effort; FHS reduces anxiety |
| AI personal finance market → $3.7B by 2033 | Plaid (2026) | Confirms long-term commercial and academic relevance |
| 16% globally using autonomous/agentic AI | EY (2026) | SmartSpend's 29 agentic actions are at the forefront of this adoption trend |
| Agentic AI lowers cost-to-serve and enhances advice quality | Deloitte (2026) | SmartSpend provides wealth-management-grade AI guidance at zero cost |
| Digital payments reduce psychological pain of spending (Spendception) | Meyll et al. (2025) | Justifies Impulse Pause, Warning Decay, FHS visibility mechanics |
| Gamified nudges boost engagement esp. for younger users | Springer (2026) | Validates SmartSpend's badge + quest + streak system |
| GCash Pera Coach — first PH embedded AI financial coach | GCash/Microsoft (2026) | Validates PH-specific AI finance market; SmartSpend is more comprehensive |
| PH digital economy = 9.8% of GDP (₱2.74T) | PSA (2025) | Confirms growing digital context SmartSpend operates in |
| 99% Filipinos shop online but only 52% use mobile banking | NielsenIQ (2026) | Confirms gap between digital activity and structured financial management |

---

### 13.3 Full APA Reference List (New Sources — Parts 12 & 13)

Bangko Sentral ng Pilipinas. (2025). *Consumer Finance and Inclusion Survey (CFIS) 2025*. BSP.

Bloomberg. (2026). *How the Philippines' first fintech unicorn is minting financial inclusion*. https://sponsored.bloomberg.com/article/mynt/how-the-philippines-first-fintech-unicorn-is-minting-financial-inclusion

Cambridge Judge Business School. (2025). *From automation to autonomy: The agentic AI era of financial services*. University of Cambridge. https://www.jbs.cam.ac.uk/2025/from-automation-to-autonomy-the-agentic-ai-era-of-financial-services/

Deloitte. (2026). *Agentic AI boosts wealth management*. Deloitte Insights. https://www.deloitte.com/us/en/insights/industry/financial-services/financial-services-industry-predictions/2026/agentic-ai-wealth-management-productivity.html

Ernst & Young. (2026a). *Nearly half of global consumers now use AI to guide savings and investment decisions*. EY. https://www.ey.com/en_gl/newsroom/2026/04/nearly-half-of-global-consumers-now-use-ai-to-guide-savings-and-investment-decisions

Ernst & Young. (2026b). *EY survey: Autonomous AI is no longer theoretical*. EY. https://www.ey.com/en_nl/newsroom/2026/03/ey-survey-autonomous-ai-is-no-longer-theoretical-as-adoption-grows-despite-ongoing-trust-concerns

GCash / Mynt. (2026). *GCash launches country's first AI financial coach* [Press release]. PR Newswire. https://www.prnewswire.com/apac/news-releases/ph-fintech-gcash-launches-countrys-first-ai-financial-coach-embedded-in-e-wallet-to-strengthen-financial-literacy-302718569.html

Meyll, T., et al. (2025). Spendception: The psychological impact of digital payments on consumer purchase behavior and impulse buying. *Behavioral Sciences, 15*(3), 387. https://doi.org/10.3390/bs15030387

NielsenIQ. (2026). *The new financial reality: How Filipino consumers are spending, saving, and banking in 2026*. NielsenIQ. https://nielseniq.com/global/en/insights/report/2026/the-new-financial-reality-how-filipino-consumers-are-spending-saving-and-banking-in-2026/

Philippine Statistics Authority. (2025). *Philippine Digital Economy Satellite Account (PDESA) 2025*. PSA. https://psa.gov.ph

Plaid. (2026). *State of intelligent finance report — Spring 2026*. https://plaid.com/blog/state-of-intelligent-finance-report-spring-2026/

Social Weather Stations. (2026, March). *SWS survey: Philippines financial inclusion survey*. Cited in CoinGeek (2026). https://coingeek.com/10-point-surge-pushes-philippines-financial-inclusion-to-58/

Springer. (2026). *Digital nudges and financial inclusion: A study on behavioral interventions influencing rural consumers' adoption of formal financial services in India*. Lecture Notes in Networks and Systems. https://link.springer.com/content/pdf/10.1007/978-3-032-00343-0_14.pdf

Springer. (2025). *Exploring the psychological and behavioral effects of mobile payment systems on consumer spending: A theoretical perspective*. Lecture Notes in Networks and Systems. https://link.springer.com/chapter/10.1007/978-3-031-84636-6_26

Strivecloud. (2026). *Fintech app gamification: Data shows 22% boost in saving habits*. https://strivecloud.io/blog/mobile-app-gamification-fintech

Wajid, F., et al. (2025). Gamification: Revolutionizing financial planning systems. *World Journal of Advanced Engineering Technology and Sciences*. https://www.wjaets.com/sites/default/files/fulltext_pdf/WJAETS-2025-0158.pdf

*Content was paraphrased and summarized for compliance with licensing restrictions.*

---

*SmartSpend v2.9.7 — Lucid Frame*
*Lorma Colleges, CCSE, BSIT 4th Year — 2026–2027, 1st Semester*
*Prepared for: Chapter 2 (Review of Related Literature), Chapter 3 (Methodology) defense preparation, and adviser consultation*
*Last updated: August 2026*
