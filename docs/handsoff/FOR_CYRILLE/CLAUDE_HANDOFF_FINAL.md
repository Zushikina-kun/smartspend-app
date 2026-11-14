# SmartSpend — FINAL Handoff for Claude
**Date:** November 13, 2026  
**This supersedes:** CLAUDE_HANDOFF.md, MANUAL_FIX_GUIDE.md, and all earlier Claude guides.  
**Based on:** Complete manuscript text + all screenshots + Claude's two guide passes + our audit.

---

## GROUND RULES

**Use these values everywhere. Never change them.**

| Protected value | Correct form |
|---|---|
| SUS score | **61.83** |
| SD | **17.58** |
| Median | **55.00** |
| Grade | **D** |
| Adjective | **"OK"** |
| Objective 3 outcome | **"partially achieved"** |
| Needs-assessment N | **30** |
| Needs-assessment split | **16 parents + 14 YP = 30** (3 "both" reclassified as parents) |
| SUS evaluation split | **10 parents + 20 YP = 30** (separate group) |
| AI intent | **96.7% (29/30)** |
| GCash usage | **93.3% (28/30)** |
| Primary AI model | **Gemini 3.5 Flash-Lite** |
| Failover description | **eight-provider cloud failover chain (Gemini 3.5 Flash-Lite as primary, seven fallbacks)** |
| Agentic actions | **34** |
| Recommendations | **9** |
| Research design | **quantitative descriptive developmental** |
| Respondent sampling | **random sampling** |
| Validator sampling | **purposive sampling** |
| Content validator | **Avigail Candevario, PFMe** |
| LLM candidates evaluated | **ten candidate LLM models** (Table 6 has 10 rows) |

---

## WHAT IS ALREADY CORRECT — SKIP THESE

These are confirmed correct in the manuscript you have. Do not touch.

- Abstract: all protected values present and correct ✅
- Scope and Limitations: clean 1-paragraph, Android only ✅
- Data Gathering Tools: per-objective structure (For the first/second/third objective...) ✅
- Avigail Candevario, PFMe as validator ✅
- Purposive sampling for validator ✅
- Random sampling sentence for respondents ✅
- Table 3: shows 16 + 14 + validator ✅
- Ethical Considerations: content correct ✅
- All 9 recommendations present ✅
- Figure 10 (Flowchart) description ✅
- Figure 11 (Use Case) description ✅
- Figure 12 (Visual TOC) description ✅
- Figure 13 (Login) description ✅
- Figure 16 (Receipt Scanning) description ✅
- Figure 19 (Local AI Setup) description ✅
- Figure 20 (SUS Computation) description ✅
- Figure 21 (SUS by Group) description ✅
- Table 7 (Overall SUS) ✅
- Table 8 (SUS by Group) ✅
- Table 9 (Multimodal Parsing) ✅

---

## FIXES — apply top to bottom

---

### FIX 1 — Research Design: Remove all qualitative language (🔴 CRITICAL)

**Location:** Chapter II, Research Design section

**Replace paragraph 1 entirely:**

FIND (whole paragraph starting with):
> "This study applied a quantitative descriptive developmental design, which integrated both qualitative and quantitative approaches..."

REPLACE WITH:
> This study applied a quantitative descriptive developmental research design, which relied on quantitative approaches in collecting and analyzing data. This design was appropriate because it allowed the researchers to describe the financial management practices of the target population and to measure the usability of the developed system through standardized numerical scores. Through this approach, the researchers were able to capture measurable trends in user behavior, preferences, and challenges.

**In paragraph 3, find:**
> "On the other hand, the quantitative aspect of the study involved the use of validated structured survey questionnaires, which underwent content validation by subject matter experts to ensure clarity, relevance, and alignment with the objectives of the study. These questionnaires were used to collect measurable data regarding financial habits, expense tracking practices, and common difficulties encountered by the respondents. The collected data were analyzed to identify patterns, frequencies, and trends that supported the development of system features aligned with user needs."

REPLACE WITH:
> The survey questionnaire underwent content validation by a subject matter expert to ensure clarity, relevance, and alignment with the objectives of the study.

(Keep the SUS sentences that follow — only delete the repeated survey sentences above.)

**In the developmental paragraph, find:**
> "based on the data gathered from both qualitative and quantitative methods."

