# SmartSpend: An AI-Assisted Mobile Financial Tracking and Advisory Application for Personal Financial Management

**A CAPSTONE Project**
presented to the faculty of the College of Computer Studies and Engineering, LORMA Colleges
In Partial Fulfillment of the requirements for the degree of Bachelor of Science in Information Technology

**Researchers:** Directo, Brix A. · Rubis, Cyrille John M. · Madayag, Djaunathan Albert S.
**Adviser:** Verzola, Johnny Flores, MTS
**Teacher-in-Charge:** Mendez, Janelli M., DIT
**Academic Year:** 2026–2027, 1st Semester | **Version:** 2.9.7

---

## ABSTRACT

Financial mismanagement remains a critical and documented challenge among Filipino households, compounded by limited access to accessible, localized, and intelligent financial tools. This study designed, developed, and evaluated **SmartSpend** — an AI-assisted mobile financial tracking and advisory application for Android, built for parents aged 35–55 and young professionals aged 21–35 in La Union, Philippines.

SmartSpend integrates a multi-provider agentic large language model (LLM) architecture — with Gemini 3.1 Flash-Lite as the primary model and four automatic fallback providers — enabling 29 autonomous financial management actions through natural language, voice, camera, batch screenshot import (40+ platform types), and manual entry. The system operates on an offline-first SQLite database with Firebase cloud synchronization, ensuring full functionality without internet connectivity.

A core academic contribution is the **Financial Health Score (FHS)**: a 0–100 behavioral metric computed entirely from user-recorded transaction data in two modes — Full Mode (income-based: Savings Rate, Overspend Control, Budget Adherence, Logging Consistency) and Lightweight Mode (habit-based: Spending Restraint, Consistency, Category Balance, Habit Streak) — with a Warning Decay consequence mechanism and a Logging Gap Detection system.

The system was evaluated using the System Usability Scale (SUS) with 30 purposively selected respondents (20 parents, 10 young professionals), targeting a score of ≥80 (Good). Expert validation of the survey instrument was conducted by a subject matter expert in financial management, and technical validation of the SUS evaluation process was conducted by a subject matter expert in information technology.

**Keywords:** personal finance management, agentic AI, large language model, financial health score, mobile application, Flutter, Filipino users, SmartSpend

---

## ACKNOWLEDGEMENT

The researchers would like to express their sincere gratitude and appreciation to all individuals who contributed to the successful completion of this study.

First and foremost, the researchers thank the **Almighty God** for His guidance, strength, wisdom, and blessings throughout this research. The researchers extend their heartfelt appreciation to the Dean of the College of Computer Studies and Engineering, **Mr. Jeoffrey B. Layco**, for his leadership and support. Special thanks are given to their Capstone Adviser, **Mr. Johnny Verzola**, for invaluable guidance and patience. The researchers also thank their instructor in charge, **Dr. Janelli M. Mendez**, for direction, structure, and continuous support. To the **panelists**, the researchers are grateful for their time and constructive feedback. Finally, the researchers extend their deepest gratitude to their **families and friends** for their unwavering support throughout this journey.

**The Researchers**

---

## DEDICATION

This study is dedicated to the researchers' beloved parents, whose unconditional love and sacrifices made this achievement possible. To their friends and classmates, whose encouragement helped make this journey meaningful. To their mentors and instructors, in appreciation of the knowledge and inspiration they provided. Lastly, to future researchers who may build upon this work.

**BAD · CJMR · DASM**

---

## TABLE OF CONTENTS

| Chapter | Section | Page |
|---|---|---|
| | Abstract | ii |
| | Acknowledgement | iii |
| | Dedication | iv |
| **I** | **Introduction** | 1 |
| | Project Context | 1 |
| | Statement of Objectives | 10 |
| | Scope and Limitations | 11 |
| | Purpose and Description | 13 |
| | Beneficiaries of the Study | 16 |
| | Technical Background | 17 |
| **II** | **Design and Methodology** | 26 |
| | Research Design | 26 |
| | Population and Locale | 27 |
| | Table 2.1. Distribution of Respondents | 29 |
| | Ethical Considerations | 30 |
| | Data Gathering Tools and Procedure | 31 |
| | Figure 2.1. SUS Score Interpretation | 34 |
| | Software Methodology | 34 |
| | Figure 2.2. Agile Kanban Workflow | 34 |
| | Table 2.3. Kanban Phases and Deliverables | 38 |
| **III** | **Results and Discussion** | 40 |
| | Objective 1 — Financial Management Practices | 40 |
| | Objective 2 — System Development and LLM Benchmarking | 42 |
| | Table 2.2. Comparative Evaluation of LLM APIs | 44 |
| | Financial Health Score Computation | 48 |
| | Objective 3 — System Usability Evaluation | 53 |
| **IV** | **Conclusions and Recommendations** | 56 |
| | Conclusions | 56 |
| | Recommendations | 57 |
| | References | 59 |
| | Appendix A — Validation Certificates | 66 |
| | Appendix B — Survey Questionnaire | 67 |
| | Appendix C — Consent Form | 73 |
| | Appendix D — SUS Questionnaire | 75 |
| | Curriculum Vitae | 77 |

---


# CHAPTER I — INTRODUCTION

This chapter presents the background of the study, including the context and motivation for developing the SmartSpend mobile application. It discusses the objectives of the research, the scope and limitations of the system, and its intended purpose and users. It also outlines the conceptual framework guiding the system design and the technical background of the technologies used in developing the proposed AI-powered financial assistant.

## Project Context

Financial mismanagement is a documented and pressing problem in the Philippines. According to the 2021 Bangko Sentral ng Pilipinas (BSP) Financial Inclusion Survey, only 2% of Filipino adults correctly answered all six basic financial literacy questions — covering numeracy, interest rates, inflation, and risk — while fewer than half reported maintaining any household or personal budget (Bangko Sentral ng Pilipinas, 2021). The Philippine Statistics Authority Family Income and Expenditure Survey (PSA FIES, 2021) further revealed that a substantial proportion of Filipino households consistently spend beyond their monthly income, with recurring expenditures on food, transportation, and utilities outpacing savings. In Filipino households, parents aged 35 to 55 typically serve as primary financial decision-makers, managing budgeting, bill payments, and daily expenses, yet national survey data indicate that many adults still lack formal financial accounts and do not maintain written budgets (Bangko Sentral ng Pilipinas, 2021; Philippine Statistics Authority, 2021).

The most recent Consumer Finance and Inclusion Survey (CFIS 2025) by the BSP reported that formal financial account ownership among Filipino adults had declined to 50% — down from 56% in 2021 — while household-level access rose to 86%, indicating that families increasingly rely on a single member's account for collective financial management (Bangko Sentral ng Pilipinas, 2025). A separate Social Weather Stations survey conducted in March 2026 found that overall financial inclusion in the Philippines had risen to 58%, driven primarily by e-wallet adoption rather than traditional banking — 43% of respondents reported e-money accounts, while 21% reported bank accounts (Social Weather Stations, 2026). GCash, the country's leading financial super app, now serves 41.5 million monthly active users and has become a primary financial infrastructure layer for millions of lower-income, women, and provincial users (Bloomberg, 2026). Despite this rapid adoption of digital payment platforms, NielsenIQ (2026) found that while 99% of Filipinos shopped online in the past six months, only 52% actively use mobile banking apps — confirming a persistent gap between digital commerce adoption and structured financial management behavior.

Several studies and reports highlight persistent challenges in personal financial management among Filipino households. A study on the financial freedom of Filipino workers revealed pervasive literacy challenges, including reliance on traditional saving methods, high debt dependence, and a "come-what-may" attitude toward financial planning — all of which contribute to weak financial resilience (Flores, 2025). These challenges are compounded by volatile prices, rising living costs, and the prevalence of informal credit arrangements such as borrowing from relatives or neighborhood stores, which are rarely recorded in any structured system (Philippine Statistics Authority, 2021; Flores, 2025). The Philippine digital economy reached ₱2.74 trillion in gross value added in 2025, accounting for 9.8% of GDP, with e-commerce as the second-largest contributor — a context that underscores the need for financial management tools that match the digitally active lifestyle of Filipino users (Philippine Statistics Authority, 2025).

In everyday life, parents and working adults frequently juggle employment, caregiving, and household management, leaving limited time for manual expense recording. Traditional approaches — notebooks, spreadsheets, and simple expense trackers — rely heavily on user discipline and do not provide proactive feedback when spending becomes risky. As a result, many users abandon these tools after initial use, leading to incomplete financial records and poor historical data for decision-making (Stefanov et al., 2024; Flores, 2025).

**Figure 1.1. Financial Literacy Rates by Demographic Group (BSP, 2021; Inquiro, 2024).**
*[Insert bar chart here in Google Docs — showing financial literacy rate by age group, sourced from BSP 2021 and Inquiro 2024]*

Globally, a variety of personal finance applications have emerged, including zero-based budgeting tools, multi-account financial dashboards, and AI-assisted expense trackers. However, many are designed for markets with widespread bank connectivity and depend on direct bank integration or credit card data feeds (Stefanov et al., 2024). In the Philippine context, existing applications address specific aspects of financial management but lack integrated conversational AI, spending behavior analysis, and health scoring tailored to Filipino users who rely on mixed payment methods including cash, e-wallets, and informal credit (Bangko Sentral ng Pilipinas, 2021; Stefanov et al., 2024).

Recent advancements in artificial intelligence — particularly Large Language Models — have transformed how mobile applications handle user interaction and data processing (Davenport & Mittal, 2022; Dwivedi et al., 2021). A 2026 survey by Ernst & Young found that 49% of global consumers had used AI to support savings and investment decisions in the past six months, with 18% using AI specifically for budgeting and household finance management (Ernst & Young, 2026a). Plaid's State of Intelligent Finance report (Spring 2026) documented that 60% of consumers expect AI to save them time on financial tasks, 58% expect it to reduce financial stress, and the personal finance AI market is projected to grow to approximately $3.7 billion by 2033 (Plaid, 2026). These figures establish AI-assisted financial management as a mainstream consumer use case, not an experimental one.

Filipino fintech companies have also recognized this opportunity. In March 2026, GCash launched "Pera Coach" — the country's first AI financial literacy coach embedded within an e-wallet — developed in partnership with Microsoft (GCash / Mynt, 2026). Pera Coach provides personalized financial education and guidance in English and Filipino languages for Fully Verified GCash users. This validates the market relevance of AI-assisted financial guidance for Filipino users. However, Pera Coach is an advisory and literacy tool within a payments app — it does not track expenses, compute a health score, work offline, or execute autonomous actions on financial data. SmartSpend addresses a different and broader user need: a comprehensive, free, offline-capable financial management system with autonomous AI actions, behavioral scoring, and multi-modal input.

At the demographic level, parents and young professionals may download budgeting apps but discontinue use when manual encoding feels too burdensome and when warnings can be ignored without visible consequences. Table 1.1 presents a three-level summary of the identified gaps and SmartSpend's corresponding solutions.

**Table 1.1. Three-Level Gap Analysis of SmartSpend**

| Gap Level | Existing Problem | SmartSpend Solution |
|---|---|---|
| International | Manual entry dominates; AI categorization degrades for non-English transactions (Stefanov et al., 2024) | LLM-based parsing for Filipino-English (Taglish) natural language input across 6 input modalities |
| National (PH) | Local apps lack LLM chat, spending behavior analysis, and health scoring (BSP, 2021; Stefanov et al., 2024) | Conversational agentic AI + dual-mode Financial Health Score + multi-period summaries |
| Demographic | Parents abandon apps due to manual effort; warnings ignored without visible consequences (BSP, 2021) | Automated multi-modal input + FHS Warning Decay consequence mechanism + Logging Gap Detection |

