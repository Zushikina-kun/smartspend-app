# SmartSpend Thesis Documentation: Chapter II (Design and Methodology)

This chapter outlines the research design, population, locale, sampling techniques, ethical safeguards, data collection instruments, and development methodology used to design, implement, and evaluate the SmartSpend mobile application. The methodology described herein utilizes a descriptive-developmental and mixed-methods research approach to evaluate a localized, offline-first personal financial management prototype in La Union, Philippines [555, 597].

---

## 2.1 Research Design

This study employs a **mixed-methods research design**, systematically integrating both qualitative and quantitative data collection and analysis workflows [597]. This design is selected because a purely quantitative approach (e.g., standard usability testing) cannot fully capture the behavioral, emotional, and social dimensions of personal budgeting, while a purely qualitative approach lacks the empirical measurements necessary to validate technical feasibility, optical character recognition (OCR) accuracy, and systemic usability [597, 598].

Additionally, this study adopts a **descriptive-developmental research approach** [599]. Descriptive-developmental research focuses on the design, development, and evaluation of functional prototypes [599]. Rather than operating as a passive tracking app, the developmental aspect of this study centers on the engineering of a functional Android-based prototype (**SmartSpend v2.9.9**) [558, 629] that merges:
1. Multimodal transaction input mechanisms (on-device OCR, voice input, barcode, manual entry, and batch screenshot parsing) [572].
2. A dual-mode programmatic **Financial Health Score (FHS)** operating under **Full Mode** (income tracking) and **Lightweight Mode** (no income required) with built-in behavioral loss-aversion modifiers (Warning Decay and Logging Gap adjustments) [559, 596].
3. Bounded, multilingual (Taglish/Filipino-English) agentic AI assistance capable of executing 31 distinct data actions and providing localized financial Q&A [559, 581, 591].

```
+-----------------------------------------------------------------------------------+
|                           SMARTSPEND IPO CONCEPTUAL FRAMEWORK                      |
+-----------------------------------------------------------------------------------+
| INPUTS                       | PROCESSES                    | OUTPUTS             |
+------------------------------+------------------------------+---------------------+
| * Natural Language (Text)    | * Gemini 3.1 Flash-Lite      | * Auto-logged       |
| * Voice Audio (en_PH locale) |   Function Calling & Parsing |   Transactions      |
| * Receipt Screenshots (OCR)  | * Google ML Kit OCR Extraction| * Financial Reports |
| * Barcode Scans              | * Offline-First sqflite DB   |   & fl_chart Views  |
| * Mixed GCash/Maya/Bank      | * Bidirectional Firebase     | * Behavioral FHS    |
|   Screenshots & Logs         |   Sync & Remote Config Keys  |   (0-100 Score)     |
| * Transaction History Text   | * RA 10173 On-Device Regex   | * 31 Agentic Data   |
|   Pasted for Bulk Parsing    |   Scrubbing and Redaction     |   Actions & Q&A     |
+------------------------------+------------------------------+---------------------+
```

The quantitative workflow measures system performance (latency, OCR precision/recall, categorization error rates) and perceived usability via the standardized **System Usability Scale (SUS)** [598, 607]. The qualitative workflow gathers insights into the financial self-regulation challenges of the target population through structured pre-development surveys and post-evaluation semi-structured interviews [597, 606].

---

## 2.2 Population, Locale, and Sampling Design

### 2.2.1 Population and Locale
The study is conducted in **San Fernando City, La Union, Philippines** [600]. The geographic choice is highly relevant: regional urban centers in the Philippines represent unique economic micro-ecosystems where digital-wallet transactions (GCash, Maya) coexist with cash-heavy informal markets and unique local financial structures (such as e-commerce shopping, cash-on-delivery, and informal credit arrangements) [568, 572, 600].

