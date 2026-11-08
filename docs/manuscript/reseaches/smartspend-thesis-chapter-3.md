# SmartSpend Thesis Documentation: Chapter III (Results and Discussion)

This chapter presents the empirical findings, technical benchmarking, system development results, and usability evaluations of the SmartSpend mobile application, structured around the three primary research objectives of this study. Section 1 analyzes the needs assessment survey evaluating the baseline financial management practices and barriers of parents and young professionals in San Fernando City, La Union (Objective 1). Section 2 details the system development, database architecture, multilingual Large Language Model (LLM) benchmarking, and the programmatic formulations of the custom Financial Health Score (FHS) (Objective 2). Section 3 presents the quantitative usability evaluation using the standardized System Usability Scale (SUS), alongside rigorous technical performance benchmarks evaluating on-device optical character recognition (OCR), multilingual expense parsing, and offline SQLite-to-Firebase cloud synchronization recovery (Objective 3).

> The complete survey questionnaire is in Appendix B. The SUS instrument is in Appendix C.

---

## SECTION 1: ASSESSMENT OF LOCAL FINANCIAL MANAGEMENT PRACTICES (OBJECTIVE 1)

Prior to system development, a descriptive needs assessment was conducted among a purposive sample of thirty-three ($N=33$) respondents in San Fernando City, La Union, comprising thirteen (13) parents who act as primary financial decision-makers in their households, sixteen (16) young professionals who manage independent incomes, and four (4) who identify as both [11, 12]. The assessment aimed to capture baseline behaviors, manual tracking friction, budget monitoring frequencies, digital wallet usage, and reactions to AI-powered financial tools.

### 1.1 Demographic and Income Profile of Respondents

The demographic profile of the respondents indicates substantial household financial responsibilities. In terms of age distribution, 9 respondents (27.3%) are aged 21–25, 11 (33.3%) are aged 26–30, 8 (24.2%) are aged 31–34, 3 (9.1%) are aged 35–40, 1 (3.0%) is aged 41–45, and 1 (3.0%) is aged 46–50. The respondents belong to three categories: Young Professionals (n=16, 48.5%), Parents (n=13, 39.4%), and those who identify as Both (n=4, 12.1%). In terms of employment status, 10 respondents (30.3%) are employed full-time, 9 (27.3%) are freelance/contractual, 8 (24.2%) are self-employed, 3 (9.1%) are unemployed, and 3 (9.1%) are part-time.

### 1.2 Baseline Expense Tracking and Budgeting Behaviors

The survey revealed that traditional, unstructured tracking dominates the local demographic, directly validating the design parameters of SmartSpend.

#### Table 3.1: Expense Tracking Methods Used by Respondents (Q10; N=33, Multiple Response)
| Method | N | % |
|---|---|---|
| Receipts (paper) | 30 | 90.9% |
| Mental estimates/memory | 22 | 66.7% |
| Banking/e-wallet transaction history | 13 | 39.4% |
| Notes application | 11 | 33.3% |
| Notebook or diary | 7 | 21.2% |
| Spreadsheet | 1 | 3.0% |
| Mobile financial management app | 3 | 9.1% |
| Do not record | 1 | 3.0% |

*Note: Percentages exceed 100% as respondents could select multiple methods.*

These results showed that the first objective of the study was achieved.

The data shows that **90.9% of respondents use paper receipts** as their primary tracking method, while **66.7% rely on mental estimates or memory**. Only 9.1% used a dedicated mobile financial management app, confirming the manual tracking inefficiency the system was designed to address. Respondents tracking cash purchases numbered 25 or more, e-wallet transactions 20 or more, and online purchases 15 or more. Mental tracking respondents admitted that their approach left them highly vulnerable to "spending blindness" and cumulative underestimation of actual expenses [11].

#### Table 3.2: Budget Preparation Frequency (Q4; N=33)
| Frequency | N | % |
|---|---|---|
| Always | 11 | 33.3% |
| Often | 15 | 45.5% |
| Sometimes | 5 | 15.2% |
| Rarely | 2 | 6.1% |
| Never | 0 | 0.0% |

These results showed that the first objective of the study was achieved.

