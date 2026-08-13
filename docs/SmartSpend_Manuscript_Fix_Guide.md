# SmartSpend Manuscript — Fix Guide
## Step-by-step corrections for the Google Docs manuscript
**Prepared by Kiro | August 2026**
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

## FIX 15 — Name Benjie G. Bucasas explicitly as technical/system validator
**Panel recommendation #26:** "Experts must validate the system itself, not just the questionnaire"
**Where:** Chapter 2, Population and Locale section — the validators table (Table 2.1) AND the Data Gathering section
**How to find it (CTRL+F):** `Technical Reviewer (SUS Process)`

**PART A — In Table 2.1, find:**
> | Technical Reviewer (SUS Process) | 1 |

**REPLACE WITH:**
> | Technical Validator (System & SUS Process) | 1 |

**PART B — Find the paragraph that describes Benjie G. Bucasas's role:**
**How to find it (CTRL+F):** `The System Usability Scale (SUS) evaluation process will be reviewed by a subject matter expert`

**CURRENT TEXT (find this):**
> The System Usability Scale (SUS) evaluation process will be reviewed by a subject matter expert in information technology to ensure proper administration and alignment with usability testing standards.

**REPLACE WITH:**
> The System Usability Scale (SUS) evaluation process and the overall technical functionality of the SmartSpend system will be reviewed by **Benjie G. Bucasas**, a subject matter expert in information technology, to ensure proper administration of the usability evaluation and to validate that the system's technical implementation aligns with established software development and usability testing standards. This expert validation covers both the correctness of the SUS evaluation process and an independent assessment of the system's core technical features.

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
- [ ] Fix 15 — Name Benjie G. Bucasas as technical/system validator (2 spots: Table 2.1 + paragraph)
- [ ] Fix 16 — Add step-by-step data gathering procedure sub-section

---

## NOTES FOR CHAPTER 3 (when you write it)

These things from the actual app should be in Chapter 3:

1. **LLM selection justification** — Primary: Gemini 3.1 Flash-Lite (1,000/day FREE, 1M context, Filipino-English excellent). Fallback chain: Gemini 3.5 Flash → Groq LLaMA 3.3 70B → Groq LLaMA 3.1 8B → Cerebras LLaMA 3.1. Reason for NOT using GPT-4o: paid only, not viable for academic deployment.

2. **FHS formula** — Both modes. Use the exact tables from `docs/SmartSpend_Capstone2_Documentation_Reference.md` Section 4.

3. **Architecture quote** (ready to paste into paper):
   > "SmartSpend implements a multi-provider agentic AI system using dynamic full-context injection from a local SQLite database, enabling autonomous financial data management without the infrastructure overhead of traditional RAG pipelines. The multi-provider routing architecture ensures continuous AI availability through automatic failover across five free-tier LLM providers, with task-based routing to match query complexity with model capability."

4. **Why not RAG** — per-user data (20-50 expenses, 5-10 budgets, 3-5 goals) fits entirely in the model's context window. No vector search needed.

5. **29 agentic actions** — list is in `docs/SmartSpend_Capstone2_Documentation_Reference.md` Section 3.

---

*Fix guide prepared by Kiro — based on comparing the manuscript against the actual v2.9.1 build*
*For questions: refer to `docs/SmartSpend_Capstone2_Documentation_Reference.md` for all accurate numbers*