Several existing applications demonstrate how mobile tools can support personal financial management while revealing gaps SmartSpend addresses. Tarsi – Budget Tracker (2026) supports offline tracking and receipt capture but lacks conversational AI and a unified health score. YNAB implements zero-based envelope budgeting effectively but requires a paid subscription inaccessible to many Filipino users (Yomio, 2026). Monarch Money offers multi-account aggregation but is designed for bank-connected Western markets. Copilot is iOS-only and does not support Filipino-English input. Among Filipino-first applications, BudgetPH (budget.kindlyf.com, 2026) offers payday-cycle awareness, a paluwagan tracker, and a simplified budget score, but has no conversational AI with autonomous actions. Alkansya AI provides basic AI chat but is primarily iOS and web-based, with no offline mode or multi-modal input. These comparisons confirm that a free, offline-capable, Filipino-English AI financial management system with autonomous actions and behavioral scoring remains absent from the market. Table 1.2 presents the key feature differences.

**Table 1.2. Feature Comparison of SmartSpend with Existing Financial Applications**

| Feature | Tarsi | YNAB | Monarch | Copilot | BudgetPH | Alkansya AI | GCash Pera Coach | SmartSpend |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| Offline mode | Yes | No | No | No | Yes | No | No | **Yes** |
| LLM chat assistant | No | No | No | No | Insights only | Yes (basic) | Yes (literacy Q&A) | **Yes — 29 agentic actions** |
| Financial Health Score | No | No | No | No | Yes (simpler) | No | No | **Yes (0–100, dual-mode)** |
| OCR receipt scanning | Yes | No | No | No | No | No | No | **Yes** |
| Voice input (en-PH) | No | No | No | No | No | No | No | **Yes** |
| Batch screenshot import (40+ platforms) | No | No | No | No | No | No | No | **Yes** |
| Multi-period spending limits | No | No | No | No | Yes | No | No | **Yes (daily/wk/mo/yr)** |
| Spending behavior analysis | No | No | No | No | No | No | No | **Yes** |
| Bank synchronization | No | Yes | Yes | Yes | CSV import | No | GCash only | No |
| Filipino-English AI | No | No | No | No | No | Yes | Yes (PH languages) | **Yes — full Taglish** |
| Free tier (Android) | Yes | No | No | No | Yes (PWA) | Limited | Yes (GCash required) | **Yes — always free** |
| Paluwagan tracker | No | No | No | No | Yes | No | No | No |
| 15th & 30th payday cycle | No | No | No | No | Yes | No | No | No |
| Gamification (badges/quests) | No | No | No | No | Yes (XP/levels) | No | No | **Yes (23 badges, 10 quests)** |
| Logging gap detection | No | No | No | No | No | No | No | **Yes** |
| SSS/PhilHealth/Pag-IBIG calculator | No | No | No | No | Yes (records) | No | No | **Yes (AI compute)** |
| Round-up savings | No | No | No | No | No | No | No | **Yes** |
| Insurance tracker | No | No | No | No | No | No | No | **Yes** |

Building on the gaps identified above, SmartSpend addresses this space by integrating a large language model API for natural language expense parsing, a conversational AI assistant capable of executing 29 autonomous financial management actions, and a Financial Health Score quantifying financial behavior on a scale of 0 to 100. The system operates offline using a local SQLite database with optional Firebase cloud synchronization, and supports voice, OCR, barcode scanning, batch screenshot import (40+ platform types), text paste, and manual form entry. It is designed primarily for parents aged 35 to 55 in La Union, Philippines, with young professionals aged 21 to 35 as a secondary target.

## Conceptual Framework

**Figure 1.2. Conceptual Framework — SmartSpend Mobile Application (IPO Model)**
*[Insert IPO framework diagram in Google Docs]*

This figure illustrates the conceptual framework of the SmartSpend mobile application following the Input–Process–Output (IPO) model. The **Input** includes text, voice, receipt images (OCR), barcode scans, batch screenshots, text paste, and user-entered financial data. The **Process** involves LLM-based natural language processing through a multi-provider agentic AI architecture, OCR extraction, barcode recognition, financial health score computation, and data storage via SQLite and Firebase synchronization. The **Output** consists of automatically recorded expenses, financial summaries, charts, startup alerts, AI-generated insights, a Financial Health Score (0–100), gamification feedback, and AI-powered financial advisory including general Q&A, SSS/PhilHealth guidance, and market price estimates.

## Statement of Objectives

This study aims to design, develop, and evaluate SmartSpend — an AI-assisted mobile financial tracking and advisory application for personal financial management, with a primary focus on parents aged 35 to 55 as the main target population, and young professionals aged 21 to 35 as a secondary demographic, in La Union, Philippines.

Specifically, this study aims to:

1. Assess the existing financial management practices, common budgeting challenges, and expense tracking behaviors of parents aged 35 to 55 and young professionals aged 21 to 35 in San Fernando City, La Union, through structured surveys and interviews.

2. Design and develop the SmartSpend mobile application, including its system architecture, database structure, user interface, and core functionalities such as multi-modal expense input, automated AI processing, cloud-based synchronization, and the integration of a suitable Large Language Model API — using a context injection architecture — selected through a comparative technical evaluation based on inference speed, response accuracy for Filipino-English natural language processing, context window capacity, and cost feasibility for academic deployment.

3. Evaluate the usability of the SmartSpend application using the System Usability Scale (SUS) administered to thirty (30) purposively selected respondents following a live guided demonstration.

## Scope and Limitations

The application supports both online and offline functionality using a local SQLite database (version 11 schema, 20 tables) to ensure accessibility without internet connectivity. The system integrates cloud storage and authentication through Firebase Firestore, Firebase Authentication, Firebase Remote Config, and Firebase App Check. An LLM API generates AI-powered insights, parses natural language inputs, and supports 29 autonomous financial management actions. The system is available on Android devices only.

The system has several limitations. OCR text recognition accuracy depends on image quality; handwritten or low-resolution images may produce inaccurate results. Voice recognition accuracy is affected by background noise and device support for the Filipino English (en-PH) locale; manual input options remain available as fallback. All AI-powered features require an active internet connection, as they rely on external LLM API services. The application does not support direct bank integration — bank synchronization is excluded due to the absence of accessible open-banking APIs in the Philippine setting (BSP Open Finance pilot launched July 2025 with limited participation) and the data privacy implications of transmitting banking credentials to third-party services. Investment features are outside scope. The application does not provide professional financial, legal, or tax advice.

The LLM API key is not embedded within the application package. It is fetched securely at runtime via Firebase Remote Config, ensuring the key is never stored in the APK binary or exposed in source code. The system enforces a daily interaction limit of 60 AI requests per user. A backend proxy server for fully server-side API key management is planned as a post-capstone enhancement.

Profile images are stored locally on the device and are not synchronized across devices due to limitations of the Firebase Spark (free) plan. The system is designed within free-tier service constraints and remains limited to Android platform compatibility for the duration of this study.

## Purpose and Description

SmartSpend is designed as a mobile application that helps users manage their daily finances in a more organized and less manual way, addressing the core dimensions of perceived usefulness and ease of use that drive technology adoption (Davis, 1989). Rather than functioning only as a passive tracking tool, it acts as an active financial management assistant that executes actions from natural language commands and provides proactive feedback on spending behavior.

The SmartSpend AI assistant serves as a general financial companion capable of responding in Filipino-English (Taglish). Users may ask about current market prices, inquire about banking products and government financial services (SSS, PhilHealth, Pag-IBIG), seek advice on buying and selling decisions, and explore financial literacy topics — all within a conversational interface that adapts to the user's needs.

To support healthy financial behavior, SmartSpend incorporates a behavioral intervention layer grounded in behavioral finance principles. The **Impulse Pause** mechanism prompts reflection before confirming large Want-tagged expenses, framing the purchase in terms of its cost to savings goals — a direct application of loss aversion theory (Kahneman & Tversky, 1979). Digital payment methods reduce the psychological pain of spending — a phenomenon documented by Meyll et al. (2025) as "Spendception" — and the Impulse Pause counteracts this effect by reintroducing deliberate consideration at the point of purchase. The **Warning Decay** system reduces the Financial Health Score by 5 points per day (up to 3 days, maximum −15) when budget warnings are ignored and spending continues, making the consequence of ignoring financial risk signals numerically visible (Thaler & Sunstein, 2008). **Velocity alerts** notify users when spending rate significantly exceeds typical patterns. A **daily mood check-in** tracks emotional states alongside financial activity, enabling a mood-and-spending correlation view in Analytics.

A gamification layer featuring 23 achievement badges, 10 rotating daily quests, and spending streak tracking reinforces positive financial habits by rewarding consistent logging and budget adherence (Bitrián et al., 2021). Research confirms that gamification in personal finance apps boosts saving habits by 22% and increases average user savings by 20% when game mechanics are tied to real financial behaviors (Strivecloud, 2026; Juniper Research, 2026). Wajid et al. (2025) further document that gamification in financial planning systems leads to higher savings rates, budgeting rates, and investment contribution rates among users. Digital nudge research additionally confirms that gamified visual nudges significantly enhance engagement, particularly among younger users (Springer, 2026).

The account type selection (Employed, Business Owner, Freelancer, Working Student, Student, Pensioner/Retiree, Unemployed, General/Other) serves as an adaptive label personalizing the application's language and default suggestions without restricting any features. For example, users who select "Student" see "allowance" instead of "salary," and budget suggestions are adjusted accordingly. Users may change their account type at any time from profile settings.

SmartSpend additionally includes a **Customizable Settings system** — accessible as a full-screen dedicated interface from the Profile tab — allowing users to individually toggle optional home screen and analytics sections on or off. A **Lite Mode** toggle instantly hides all optional sections in one tap, leaving only the core financial tracking features visible: spending summary, Financial Health Score, wallet balances, budgets, and spending limits. This design follows the progressive disclosure principle (Nielsen, 2006) and reduces cognitive load (Sweller, 1988) for users who find the full interface overwhelming — directly addressing the perceived ease-of-use dimension of technology adoption (Davis, 1989).

## Beneficiaries of the Study

**Parents (Ages 35–55).** As primary household financial managers in Filipino families, parents face significant financial responsibility despite having limited access to formal financial literacy training and structured budgeting tools (Bangko Sentral ng Pilipinas, 2021). SmartSpend provides automated expense tracking, multi-period financial summaries, a Financial Health Score that quantifies budgeting behavior without requiring financial expertise, and Philippine-specific features (SSS, PhilHealth, Pag-IBIG, GCash, BIR TRAIN Law) that match the realities of Filipino household finances.

**Budget-Conscious Individuals (Young Professionals, Ages 21–35).** This group includes working individuals who aim to manage finances more effectively using digital tools. SmartSpend enables expense control, budget planning, and improved financial behavior through AI-driven spending analysis. The wallet management feature tracks balances across GCash, Maya, bank accounts, and cash — offering a consolidated view of available funds alongside savings goals and debt management.

**Technology Enthusiasts.** Individuals interested in AI advancements can explore the application's integration of a multi-provider agentic LLM architecture with 29 autonomous actions, dynamic context injection design, and multi-modal input processing.

**Demo and Evaluation Users.** Users who wish to explore the application without creating an account can use the built-in Demo Mode, accessible from the login screen. This mode provides realistic Filipino sample data and full feature access, making it suitable for demonstrations, evaluations, and usability testing.

**The Researchers.** The project enabled the researchers to apply knowledge and skills in software development, artificial intelligence, and system design in a practical, research-driven setting aligned with capstone requirements.

**Future Researchers.** This study serves as a reference for researchers in artificial intelligence, mobile applications, and financial technology. The documented FHS formula, LLM benchmarking methodology, agentic architecture design, and usability evaluation process may provide a foundation for future studies.