The target population consists of two distinct demographic segments:
1. **Primary Target Population (Parents aged 35–55):** Defined as adult parents who serve as the principal household financial decision-makers in Filipino families [558, 600]. Per the **Bangko Sentral ng Pilipinas (BSP) 2021 Financial Inclusion Survey**, this age bracket shoulders the highest household financial responsibilities (rent, utilities, childcare, tuition) yet exhibits some of the lowest rates of formal budgeting and digital tool adoption due to manual data entry friction and lack of localized feedback [567, 586, 600].
2. **Secondary Target Population (Young Professionals aged 21–35):** Defined as early-career working individuals who independently manage their personal income [558, 600]. This segment represents the highest demographic of digital payment and e-wallet adopters but often exhibits a "come-what-may" attitude (*bahala na*) toward financial planning, resulting in high discretionary overspending and low savings rates [568, 600, 665].

### 2.2.2 Purposive Sampling and Sample Size Justification
A total of **thirty (30) respondents** are selected using **purposive sampling**, which is a non-probability sampling technique where respondents are chosen based on specific pre-defined inclusion criteria [601]:
* **Inclusion Criteria for Parents (n=20):** Must be aged 35–55, reside in La Union, act as the primary manager of household expenses, and regularly use digital-wallets (GCash or Maya) or cash to settle expenses [558, 600].
* **Inclusion Criteria for Young Professionals (n=10):** Must be aged 21–35, reside in La Union, be currently employed or self-employed, independently manage personal earnings, and possess an Android smartphone [558, 600].

```
+-----------------------------------------------------------------------+
|                 SAMPLE DISTRIBUTION AND DESIGN SCHEME                 |
+-----------------------------------------------------------------------+
| Participant Segment       | Sample Size (n) | Selection Criteria      |
+---------------------------+-----------------+-------------------------+
| Parents (Ages 35-55)      | 20 (Primary)    | Primary HH Decision-    |
|                           |                 | Maker, lowest PFM rate  |
+---------------------------+-----------------+-------------------------+
| Young Professionals       | 10 (Secondary)  | Early-career, working,  |
| (Ages 21-35)              |                 | independent income      |
+---------------------------+-----------------+-------------------------+
| Survey Content Validator  | 1               | Business/Commerce Expert|
+---------------------------+-----------------+-------------------------+
| Technical Validator       | 1               | IT/Software Expert      |
+---------------------------+-----------------+-------------------------+
| Total Portfolio           | 32              | Mixed Purposive Design  |
+-----------------------------------------------------------------------+
```

#### 📊 Methodological Sample Size Justification (The Usability Exception)
During the capstone defense, the panel may query: *“Given that the underlying PLS-SEM studies in your literature review utilized large sample sizes (e.g., N=656 in the Atlantis Press study to achieve statistical power [92]), how can you justify a sample size of only 30 respondents?”* [91, 92]

To defend this, the methodology draws a strict line between **predictive behavioral modeling** and **prototype usability/feasibility testing** [532, 538]:
1. **PLS-SEM Modeling Rationale:** In the **Atlantis Press (2026)** study, a priori power analysis using **G*Power 3.1** indicated that a minimum of 77 respondents was required to detect a medium effect size ($f^2 = 0.15$) at $lpha = 0.05$ and power $eta = 0.80$ for the structural model containing three predictors [91, 92]. The study's actual sample of $N=656$ was required because PLS-SEM evaluates latent structural covariance and population-wide behavioral generalizability [92, 93, 118].
2. **Usability and Feasibility Testing Rationale:** In contrast, SmartSpend is evaluated as a functional prototype [599]. For usability testing using the **System Usability Scale (SUS)**, a purposive sample of $N=30$ is statistically robust and represents the gold standard in human-computer interaction (HCI) literature [598, 601]. Landmark usability research by **Nielsen (1993)** and **Faulkner (2003)** empirically proves that usability testing with **5 participants uncovers 80–85% of core usability defects**, while **20 to 30 participants are sufficient to uncover over 90–95% of all usability and technical issues**, including edge-case errors [601, 607]. Therefore, $N=30$ provides extreme statistical reliability for prototype validation, preventing unnecessary and costly data gathering on a pre-commercial prototype.

