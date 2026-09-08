# SmartSpend Thesis Documentation: Abstract & Chapter I (Introduction)

## Capstone Research Abstract

**Title:** SmartSpend: An AI-Assisted Mobile Financial Tracking and Advisory Application for Personal Financial Management  
**Researchers:** Directo, Brix A., Rubis, Cyrille John M., and Madayag, Djaunathan Albert S.  
**Adviser:** Mr. Johnny Flores Verzola, MTS  
**Chairperson:** Ms. Ellen F. Mangaoang, MIT  
**Institution:** College of Computer Studies and Engineering, Lorma Colleges, San Fernando City, La Union, Philippines  
**Degree:** Bachelor of Science in Information Technology  

---

### Abstract

Financial mismanagement remains a pervasive and documented challenge among Filipino households, compounded by a critical gap in accessible, localized, and behaviorally supportive digital tracking tools [576]. This study designed, developed, and evaluated **SmartSpend**, an AI-assisted, offline-first mobile financial tracking and advisory application built on the Flutter framework for Android devices [566, 583]. Designed for parents aged 35–55 as the primary financial decision-makers, and early-career young professionals aged 21–35 in La Union, Philippines [566, 591], the application integrates a multi-provider agentic Large Language Model (LLM) architecture—featuring **Gemini 3.1 Flash-Lite** as the primary engine—enabling 31 conversational actions for automated transaction parsing, data query, and non-prescriptive financial education [567, 592]. To address logging friction, SmartSpend integrates Google ML Kit OCR and an automated multimodal screenshot importer supporting 40+ local platforms (including GCash, Shopee, and Maya) [567, 583]. 

A core contribution of this study is the programmatic **Financial Health Score (FHS)**, designed as a custom **Observed Financial Health Indicator (FHI)** [545] computed in two modes: Full Mode (Savings Rate, Overspend Control, Budget Adherence, and Logging Consistency) and Lightweight Mode (Spending Restraint, Logging Consistency, Category Balance, and Habit Streak) [611]. Grounded in Self-Determination Theory (SDT) and Prospect Theory, the scoring incorporates a Warning Decay algorithm (−5 points/day) to enforce loss aversion, alongside Gap Detection and nudge mechanics [611, 645]. Usability was evaluated using the standardized 10-item System Usability Scale (SUS) with 30 purposively selected local respondents (20 parents, 10 young professionals), achieving a mean usability score exceeding the predefined threshold of $\ge 80$ (Good) [613]. Engineering performance was verified through localized Taglish OCR field precision, multi-locale categorization accuracy, and robust SQLite synchronization recovery under simulated low-connectivity states [556, 557]. This capstone establishes a scalable, privacy-preserving, and behaviorally optimized model for personal financial management within the Philippine mobile ecosystem [583, 652].

**Keywords:** personal finance management, agentic AI, large language model, financial health score, mobile application, Flutter, Filipino users, SmartSpend [568].

---

# CHAPTER I: INTRODUCTION

## Project Context

Personal financial mismanagement is a documented, systemic, and multi-layered socio-economic problem in the Republic of the Philippines. According to the 2021 Bangko Sentral ng Pilipinas (BSP) Financial Inclusion Survey, only **2%** of Filipino adults correctly answered all six basic financial literacy questions covering compounding interest, inflation, numeracy, and risk division [576]. Furthermore, less than half of the adult population reported maintaining any structured household or personal budget, with family finances managed primarily through ad-hoc, informal, and non-systematic methods [576]. The Family Income and Expenditure Survey (FIES), conducted by the Philippine Statistics Authority (PSA), reveals a chronic deficit in household savings [576]. Discretionary and recurring expenditures on household essentials (food, transportation, utilities, and debt servicing) consistently outpace disposable income, leaving Filipino households highly vulnerable to sudden macroeconomic contractions or unexpected household financial shocks [576].

Within Filipino households, parents aged 35 to 55 typically assume the responsibility of the primary financial manager and decision-maker [576, 598]. This demographic oversees complex daily budgeting, grocery tracking, utility payments, and tuition allocations [576]. Yet, empirical survey data from the BSP reveals that these primary decision-makers exhibit some of the lowest rates of formal financial account ownership and structured personal budgeting behavior across all adult demographics [576, 598]. Conversely, early-career young professionals aged 21 to 35 represent a growing demographic of digital-first mobile users in the formal workforce [615]. However, research indicates they frequently exhibit a "come-what-may" attitude toward long-term savings, characterized by high consumer debt dependence, peer-driven spending behaviors, and a reliance on informal lending channels (such as *utang* or borrowing from relatives) that escape systematic recording in traditional banking software [577, 578].

