# SmartSpend Manuscript Reconciliation Plan
**Source:** `1_MANUSCRIPT_FIX_GUIDE.md` vs `1_MAIN_MANUSCRIPT_FINAL.docx`  
**Generated for:** Nov 16, 2026 final defense  
**Purpose:** Classify every fix-guide item so a coder can apply, skip, or flag each one without re-reading all source documents.

---

## PROTECTED VALUES (never override these)
| Value | Number |
|---|---|
| SUS mean | 61.83 |
| SUS SD | 17.58 |
| SUS N | 30 |
| SUS median | 55.0 |
| SUS range | 35.0–92.5 |
| SUS Grade | D |
| SUS adjective | OK |
| AI intent | 96.7% (29/30) |
| GCash users | 93.3% (28/30) |
| SUS demographics | 10 parents + 20 YP |
| Needs-assessment demographics | 13 parents + 14 YP + 3 both = 30 |
| App version evaluated | v3.1.0 |
| AI actions | 34 |
| Badges | 36 |
| Screens | 45 |
| Panel names | Jeoffrey B. Layco MIS · Shekiro R. Raposas MTS/MIS · Mary-Ann Mzana MTS |
| Adviser | Ellen Flores Mangaoang DIT |
| Validator | Avigail Candevario PFMe |

---

## SECTION A — Fix These First

---

### A1. Figure 3.12 does not match SUS statistics
**Classification:** NEEDS_CONFIRM  
**Rationale:** The chart bars must be verified against the raw Google Form export before any statistics are changed; the manuscript text values (mean 61.83, SD 17.58, median 55.0, range 35.0–92.5) are PROTECTED and cannot be altered without raw-data confirmation.  
**What to check:** Export 30 valid SUS rows from Google Forms. Run `regen_sus_charts.py` with `id,group,score` CSV. If computed stats match the protected values exactly, regenerate Fig 3.12 and Fig 3.13 images only. If computed stats differ, escalate — do NOT change any number in the manuscript without explicit team confirmation.

---

### A2. Appendix "SUS Individual Scores" is missing; Fig 3.11 caption is misleading
**Classification:** APPLY_NOW (caption fix) + NEEDS_CONFIRM (table build)  
**Rationale:** The caption fix is a safe text change; the 30-row appendix table requires the raw Form export to build.

**APPLY_NOW — caption:**  
- FIND: `SUS Computation Table`  
- REPLACE: `Sample SUS Computation for One Respondent (individual scores for all 30 respondents are in Appendix F)`

**NEEDS_CONFIRM — Appendix F table:**  
What to check: build the 30-row table (Respondent | Group | Q1–Q10 raw | Sum | Score) from the Google Form export. Add it as Appendix F. Update TOC/List of Figures entry for Fig 3.11 to match the new caption. Update Appendix list to include F.

---

### A3. Leftover internal instruction inside Peso paragraph (Ch III, Obj 2)
**Classification:** APPLY_NOW  
**Rationale:** The sentence `Present Peso as a design feature, not as evidence of behaviour change, and avoid phrases such as "dopamine reinforcement".` is visibly present in the extracted manuscript text as an instruction to the team, not academic prose. It must be deleted before submission.

**APPLY_NOW:**  
- FIND: `Present Peso as a design feature, not as evidence of behaviour change, and avoid phrases such as "dopamine reinforcement".`  
- REPLACE: *(delete — leave nothing)*

**APPLY_NOW — British to American spelling in same paragraph:**  
- FIND: `These behaviours applied the same ideas`  
- REPLACE: `These behaviors applied the same ideas`

- FIND: `so their effect on user behaviour has not been measured`  
- REPLACE: `so their effect on user behavior has not been measured`

---

### A4. Two different names for the survey validator
**Classification:** ALREADY_DONE (pre-determined)  
**Rationale:** Pre-determined: Avigail Candevario PFMe was confirmed. The manuscript body already contains both names in different paragraphs — the Population section still reads "Susan C. Arquisal" while the Step 1 procedure and Table 2.1 area read "Avigail Candevario, PFMe". The Susan C. Arquisal sentence needs the find/replace below; it is APPLY_NOW.

**APPLY_NOW — fix the remaining stale reference:**  
- FIND: `The survey questionnaire was reviewed by Susan C. Arquisal, a graduate of Bachelor of Science in Commerce major in Management and an active business owner with experience in financial management and business operations, prior to distribution. This review ensured that the questions were appropriate, relevant, and grounded in the actual financial management experiences of the target population.`  
- REPLACE: `The survey questionnaire was reviewed by Avigail Candevario, PFMe, a subject matter expert in financial management and business operations, prior to distribution. This review ensured that the questions were appropriate, relevant, and grounded in the actual financial management experiences of the target population.`

**APPLY_NOW — add cross-reference sentence after Step 1 validation paragraph:**  
- FIND: `The expert's credentials was recorded in the Content Validation Certificate (Appendix A).`  
- REPLACE: `The expert's credentials were recorded in the Content Validation Certificate (Appendix D). The same content validator also reviewed the Financial Health Score formula (Appendix E).`

**NEEDS_CONFIRM — Technical Validation Certificate:**  
What to check: The manuscript mentions a Technical Validation Certificate and lists 1 technical validator in Table 2.1, but no Appendix G exists. Either add it as Appendix G or delete the reference sentence and adjust Table 2.1 to show 0 technical validators. Confirm with the team.