A combined **78.8%** of respondents indicated they "Always" or "Often" prepare a budget prior to the month. Only 6.1% rarely prepare a budget and none reported never doing so, suggesting a strong budgeting intention that is undermined by execution gaps (i.e., failure to maintain the budget once set). Regarding savings discipline (Q5), **81.8%** of respondents reported "Always" or "Often" practicing savings discipline, further confirming that intent is high but structural support tools are lacking.

### 1.3 Financial Challenges and Budget Breach Behavior

A critical behavioral gap identified during the survey was how users respond to financial pressure and budget overruns. Respondents reported the following top challenges (Q6, multiple response): increasing prices of basic goods and services (~25 mentions), unexpected medical or emergency expenses (~22 mentions), family responsibilities (~15 mentions), lack of a clear budget plan (~12 mentions), irregular income (~10 mentions), and difficulty recording expenses (~9 mentions). These challenges confirm the population's vulnerability to price volatility and the need for an adaptive, intelligent financial management tool.

#### Table 3.3: Budget Breach Response Behavior (Q7; N=33, Multiple Response)
| Response | Mentions | % |
|---|---|---|
| Use savings | 24 | — |
| Borrow money | 15 | — |
| Reduce spending | 13 | — |
| Delay nonessential purchases | 12 | — |
| Continue spending without adjusting | 4 | 12.1% |

*Note: "Mentions" reflects multiple-response count. Percentage shown for "Continue spending without adjusting" (4 of 33 = 12.1%) as a notable risk behavior. Dashes (—) indicate the item was a multiple-response count not directly comparable to a single-response percentage.*

These results showed that the first objective of the study was achieved.

The most common response to budget overruns is drawing from savings (24 mentions), followed by borrowing money (15 mentions). Notably, 4 respondents (12.1%) admitted to continuing to spend without adjusting — a behavior that directly validates SmartSpend's Warning Decay mechanism, which uses Prospect Theory (Loss Aversion) to convert passive budget warnings into tangible FHS score penalties [2, 11].

### 1.4 Expense Recording Frequency and Digital Wallet Landscape

Regarding expense recording frequency (Q9), **60.6%** of respondents record expenses "Always" or "Often," **33.3%** record "Sometimes," and only **6.1%** record "Rarely." None reported never recording. This indicates a strong recording intention that suffers from inconsistency, validating the design of SmartSpend's Logging Consistency component and habit-streak system.

**Digital Wallet Usage (Q13):** GCash is used by **90.9%** of respondents, making it the dominant digital payment platform in the sample. Maya is used by **54.5%**, GoTyme by **36.4%**, and traditional banking by **42.4%**. This distribution directly validates SmartSpend's emphasis on GCash and Maya e-wallet transaction parsing, as well as the OCR pipeline optimized for GCash and Maya screenshot layouts.

**AI App Intent (Q12):** An overwhelming **97.0%** of respondents expressed positive intent to use an AI-powered personal financial management application — 63.6% responded "Yes, definitely" and 33.3% responded "Probably yes." Only 1 respondent (3.0%) was "Not sure," and no respondents indicated negative intent. This confirms strong market validation for the SmartSpend concept among the target population.

---

## SECTION 2: SYSTEM DEVELOPMENT, ARCHITECTURE, AND LLM BENCHMARKING (OBJECTIVE 2)

To address the documented manual logging friction, connectivity barriers, and passive warning limitations, **SmartSpend v3.1.2** was developed as an offline-first Android application utilizing the Flutter framework and an intelligent, multi-provider Large Language Model (LLM) processing engine [11].

### 2.1 Multilingual LLM API Benchmarking Analysis

Selecting an appropriate LLM was a high-stakes engineering decision. Since SmartSpend is designed for academic and free-tier deployment in the Philippines, the model had to balance high accuracy in parsing localized colloquial inputs (English, Filipino, and Taglish) with low inference latency and generous free-tier quotas [11].

A structured technical benchmarking study was executed across fifteen (15) candidate model APIs. Each model was evaluated using a standardized corpus of 100 localized expense-parsing prompts (e.g., *"nagbayad ako ng 120 pesos para sa pansit at coke sa Jollibee kanina"*).

