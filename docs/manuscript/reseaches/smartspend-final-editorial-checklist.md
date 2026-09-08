# SmartSpend Thesis Documentation: Final Editorial & Submission Checklist

This checklist is custom-designed for the **SmartSpend** capstone group (**Directo, Brix A.**, **Rubis, Cyrille John M.**, and **Madayag, Djaunathan Albert S.**) to conduct a meticulous, page-by-page review of the final manuscript before printing and formal submission to the **College of Computer Studies and Engineering (CCSE)** faculty at **Lorma Colleges**.

---

## PART 1: ADMINISTRATIVE & TITLE PAGE STANDARDIZATION

| Page / Section | Checkpoint Description | Status | Responsibility | Notes / Verification Details |
| :--- | :--- | :---: | :---: | :--- |
| **Title Page** | **Student Author Block**: Verify that Johnny Flores Verzola, MTS is **completely removed** from the student author block and listed strictly as the adviser. Only Directo, Rubis, and Madayag must appear. | [ ] | Brix | Must read: "by: Directo, Brix A., Rubis, Cyrille John M., and Madayag, Djaunathan Albert S." |
| **Title Page** | **Institution Name & Layout**: Verify the accrediting institution is formatted as "Lorma Colleges, CLI Bldg., San Juan Campus, La Union". | [ ] | Cyrille | Ensure correct spacing and capitalization. |
| **Approval Sheet** | **Chairperson & Dean Roles**: Ensure **Ellen F. Mangaoang, MIT** is designated as the Chairperson/Adviser, **Jeoffrey B. Layco, MIS** as Dean of CCSE, and **Jopher F. Reyes, MIT** and **Gelo Ryann M. Carbonell** as Oral Committee Members. | [ ] | Djaunathan | Spelled correctly with correct post-nominal credentials (MIT, MIS). |
| **Acknowledgement** | **Adviser & Instructor Spacing**: Confirm that **Mr. Johnny Flores Verzola, MTS** is acknowledged as the Capstone Project Adviser, and **Dr. Janelli M. Mendez, MIT** is acknowledged as the Course Instructor. | [ ] | Brix | Spelled correctly, matching their exact designations in Chapters I and II. |
| **Abstract Metadata** | **Teacher-in-Charge**: Confirm that **Shekiro R. Raposas** is designated as the Teacher-in-Charge. | [ ] | Cyrille | Check against school records for the exact term. |
| **Curriculum Vitae** | **Academic Qualifications**: Ensure the CVs for Brix, Cyrille, and Djaunathan are up to date (2026), listing Lorma Colleges as their current tertiary institution, and that Brix's birthdate (September 4, 1999), Cyrille's (August 26, 2005), and Djaunathan's (March 8, 2005) are correct. | [ ] | All | Verify addresses and contact details are professional. |

---

## PART 2: MANUSCRIPT FORMATTING & APA 7 COMPLIANCE

| Section | Checkpoint Description | Status | Responsibility | Notes / Verification Details |
| :--- | :--- | :---: | :---: | :--- |
| **Page Layout** | **Margins**: Verify that all pages have a **1.5-inch left margin** (to accommodate spiral or hard binding) and **1-inch margins** on the top, bottom, and right. | [ ] | Djaunathan | Critical for Lorma Colleges physical thesis submission. |
| **Typography** | **Font & Line Spacing**: Ensure the entire document uses **Arial or Times New Roman, 12pt**, and is **double-spaced** (except for table headers, code blocks, and formulas, which can be single-spaced). | [ ] | Cyrille | Font must be consistent across all chapters. |
| **Page Numbering** | **Preliminaries vs. Body**: Verify **Roman numerals** (i, ii, iii...) are used and centered at the bottom of the page for preliminary sections (Approval Sheet, Abstract, Table of Contents, List of Tables). Arabic numerals (1, 2, 3...) must start on Page 1 of Chapter I, placed in the **top-right corner** (or centered at the bottom on chapter opening pages). | [ ] | Brix | Cross-check page numbers against the Table of Contents. |
| **In-Text Citations** | **No Raw URLs**: Scan all chapters to ensure there are **zero raw URLs** in the body text (e.g., "according to https://bsp.gov.ph..."). All citations must use author-date formatting (e.g., "Bangko Sentral ng Pilipinas [BSP], 2021"). | [ ] | Cyrille | URLs must be restricted entirely to the References list. |
| **In-Text Citations** | **De-biased Claims**: Ensure all previous marketing claims have been completely modified. Verify that **none** of the following figures appear as established facts: "32% overspending reduction", "10-20% discretionary savings", "22% gamification boost", or "$133/month subscription overpayment". | [ ] | Brix | Must be framed strictly as hypotheses or conceptual frameworks in Chapter I. |
| **In-Text Citations** | **Exclusivity Claims**: Double-check that absolute statements like "first and only e-wallet screenshot parser" or "unique financial scoring app" are modified to "novel integrated bundle" or "specifically tailored for local demographics" to avoid panel critique due to existing local tools (BudgetPH, Alkansya, P1SO). | [ ] | Djaunathan | Focus on the integrated, offline-first execution. |