**NEEDS_CONFIRM — Brix's email:**  
Brix's CV lists `brix.arquisal@lorma.edu`. If the validator surname Arquisal is shared, prepare an independence answer for the panel. If the email is a typo, correct it in the CV.

---

### A5. Figure 3.14 caption / arithmetic conflict
**Classification:** CONFLICT / REJECT (pre-determined)  
**Rationale:** Pre-determined override. The fix guide says to delete Figure 3.14, but the Fig 3.14 caption in the manuscript reads: *"Demographic Distribution of Needs-Assessment Respondents (N = 30). The 3 respondents who identified as both parent and young professional were reclassified by primary financial role for SUS subgroup analysis, yielding 10 parents and 20 young professionals."* This caption correctly describes the needs-assessment sample (13+14+3=30) with the dagger footnote, and the 10+20 refers specifically to the SUS subgroup reclassification — it is NOT an impossible arithmetic claim. Deleting the figure would remove information the manuscript uses. **Do NOT delete Figure 3.14.**

**What to do instead — fix the three stray TOC-style lines in the body:**  
These three lines appear in the extracted text immediately after Fig 3.11 and are clearly auto-field artifacts, not body text:  
```
Figure 3.12.  SUS Score Distribution (N = 30)	70
Figure 3.13.  SUS Scores by Respondent Group (N = 30)	71
Figure 3.14.  Demographic Distribution of Needs-Assessment Respondents (N = 30)	44
```

**APPLY_NOW — delete these three stray lines:**  
- FIND: `Figure 3.12.  SUS Score Distribution (N = 30)	70`  
  REPLACE: *(delete)*  
- FIND: `Figure 3.13.  SUS Scores by Respondent Group (N = 30)	71`  
  REPLACE: *(delete)*  
- FIND: `Figure 3.14.  Demographic Distribution of Needs-Assessment Respondents (N = 30)	44`  
  REPLACE: *(delete)*  

**APPLY_NOW — move the loose `†` footnote:**  
Three identical stray notes appear at the end of the references section:  
```
Note: The 3 respondents who identified as both parent and young professional were classified by their primary financial role for SUS subgroup analysis, resulting in a final breakdown of 10 parents and 20 young professionals for statistical comparison (Table 8).
```
- FIND the first occurrence of: `Note: The 3 respondents who identified as both parent and young professional were classified by their primary financial role for SUS subgroup analysis, resulting in a final breakdown of 10 parents and 20 young professionals for statistical comparison (Table 8).`  
  REPLACE: *(delete — move placement to under Table 3.1 as: `Note. † Respondents who identified as both a parent and a young professional. The three "both" respondents were reclassified by primary financial role for SUS subgroup analysis, yielding 10 parents and 20 young professionals.`)*  
- Delete the two remaining duplicate occurrences of the same note.

**APPLY_NOW — add note under Table 3.4:**  
After Table 3.4, add: `Note. In the SUS form, respondents chose the one role that best described them (Parent or Young Professional); this sample is separate from the needs-assessment sample (N = 30, Table 3.1).`

---

### A6. Peso and badges: which build was evaluated?
**Classification:** NEEDS_CONFIRM  
**Rationale:** The manuscript (Ch III) says Peso was developed from v3.0.5 to v3.1.0 and the evaluated build was v3.1.0, while the defense script Q10 answer says "Peso and badges were added in v3.1.1–v3.1.2 after the evaluation." These cannot both be true. The panel will ask.  
**What to check:** Check the git log / release notes for the exact build the 30 SUS respondents installed. Then apply exactly one of the two variants from the fix guide. Update the manuscript, script, and reviewer consistently.

---

### A7. Conclusion contradicts Table 3.3 and Chapter IV
**Classification:** APPLY_NOW  
**Rationale:** The manuscript Ch IV Conclusions section is incomplete (the extracted text shows "SmartSpend " as a truncated sentence), and the fix guide's replacement text is consistent with the protected SUS values and the limitation language already in Ch III.

**APPLY_NOW — fix the marginal/acceptable contradiction:**  
- FIND: `below target but acceptable for a prototype system`  
- REPLACE: `below the 68 average benchmark and the pre-set target of 80, and rated marginal (not acceptable) under our criteria`

**APPLY_NOW — fix the "successfully developed" overclaim:**  
- FIND: `successfully developed with all identified features implemented`  
- REPLACE: `developed as a working Android prototype with the features reported in Chapter III; on-device AI, a backend proxy, and database encryption remain future work`

**APPLY_NOW — add Objective 1 judgment sentence:**  
In the Ch IV Conclusions paragraph for Objective 1, add after the last sentence of that paragraph:  
- FIND: `These results showed that the first objective of the study was achieved: the financial management practices, budgeting challenges, and expense tracking behaviors of the target population were successfully assessed through the validated survey instrument.` *(this is in Ch III — the Ch IV version is truncated; apply the full replacement text from Section D of the fix guide — see A8 below)*

---