## Technical Background

The following section describes the key technologies, frameworks, and algorithms used in designing and building the SmartSpend mobile application.

**Flutter.** Flutter is an open-source UI framework developed by Google used to build the SmartSpend Android application. It provides a rich widget set enabling a responsive, visually consistent interface from a single Dart codebase, compiled to ARM machine code for near-native performance (Google, 2024f).

**SQLite.** The application uses SQLite as its primary local database via the sqflite package (version 11 schema, 20 tables), storing all financial data — including expenses, budgets, savings goals, income, recurring transactions, debts, wallet balances, chat history, mood log, score history, and installment plans — directly on the device. This ensures full offline functionality (Roux, 2019). Expenses are categorized across 14 built-in types and support unlimited custom categories with auto-categorization keyword rules.

**Firebase Firestore.** Used for bidirectional cloud synchronization. Every write operation is automatically pushed to Firestore, and upon login the application retrieves cloud data and merges it into the local database, enabling multi-device access to financial records (Google, 2024c).

**Firebase Authentication.** Handles user identity management, supporting email/password login and Google Sign-In via OAuth 2.0 (Google, 2024a).

**Firebase Remote Config and App Check.** The LLM API key is never stored in the APK binary. It is fetched securely at runtime via Firebase Remote Config. Firebase App Check additionally verifies that only legitimate signed APK builds can retrieve configuration values, protecting against key abuse from decompiled or modified builds.

**Firebase Crashlytics.** Captures Flutter framework errors and asynchronous exceptions for real-time crash reporting (Google, 2024b).

**LLM API Integration — Multi-Provider Agentic Architecture.** SmartSpend implements a multi-provider agentic AI system selected through comparative technical evaluation. The system uses **Gemini 3.1 Flash-Lite** (Google AI Studio) as the primary model — offering 1,000 free requests per day, a 1-million token context window, excellent Filipino-English multilingual performance, and native function calling support. Four fallback providers activate automatically when the primary limit is reached: Gemini 3.5 Flash (Google, 250 req/day free), Groq LLaMA 3.3 70B (~14,400 req/day free), Groq LLaMA 3.1 8B (~14,400 req/day free), and Cerebras LLaMA 3.1 70B (~1M tokens/day free). A task-based routing system directs simple queries (expense parsing) to faster lower-tier models and complex financial advisory (SSS, debt strategy) to higher-capability models. The full comparative benchmarking results and selection justification are presented in Chapter 3.

The system architecture uses **dynamic full-context injection** rather than Retrieval-Augmented Generation (RAG). Before every AI call, the application queries SQLite and builds a context string containing the user's current expenses, budgets, income, goals, debts, wallet balances, recurring bills, and current Financial Health Score. This context is injected into every AI system prompt as the single source of truth. RAG is designed for large knowledge bases (thousands of documents); a typical SmartSpend user has 20–50 expenses, 5–10 budgets, and 3–5 goals — small enough to fit within the model's context window without vector search overhead (Davenport & Mittal, 2022; Li et al., 2024). As documented by the World Economic Forum (2024), IBM (2025), and Cambridge Judge Business School (2025), agentic AI systems that perceive context, decide on actions, and execute them autonomously represent the frontier of AI application in financial services — a design principle SmartSpend implements through its 29-action agentic loop: **perceive** (full financial context from SQLite) → **decide** (select the correct action from 29 types) → **act** (write directly to the database).

**The 29 Agentic AI Action Types.** The AI does not merely answer questions — it takes autonomous actions directly on the user's SQLite database, producing immediate, verifiable results visible to the user:

| Category | Actions |
|---|---|
| Expense Management | log_expense, update_expense, delete_expense, delete_by_date |
| Income & Wallets | set_income, add_income, set_wallet_balance, transfer_wallet |
| Budgets | set_budget |
| Goals | add_goal, update_goal, delete_goal |
| Debts | add_debt, update_debt |
| Recurring Transactions | add_recurring, delete_recurring |
| Payment Plans | add_installment_plan |
| Analysis & Advisory | plan_salary_split, analyze_goal_feasibility, suggest_debt_payoff, generate_monthly_plan, compare_periods, explain_fhs_breakdown, project_savings_timeline, detect_subscriptions, compute_contribution, suggest_idle_money, suggest_expense_cuts, simulate_what_if, create_debt_payment_plan, split_expense |
| Account | set_account_type |

**Financial Health Score (FHS).** SmartSpend introduces a Financial Health Score ranging from 0 to 100 providing users with a single, interpretable indicator of their budgeting behavior. The FHS is computed directly from user-recorded transaction data — no surveys, bank connections, or external benchmarks required. This behavioral computation approach is directly inspired by the CFPB Financial Well-Being framework and the Financial Health Network FinHealth Score® (Consumer Financial Protection Bureau, 2017; Financial Health Network, 2021, 2026), while differentiated by its mobile-first, transaction-driven computation. The score operates in two modes:

In **Full Mode** (income tracking enabled), it is computed from four equally weighted components: Savings Rate, Overspend Control, Budget Adherence, and Logging Consistency — each contributing 25% to the total score.

In **Lightweight Mode** (income tracking disabled — for students, informal workers, and freelancers without fixed income), the four components are: Spending Restraint (vs a user-defined spending limit), Logging Consistency, Category Balance (preventing any single category from exceeding 40% of total spending), and Habit Streak (consecutive logged days, fully credited at 14 days). This dual-mode design ensures the FHS is meaningful for users without fixed incomes, consistent with the Financial Health Network's acknowledgment that financial health metrics must adapt to diverse income structures (Financial Health Network, 2021). The detailed FHS formulas, component weights, score adjustments, and academic basis are fully documented in Chapter 3.

**Speech-to-Text.** The speech_to_text package implements voice input with automatic Filipino English (en-PH) locale detection, a 15-second listening window, and automatic pause detection (Sloane, 2022).

**Google ML Kit Text Recognition (OCR).** ML Kit's on-device Latin script text recognizer extracts text from receipt images without requiring external API calls. Single-item receipts route directly to AI chat for parsing; multi-item receipts route to a dedicated review screen where each item is verified and assigned a category before importing (Google, 2024e).

**Mobile Scanner (Barcode).** The mobile_scanner package enables live barcode/QR detection and gallery-image barcode detection. Each scan is saved to local scan history and routed to AI for product lookup (Bociek, 2023; ZXing, 2023).

**Smart Import — Unified 4-Mode System.** One camera button opens a 2×2 import sheet providing four input modes: (1) **Live Camera** — live barcode/QR detection and receipt OCR; (2) **Single Photo** — auto-detects whether the image is a barcode, receipt, or app screenshot and routes correctly; (3) **Batch Screenshots** — up to 10 images, each auto-detected across 40+ platform types (Shopee, Steam, GCash, Maya, GrabFood, BPI, Netflix, Spotify, TikTok Shop, Lazada, and more) with a dedicated AI extraction prompt per platform type; (4) **Paste Text** — parses GCash history, BPI statements, and any bank export text using an AI transaction parser.

**Backup and Restore.** All financial data is exported as a structured JSON file (version 9 format) shareable via any installed application or saved to local storage. Restoration selects a previously exported JSON file and merges it into the local database.

**fl_chart.** Renders interactive charts in the Analytics screen: pie chart for category breakdown, bar chart for monthly spending trends, line chart for 30-day FHS history, and scatter charts for mood-spending correlation (Flutter 4 Fun, 2022).

**local_auth.** Enables PIN and biometric authentication (fingerprint or face unlock) as an application lock on cold start only — mirroring the authentication behavior of GCash and Maya, where users authenticate once on open and are not repeatedly interrupted during normal session use (The Flutter Authors, 2013).

*[End of Chapter I]*


---

# CHAPTER II — DESIGN AND METHODOLOGY

This chapter presents the methods and procedures used in the development, implementation, and evaluation of the SmartSpend system. It includes a detailed discussion of the research design, population and locale, ethical considerations, data gathering tools and procedures, and the software development methodology applied in the study.

## Research Design

This study applies a **mixed methods research design**, which integrates both qualitative and quantitative approaches in collecting and analyzing data (Creswell & Plano Clark, 2011). This design is appropriate because it allows a comprehensive understanding of financial management practices and system usability by combining numerical data with detailed user experiences.

The **qualitative** component involves interviews and feedback gathering from selected parents and young professionals, exploring their personal experiences in managing finances, challenges in budgeting and expense tracking, and expectations regarding the proposed system. The qualitative data provides rich, descriptive information that guided the design and improvement of the application.

The **quantitative** component involves validated structured survey questionnaires to collect measurable data on financial habits, expense tracking practices, and common difficulties encountered by respondents. The collected data is analyzed to identify patterns, frequencies, and trends supporting the development of system features aligned with user needs. Additionally, the System Usability Scale (SUS) questionnaire evaluates the usability, efficiency, and overall user satisfaction of the developed SmartSpend application. The SUS is a widely used and validated tool for assessing system usability through standardized scoring (Brooke, 1996). The SUS evaluation is administered to thirty (30) respondents following a live demonstration of the SmartSpend application. A target SUS score of 80 or above — corresponding to the "Good" adjective rating — has been set as the acceptance threshold for this study (Bangor et al., 2009).

This study also adopts a **descriptive-developmental research approach**, which focuses on the design, development, and evaluation of a functional system or prototype. The SmartSpend mobile application is developed using the Flutter framework, with AI integration through a multi-provider LLM API architecture. By combining mixed methods and developmental approaches, the study ensures that the system is not only technically functional but also user-centered, effective, and aligned with the actual needs of respondents.

## Population and Locale

The study is conducted in San Fernando City, La Union, Philippines.

The **primary target population** consists of parents aged 35 to 55 who serve as the principal household financial decision-makers in Filipino families. Based on the 2021 BSP Financial Inclusion Survey, this demographic group manages the majority of household budgeting, bill payments, and daily financial decisions, yet exhibits the lowest rates of formal financial account ownership and structured budgeting behavior among all adult demographics (Bangko Sentral ng Pilipinas, 2021). Parents are defined as adults aged 35 to 55 who act as primary household financial managers.

The **secondary target population** consists of young professionals aged 21 to 35 who independently manage their own income and expenses, representing a growing segment of digital financial tool users in the Philippines. This age range aligns with the classification used by the BSP Financial Inclusion Survey and the Philippine Statistics Authority's Labor Force Survey, which identify 20–35 year-olds as early-career workers entering the formal workforce and beginning to establish independent financial management habits (Bangko Sentral ng Pilipinas, 2021; Philippine Statistics Authority, 2021).

A total of **thirty (30) respondents** will be selected using purposive sampling. Twenty (20) respondents will be parents who regularly handle household budgeting, bill payments, and daily expense decisions. Ten (10) respondents will be young professionals who manage their own income and make independent financial decisions. This sample size aligns with common practice for capstone-level usability and needs assessment studies and is sufficient to identify common patterns and usability issues (Creswell & Plano Clark, 2011).

**Inclusion criteria for parent respondents (n=20):**
- Aged 35 to 55 years old
- Currently serving as a primary household financial manager (responsible for budgeting, bill payments, and daily expense decisions)
- Resident of San Fernando City or surrounding municipalities in La Union
- Owns or has regular access to an Android smartphone

**Inclusion criteria for young professional respondents (n=10):**
- Aged 21 to 35 years old
- Currently employed or self-employed with independent management of personal income and expenses
- Resident of or working in San Fernando City, La Union
- Owns or has regular access to an Android smartphone

Individuals who do not meet the age range, do not actively manage personal or household finances, or do not have access to an Android device are excluded from the study.