---

## PART 3: EQUATION & VARIABLE AUDIT (CHAPTER III)

SmartSpend's custom **Financial Health Score (FHS)** formulas must have 100% mathematical and variable consistency. Check the following equations in **Chapter III** page-by-page:

### 1. Full Mode Score Formula
Verify that the FHS is computed as the sum of its four components, restricted to a $[0, 100]$ range:
$$FHS_{Full} = 	ext{Savings Rate (25 pts)} + 	ext{Overspend Control (25 pts)} + 	ext{Budget Adherence (25 pts)} + 	ext{Logging Consistency (25 pts)}$$

*   [ ] **Savings Rate variable**: Check that the equation is written exactly as:
    $$S_{Savings} = 25 	imes \min\left(1.0, rac{	ext{Savings Rate}}{0.20}ight)$$
    Confirm the text defines $0.20$ as the $20\%$ target savings heuristic from the **50/30/20 rule (Warren & Tyagi, 2005)**.
*   [ ] **Overspend Control variable**: Check that the equation is written exactly as:
    $$S_{Overspend} = 25 	imes \left(1.0 - rac{	ext{Overspent Days}}{	ext{Active Days}}ight)$$
    Verify that the text explains how this measures daily spending restraint, penalizing the frequency (not just the magnitude) of budget breaches.
*   [ ] **Budget Adherence variable**: Check that the equation is written exactly as:
    $$S_{Budget} = 25 	imes \left(rac{	ext{On-Budget Categories}}{	ext{Total Budgeted Categories}}ight)$$
    Ensure the fallback is defined: if the user sets zero category budgets, this component must default to a full score of $25$ to avoid penalizing minimalist tracking.
*   [ ] **Logging Consistency variable**: Check that the equation is written exactly as:
    $$S_{Logging} = 25 	imes \left(rac{	ext{Logged Days}}{	ext{Active Days}}ight)$$
    Confirm that "Active Days" is defined as the number of days since account creation or within the evaluated 30-day window.

---

### 2. Lightweight Mode Score Formula
Verify that for students and informal workers, the FHS calculates without requiring income input:
$$FHS_{Light} = 	ext{Spending Restraint (25 pts)} + 	ext{Logging Consistency (25 pts)} + 	ext{Category Balance (25 pts)} + 	ext{Habit Streak (25 pts)}$$

*   [ ] **Spending Restraint variable**: Verify that this component is calculated against a user-defined absolute spending limit ($L_{Limit}$):
    $$S_{Restraint} = 25 	imes \min\left(1.0, rac{L_{Limit}}{	ext{Total Spent}}ight)$$
*   [ ] **Category Balance variable**: Verify that this component prevents a single category from dominating more than $40\%$ of discretionary expenditures:
    $$S_{Balance} = 25 	imes \left(1.0 - \max\left(0.0, rac{	ext{Max Category Spend}}{	ext{Total Spend}} - 0.40ight)ight)$$
*   [ ] **Habit Streak variable**: Verify that the daily logging streak rewards consistent self-monitoring:
    $$S_{Streak} = 25 	imes \min\left(1.0, rac{	ext{Consecutive Logged Days}}{14}ight)$$
    Ensure the text notes that habit formation achieves full score credit at a 14-day streak.

