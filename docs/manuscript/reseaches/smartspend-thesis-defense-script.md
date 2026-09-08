# SmartSpend Capstone Thesis Defense Presentation Script
**Institution:** College of Computer Studies and Engineering, LORMA Colleges  
**Degree:** Bachelor of Science in Information Technology  
**Capstone Title:** SmartSpend: An AI-Assisted Mobile Financial Tracking and Advisory Application for Personal Financial Management  
**Adviser:** Mr. Johnny Flores Verzola, MTS  
**Chairperson:** Ms. Ellen F. Mangaoang, MIT  
**Teacher-in-Charge:** Dr. Janelli M. Mendez, MIT  

---

## SLIDE 1: Title Slide & Introductions

### 1. Slide Configuration
*   **Slide Title:** SmartSpend: An AI-Assisted Mobile Financial Tracking and Advisory Application for Personal Financial Management
*   **Visual Layout:** Clean, minimalist dark-teal background. SmartSpend app logo on the left; Title, Degree, and Author Block on the right.
*   **On-Slide Content:**
    *   Presented by: Brix A. Directo, Cyrille John M. Rubis, and Djaunathan Albert S. Madayag
    *   In Partial Fulfillment of the Requirements for the Degree of Bachelor of Science in Information Technology
    *   Capstone Project Adviser: Mr. Johnny Flores Verzola, MTS
    *   LORMA Colleges, College of Computer Studies and Engineering (CCSE)

### 2. Presenter's Speaking Script
> "Good morning, respected members of the panel, Chairperson Mangaoang, Dean Layco, and guests. We are Brix Directo, Cyrille John Rubis, and Djaunathan Albert Madayag. Today, we are privileged to present our capstone research project entitled: *'SmartSpend: An AI-Assisted Mobile Financial Tracking and Advisory Application for Personal Financial Management.'*
> 
> Our research has been conducted under the guidance of our Capstone Project Adviser, Mr. Johnny Flores Verzola, MTS. The focus of our work is to design, implement, and rigorously evaluate an intelligent, offline-first mobile financial tracking ecosystem specifically optimized for parents and young professionals in the province of La Union, Philippines. We will demonstrate how our system mitigates manual entry barriers through automated multimodal processing and enforces behavioral financial wellness via a mathematically-modeled Financial Health Score."

### 3. Source Grounding & Defense Alignment
*   **Academic Base:** Resolves title page inconsistencies. Verzola is properly designated as the primary Adviser, Mangaoang as Chairperson, and the student author block is corrected to exclude faculty members [SmartSpend Manuscript Approval Sheet].

---

## SLIDE 2: Project Context & Problem Statement

### 1. Slide Configuration
*   **Slide Title:** Project Context & Personal Finance Challenges in the Philippines
*   **Visual Layout:** Two-column split. Left column shows key statistics in bold cards. Right column has a diagnostic diagram illustrating "Passive Tracking vs. Active Behavioral Guidance".
*   **On-Slide Content:**
    *   **Financial Literacy Gap:** Only 2% of Filipino adults correctly answer basic financial literacy questions (BSP, 2021).
    *   **Budgeting Inertia:** Fewer than 50% of households maintain any personal or family budget (BSP, 2021).
    *   **Adoption Barriers:** Manual tracking is abandoned due to cognitive friction, lack of local language support, and a lack of consequences for overspending.
    *   **Target Locale:** Focused on San Fernando City, La Union, capturing the specific demands of local parents (primary managers) and young professionals.

### 2. Presenter's Speaking Script
> "To understand why SmartSpend is critical, we must examine the severe financial management challenges in the Philippines. According to the 2021 Bangko Sentral ng Pilipinas Financial Inclusion Survey, only 2% of Filipino adults correctly answered all basic financial literacy questions, and fewer than half reported keeping any written budget [605]. 
> 
> While mobile phone penetration is near-universal, local users systematically abandon traditional budgeting tools. Our empirical needs assessment identified three core barriers: first, the extreme manual effort required to log cash and e-wallet transactions; second, the complete lack of local language (Taglish) support in existing financial technology; and third, the passive nature of current apps, which display charts but fail to guide behavior or create consequences when spending warnings are ignored [608]. SmartSpend directly solves these local pain points."