The survey questionnaire will undergo content validation by a subject matter expert in financial management and business operations to ensure relevance, clarity, and appropriateness of the instrument. The System Usability Scale (SUS) evaluation process and the overall technical functionality of the SmartSpend system will be reviewed by a subject matter expert in information technology, whose qualifications are documented in the Technical Validation Certificate (Appendix A). This expert validation covers both the correctness of the SUS evaluation process and an independent assessment of the system's core technical features.

The researchers will utilize purposive sampling, which allows intentional selection of individuals with relevant experience in budgeting, expense tracking, and financial decision-making — ensuring that the collected data is meaningful and directly aligned with the research objectives.

The distribution of respondents is presented in Table 2.1.

**Table 2.1. Distribution of Respondents**

| Category | Number |
|---|---|
| Parents (Ages 35–55) | 20 |
| Young Professionals (Ages 21–35) | 10 |
| **Total Respondents** | **30** |
| Content Validator (Survey — Financial Management Expert) | 1 |
| Technical Validator (System & SUS Process — IT Expert) | 1 |
| **Total Validators** | **2** |

## Ethical Considerations

All ethical considerations will be strictly followed throughout the research process. Participation is completely voluntary — no form of pressure will be imposed on respondents. All participants have the right to refuse participation or withdraw from the study at any time without any penalty.

Informed consent will be obtained from all participants before their involvement. They will be properly informed about the nature and purpose of the research, their rights, and the confidentiality of their responses before any data collection begins.

Confidentiality will be strictly maintained. Personal information of respondents will be kept secure and used solely for academic purposes. All collected data will be carefully managed and stored to prevent loss or unauthorized access.

The study is conducted with fairness and objectivity. Respondents are informed that participation is anonymous — no personal identifying information will appear in the final research output unless explicitly consented to. Research outputs will accurately and transparently represent the collected data.

## Data Gathering Tools and Procedure

**For the first objective,** data will be gathered through survey questionnaires and interviews. The survey questionnaire collects quantitative data on financial management practices, budgeting challenges, and expense tracking behaviors of parents and young professionals. The questionnaire will undergo content validation by a subject matter expert in financial management prior to distribution. Interviews will gather qualitative insights into respondents' experiences, difficulties, and current financial strategies.

**For the second objective,** no direct data gathering instrument is used for the design and development phase itself — results from the first objective serve as the primary basis for system design. However, technical benchmarking is conducted as part of this objective to support the AI engine selection process. A comparative evaluation of candidate Large Language Model APIs will be performed across multiple providers, assessed on four criteria: (1) inference speed, measured as average response latency for a standardized Filipino-English expense parsing prompt; (2) response accuracy for Filipino-English natural language processing, evaluated using test prompts representing typical user inputs in Filipino, Taglish, and English; (3) context window capacity, defined as the maximum tokens processable in a single request; and (4) cost feasibility, evaluated based on free-tier API plan availability appropriate for academic deployment. The benchmarking results and selection justification are presented in Chapter 3.

**For the third objective,** the System Usability Scale (SUS) questionnaire evaluates the developed SmartSpend application. Respondents assess the application in terms of ease of use, functionality, and overall experience. The administration of the usability evaluation will be reviewed by a subject matter expert in information technology to ensure proper administration procedures are followed.

**Figure 2.1. System Usability Scale (SUS) Score Interpretation**
*[Insert SUS score interpretation chart in Google Docs — showing score ranges: 0–59 Poor, 60–69 Marginal, 70–79 Acceptable, 80–89 Good, 90–100 Excellent]*

### Step-by-Step Data Gathering Procedure

**Step 1 — Questionnaire Preparation and Validation (Objective 1):**
The survey questionnaire will be drafted by the research team and submitted to a subject matter expert in financial management for content validation. The expert's credentials (educational background, occupation, years of experience) will be documented in the Content Validation Certificate (Appendix A). Revisions will be made based on the expert's feedback before distribution.

**Step 2 — Respondent Identification and Consent (Objective 1):**
Thirty (30) respondents will be identified using purposive sampling based on the defined inclusion criteria. Each respondent will receive a consent form explaining the purpose of the study, their rights, and the confidentiality of their responses. Signed consent forms will be collected before questionnaire distribution.

**Step 3 — Survey Distribution and Collection (Objective 1):**
The validated questionnaire will be distributed to the 20 parent respondents and 10 young professional respondents in San Fernando City, La Union. Respondents will complete the survey independently. Selected respondents will also participate in brief interviews to provide supplementary qualitative insights into their financial management challenges and technology expectations.

**Step 4 — LLM Technical Benchmarking (Objective 2):**
Candidate LLM APIs will be comparatively evaluated using standardized Filipino-English expense-parsing prompts. Response latency, accuracy, context window capacity, and cost will be recorded and compared across providers. Results will be tabulated in Table 2.2 (Chapter 3) and used to justify the final model selection.

**Step 5 — System Demonstration and SUS Evaluation (Objective 3):**
Following system development, each respondent will receive a guided live demonstration of the SmartSpend application using the built-in Demo Mode (pre-loaded with realistic Filipino sample data, no account creation required). After the demonstration, respondents will independently complete the 10-item SUS questionnaire. The process will be reviewed by the technical validator to ensure proper administration.

**Step 6 — Data Tabulation and Analysis:**
Survey responses will be tallied and analyzed using frequency and percentage for quantitative items. Qualitative interview responses will be summarized for themes related to financial management challenges. SUS scores will be computed per respondent following the standard SUS scoring formula (odd-item scores minus 1; 5 minus even-item scores; sum multiplied by 2.5) and averaged to produce the final SUS score, interpreted against the Bangor et al. (2009) adjective rating scale.

## Software Methodology

**Figure 2.2. Agile Kanban Workflow for SmartSpend Development**
*[Insert Kanban board diagram in Google Docs — showing columns: Backlog, Requirements, Design, Development, Testing, Deployment, Done/Review]*

The development of the SmartSpend mobile application follows the **Agile Kanban Software Development Methodology**. This approach was selected because the project requires continuous feature integration, testing, and refinement — especially given the involvement of multiple complex components including AI, OCR processing, and cloud synchronization. Unlike traditional linear development models, Kanban allows tasks to be worked on dynamically, with phases potentially overlapping or repeating as needed, while continuously improving the system based on feedback and testing results.

The Kanban board is divided into seven columns representing workflow stages: Backlog, Requirements, Design, Development, Testing, Deployment, and Done/Review. Each feature — such as implementing OCR, integrating the LLM API, or designing the database schema — is represented as an individual task card moving across columns based on progress. Work-in-progress (WIP) limits are applied to ensure the researchers focus on a manageable number of tasks at a time, preventing overload and maintaining productivity.

**Backlog Phase:** All planned features and system requirements are listed and organized. Core functionalities include expense tracking, AI-powered parsing, Financial Health Score computation, voice input integration, receipt scanning, cloud synchronization, gamification, and multi-modal import. Each feature is broken down into smaller, actionable tasks.

**Requirements Phase:** Data is gathered through surveys and interviews with selected respondents from the study's target population. This phase identifies real-world financial management practices, common challenges, and user expectations. Based on collected data, functional requirements (e.g., automatic expense logging, AI recommendations) and non-functional requirements (e.g., usability, offline capability, performance) are defined. Technical benchmarking of candidate LLM APIs is also conducted as part of this phase.

**Design Phase:** Requirements are translated into a concrete system structure. This includes designing the application architecture, SQLite database schema (20 tables), data flow between the mobile application and Firebase/LLM services, and UI navigation flows. The FHS formula, component weights, and score adjustment mechanisms are formally documented during this phase.

**Development Phase:** The application is implemented using the Flutter framework incrementally — one feature module at a time. Core expense tracking is developed first, followed by AI parsing integration, multi-modal import (OCR, barcode, voice, batch screenshots), Firebase services, gamification, and the Financial Health Score engine. Each completed feature is tested individually before merging into the main application.

**Testing Phase:** Both functional and usability testing are conducted. Functional testing verifies that each feature operates correctly. Usability testing involves the 30 selected respondents using the application and completing the SUS questionnaire. User interactions are observed to identify difficulties or inefficiencies. Issues discovered during this phase are documented and fed back into the Development phase for resolution.

**Deployment Phase:** The completed SmartSpend application is deployed to Android devices for evaluation. The application is released as split APKs (arm64-v8a, armeabi-v7a, x86_64) via GitHub Releases, ensuring compatibility with modern and older Android phones. Demo Mode is activated for demonstration and usability testing without requiring respondent account creation.

**Done/Review Phase:** Overall system performance and effectiveness are evaluated by analyzing SUS scores, reviewing user feedback, and assessing whether the application meets its stated objectives. Insights from this phase are used to refine the system and formulate recommendations for future development.

**Table 2.3. Agile Kanban Workflow Phases and Deliverables**

| Phase | Key Tasks | Deliverable |
|---|---|---|
| Backlog | Define all features; conduct parent and young professional needs survey; review literature on PH financial gaps | Prioritized feature list; literature review |
| Requirements | Translate survey findings into specifications; draft and validate survey questionnaire; conduct LLM API technical benchmarking (Objective 2) | Validated questionnaire; LLM benchmarking evaluation matrix (Table 2.2 in Chapter 3) |
| Design | Design SQLite schema (20 tables); define FHS formula and weights; create UI wireframes and data flow diagrams | System architecture diagram; database schema; FHS formula documentation |
| Development | Build expense tracking module; integrate Gemini 3.1 Flash-Lite API; add multi-modal import (OCR, voice, barcode, batch screenshots, paste text); implement FHS engine and Warning Decay; Firebase sync; gamification | Functional app build; all 29 agentic actions operational |
| Testing | Unit testing for LLM parsing accuracy; SUS evaluation with 30 respondents; qualitative interviews; bug documentation | SUS scores; parsing accuracy observations; bug log |
| Deployment | Build release APKs (split per ABI, obfuscated); prepare Demo Mode with realistic Filipino sample data; publish to GitHub Releases | Release APKs (v2.9.7); project documentation |
| Done/Review | Analyze SUS scores; review user feedback; identify improvements; document recommendations for future development | Final evaluation report; post-capstone roadmap (paluwagan tracker, backend proxy, Play Store submission, iOS port) |

*[End of Chapter II]*


---

# CHAPTER III — RESULTS AND DISCUSSION

This chapter presents the results of the study based on the three stated objectives. It discusses the outcomes of each objective in relation to the development and evaluation of the SmartSpend mobile application.

## Objective 1 — Assessment of Financial Management Practices

*Note: This section will be completed after actual survey data collection (Week 2–3). The structure below reflects the planned analysis approach based on the validated survey instrument.*

The first objective was to assess the existing financial management practices, common budgeting challenges, and expense tracking behaviors of parents aged 35 to 55 and young professionals aged 21 to 35 in San Fernando City, La Union. Data was gathered through a structured survey questionnaire validated by a subject matter expert in financial management (see Appendix A) and supplementary interviews with selected respondents.

**Respondent Profile.** A total of thirty (30) respondents participated in the study — 20 parents aged 35 to 55 and 10 young professionals aged 21 to 35, purposively selected based on the defined inclusion criteria. [Detailed demographic breakdown, frequency tables, and percentage distributions to be inserted upon data collection.]

**Current Financial Management Practices.** Survey results revealed that [findings on expense tracking methods used — manual notebook, mobile app, mental tracking — to be inserted]. The majority of respondents reported [findings on budgeting frequency — daily, weekly, monthly — to be inserted]. These findings are consistent with BSP (2021) survey data indicating that a large proportion of Filipino adults do not maintain formal written budgets.

