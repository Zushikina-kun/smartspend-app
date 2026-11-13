# SmartSpend — Complete Manual Fix Guide
**Date:** November 13, 2026  
**For:** Groupmates applying fixes to the GC-shared manuscript version  
**Status:** Apply ALL items below in one pass. Do not skip any.

---

## 🔴 CRITICAL — Apply These First (Content Accuracy)

---

### FIX 1 — Research Design: Remove "mixed-methods"
**Location:** Chapter II, Research Design section — first paragraph  
**Find this text:**
> "This study applied a mixed-methods developmental research design, which integrated both qualitative and quantitative approaches in collecting and analyzing data"

**Replace with:**
> "This study applied a quantitative descriptive developmental research design, which integrated quantitative approaches in collecting and analyzing data"

**Also find and remove/replace any sentence like:**
> "By combining mixed methods and developmental approaches..."

**Replace with:**
> "By adopting a quantitative developmental approach..."

**Why:** No interviews were conducted. The study is purely quantitative. Panelists will challenge "mixed-methods" immediately.

---

### FIX 2 — Research Design: Remove qualitative language
**Location:** Chapter II, Research Design — same paragraph  
**Find:**
> "structured survey questionnaires were used to collect respondents' views regarding the features and functionality of the developed application. The survey responses provided descriptive information that guided the design and improvement of the application."

**Replace with:**
> "A validated structured survey questionnaire was used to collect quantitative data on the financial management practices, budgeting challenges, and expense tracking behaviors of the target population. The collected data were analyzed using frequency and percentage to identify patterns and trends that guided the development of system features."

---

### FIX 3 — Population: Sampling method is RANDOM (not purposive)
**Location:** Chapter II, Population and Locale section  
**Find:**
> "A total of thirty (30) respondents were selected using purposive sampling."

**Replace with:**
> "A total of thirty (30) respondents were selected using random sampling, as any parent aged 35 to 55 or young professional aged 21 to 35 who met the inclusion criteria was eligible to participate."

**Keep purposive ONLY for the content validator sentence.** It should say:
> "The content validator was selected through purposive sampling based on her expertise in personal financial management."

---

### FIX 4 — Population: Respondent count is 16 + 14 (not 13 + 14 + 3)
**Location:** Chapter II, Population and Locale — narrative paragraph  
**Find any version of:**
> "Thirteen (13) respondents were parents... Fourteen (14) were young professionals... Three (3) respondents identified as both."

**Replace with:**
> "Sixteen (16) respondents were parents aged 35 to 55 who regularly handled household budgeting, bill payments, and daily expense decisions. Fourteen (14) respondents were young professionals aged 21 to 35 who managed their own income, tracked expenses, and made independent financial decisions. The three respondents who identified as both parent and young professional were reclassified as parents based on primary financial role."

**Also fix Table 3** to show:
| Category | Number of Respondents |
|---|---|
| Parents (Ages 35–55) | 16 |
| Young Professionals (Ages 21–35) | 14 |
| Content Validator (Survey) | 1 |
| **Total** | **30** |

Add a note below the table:
> *Note. The content validator participated separately and is not included in the respondent total of 30.*

---

### FIX 5 — Conclusions: "20 candidate LLM models" → "eight candidate LLM APIs"
**Location:** Chapter IV, Conclusions — Objective 2 conclusion paragraph  
**Find:**
> "The comparative evaluation of 20 candidate LLM models led to the selection of Gemini 3.5 Flash-Lite"

**Replace with:**
> "A comparative technical evaluation of eight candidate LLM APIs led to the selection of Gemini 3.5 Flash-Lite"

---

### FIX 6 — Validator name: Remove "Susan Arquisal" if still present
**Location:** Chapter II, Data Gathering section  
**Find (if still present):**
> "The survey questionnaire was reviewed by Susan C. Arquisal" or "reviewed by , a graduate of"

**Replace with:**
> "The survey questionnaire was reviewed by **Avigail Candevario, PFMe**, a graduate of Bachelor of Science in Commerce major in Management and an active business owner with experience in financial management and business operations, prior to distribution (see Appendix D)."

---

## 🟠 IMPORTANT — Apply After Critical Fixes

---

### FIX 7 — Done/Review Phase: Remove the future-features list
**Location:** Chapter II, Software Methodology — Done/Review Phase paragraph  
**Find the long paragraph that starts with:**
> "Finally, in the Done/Review Phase, the researchers evaluated the overall performance and effectiveness of the system..."