### A8. Abstract and Chapter IV recommendations are inconsistent; Table 3.5 cross-reference is broken
**Classification:** APPLY_NOW  
**Rationale:** The abstract says "seven recommendations" and lists items that do not match Ch IV's seven items (the Ch IV list omits UI/UX refinement and formal parsing evaluation). Table 3.5 note references "Chapter IV, Recommendation 6" for the 50+ receipt evaluation, but Rec 6 in Ch IV is "Household and remittance features." These are findable, automatable text replacements.

**APPLY_NOW — replace abstract recommendations sentence:**  
- FIND: `Seven recommendations were identified for future development, including UI/UX refinement, a backend API proxy, on-device AI, SQLite encryption, formal parsing evaluation, and a longitudinal study.`  
- REPLACE: `Eight recommendations were identified for future development: UI/UX refinement, formal parsing evaluation, a backend API proxy followed by a Google Play release, SQLite encryption, an on-device AI tier, payday-cycle budgeting, household and remittance features, and a longitudinal evaluation.`

**APPLY_NOW — fix Table 3.5 cross-reference:**  
- FIND: `Chapter IV, Recommendation 6`  
  REPLACE: `Chapter IV, Recommendation 2`

**APPLY_NOW — fix SUS paragraph cross-reference:**  
- FIND: `inform the UI/UX recommendations in Chapter IV`  
  REPLACE: `informed Recommendation 1 in Chapter IV`

**APPLY_NOW — replace Chapter IV with the 8-item list (Section D of the fix guide):**  
The extracted Ch IV Conclusions text is truncated. Replace the entire Conclusions and Recommendations section using the paste-ready text from `1_MANUSCRIPT_FIX_GUIDE.md` Section D. That text is reproduced here verbatim for the coder:

> **Conclusions**  
> `Objective 1 was to assess the financial management practices, budgeting challenges, and expense-tracking behaviors of parents aged 35 to 55 and young professionals aged 21 to 35 in San Fernando City. The needs assessment of 30 respondents showed that 90.0% track expenses through receipts, 53.3% through mental estimates, and only 10.0% through a mobile app, while 96.7% intend to use an AI-powered financial app and 93.3% already use GCash. The first objective was achieved.`
>
> `Objective 2 was to design and develop SmartSpend, with an LLM API chosen through comparative technical evaluation. SmartSpend v3.1.0 was developed as a working Android application with 34 autonomous AI actions, Gemini 3.5 Flash-Lite as the primary model with seven fallback providers, an optional private local model, and a Financial Health Score. The second objective was achieved. Security remains prototype-grade, and accuracy figures come from preliminary developer testing.`
>
> `Objective 3 was to evaluate usability and performance using the System Usability Scale and user feedback. The mean SUS score of 61.83 (SD = 17.58, N = 30) corresponds to an adjective rating of "OK" and Grade D, below the 68 average benchmark and the pre-set target of 80, and is marginal under the acceptability criteria. Users reported strong intent to use the app often (4.35 out of 5) and confidence (4.19), while consistency (Q6), complexity (Q2), and need for technical support (Q4) were the main concerns. Because usability was evaluated but the target was not met, and performance was assessed only preliminarily, the third objective was partially achieved.`
>
> **Recommendations** (8 items — each tied to a limitation):  
> 1. UI/UX refinement — address consistency, complexity, technical-support concerns (SUS Q6, Q2, Q4).  
> 2. Formal parsing evaluation — test against 50+ standardized receipts, replacing preliminary 91.2%/88.5%.  
> 3. Backend API proxy, then Google Play release — move API keys server-side.  
> 4. SQLite encryption — SQLCipher.  
> 5. On-device AI tier — ~2.6 GB opt-in model for offline AI.  
> 6. Payday-cycle-aware budgeting — 15th and 30th salary cycle.  
> 7. Household and remittance features — shared wallets, OFW remittance.  
> 8. Longitudinal evaluation — 3–6 months, larger sample.

---

### A9. Objective 1 "challenges" data is almost absent
**Classification:** NEEDS_CONFIRM  
**Rationale:** Ch III Obj 1 mentions "the most prevalent challenges were rising prices of basic goods, unexpected medical expenses, and family responsibilities" but provides no counts or percentages. A panel will ask for numbers.  
**What to check:** From the Google Form export, tabulate Q6 (budgeting challenges), Q4 (budget frequency), Q5 (savings frequency), and Q12 (definitely vs probably). Then add Table 3.1b with counts and percentages, and paste the fill-in-the-bracket paragraph from the fix guide with the actual numbers. This cannot be automated without the raw data.

---

## SECTION B — Visible Inconsistencies

---

### B1. Abstract: provider count says "six-provider"
**Classification:** APPLY_NOW  
**Rationale:** The abstract reads "six-provider AI failover chain" but Ch III and the script consistently say primary + 7 fallbacks (8 total cloud providers). This is a simple find/replace.

- FIND: `six-provider AI failover chain`  
- REPLACE: `an eight-provider cloud failover chain (Gemini 3.5 Flash-Lite as primary, seven fallbacks) plus an optional private local model`

---

### B2. Abstract: grade and benchmark attribution
**Classification:** APPLY_NOW  
**Rationale:** The abstract conflates Bangor's adjective scale with Sauro & Lewis's grade scale. The extracted abstract reads: `corresponding to a grade of D and an adjective rating of "OK" under the Bangor et al. (2009) scale`. Grades come from Sauro & Lewis, not Bangor.

