# SmartSpend — Claude Handoff Guide
**Date:** November 13, 2026  
**Purpose:** Complete fix guide for Claude (or any editor) working on the GC-shared manuscript.  
**Source of truth:** The manuscript text pasted by Brix + screenshots provided in chat.  
**Priority order:** Apply top-to-bottom. Items marked 🔴 are defense-critical. Items marked 🟡 are important. Items marked 🔵 are minor cleanup.

---

## WHAT IS CORRECT — DO NOT CHANGE THESE

Before anything else, confirm these are already correct in the manuscript you have. **Do not touch them.**

| Value | Status |
|---|---|
| Abstract: "quantitative descriptive developmental research design" | ✅ Already correct |
| Abstract: SUS 61.83, SD 17.58, Grade D, "OK" | ✅ Already correct |
| Abstract: eight-provider cloud failover chain | ✅ Already correct |
| Abstract: Gemini 3.5 Flash-Lite | ✅ Already correct |
| Abstract: Nine recommendations | ✅ Already correct |
| Scope: 1 clean paragraph, Android only, no interviews | ✅ Already correct |
| Data Gathering: per-objective structure (For the first/second/third objective...) | ✅ Already correct |
| Avigail Candevario, PFMe as validator | ✅ Already correct |
| Purposive sampling for validator | ✅ Already correct |
| Random sampling for respondents | ✅ Already correct |
| Table 3: 16 parents + 14 YP + 1 validator = 30 respondents | ✅ Already correct (see FIX 1 below — keep 16+14) |
| Recommendations 8 (UI/UX) and 9 (Formal parsing) | ✅ Already present |
| All figure descriptions 13–21 | ✅ Already written |
| Panel names: Jeoffrey B. Layco MIS, Shekiro R. Raposas MTS/MIS, Mary-Ann Mzana MTS | ✅ Already correct |
| Adviser: Ellen Flores Mangaoang, DIT | ✅ Already correct |

---

## 🔴 FIX 1 — Respondent counts: Keep 16+14 in Table 3 and narrative (IMPORTANT DECISION)

**Decision:** Keep **16 parents + 14 YP = 30** throughout the manuscript.

**Reasoning:** Maam Ellen's comment said "adjust this based on actual, then adjust also the text" — meaning adjust to match whatever the actual data is. The Figure 5 bar chart in the GC version shows 13/14/3. HOWEVER, the manuscript text, Table 3, and Table 5 note already say 16+14 (with the 3 "both" reclassified as parents). This was the previously confirmed decision — Maam Ellen agreed to reclassify the 3 "both" respondents as parents based on primary financial role. The chart showing 13/14/3 is the **needs-assessment** view (before reclassification). The 16+14 is the **final analyzed** view.

**What to fix instead:**
- Figure 5's description currently says the reclassification yields 10+20 for SUS. Keep that sentence. It's correct.
- Table 5 has headers `Parents (n = 13)` and `Both (n = 3)†` but the note says `(parents n = 16, young professionals n = 14)`. This is a **contradiction**. Fix the Table 5 column headers to match the note:
  - Change `Parents (n = 13)` → `Parents (n = 16, includes reclassified "both")`  
  - Remove the `Both (n = 3)†` column header or merge it
  - Or alternatively: keep 13/14/3 columns but add a note explaining the reclassification happened after data collection
- The simplest fix: **add a footnote to Table 5**: *"† The three respondents who identified as 'both' were reclassified as parents based on primary financial role, yielding n = 16 parents for analysis."*