Despite a high mobile internet and smartphone penetration rate across urban and regional areas in the Philippines—including regional centers like San Fernando City, La Union [576, 591]—the adoption rate of digital personal financial management (PFM) software remains critically low [576]. Existing literature highlights three primary barriers to adoption among Filipino users:
1. **High Manual Entry Friction:** Traditional PFM tools rely entirely on manual, transaction-by-transaction text entry. Everyday users, juggling caregiving, employment, and household tasks, experience rapid cognitive fatigue and abandon manual logging within the first week of installation [578, 579].
2. **The Taglish and Local Context Gap:** Modern financial applications are built for Western markets with direct open-banking APIs and widespread bank-account connectivity [579]. In the Philippines, the financial landscape is highly fragmented, depending on e-wallets (GCash, Maya), bank transfers, and cash transactions. Moreover, global LLMs and PFM tools are trained on standard English market data and fail to parse Taglish (mixed Tagalog-English colloquial inputs) or localized e-wallet screenshots [580].
3. **The Lack of Proactive, Behavioral Choice Architecture:** Standard apps act as passive, retrospective mirrors that display historical charts of overspending [341, 578]. They do not actively nudge the user or implement consequences when budget alerts are repeatedly ignored [578].

SmartSpend directly addresses these localized, structural, and demographic barriers. It is designed not as a generic financial calculator, but as an **AI-assisted, offline-first personal financial tracker and behavioral counselor** [566, 583]. By leveraging **Gemini 3.1 Flash-Lite** [641], SmartSpend minimizes logging friction through localized, Taglish natural language conversational parsing, voice recording, Google ML Kit OCR receipt scanning, and a multi-modal batch screenshot importer that automatically recognizes 40+ distinct Philippine transaction formats [583, 608]. Furthermore, instead of displaying static, easily ignorable graphs, SmartSpend programmatically calculates a 0–100 **Financial Health Score (FHS)** that serves as an active, behavioral **Observed Financial Health Indicator (FHI)** [545, 611]. By implementing a **Warning Decay** mechanism rooted in Prospect Theory and Loss Aversion [611, 645], the app applies concrete, visual feedback to budget overruns—reducing the score programmatically if budget alerts are ignored—making the long-term consequences of current financial behaviors immediate and cognitively salient [645].

---

## Conceptual Framework

The conceptual design of SmartSpend is modeled around the **Input-Process-Output (IPO)** framework, which structures the relationship between user data collection, technical execution, and user-facing behavioral outputs:

```
+---------------------------------------------------------------------------------------------------------+
|                                           CONCEPTUAL FRAMEWORK                                          |
+------------------------------------+------------------------------------+-------------------------------+
| INPUT                              | PROCESS                            | OUTPUT                        |
+------------------------------------+------------------------------------+-------------------------------+
| - User Natural Language (Taglish)  | - Gemini 3.1 Flash-Lite Parsing    | - Auto-Categorized Expenses   |
| - Multimodal GCash/Maya Screenshots| - On-Device Regex Masking Layer    | - Interactive Analytics       |
| - Voice Input (en_PH Locale)       | - SQLite Transaction Logging       | - 0-100 Financial Health Score|
| - Camera Images of Paper Receipts  | - Warning Decay Score Calculations | - Non-Prescriptive AI Q&A     |
| - Configurable Budget Thresholds   | - Firebase Sync & Sync-Recovery    | - 23 Habit Achievement Badges |
+------------------------------------+------------------------------------+-------------------------------+
|                                      FEEDBACK / BEHAVIORAL LOOPS                                        |
|                     (Warning Decay, Loss Aversion, and Self-Monitoring Reminders)                       |
+---------------------------------------------------------------------------------------------------------+
```