### 3. Source Grounding & Defense Alignment
*   **Academic Base:** Grounded in BSP (2021) Financial Inclusion Survey, PSA FIES (2021), and local literature on Filipino workers' financial freedom [605, 606, 607]. Avoids over-generalizing national statistics as direct causal proof for La Union, setting the context as a regional design problem.

---

## SLIDE 3: The Defensible Research Gap & Objectives

### 1. Slide Configuration
*   **Slide Title:** Research Gap & Study Objectives
*   **Visual Layout:** Three horizontal chevron arrows representing the Gap, the Bundle Solution, and the Evaluation Criteria.
*   **On-Slide Content:**
    *   **The Defensible Gap:** Evaluation of a specific integrated prototype combining local financial workflows, offline-first operation, multimodal entry, and transparent transaction-derived feedback [587].
    *   **Objective 1:** Assess existing financial practices of parents and young professionals in San Fernando City, La Union [621].
    *   **Objective 2:** Design and develop the SmartSpend mobile application utilizing an offline-first SQLite database and secure context-injected LLM APIs [621].
    *   **Objective 3:** Evaluate usability (SUS), OCR precision/recall, categorization accuracy, and synchronization performance [621, 622].

### 2. Presenter's Speaking Script
> "Let us address a key question: what is our study's unique academic contribution? During our literature and competitor audit, we discovered that while apps like *BudgetPH*, *Alkansya*, and *P1SO* exist, no study has evaluated a unified mobile prototype that integrates local financial workflows, full offline capability, multimodal screenshot parsing, and a transparent, behaviorally grounded Financial Health Score [582, 587].
> 
> Therefore, our research gap focuses on evaluating this specific integrated bundle and analyzing the relationship between its transaction-derived indicators and validated psychometric scales of well-being [587]. To resolve this, our objectives are: first, to assess baseline local financial behaviors; second, to engineer the SmartSpend Flutter prototype with local language support and robust data boundaries; and third, to evaluate the system using both the standardized System Usability Scale and objective technical performance metrics [621, 622]."

### 3. Source Grounding & Defense Alignment
*   **Academic Base:** Standardizes the contribution statement, explicitly noting that SmartSpend does not claim to be the 'first' or 'only' budgeting app, but rather an evaluated 'integrated bundle' [582, 587].

---

## SLIDE 4: Theoretical Framework: Nudge and Self-Determination Theory

### 1. Slide Configuration
*   **Slide Title:** Theoretical Foundations: Nudge & Self-Determination Theory
*   **Visual Layout:** Flow diagram showing Nudge Theory (Thaler & Sunstein, 2008), Self-Determination Theory (Deci & Ryan, 2000), and Social Comparison Theory (Festinger, 1954) feeding into "Sustainable Financial Intention" (SFI).
*   **On-Slide Content:**
    *   **Choice Architecture:** Prompts delivered at the decision point guide behavior without restricting choice (Nudge Theory).
    *   **Intrinsic Motivation:** Gamification (daily quests, badges, streaks) supports the core psychological needs of Autonomy, Competence, and Relatedness (SDT).
    *   **Peer Cues:** Benchmarking against local spending standards drives competitive motivation (Social Comparison Theory).
    *   **Validated Path Coefficients:** (Atlantis Press, 2026 PLS-SEM)
        *   Personalized Feedback Nudge (PBFN) $ightarrow$ SFI ($eta = 0.28$, $t = 6.21$)
        *   Gamified Rewards (GR) $ightarrow$ SFI ($eta = 0.25$, $t = 5.89$)
        *   Social Comparison (SC) $ightarrow$ SFI ($eta = 0.18$, $t = 4.11$)