---

## 2.3 Ethical Considerations and Data Governance (RA 10173 & NIST AI RMF)

### 2.3.1 Compliance with the Philippine Data Privacy Act of 2012 (RA 10173)
Because SmartSpend ingests sensitive personal financial data—including GCash, Maya, and bank transaction screenshots, manual expenses, income levels, and financial chat histories—strict compliance with **Republic Act No. 10173** (and its 2016 Implementing Rules and Regulations) is embedded directly into the software architecture [540, 553, 554]:

1. **The Principle of Purpose Limitation:** The application declares separate, explicit processing purposes for on-device tracking, local OCR text extraction, voice-to-text processing, Firebase cloud synchronization, and scholarly research [540, 541]. Optional features are decoupled; a user can decline cloud synchronization or Firebase login and continue using the app in fully offline mode using local SQLite [541, 576, 581].
2. **The Principle of Data Minimization:** The application strictly avoids the collection of highly sensitive credentials such as bank passwords, credit card PINs, e-wallet passwords, or One-Time Passwords (OTPs) [540, 556]. Mascot and profile images are saved locally rather than stored on Firebase cloud [582].
3. **Automated On-Device Regex Masking Layer:** To protect user privacy before any data leaves the device, SmartSpend implements a client-side regex pre-processing layer [540, 541]. This layer intercepts OCR-extracted text and pasted text histories, scanning for e-wallet mobile numbers (e.g., `09XX-XXX-XXXX`), bank account digits, and full names, permanently redacting them (replacing them with `[REDACTED_PHONE]` or `[REDACTED_ACCOUNT]`) *on-device* before transmitting any prompt payload to the Google Gemini LLM API [540, 541, 590].
4. **Granular notice and Consent:** All purposive participants review and sign an **Informed Consent Form** (Appendix C) [605, 657]. This document details the data categories collected, processing methods, retention periods, user rights (the right to access, export, correct, and permanently delete their data), and the right to withdraw participation at any time without penalty [541, 605, 658, 659].

### 2.3.2 NIST-Aligned AI Risk Management Framework (AI RMF)
Following the **NIST AI RMF (Govern, Map, Measure, Manage)** guidelines, SmartSpend implements a proactive AI governance model to manage hallucination, model drift, automation bias, and prompt-injection threats [539, 553]:

* **Govern:** Establish strict technical boundaries [539]. The AI assistant is system-prompted to refuse requests for registered investment, tax, or legal advice, acting strictly as an educational financial companion [532, 536, 582].
* **Map:** Document potential failure modes, particularly the "longer context hallucination" risk [13, 539]. Benchmarking revealed that sending more than 100 transactions in a single batch to the LLM increases categorization errors and causes the model to fabricate or duplicate transaction IDs [13, 547]. SmartSpend restricts bulk text-pasting and transaction imports to a maximum target batch size of **120 transactions** [547].
* **Measure:** Monitor and record factual accuracy, prompt injection pass rates, and the frequency of unsafe responses [539, 548].
* **Manage (Human-in-the-Loop Safeguard):** To prevent catastrophic failures like unauthorized database writes, deletions, or erratic FHS calculations, the app enforces a strict **Human-in-the-Loop (HITL) architecture** [536, 539, 547]. No agentic AI action (from the 31 natural language actions) can write to, update, or delete records from the local SQLite database without displaying a transparent **"Review and Confirm" preview screen** [547, 593]. The user must manually review and tap a confirmation button before any local write is executed, and an "Undo" transaction button is available on all log screens [539, 547, 593].

---

## 2.4 Data Gathering Instruments and Validation