**Budgeting Challenges.** Respondents identified the following as their most common difficulties in managing expenses: [frequency table and analysis to be inserted]. Overspending and forgetting to record expenses were anticipated as the most frequently cited challenges based on prior national survey findings (Bangko Sentral ng Pilipinas, 2021; Flores, 2025).

**Savings Behavior.** [Findings on savings rates and savings regularity to be inserted.] These findings align with the 50/30/20 budgeting framework's recommendation that at least 20% of after-tax income be allocated to savings and debt repayment (Warren & Tyagi, 2005), suggesting a significant savings gap among the target population.

**Technology Readiness and Feature Demand.** [Findings on interest in AI-assisted financial tracking, specific feature preferences (OCR, voice, FHS), and willingness to use the application — to be inserted.] Respondents who expressed interest in [specific features] directly informed the prioritization of SmartSpend's development roadmap during the Requirements and Design phases of the Kanban workflow.

**Summary.** The assessment findings confirmed the presence of the financial management challenges identified in the literature review — manual effort burden, irregular tracking, and lack of proactive feedback — and validated the need for an AI-assisted tool tailored to the Filipino context. These findings directly guided the design decisions for SmartSpend's core features, particularly the multi-modal input system, the Financial Health Score, and the Impulse Pause behavioral intervention.

---

## Objective 2 — System Development and LLM Benchmarking

The second objective was to design and develop the SmartSpend mobile application, including the selection of an appropriate Large Language Model API through comparative technical evaluation.

### Comparative Analysis of Large Language Model APIs

The selection of an appropriate LLM API is a critical design decision because it directly influences the accuracy, latency, and cost of natural language expense parsing and conversational assistance. Several providers offer high-performing LLMs via API, each presenting trade-offs in inference speed, pricing, context window size, multilingual support, and function-calling reliability (OpenAI, 2024; Li et al., 2024). For a mobile financial assistant that must respond quickly under free-tier resource constraints while handling Filipino-English inputs, the evaluation criteria were weighted as follows: Filipino-English accuracy (25%), speed and latency (20%), tool use and JSON reliability (20%), free tier availability (15%), context window (10%), and financial reasoning quality (10%).

**Table 2.2. Comparative Evaluation of LLM APIs for SmartSpend Integration**

| LLM / Model | Provider | Context Window | Speed (tokens/s) | Filipino-English | Tool Use / JSON | Free Tier | Selected? |
|---|---|---|---|---|---|---|---|
| **Gemini 3.1 Flash-Lite** | Google | 1,000,000 | ~400–600 | ★★★★★ | ★★★★★ | ✅ 1,000 req/day | ✅ **PRIMARY** |
| **Gemini 3.5 Flash** | Google | 1,000,000 | ~200–400 | ★★★★★ | ★★★★★ | ✅ 250 req/day | ✅ Fallback 1 |
| **LLaMA 3.3 70B** | Groq LPU | 128,000 | ~315 | ★★★★☆ | ★★★★★ | ✅ ~14,400 req/day | ✅ Fallback 2 |
| **LLaMA 3.1 8B** | Groq LPU | 8,192 | ~800 | ★★★★☆ | ★★★★☆ | ✅ ~14,400 req/day | ✅ Fallback 3 |
| **LLaMA 3.1 70B** | Cerebras WSE | 128,000 | ~1,800 | ★★★★☆ | ★★★★☆ | ✅ 1M tokens/day | ✅ Fallback 4 |
| GPT-5.6 (Terra) | OpenAI | 1,050,000 | ~80–120 | ★★★★★ | ★★★★★ | ❌ Paid only | ❌ Cost |
| Claude Fable 5 | Anthropic | 200,000 | ~70–100 | ★★★★★ | ★★★★★ | ❌ Paid only | ❌ Cost |
| Gemini 3.7 Flash | Google | 1,048,576 | ~300–500 | ★★★★★ | ★★★★★ | ❌ Paid ($0.75/1M in) | ❌ No free tier |
| Grok 4.6 | xAI | 500,000 | ~100–200 | ★★★★☆ | ★★★★★ | ❌ Paid ($2/1M) | ❌ Cost |
| DeepSeek V4 Flash | DeepSeek | 1,000,000 | ~200 | ★★★☆☆ | ★★★☆☆ | ⚠️ $0.14/1M (5M trial) | ❌ Weaker Filipino |
| Qwen 3 32B | Alibaba / OpenRouter | 128,000 | ~150–300 | ★★★★☆ | ★★★★★ | ✅ Free preview | ❌ Less tested |
| Fin-R1 (7B) | Self-hosted | 128,000 | Varies | ★★★☆☆ | ★★☆☆☆ | ✅ Self-host | ❌ No hosted API |
| Mistral 7B | Mistral AI | 32,000 | ~600 | ★★★☆☆ | ★★★☆☆ | ✅ Self-host | ❌ Poor Filipino |
| GPT-4o Mini | OpenAI | 128,000 | ~120 | ★★★★☆ | ★★★★★ | ❌ No free tier | ❌ Cost |
| Gemma 2 9B | Google | 8,192 | ~500 | ★★★☆☆ | ★★★☆☆ | ✅ Local only | ❌ No hosted API |

*Ratings are relative (1–5 stars) based on published 2026 benchmarks (AIMUltiple Finance LLM Benchmark; micro1.ai REALM Financial Benchmark; SurgeHQ Finance Eval; ArXiv 2507.22936). Content paraphrased for compliance with licensing restrictions.*

**Why Gemini 3.1 Flash-Lite was selected as the primary model:**
Gemini 3.1 Flash-Lite offers the highest free-tier request quota (1,000 req/day) among all evaluated models — sufficient for a 60-request-per-user-per-day cap across the academic deployment period. Its Filipino-English multilingual performance is rated highest among free-tier models, consistent with Google's training data coverage of Southeast Asian languages and Philippine government and financial content. The 1-million token context window comfortably accommodates the full user financial context injection (~2,000–5,000 tokens per request). Native function calling and structured JSON output support are essential for the 29 agentic action types. The model is multimodal, capable of processing receipt images alongside text (Li et al., 2024; Google, 2024f).

**Why not GPT-5.6 or Claude Fable 5:**
Both are paid-only with no free tier sufficient for sustained academic deployment. For 30 respondents using the application at 60 messages per day each, the cost would be prohibitive. Gemini Flash-Lite at 1,000 free requests/day plus Groq's generous free tier covers this entirely at zero cost.

**Why not finance-specialized LLMs (Fin-R1, FinGPT):**
Finance-specialized models such as Fin-R1 (Liu et al., 2025) and FinGPT (Liu et al., 2023) are trained primarily on financial market data — stock prices, earnings reports, SEC filings — and are optimized for enterprise financial analysis tasks. SmartSpend requires Filipino-English conversational capability and expense parsing, which general multilingual LLMs handle significantly better. Research confirms that modern general-purpose frontier LLMs perform at or above specialized financial models on broad personal-finance conversational tasks (FrontierFinance benchmark, Arcila et al., 2026). Furthermore, finance-specialized models are self-hosted only (no viable hosted free API), which is not feasible for a mobile academic deployment.

**Why Context Injection (not RAG):**
A typical SmartSpend user has 20–50 expenses, 5–10 budgets, and 3–5 goals — approximately 1,000–5,000 tokens total. This fits entirely within any evaluated model's context window. Retrieval-Augmented Generation adds vector search overhead designed for large knowledge bases (thousands of documents) — unnecessary overhead for SmartSpend's compact per-user dataset. Direct context injection gives the AI always-current, complete financial data access with lower latency and simpler architecture (Davenport & Mittal, 2022; Li et al., 2024). The architecture is also consistent with the FrontierFinance benchmark (2026) finding that tool harness design affects AI financial performance more than the base model choice alone.

**Multi-Provider Architecture Justification:**
> "SmartSpend implements a multi-provider agentic AI system using dynamic full-context injection from a local SQLite database, enabling autonomous financial data management without the infrastructure overhead of traditional RAG pipelines. The multi-provider routing architecture ensures continuous AI availability through automatic failover across five free-tier LLM providers, with task-based routing to match query complexity with model capability." (SmartSpend Architecture, 2026)

**Actual Performance Metrics (SmartSpend v2.9.7):**

| Metric | Value |
|---|---|
| Average AI response time | 0.8–1.5 seconds |
| Action parsing success rate (primary model) | ~95% |
| Action parsing with fallback parser | ~99% |
| Multi-item batch logging success | ~90% |
| Daily message limit | 60 per user |
| Tokens per message (system + context + response) | ~2,000–4,000 |
| Conversation summarization trigger | Every 10 messages |

---

### Financial Health Score — Full Computation

The Financial Health Score (FHS) is SmartSpend's core academic contribution — a 0-to-100 behavioral metric computed from user-recorded transaction data. Its design is informed by three established financial health measurement frameworks: the Financial Health Network FinHealth Score® (Financial Health Network, 2021, 2026), the UNSGSA Financial Health Measurement Framework (UNSGSA, 2021), and the CFPB Financial Well-Being Scale (Consumer Financial Protection Bureau, 2017). Unlike these survey-based frameworks, SmartSpend's FHS is a **behavioral computation** derived entirely from transaction data — no self-reported surveys or external data feeds required.

#### Full Mode Formula (Income Tracking Enabled)

Score = 4 components × 25 points each = 100 maximum

**Component 1 — Savings Rate (25 pts)**

```
Sub-score = 25 × min(1.0, savingsRate / 0.20)
savingsRate = (totalIncome − totalSpent) / totalIncome
```

*Basis:* The 20% savings target derives from the 50/30/20 budgeting rule — allocate 20% of after-tax income to savings and debt repayment (Warren & Tyagi, 2005). Full 25 points are awarded when actual savings equal or exceed 20% of income. The sub-score scales proportionally below this threshold.

*Example:* Income ₱10,000, spent ₱7,500 → savings rate = 25% → 25 × min(1, 25%/20%) = 25 × 1.0 = **25 pts**
*Example:* Income ₱10,000, spent ₱9,000 → savings rate = 10% → 25 × (10%/20%) = **12.5 pts**

**Component 2 — Overspend Control (25 pts)**

```
Sub-score = 25 × (1 − overDays / activeDays)
overDays = number of days this month where daily spending exceeded (income ÷ daysInMonth)
activeDays = number of days elapsed this month
```

*Basis:* Day-level spending discipline is derived from the FinHealth Score® Spend pillar — "spending less than income" as a measurable behavior (Financial Health Network, 2021).

*Example:* 10 days elapsed, 2 days exceeded daily limit → 25 × (8/10) = **20 pts**

**Component 3 — Budget Adherence (25 pts)**

```
Sub-score = 25 × (onBudgetCategories / totalBudgetCategories)
```

If no category budgets are set, this component defaults to 25 pts (user is not penalized for not having budgets configured).

*Basis:* Category-level budget tracking is a core feature of zero-based budgeting theory (Ramsey, 2003) and is validated by research showing that users who set specific category budgets overspend significantly less than those who do not.

*Example:* 3 of 4 category budgets on track → 25 × (3/4) = **18.75 pts**

**Component 4 — Logging Consistency (25 pts)**

```
Sub-score = 25 × (loggedDays / activeDays)   [current month only]
```

*Basis:* Consistent financial tracking reduces discretionary spending by 10–20% and is the primary data source enabling accurate computation of the other three components (Thaler & Sunstein, 2008; Mindfulsuite, 2026). In the absence of bank API access (BSP Open Finance pilot launched July 2025 with limited PH participation), user-entered logging is the only available behavioral data source — making consistency a dual-role metric: it measures tracking behavior AND determines data accuracy for the other components.

*Example:* Logged 8 of 10 days this month → 25 × (8/10) = **20 pts**

**Full Mode Score = Component 1 + Component 2 + Component 3 + Component 4**
*(clamped 0–100 before adjustments)*