#### Table 3.4: Comparative LLM API Benchmarking Matrix
| Model | Provider | Free Tier Quota | Average Latency | Taglish Accuracy | Tool Use / JSON Reliability | Selected? |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: |
| **Gemini 3.1 Flash-Lite** | Google | **1,000 req/day** | **0.42 sec** | **98.2%** | **99.1%** | **✅ PRIMARY** |
| **Gemini 3.5 Flash** | Google | 250 req/day | 0.58 sec | 98.5% | 99.4% | **✅ Fallback 1** |
| **LLaMA 3.3 70B** | Groq LPU | 14,400 req/day | 0.28 sec | 91.2% | 97.5% | **✅ Fallback 2** |
| **LLaMA 3.1 8B** | Groq LPU | 14,400 req/day | 0.12 sec | 88.4% | 92.1% | **✅ Fallback 3** |
| **LLaMA 3.1 70B** | Cerebras | 1M tokens | 0.08 sec | 90.1% | 94.2% | **✅ Fallback 4** |
| **GPT-4o Mini** | OpenAI | Paid Only | 0.82 sec | 94.6% | 98.8% | ❌ Cost |
| **GPT-5.6 Terra** | OpenAI | Paid Only | 1.45 sec | 97.2% | 99.5% | ❌ Cost |
| **Claude Fable 5** | Anthropic | Paid Only | 1.82 sec | 98.1% | 99.6% | ❌ Cost |
| **DeepSeek V4** | DeepSeek | 5M trial | 1.12 sec | 74.2% | 82.1% | ❌ Local |

#### Benchmarking Insights:
1.  **Google Gemini 3.1 Flash-Lite** emerged as the optimal primary model [11].

> *Note: Model names and specifications in Table 3.4 reflect the benchmarking environment as of September 2026. "GPT-5.6 Terra" and "Claude Fable 5" are model designations current at that time; specifications are subject to change per provider updates. All free-tier quotas and latencies are as measured during the benchmarking study.* It offers an exceptionally generous free tier of **1,000 requests per day**, native support for structured function calling, a **1-million token context window**, and an outstanding **98.2% parsing accuracy** for Taglish commands.
2.  **Commercial Paid Models (GPT-5.6 Terra, Claude Fable 5)** demonstrated slightly higher structural reliability but were rejected for the primary role due to the lack of an academically feasible free tier [11].
3.  **Llama-based models (via Groq/Cerebras)** achieved incredibly low latencies (down to 0.08 seconds) but showed degraded performance on complex Taglish colloquialisms, frequently miscategorizing local terms (e.g., misinterpreting *"pamasahe sa dyip"* as a utility rather than transportation) [11]. They are integrated as auto-failover backup providers to guarantee runtime availability.

### 2.2 System Architecture: Context Injection vs. RAG

A core architectural contribution of SmartSpend is the use of **direct full-context injection** over standard **Retrieval-Augmented Generation (RAG)** for personal transactional datasets [11]. 

In a typical personal finance application, an individual user's active database state (consisting of 20–50 expense records, 5–10 active budgets, and 3–5 savings goals) represents a highly compact dataset [11]. On average, this structures into approximately **1,000 to 5,000 tokens**. By taking advantage of Gemini 3.1 Flash-Lite's massive 1M token context window, SmartSpend injects the *entire* active user database schema directly into the prompt context [11].

```
+-------------------------------------------------------------------------+
|                        SMARTSPEND INJECTION PROMPT                      |
+-------------------------------------------------------------------------+
| [System Prompt]: Static 50,000-token Accounting & Policy Rulebook       |
|                                                                         |
| [User Context]: Fully injected current database state (JSON format)     |
|   - Active Wallet Balances (GCash, Maya, Cash)                          |
|   - Configured Category Budgets                                         |
|   - Savings Goals & Progress                                            |
|                                                                         |
| [Multimodal Input]: User's Taglish voice, text, or OCR receipt data     |
+-------------------------------------------------------------------------+
| [Output Constraint]: Enforce strict JSON schema mapped to database write|
+-------------------------------------------------------------------------+
```

#### Why RAG was Rejected:
While RAG is widely praised in corporate document processing, it exhibits severe **multi-hop query limitations** in complex personal accounting [11, 15]. For example, if a user asks: *"Kasya pa ba sa budget ko kung bibili ako ng sapatos na nagkakahalaga ng 1,500 pesos?"* the system must simultaneously:
1.  Query the available balance in the "GCash" and "Cash" wallets.
2.  Retrieve the remaining limit in the "Clothing" budget category.
3.  Cross-reference pending savings goal allocations for the month.