### Theoretical Foundations
1. **Self-Determination Theory (SDT):** Grounded in the psychological needs of Autonomy, Competence, and Relatedness [35]. SmartSpend supports *Competence* through its 23 habit achievement badges and progress streaks [49, 597], *Autonomy* by providing non-prescriptive, customizable budget parameters [611], and *Relatedness* by framing financial tracking within local community realities [591, 598].
2. **Nudge Theory (Thaler & Sunstein, 2008):** Proposes that subtle choice architecture can guide individuals toward optimal choices without restricting freedom [34]. SmartSpend applies cognitive nudges through timely budget alerts, end-of-month balance projections, and spending restraint indicators [55, 611].
3. **Prospect Theory & Loss Aversion (Kahneman & Tversky, 1979):** Establishes that individuals are significantly more motivated to avoid losses than to achieve equivalent gains [645]. The FHS **Warning Decay** algorithm (−5 points per day, capped at −15) acts as an active loss nudge, applying a temporary reduction in the user’s overall score for ignored alerts, thereby breaking automation bias and promoting active budget self-regulation [611, 645].
4. **Technology Acceptance Model (TAM):** Evaluates user adoption based on Perceived Usefulness (PU) and Perceived Ease of Use (PEOU) [502, 596]. SmartSpend optimizes PEOU through its multimodal, low-friction entry mechanisms and local Taglish conversational interface [583, 596].

---

## Statement of Objectives

The primary objective of this study is to design, develop, and evaluate **SmartSpend**, an AI-assisted mobile personal financial tracking and advisory application built specifically for parents aged 35 to 55 and early-career young professionals aged 21 to 35 in San Fernando City, La Union, Philippines [591].

Specifically, the study aims to:

1. **Assess** the existing financial management practices, common budgeting challenges, and expense-logging behaviors of parents aged 35 to 55 and early-career young professionals aged 21 to 35 in San Fernando City, La Union, through validated structured needs-assessment surveys and interviews [592, 622].
2. **Design and Develop** the SmartSpend mobile application on the Flutter framework, integrating:
   * An offline-first SQLite database architecture with sqflite (v11) to ensure full functional continuity in regional areas with intermittent internet access [588, 602].
   * An intelligent multimodal import engine comprising Google ML Kit Latin-Script OCR, barcode scanning, and a bulk transaction parsing algorithm supporting 40+ local platforms [583, 608].
   * A programmatic 0–100 Financial Health Score (FHS) engine supporting both **Full Mode** (Savings Rate, Overspend Control, Budget Adherence, Logging Consistency) and **Lightweight Mode** (Spending Restraint, Logging Consistency, Category Balance, Habit Streak) [611].
   * A localized **Gemini 3.1 Flash-Lite** Large Language Model (LLM) API integration layer using full-context injection and local Taglish conversation-summarization algorithms, selected through a comparative technical evaluation of disponible API models [592, 604, 607].
3. **Evaluate** the usability, engineering performance, and responsible-AI safety parameters of SmartSpend:
   * Evaluating perceived usability among 30 purposively selected local respondents (20 parents, 10 young professionals) using the standardized 10-item System Usability Scale (SUS) under the Bangor et al. (2009) adjective rating scale [613].
   * Benchmarking engineering metrics, including:
     1. Localized Taglish OCR field precision and recall (Merchant, Amount, Date, Category) [556].
     2. Multi-locale transaction categorization accuracy across English, Tagalog, and colloquial Taglish inputs [556].
     3. Local database synchronization recovery and error handling under simulated network dropouts [556].
     4. LLM API token consumption, prompt caching efficiency, and refusal/hallucination rates [556].

---

## Scope and Limitations of the Study

### Scope of the System
* **Mobile Operating System:** The application is built natively for the Android platform using Google’s Flutter SDK to maximize performance and deployment availability across local, lower-to-mid-range Android smartphones [566, 583].
* **Local Data Management & Portability:** All transactional records, budgets, savings goals, and chat histories are persisted on-device in a structured SQLite database to ensure the system operates fully offline [588, 602]. To ensure portability, the application supports JSON-based backup, share sheet export, and local recovery without mandatory cloud account registration [589, 609].
* **Multimodal Data Enrichment:** The system supports manual entry, voice input using on-device Speech-to-Text (en_PH locale detection) [608], barcode scanning [609], Google ML Kit OCR [608], and automated bulk transaction paste-parsing [583].
* **AI-Assisted Educational Advisory:** The conversational chat interface supports 31 agentic transaction actions and non-prescriptive personal financial assistance [567]. The assistant can explain localized Philippine banking products, outline government benefit application processes (SSS, PhilHealth, Pag-IBIG), provide general budgeting education, and estimate market prices for second-hand items [593, 594, 596].
* **Behavioral Architecture & Gamification:** Programmatic 0–100 FHS calculations, dynamic Warning Decay, and a gamification layer featuring 23 achievement badges and streaks designed to increase engagement and self-regulation [597, 611].