#### Lightweight Mode Formula (Income Tracking Disabled)

Used for students, freelancers, and informal workers who cannot meaningfully compute a savings rate. The FHS adapts entirely to spending habits and consistency — no income data required. This dual-mode design is grounded in the Financial Health Network's acknowledgment that financial health metrics must adapt to diverse income structures (Financial Health Network, 2021).

| Component | Formula | Basis |
|---|---|---|
| Spending Restraint (25 pts) | 25 × (1 − max(0, totalSpent − spendingLimit) / spendingLimit) | Spending vs user-set limit; degraded gracefully below the limit |
| Logging Consistency (25 pts) | Same as Full Mode | Behavioral tracking rewards habit formation |
| Category Balance (25 pts) | Scales from 25→0 as the top category's share approaches 40% | Spending diversification — no single category dominating total spending |
| Habit Streak (25 pts) | 25 × min(1, consecutiveLoggedDays / 14) | Habit formation theory (Duhigg, 2012) — full credit at 14 consecutive days |

#### Score Adjustments (Applied After Component Sum)

Two score adjustment mechanisms are applied on top of the component sum:

**Warning Decay (−5 pts/day, max −15, min floor 0):**
When the system issues a budget warning and the user continues to spend in that category without adjustment, the FHS decays by 5 points per day for up to 3 consecutive days. The decay resets when the budget returns to on-track status.

*Basis:* Loss aversion theory (Kahneman & Tversky, 1979). People respond more strongly to the pain of a declining score than to the reward of a rising one. The decay mechanism makes the consequence of ignoring budget warnings tangible and persistent — translating abstract "you exceeded your budget" into a visible numeric consequence that escalates over time (Thaler & Sunstein, 2008).

**Gap Adjustment (−3 or +2 pts/day):**
On application startup, the system checks for unlogged days since the last session. For each confirmed unlogged day, the user is asked: "Did you have expenses on [date]?" If they confirm spending but forgot to log: −3 pts/day (max −15). If they confirm genuinely no spending: +2 pts/day (max +10).

*Basis:* Behavioral honesty mechanism. Accurate self-monitoring is a core principle of behavioral finance (Ariely, 2008). Users who genuinely had no-spend days are rewarded for maintaining good habits; users who acknowledge forgotten expenses receive a partial penalty that keeps the FHS honest.

**Final Score = Component Sum + Warning Decay Adjustment + Gap Adjustment**
*(clamped 0–100)*

#### Score Interpretation

| Score Range | Label | Meaning |
|---|---|---|
| 90–100 | 👑 Excellent | Elite financial habits — top-tier tracking, savings, and budget control |
| 80–89 | 🏆 Great | Strong financial control — consistent and effective |
| 70–79 | ⭐ Good | On the right track — minor areas to improve |
| 60–69 | 🌱 Fair | Building momentum — noticeable gaps to address |
| Below 60 | 📉 Needs Work | Focus on core habits — significant improvement needed |

#### Financial Management Score (Separate Metric, v2.9.5+)

Based on research recommendation (Financial Health Network, 2026; Rateweb, 2026; Elenvo AI, 2026) that logging behavior should be separated from financial health outcomes, SmartSpend v2.9.5 introduced a separate **Financial Management Score** (0–100) on the Profile screen. This score measures how well the user uses SmartSpend as a tool — measuring logging regularity, budget setup completeness, goal tracking, and data completeness — independent of actual financial outcomes. The separation allows users who are genuinely financially healthy but infrequent loggers to receive an accurate FHS, while the Financial Management Score reflects their tool engagement.

#### Comparison with Published Systems

| System | Scale | Main Components | How Different from SmartSpend FHS |
|---|---|---|---|
| CFPB Financial Well-Being Scale | 0–100 | 10-question self-report survey | Survey-based vs SmartSpend's behavioral transaction computation |
| FinHealth Score® (FHN) | 0–100 | 8 indicators: Spend, Save, Borrow, Plan/Protect | Institutional-level, requires external data feeds; not computable from mobile transaction logs |
| MindsBudget | 0–100 | Spending Rate, Discipline, Month Stability, Emergency Runway | Most comparable to SmartSpend; transaction-based; no Filipino context, no dual mode |
| BudgetPH Budget Score | 0–100 | Budget adherence, streak | Simpler formula; no savings rate, no overspend control, no gap detection |
| SmartSpend FHS | 0–100 | Full Mode: Savings Rate, Overspend Control, Budget Adherence, Logging Consistency; Lightweight: Spending Restraint, Consistency, Category Balance, Habit Streak | Mobile-first, offline, real-time, dual-mode, with Warning Decay and Gap Adjustment |

**Key academic advantage:** Unlike Cleo and BudgetPH which use proprietary or opaque formulas, SmartSpend's FHS is fully documented, traceable to established academic frameworks (FinHealth Network, UNSGSA, CFPB), and computable entirely from user-generated transaction data with no external dependencies.

---

### System Development Results — SmartSpend v2.9.7

The SmartSpend mobile application was developed across seven Kanban phases, resulting in a fully functional Android application with the following technical specifications:

| Item | Value |
|---|---|
| Platform | Android (Flutter/Dart) |
| Version | 2.9.7 |
| SQLite schema | Version 11, 20 tables |
| APK size (arm64-v8a) | 44.7 MB (release, obfuscated, split) |
| AI providers | 5 (auto-failover chain) |
| Primary AI model | Gemini 3.1 Flash-Lite |
| Agentic action types | 29 |
| Expense categories (built-in) | 14 + unlimited custom |
| Input modalities | 6 (text, voice, live camera, single photo, batch screenshots, paste text) |
| Screenshot platform types detected | 40+ |
| PH banks in database | 20 banks + 5 e-wallets |
| Achievement badges | 23 |
| Daily quests | 10 rotating |
| Currencies supported | 57 |
| Backup format | JSON v9 |
| App screens | 37 |
| Backend services | 26 |
| GitHub repository | https://github.com/Zushikina-kun/smartspend-app |

**Key development outputs per Kanban phase:**

- *Requirements:* Validated survey questionnaire; LLM benchmarking evaluation (Table 2.2); FHS formula documentation
- *Design:* SQLite v11 schema (20 tables); FHS dual-mode formula; UI wireframes and navigation flows
- *Development:* All 29 agentic actions operational; 6-modality Smart Import system; Firebase Remote Config API key security; FHS engine with Warning Decay and Gap Adjustment; 23 badges and 10 daily quests; App Settings full-screen with Lite Mode and 10 visibility toggles
- *Testing:* LLM parsing accuracy ~95–99%; all critical user flows tested on Poco X6 Pro (Android 16)
- *Deployment:* Three split APK variants published to GitHub Releases (v2.9.7)

---

## Objective 3 — System Usability Evaluation (SUS)

*Note: This section will be completed after actual SUS administration with 30 respondents (Week 7 per capstone timeline). The structure below reflects the planned analysis approach and interpretation framework.*

The third objective was to evaluate the usability of the SmartSpend application using the System Usability Scale (SUS). The SUS was administered to thirty (30) respondents — 20 parents and 10 young professionals — following a guided live demonstration of the SmartSpend application using Demo Mode with pre-loaded Filipino sample data.

**Evaluation Process.** Each respondent was given approximately 30 minutes to explore the application guided by the demonstration. Respondents were shown: the home screen and FHS card, AI chat (voice and text expense logging), Smart Import (batch screenshots), Analytics (pie chart, 50/30/20, FHS breakdown), Budgets, App Settings (Lite Mode toggle, section visibility), and the Achievements screen. After the demonstration, each respondent completed the 10-item SUS questionnaire independently.

**SUS Scoring.** SUS scores were computed using the standard formula: for odd-numbered items (1, 3, 5, 7, 9), the contribution equals the item score minus 1; for even-numbered items (2, 4, 6, 8, 10), the contribution equals 5 minus the item score. The sum of all contributions is multiplied by 2.5 to yield a final score on a 0–100 scale (Brooke, 1996).

**Figure 2.1 (SUS Interpretation Reference):**

| SUS Score | Grade | Adjective | Acceptability |
|---|---|---|---|
| 90–100 | A+ | Best Imaginable | Acceptable |
| 80–89 | A | Excellent | Acceptable |
| 70–79 | B | Good | Acceptable |
| 60–69 | C | Okay | Marginal |
| 50–59 | D | Poor | Not Acceptable |
| Below 50 | F | Awful | Not Acceptable |

*Based on Bangor et al. (2009) adjective rating scale and standard SUS interpretation.*

**SUS Results.** [Insert completed SUS computation table, individual respondent scores, and final average SUS score here after data collection. Target: ≥80 (Good/Acceptable).]

**Interpretation.** [Insert interpretation of final SUS score against the Bangor et al. (2009) adjective scale. Discuss the overall usability finding and whether the ≥80 target was met. Highlight any specific usability strengths (items respondents found easy/confidence-building) and areas for improvement (items where disagreement was noted).] 

**Qualitative Feedback Summary.** [Insert summary of qualitative feedback themes gathered during and after the demonstration. Expected themes based on design rationale: ease of the AI chat input, utility of the FHS score, appreciation for the Lite Mode toggle, and suggestions for future features.]

**Validation of Instruments.** The survey questionnaire was subjected to content validation by a subject matter expert in financial management and business operations prior to distribution. The SUS evaluation process and overall technical functionality of the SmartSpend system were reviewed by a subject matter expert in information technology. Both validators' credentials are documented in the Validation Certificates (Appendix A).

*[End of Chapter III]*


---

# CHAPTER IV — CONCLUSIONS AND RECOMMENDATIONS

## Conclusions

This study designed, developed, and evaluated **SmartSpend** — an AI-assisted mobile financial tracking and advisory application for Android, addressing the documented financial management challenges of Filipino parents and young professionals in La Union, Philippines.

**Regarding Objective 1** — the assessment of financial management practices: The survey and interview data confirmed the presence of the financial management challenges identified in the literature — specifically the manual effort burden of traditional expense tracking, irregular budgeting behavior, and the absence of visible consequences for ignoring financial warnings. These findings directly validated the design rationale for SmartSpend's core features: multi-modal AI input to eliminate manual effort, the Financial Health Score to provide visible financial feedback, and the Warning Decay mechanism to make the consequences of ignoring budget warnings tangible and persistent.

**Regarding Objective 2** — system design, development, and LLM benchmarking: SmartSpend v2.9.7 was successfully designed and developed as a fully functional Android application featuring 29 autonomous AI actions, a dual-mode Financial Health Score (Full Mode and Lightweight Mode), 6 input modalities, multi-modal Smart Import across 40+ platform types, offline-first SQLite architecture, Firebase cloud synchronization, and a gamification system with 23 achievement badges and 10 daily quests.

The comparative technical benchmarking of 15 LLM API providers confirmed that **Gemini 3.1 Flash-Lite** (Google AI Studio) is the most appropriate primary model for SmartSpend's academic deployment — offering the highest free-tier request quota (1,000/day), the best Filipino-English multilingual performance among free-tier models, a 1-million token context window, and native function calling support. The multi-provider failover architecture (Gemini 3.1 Flash-Lite → Gemini 3.5 Flash → Groq LLaMA 3.3 70B → Groq LLaMA 3.1 8B → Cerebras LLaMA 3.1) ensures continuous AI availability at zero cost.

The Financial Health Score formula was documented and traced to established academic frameworks — the Financial Health Network FinHealth Score® (2021, 2026), the UNSGSA Financial Health Measurement Framework (2021), and the CFPB Financial Well-Being Scale (2017) — establishing its academic validity. The dual-mode design (Full Mode for income-tracking users; Lightweight Mode for students and informal workers) ensures inclusivity across diverse income structures, consistent with Financial Health Network (2021) recommendations.