- FIND: `corresponding to a grade of D and an adjective rating of "OK" under the Bangor et al. (2009) scale`  
- REPLACE: `corresponding to an adjective rating of "OK" (Bangor et al., 2009) and a Grade D on the Sauro and Lewis (2016) curved scale, which is below the 68-point average benchmark (Sauro & Lewis, 2016) and the pre-set target of 80`

**APPLY_NOW — fix same error in Ch III body:**  
- FIND: `Per Bangor, Kortum, and Miller (2009), this corresponds to an adjective rating of "OK" (Grade D)`  
- REPLACE: `…an adjective rating of "OK" (Bangor et al., 2009) and Grade D on the Sauro and Lewis (2016) scale`

- FIND: `the 68-point average benchmark established by Bangor et al.`  
- REPLACE: `the 68-point average benchmark established by Sauro and Lewis (2016)`

---

### B3. Target of 80 described as "Good"
**Classification:** APPLY_NOW  
**Rationale:** The manuscript Ch II reads: `A target SUS score of 80 or above, corresponding to the adjective rating of Good, was set as the acceptance threshold`. Per Bangor's anchors, Good ≈ 71 and Excellent ≈ 85, so 80 is between them — calling it "Good" is imprecise.

- FIND: `corresponding to the adjective rating of Good`  
- REPLACE: `which lies between the Good (about 71) and Excellent (about 85) adjective anchors of Bangor et al. (2009); it was set as an aspirational threshold before data collection, and the 68 average benchmark (Sauro & Lewis, 2016) served as a secondary reference`

---

### B4. Figure 2.1: text and picture describe different SUS scales
**Classification:** APPLY_NOW (text replacement) + NEEDS_CONFIRM (image replacement)  
**Rationale:** The Ch II text under Fig 2.1 uses a 5-band scale (Poor <60, Marginal 60–69, Acceptable 70–79, Good 80–89, Excellent 90–100) that disagrees with Bangor's 3-band acceptability model. The image replacement requires the `Fig_2_1_SUS_interpretation_redrawn.png` asset.

**APPLY_NOW — replace description paragraph:**  
- FIND: `The SUS score ranged from 0 to 100 and is categorized into different levels: Poor (below 60), Marginal (60–69), Acceptable (70–79), Good (80–89), and Excellent (90–100). Higher scores indicated better usability, user satisfaction, and system performance, while lower scores suggested the need for improvements. This scale served as a standardized tool to assess how effectively and efficiently users could interact with the system.`  
- REPLACE: `Figure 2.1 shows how SUS scores were interpreted. Scores below 51 were considered not acceptable, 51 to 70 marginal, and 71 and above acceptable (Bangor et al., 2008). The adjective anchors of Bangor et al. (2009) are marked on the scale: OK (about 51), Good (about 71), and Excellent (about 85). The dashed line marks the 68-point average benchmark (Sauro & Lewis, 2016) and the pre-set target is 80.`

**NEEDS_CONFIRM — image swap:**  
Replace the Fig 2.1 picture in the Word document with `manuscript_fix_assets/Fig_2_1_SUS_interpretation_redrawn.png` (from the fix guide assets folder).

---

### B5. SUS item labels — Q4 is mislabeled
**Classification:** APPLY_NOW  
**Rationale:** The manuscript describes Q4 as "complexity" but SUS Item 4 is "I would need the support of a technical person to be able to use this system."

- FIND: `complexity (Q2, Q4)`  
- REPLACE: `complexity (Q2) and need for technical support (Q4)`

---

### B6. SUS exclusions: two different explanations
**Classification:** APPLY_NOW  
**Rationale:** The Ch III exclusion text reads "30 confirmed they used the app for the required minimum duration" (implying 6 excluded for time only) but the actual breakdown is 5 for time + 1 for straight-line responding.

- FIND: `Of 36 respondents who attempted the survey, 30 confirmed they used the app for the required minimum duration and were included in the final analysis. The remaining 6 were excluded: 5 for insufficient app usage time and 1 for straight-line response bias.`  
  *(This paragraph is already partially correct — verify exact wording and ensure it reads:)*  
- FIND: `30 confirmed they used the app for the required minimum duration`  
- REPLACE: `Of 36 respondents who attempted the survey, 31 confirmed using the app for the required minimum duration; 1 of these was excluded for straight-line responding, leaving 30 valid respondents. The other 5 were excluded for insufficient usage time.`

**APPLY_NOW — fix Ch IV references to exclusions:**  
- FIND: `6 excluded for insufficient app usage time`  
- REPLACE: `6 excluded (5 for insufficient usage time, 1 for straight-line responding)`

---

### B7. Criteria for choosing the LLM: "four" vs "six"
**Classification:** ALREADY_DONE (pre-determined)  
**Rationale:** Pre-determined. The extracted manuscript already contains the six-criteria text in Ch III: `Filipino-English accuracy (25%), speed/latency (20%), tool use and JSON reliability (20%), free tier availability (15%), context window (10%), and financial reasoning quality (10%)`. However, the Ch II Objective 2 statement and Step 4 still reference only four criteria. Apply the two targeted fixes below.