### 2. Presenter's Speaking Script
> "SmartSpend is built on robust behavioral economics. We do not simply display transaction lists; we employ an active choice architecture. By combining **Nudge Theory** and **Self-Determination Theory**, we explain how subtle design elements foster long-term behavior change [34]. 
> 
> To validate these choices, we cite empirical PLS-SEM structural equation modeling from the Atlantis Press (2026) study of 656 respondents [21, 98]. Their structural model proves that personalized budget feedback nudges ($eta = 0.28$, $t = 6.21$), gamified rewards ($eta = 0.25$, $t = 5.89$), and social comparison cues ($eta = 0.18$, $t = 4.11$) all have statistically significant positive effects on a user's Sustainable Financial Intention [113]. This empirical data validates why SmartSpend incorporates configurable daily quests, badges, and progress streaks to drive budget adherence."

### 3. Source Grounding & Defense Alignment
*   **Academic Base:** Grounded in the theoretical integration of Nudge, SDT, and Social Comparison [34, 39, 40]. Uses exact path coefficients, t-statistics, and sample sizes from the empirical model [113].

---

## SLIDE 5: Literature Alignment: Explainable AI and transparency

### 1. Slide Configuration
*   **Slide Title:** Perceived Algorithm Transparency as an Active Moderator
*   **Visual Layout:** Interaction plot illustrating how Perceived Algorithm Transparency (PAT) moderates the path from Sustainable Financial Intention (SFI) to Digital Financial Well-being (DFWB). Includes model fit and variance metrics.
*   **On-Slide Content:**
    *   **The Path SFI $ightarrow$ PAT:** $eta = 0.51$, $t = 10.04$ (Atlantis Press, 2026).
    *   **Direct Path PAT $ightarrow$ DFWB:** $eta = 0.43$, $t = 8.67$.
    *   **Moderation Interaction (SFI $	imes$ PAT $ightarrow$ DFWB):** $eta = 0.14$, $t = 2.95$, $p < 0.001$.
    *   **Variance Explained ($R^2$):**
        *   $	ext{SFI} = 0.38$ (Nudges explain 38% of intention).
        *   $	ext{PAT} = 0.26$ (Intention explains 26% of perceived transparency).
        *   $	ext{DFWB} = 0.56$ (Interaction explains 56% of overall experienced well-being).

### 2. Presenter's Speaking Script
> "A common criticism of AI apps is the 'black box' effect—users receive advice but do not know why, which degrades trust. SmartSpend addresses this by prioritizing **Explainable AI (XAI)** [28].
> 
> The Atlantis Press study evaluated this relationship and confirmed that Sustainable Financial Intention strongly influences Perceived Algorithm Transparency ($eta = 0.51$, $t = 10.04$) [114]. Crucially, they proved that perceived transparency acts as an **active moderator** of the relationship between responsible intentions and overall Digital Financial Well-being, with an interaction effect of $eta = 0.14$ ($t = 2.95$, $p < 0.001$) [112]. Furthermore, the model explains 56% of the variance in experienced well-being ($R^2 = 0.56$) [115, 116]. This proves that explaining the 'why' behind SmartSpend's recommendations is mathematically proven to amplify the user's financial wellness."

### 3. Source Grounding & Defense Alignment
*   **Academic Base:** Cites exact PLS-SEM empirical findings, t-values, p-values, $R^2$ variance, and moderating effect sizes ($f^2$) from the Atlantis Press study [111, 112, 115, 116, 117].

---

## SLIDE 6: Methodological Correction: Reconciling the custom FHS

