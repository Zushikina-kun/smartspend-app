# SmartSpend manuscript fix guide (for the Nov 16 defense)

How to use: open the manuscript in Word, press **Ctrl+H**, paste the **FIND** text (first 6–10 words are enough to jump to it; Word may use curly quotes, so retype quotes if a search misses), then paste the **REPLACE** text. Items tagged **[CONFIRM]** need a fact only you can check (code, git log, Google Form export). Do them in the order below: A is dangerous in a defense, B is visible inconsistency, C is polish.

Files in `manuscript_fix_assets/`: cropped Fig 1.2 and 2.2, redrawn Fig 2.1, pixelated receipt (Fig 3.7a), batch import screenshot (Fig 3.7b), and `regen_sus_charts.py`.

---

## A. Fix these first (a panel can catch them in minutes)

### A1. Figure 3.12 does not match your SUS statistics
I measured the bar heights in the image. The chart implies min about 38, max about 90.5, median about 58–59, SD about 13.8. Your text and Table 3.4 say min 35.0, max 92.5, median 55.0, SD 17.58. (Mean agrees: about 61.3 vs 61.83.) Also, real SUS scores are multiples of 2.5, and several bars fall off that grid.
1. Export the raw SUS responses from the Google Form (30 valid rows).
2. Compute each score with the SUS formula; save `scores.csv` as `id,group,score` (group = `Parent` or `YoungProf`).
3. Run `python3 regen_sus_charts.py`. It prints mean, SD, median, min, max, group stats, and band counts, and saves a new Fig 3.12.
4. If the printed numbers differ from Table 3.3/3.4, **the raw data wins**: update Table 3.3, Table 3.4, Fig 3.13, the abstract, Ch III text, Ch IV, the deck (slide 29) and the script. Do not defend any number you cannot reproduce from the raw file.

### A2. Appendix "SUS Individual Scores" is missing, and Fig 3.11 is only a sample
The TOC promises "Appendix C: SUS Individual Scores", but the body has no per-respondent table. Fig 3.11 is one sample respondent (75.0).
- Add a new appendix (call it **Appendix F**) with a 30-row table: Respondent | Group | Q1–Q10 raw answers | Sum of contributions | Score (= sum × 2.5). Build it in Excel from the Form export, paste into Word.
- Change the Fig 3.11 caption.
  - FIND: `SUS Computation Table`
  - REPLACE: `Sample SUS Computation for One Respondent (individual scores for all 30 respondents are in Appendix F)`
- Update the TOC / List of Figures line the same way.

### A3. A leftover instruction to yourselves is inside the Peso paragraph (Ch III, Obj 2)
- FIND: `Present Peso as a design feature, not as evidence of behaviour change, and avoid phrases such as "dopamine reinforcement".`
- REPLACE: *(delete the sentence completely)*
- In the same paragraph change British spelling to American: `behaviour` → `behavior`, `behaviours` → `behaviors`.

### A4. Two different names for the survey validator
Ch II (Population) says the survey was reviewed by **Susan C. Arquisal**. The certificates in Appendix D and E are signed by **Avigail Candevario, PFMe**. [CONFIRM who actually validated.]
- If it was Avigail Candevario: FIND `Susan C. Arquisal` → REPLACE `Avigail Candevario, PFMe` and fix her credentials sentence to match her certificate.
- Appendix E (FHS formula) is signed by the same person. Say so: `The same content validator also reviewed the Financial Health Score formula (Appendix E).`
- Ch II mentions a **Technical Validation Certificate** that is not in the appendices, and Table 2.1 lists 1 technical validator. Either add it as **Appendix G**, or delete the sentence and change Table 2.1 to match.
- Brix's CV lists `brix.arquisal@lorma.edu`. Check it. If the validator shares that surname, expect an independence question and be ready to answer it. If it is a typo, correct it.