**APPLY_NOW — fix Objective 2 statement in Ch I:**  
- FIND: `inference speed, response accuracy for Filipino-English natural language processing, context window capacity, and cost feasibility for academic deployment` *(the first occurrence, inside the Objectives section)*  
- REPLACE: `Filipino-English accuracy, inference speed, tool use and JSON reliability, free-tier availability, context window capacity, and financial reasoning quality`

**APPLY_NOW — fix Step 4 in Ch II procedure:**  
- FIND: `Response latency, accuracy, context window, and cost were recorded and compared.`  
- REPLACE: `Latency, Filipino-English accuracy, tool-use reliability, free-tier availability, context window, and financial reasoning were recorded and compared.`

**APPLY_NOW — add note under Table 3.2:**  
After Table 3.2, add: `Note. Table 3.2 reports the measured values per criterion. A single weighted total per model was not computed, and entries marked "Not measured" were outside the team's own benchmark run.`

---

### B8. Table 3.2 row "Gemini 3.7 Flash": Provider cell contains a status sentence
**Classification:** APPLY_NOW  
**Rationale:** The fix guide identified this as a data-cell content error. The status sentence belongs in the Status column, not the Provider column.

- FIND (in Table 3.2 row for Gemini 3.7 Flash, Provider cell): `Not used: same ~20/day quota as 3.5 Flash with no added benefit in trials`  
  → Move this text to the Status cell; put `Google` in the Provider cell.  
  *(This requires a table cell edit in Word — select the Provider cell for Gemini 3.7 Flash, type `Google`, then paste the status sentence into the Status cell.)*

---

### B9. Fig 3.7 caption vs content; real names visible in screenshot
**Classification:** NEEDS_CONFIRM  
**Rationale:** Whether the receipt screenshot in Fig 3.7 exposes real names requires visual inspection of the actual image in the Word document. The caption fix is text-only.

**APPLY_NOW — caption fix:**  
- FIND: `Receipt Scanning and Batch Screenshot Import` *(the Fig 3.7 caption)*  
- REPLACE: `Receipt Scanning (a) and Batch Screenshot Import (b)` *(only if two side-by-side images replace the original; otherwise leave caption and replace image manually)*

**NEEDS_CONFIRM — image privacy:**  
Open the Word document, inspect Fig 3.7. If real names appear in the receipt OCR preview, replace the image with `manuscript_fix_assets/Fig_3_7a_Receipt_review_names_pixelated.jpg` and `manuscript_fix_assets/Fig_3_7b_Batch_screenshot_import.jpg`.

---

### B10. Fig 3.9 caption mismatches content
**Classification:** NEEDS_CONFIRM  
**Rationale:** The fix guide says the Fig 3.9 screenshot shows only the Budgets screen, not safe-to-spend and goals. This requires visual inspection of the actual image.

**NEEDS_CONFIRM — image content check:**  
Open the Word document, inspect Fig 3.9. If it shows only the budgets screen:  
- FIND: `Budgets, Safe-to-Spend, and Savings Goals` *(the Fig 3.9 caption)*  
- REPLACE: `Budgets Screen with Over-Income Warning`  
  Or swap in a screenshot that actually shows safe-to-spend and goals.

---

### B11. Figs 3.5 and 3.8 show different scores; "Management Score" unexplained
**Classification:** APPLY_NOW (explanatory sentence) + NEEDS_CONFIRM (Management Score definition)  
**Rationale:** Both screenshots come from Demo Mode at different data states, so both scores can be correct. The explanatory sentence can be added now. The "Management Score 97/100 (Expert Tracker)" term in Fig 3.5 is not defined anywhere in the manuscript.

**APPLY_NOW — add note under Fig 3.8:**  
After the Fig 3.8 caption line in the manuscript body, add: `Figures 3.5 and 3.8 were captured from Demo Mode at different data states, so the displayed scores differ.`

**NEEDS_CONFIRM — Management Score:**  
Check the codebase: what is "Management Score 97/100 (Expert Tracker)" in Fig 3.5? If it is a separate metric from the FHS, add one sentence defining it. If it is an artifact of the demo data tier label, crop it from Fig 3.5 or explain it in a note.

---

### B12. Fig 3.1 flowchart decision diamond logic
**Classification:** NEEDS_CONFIRM  
**Rationale:** Whether the diagram currently reads "Local-only mode on?" or something else requires visual inspection of the actual figure in the document.

**NEEDS_CONFIRM — image check:**  
Open the Word document, inspect Fig 3.1. If the decision diamond reads `Local-only mode on?`:  
- Change it to: `Local AI server reachable, or Local-only on?`  
  This requires redrawing or replacing the flowchart image, not a text find/replace.

---

### B13. Figures 1.2 and 2.2 have a caption baked into the picture
**Classification:** NEEDS_CONFIRM  
**Rationale:** Whether the images have embedded captions requires visual inspection. The replacement images are in `manuscript_fix_assets/`.

**NEEDS_CONFIRM — image check:**  
Inspect Fig 1.2 and Fig 2.2 in the Word document. If they show "Figure 1." or "Figure X." text baked into the image:  
- Replace Fig 1.2 with `manuscript_fix_assets/Fig_1_2_IPO_no_baked_caption.png`  
- Replace Fig 2.2 with `manuscript_fix_assets/Fig_2_2_Kanban_no_baked_caption.png`

---