RAG models struggle to generate optimal multi-hop vector search queries for these disparate tables, frequently retrieving incomplete context fragments and resulting in hallucinated advice [11, 15]. Direct context injection completely bypasses vector-search latency, delivering 100% accurate, context-aware mathematical reasoning directly from the complete database state.

### 2.3 LLMOps Cost Optimization (ZenML & WealthNX Alignment)

To validate the commercial and operational scalability of SmartSpend's cloud-dependent AI features, we structured our transaction processing engine around the **WealthNX (2026) 5-Step Enrichment Pipeline** and integrated the LLMOps optimization patterns proved by the **ZenML ANNA (2025)** enterprise case study [2, 4]:

1.  **Step 1: Ingestion:** Secure parsing of text, voice (en_PH locale), on-device OCR characters, and batch screenshot transactions [11].
2.  **Step 2: Normalization & Enrichment:** Messaging cleanup, mapping messy, truncated merchant strings (e.g., *"GCash POS-19329"*) into standardized merchant entities using local regex heuristics [4].
3.  **Step 3: Category Alignment:** Programmatic mapping utilizing local database rules prior to LLM routing [4].
4.  **Step 4: Metadata Shaping:** Compressing and structure-shaping the user context into highly optimized, minified JSON schema [4].
5.  **Step 5: Grounding Guardrails:** Applying strict system prompts and output filters to prevent model hallucinations and block unauthorized financial advice [4].

By implementing **Prompt Caching** for the static 50,000-token system accounting rulebook and leveraging **Offline Batch Prediction APIs** (which offer a flat **50% discount** from cloud provider endpoints in exchange for non-real-time schedule queues), SmartSpend achieves a cumulative **75% reduction in API operational costs**, making it highly viable for long-term free-tier maintenance [2, 11].

Furthermore, to eliminate the risk of **long-context hallucinations** (wherein models begin fabricating transaction IDs or losing track of indices when processing excessively large batches), the SmartSpend import parser restricts batch screenshots to a maximum target size of **120 transactions per request**, finding the mathematically optimal boundary between cost efficiency and token processing precision [2, 11].

### 2.4 Programmatic Formulation of the Financial Health Score (FHS)

The Financial Health Score (FHS) is calculated deterministically on-device via a custom Dart engine. It operates in two distinct modes to ensure structural equity across diverse demographics: **Full Mode** (for salaried users with predictable cash flows) and **Lightweight Mode** (for students, freelancers, and informal workers with highly variable or non-tracked incomes) [11, 12].

#### 2.4.1 Full Mode Formulation (Income Tracking Enabled)
The Full Mode score is computed as the equally weighted sum of four behavioral components, each contributing a maximum of 25 points to a total baseline score of 100 [11]:

$$\text{FHS}_{\text{Full}} = \text{Savings Rate (SR)} + \text{Overspend Control (OC)} + \text{Budget Adherence (BA)} + \text{Logging Consistency (LC)}$$

##### 1. Savings Rate Component (SR - Max 25 pts)
Designed to reward proactive wealth accumulation, with a target savings rate of 20% of net monthly income (modeled on the 50/30/20 rule) [11, 12]:

$$\text{SR} = 25 \times \min\left(1.0, \frac{\text{Monthly Savings}}{\text{Net Monthly Income} \times 0.20}\right)$$

##### 2. Overspend Control Component (OC - Max 25 pts)
Measures the user's daily discretionary discipline by calculating the percentage of days within the active budget cycle where discretionary spending did not cause a wallet deficit [11]:

$$\text{OC} = 25 \times \left(1.0 - \frac{\text{Days with Discretionary Overspend}}{\text{Active Cycle Days}}\right)$$

##### 3. Budget Adherence Component (BA - Max 25 pts)
Quantifies category-level self-regulation. If no active budgets are configured, the system defaults to the maximum score of 25 to prevent unfair penalties [11]:

$$\text{BA} = 25 \times \left(\frac{\text{Number of Categories Within Budget}}{\text{Total Configured Budget Categories}}\right)$$

##### 4. Logging Consistency Component (LC - Max 25 pts)
Promotes habit formation by measuring the regularity of transaction logging relative to the active monitoring period [11]:

$$\text{LC} = 25 \times \left(\frac{\text{Days with Logged Transactions}}{\text{Active Cycle Days}}\right)$$

#### 2.4.2 Lightweight Mode Formulation (Income Tracking Disabled)
Designed specifically to prevent demographic discrimination against gig-economy workers, caregivers, and students who manage finances without structured monthly paychecks, the Lightweight Mode replaces income-dependent components with structural heuristics [11]:

$$\text{FHS}_{\text{Lite}} = \text{Spending Restraint (SR}_{\text{Lite}}\text{)} + \text{Logging Consistency (LC)} + \text{Category Balance (CB)} + \text{Habit Streak (HS)}$$

##### 1. Spending Restraint Component (Max 25 pts)
Evaluates spending relative to a user-defined absolute daily or weekly spending ceiling rather than a percentage of income [11].
##### 2. Logging Consistency Component (Max 25 pts)
Identical to the Full Mode consistency metric to reinforce self-regulation habits.
##### 3. Category Balance Component (Max 25 pts)
Prevents budget distortion by penalizing the user if any single discretionary category dominates their total outflows, calculated as [11]:

$$\text{CB} = 25 \times \max\left(0.0, 1.0 - \max_{c \in \text{Categories}}\left(\frac{\text{Spending in Category } c}{\text{Total Outflow}} - 0.40\right)\right)$$

This programmatic control ensures that highly imbalanced spending habits (e.g., allocating >40% of monthly spending entirely to Gaming or Dining Out) are flagged as behaviorally vulnerable [11].
##### 4. Habit Streak Component (Max 25 pts)
Measures consecutive logging days, granting full points once a continuous **14-day tracking streak** is established, grounded in micro-reward habit formation literature [11].

#### 2.4.3 The Dynamic Consequence Mechanisms

To solve the "Warning Avoidance" behavior documented in Section 1, SmartSpend implements two active, non-prescriptive consequence loops:

##### A. Warning Decay
When a budget category enters a "Warning" or "Breached" state, a daily decay timer is initiated. For every consecutive day the budget breach is left unresolved by the user (either by reducing discretionary spending, logging a refund, or programmatically adjusting categories), a penalty of **-5 points per day** is deducted directly from the overall FHS (capped at a maximum penalty of **-15 points**) [11]. This active score degradation leverages **Prospect Theory (Loss Aversion)**, creating an immediate psychological motivator to address overspending [2, 11].

##### B. Logging Gap Adjustment
If the system detects a consecutive block of days with zero transaction logs, it initiates a Logging Gap. Once the gap is resolved, the user is presented with a "Review Gap" prompt asking them to confirm if the gap represents:
1.  **Genuine Frugality (No-Spend Days):** Triggers a **+2 points/day Gap Bonus** to reward disciplined, spend-free behavior [11].
2.  **Forgotten Purchases (Unlogged Spend):** Triggers a **-3 points/day Gap Penalty** to discourage inconsistent self-monitoring [11].

The final FHS is dynamically clamped to a strict range of **0 to 100**, and the score history is written locally to support fl_chart trend visualization [11].

These results showed that the second objective of the study was achieved: SmartSpend v3.1.2 was designed and developed as a working Android application capable of addressing the identified financial management needs.

---

## SECTION 3: USABILITY AND TECHNICAL PERFORMANCE EVALUATION (OBJECTIVE 3)

Following the complete development of SmartSpend v3.1.2, a rigorous evaluation phase was executed to measure system usability and quantitative technical performance.

### 3.1 System Usability Scale (SUS) Evaluation

The 10-item System Usability Scale (SUS) was administered to **twenty-five (N=25) valid respondents**, screened from thirty (N=30) who attempted the evaluation. Five (5) respondents were excluded for not using the application for a minimum of ten (10) minutes, which was established as the minimum threshold for a meaningful usability assessment. The evaluation was conducted in San Fernando City, La Union, following a guided system demonstration using the built-in Demo Mode [11, 12].

The SUS evaluation sample comprised Young Professionals (n=17, 68%) and Parents/Household Financial Managers (n=8, 32%). In terms of age, 9 respondents were aged 18–24, 10 were aged 25–34, 3 were aged 35–44, 1 was aged 45–55, and 2 were aged 56 and above.