### A5. Fig 3.14 and the "10 parents / 20 young professionals" caption are arithmetically impossible
The needs assessment has 13 parents, 14 young professionals, 3 "both". Reclassifying the 3 "both" cannot give 10 and 20. Those 10 / 20 are the separate SUS sample (Table 2.1).
- **Delete Figure 3.14** (it duplicates Table 3.1, and it is numbered 3.14 but appears before Figure 3.1). Also delete its List of Figures line.
- Delete the three stray lines in the body after Fig 3.11: `Figure 3.12 … 70`, `Figure 3.13 … 71`, `Figure 3.14 … 44`.
- Move the loose `†` footnote (found after the references) to just under **Table 3.1** as: `Note. † Respondents who identified as both a parent and a young professional.`
- Delete the three stray notes at the end of the references that say `(Table 8)`, and add under **Table 3.4**: `Note. In the SUS form, respondents chose the one role that best described them (Parent or Young Professional); this sample is separate from the needs-assessment sample.`

### A6. Peso and badges: your documents disagree about which build was evaluated [CONFIRM from git log / release dates]
- Manuscript: Peso was built from v3.0.5 to v3.1.0 and the evaluated build was v3.1.0.
- Deck slide 9 (old and new): v3.1.0 has 36 badges.
- Old script Q10: Peso and badges were added in v3.1.1–v3.1.2, after the evaluation.
Both cannot be true. Check which build the 30 SUS respondents installed, then use ONE version everywhere.
- **Variant 1 (Peso/badges were in the evaluated build):** limitation text → `Peso and the achievement badges were part of the evaluated build, but the study did not isolate their effect on usability or behavior.` Script Q10 → "The evaluated build already included Peso and the badges, but we did not isolate their effect."
- **Variant 2 (added after):** keep the manuscript sentence, then fix the deck (slide 9: say "v3.1.0 evaluated; Peso/badges added later") and Fig 3.4–3.6 (they show Peso, so say they come from the current build).

### A7. Conclusion contradicts Table 3.3 and the limitations (Ch IV)
- FIND: `below target but acceptable for a prototype system` → REPLACE `below the 68 average benchmark and the pre-set target of 80, and rated marginal (not acceptable) under our criteria`
- FIND: `successfully developed with all identified features implemented` → REPLACE `developed as a working Android prototype with the features reported in Chapter III; on-device AI, a backend proxy, and database encryption remain future work`
- Also add an explicit judgment sentence to the Objective 1 conclusion (the others have one): `The first objective was achieved.`

### A8. Abstract and Chapter IV list different recommendations; Table 3.5 and the SUS text point to recommendations that do not exist
- Abstract says seven recommendations including "UI/UX refinement" and "formal parsing evaluation". Ch IV has neither. Ch IV has payday cycle, Google Play and household/remittance, which the abstract omits.
- Table 3.5 note says `see Chapter IV, Recommendation 6` for the 50+ receipt evaluation, but Rec 6 is household/remittance.
- The SUS paragraph says concerns `inform the UI/UX recommendations in Chapter IV`.

Fix by replacing Chapter IV Recommendations with the **8-item list in section D** (each tied to a limitation), then:
- Abstract FIND: `Seven recommendations were identified for future development, including UI/UX refinement, a backend API proxy, on-device AI, SQLite encryption, formal parsing evaluation, and a longitudinal study.`
  REPLACE: `Eight recommendations were identified for future development: UI/UX refinement, formal parsing evaluation, a backend API proxy followed by a Google Play release, SQLite encryption, an on-device AI tier, payday-cycle budgeting, household and remittance features, and a longitudinal evaluation.`
- Table 3.5 note: `Recommendation 6` → `Recommendation 2`.
- SUS paragraph: `inform the UI/UX recommendations in Chapter IV` → `informed Recommendation 1 in Chapter IV`.