REPLACE WITH:
> "based on the survey and usability data gathered."

**In the final paragraph, find:**
> "By combining quantitative descriptive developmental and developmental approaches, the study ensured"

REPLACE WITH:
> "By adopting a quantitative descriptive developmental approach, the study ensured"

Then find:
> "This integrated research design supported"

REPLACE WITH:
> "This research design supported"

**Also delete the Creswell & Plano Clark (2011) citation.** That book is about mixed-methods research. It is cited but doesn't support a quantitative-only design, and it is missing from your References anyway.

---

### FIX 2 — Ten candidate LLM models (🔴 CRITICAL)

Your Table 6 has **10 rows** (Gemini 3.5 Flash-Lite, Gemini 3.5 Flash, GPT-OSS 120B Groq, Qwen 3.6 27B, Qwen 3.8 27B, GPT-OSS 20B, Groq Compound Mini, GPT-OSS 120B Cerebras, Mistral 7B, Gemma 2 9B). The number must match your own table.

**In Chapter I, Technical Background, LLM API Integration, find:**
> "selected after a comparative evaluation of eight providers based on"

REPLACE WITH:
> "selected after a comparative evaluation of ten candidate models from four providers (see Table 6) based on"

**In Chapter III, LLM selection paragraph, find:**
> "eight candidate LLM APIs" (anywhere it appears)

REPLACE WITH:
> "ten candidate models from four providers"

**In Chapter IV, Conclusions, find:**
> "The comparative evaluation of 20 candidate LLM models"
OR any version saying "eight candidate"

REPLACE WITH:
> "A comparative technical evaluation of ten candidate models from four providers led to the selection of Gemini 3.5 Flash-Lite as the primary model, supported by an eight-provider cloud failover chain (seven fallbacks)."

**Note on "eight-provider chain":** The Abstract correctly says "eight-provider cloud failover chain (Gemini 3.5 Flash-Lite as primary, seven fallbacks)." This is correct — there are 8 models in the active chain (1 primary + 7 fallbacks). **Do not change the Abstract.** The 10 candidates evaluated ≠ the 8 in the final chain. Some candidates were not selected.

---

### FIX 3 — Table 3: Remove validator row, clean up total (🔴 CRITICAL)