**Do NOT change:**
- Table 3: keep 16+14+1=30 (or if your version shows 13/14/3+1, that's fine too — just be consistent)
- Population narrative: keep "Sixteen (16) respondents were parents..." 
- The 96.7%, 93.3% figures
- The SUS subgroup: 10 parents + 20 YP (separate from needs-assessment)

---

## 🔴 FIX 2 — Research Design: Remove "both qualitative and quantitative" language

**Location:** Chapter II, Research Design — first paragraph  
**Find:**
> "This study applied a quantitative descriptive developmental design, which integrated both qualitative and quantitative approaches in collecting and analyzing data"

**Replace with:**
> "This study applied a quantitative descriptive developmental research design, which integrated quantitative approaches in collecting and analyzing data"

**Also find and fix later in the same section:**
> "By combining quantitative descriptive developmental and developmental approaches..."

**Replace with:**
> "By adopting a quantitative descriptive developmental approach..."

**Also find and delete this sentence:**
> "This approach enabled the researchers to iteratively improve the system based on the data gathered from both qualitative and quantitative methods."

**Replace with:**
> "This approach enabled the researchers to iteratively improve the system based on the quantitative data gathered throughout the development process."

**Why:** The study has no qualitative component. No interviews were conducted. Saying "qualitative and quantitative" is factually wrong and panelists will challenge it.

---

## 🔴 FIX 3 — LLM table: "ten candidate LLM APIs" (not eight, not twenty)

**Location:** Chapter III, LLM selection paragraph and Chapter IV Conclusions  

Looking at Table 6 in your manuscript, it has **10 rows**:
1. Gemini 3.5 Flash-Lite
2. Gemini 3.5 Flash
3. GPT-OSS 120B (Groq)
4. Qwen 3.6 27B
5. Qwen 3.8 27B
6. GPT-OSS 20B
7. Groq Compound Mini
8. GPT-OSS 120B (Cerebras)
9. Mistral 7B
10. Gemma 2 9B

**Find in Chapter III:**
> "eight candidate LLM APIs" (anywhere it says eight)

**Replace with:**
> "ten candidate LLM APIs"

**Find in Chapter IV Conclusions:**
> "The comparative evaluation of 20 candidate LLM models"  
OR  
> "eight candidate LLM APIs"

**Replace with:**
> "A comparative technical evaluation of ten candidate LLM APIs led to the selection of Gemini 3.5 Flash-Lite as the primary model"

**Note:** The manuscript also says "Google, 2024f" is a citation for Gemini selection. Keep that citation.

---

## 🔴 FIX 4 — Figure 15 description is wrong (describes Local AI, not Peso Chat)

**Location:** Chapter III, under "Figure 15. Expense Logging Through Peso Chat"  
**Current wrong text:**
> "Figure 15 presents the Local AI Mode setup screen of SmartSpend. This screen guides users who wish to configure an optional offline AI model running on their home network..."

**The actual Figure 15 screenshot shows the Peso Chat** (user typed "nag-lunch ako 150 pesos", Peso replied "Noted! Lunch for ₱150").

**Replace the entire description with:**
> "Figure 15 presents expense logging through the Peso chat interface of SmartSpend. The user typed 'nag-lunch ako 150 pesos' in Filipino, and the AI assistant Peso replied conversationally in Taglish while recording the expense automatically. A session summary card at the bottom confirmed one recorded item (Lunch, ₱150, dated November 9), and a snackbar confirmed the automatic deduction from Cash on Hand with an Undo option available. A banner at the top detected GCash or bank text in the clipboard and offered to paste it for automatic logging. This interaction demonstrates the system's support for natural language input and its agentic action capability — parsing and recording the transaction in a single step without manual form filling."

---

## 🔴 FIX 5 — Figure 17 description is wrong (describes SUS distribution, not FHS Breakdown)

**Location:** Chapter III, under "Figure 17. Financial Health Score Breakdown"  
**Current wrong text:**
> "Figure 17 presents the distribution of individual SUS scores across all 30 valid respondents. The chart shows the spread of scores ranging from 35.0 to 92.5..."

**This description belongs to a SUS distribution chart, but the caption says FHS Breakdown.**

**Replace the entire description with:**
> "Figure 17 presents the Financial Health Score breakdown screen of SmartSpend, displaying a detailed view of a demo user's score. The screen shows the overall score tier, a list of strengths and focus areas, and a breakdown of the four scored components: Savings Rate, Overspend Control, Budget Adherence, and Logging Consistency, each scored out of 25 points. Each component also displays a brief actionable tip, helping users understand specifically what to improve rather than presenting only a final score. This screen is accessible from the home dashboard and is designed to make the FHS transparent and interpretable."

---

## 🔴 FIX 6 — Figure 18 description is wrong (describes SUS by group, not Budgets screen)

**Location:** Chapter III, under "Figure 18. Budgets, Safe-to-Spend, and Savings Goals"  
**Current wrong text:**
> "Figure 18 presents the SUS scores broken down by respondent group. Parents aged 35–55 (n = 10) obtained a mean score of 58.25..."

**This SUS content does not belong here. The caption says Budgets screen.**

**Replace the entire description with:**
> "Figure 18 presents the Budgets screen of SmartSpend, showing the user's spending limits and current progress for each expense category. The header displays the total budgeted amount, total spent, and total income for the current period, with a warning indicator if total budgets exceed income. Each category card — such as Food, Transportation, Bills, and Entertainment — shows the amount spent against the set limit, the remaining balance, and a pace indicator showing whether spending is on track relative to the number of days elapsed in the month. Users can add, edit, or remove budget categories directly from this screen."

---

## 🔴 FIX 7 — The SUS content that was under Figure 17 and 18 needs to move

The SUS distribution text (scores ranging from 35.0 to 92.5) and the SUS by group text (parents 58.25, YP 63.62) are real content — they just ended up under the wrong figure captions.

**Move them** to the correct location: they belong **after Figure 21** (which is captioned "SUS Scores by Respondent Group") and **in the narrative paragraph** that discusses the SUS results (after Table 7 and Table 8).

The paragraph that starts "As shown in Tables 3.3 and 3.4..." should be the place. **Fix the table reference** in that paragraph:
- Find: "As shown in Tables 3.3 and 3.4"
- Replace with: "As shown in Tables 7 and 8"

---

## 🔴 FIX 8 — Figure 14 Home Dashboard: "Expert Tracker" label

**Location:** Chapter III, under "Figure 14. Home Dashboard"  
**Current text says:**
> "A management score of 97 out of 100 with a 'Consistent Saver' achievement badge is displayed"

**Looking at the actual screenshot:** The label next to 97/100 says "Expert Tracker" (not Consistent Saver). "Consistent Saver" is a separate achievement card below.

**Find:**
> "A management score of 97 out of 100 with a 'Consistent Saver' achievement badge is displayed"

**Replace with:**
> "A management score of 97 out of 100 with an 'Expert Tracker' label is displayed, followed by a 'Consistent Saver' achievement card"

---

## 🟡 FIX 9 — Done/Review Phase: Remove the future-features changelog

**Location:** Chapter II, Software Methodology — Done/Review Phase paragraph  
**Find and DELETE everything from:**
> "Based on the iterative development process, several features had been identified for future implementation beyond the scope of this study. A multi-wallet system enabling separate tracking of GCash, Maya, and bank balances..."

**...all the way through to:**
> "...would require expanded system architecture and were proposed for subsequent research."

**Keep everything before it** (the paragraph about analyzing SUS scores and reviewing feedback). **End the Done/Review paragraph with:**
> "Insights gathered from this phase were used to refine the system and provide recommendations for future development."

**Why:** This is a changelog, not methodology. Panelists will ask why you're listing future features in a methodology chapter.

---

## 🟡 FIX 10 — Figure # placeholder needs to be Figure 4

**Location:** Chapter II, Software Methodology — opening sentence  
**Find:**
> "...followed the Agile Kanban Software Development Methodology as seen in Figure #."

**Replace with:**
> "...followed the Agile Kanban Software Development Methodology as seen in Figure 4."

---

## 🟡 FIX 11 — Add "(see Appendix B)" to informed consent sentence

**Location:** Chapter II, Ethical Considerations  
**Find:**
> "Informed consent was obtained from all participants before their involvement in the study."

**Replace with:**
> "Informed consent was obtained from all participants before their involvement in the study (see Appendix B)."

---

## 🟡 FIX 12 — Add "(see Appendix D)" to validator sentence

**Location:** Chapter II, Data Gathering Tools and Procedure  
**Find:**
> "Prior to distribution, the questionnaire underwent content validation by Avigail Candevario, PFMe, a graduate of Bachelor of Science in Commerce major in Management and an active business owner with experience in financial management and business operations."

**Add at the end of that sentence:**
> "..., prior to distribution (see Appendix D)."

---

## 🟡 FIX 13 — Fix "No formal open-ended Survey" capitalization

**Location:** Chapter III, after the SUS results  
**Find:**
> "No formal open-ended Survey data was collected."

**Replace with:**
> "No formal open-ended survey data was collected. No interviews were conducted; the study used a structured quantitative instrument only."

---

## 🟡 FIX 14 — Fix duplicate Conclusion paragraphs

**Location:** Chapter IV, Conclusions  
The conclusions section currently has three separate paragraph blocks that each restate the objectives. Keep only these in this order:

**Keep Paragraph 1 (brief overview):**
> "The needs assessment confirmed that 96.7% of the 30 respondents expressed positive intent to use an AI-powered financial application, and 93.3% already use GCash validating the study's target population and feature priorities. SmartSpend v3.1.0 was successfully developed with all identified features implemented. The SUS evaluation yielded a mean score of 61.83 (adjective: 'OK'), below the ≥80 target but acceptable for a prototype system. Therefore, all three objectives of the study were addressed, with the third objective partially achieved pending UI refinements in future iterations."

**Replace Paragraph 2 (the one about "20 candidate LLM models") with:**
> "SmartSpend v3.1.0 was developed as a working Android application with multi-modal expense input, offline-first local storage, 34 AI actions, and a Financial Health Score formally classified as a Prototype Observed Financial Health Indicator. A comparative technical evaluation of ten candidate LLM APIs led to the selection of Gemini 3.5 Flash-Lite as the primary model, supported by a seven-provider fallback chain. Therefore, the second objective of designing and developing the SmartSpend mobile application, including the selection of a suitable LLM API, was achieved."

**Keep Paragraph 3 (SUS paragraph) as-is** — it already correctly states 61.83, SD 17.58, Median 55.00, Grade D, "OK".

---

## 🔵 FIX 15 — Chapter III heading typo

**Find:**
> "Designed and Developed of the SmartSpend Mobile Application - see objective"

**Replace with:**
> "Design and Development of the SmartSpend Mobile Application"

(Remove "- see objective" placeholder)

---

## 🔵 FIX 16 — Appendix C label mismatch

**The TOC says:** "APPENDIX C: Transcript of Interview" (page 74 in older TOC) or "APPENDIX C: SUS Individual Scores" (newer TOC)  
**The actual Appendix C content** is the SUS Questionnaire.

**Check your TOC and fix it to say:**
> "APPENDIX C: System Usability Scale (SUS) Questionnaire"

The old TOC listed "Transcript of Interview" as Appendix C — that is wrong. No interviews were conducted.

---

## 🔵 FIX 17 — References: Google 2024f is cited but may be missing

**Location:** References section  
**Find "Google. (2024f)"** in the references list. If it's missing, add it:
> Google. (2024f). *Gemini API documentation*. https://ai.google.dev/docs

This is cited in the LLM selection paragraph with "(Li et al., 2024; Google, 2024f)".

---

## 🔵 FIX 18 — Technical Background: Remove library citations (per Maam Ellen and Cyrille)

**Per comments:** "wag literatures, pano ginamit sa app dapat" and "Same sa flutter" and "tanggalin na rin mga citations"

For each technology entry in Technical Background, **remove the parenthetical citations at the end**. Keep only the description of how it was used in SmartSpend.

Specifically delete these citations from Technical Background paragraph endings:
- `(Google, 2024c)` from Firebase Firestore paragraph
- `(Google, 2024a)` from Firebase Authentication paragraph  
- `(Google, 2024b)` from Firebase Crashlytics paragraph
- `(Sloane, 2022)` from Speech-to-Text paragraph
- `(Google, 2024e)` from ML Kit OCR paragraph
- `(Bociek, 2023; ZXing, 2023)` from Mobile Scanner paragraph
- `(Flutter 4 Fun, 2022)` from fl_chart paragraph
- `(The Flutter Authors, 2013)` from local_auth paragraph

**Keep citations in the main body** (Project Context, Research Design, etc.) — only remove them from Technical Background section.

---

## 🔵 FIX 19 — Figure numbering in List of Figures (TOC)

The manuscript uses chapter-prefixed numbering in the List of Figures (1.1, 1.2, 2.1, etc.) but the body uses sequential numbering (Figure 1, Figure 2, etc.). **Pick one and be consistent.**

**Recommendation:** Use sequential numbering everywhere (Figure 1 through Figure 21). Update the List of Figures to match:

| In TOC | Should be |
|---|---|
| Figure 1.1 | Figure 1 |
| Figure 1.2 | Figure 2 |
| Figure 2.1 | Figure 3 |
| Figure 2.2 | Figure 4 |
| Figure 3.1 through 3.14 | Figure 5 through Figure 21 |

If you keep chapter-prefixed in the TOC, then update ALL body captions to match (Figure 3.1, 3.2, etc.). Either way, they must match.

---

## 🔵 FIX 20 — Table of Contents has two TOC pages

The manuscript has TWO table of contents sections — one with the old format (roman numerals for chapters, Appendix C = Transcript of Interview) and one with the corrected format (page numbers). **Delete the first/older one.** Keep only the second one (the one that starts with "Title Page ... i").

---

## WHAT CLAUDE SHOULD NOT CHANGE

These items from Claude's guide are **debatable or already handled**:

| Claude's suggestion | Our decision |
|---|---|
| Change 16+14 to 13+14+3 throughout | ❌ Keep 16+14 in Table 3 and narrative. Add a footnote to Table 5 explaining the 13/14/3 columns are pre-reclassification. |
| Delete the SUS distribution paragraph | ❌ Keep it — just move it to after Figure 21, not under Figure 17 |
| Change "eight candidate" to "ten candidate" | ✅ Correct — the table has 10 rows |
| Delete the SUS by group paragraph | ❌ Keep it — just move it out from under Figure 18, place it after Figure 21 |
| Blur Figure 16 receipt (student number visible) | ✅ Do this — blur the reference number and any personal info on the receipt image |
| Remove citations from Technical Background | ✅ Do this per Maam Ellen and Cyrille's comments |
| Delete uncited references | ✅ Safe to do after fixing Technical Background |
| Fix Figure 11 include relationship description | ✅ Minor correction, safe to do |
| Rename Figure 18 caption | ❌ Keep caption as "Figure 18. Budgets, Safe-to-Spend, and Savings Goals" — just fix the description text |

---

## PRIORITY ORDER FOR CLAUDE

Do these in order. Stop after each group and verify before continuing.

**Group A — Accuracy (must be done before defense):**
1. FIX 2 — Remove "qualitative" from Research Design
2. FIX 3 — Change "twenty/eight candidate" → "ten candidate LLM APIs"
3. FIX 4 — Replace wrong Figure 15 description (Local AI → Peso Chat)
4. FIX 5 — Replace wrong Figure 17 description (SUS distribution → FHS Breakdown)
5. FIX 6 — Replace wrong Figure 18 description (SUS by group → Budgets)
6. FIX 7 — Move the SUS content to correct location (after Figure 21, fix "Tables 3.3 and 3.4" → "Tables 7 and 8")
7. FIX 8 — Fix "Consistent Saver" → "Expert Tracker" in Figure 14 description
8. FIX 14 — Fix duplicate Conclusions (change "20 candidate LLM models" → "ten candidate LLM APIs")

**Group B — Important (do before printing):**
9. FIX 9 — Remove future-features list from Done/Review
10. FIX 10 — Replace "Figure #" with "Figure 4"
11. FIX 11 — Add "(see Appendix B)"
12. FIX 12 — Add "(see Appendix D)"
13. FIX 13 — Fix "No formal open-ended Survey" capitalization
14. FIX 1 — Add footnote to Table 5 about reclassification

**Group C — Cleanup (do if time permits):**
15. FIX 15 — Chapter III heading
16. FIX 16 — Appendix C label
17. FIX 17 — Add Google 2024f to References
18. FIX 18 — Remove citations from Technical Background
19. FIX 19 — Standardize figure numbering
20. FIX 20 — Remove duplicate TOC

---

## AFTER ALL FIXES — VERIFY THESE

Before calling it done, check that the final manuscript has:

- [ ] "quantitative descriptive developmental research design" in Research Design (not "mixed-methods")
- [ ] "ten candidate LLM APIs" in Chapter III LLM selection and Chapter IV Conclusions
- [ ] Figure 15 description = Peso Chat (not Local AI)
- [ ] Figure 17 description = FHS Breakdown screen (not SUS distribution)
- [ ] Figure 18 description = Budgets screen (not SUS by group)  
- [ ] "Tables 7 and 8" (not "Tables 3.3 and 3.4") in SUS results paragraph
- [ ] No "Figure #" placeholder anywhere
- [ ] Done/Review paragraph has no multi-wallet/bank list
- [ ] Conclusions say "ten candidate LLM APIs" not "20 candidate LLM models"
- [ ] SUS: 61.83, SD 17.58, N=30, Grade D, "OK", partially achieved — unchanged
- [ ] All 9 recommendations present (Recs 8 and 9 for UI/UX and formal parsing)
- [ ] No duplicate TOC
- [ ] After editing: resolve all Word comments via Review → Delete All Comments

---

*Handoff written: November 13, 2026*  
*Based on: actual manuscript text, all screenshots provided, Claude's audit findings, and confirmed study decisions*