### B14. Fig 1.1 contradicts Ch I claims about parents
**Classification:** APPLY_NOW  
**Rationale:** The manuscript says parents 35–55 "exhibited the lowest rates of formal account ownership and structured budgeting among all adult demographics" but Fig 1.1 (BSP data) shows adults 25–64 budgeting at higher rates than all adults combined. The fix is to replace the impossible claim with the accurate reading of Fig 1.1.

**APPLY_NOW — replace the false lowest-rates sentence (all occurrences):**  
- FIND: `exhibited the lowest rates of formal account ownership and structured budgeting among all adult demographics`  
- REPLACE: `carry the main household financial responsibility, yet, as Figure 1.1 shows, fewer than half of Filipino adults kept a household budget (46%) and only 2% answered all six financial literacy questions correctly`  
  *(Replace all occurrences — the fix guide notes this phrase appears in several places)*

---

### B15. Ch I competitor paragraph: wrong table reference
**Classification:** ALREADY_DONE (pre-determined)  
**Rationale:** Pre-determined. The extracted manuscript reads `Table 2.1 summarized the key feature differences` in the competitor paragraph — but that is now `Table 1.2`. However, in the extracted text the same paragraph also contains `Table 1.2` correctly used just below it. Confirm the stale reference is still present and apply if so.

**APPLY_NOW — verify and fix if present:**  
- FIND: `Table 2.1 summarized the key feature differences`  
- REPLACE: `Table 1.2 summarized the key feature differences`

**APPLY_NOW — PocketGuard sentence:**  
- FIND: `PocketGuard simplified available spending into a single daily figure but lacked spending behavior analysis, health scoring, or multi-modal input. These comparisons demonstrated`  
- REPLACE: `These comparisons demonstrated`  
  *(Delete the PocketGuard sentence if PocketGuard does not appear in Table 1.2; or add a PocketGuard column to Table 1.2)*

---

### B16. Garbled sentences in Ch II
**Classification:** APPLY_NOW  
**Rationale:** The extracted text contains two clearly broken sentences in Ch II Research Design.

**APPLY_NOW:**  
- FIND: `only surveys, not surveys, were used`  
- REPLACE: `only structured survey questionnaires were used`

- FIND: `No surveys were conducted; qualitative insights`  
- REPLACE: `No interviews or focus groups were conducted; qualitative insights`

**APPLY_NOW — Ch III open-ended data sentence:**  
- FIND: `No formal open-ended Survey data was collected. The study used a structured quantitative survey instrument. Qualitative insights were derived from the survey response patterns described above.`  
- REPLACE: `Optional comments were invited in the SUS form (Appendix C) but were not analyzed thematically. The study used a structured quantitative survey instrument; qualitative insights were derived from survey response patterns.`

---

### B17. Ch II implementation sentence overstates what was built
**Classification:** APPLY_NOW  
**Rationale:** The extracted text reads: `Additional enhancements included the implementation of a backend proxy server for secure LLM API key handling, PDF export functionality for financial summaries, and SQLite database encryption.` This is false — the proxy and encryption are listed as future recommendations, not built features.

- FIND: `Additional enhancements included the implementation of a backend proxy server for secure LLM API key handling, PDF export functionality for financial summaries, and SQLite database encryption.`  
- REPLACE: `A backend proxy server for API key handling and SQLite database encryption were identified as enhancements but were not implemented in this study (Chapter IV, Recommendations 3 and 4).`

**NEEDS_CONFIRM — PDF export:**  
Check if PDF export is actually implemented in v3.1.0. If yes, keep it in the REPLACE text: `A backend proxy server for API key handling and SQLite database encryption were identified as enhancements but were not implemented in this study (Chapter IV, Recommendations 3 and 4). PDF export of financial summaries was implemented.` If not implemented, omit it entirely.

---

### B18. Truncated sentence at the start of "System Development Results"
**Classification:** APPLY_NOW  
**Rationale:** The extracted text contains: `SmartSpend v3.1.0 was developed across seven Kanban phases (Table 2.2: Agile Kanban Workflow Phases and Deliverables` — this is a truncated parenthetical with no closing text.

- FIND: `(Table 2.2: Agile Kanban Workflow Phases and Deliverables`  
- REPLACE: `(see Table 2.2). The system architecture, use-case view, and navigation structure are shown in Figures 3.1 to 3.3.`

---

### B19. Stale and unsupported app facts
**Classification:** APPLY_NOW (sqflite version + FHS open-item deletion) + NEEDS_CONFIRM (all code-dependent numbers)

**APPLY_NOW — sqflite version:**  
- FIND: `sqflite package (version 11)` *(appears twice in the manuscript)*  
- REPLACE: `sqflite package (database schema version 14)`  
  *(The extracted text confirms v14 chat_sessions schema is mentioned in System Development; schema v14 is the current version.)*

**APPLY_NOW — delete FHS open-item note:**  
- FIND: `The behavior of this component when zero category budgets were configured was a known open item pending confirmation against the current build and was not asserted here.`  
- REPLACE: *(delete — confirm the actual behavior with Kiro/code before the defense and use it only in Q&A)*