### 1. Slide Configuration
*   **Slide Title:** Reconciling the Custom FHS: Solving the Measurement Gap
*   **Visual Layout:** Split-scale diagram. Left side: Subjective Psychometric Scales (CFPB, 2017). Right side: Objective Transaction-Derived Scale (SmartSpend FHS). Bottom: The CBA-MI dual-scale bridge.
*   **On-Slide Content:**
    *   **Subjective Scale:** CFPB 10-item FWB scale measures psychological worry, security, and perception [191, 221].
    *   **Objective Scale:** SmartSpend FHS programmatically calculates transactional behaviors.
    *   **The CBA/MI (2018) & UNSGSA (2021) Resolution:**
        *   *Reported FWB Scale:* Subjective survey-based metrics [436].
        *   *Observed FWB Scale:* Objective bank-administrative data [436, 468].
    *   **SmartSpend Alignment:** Programmatic FHS is formally defined as a **Prototype Observed Financial Health Indicator (FHI)** modeled on FHN Spend-Save-Borrow-Plan domains [434, 574].

### 2. Presenter's Speaking Script
> "During our defense preparation, we resolved a vital methodological divergence. The CFPB Financial Well-Being scale is a highly validated, subjective psychometric instrument composed of 10 self-reported survey items [191, 221]. Because SmartSpend programmatically calculates its score from SQLite transaction data, we cannot claim the CFPB validates our exact formula [572, 573].
> 
> To reconcile this, we cite the **Commonwealth Bank of Australia and the Melbourne Institute (CBA/MI, 2018)** and the **UNSGSA (2021)** technical frameworks [413, 436]. CBA-MI established a dual-scale model: a *Reported Scale* for subjective perceptions and an *Observed Scale* for transaction records [436, 468]. We formally position the SmartSpend FHS as a **Prototype Observed Financial Health Indicator (FHI)** [574]. This enables us to maintain complete scientific integrity, separating objective behavior tracking from psychological states."

### 3. Source Grounding & Defense Alignment
*   **Academic Base:** Grounded in CFPB (2017), CBA-MI (2018), and UNSGSA (2021) technical guidelines, resolving the subjective-objective measurement gap [221, 413, 436, 468, 574].

---

## SLIDE 7: Technical Architecture: WealthNX 5-Step Pipeline

### 1. Slide Configuration
*   **Slide Title:** Technical Architecture: Transaction Enrichment Pipeline
*   **Visual Layout:** Schematic diagram showing the 5-step processing pipeline: Raw e-wallet string input $ightarrow$ Clean standardized database output.
*   **On-Slide Content:**
    *   **WealthNX 5-Step Model:**
        1.  *Ingestion:* Ingesting messy payment signals (GCash, Shopee, Lazada screenshots or pasted SMS logs) [360].
        2.  *Merchant Normalization:* Stripping payment routing codes and abbreviations to map unique merchant entities [361].
        3.  *Category Alignment:* Aligning inputs to our 14 SQLite categories based on Merchant Category Codes (MCC) [361].
        4.  *Metadata Shaping:* Flagging descriptors like 'want vs. need', 'recurring', or 'travel-related' [361, 362].
        5.  *Prompt Generation:* Converting structured records into schema-driven, natural-language prompts [362].

### 2. Presenter's Speaking Script
> "To minimize logging friction, SmartSpend supports bulk transaction imports from screenshots and pasted SMS histories [612]. However, raw transaction strings are cryptic and non-standardized. To process these, we implemented the **WealthNX (2026) 5-Step Enrichment Pipeline** [359].
> 
> First, our *Ingestion* layer captures GCash, Maya, Shopee, and Lazada screenshot text [360, 612]. Second, we run *Merchant Normalization* to strip terminal IDs, dates, and payment routing codes [361]. Third, we perform *Category Alignment*, mapping merchant strings to our 14 local database categories [361, 632]. Fourth, *Metadata Shaping* tags transactions as Wants or Needs and identifies recurring subscriptions [361]. Finally, *Prompt Generation* formats these structured fields into a compact schema before executing LLM function calls [362]. This guarantees that messy local inputs are parsed with high semantic precision."

### 3. Source Grounding & Defense Alignment
*   **Academic Base:** Grounded in the WealthNX transaction-processing architecture and MCC classification standards [359, 360, 361, 362].

---

## SLIDE 8: Technical Engineering: Offline-First Database & Context Injection