### 2.4.1 Survey Questionnaires and Structured Interviews (Objective 1)
To assess pre-development financial practices and challenges, a structured survey (Appendix B) is content-validated by **Susan C. Arquisal**, a graduate of Bachelor of Science in Commerce major in Management and an active business owner with extensive financial operations experience [602, 656]. This questionnaire collects data on monthly income brackets, expense tracking habits, budget breach frequencies, manual logging inconveniences, and feature requirements [652, 653, 654, 655]. Pre-development qualitative interviews gather deeper contextual themes on local budget stressors, caregiving costs, and digital payment friction [598, 606].

### 2.4.2 Technical Benchmarking (Objective 2)
The technical evaluation of Large Language Models is conducted systematically by running identical expense-parsing, Taglish translation, and function-calling prompts across 15 candidate APIs [580, 608]. Performance is benchmarked on:
* **Inference Speed:** Tokens per second (t/s) [580, 622].
* **Filipino-English Accuracy:** Percentage of colloquial Taglish financial statements (e.g., *"nagbayad ako ng ₱150 sa trike kanina"*) correctly converted to structured JSON [580, 622].
* **Function-Calling Reliability:** Execution success rate across the 31 agentic actions [559, 622].
* **Free-Tier Viability:** Request quotas permitted under academic/free developer constraints [580, 622].

### 2.4.3 System Usability Scale (SUS) (Objective 3)
Perceived usability is measured using the standard 10-item **System Usability Scale (SUS)** developed by **Brooke (1996)** [598, 607, 660]:
* Respondents independently complete the 10-item questionnaire on a 5-point Likert scale (1 = Strongly Disagree, 5 = Strongly Agree) [598, 609, 660].
* The SUS score is computed using the standard psychometric formula [609, 631]:
  * For odd-numbered items (positive statements): $X_i = 	ext{Score} - 1$ [631]
  * For even-numbered items (negative statements): $Y_i = 5 - 	ext{Score}$ [631]
  * Overall SUS Score = $(\sum X_i + \sum Y_i) 	imes 2.5$ [631]
* The resulting score ranges from 0 to 100 [610].
* To interpret the score, we apply the **Bangor, Kortum, & Miller (2009)** adjective rating scale [598, 630]:
  * $\ge 90$: Excellent (Grade A) [610, 631]
  * $80 - 89$: Good (Grade B) [610, 631]
  * $70 - 79$: Acceptable (Grade C) [610, 631]
  * $60 - 69$: Marginal (Grade D) [610, 631]
  * $<60$: Poor (Grade F) [610, 631]
* The target usability benchmark for SmartSpend is set at **$\ge 80$ (Good)** [560, 598].

---

## 2.5 Software Development Methodology (Agile Kanban)

The development of SmartSpend utilizes the **Agile Kanban Software Development Methodology** [611]. Kanban is selected over rigid, linear models (like Waterfall) because of the complexity of integrating advanced machine learning components, on-device OCR, multilingual voice recognition, and real-time database synchronization [611]. The incremental, visual, and iterative nature of Kanban allows tasks to progress dynamically, enabling continuous integration and immediate refinement based on testing feedback [611].

```
+------------------------------------------------------------------------------------+
|                         SMARTSPEND AGILE KANBAN PIPELINE                           |
+------------------------------------------------------------------------------------+
| BACKLOG        --> REQUIREMENTS  --> DESIGN      --> DEVELOPMENT --> TESTING & QA  |
| * Feature List | * User Surveys  | * Schema v11  | * Flutter     | * OCR Testing  |
| * User Stories | * Functional    | * FHS Formula | * sqflite DB  | * SUS Protocol |
| * Tech Stack   |   Specifications| * UI Mockups  | * Gemini API  | * Backup/Sync  |
+------------------------------------------------------------------------------------+
```

### 2.5.1 Work-in-Progress (WIP) Limits and Board Architecture
The development workflow is visualized on a Kanban board containing seven columns: Backlog, Requirements, Design, Development, Testing, Deployment, and Done/Review [612]. To maintain developer velocity, minimize multitasking bottlenecks, and ensure code quality, **Work-in-Progress (WIP) limits** are enforced [612]:
* **Development WIP Limit:** Maximum of 3 active feature tasks simultaneously.
* **Testing WIP Limit:** Maximum of 2 features undergoing evaluation.