**NEEDS_CONFIRM — add app-spec paragraph to Ch III Obj 2:**  
The deck states 45 screens, 7 input modalities, 9 AI providers, 57 currencies, ~47.5 MB. The manuscript has none of these in one place. After confirming all numbers against the code, add to Ch III Obj 2: `SmartSpend v3.1.0 comprises 34 autonomous AI actions, 7 input modalities, 40+ supported screenshot platforms, a 26-table SQLite database, 45 screens, 36 achievement badges, 9 AI providers (8 cloud and 1 local), and 57 currencies, in an Android package of about 47.5 MB.`

---

### B20. Appendix and list numbering
**Classification:** APPLY_NOW (reference fixes) + NEEDS_CONFIRM (new appendix inserts)

**APPLY_NOW — fix Step 1 Appendix reference:**  
- FIND: `Content Validation Certificate (Appendix A)` *(in Ch II Step 1)*  
- REPLACE: `Content Validation Certificate (Appendix D)`

**NEEDS_CONFIRM — Appendix reordering and TOC:**  
The current appendix order is A (Survey), B (SUS), C (SUS Individual Scores placeholder), D (Content Validation Survey), E (Content Validation FHS). After adding Appendix F (SUS Individual Scores) and Appendix G (Technical Validation Certificate, if it exists), re-label: A Survey Questionnaire · B Informed Consent Form · C SUS Questionnaire · D Content Validation Certificate (Survey) · E Content Validation Certificate (FHS) · F SUS Individual Scores · G Technical Validation Certificate. Update every in-text reference to Appendix letters accordingly.

After all edits, right-click each TOC / List of Tables / List of Figures → Update Field → Update entire table.

---

### B21. Obj 3 "performance" is not formally evaluated
**Classification:** APPLY_NOW  
**Rationale:** The Ch III Table 3.5 discussion already says performance is preliminary, but there is no explicit statement linking this to the recommendations.

**APPLY_NOW — add sentence to Table 3.5 discussion:**  
After the Table 3.5 note block, add: `Performance was assessed only through preliminary developer testing; no formal performance evaluation was conducted, which is why Recommendation 2 proposes one.`

**NEEDS_CONFIRM — Table 3.5 test size:**  
- FIND: `91.2% precision, 88.5% recall` in Table 3.5  
- Add `(n = [number of test items])` after each figure once you confirm the internal test set size.

---

## SECTION C — Polish

| Item | Classification | Action |
|---|---|---|
| **Title page adviser label** | APPLY_NOW | Add `Adviser:` before Ellen Flores Mangaoang's name in the title-page author block. Use `Ellen F. Mangaoang, DIT` consistently. |
| **Raposas's title** | NEEDS_CONFIRM | Manuscript uses "Mr. Shekiro R. Raposas"; ORDINEX deck uses "Engr." Confirm his preferred title and use it everywhere (manuscript, deck, script). |
| **Role names for Raposas** | APPLY_NOW | Pick one role label. The approval sheet says "Capstone Teacher-in-Charge". FIND: `instructor in charge` → REPLACE: `Capstone Teacher-in-Charge`. FIND: `Instructor` (where referring to Raposas) → REPLACE: `Capstone Teacher-in-Charge`. |
| **Ariely (2008) URL** | APPLY_NOW | FIND: `https://www.anthropic.com/claude` (in the Ariely reference) → REPLACE: *(delete — Ariely 2008 is a book, not a web page)*. |
| **Bitrián et al. DOI** | NEEDS_CONFIRM | The visible DOI text is `IJBM-02-2021-0074` but the link target is `IJBM-09-2020-0491`. Check both at doi.org and use the correct one. |
| **Gubbins/UNSGSA citation** | APPLY_NOW | FIND: `UNSGSA. (2021). Measuring financial health: Concepts and considerations.` → REPLACE: `Gubbins, P., Mazzotta, B., & Rhyne, E. (2021). Measuring financial health: Concepts and considerations. UNSGSA.` |
| **Google 2024d/2024f duplication** | NEEDS_CONFIRM | `2024f` is used for both Flutter docs and Gemini function calling. Give the function-calling source its own letter (e.g. `2024g`). Confirm that `2024d` is not skipped — letters should run a, b, c, d, e, f, g. |
| **National Privacy Commission citation** | APPLY_NOW | FIND: `Republic Act No. 10173` *(in the Scope paragraph)* → REPLACE: `Republic Act No. 10173 (National Privacy Commission, 2012)` |
| **Stray reference entries** | APPLY_NOW | Move the three stray references at the end of the document (Bangor 2008, Deci & Ryan, Sauro & Lewis) into their correct alphabetical positions within the References section. |
| **Djaunathan CV research section** | APPLY_NOW | Add `Capstone 1: SmartSpend: AI-Assisted Financial Tracker (Capstone Project)` to Djaunathan's research section (currently blank at the college level — the 2021–2023 high-school entries are present but the capstone entry is missing). |
| **Brix CV contact number** | NEEDS_CONFIRM | Brix's CV lists no contact number. Add one if the team wants it in the printed submission. |
| **Age range consistency** | APPLY_NOW | FIND: `20–35` *(in Ch I where it refers to young professionals)* → REPLACE: `21–35` *(to match every other occurrence)*. |
| **Table 3.1 `†` footnote** | ALREADY_DONE (via A5) | Fixed by the note relocation in A5. |
| **Figure numbering after A5** | ALREADY_DONE | Since Figure 3.14 is NOT deleted (A5 conflict/reject), figures 3.1–3.14 remain continuous. No renumbering needed. |
| **Login screen "Smart Spend" vs "SmartSpend"** | NEEDS_CONFIRM | Expect the panel to ask. Prepare a one-sentence answer: "The login screen uses the spaced form as a stylistic choice; the official name throughout documentation is SmartSpend." No manuscript edit required unless the team prefers consistency. |