### 1. Slide Configuration
*   **Slide Title:** Technical Engineering: SQLite & LLM Context Injection
*   **Visual Layout:** High-level database schema diagram. Shows the local SQLite storage synced bidirectionally to Firebase Firestore, and direct context injection to the LLM.
*   **On-Slide Content:**
    *   **Offline-First SQLite Architecture:** Keeps 20 database tables fully active offline, ensuring 100% core tracking without internet [632, 677].
    *   **Context Injection vs. RAG:**
        *   User financial profile (~20-50 expenses, 5-10 budgets, 3-5 goals) averages **1,000–5,000 tokens** [672].
        *   Direct context injection fits entirely in memory, eliminating costly vector database overhead, token latency, and multi-hop query failures [15, 672].
    *   **Conversational Summarization:** Periodically compresses historical chat into semantic summaries to preserve context window and reduce input token costs [637].

### 2. Presenter's Speaking Script
> "SmartSpend utilizes an **offline-first SQLite architecture** with 20 database tables, ensuring that budgeting, expense logging, and behavioral health scores are fully functional without an internet connection [632, 677].
> 
> For our AI advisor layer, we made an intentional engineering decision to use **direct context injection** instead of Retrieval-Augmented Generation (RAG) [672]. Because a local user's active transaction context is highly localized and lightweight—averaging between 1,000 and 5,000 tokens—it fits completely within the context window of modern models [672]. RAG introduces unnecessary vector database lookup latencies and fails on complex multi-hop queries, such as calculating average grocery spending over three months [15]. Additionally, we engineered a conversational summarization mechanism that periodically compresses chat history, keeping token overhead minimal while preserving contextual awareness [637]."

### 3. Source Grounding & Defense Alignment
*   **Academic Base:** Grounded in personal finance development guidelines and LLM context engineering literature [15, 392, 393, 672].

---

## SLIDE 9: LLMOps Cost Optimization (ZenML Benchmarks)

### 1. Slide Configuration
*   **Slide Title:** LLMOps Cost Optimization (ZenML-Aligned ANNA Model)
*   **Visual Layout:** Cumulative bar chart showing step-by-step token and API cost reductions. Displays the transition from naive API calls to optimized bulk batch sizes.
*   **On-Slide Content:**
    *   **LLMOps Case Study (ZenML ANNA, 2025):** Employs strategies to reduce commercial LLM cost by 75% [2, 12].
    *   **SmartSpend Optimization Suite:**
        1.  *Offline/Batch Predictions:* Submitting non-real-time tax or categorization logs yields a **50% Vertex AI discount** [8].
        2.  *Expanded Output Windows:* Transitioning to long-context output windows allows single-call processing of multiple items, contributing an **additional 22% in savings** [8, 10].
        3.  *Prompt Caching:* Caching our static 50,000-token rules and system prompt saves **3% on input token costs** [10, 12].
    *   **Target Batch Size Boundary:** Hallucinations and transaction ID errors spike from 0% to 3% when processing >100 transactions per request [13]. Batch sizes are securely capped at **120 transactions** [13, 572].

### 2. Presenter's Speaking Script
> "To prove that SmartSpend is financially sustainable for academic deployment and free tier usage, we implemented the cost-reduction strategies of the **ZenML (ANNA, 2025)** transaction categorization model [2]. Naive, real-time LLM requests consume massive tokens and incur high API overhead [7].
> 
> By utilizing Google Cloud's batch prediction APIs, we capture a **50% standard discount** [8]. By optimizing our transaction batching, we reduce individual API round-trips, achieving an **additional 22% in savings** [10, 12]. Prompt caching of our static 50,000-token rules and prompt guidelines saves a further 3% [6, 12]. This yields a cumulative **75% cost reduction** [12]. Finally, to mitigate the documented 'long context hallucination' risk, where model attribution and transaction ID errors spike above 100 transactions, we capped our processing batch sizes to a target limit of **120 transactions** [13, 572]."