### A9. Objective 1 reports almost no "challenges" data
Objective 1 asks about practices and budgeting challenges, but Ch III only shows demographics, tracking methods, 96.7% and GCash. The deck cannot show challenges either, and a panel will ask.
- From the Form export, build **Table 3.2 (new)**: Q6 challenges with counts and %, plus the budgeting/savings frequency questions (Q4, Q5) and the Q12 breakdown (definitely vs probably). Then renumber nothing else if you name it `Table 3.1b`.
- Paste-ready paragraph (fill the brackets from the export): `Table 3.1b shows that the most frequently reported challenge was [challenge] ([n] of 30, [x]%), followed by [challenge] ([x]%) and [challenge] ([x]%). [x]% of respondents [budget regularly / rarely budget] and [x]% [save regularly]. Of the 29 respondents who intend to use an AI-powered financial app, [n] answered "definitely" and [n] "probably".`
- Tell me the numbers and I will update the deck (slides 16–17) and the script.

---

## B. Visible inconsistencies

### B1. Abstract: provider count
- FIND: `six-provider AI failover chain` → REPLACE `an eight-provider cloud failover chain (Gemini 3.5 Flash-Lite as primary, seven fallbacks) plus an optional private local model`
- (Table 3.2 and the deck both show primary + 7 fallbacks.)

### B2. Abstract: grade and benchmark attribution
- FIND the clause ending `grade of D and an adjective rating of "OK"` → REPLACE `an adjective rating of "OK" (Bangor et al., 2009) and a Grade D on the Sauro and Lewis (2016) curved scale, which is below the 68-point average benchmark (Sauro & Lewis, 2016) and the pre-set target of 80`
- Ch III and Ch IV: `Per Bangor, Kortum, and Miller (2009), this corresponds to an adjective rating of "OK" (Grade D)` → `…an adjective rating of "OK" (Bangor et al., 2009) and Grade D on the Sauro and Lewis (2016) scale`. Grades come from Sauro & Lewis, not Bangor.
- `the 68-point average benchmark established by Bangor et al.` → `…established by Sauro and Lewis (2016)`.

### B3. Target of 80 is not "Good"
- FIND: `corresponding to the adjective rating of Good` → REPLACE `which lies between the Good (about 71) and Excellent (about 85) adjective anchors of Bangor et al. (2009); it was set as an aspirational threshold before data collection, and the 68 average benchmark (Sauro & Lewis, 2016) served as a secondary reference`

### B4. Figure 2.1: text and picture describe different scales
Text says Poor <60, Marginal 60–69, Acceptable 70–79, Good 80–89, Excellent 90–100. The image shows Bangor's bands (<51, 51–70, 71+). The image also has overlapping labels.
- Replace the picture with `Fig_2_1_SUS_interpretation_redrawn.png`.
- Replace the description paragraph with: `Figure 2.1 shows how SUS scores were interpreted. Scores below 51 were considered not acceptable, 51 to 70 marginal, and 71 and above acceptable (Bangor et al., 2008). The adjective anchors of Bangor et al. (2009) are marked on the scale: OK (about 51), Good (about 71), and Excellent (about 85). The dashed line marks the 68-point average benchmark (Sauro & Lewis, 2016) and the pre-set target is 80.`

### B5. SUS item labels
- `complexity (Q2, Q4)` → `complexity (Q2) and need for technical support (Q4)` (Item 4 is "I would need the support of a technical person", not complexity).

### B6. SUS exclusions: two different explanations
- Ch III FIND: `30 confirmed they used the app for the required minimum duration` (whole sentence) → REPLACE `Of 36 respondents who attempted the survey, 31 confirmed using the app for the required minimum duration; 1 of these was excluded for straight-line responding, leaving 30 valid respondents. The other 5 were excluded for insufficient usage time.`
- Ch IV: `6 excluded for insufficient app usage time` → `6 excluded (5 for insufficient usage time, 1 for straight-line responding)`.