---

## Digest

### Files this plan touches
| File | Blocks changed | Test / verification |
|---|---|---|
| `1_MAIN_MANUSCRIPT_FINAL.docx` | Abstract (provider count, recommendations, grade attribution), Ch I (age range, competitor table ref, lowest-rates claim), Ch II (garbled sentences, proxy sentence, SUS target description, Fig 2.1 caption, Step 4 criteria, Appendix A→D ref), Ch III (exclusion sentence, Peso paragraph instruction + spelling, Fig 3.11 caption, stray figure lines, B17 open-item deletion, sqflite version ×2, exclusion note B6/Ch IV, Fig 3.7 caption, B18 truncation, B21 performance sentence, Table 3.5 ref, B5 Q4 label, B2 grade attribution, B3 target description), Ch IV (full Conclusions + Recommendations replacement via A8), References (Ariely URL, Gubbins/UNSGSA, NPC citation, stray entries alphabetized), Appendices (Step 1 Appendix letter fix), CVs (Djaunathan research, age range) | Open in Word; use Ctrl+H for each FIND/REPLACE; manually inspect figures noted as NEEDS_CONFIRM; rebuild TOC/List fields after all edits; print one copy and visually verify every page number |
| `4_DEFENSE_SCRIPT_FINAL.md` | Slide 10 exclusion sentence (5+1); Slide 14 Q4 label; Slide 17 recommendations count (seven → eight); Q10 answer (align with A6 resolution) | Read-through against the updated manuscript |
| `2_DEFENSE_SCRIPT_v3.md` | Same targeted fixes as FINAL script above | Read-through |
| `3_DEFENSE_REVIEWER.md` | Numbers table: exclusion breakdown; Q38 Q4 label; Q46 recommendations list | Read-through |

### APPLY_NOW items (automatable with find/replace — ordered by dependency)
1. A3 — delete internal instruction + British spellings *(do first; the sentence itself is a hazard)*
2. A4 — replace Susan C. Arquisal sentence; fix "Appendix A" → "Appendix D" in Step 1
3. B1 — abstract provider count
4. B2 — abstract + Ch III grade attribution
5. B3 — SUS target description
6. B4 — Fig 2.1 description paragraph
7. B5 — Q4 label
8. B6 — exclusion sentence
9. B7 — Step 4 criteria + Table 3.2 note
10. B14 — lowest-rates claim
11. B15 — Table 2.1 → Table 1.2 competitor reference
12. B16 — garbled Ch II sentences + Ch III open-ended sentence
13. B17 — proxy sentence
14. B18 — truncated sentence
15. B19 — sqflite version ×2 + FHS open-item deletion
16. B20 — Step 1 Appendix letter
17. B21 — performance sentence
18. A5 — delete three stray figure lines; relocate footnote notes; add Table 3.4 note
19. A7 — marginal/acceptable contradiction + overclaim
20. A8 — abstract recommendations sentence + Table 3.5 ref + SUS paragraph ref + Ch IV full replacement
21. C Polish items (adviser label, role names, Ariely URL, Gubbins/UNSGSA, NPC citation, stray refs, age range, Djaunathan CV)

### NEEDS_CONFIRM items (block until raw data or code check)
- A1 — raw SUS export → regenerate Fig 3.12/3.13 images only (numbers are protected)
- A2 — Appendix F 30-row table from Form export
- A4 — Technical Validation Certificate decision
- A4 — Brix email/surname conflict preparation
- A6 — which build did SUS respondents use? Align A6 variant throughout
- A9 — Q6/Q4/Q5/Q12 counts for Table 3.1b
- B4 — replace Fig 2.1 image with redrawn asset
- B9 — inspect Fig 3.7 for real names; swap images if needed
- B10 — inspect Fig 3.9 content; fix caption or swap image
- B11 — confirm "Management Score" definition from code
- B12 — inspect Fig 3.1 flowchart diamond label; redraw if needed
- B13 — inspect Fig 1.2/2.2 for baked-in captions; swap images if needed
- B17 — confirm whether PDF export is implemented
- B19 — confirm all app-spec numbers from code for the Ch III paragraph
- B20 — appendix reordering after Appendix F/G are built
- B21 — test set n for Table 3.5
- C — Raposas title (Mr. vs Engr.)
- C — Bitrián DOI verification
- C — Google 2024d/f letter reconciliation
- C — Brix CV contact number

### CONFLICT / REJECT items (do not apply)
- **A5 (delete Figure 3.14):** REJECTED. The fix guide's deletion instruction is wrong. Figure 3.14 correctly shows the needs-assessment demographics (N=30, 13+14+3) with a dagger note explaining the 10+20 SUS reclassification. The 10+20 is the SUS subgroup count, not an impossible reclassification of the 13+14+3. Keep the figure.

---

*Plan file location: `c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\analysis\RECONCILE_PLAN.md`*