### 3. Source Grounding & Defense Alignment
*   **Academic Base:** Leverages empirical LLMOps data from the ANNA-ZenML production study, documenting exact cost reductions, batching mechanics, caching structures, and contextual error rates [2, 6, 8, 10, 12, 13].

---

## SLIDE 10: Local Governance: RA 10173 & Privacy-by-Design

### 1. Slide Configuration
*   **Slide Title:** Local Governance: Compliance with Philippine RA 10173
*   **Visual Layout:** High-level architectural flowchart of the device boundary. Displays the raw transaction image being processed on-device, sensitive personal data being redacted, and masked payloads being sent to the cloud.
*   **On-Slide Content:**
    *   **Philippine Data Privacy Act (DPA) of 2012 (RA 10173):** Mandates strict protection of sensitive financial profiles [577].
    *   **Data Minimization Controls:**
        *   *On-Device Redaction:* Regex scrubbing layers redact e-wallet numbers, mobile numbers, and personal names *before* cloud sync [577, 578].
        *   *No Sensitive Collection:* Passwords, PINs, and OTPs are strictly excluded from ingestion [578].
    *   **Database Security:** SQLCipher-ready local AES-256 database encryption protects the device-side SQLite file [577, 578].
    *   **Purpose Limitation:** Clear separate consent models for localized tracking, OCR imports, and research participation [577, 578].

### 2. Presenter's Speaking Script
> "Because SmartSpend ingests sensitive e-wallet screenshots, bank statements, and transactional histories from GCash, Shopee, and Maya, our architecture must comply with the **Philippine Data Privacy Act of 2012, or Republic Act 10173** [577, 612].
> 
> We implement a strict **Privacy-by-Design** model. Our on-device preprocessing layer utilizes regular expressions to permanently scrub and redact account numbers, full names, and e-wallet mobile numbers before transaction data is synchronized with Firebase or processed via cloud LLM APIs [577, 578]. Under no circumstances does the system collect, read, or persist user passwords, PINs, or One-Time Passwords [578]. Device-side database security is managed via secure local encryption, ensuring that even if the physical Android hardware is compromised, the user's financial profile remains unreadable [578]."

### 3. Source Grounding & Defense Alignment
*   **Academic Base:** Grounded in Republic Act No. 10173 (DPA of 2012) and National Privacy Commission (NPC) data minimization and consent standards [577, 578, 590, 591].

---

## SLIDE 11: NIST AI Risk Management Framework

### 1. Slide Configuration
*   **Slide Title:** SmartSpend Proactive AI Risk Register (NIST AI RMF)
*   **Visual Layout:** A high-contrast table mapping Identified AI Harms, technical controls, metrics, and risk ownership.
*   **On-Slide Content:**
    *   **Framework Alignment:** Governed under the NIST AI Risk Management Framework (Govern, Map, Measure, Manage) [575, 576].
    *   **Key Controls in SmartSpend:**
        *   *Hallucination / Unauthorized Advice:* Isolated financial domain prompts with professional disclaimers and auto-refusal protocols for non-PFM tasks [584].
        *   *Unauthorized DB Writes:* Strict human-in-the-loop preview screens before any write or delete command executes [584].
        *   *Prompt Injection in OCR:* Isolate raw OCR text fields; treat all text imported from screenshots as completely untrusted string inputs [584].

### 2. Presenter's Speaking Script
> "To prevent AI anomalies from impacting our users, we adopted the **NIST AI Risk Management Framework**, organizing our testing into four pillars: Govern, Map, Measure, and Manage [575, 576]. We constructed a proactive AI Risk Register to handle structural harms [584].
> 
> To control model hallucinations or unsafe advice, our prompts restrict the AI to non-prescriptive personal financial management, and we enforce a mandatory professional disclaimer [584]. To prevent agentic AI commands from executing dangerous or unauthorized local database writes or deletions, we implemented a mandatory **Human-in-the-Loop** confirmation screen; no SQLite write or delete command can execute without explicit user confirmation [584]. Finally, to mitigate prompt injection risks, where malicious actors embed hidden commands in screenshot text, our backend treats all OCR-extracted strings as untrusted inputs, completely isolating them from our code execution environments [584]."