---

### 3. Score Adjustments (Warning Decay & Logging Gaps)
*   [ ] **Warning Decay Loop**: Check that the formula subtracts $5$ points per day for ignoring active overspending warnings, capped at a maximum deduction of $15$ points:
    $$Decay = \min(15, 5 	imes 	ext{Days Warnings Ignored})$$
    Verify that this mechanism is theoretically grounded in **Loss Aversion (Kahneman & Tversky, 1979)**.
*   [ ] **Logging Gap Adjustment**: Check that the formula applies a $+2$ points/day bonus for confirmed "no-spend" days, and a $-3$ points/day penalty for unlogged periods longer than 48 hours to prevent behavioral drift.

---

## PART 4: EMPIRICAL & USABILITY CONVERGENCE AUDIT

| Section | Checkpoint Description | Status | Responsibility | Notes / Verification Details |
| :--- | :--- | :---: | :---: | :--- |
| **Chapter I / III** | **CFPB Scale Distinction**: Ensure the manuscript **explicitly notes** that the CFPB 10-item scale is a *subjective, self-reported psychological instrument*, whereas the SmartSpend FHS is an *objective, transaction-derived indicator*. Reframe your programmatic score as a **Prototype Observed Financial Health Indicator (FHI)** based on the **CBA-MI (2018)** and **UNSGSA (2021)** dual-scale guidelines. | [ ] | Brix | Panelists will fail you if you claim the CFPB validates your programmatic algorithm. |
| **Chapter II / III** | **Purposive Sample Size ($N=30$)**: Ensure your sample size of 30 local testers is mathematically and methodologically justified: draw a clear boundary between **predictive behavioral modeling** (which requires large samples like the $N=656$ in the Atlantis Press study to achieve statistical power) and **prototype usability testing** (where Nielsen [1994, 2012] and Faulkner [2003] prove that **20–30 participants uncover over 90–95% of usability and technical defects**). | [ ] | Cyrille | This is the most common defense question regarding sample size. |
| **Chapter III** | **SUS Adjective Interpretation**: Verify that your usability score outcomes (average SUS of **82.50**) are interpreted strictly according to the **Brooke (1996)** and **Bangor, Kortum, & Miller (2009)** frameworks, mapping a score of 82.50 to a **Grade B / Adjective Rating of "Good"**. | [ ] | Djaunathan | Do not invent custom adjectives; use the Bangor (2009) adjective scale precisely. |
| **Chapter III** | **OCR & NLP Metrics**: Verify that your Technical Evaluation section documents: (1) **ML Kit Latin-script OCR field precision and recall** (target $\geq 92\%$ accuracy on GCash and Shopee invoices), and (2) **multilingual expense-parsing accuracy** (English vs. Taglish colloquialisms). | [ ] | Brix | Demonstrates engineering rigor. |
| **Chapter III** | **Offline SQLite Synchronization**: Confirm that the SQLite section details the on-device database's recovery performance under simulated network dropouts, documenting the **idempotent merge protocols** that prevent duplicate transactions when syncing back to Firebase. | [ ] | Cyrille | Essential to prove the "offline-first" thesis claim. |

---

## PART 5: DATA PRIVACY & responsible AI GOVERNANCE (RA 10173 & NIST)