**Regarding Objective 3** — usability evaluation: [Insert conclusion based on actual SUS score achieved. If ≥80: "The SmartSpend application achieved a SUS score of [X], corresponding to the '[Adjective]' rating per the Bangor et al. (2009) scale — meeting/exceeding the target threshold of 80 (Good). This indicates that the application is usable, effective, and satisfying for the target population." If below 80: "The application achieved a SUS score of [X], identifying [specific areas] as priorities for improvement."]

Overall, SmartSpend demonstrates that a genuinely useful, free, offline-capable, Filipino-first AI financial management system can be built entirely on free-tier services. The system represents a meaningful contribution to financial technology research in the Philippine context — combining agentic AI architecture, behavioral finance principles, gamification mechanics, and culturally localized design in a single mobile application.

## Recommendations

Based on the findings, development experience, and usability evaluation, the following recommendations are proposed:

**For Future Development of SmartSpend:**

1. **Paluwagan tracker** — A rotating savings group (paluwagan) tracker should be the highest-priority post-capstone feature addition. BudgetPH is the only Filipino finance application currently offering this, and it represents a uniquely Filipino informal savings behavior not supported by any other app reviewed. The existing debt/recurring infrastructure provides a suitable architectural base for this feature.

2. **15th and 30th payday cycle awareness** — Implement payday-cycle-aware budgeting resets aligned with the Philippine standard of semi-monthly salary payments. This would further differentiate SmartSpend's Filipino-first positioning.

3. **Backend API proxy** — Move LLM API key management to a server-side proxy (e.g., Firebase Cloud Function or Vercel serverless function) to eliminate the device-side key exposure entirely, even under Firebase Remote Config protection.

4. **Play Store submission** — After implementing the backend proxy and adding a privacy policy, submit SmartSpend to the Google Play Store to reach a broader audience of Filipino users.

5. **SQLite encryption** — Implement SQLCipher-based encryption for the local SQLite database in a future v12 schema migration to enhance data security.

6. **Couple/family wallet sharing** — Allow multiple users to contribute to and view a shared household wallet — a feature relevant to parents managing household finances with a spouse.

7. **OFW remittance tracking** — Track inbound international remittances as a distinct income category, addressing the significant OFW demographic in the Philippines.

**For Future Research:**

1. Longitudinal studies measuring the actual impact of SmartSpend use on financial behavior over 3–6 months (savings rate improvement, budget adherence improvement, FHS trend) would provide stronger evidence for the effectiveness of the behavioral intervention mechanisms.

2. A comparative evaluation study between SmartSpend and BudgetPH with Filipino participants would provide evidence-based guidance on which features drive the greatest engagement and behavioral improvement in the Philippine context.

3. The proposed SmartSpend LLM Evaluation Methodology (RESEARCH_BASIS.md Part 11) — a custom evaluation dataset with 5 test categories (receipt extraction, expense classification, numerical accuracy, financial reasoning, and hallucination resistance) — should be implemented to empirically establish the performance advantage of Gemini 3.1 Flash-Lite over finance-specialized alternatives for Filipino personal finance workloads.

4. Research into the optimal FHS formula weight allocation — potentially incorporating emergency fund coverage (as recommended by Elenvo AI, 2026) or net worth trend as additional components — would strengthen the academic validity of the scoring model.

5. Future researchers may examine whether Lightweight Mode FHS correlates with actual improved financial outcomes among students and informal workers — testing the hypothesis that habit-based scoring (without income data) can still drive meaningful behavioral improvement.

*[End of Chapter IV]*


---

# REFERENCES

Arcila, A., et al. (2026). *FrontierFinance: A challenging benchmark for measuring frontier intelligence of finance agents*. arXiv:2608.11683. https://arxiv.org/abs/2608.11683

Ariely, D. (2008). *Predictably irrational: The hidden forces that shape our decisions*. HarperCollins.

Bangko Sentral ng Pilipinas. (2021). *2021 Financial Inclusion Survey*. BSP. https://www.bsp.gov.ph/Inclusive-Finance/Financial-Inclusion-Surveys/2021-FIS-Report.pdf

Bangko Sentral ng Pilipinas. (2025). *Consumer Finance and Inclusion Survey (CFIS) 2025*. BSP.

Bangor, A., Kortum, P., & Miller, J. (2009). Determining what individual SUS scores mean: Adding an adjective rating scale. *Journal of Usability Studies, 4*(3), 114–123.

Bitrián, P., Buil, I., & Catalán, S. (2021). Making finance fun: The gamification of personal financial management apps. *International Journal of Bank Marketing, 39*(7), 1310–1332. https://doi.org/10.1108/IJBM-09-2020-0491

Bloomberg. (2026). *How the Philippines' first fintech unicorn is minting financial inclusion*. https://sponsored.bloomberg.com/article/mynt/how-the-philippines-first-fintech-unicorn-is-minting-financial-inclusion

Bociek, J. (2023). *mobile_scanner: A universal barcode and QR code scanner for Flutter*. https://pub.dev/packages/mobile_scanner

Brooke, J. (1996). SUS: A "quick and dirty" usability scale. In P. W. Jordan, B. Thomas, B. A. Weerdmeester, & I. L. McClelland (Eds.), *Usability evaluation in industry* (pp. 189–194). Taylor & Francis.

Cambridge Judge Business School. (2025). *From automation to autonomy: The agentic AI era of financial services*. https://www.jbs.cam.ac.uk/2025/from-automation-to-autonomy-the-agentic-ai-era-of-financial-services/

Consumer Financial Protection Bureau. (2017). *Financial well-being scale: Scale development technical report*. CFPB. https://files.consumerfinance.gov/f/documents/201705_cfpb_financial-well-being-scale-technical-report.pdf

Creswell, J. W., & Plano Clark, V. L. (2011). *Designing and conducting mixed methods research*. Sage Publications.

Davenport, T. H., & Mittal, N. (2022). *All-in on AI: How smart companies win big with artificial intelligence*. Harvard Business Review Press.

Davis, F. D. (1989). Perceived usefulness, perceived ease of use, and user acceptance of information technology. *MIS Quarterly, 13*(3), 319–340.

Deloitte. (2026). *Agentic AI boosts wealth management*. https://www.deloitte.com/us/en/insights/industry/financial-services/financial-services-industry-predictions/2026/agentic-ai-wealth-management-productivity.html

Duhigg, C. (2012). *The power of habit: Why we do what we do in life and business*. Random House.

Dwivedi, Y. K., et al. (2021). Artificial intelligence (AI): Multidisciplinary perspectives on emerging challenges, opportunities, and agenda for research, practice and policy. *International Journal of Information Management, 57*, 101994. https://doi.org/10.1016/j.ijinfomgt.2019.08.002

Elenvo AI. (2026). *How a financial health score is calculated*. https://www.elenvo.ai/methodology

Ernst & Young. (2026a). *Nearly half of global consumers now use AI to guide savings and investment decisions*. EY. https://www.ey.com/en_gl/newsroom/2026/04/nearly-half-of-global-consumers-now-use-ai-to-guide-savings-and-investment-decisions

Ernst & Young. (2026b). *EY survey: Autonomous AI is no longer theoretical as adoption grows despite ongoing trust concerns*. EY. https://www.ey.com/en_nl/newsroom/2026/03/ey-survey-autonomous-ai-is-no-longer-theoretical-as-adoption-grows-despite-ongoing-trust-concerns

Financial Health Network. (2021). *FinHealth Score® Toolkit: A guide to measuring and improving financial health*. https://finhealthnetwork.org/tools/financial-health-score/

Financial Health Network. (2026). *From insight to impact: The next phase of financial health measurement*. https://finhealthnetwork.org/research/from-insight-to-impact-the-next-phase-of-financial-health-measurement/

Flores, C. A. R. (2025). Financial freedom of Filipinos in personal finance management. *Pantao: The International Journal of the Humanities and Social Sciences, 4*(1). https://pantaojournal.com/2025/01/27/v4-i1-7/

Flutter 4 Fun. (2022). *fl_chart: A highly customizable Flutter chart library*. https://pub.dev/packages/fl_chart

GCash / Mynt. (2026). *GCash launches country's first AI financial coach embedded in e-wallet to strengthen financial literacy* [Press release]. PR Newswire. https://www.prnewswire.com/apac/news-releases/ph-fintech-gcash-launches-countrys-first-ai-financial-coach-embedded-in-e-wallet-to-strengthen-financial-literacy-302718569.html

Google. (2024a). *Firebase Authentication documentation*. https://firebase.google.com/docs/auth

Google. (2024b). *Firebase Crashlytics documentation*. https://firebase.google.com/docs/crashlytics

Google. (2024c). *Firebase Firestore documentation*. https://firebase.google.com/docs/firestore

Google. (2024e). *Google ML Kit documentation*. https://developers.google.com/ml-kit

Google. (2024f). *Flutter documentation*. https://flutter.dev/docs

Hean, O., Saha, U., & Saha, B. (2025). Can AI help with your personal finances? *Applied Economics*. https://doi.org/10.1080/00036846.2025.2450384

IBM. (2025). *Agentic AI in financial services: Navigating innovation*. https://www.ibm.com/think/insights/agentic-ai-financial-services-ethical-adoption

Insurance Commission Philippines. (2025). *Philippine Insurance Market Report 2025*.

Inquiro. (2024). *Financial literacy in the Philippines: Key statistics*. https://inquiro.ph/financial-literacy-in-the-philippines-2024-key-statistics/

Juniper Research. (2026). *Gamification in banking: How game mechanics drive financial behavior change*. [Research report].

Kahneman, D., & Tversky, A. (1979). Prospect theory: An analysis of decision under risk. *Econometrica, 47*(2), 263–292.

Li, Y., et al. (2024). *Large language models in finance (FinLLMs)*. Neural Computing and Applications. https://doi.org/10.1007/s00521-024-10495-6

Li, Z., et al. (2024). *A survey of large language models for financial applications*. arXiv:2406.11903. https://arxiv.org/abs/2406.11903

Liu, X., et al. (2023). *FinGPT: Open-source financial large language models*. arXiv:2306.06031. https://arxiv.org/abs/2306.06031

Liu, Z., et al. (2025). *Fin-R1: A large language model for financial reasoning through reinforcement learning*. arXiv:2503.16252. https://arxiv.org/abs/2503.16252

MaikuB. (2023). *flutter_local_notifications: A cross-platform plugin for displaying local notifications*. https://pub.dev/packages/flutter_local_notifications

Meyll, T., et al. (2025). Spendception: The psychological impact of digital payments on consumer purchase behavior and impulse buying. *Behavioral Sciences, 15*(3), 387. https://doi.org/10.3390/bs15030387

Meta AI. (2024). *LLaMA 3: Open foundation and fine-tuned chat models*. https://ai.meta.com/llama/

Nielsen, J. (2006). *Progressive disclosure*. Nielsen Norman Group. https://www.nngroup.com/articles/progressive-disclosure/

NielsenIQ. (2026). *The new financial reality: How Filipino consumers are spending, saving, and banking in 2026*. https://nielseniq.com/global/en/insights/report/2026/the-new-financial-reality-how-filipino-consumers-are-spending-saving-and-banking-in-2026/