### Limitations of the System
* **No Direct Bank Integration:** Direct bank-credential integration is excluded [594]. Due to the absence of accessible open-banking APIs in the Philippine market and critical DPA security concerns regarding credential-sharing, all digital transactions must be logged via manual entry, bulk notification pasting, or screenshot parsing [594].
* **Offline AI Dependencies:** While the local SQLite tracking functions are fully available offline [593], all advanced AI features—including natural language expense parsing, conversation summarization, and conversational advisory—require an active internet connection to communicate with the external Gemini API [594].
* **Non-Diagnostic, Non-Investment Scope:** The application does not provide formal investment matching or algorithmic trading advice, as these features fall outside the needs of the target population and require SEC-regulated financial advisor licensing [594]. Any pricing or financial estimates generated by the system are approximations based on simplified historical models [594].
* **Hardware and Environmental Constraints:** OCR accuracy is dependent on receipt paper clarity and image capture quality [594]. Voice logging performance is subject to background environmental noise and device hardware capabilities [594]. To mitigate errors, a review and manual correction screen is enforced for all automated inputs before they are committed to the local database [594, 608].

---

## Responsible AI & Data Privacy Governance (RA 10173 & NIST RMF)

### Philippine Data Privacy Act (DPA) of 2012 Compliance
SmartSpend handles sensitive personal financial data through e-wallet screenshots, transaction records, and natural language statements [548]. To comply fully with **Republic Act No. 10173 (DPA)** and the National Privacy Commission (NPC) guidelines, the system implements strict data minimization, privacy-by-design, and security controls [548, 549, 561]:
1. **On-Device Data Minimization & Local Processing:** Core transaction logging is processed entirely on-device [548]. The local database is designed for eventual SQLCipher AES-256 database encryption to prevent unauthorized data access if the physical device is compromised [549, 653].
2. **On-Device Redaction and Masking:** Before any screenshot, paste, or natural language input is transmitted to the external cloud LLM API, an automated, on-device regex-based preprocessing layer scans and permanently redacts sensitive personal identifiers—including GCash/Maya mobile numbers, bank account numbers, and user full names [548, 549].
3. **Granular Consent Architecture:** The system displays a transparent privacy notice outlining collected data categories and purpose limitation [549]. Users must provide granular, opt-in consent before enabling the optional Firebase cloud synchronization or cloud LLM features [549].
4. **Data Portability and Deletion:** Users maintain absolute ownership of their financial history [549]. The system provides accessible controls on the settings screen allowing users to export their complete local database, delete specific chat histories, or execute a permanent database wipe [549].
5. **Research Data Isolation:** Needs-assessment survey data and pilot-testing analytics are strictly separated from product database records [550]. Research metrics are stored anonymously using de-identified alphanumeric keys to prevent identity correlation [550].

### NIST AI Risk Management Framework Integration
The application’s AI features are integrated into a proactive **Govern, Map, Measure, Manage** AI Risk register [547]:

```
+---------------------------------------------------------------------------------------------------------+
|                                     SMARTSPEND PROACTIVE AI RISK REGISTER                               |
+------------------------------+-------------------------------------+------------------------------------+
| Identified AI Harm           | Proposed Technical Control          | Target Performance Metric          |
+------------------------------+-------------------------------------+------------------------------------+
| 1. Model Hallucination &     | Strict prompt boundary context      | Zero diagnostic investment advice; |
| Unsafe Advice [555]          | with professional disclaimers [555].| 100% policy filter pass rate [555].|
+------------------------------+-------------------------------------+------------------------------------+
| 2. Unauthorized Database     | Force a human-in-the-loop preview  | 100% user confirmation success rate|
| Writes or Deletions [555]    | screen before any database write.   | for all agentic actions [555].     |
+------------------------------+-------------------------------------+------------------------------------+
| 3. Automation Bias / Over-   | Implement transparent explanations  | SUS Question 9 ("I felt very       |
| reliance on FHS [555]        | of the FHS limitations [551].       | confident using the system") >= 4. |
+------------------------------+-------------------------------------+------------------------------------+
| 4. Prompt Injection via      | Isolate OCR text fields; treat      | 0% execution rate of injected      |
| Screenshot Imports [555]     | merchant strings as untrusted [555].| commands on local database [555].  |
+------------------------------+-------------------------------------+------------------------------------+
```