### 2.5.2 Agile Kanban Phases and Technical Deliverables

#### Phase 1: Backlog Phase
The Backlog is populated with user stories, technical tasks, and desired system requirements [613]:
* *Example User Story:* *"As a budget-conscious parent, I want to capture a receipt screenshot of my Shopee or Lazada checkout so that I don't have to manually encode every household item."* [558, 572, 613]
* *Deliverable:* A prioritized backlog of 31 agentic actions, 6 input modalities, 14 expense categories, and 23 gamification badges [613, 628, 629].

#### Phase 2: Requirements Phase
This phase defines functional requirements (automated Taglish transaction logging, e-wallet balance synchronization, programmatic FHS computing, regulatory privacy scrubbing) and non-functional requirements (offline capability, response latency $< 1.5$ seconds, target SUS score $\ge 80$) based on Objective 1 survey data [580, 598, 614].
* *Deliverable:* Complete Functional Specification Document and content-validated user research survey instruments [614, 628].

#### Phase 3: Design Phase
System structures are mapped out [615]:
* **Database Schema (v11):** 20 tables implemented in SQLite, mapped to handle transactional records, custom budgets, savings goals, e-wallet balances, gamified quest progress, and encrypted chat history [615, 629].
* **Choice Architecture Mapping:** Mapping the FHS mathematical logic, the Warning Decay loss-aversion loop (declining 5 points per day if warnings are ignored), and the Impulse Pause mechanic (cognitive friction delay for discretionary 'Want' purchases over ₱500) [559, 596, 627, 665].
* *Deliverable:* Complete Entity-Relationship Diagrams (ERDs), UI/UX wireframes, and FHS formula specifications [615, 628].

#### Phase 4: Development Phase
Actual coding in Dart using the **Flutter framework** [558, 560, 616]. Development follows an incremental, feature-by-feature pipeline [616]:
1. **Core Database Setup:** Build local sqflite v11 database and initialize the 14 localized expense categories (Food, Transportation, Personal Care, Gaming, etc.) [588, 616].
2. **On-Device OCR & Voice Integration:** Implement Google ML Kit Latin script text recognizer and Dart speech_to_text for the en_PH locale [593, 616].
3. **LLM API Integration:** Construct a secure client-side model adaptivity layer. This layer pulls the API key securely at runtime via **Firebase Remote Config** (preventing key exposure in the APK binary) and implements a **conversation summarization mechanism** to compress conversation history, saving up to 75% on token overhead [583, 589, 592].
4. **Cloud Synchronization:** Build bidirectional sync using Firebase Firestore, automatically merging offline SQLite records with cloud backups once connection is restored [576, 616].
5. **On-Device Privacy Masking:** Write the client-side regex filter to scrub e-wallet and account numbers before transmitting prompt payloads to the cloud LLM [540, 541].
* *Deliverable:* A compile-ready Android APK (v2.9.9) with all 31 agentic actions operational [559, 628, 629].

#### Phase 5: Testing Phase
This phase runs functional, technical, and usability evaluations [617]. In addition to standard unit testing, this capstone study implements a rigorous **Technical Performance Evaluation Protocol** [617, 628]:

```
+------------------------------------------------------------------------------------+
|                         SMARTSPEND QUANTITATIVE QA GATE                            |
+------------------------------------------------------------------------------------+
| USABILITY TESTING            | PERFORMANCE BENCHMARKS       | ROBUSTNESS           |
| * SUS Score >= 80            | * OCR Precision/Recall (95%) | * Offline Recovery   |
| * Task Completion Rate (90%) | * Taglish Accuracy (90%)     | * Sync Conflict      |
| * Average Latency < 1.5s     | * RA 10173 Scrubbing (100%)  |   Resolution (100%)  |
+------------------------------------------------------------------------------------+
```