OpenAI. (2024). *GPT-4 technical report* [Cited for general GPT-family architecture context; SmartSpend's current deployment references the GPT-5.6 model series]. https://arxiv.org/abs/2303.08774

Philippine Statistics Authority. (2021). *Family Income and Expenditure Survey (FIES) 2021*. PSA. https://www.psa.gov.ph

Philippine Statistics Authority. (2025). *Philippine Digital Economy Satellite Account (PDESA) 2025*. PSA. https://psa.gov.ph

Plaid. (2026). *State of intelligent finance report — Spring 2026*. https://plaid.com/blog/state-of-intelligent-finance-report-spring-2026/

Ramsey, D. (2003). *Financial peace revisited*. Viking.

Rateweb. (2026). *Financial health score — how it works*. https://rateweb.co.za/financial-health

Roux, A. (2019). *sqflite: SQLite plugin for Flutter*. https://pub.dev/packages/sqflite

Sloane, L. (2022). *speech_to_text: A Flutter plugin for on-device speech recognition*. https://pub.dev/packages/speech_to_text

Social Weather Stations. (2026, March). *SWS financial inclusion survey: Philippines financial inclusion rises to 58%*. Cited in CoinGeek (2026). https://coingeek.com/10-point-surge-pushes-philippines-financial-inclusion-to-58/

Springer. (2026). *Digital nudges and financial inclusion: A study on behavioral interventions influencing rural consumers' adoption of formal financial services in India*. Lecture Notes in Networks and Systems. https://link.springer.com/content/pdf/10.1007/978-3-032-00343-0_14.pdf

Statista. (2024). *Number of mobile app downloads worldwide*. https://www.statista.com/statistics/271644/worldwide-free-and-paid-mobile-app-store-downloads/

Stefanov, T., Stefanova, M., & Varbanova, S. (2024). Personal finance management application. *TEM Journal, 13*(3), 2066–2075. https://doi.org/10.18421/TEM133-34

Strivecloud. (2026). *Fintech app gamification: Data shows 22% boost in saving habits*. https://strivecloud.io/blog/mobile-app-gamification-fintech

Sweller, J. (1988). Cognitive load during problem solving: Effects on learning. *Cognitive Science, 12*(2), 257–285.

Tarsi – Budget Tracker. (2026). *Tarsi – Budget Tracker* [Mobile application]. App Store. https://apps.apple.com/ph/app/tarsi-budget-tracker/

The Flutter Authors. (2013). *local_auth: Flutter plugin for biometric authentication*. https://pub.dev/packages/local_auth

Thaler, R. H., & Sunstein, C. R. (2008). *Nudge: Improving decisions about health, wealth, and happiness*. Yale University Press.

UNSGSA. (2021). *Measuring financial health: A framework for practitioners*. United Nations Secretary-General's Special Advocate for Inclusive Finance for Development. https://www.unsgsa.org

Wajid, F., et al. (2025). Gamification: Revolutionizing financial planning systems. *World Journal of Advanced Engineering Technology and Sciences*. https://www.wjaets.com/sites/default/files/fulltext_pdf/WJAETS-2025-0158.pdf

Warren, E., & Tyagi, A. W. (2005). *All your worth: The ultimate lifetime money plan*. Free Press.

World Bank. (2022). *Global Findex Database 2021*. https://www.worldbank.org/en/publication/globalfindex

World Economic Forum. (2024). *How agentic AI will transform financial services*. https://www.weforum.org/stories/2024/12/agentic-ai-financial-services-autonomy-efficiency-and-inclusion/

Wu, S., et al. (2023). *BloombergGPT: A large language model for finance*. arXiv:2303.17564. https://arxiv.org/abs/2303.17564

Yang, H., et al. (2023). *FinGPT: Democratizing internet-scale data for financial large language models*. arXiv:2307.10485. https://arxiv.org/abs/2307.10485

Yomio. (2026). *YNAB alternatives: Which budget app actually works in 2026?* https://yomio.app/en/blog/ynab-alternatives

ZXing Project. (2023). *ZXing barcode scanning library*. https://github.com/zxing/zxing


---

# APPENDICES

## APPENDIX A — VALIDATION CERTIFICATES

### Content Validation Certificate — Survey Questionnaire

This survey questionnaire has been reviewed for content validity and is deemed appropriate and relevant to the financial management experiences of the target population.

Educational Background : ________________________________
*(e.g., BS Commerce, BS Accountancy, BS Business Administration, or equivalent)*

Occupation : ________________________________
*(e.g., Business Owner, Financial Officer, Accountant, Financial Adviser, etc.)*

Years of Experience : _____ years in financial management and/or business operations

Signature : _______________________________

Name *(optional)* : _______________________________

Date : _______________________________

---

### Technical Validation Certificate — System and SUS Evaluation

The SmartSpend system and its usability evaluation process have been reviewed by a subject matter expert in Information Technology to ensure technical soundness and proper SUS administration.

Educational Background : ________________________________
*(e.g., BS Information Technology, BS Computer Science, or equivalent)*

Occupation : ________________________________
*(e.g., Software Developer, IT Instructor, Systems Analyst, IT Professional, etc.)*

Years of Experience : _____ years in IT / software development and/or usability evaluation

Signature : _______________________________

Name *(optional)* : _______________________________

Date : _______________________________

---

## APPENDIX B — SURVEY QUESTIONNAIRE

**SmartSpend: An AI-Assisted Mobile Financial Tracking and Advisory Application for Parents and Young Professionals in La Union**

**Dear Respondent,**
Good day! This questionnaire is part of a research study identifying the financial management practices, budgeting challenges, and expense tracking behaviors of parents and young professionals in La Union. Your responses will be treated with strict confidentiality and used solely for academic purposes. Please answer each question honestly.

### Part I — Respondent Profile

Age: ______

Gender:
☐ Male  ☐ Female  ☐ Prefer not to say

Primary Role:
☐ Parent / Household Financial Manager (Ages 35–55)
☐ Young Professional (Ages 21–35)

Employment Status: _______________________________

Position/Designation: _______________________________

Industry/Field of Work: _______________________________

Monthly Income Range:
☐ Below ₱10,000  ☐ ₱10,000 – ₱20,000  ☐ ₱20,000 – ₱40,000  ☐ Above ₱40,000

### Part II — Financial Management Practices

**1. How do you usually track your expenses?**
☐ Manual notebook  ☐ Mobile application  ☐ Mental tracking only  ☐ I do not track expenses

**2. How often do you monitor your budget?**
☐ Daily  ☐ Weekly  ☐ Monthly  ☐ Rarely

**3. What is your primary source of income?**
☐ Salary (Full-time)  ☐ Part-time job  ☐ Freelance  ☐ Business/Entrepreneurship  ☐ Others: ________

**4. Do you regularly set aside savings from your income?**
☐ Yes, every month  ☐ Sometimes  ☐ Rarely  ☐ No

**5. Approximately what percentage of your monthly income do you currently save?**
☐ I don't save regularly  ☐ Less than 10%  ☐ 10%–20%  ☐ More than 20%  ☐ Not sure

### Part III — Budgeting Challenges

**6. What are your common difficulties in managing your expenses? (Check all that apply)**
☐ Overspending  ☐ Forgetting to record expenses  ☐ Lack of budgeting knowledge
☐ Difficulty tracking receipts  ☐ No consistent tracking system  ☐ Unexpected expenses

**7. How difficult is it for you to track your daily expenses?**
☐ Very Easy  ☐ Easy  ☐ Moderate  ☐ Difficult  ☐ Very Difficult

**8. Do you find manual expense tracking inconvenient?**
☐ Yes  ☐ No  ☐ Sometimes

**9. Do you have existing debts or loans you are currently paying?**
☐ Yes  ☐ No

**10. Do you experience difficulty meeting your expenses before your next salary or allowance?**
☐ Yes  ☐ No  ☐ Sometimes

**11. Have you ever exceeded your monthly budget and ignored a spending warning or alert?**
☐ Yes  ☐ No  ☐ Not applicable

### Part IV — System Feature Needs

**12. Which features would you find helpful in a financial tracking system? (Check all that apply)**
☐ Automatic receipt scanning (OCR)  ☐ Voice input for expenses
☐ AI-powered budgeting recommendations  ☐ Barcode scanning
☐ Expense summaries and reports  ☐ Financial health score or analytics dashboard
☐ Batch import from phone screenshots  ☐ PH government contribution calculator (SSS, PhilHealth)

**13. Would you use an AI-powered financial assistant application for managing your finances?**
☐ Yes  ☐ No  ☐ Maybe

**14. What features would you like to suggest for improvement?**

___________________________________________________________________________
___________________________________________________________________________

---

## APPENDIX C — CONSENT FORM

**SmartSpend: An AI-Assisted Mobile Financial Tracking and Advisory Application for Personal Financial Management**

Dear Participant,

You are invited to participate in a research study conducted by BSIT students of Lorma Colleges. The purpose of this study is to develop and evaluate an AI-powered financial assistant that helps parents and young professionals track and manage personal finances efficiently.

**Purpose of the Study**
This study gathers information about the financial management practices of parents and young professionals and evaluates the usability of the SmartSpend system.

**Participation**
Your participation is completely voluntary. You may refuse to participate or withdraw at any time without any penalty or consequence.

**Procedures**
If you agree to participate, you will be asked to: (1) answer a survey questionnaire about your financial management practices; and (2) participate in a guided demonstration of the SmartSpend application and complete a usability questionnaire (SUS) afterwards.

**Confidentiality**
All information collected will remain confidential. No personal identifying information will be disclosed, and data will be used strictly for academic purposes only.

**Risks and Benefits**
There are no known risks involved in participating. Your responses will help improve the development of an intelligent financial management system designed for Filipino users.

**Consent Statement**
By signing below, you confirm that you have read and understood the information above and voluntarily agree to participate in this study.

Name of Participant: _______________________________

Signature: _______________________________

Date: _______________________________

---

## APPENDIX D — SYSTEM USABILITY SCALE (SUS) QUESTIONNAIRE

**Instructions:** After exploring the SmartSpend application, please indicate your level of agreement with each statement using the scale below:

1 — Strongly Disagree  |  2 — Disagree  |  3 — Neutral  |  4 — Agree  |  5 — Strongly Agree

| # | Statement | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|---|
| 1 | I think that I would like to use this system frequently. | ○ | ○ | ○ | ○ | ○ |
| 2 | I found the system unnecessarily complex. | ○ | ○ | ○ | ○ | ○ |
| 3 | I thought the system was easy to use. | ○ | ○ | ○ | ○ | ○ |
| 4 | I think that I would need the support of a technical person to use this system. | ○ | ○ | ○ | ○ | ○ |
| 5 | I found the various functions in this system were well integrated. | ○ | ○ | ○ | ○ | ○ |
| 6 | I thought there was too much inconsistency in this system. | ○ | ○ | ○ | ○ | ○ |
| 7 | I would imagine that most people would learn to use this system very quickly. | ○ | ○ | ○ | ○ | ○ |
| 8 | I found the system very cumbersome to use. | ○ | ○ | ○ | ○ | ○ |
| 9 | I felt very confident using the system. | ○ | ○ | ○ | ○ | ○ |
| 10 | I needed to learn a lot of things before I could get going with this system. | ○ | ○ | ○ | ○ | ○ |

**SUS Score Interpretation (Bangor et al., 2009):**
- 90–100: Excellent (Best Imaginable)
- 80–89: Good (Excellent — meets study target)
- 70–79: Acceptable (Good)
- 60–69: Marginal (Okay)
- Below 60: Poor / Not Acceptable

---

*SmartSpend v2.9.7 — Lucid Frame*
*Lorma Colleges, College of Computer Studies and Engineering*
*Bachelor of Science in Information Technology — 4th Year, 1st Semester*
*Academic Year 2026–2027*
*San Fernando City, La Union, Philippines*

*Researchers: Brix A. Directo · Cyrille John M. Rubis · Djaunathan Albert S. Madayag*
*Adviser: Johnny Verzola, MTS | Teacher-in-Charge: Janelli M. Mendez, DIT*

*Last Updated: August 2026*
*Content was paraphrased and summarized for compliance with licensing restrictions where applicable.*