### 3. Source Grounding & Defense Alignment
*   **Academic Base:** Directly mapped to the NIST AI Risk Management Framework (AI RMF 1.0) and industry-standard security patterns [575, 576, 584, 590].

---

## SLIDE 12: Usability Evaluation Protocol

### 1. Slide Configuration
*   **Slide Title:** Evaluation Protocol & Usability Methodology
*   **Visual Layout:** Demographic breakdown chart of the $N=30$ purposive sample. Icon display of the System Usability Scale (SUS) score interpretation bands (Bangor et al., 2009).
*   **On-Slide Content:**
    *   **Usability Standard:** Standard 10-item System Usability Scale (Brooke, 1996) [643].
    *   **Demographic Composition ($N=30$ Purposive Sample):**
        *   *Primary:* Parents (Ages 35–55) managing family budgets ($N=20$) [645, 646].
        *   *Secondary:* Young Professionals (Ages 21–35) managing independent income ($N=10$) [645, 646].
    *   **Acceptance Criteria:** Adjective rating of **"Good" (SUS score $\geq 80$)** under the Bangor, Kortum, and Miller (2009) framework [643].
    *   **Local Validation:** Survey questionnaire content-validated by a business/financial management expert, system verified by an IT expert [649].

### 2. Presenter's Speaking Script
> "To evaluate the usability and practical adoption of SmartSpend, we structured a rigorous usability protocol based on the **System Usability Scale (SUS)** framework by Brooke (1996) [643]. Our evaluation utilizes a purposive sample of thirty (30) local respondents [646].
> 
> This sample is strategically composed of twenty (20) parents aged 35 to 55, representing our primary household financial decision-makers, and ten (10) young professionals aged 21 to 35 [645, 646]. After a guided, live demonstration using our built-in Demo Mode, respondents completed the 10-item SUS instrument [657]. To ensure statistical validity, we set our acceptance threshold at a score of **80 or above**, which corresponds to an adjective rating of **'Good'** under the validated Bangor, Kortum, and Miller (2009) interpretation scale [643]. Content validation of our needs survey was certified by a financial management expert, and technical correctness of our SUS process was certified by an independent IT professional [649]."

### 3. Source Grounding & Defense Alignment
*   **Academic Base:** Grounded in Brooke (1996) SUS, Bangor et al. (2009) adjective rating scales, and purposive sample methodology [643, 645, 646, 649, 728].

---

## SLIDE 13: Engineering Performance & Sync Recovery Verification

### 1. Slide Configuration
*   **Slide Title:** Engineering Performance & Verification Benchmarks
*   **Visual Layout:** Dashboard of four technical data plots: OCR Processing Precision/Recall, Language Categorization Accuracy, Offline-to-Cloud Sync Recovery Latency, and Memory Footprint.
*   **On-Slide Content:**
    *   **OCR Accuracy Targets:** Measuring field-level precision and recall for crucial transaction fields (Date, Merchant, Amount, Category) across local receipts [585].
    *   **Multilingual Categorization:** Verification of AI categorization rates across English, Tagalog, and colloquial Taglish inputs [585].
    *   **Offline SQLite Sync Recovery:** Benchmarking database conflict resolution and transaction reconstruction after simulated network dropouts [585, 586].

### 2. Presenter's Speaking Script
> "While usability is vital, capstone-level computer science research requires objective technical evaluation. Therefore, our methodology includes rigorous **Engineering Performance Benchmarks** [585].
> 
> First, we measure the field-level **precision and recall of our Optical Character Recognition (OCR)** engine across local receipt types, evaluating how accurately it extracts transaction Dates, Merchants, and Amounts without human correction [585, 616]. Second, we benchmark our AI model's **categorization accuracy** across a test set of English, Filipino, and colloquial Taglish inputs [585]. Third, we verify our **offline SQLite sync recovery** [585, 586]. We simulate network dropouts during active transaction logging, measure conflict resolution speed, and verify data completeness upon reconnecting to Firebase Firestore [585, 586]. These engineering metrics ensure that SmartSpend meets production-level software reliability standards."