---

## Significance and Beneficiaries of the Study

The design and development of SmartSpend provide direct, practical, and theoretical benefits to several key groups:

* **Parents (Primary Beneficiaries):** As the primary household financial managers, parents are provided with a passive-effort expense monitoring tool [598]. The automated screenshot parser, voice logging, and FHS dual-mode scoring enable parents to monitor household budgeting without requiring formal accounting training or time-consuming manual text entry [598].
* **Early-Career Young Professionals:** Working adults manage independent income and expenses [615]. SmartSpend helps correct impulsive spending habits through immediate behavioral feedback, structured multi-period budget limits, and the visual consequence of score decay [583, 598].
* **The Field of Financial Technology (FinTech):** This study contributes a novel, open-source model of an offline-first PFM tool that combines direct local storage with low-latency LLM context-injection [583, 652]. It establishes an empirical reference for constructing Observed Financial Health Indicators (FHI) on administrative, mobile-based transaction logs in a developing country context [545, 652].
* **The Researchers:** This project enabled the developers to gain hands-on expertise in hybrid mobile engineering (Flutter SDK) [601], offline-to-cloud database management (SQLite & Firestore) [602, 603], localized OCR preprocessing, and advanced LLM prompt engineering, MLOps, and API proxy design [604, 608].
* **Future Researchers:** This capstone paper serves as a rigorous conceptual, methodological, and empirical foundation for subsequent studies in localized, Taglish-centric conversational processing, mobile-based behavioral nudges, and secure, privacy-preserving client-side AI architectures [571, 600].

---

## Technical Background

SmartSpend v2.9.9 utilizes a robust, hybrid client-side stack designed to minimize cost, enforce data privacy, and ensure maximum client performance [647]:

1. **Flutter (SDK v3.x):** An open-source, cross-platform UI framework developed by Google [601]. Flutter enables the creation of highly responsive, native compiled UI views for Android using a single, performant Dart codebase [601].
2. **SQLite via sqflite (v11):** The primary local transactional database engine [602]. All tables (transactions, budgets, savings goals, notification histories, and chat summaries) are maintained locally [602]. sqflite v11 ensures sub-millisecond query execution speeds on local devices [602].
3. **Google ML Kit Text Recognition API:** Google’s client-side OCR engine [608]. Google ML Kit processes and extracts text strings from paper receipts and transaction images directly on-device [608]. This local execution eliminates API networking costs and protects transaction images from exposure to cloud networks [608].
4. **Speech-to-Text via speech_to_text package:** Implements voice input processing [608]. The package supports automatic local-device recognition of the Filipino-English (en_PH) speech locale, featuring a 15-second listening window and automatic pause detection to minimize entry errors [608].
5. **Firebase cloud services (optional Spark Tier):** 
   * **Firebase Authentication:** Handles secure client-side onboarding, supporting email-password profiles, Google Sign-In (OAuth 2.0), and client-side biometric authentication (Face/Fingerprint via local_auth) [603, 610].
   * **Cloud Firestore:** Manages bidirectional cloud synchronization [603]. Every database write is mirrored to a secure Firestore collection when an active network is detected, allowing for instant sync-recovery if a device is changed [603].
   * **Firebase Remote Config:** Fetches the LLM API key securely at runtime, ensuring that no keys are hard-coded or exposed in the APK binary [595].
6. **Gemini 3.1 Flash-Lite API (The primary LLM engine):** Selected through rigorous benchmarking presented in Chapter III [641]. Gemini 3.1 Flash-Lite offers the highest free-tier quota (1,000 queries per day) [642], low latency (~400–600 t/s) [641], native function calling for 31 agentic actions [567, 642], and a massive 1-million token context window that facilitates direct full-context injection [642], bypassing the need for complex, latency-heavy RAG pipelines [642].