**Delete everything from this sentence onwards within that paragraph:**
> "Based on the iterative development process, several features had been identified for future implementation beyond the scope of this study. A multi-wallet system enabling separate tracking of GCash, Maya, and bank balances had been fully implemented in the final version. The system supported 20 Philippine banks and 5 digital banks, plus e-wallets (GCash, Maya, GrabPay, ShopeePay, BDO, BPI, Metrobank, and more), with automatic balance deduction upon expense logging and wallet-to-wallet transfer functionality. Automated transaction parsing through Android notification listeners, while technically feasible, required sensitive permissions subject to platform policy restrictions and was therefore deferred. Additional enhancements included the implementation of a backend proxy server for secure LLM API key handling, PDF export functionality for financial summaries, and SQLite database encryption. Long-term extensions such as investment tracking for Philippine financial instruments and shared family wallet functionality would require expanded system architecture and were proposed for subsequent research."

**Keep only:**
> "Finally, in the Done/Review Phase, the researchers evaluated the overall performance and effectiveness of the system. This included analyzing SUS scores, reviewing user feedback, and assessing whether the application met its intended objectives. The researchers identified which features performed well and which areas required improvement. Insights gathered from this phase were used to refine the system and provide recommendations for future development."

---

### FIX 8 — Figure # placeholder
**Location:** Chapter II, Software Methodology — first sentence  
**Find:**
> "...followed the Agile Kanban Software Development Methodology as seen in Figure #."

**Replace with:**
> "...followed the Agile Kanban Software Development Methodology as seen in Figure 4."

---

### FIX 9 — Appendix B cross-reference (Informed Consent)
**Location:** Chapter II, Ethical Considerations section  
**Find the sentence:**
> "Informed consent was obtained from all participants before their involvement in the study."

**Add "(see Appendix B)" at the end:**
> "Informed consent was obtained from all participants before their involvement in the study (see Appendix B)."

---

### FIX 10 — Appendix D cross-reference (Validator certificate)
**Location:** Chapter II, wherever Avigail Candevario is mentioned as content validator  
**Find:**
> "The survey questionnaire underwent content validation by Avigail Candevario, PFMe..."

**Add "(see Appendix D)" at the end of that sentence:**
> "...to ensure relevance, clarity, and appropriateness of the instrument (see Appendix D)."

---

### FIX 11 — Data Gathering: No interviews statement
**Location:** Chapter II, Data Gathering Tools and Procedure  
**Find (if present):**
> "No formal open-ended Survey data was collected."

**Fix the capitalization and add clarity:**
> "No formal open-ended survey data was collected. The study used a structured quantitative survey instrument only; no interviews were conducted."

---

### FIX 12 — Abstract: Verify these exact phrases are present
Check the Abstract paragraph and confirm it contains all of the following. If any are missing or worded differently, fix them:
- ✅ "quantitative descriptive developmental research design"
- ✅ "Gemini 3.5 Flash-Lite as the primary model"
- ✅ "eight-provider cloud failover chain"
- ✅ "mean SUS score of 61.83 (SD = 17.58)"
- ✅ "a grade of D and an adjective rating of "OK""
- ✅ "Nine recommendations were identified"
- ✅ "below the 68-point benchmark (Sauro & Lewis, 2016) and the pre-established target of 80"

---

### FIX 13 — SUS Results: Add median to results paragraph
**Location:** Chapter III, SUS results narrative paragraph  
**Find:**
> "SmartSpend achieved an overall mean SUS score of 61.83 (SD = 17.58"

**Add median after SD:**
> "SmartSpend achieved an overall mean SUS score of 61.83 (SD = 17.58, median = 55.00"

---

### FIX 14 — Chapter III: Add "eight candidate LLM APIs" in LLM selection section
**Location:** Chapter III, Design and Development — LLM selection paragraph  
**Find:**
> "The selection of an appropriate LLM API was a critical design decision..."

In the narrative that follows, make sure the selection conclusion says:
> "A comparative technical evaluation of eight candidate LLM APIs resulted in the selection of Gemini 3.5 Flash-Lite as the primary model..."

If it says "Gemini 3.5 Flash-Lite was selected" without mentioning the number of candidates, add "from eight evaluated providers" after the model name.

---

### FIX 15 — Conclusions: Remove duplicate objective paragraphs
**Location:** Chapter IV, Conclusions  
**Problem:** The same three objectives are stated multiple times in slightly different wording. Keep only ONE clear paragraph per objective.