**Current Table 3** shows 16 + 14 + 1 validator = total 30, which is misleading (the 30 doesn't include the validator).

**Replace Table 3 with:**

| Category | Number of Respondents |
|---|---|
| Parents (Ages 35–55) | 16 |
| Young Professionals (Ages 21–35) | 14 |
| **Total Respondents** | **30** |

**Add this note below the table:**
> Note. One content validator participated separately for survey instrument validation and is not counted among the 30 respondents.

**Also delete** the stray note that appears above Figure 4 in Software Methodology:
> "Note. The content validator participated separately and is not included in the respondent total of 30."

That note is a leftover from an earlier edit and is now duplicated incorrectly.

---

### FIX 4 — Population paragraph: Add the 3 "both" reclassification sentence (🟠 IMPORTANT)

**Location:** Chapter II, Population and Locale, after the Fourteen (14) sentence.

**Find:**
> "Fourteen (14) respondents were young professionals who managed their own income, tracked expenses, and made independent financial decisions."

**Add this sentence after it:**
> "Three respondents identified as both a parent and a young professional and were classified as parents based on their primary financial role, yielding a final count of 16 parents and 14 young professionals."

---

### FIX 5 — Population paragraph: Fix "intentional selection" contradicts random sampling (🟠 IMPORTANT)

**Find the last paragraph of Population and Locale:**
> "The researchers utilized random sampling in selecting participants. This method allowed the intentional selection of individuals who had relevant experience in budgeting, expense tracking, and financial decision-making, ensuring that the collected data was meaningful and directly aligned with the research objectives."

**Replace with:**
> Any parent aged 35 to 55 or young professional aged 21 to 35 who managed personal or household finances was eligible to participate, and respondents were selected at random from among those who met these criteria.

("Intentional selection" is the definition of purposive sampling, not random sampling — this contradicts the whole chapter.)

---

### FIX 6 — Table 5: Fix column headers to match 16+14 (🟠 IMPORTANT)

**Current Table 5** has columns `Parents (n = 13)`, `Young Professionals (n = 14)`, `Both (n = 3)†`, `Total (N = 30)†`

The text and Table 3 say 16 parents. The table columns still show 13 and "Both". Replace the table header row and Part A data with the version below. The tracking methods in Part B are recalculated to reflect 16 parents (13 original + 3 reclassified).

| Item | Parents (n = 16) | Young Professionals (n = 14) | Total (N = 30) |
|---|---|---|---|
| **A. Demographic profile, f (%)** | | | |
| Parents aged 35–55 | 16 (53.3%) | — | 16 (53.3%) |
| Young professionals aged 21–35 | — | 14 (46.7%) | 14 (46.7%) |
| Employed full-time | — | — | 10 (33.3%) |
| Freelance or contractual | — | — | 9 (30.0%) |
| Self-employed | — | — | 8 (26.7%) |
| Unemployed or part-time | — | — | 3 (10.0%) |
| GCash users | — | — | 28 (93.3%) |
| **B. Expense tracking methods used, f (%)** | | | |
| Receipts | 14 (87.5%) | 13 (92.9%) | 27 (90.0%) |
| Mental estimates | 9 (56.3%) | 7 (50.0%) | 16 (53.3%) |
| E-wallet transaction history | 7 (43.8%) | 6 (42.9%) | 13 (43.3%) |
| Notes app | 4 (25.0%) | 5 (35.7%) | 9 (30.0%) |
| Notebook | 4 (25.0%) | 3 (21.4%) | 7 (23.3%) |
| Mobile app | 1 (6.3%) | 2 (14.3%) | 3 (10.0%) |

**Delete the † marks.** Keep the Note below the table — it already says `(parents n = 16, young professionals n = 14)` which is correct.

---

### FIX 7 — Table 5 intro text: Fix "16 parents" vs "13 parents" (🟠 IMPORTANT)

**Find in Chapter III:**
> "The sample comprised 16 parents aged 35–55 (53.3%) and 14 young professionals aged 21–35 (46.7%)."

This is correct. **Keep it.**

**But also find and delete:**
> "The 3 respondents who identified as both parent and young professional were reclassified by primary financial role for SUS subgroup analysis, yielding 10 parents and 20 young professionals."

**Replace with:**
> "The three respondents who identified as both parent and young professional were classified as parents based on their primary financial role."

(The SUS sample 10+20 is a separate group explained in Table 8 — it doesn't need to be mentioned here.)

---

### FIX 8 — Chapter III heading typo (🟠 IMPORTANT)

**Find:**
> "Designed and Developed of the SmartSpend Mobile Application - see objective"

**Replace with:**
> "Design and Development of the SmartSpend Mobile Application"

---

### FIX 9 — Fill in the missing paragraph in Chapter III (🟠 IMPORTANT)

**Find the placeholder:**
> "EXPLAIN WHAT DID IN THE DESIGN AND DEVELOPMENT"

**Replace with:**
> Guided by the needs assessment results, the researchers designed SmartSpend as an offline-first Flutter application for Android. A local SQLite database stored all financial records, with optional Firebase Firestore synchronization and Firebase Authentication for signed-in users. Because most respondents tracked expenses through receipts and e-wallet histories, expense input was designed around multiple modalities: natural-language text and voice, receipt OCR, barcode scanning, and batch screenshot import of e-wallet transactions. An LLM-powered assistant, Peso, was integrated to parse these inputs and execute 34 financial actions, and a Financial Health Score was designed to summarize budgeting behavior. The selection of the LLM API, the computation of the Financial Health Score, and the resulting system are presented in the sections that follow.

---

### FIX 10 — LLM paragraph: Add "From the ten candidates in Table 6" (🟠 IMPORTANT)

**Find:**
> "Gemini 3.5 Flash-Lite was selected as the primary model because"

**Replace with:**
> "From the ten candidate models in Table 6, Gemini 3.5 Flash-Lite was selected as the primary model because"

---

### FIX 11 — Delete leftover editor notes in Chapter III (🟠 IMPORTANT)

**Delete this sentence** (it is an internal note, not manuscript text):
> "The behavior of this component when zero category budgets were configured was a known open item pending confirmation against the current build and was not asserted here."

**Delete this paragraph** (it is an instruction to Kiro, not manuscript text):
> "These behaviours applied the same ideas used for Warning Decay... Present Peso as a design feature, not as evidence of behaviour change, and avoid phrases such as 'dopamine reinforcement'."

**Delete this placeholder:**
> "Introductory paragraph then table then discussion of the table"

---

### FIX 12 — Figure 15 description is WRONG (🔴 CRITICAL)

**Caption says:** "Figure 15. Expense Logging Through Peso Chat"
**Current description talks about Local AI Mode setup — WRONG.**

**Find the paragraph starting with:**
> "Figure 15 presents the Local AI Mode setup screen of SmartSpend. This screen guides users who wish to configure an optional offline AI model..."

**Replace entirely with:**
> Figure 15 presents expense logging through the Peso chat interface of SmartSpend. The user typed "nag-lunch ako 150 pesos" in Filipino, and the AI assistant Peso replied conversationally in Taglish, confirming the transaction. A session summary card at the bottom confirmed one recorded item (Lunch, ₱150), and a snackbar showed the automatic deduction from Cash on Hand with an Undo option available. A banner at the top detected GCash or bank text in the clipboard and offered to paste it for automatic logging. This demonstrates the system's support for natural language input and its agentic action capability — parsing and recording the transaction in a single step without manual form filling.

---

### FIX 13 — Figure 17 description is WRONG (🔴 CRITICAL)

**Caption says:** "Figure 17. Financial Health Score Breakdown"
**Current description talks about SUS score distribution — WRONG.**

**Find the paragraph starting with:**
> "Figure 17 presents the distribution of individual SUS scores across all 30 valid respondents. The chart shows the spread of scores ranging from 35.0 to 92.5..."

**Replace entirely with:**
> Figure 17 presents the Financial Health Score breakdown screen of SmartSpend, displaying a detailed view of a demo user's score. The screen shows the overall score tier, a list of identified strengths and focus areas, and the four scored components: Savings Rate, Overspend Control, Budget Adherence, and Logging Consistency, each contributing up to 25 points. Each component also displays a brief actionable tip, helping users understand specifically which behavior to improve rather than presenting only a final number.

---

### FIX 14 — Figure 18 description is WRONG (🔴 CRITICAL)

**Caption says:** "Figure 18. Budgets, Safe-to-Spend, and Savings Goals"
**Current description talks about SUS scores by respondent group — WRONG.**

**Find the paragraph starting with:**
> "Figure 18 presents the SUS scores broken down by respondent group. Parents aged 35–55 (n = 10) obtained a mean score of 58.25..."

**Replace entirely with:**
> Figure 18 presents the Budgets screen of SmartSpend, showing the user's spending limits and current progress for each expense category. The header summarizes the total budgeted amount, total amount spent, and total income for the current period, with a warning indicator when total budgets exceed income. Each category card shows the amount spent against the set limit, the remaining balance, and a pace indicator showing whether spending is on track relative to the number of days elapsed in the month. Users can add, edit, or remove categories directly from this screen.

---

### FIX 15 — Move the SUS content to after Figure 21 (🔴 CRITICAL)

The old SUS descriptions that were under Figures 17 and 18 contained real content that now has no home. Place it correctly.

**After Figure 21 caption** ("Figure 21. SUS Scores by Respondent Group"), check if the description paragraph is already there. It should read about the bar chart with error bars showing 58.25 and 63.62. That is already written correctly as Figure 21's description — good, keep it.

**The "scores ranging from 35.0 to 92.5" SUS distribution text** — if it doesn't appear anywhere after removing it from Figure 17, it means that content was deleted. This is acceptable since Figure 21 already shows the by-group results. The distribution histogram (Figure 3.12 in Maam Ellen's TOC) may not exist as an image in your manuscript body. If there is no histogram image, delete any reference to it in the TOC as well.

---

### FIX 16 — Fix "Tables 3.3 and 3.4" reference (🔴 CRITICAL)

**Find:**
> "As shown in Tables 3.3 and 3.4,"

**Replace with:**
> "As shown in Tables 7 and 8,"

---

### FIX 17 — Fix "No formal open-ended Survey" capitalization (🟡)

**Find:**
> "No formal open-ended Survey data was collected. The study used a structured quantitative survey instrument, and no open-ended or interview data were collected."

**Replace with:**
> "No formal open-ended survey data was collected. The study used a structured quantitative survey instrument only; no interviews were conducted."

---

### FIX 18 — Done/Review Phase: Remove future-features changelog (🟠 IMPORTANT)

**Find the sentence:**
> "such as adding bank integration or improving AI accuracy."

Change the period: end the sentence at "future development." Then **delete everything after it** starting from:
> "Based on the iterative development process, several features had been identified..."

...all the way through:
> "...would require expanded system architecture and were proposed for subsequent research."

The Done/Review paragraph should end with:
> "Insights gathered from this phase were used to refine the system and provide recommendations for future development."

---

### FIX 19 — Figure # placeholder (🟠 IMPORTANT)

**Find:**
> "as seen in Figure #."

**Replace with:**
> "as seen in Figure 4."

---

### FIX 20 — Add Appendix cross-references (🟡)

**In Ethical Considerations, find:**
> "Informed consent was obtained from all participants before their involvement in the study."

**Add "(see Appendix B)" before the period:**
> "Informed consent was obtained from all participants before their involvement in the study (see Appendix B)."

**In Data Gathering, find:**
> "...experience in financial management and business operations. Survey responses were tallied"

**Change to:**
> "...experience in financial management and business operations (see Appendix D). Survey responses were tallied"

---

### FIX 21 — Conclusions: Replace all three paragraphs (🔴 CRITICAL)

**Delete all existing conclusion paragraphs** and replace with these four:

---
The needs assessment confirmed that 96.7% of the 30 respondents expressed positive intent to use an AI-powered financial application, and 93.3% already used GCash, validating the study's target population and feature priorities. SmartSpend v3.1.0 was successfully developed with its core planned features implemented. The SUS evaluation yielded a mean score of 61.83 (adjective: "OK"), below the ≥80 target. Therefore, all three objectives of the study were addressed, with the third objective partially achieved.

The first objective was to assess the financial management practices, budgeting challenges, and expense tracking behaviors of parents aged 35 to 55 and young professionals aged 21 to 35. The needs assessment of thirty (30) respondents revealed that 96.7% expressed positive intent to use an AI-powered financial application and 93.3% already used GCash. The first objective was **achieved**.

The second objective was to design and develop the SmartSpend mobile application with the integration of a suitable LLM API. SmartSpend v3.1.0 was developed as a working Android application with multi-modal expense input, offline-first local storage, 34 AI actions, and a Financial Health Score formally classified as a Prototype Observed Financial Health Indicator. A comparative technical evaluation of ten candidate models from four providers led to the selection of Gemini 3.5 Flash-Lite as the primary model, supported by an eight-provider cloud failover chain (Gemini 3.5 Flash-Lite as primary, seven fallbacks). The second objective was **achieved**.

The third objective was to evaluate the usability of SmartSpend using the System Usability Scale. The evaluation yielded a mean SUS score of 61.83 (SD = 17.58, Median = 55.00) from 30 valid respondents, which was below the pre-established acceptance threshold of 80 and the 68-point average benchmark (Sauro & Lewis, 2016). The third objective was **partially achieved**.

---

### FIX 22 — Front matter: Delete the first/old TOC (🟡)

You have two Tables of Contents. The first old one lists:
- "C – Transcript of Interview"  
- Chapters without roman numerals
- Acknowledgement/Dedication before Abstract

**Delete the entire first TOC.** Keep only the second one (the one that starts with "Title Page ... i" and has APPENDIX C: SUS Questionnaire).

---

### FIX 23 — Fix Appendix C label in the TOC you keep (🟡)

**In the remaining TOC, find:**
> "APPENDIX C: Transcript of Interview"
OR
> "APPENDIX C: SUS Individual Scores"

**Replace with:**
> "APPENDIX C: System Usability Scale (SUS) Questionnaire"

The actual Appendix C content is the SUS questionnaire (confirmed from the manuscript text).

---

### FIX 24 — Figure 14 Home Dashboard: "Expert Tracker" label (🟡)

**Looking at the actual Home Dashboard screenshot:** The label next to 97/100 says "Expert Tracker" (not "Consistent Saver"). "Consistent Saver" is a separate card below.

**Find:**
> "A management score of 97 out of 100 with a 'Consistent Saver' achievement badge is displayed"

**Replace with:**
> "A management score of 97 out of 100 with an 'Expert Tracker' label is displayed, followed by a 'Consistent Saver' achievement card"

---

### FIX 25 — Technical Background: Remove library citations (🟡 — per Maam Ellen's comments)

**In the Technical Background section only**, delete these parenthetical citations from the end of their sentences:
- `(Google, 2024c)` — from Firebase Firestore paragraph
- `(Google, 2024a)` — from Firebase Authentication paragraph
- `(Google, 2024b)` — from Firebase Crashlytics paragraph
- `(Sloane, 2022)` — from Speech-to-Text paragraph
- `(Google, 2024e)` — from ML Kit OCR paragraph
- `(Bociek, 2023; ZXing, 2023)` — from Mobile Scanner paragraph
- `(Flutter 4 Fun, 2022)` — from fl_chart paragraph
- `(The Flutter Authors, 2013)` — from local_auth paragraph

Keep the description text. Only remove the citations. Keep all citations in other chapters (Project Context, Methodology, etc.) unchanged.

---

### FIX 26 — References: Check these three (🟡)

1. **Google (2024f)** is cited in the LLM paragraph with `(Li et al., 2024; Google, 2024f)`. Check if it's in your References list. If missing, add:
   > Google. (2024f). *Gemini API documentation*. https://ai.google.dev/docs

2. **Creswell & Plano Clark (2011)** — After FIX 1 removes this citation from Research Design, check if it appears anywhere else. If not, delete the reference entry too.

3. **UNSGSA (2021)** is in the references but the in-text cite says `(Gubbins, Mazzotta & Rhyne, 2021)`. These need to match. Either:
   - Change the reference entry to: Gubbins, E., Mazzotta, B., & Rhyne, E. (2021). *Measuring financial health: Concepts and considerations*. UNSGSA. https://www.unsgsa.org
   - Or change the in-text cite to `(UNSGSA, 2021)`

---

## AFTER ALL FIXES — verify this checklist

- [ ] Research Design says "quantitative descriptive developmental" with no qualitative/mixed language
- [ ] Table 6 has 10 rows, and all references say "ten candidate models from four providers"
- [ ] Table 3 shows 16+14=30, with note about validator being separate
- [ ] Table 5 columns show Parents (n=16), no "Both" column
- [ ] Figure 15 description = Peso chat logging (not Local AI)
- [ ] Figure 17 description = FHS Breakdown screen (not SUS distribution)
- [ ] Figure 18 description = Budgets screen (not SUS by group)
- [ ] "Tables 7 and 8" (not "Tables 3.3 and 3.4")
- [ ] "Figure 4" (not "Figure #")
- [ ] Done/Review paragraph has no multi-wallet/bank changelog
- [ ] Conclusions say "ten candidate models from four providers"
- [ ] Conclusions have clean 4 paragraphs, no duplicate content
- [ ] Only one TOC (the correct one with "APPENDIX C: SUS Questionnaire")
- [ ] No leftover editor notes ("EXPLAIN WHAT DID", "see objective", Peso/dopamine note)
- [ ] SUS: 61.83, SD 17.58, N=30, Grade D, "OK", partially achieved — still correct
- [ ] All 9 recommendations present
- [ ] After editing: Review → Delete All Comments in Word

---

## PPT AND SCRIPT — apply these changes

Both files are mostly correct. Only change these:

**PPT:**
- Slide 12: change "8 candidate LLM APIs" → "10 candidate models from four providers"
- Slide 17 Conclusion 2: change "Gemini 3.5 Flash-Lite (selected from 8 candidate LLM APIs)" → "Gemini 3.5 Flash-Lite (selected from 10 candidate models)"

**Script:**
- Slide 12 spoken text: change "eight candidate LLM APIs across multiple providers" → "ten candidate models from four providers — Google, Groq, Cerebras, and Mistral"
- Q6 answer: change "eight candidate LLM APIs — including models from Google, Groq, and Cerebras" → "ten candidate models from four providers — Google, Groq, Cerebras, and Mistral"
- Slide 17 / Q10 / Conclusions: change "eight candidate LLM APIs" → "ten candidate models from four providers"
- Everything else in the script is correct — especially all protected SUS values, 9 recommendations, Rec 8=UI/UX, Rec 9=Formal parsing

---

*Final handoff compiled: November 13, 2026*  
*Supersedes all previous guides. Based on complete manuscript text + screenshots + both Claude guide passes + Kiro audit.*