1. **OCR Field-Level Precision & Recall:** Tested using a curated corpus of 50 local receipt images (GCash receipts, Shopee invoices, physical thermal receipts). Precision and recall are measured independently for four target fields: Date, Merchant, Amount, and Category [548].
2. **Categorization Accuracy:** Evaluated across a benchmark dataset of 200 transactions containing English, Tagalog, and colloquial Taglish inputs (e.g., *"nakatanggap ako ng pension kanina ₱5000"*) [548].
3. **Offline SQLite Synchronization Recovery:** Tested in a simulated network dropout chamber. Transactions are logged under "Airplane Mode" to verify local SQLite write continuity [549, 581]. The network is then restored to verify:
   * Event-driven cloud syncing and data restoration [576, 594].
   * Deduplication logic (preventing duplicate entries when merging on-device logs with cloud Firestore) [544, 576].
4. **Responsible AI Safeguards Verification:** Unit-tested with adversarial prompts (prompt injections, direct commands to execute database wipes, requests for unauthorized financial investments) to verify that policy filters and the on-device regex masking layer achieve 100% compliance [539, 547].
5. **Standardized Usability Testing:** Administrated to the purposive sample of 30 local testers using Demo Mode, with SUS evaluations recorded and tabulated [598, 607, 630].
* *Deliverable:* SUS Score reports, Bug logs, OCR precision metrics, and SQLite sync recovery logs [628].

#### Phase 6: Deployment Phase
The compiled release-ready APK (v2.9.9) is built with arm64-v8a target architectures, optimizing package size to 45 MB to ensure installation feasibility on low-end and mid-range Android devices common in La Union [618, 629]. Demo Mode is activated with pre-seeded, realistic Filipino sample data to enable frictionless usability evaluations [577, 618].
* *Deliverable:* Stable GitHub Releases repository and installable APK binaries [628, 629].

#### Phase 7: Done/Review Phase
Review of project objectives against empirical outcomes [618]. In this phase, SUS results, OCR precision scores, and qualitative feedback are consolidated to prioritize subsequent, post-capstone roadmaps (e.g., implementing SQLCipher database encryption, establishing a backend proxy server for server-side API key handling, and designing a Paluwagan rotating savings tracker) [618, 628, 634, 635].
* *Deliverable:* Approved capstone manuscript chapters, technical validation certificates, and final research report [628].

---

## 2.6 Methodological Summary Map
The Agile Kanban phases correspond directly to the research objectives and academic deliverables, ensuring systematic alignment and traceability:

| **Kanban Phase** | **Target Research Objective** | **Key Technical Tasks** | **Primary Deliverable** | **Grounding Citations** |
| :--- | :--- | :--- | :--- | :--- |
| **Backlog** | Needs Assessment (Obj. 1) | Define local financial gaps; map Philippine e-wallet context | Prioritized features; pre-development themes | [567, 568, 600, 628] |
| **Requirements** | Design Prep (Obj. 2) | Gather functional inputs; validate survey instruments | Content-validated questionnaire; spec sheets | [580, 606, 614] |
| **Design** | System Architecture (Obj. 2) | Design sqflite v11 database; specify behavioral FHS formulas | ERDs; wireframes; choice architecture specs | [596, 615, 627] |
| **Development** | Coding & Integration (Obj. 2) | Program in Flutter; write client-side regex privacy scrub | Release-ready APK v2.9.9; operational agentic actions | [541, 560, 616, 629] |
| **Testing** | usabiliy & Feasibility (Obj. 3) | Administer SUS; measure OCR precision and SQLite recovery | Usability scores; engineering benchmarks | [548, 598, 607, 631] |
| **Deployment** | System Release (Obj. 2 & 3) | Compile release APK; configure pre-seeded Demo Mode | GitHub Releases repository; installable APK binaries | [577, 618, 629] |
| **Done/Review** | Document Validation (Obj. 3) | Tabulate usability metrics; compile post-capstone roadmaps | Approved thesis chapters; technical certificates | [618, 633, 634] |

---