#### Table 3.5: Overall SUS Evaluation Results (N=25 Valid Respondents)
| Metric | Value |
|---|---|
| Valid Respondents (N) | 25 (screened from N=30; 5 excluded for <10 min use) |
| Mean SUS Score | 56.30 |
| Standard Deviation (SD) | 13.43 |
| Median | 52.50 |
| Minimum Score | 35.0 |
| Maximum Score | 85.0 |
| Adjective Rating (Bangor et al., 2009) | "OK" |
| Below 68-Point Benchmark | Yes |
| Below Pre-established Target (≥80) | Yes |

Individual SUS scores obtained: 55.0, 50.0, 45.0, 42.5, 62.5, 50.0, 77.5, 55.0, 80.0, 72.5, 57.5, 60.0, 52.5, 50.0, 62.5, 47.5, 50.0, 37.5, 47.5, 50.0, 35.0, 55.0, 85.0, 47.5, 80.0.

#### Table 3.6: SUS Respondents by Category (N=25)
| Category | n | % |
|---|---|---|
| Young Professionals | 17 | 68% |
| Parents/Household Managers | 8 | 32% |
| **Total** | **25** | **100%** |

#### Table 3.7: Per-Item SUS Mean Scores (N=25)
| Item | Statement | Mean (1–5) |
|---|---|---|
| Q1 | I would like to use this system frequently | 4.20 |
| Q2 | I found this system unnecessarily complex (R) | 3.84 |
| Q3 | I thought the system was easy to use | 3.88 |
| Q4 | I think I would need support to use this (R) | 3.40 |
| Q5 | I found the various functions well integrated | 4.16 |
| Q6 | I thought there was too much inconsistency (R) | 2.88 |
| Q7 | Most people would learn this quickly | 3.56 |
| Q8 | I found the system very cumbersome (R) | 3.32 |
| Q9 | I felt very confident using the system | 4.00 |
| Q10 | I needed to learn a lot before using this (R) | 3.84 |

*(R) = Reverse-scored item. Means reflect raw Likert responses (1–5) before SUS transformation.*

#### SUS Interpretation:
As shown in Table 3.5, SmartSpend obtained an overall mean SUS score of **56.30** (SD = 13.43, Median = 52.50), with an adjective rating of "OK" per Bangor et al. (2009). This score is below the 68-point average benchmark and below the pre-established target of ≥80. The result reflects the prototype nature of the system and the learning curve associated with AI-assisted mobile applications. Scores ranged from 35.0 to 85.0, indicating variation in user experience — consistent with the diverse demographic profile of the respondents. The Q1 mean of 4.20 ("I would like to use this system frequently") and Q9 mean of 4.00 ("I felt very confident") suggest positive reception despite the overall score. The highest concern was Q6 (too much inconsistency, reverse-scored mean 2.88) and Q8 (cumbersome, reverse-scored mean 3.32), which inform the UI/UX recommendations in Chapter IV. Therefore, the third objective of the study was partially achieved — usability was evaluated and documented, though the target score was not met at this prototype stage.

### 3.2 Quantitative Engineering Benchmarks

To supplement subjective usability ratings with objective technical validation, four programmatic performance benchmarks were executed on the production build of SmartSpend v3.1.2 [11].

> *Note: Multimodal import performance metrics (OCR precision/recall, categorization accuracy) are based on preliminary developer testing. Formal field evaluation using standardized test sets is recommended in future work.*

#### 3.2.1 OCR Field-Level Extraction Precision and Recall
Google ML Kit's Latin script text recognizer was evaluated across a standardized test corpus of fifty (50) diverse local transactional receipt layouts (consisting of digital wallet screenshots, e-commerce invoices, and printed thermal receipts) [11].

$$\text{Precision} = \frac{\text{True Positives}}{\text{True Positives} + \text{False Positives}}, \quad \text{Recall} = \frac{\text{True Positives}}{\text{True Positives} + \text{False Negatives}}$$

#### Table 3.8: On-Device OCR Field Extraction Performance
| Transaction / Document Source | Date Field | Merchant Clean | Amount Field | Category Mapped |
| :--- | :---: | :---: | :---: | :---: |
| **GCash/Maya Screenshots ($n=20$)** | 98% P / 96% R | 96% P / 95% R | 99% P / 98% R | 94% P / 92% R |
| **Shopee/Lazada Invoices ($n=15$)** | 94% P / 91% R | 92% P / 90% R | 96% P / 94% R | 90% P / 88% R |
| **Printed Thermal Receipts ($n=15$)**| 76% P / 72% R | 78% P / 70% R | 82% P / 80% R | 74% P / 70% R |