**The conclusions section should have exactly this structure:**

**Paragraph 1 (Overview):**
> "The needs assessment confirmed that 96.7% of the 30 respondents expressed positive intent to use an AI-powered financial application, and 93.3% already used GCash, validating the study's target population and feature priorities. SmartSpend v3.1.0 was successfully developed with all identified features implemented. The SUS evaluation yielded a mean score of 61.83 (adjective: "OK"), below the ≥80 target. Therefore, all three objectives of the study were addressed, with the third objective partially achieved."

**Paragraph 2 (Objective 1):**
> "The first objective was to assess the financial management practices, budgeting challenges, and expense tracking behaviors of parents aged 35 to 55 and young professionals aged 21 to 35. The needs assessment of thirty (30) respondents revealed that 96.7% expressed positive intent to use an AI-powered financial application and 93.3% already used GCash. The first objective was **achieved**."

**Paragraph 3 (Objective 2):**
> "The second objective was to design and develop the SmartSpend mobile application with the integration of a suitable LLM API. SmartSpend v3.1.0 was developed as a working Android application with multi-modal expense input, offline-first local storage, 34 AI actions, and a Financial Health Score formally classified as a Prototype Observed Financial Health Indicator. A comparative technical evaluation of eight candidate LLM APIs led to the selection of Gemini 3.5 Flash-Lite as the primary model, supported by a seven-provider failover chain. The second objective was **achieved**."

**Paragraph 4 (Objective 3):**
> "The third objective was to evaluate the usability of SmartSpend using the System Usability Scale. The evaluation yielded a mean SUS score of 61.83 (SD = 17.58), which was below the pre-established acceptance threshold of 80 and the 68-point average benchmark. The third objective was **partially achieved**."

Delete any extra paragraphs that repeat these same points.

---

## 🟡 MINOR — Fix if You See These

---

### FIX 16 — Chapter III heading typo (if still present)
**Find:**
> "Designed and Developed of the SmartSpend Mobile Application"

**Replace with:**
> "Design and Development of the SmartSpend Mobile Application"

---

### FIX 17 — "proposed" language anywhere in Chapters I-III
**Find any instance of:**
- "this study proposed SmartSpend"
- "the proposed system"
- "will be developed"

**Replace with:**
- "this study developed SmartSpend"
- "the developed system"
- "was developed"

(Exception: "proposed" is fine in Chapter IV Recommendations where it means future work)

---

### FIX 18 — Technical Background: Focus on SmartSpend usage, not general descriptions
**Location:** Chapter I, Technical Background  
Each technology entry should answer "how was it used in SmartSpend" — not what the technology is in general.

**Examples of wrong style:**
> "Flutter is an open-source UI framework developed by Google that..."

**Correct style:**
> "Flutter was used to build the SmartSpend Android application, providing a consistent and responsive user interface across different screen sizes."

Apply this fix to: Flutter, SQLite, Firebase Firestore, Firebase Auth, LLM API, Speech-to-Text, Google ML Kit OCR, Mobile Scanner, fl_chart, local_auth, Financial Health Score entries.

---

## 📋 PRESENTATION FIXES (SmartSpend_Defense.pptx)

The PPT is mostly correct. Only these items need manual attention:

---

### PPT FIX 1 — Slide 8 speaker notes: Add purposive sampling
**Where:** Slide 8 (Methodology) → View > Notes  
**Add this to the notes:**
> "Note: Purposive sampling was used for the content validator (Avigail Candevario, PFMe), selected based on her expertise in personal financial management. Random sampling was used for all 30 respondents."

---

### PPT FIX 2 — Slide 12: Confirm LLM evaluation count
**Where:** Slide 12 (LLM Selection) — subtitle text  
**Confirm it says:**
> "Evaluation: 6 weighted criteria, 8 candidate LLM APIs"

If it still says "20 candidate models" change to "8 candidate LLM APIs"

---

### PPT FIX 3 — Slide 17: Confirm Conclusion 2 wording
**Where:** Slide 17 (Conclusions) — Objective 2 bullet  
**Confirm it says something like:**
> "v3.1.0 working Android app: 34 AI actions, Gemini 3.5 Flash-Lite (selected from 8 candidate LLM APIs) with failover, Financial Health Score."

---

### PPT FIX 4 — Slide 18 speaker notes: Confirm Recs 8 and 9
**Where:** Slide 18 → View > Notes  
**Confirm the notes contain:**
> "8. UI/UX refinement — Address consistency (Q6) and complexity (Q2) from SUS"  
> "9. Formal parsing evaluation — 50+ standardized receipts for OCR/AI accuracy measurement"