### B7. Criteria for choosing the LLM: "four" vs "six"
Ch I (Objective 2), Ch II (LLM Integration, procedure Step 4) say four criteria (speed, accuracy, context window, cost). Ch III and the deck say six weighted criteria.
- Replace each mention with: `six weighted criteria: Filipino-English accuracy (25%), speed (20%), tool use and JSON reliability (20%), free-tier availability (15%), context window (10%), and financial reasoning (10%)`.
- Step 4: `Response latency, accuracy, context window, and cost were recorded` → `Latency, Filipino-English accuracy, tool-use reliability, free-tier availability, context window, and financial reasoning were recorded and compared`.
- Under Table 3.2 add: `Table 3.2 reports the measured values per criterion. A single weighted total per model was not computed, and entries marked "Not measured" were outside the team's own benchmark run.` (Honest, and it pre-empts "show me the weighted scores".)

### B8. Table 3.2 row "Gemini 3.7 Flash": the Provider cell contains the status sentence
- Put `Google` in the Provider cell and move `Not used: same ~20/day quota as 3.5 Flash with no added benefit in trials` to the Status cell.

### B9. Fig 3.7 caption promises more than the picture shows
Caption: "Receipt Scanning and Batch Screenshot Import". The image is only the receipt review screen, and it exposes real names (the extracted text shows a name and a cashier's name), which is awkward next to a privacy claim.
- Replace the image with two side-by-side images: `Fig_3_7a_Receipt_review_names_pixelated.jpg` and `Fig_3_7b_Batch_screenshot_import.jpg`.

### B10. Fig 3.9 caption
- FIND: `Budgets, Safe-to-Spend, and Savings Goals` → REPLACE `Budgets Screen with Over-Income Warning` (the screenshot shows only budgets; or swap in a screenshot that really shows safe-to-spend and goals).

### B11. Fig 3.5 vs 3.8: two different scores, plus an unexplained "Management Score"
Fig 3.5 shows 96/100 and "Management Score 97/100 (Expert Tracker)"; Fig 3.8 shows 64/100. Add under Fig 3.8: `Figures 3.5 and 3.8 were captured from Demo Mode at different times, so the displayed scores differ.` The "Management Score" is not explained anywhere. [CONFIRM what it is] and add one sentence, or crop it out of Fig 3.5.

### B12. Fig 3.1 flowchart logic
The diagram branches on "Local-only mode on?". The text says Private Local Mode is used when the local server is reachable, and Local-only only blocks the cloud fallback. Change the decision diamond to `Local AI server reachable, or Local-only on?`

### B13. Figures 1.2 and 2.2 have a caption baked into the picture
They read "Figure 1." and "Figure X." under your real caption. Replace the images with `Fig_1_2_IPO_no_baked_caption.png` and `Fig_2_2_Kanban_no_baked_caption.png`. Fig 1.1 also carries its own title; fine, but make sure the numbering matches your caption.

### B14. Fig 1.1 contradicts three claims in Ch I
Fig 1.1 shows adults 25–44 at 51% and 45–64 at 49% keeping a budget, higher than all adults (46%). But Ch I says parents 35–55 "exhibited the lowest rates of formal account ownership and structured budgeting among all adult demographics" (in several places).
- Replace each such sentence with: `Parents aged 35 to 55 carry the main household financial responsibility, yet, as Figure 1.1 shows, fewer than half of Filipino adults kept a household budget (46%) and only 2% answered all six financial literacy questions correctly.`

### B15. Ch I competitor paragraph
- FIND: `Table 2.1 summarized the key feature differences` → REPLACE `Table 1.2 summarized the key feature differences`.
- PocketGuard is discussed in the text but not in Table 1.2; delete that sentence or add a PocketGuard column.

### B16. Garbled sentences in Ch II
- FIND: `only surveys, not surveys, were used` → REPLACE `only structured survey questionnaires were used`
- FIND: `No surveys were conducted; qualitative insights` → REPLACE `No interviews or focus groups were conducted; qualitative insights`
- Ch III FIND: `No formal open-ended Survey data was collected.` → [CONFIRM] if the SUS form had an optional comment box (Appendix C does), use `Optional comments were invited in the SUS form but were not analyzed thematically.`

### B17. Ch II implementation sentence reads as if the proxy and encryption exist
- FIND: `Additional enhancements included the implementation of a backend proxy server` (whole sentence)
- REPLACE: `A backend proxy server for API key handling and SQLite database encryption were identified as enhancements but were not implemented in this study (Chapter IV, Recommendations 3 and 4).` (Add PDF export only if it exists. [CONFIRM])

### B18. Truncated sentence at the start of "System Development Results"
- FIND: `(Table 2.2: Agile Kanban Workflow Phases and Deliverables` → REPLACE `(see Table 2.2). The system architecture, use-case view, and navigation structure are shown in Figures 3.1 to 3.3.`

### B19. Stale and unsupported app facts
- `sqflite package (version 11)` (appears twice) → `sqflite package (database schema version 14)` [CONFIRM current schema version].
- The deck states 45 screens, 7 input modalities, 9 AI providers, 57 currencies and APK about 47.5 MB. The manuscript states none of them. Add one paragraph to Ch III Obj 2: `SmartSpend v3.1.0 comprises 34 autonomous AI actions, 7 input modalities, 40+ supported screenshot platforms, a 26-table SQLite database, 45 screens, 36 achievement badges, 9 AI providers (8 cloud and 1 local), and 57 currencies, in an Android package of about 47.5 MB.` [CONFIRM each number in the code]
- FHS paragraph: delete `The behavior of this component when zero category budgets were configured was a known open item pending confirmation against the current build and was not asserted here.` Ask Kiro what the code does, and keep the answer for Q&A.

### B20. Appendix and list numbering
Recommended appendix order (matches what is actually in the body, plus the two new ones): A Survey Questionnaire · B Informed Consent Form · C SUS Questionnaire · D Content Validation Certificate (Survey) · E Content Validation Certificate (FHS) · F SUS Individual Scores (new) · G Technical Validation Certificate (new or removed).
- Ch II Step 1: `Content Validation Certificate (Appendix A)` → `(Appendix D)`.
- TOC: add Informed Consent as B, fix C, D, E, add F and G.
- List of Tables: **Table 2.2 must read `Agile Kanban Workflow Phases and Deliverables`** (it currently shows an LLM title). Check that Table 3.2's page is not before its section's page.
- List of Figures: remove 3.14, add page numbers for 3.12 and 3.13.
- After all edits: right-click each TOC / list → update. If they are typed by hand, re-check every page number once.

### B21. Obj 3 "performance" is not evaluated formally
Objective 3 says "usability and performance". Add to the Table 3.5 discussion: `Performance was assessed only through preliminary developer testing; no formal performance evaluation was conducted, which is why Recommendation 2 proposes one.` And in Table 3.5 add the test size to the overall row: `91.2% precision, 88.5% recall (n = [number of test items])`. [CONFIRM n]

---

## C. Polish
- **Title and adviser:** the title page lists the adviser inside the author block with no label. Add `Adviser:` and use one form of the name everywhere (`Ellen F. Mangaoang, DIT`).
- **Raposas's title:** your manuscript uses "Mr. Shekiro R. Raposas"; the ORDINEX reference deck uses "Engr. Shekiro R. Raposas". Confirm his preferred title and use it in the manuscript, deck and script.
- **Role names:** he is "Capstone Teacher-in-Charge" (approval sheet), "instructor in charge" (acknowledgments), "Instructor" (script). Pick one.
- **Citations:**
  - Ariely (2008): delete the URL `https://www.anthropic.com/claude` from the reference.
  - Bitrián et al. (2021): the visible DOI text (`IJBM-02-2021-0074`) differs from the link target (`IJBM-09-2020-0491`). Check at doi.org and make them identical.
  - Gubbins, Mazzotta & Rhyne (2021) is cited in-text but listed as "UNSGSA (2021)". Change the entry to start with the three authors.
  - `Google, 2024f` is used for both Flutter and Gemini function calling. Give the function-calling document its own letter, and there is no `2024d`: relabel so letters run a, b, c, d, e.
  - The Data Privacy Act (RA 10173) is listed (National Privacy Commission, 2012) but never cited in the text. Add `(National Privacy Commission, 2012)` after "Republic Act No. 10173" in the Scope paragraph.
  - Move the 3 stray references after the notes (Bangor 2008, Deci & Ryan, Sauro & Lewis) into alphabetical position.
- **CVs:** Djaunathan's research section is blank (the other two list Capstone 1); Brix's CV has no contact number.
- **Age range:** Ch I says "20–35"; everywhere else 21–35. Make it 21–35.
- **Table 3.1:** `†` appears in the "Both" and "Total" headers with no footnote under the table (fixed in A5).
- **Fig numbering consistency:** after deleting 3.14, figures 3.1–3.13 are continuous, so the deck's "Fig 3.4 to 3.7" labels stay correct.
- **App name on screen:** the login screen reads "Smart Spend" (two words). Everything else says "SmartSpend". Fine, but expect the question.

---

## D. Paste-ready Chapter IV (replace the existing Conclusions and Recommendations)

### Conclusions
`Objective 1 was to assess the financial management practices, budgeting challenges, and expense-tracking behaviors of parents aged 35 to 55 and young professionals aged 21 to 35 in San Fernando City. The needs assessment of 30 respondents showed that 90.0% track expenses through receipts, 53.3% through mental estimates, and only 10.0% through a mobile app, while 96.7% intend to use an AI-powered financial app and 93.3% already use GCash. The first objective was achieved.`

`Objective 2 was to design and develop SmartSpend, with an LLM API chosen through comparative technical evaluation. SmartSpend v3.1.0 was developed as a working Android application with 34 autonomous AI actions, Gemini 3.5 Flash-Lite as the primary model with seven fallback providers, an optional private local model, and a Financial Health Score. The second objective was achieved. Security remains prototype-grade, and accuracy figures come from preliminary developer testing.`

`Objective 3 was to evaluate usability and performance using the System Usability Scale and user feedback. The mean SUS score of 61.83 (SD = 17.58, N = 30) corresponds to an adjective rating of "OK" and Grade D, below the 68 average benchmark and the pre-set target of 80, and is marginal under the acceptability criteria. Users reported strong intent to use the app often (4.35 out of 5) and confidence (4.19), while consistency (Q6), complexity (Q2), and need for technical support (Q4) were the main concerns. Because usability was evaluated but the target was not met, and performance was assessed only preliminarily, the third objective was partially achieved.` [update numbers if A1 changes them]

### Recommendations (each is tied to a limitation; none is already built)
1. **UI/UX refinement.** Unify interface patterns and simplify onboarding and navigation to address the consistency, complexity, and technical-support concerns (SUS Q6, Q2, Q4) and the below-target score.
2. **Formal parsing evaluation.** Test receipt, screenshot, voice, and text parsing against at least 50 standardized receipts across platforms, replacing the preliminary 91.2% precision and 88.5% recall.
3. **Backend API proxy, then Google Play release.** Move API keys server-side with per-user limits to remove device-side key exposure, and publish on Google Play only after the proxy and a privacy policy are in place.
4. **SQLite encryption.** Encrypt the local database (for example with SQLCipher), since it is currently unencrypted.
5. **On-device AI tier.** Offer an opt-in model of about 2.6 GB so AI features work offline, since all AI features currently need internet access.
6. **Payday-cycle-aware budgeting.** Align budget resets with the 15th and 30th salary cycle, a feature only one compared app offers (Table 1.2).
7. **Household and remittance features.** Add shared household wallets and OFW remittance as a distinct income category.
8. **Longitudinal evaluation.** Evaluate over three to six months with a larger sample that includes more parents, to measure behavior change and the effect of Peso and the badges.

---

## E. Before Nov 16: quick checklist
- [ ] A1 raw SUS file reproduced all stats
- [ ] A2 Appendix F table built
- [ ] A4 validator name settled; Technical Validation Certificate added or sentence removed
- [ ] A6 evaluated build version confirmed
- [ ] A9 Objective 1 challenge table added
- [ ] All Section D text pasted; Abstract updated
- [ ] TOC / List of Tables / List of Figures re-checked
- [ ] Printed copies match the final file