| Section | Checkpoint Description | Status | Responsibility | Notes / Verification Details |
| :--- | :--- | :---: | :---: | :--- |
| **Chapter II** | **RA 10173 Compliance**: Document that the app conforms to the **Philippine Data Privacy Act of 2012** through strict client-side data minimization. Specifically, verify that your **on-device regex scrubbing layer** automatically redacts phone numbers (`09XX-XXX-XXXX`) and e-wallet account digits *before* any text is transmitted to Firebase or the Gemini API. | [ ] | Djaunathan | Keeps the system fully compliant with National Privacy Commission (NPC) circulars. |
| **Chapter II** | **On-Device SQLite Encryption**: Ensure that the future technical roadmap in Chapter IV recommends migrating the local database to an encrypted SQLite layer utilizing **SQLCipher** (AES-256) to secure data-at-rest in the event of physical device theft. | [ ] | Cyrille | Highlight this under "Technical Security Recommendations". |
| **Chapter II** | **NIST AI Risk Register**: Verify that the proactive AI Risk Register is properly tabulated in Chapter II, detailing specific controls and metrics for: (1) **model hallucinations** (restricting outputs to financial literacy, refusing investments), (2) **automation bias**, and (3) **prompt injection** via OCR text inputs. | [ ] | Brix | Maps directly to the **NIST AI Risk Management Framework (Govern, Map, Measure, Manage)**. |
| **Chapter II** | **Human-in-the-Loop (HITL)**: Document that for all 31 agentic actions, **no direct database writes or deletions** can occur autonomously. The system must always display a transparent "Review & Confirm" preview screen to mitigate hallucination risks. | [ ] | Cyrille | Vital safeguard for agentic LLM operations. |

---

## PART 6: PRE-PRINT BIBLIOGRAPHY AUDIT (APA 7)

Before compiling your final thesis booklet, Brix, Cyrille, and Djaunathan must cross-reference and verify the presence of these **essential peer-reviewed and official seed references** in the final bibliography:

*   [ ] **CFPB (2017)**:
    *   *Citation*: Consumer Financial Protection Bureau. (2017). *Financial well-being in America*. CFPB.
    *   *Verification*: Verify the official URL matches: `https://www.consumerfinance.gov/data-research/research-reports/financial-well-being-scale/`
*   [ ] **UNSGSA (2021)**:
    *   *Citation*: United Nations Secretary-General’s Special Advocate for Inclusive Finance for Development (UNSGSA). (2021). *Measuring financial health: Concepts and considerations*. UNSGSA Financial Health Working Group.
    *   *Verification*: Ensure the official URL matches: `https://www.unsgsa.org/publications/measuring-financial-health-concepts-and-considerations`
*   [ ] **FHN Score Toolkit (2021)**:
    *   *Citation*: Financial Health Network. (2021). *FinHealth Score® Toolkit: A guide to measuring and improving financial health*. Financial Health Network.
    *   *Verification*: Verify the presence of the Spend, Save, Borrow, Plan domain taxonomy in the reference list.
*   [ ] **Atlantis Press (2026)**:
    *   *Citation*: Sharma, P., Gaba, P., & Sharma, B. (2026). Can cognitive nudges in gamified digital payments foster digital financial well-being? *Proceedings of the 13th International Youth Conference (IYC 2026)*, Advances in Intelligent Systems Research, 208, 262–287.
    *   *Verification*: Verify that the PLS-SEM path coefficients mentioned in Chapter I/III are identical to this reference.
*   [ ] **ZenML LLMOps Case Study (2025)**:
    *   *Citation*: Teriffen, N. (2025). *ANNA: Cost-effective LLM transaction categorization for business banking*. ZenML LLMOps Database.
    *   *Verification*: Verify that the ZenML optimizations (offline batching, prompt caching) used to justify your 75% API cost reduction are correctly cited.
*   [ ] **WealthNX Data Pipeline (2026)**:
    *   *Citation*: Team WealthNX. (2026, March 13). How financial apps use large language models for transaction explanations. *WealthNX Blog*.
    *   *Verification*: Verify that the 5-step transaction enrichment pipeline (Ingestion, Normalization, Category Alignment, Metadata Shaping, Prompt Generation) matches this source.

---

## PART 7: SIGN-OFF & PRINT AUTHORIZATION

By signing below, the capstone researchers and adviser certify that the page-by-page editorial audit has been successfully completed, and the manuscript is authorized for professional printing and submission.

```
________________________________________     ____________________
Brix A. Directo                              Date
Capstone Researcher

________________________________________     ____________________
Cyrille John M. Rubis                        Date
Capstone Researcher

________________________________________     ____________________
Djaunathan Albert S. Madayag                 Date
Capstone Researcher

________________________________________     ____________________
Mr. Johnny Flores Verzola, MTS               Date
Capstone Project Adviser
```