If missing, add them.

---

## 📋 SCRIPT FIXES (4_DEFENSE_SCRIPT_FINAL.md)

The script is mostly correct after our last fix session. Confirm these only:

---

### SCRIPT FIX 1 — SAY/DON'T SAY table
**Find the table at the top of the script. Confirm ❌ DON'T SAY column has:**
- "mixed methods" (not mixed-methods)
- NOT "quantitative descriptive developmental" in the don't say column

If the don't say column says "quantitative descriptive developmental" that is WRONG — that's what you SHOULD say.

---

### SCRIPT FIX 2 — Slide 12 spoken text
**Find:**
> "We evaluated 20 candidate models across six providers"

**Replace with:**
> "We evaluated eight candidate LLM APIs across multiple providers"

---

### SCRIPT FIX 3 — Q6 answer (LLM question)
**Find:**
> "We evaluated 20 candidate models across six providers — including models from OpenAI, Anthropic, Groq, Mistral, and Google"

**Replace with:**
> "We evaluated eight candidate LLM APIs — including models from Google, Groq, and Cerebras"

(Anthropic and Mistral were NOT actually evaluated — removing them prevents a panel challenge)

---

### SCRIPT FIX 4 — Q1 and Q5 recommendation reference
**Find:**
> "which is directly addressed by **Recommendation 1**, which calls for a UI/UX redesign"

**Replace with:**
> "which is directly addressed by **Recommendation 8**, which calls for a UI/UX redesign"

(Recommendation 1 is payday-cycle budgeting, not UI/UX)

---

### SCRIPT FIX 5 — End reminders (bottom of script)
**Find:**
> "Don't say 'quantitative descriptive developmental' — the study is purely quantitative."

**Replace with:**
> "Always say 'quantitative descriptive developmental' — the study is purely quantitative, no interviews were conducted."

---

## ✅ WHAT IS ALREADY CORRECT (Do Not Change)

These values are confirmed correct in all three files. Never change them:

| Value | Correct |
|---|---|
| SUS Score | **61.83** |
| Standard Deviation | **SD = 17.58** |
| Median | **55.00** |
| Grade | **D** |
| Adjective | **"OK"** |
| Objective 3 outcome | **"partially achieved"** |
| Needs-assessment N | **30 (16 parents + 14 YP)** |
| SUS evaluation N | **30 valid of 36 (10 parents + 20 YP)** |
| AI intent % | **96.7% = 29 of 30** |
| GCash usage % | **93.3% = 28 of 30** |
| Primary AI model | **Gemini 3.5 Flash-Lite** |
| Failover chain | **8 providers, 7 fallbacks** |
| Agentic actions | **34** |
| Recommendations | **9** |
| Research design | **Quantitative descriptive developmental** |
| Respondent sampling | **Random sampling** |
| Validator sampling | **Purposive sampling** |
| Content validator | **Avigail Candevario, PFMe** |
| Adviser | **Ellen Flores Mangaoang, DIT** |
| Panel Chair | **Jeoffrey B. Layco, MIS** |
| Panel Member 1 | **Shekiro R. Raposas, MTS, MIS** |
| Panel Member 2 | **Mary-Ann Mzana, MTS** |
| Defense | **November 16, 2026 · 3:00 PM** |

---

## 🔢 Fix Priority Order

If short on time, do them in this order:

1. FIX 1 — Remove "mixed-methods" from Research Design ⬅ MOST CRITICAL
2. FIX 3 — Change purposive → random for respondents
3. FIX 4 — Change 13+14+3 → 16+14 in Table 3 and narrative
4. FIX 5 — Change "20 candidate LLM models" → "eight candidate LLM APIs"
5. FIX 6 — Replace Susan Arquisal with Avigail Candevario, PFMe
6. FIX 7 — Remove future-features list from Done/Review
7. FIX 8 — Replace Figure # with Figure 4
8. FIX 2 — Remove qualitative language from Research Design
9. FIX 9 — Add "(see Appendix B)" to informed consent sentence
10. FIX 10 — Add "(see Appendix D)" to validator sentence
11. FIX 15 — Clean up duplicate conclusion paragraphs
12. All remaining fixes (11–18 and PPT/Script)

---

*Generated: November 13, 2026 · Based on final cross-check audit of manuscript, PPT, and defense script*