### 3. Source Grounding & Defense Alignment
*   **Academic Base:** Leverages technical benchmarking practices, testing local processing constraints, language patterns, and SQLite recovery under network volatility [585, 586, 616].

---

## SLIDE 14: Post-Capstone Future Roadmap

### 1. Slide Configuration
*   **Slide Title:** Post-Capstone Future Development Roadmap
*   **Visual Layout:** Horizontal timeline highlighting three immediate technical milestones and two long-term research directions.
*   **On-Slide Content:**
    *   **Milestone 1: Paluwagan Tracker (High Priority):** A specialized tracker for rotating savings groups, utilizing our existing debt and recurring transaction tables [666, 682].
    *   **Milestone 2: Payday-Cycle-Aware Budgeting:** Implementing semi-monthly salary cycle resets (15th and 30th) to align with standard Philippine payrolls [666, 683].
    *   **Milestone 3: Secure Backend API Proxy:** Moving LLM API key management to secure server-side proxy environments to prevent APK-level key exposure [683].
    *   **Long-Term: Multi-user Shared Wallets & Remittance Tracking** [666, 684].

### 2. Presenter's Speaking Script
> "Based on our developmental findings and expert validation, we have established a clear **Post-Capstone Roadmap** to transition SmartSpend into a production-level ecosystem [666, 682].
> 
> Our highest priority is the implementation of a **Paluwagan tracker** to support local rotating savings groups, leveraging our active debt and recurring transaction database tables [682]. Second, we are building **payday-cycle-aware budgeting resets** [683]. Standard Philippine payrolls operate on semi-monthly cycles—specifically on the 15th and 30th—and our budget engine must reflect this local reality [683]. Third, to align with production-grade security, we will migrate our LLM API key management from secure runtime configuration to a **backend proxy server**, preventing any device-side key exposure [683]. We also plan to submission to the Google Play Store after implementing a comprehensive, certified privacy policy [683]."

### 3. Source Grounding & Defense Alignment
*   **Academic Base:** Addresses future work, aligning with the actual capabilities, constraints, and post-capstone recommendations documented in your manuscript [666, 682, 683, 684].

---

## SLIDE 15: Conclusion & Contributions

### 1. Slide Configuration
*   **Slide Title:** Conclusion & Capstone Contributions
*   **Visual Layout:** Minimalist slide with three bold cards highlighting: Contextual Software Contribution, Responsible AI Model, and Empirical Validation.
*   **On-Slide Content:**
    *   **Practical Contribution:** Proves that an offline-first, multilingual, AI-assisted personal finance tool can operate securely within a local Philippine context [586].
    *   **AI Democratization:** Proves that highly robust AI assistance can be engineered entirely on free-tier resource boundaries [682].
    *   **Future Impact:** Opens a pathway for longitudinal empirical research evaluating the actual behavioral impact of transaction-derived scoring on household financial resilience.

### 2. Presenter's Speaking Script
> "In conclusion, our capstone research makes three significant contributions [625]. First, we have successfully designed and engineered a functional personal finance tracking mobile application that respects and integrates local Philippine financial realities—combining offline stability, multilingual taglish processing, and multimodal screenshot import [586].
> 
> Second, we have demonstrated that highly sophisticated AI personal financial assistance can be made widely accessible and sustainable within free-tier academic deployment budgets, utilizing ZenML cost optimization frameworks [672, 682]. Finally, our research establishes a solid theoretical and empirical baseline for future longitudinal studies to measure the long-term impact of transaction-derived scoring on actual household financial resilience in the Philippines [684]. 
> 
> We are now ready to address your questions. Thank you very much."

### 3. Source Grounding & Defense Alignment
*   **Academic Base:** Direct summation of the study's conclusions, engineering achievements, and theoretical baseline contributions [586, 672, 682, 684].