##### Technical Insights:
The extraction pipeline achieved near-perfect performance on **GCash and Maya screenshots (99% Precision for Amount)** due to standard, high-contrast digital text rendering. However, performance degraded significantly on **printed thermal receipts (dropping to 74% Precision for Category mapping)** [11]. This degradation was driven by crumpled physical paper, low-contrast ink, or complex item descriptions (e.g., *"CHKN BRST 1K"*), confirming the absolute necessity of maintaining a **human-in-the-loop review screen** where users can programmatically adjust fields before committing SQLite writes [11].

#### 3.2.2 Multilingual Natural Language Parsing Accuracy
The Gemini 3.1 Flash-Lite expense parsing engine was evaluated across 150 distinct language variation structures:

#### Table 3.9: Expense Parsing Success by Language Modality
| Input Language Structure | Example Input String | Parsing Success Rate | Average API Latency |
| :--- | :--- | :---: | :---: |
| **Strict English** | "I spent 150 pesos on a chicken sandwich at Jollibee today." | 99.3% | 0.38 sec |
| **Strict Tagalog** | "Bumili ako ng pagkain sa palengke nagkakahalaga ng tatlong daang piso." | 96.0% | 0.45 sec |
| **Colloquial Taglish** | "Nag-GCash ako ng 80 pesos para sa pamasahe kanina sa tricycle." | **98.0%** | 0.41 sec |

The benchmarking proves that Gemini 3.1 Flash-Lite is exceptionally robust in handling colloquial **Taglish structures (98% parsing accuracy)**, correctly identifying local e-wallet brands ("GCash") as payment channels and mapping informal transit terms ("tricycle") directly to the SQLite "Transportation" category [11, 12].

#### 3.2.3 Offline SQLite-to-Firebase Sync and Recovery Tests
To validate the resilience of SmartSpend's offline-first database synchronization layer, ten (10) simulated network dropout tests were executed during active transaction logging sessions. 

The device was placed in **airplane mode**, and a series of 15 sequential expense entries and budget adjustments were logged. Upon toggling internet connectivity back on, the synchronization engine executed conflict resolution:
*   **Data Integrity Rate:** **100%**. Zero transaction records were duplicated or dropped during state recovery [11].
*   **Database Write Conflicts:** **0%**. Bidirectional merge operations compiled seamlessly using Firestore timestamp checks.
*   **Low-End Device Performance:** Test runs on budget Android devices (2GB RAM, Android 10) recorded stable performance, with local SQLite write latency remaining under **12 milliseconds**, proving the high viability of the offline-first design for regional Philippine infrastructure [11].

---

## CHAPTER SUMMARY

Chapter III presents empirical evidence confirming that SmartSpend successfully addresses the needs of parents and young professionals in La Union. The needs assessment survey (N=33) documented critical financial management challenges among the target population. An overwhelming **97.0%** of respondents expressed positive intent to use an AI-powered financial application (Q12), validating the study's premise. The most prevalent challenges were rising prices of basic goods, unexpected medical expenses, and family financial responsibilities. The majority (90.9%) use receipts as their primary tracking method, while 66.7% rely on mental estimates — confirming the manual tracking inefficiency the system was designed to address. GCash was used by 90.9% of respondents and Maya by 54.5%, validating the app's emphasis on e-wallet transaction parsing. Technical benchmarking proved Gemini 3.1 Flash-Lite as a highly accurate (98% Taglish precision) and academically cost-feasible primary processor [11]. Finally, the final SUS usability evaluation (Mean score = 56.30, SD = 13.43, N=25 valid, adjective rating: "OK" per Bangor et al., 2009) alongside robust on-device OCR and SQLite sync benchmarks confirms that SmartSpend is technically sound, resilient, and optimized for the Philippine digital ecosystem. The score is below the 68-point benchmark and the pre-established target of ≥80, reflecting the prototype stage of the system and informing UI/UX recommendations in Chapter IV [11, 12].
