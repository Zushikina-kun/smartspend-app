# Manual Edit Guide: Manuscript + Deck (content-only)

Apply by hand in Word and PowerPoint. This guide does not resave your files, so formatting stays untouched. Items marked **[CONFIRM]** need a fact only you can supply.

Decisions built in:
- Objective 3 = "partially achieved" everywhere.
- SUS target stays 80. The 68 average is attributed to Sauro & Lewis (2016).
- The SUS protocol follows Ch. III: self-directed use of 10+ minutes with a screening question.
- Recommendations are 7, matching the deck.

---

## PART A: MANUSCRIPT

### A1. Front matter
1. **Acknowledgement**
   - Find: `Dr. Janelli M. Raposas`
   - Replace with the real instructor in charge. The Approval Sheet says Shekiro R. Raposas, MIT is Teacher-in-Charge. If that's right, use `Mr. Shekiro R. Raposas, MIT`. **[CONFIRM]**
2. **Approval Sheet**
   - Chairperson and Dean are both "Jeoffrey B. Layco, MIS."
   - If the Chairperson is someone else or still unassigned, fix the Chairperson block only. **[CONFIRM]**
3. **Abstract**
   - Find: `(CBA-MI, 2018) Observed`
   - Replace: `(Comerton-Forde et al., 2018) Observed`

### A2. Chapter I
4. Find: `Secondary analyses estimate that only around one in four Filipino adults meets international financial literacy benchmarks — far below neighboring countries such as Malaysia and Singapore where rates exceed 50% (Inquiro, 2024).`
   - Action: **delete the sentence.** It conflicts with the BSP measures. Fig. 1.1 still cites Inquiro.
5. Find: `reports that 74% of Filipinos now correctly answer basic financial literacy questions, up from 69% in 2021`
   - Replace: `reports that 74% of Filipino adults now correctly answer at least half of six basic financial literacy questions, up from 69% in 2021 (compared with 2% who answered all six correctly in 2021)`
6. Find: `Table 2.1 summarizes the key feature differences.`
   - Replace: `Table 1.2 summarizes the key feature differences.`
7. **Table 1.2**, row "Paluwagan tracker", SmartSpend column: `No` → `Yes`. Leave "15th & 30th payday cycle" as No.
8. Find (appears twice, Project Context and Technical Background): `sqflite package (version 11)`
   - Replace: `sqflite package (database schema v14, 26 tables)`

### A3. Chapter II
9. **Research Design, SUS paragraph**
   - Find: `following a live demonstration of the SmartSpend application. A target SUS score of 80 or above, corresponding to the adjective rating of Good, has been set as the acceptance threshold for this study (Bangor et al., 2009).`
   - Replace: `after they used the SmartSpend application (the full version or the built-in Demo Mode) for at least 10 minutes. A target SUS score of 80 or above, which lies between the "Good" and "Excellent" adjective anchors of Bangor et al. (2009), was set in advance as the acceptance threshold for this study; the widely used average of 68 (Sauro & Lewis, 2016) is reported as a secondary benchmark.`
10. **Population and Locale**
    - After the sentence ending `Three (3) respondents identified as both.`, add:
    - `The usability (SUS) sample was separate from the needs-assessment sample. Of 36 responses received, 30 were valid: 10 parents and 20 young professionals, as self-identified in the SUS form. Six responses were excluded (5 for insufficient app-use time, 1 for straight-line response bias).`
11. **Table 2.1**
    - Retitle: `Table 2.1. Distribution of Respondents and Validators` (matches the List of Tables).
    - Add a block after "Total": `SUS evaluation sample: Parents (35–55) 10 | Young Professionals (21–35) 20 | Total 30`
12. **Data Gathering, Objective 1**
    - Find: `No surveys were conducted; qualitative insights`
    - Replace: `No interviews were conducted; qualitative insights`
13. **Data Gathering, Objective 2**
    - Find: `Each candidate was assessed across four criteria: (1) inference speed` through `(4) cost feasibility, evaluated based on the availability of a free-tier API plan appropriate for academic deployment.`
    - Replace the whole span with: `Each candidate was assessed across six weighted criteria: Filipino-English accuracy (25%), speed/latency (20%), tool use and JSON reliability (20%), free-tier availability (15%), context window (10%), and financial reasoning quality (10%). Speed was recorded as response latency for a standardized expense-parsing prompt; Filipino-English accuracy was assessed with test prompts in Filipino, Taglish, and English; and free-tier availability was based on the provider's published plan.`
14. **Step 1**
    - Find: `Content Validation Certificate (Appendix A)`
    - Replace: `Content Validation Certificate (Appendix D)`
    - Add Appendix D (Content Validation Certificate) and Appendix E (Technical Validation Certificate) with scans. **[CONFIRM you have both]**
    - If you can't include them, replace with `on file with the researchers`.
15. **Step 5**
    - Find: `respondents were given a live demonstration of SmartSpend using the built-in Demo Mode. They then independently completed the 10-item SUS questionnaire.`
    - Replace: `respondents used SmartSpend (the full version or the built-in Demo Mode) for at least 10 minutes, confirmed by a screening question, and then independently completed the 10-item SUS questionnaire online.`
16. **Figure 2.1 caption/description**
    - Replace the whole description with: `This figure illustrates how SUS scores (0–100) are interpreted in this study. Scores below 51 are considered not acceptable, 51–70 marginal, and 71 and above acceptable (Bangor et al., 2008). Bangor et al. (2009) also mapped mean scores to adjective anchors: OK (about 51), Good (about 71), and Excellent (about 85). The study's pre-set target of 80 lies between Good and Excellent, and the 68 average (Sauro & Lewis, 2016) is used as a secondary benchmark. Higher scores indicate better perceived usability.`
    - **Redraw the Figure 2.1 image** so its bands match. The old Poor/Marginal/Acceptable/Good/Excellent bands conflict.
17. **Done/Review phase**
    - Find: `such as adding bank integration or improving AI accuracy`
    - Replace: `such as improving AI accuracy and formally evaluating parsing performance`

### A4. Chapter III
18. **Objective 1**
    - Find: `Among the 30 respondents, 96.7% expressed positive intent`
    - Replace: `Among the 30 respondents, 96.7% (29 of 30, answering "Yes, definitely" or "Probably yes") expressed positive intent`
19. **Objective 1, add after the tracking-methods paragraph**, using your Google Form export: **[FILL]**
    - `Regarding budgeting and saving practices, [X]% of respondents reported preparing a budget "always" or "often" (Q4), [X]% set aside savings before spending "always" or "often" (Q5), and [X]% recorded expenses "always" or "often" (Q9). The most frequently selected budgeting challenges were [challenge 1] ([X]%), [challenge 2] ([X]%), and [challenge 3] ([X]%) (Q6).`
20. **Table 3.1:** add under the table: `† Respondents who identified as both a parent and a young professional.`
21. **Table 3.2**
    - Gemini 3.5 Flash status: `Fallback 1 (limited quota; used only after Flash-Lite)`
    - Gemini 3.7 Flash status: `Not used: same ~20/day quota as 3.5 Flash with no added benefit in trials` **[CONFIRM]**
22. **Circular 1133**
    - Find: `the Bangko Sentral ng Pilipinas' interest rate cap under BSP Circular No. 1133`
    - Replace: `the interest-rate ceilings that BSP Circular No. 1133 (Series of 2021) sets for lending and financing companies and their online lending platforms on small, short-term loans`
    - Ceilings were later recalibrated by the SEC (Dec 2025). Check the AI prompt's numbers against the current rule. **[CONFIRM]**
23. **FHS section, two places**
    - Find: `(Gubbins, Mazzotta & Rhyne, 2021)`
    - Replace: `(UNSGSA, 2021)` (matches the reference entry)
24. **Budget Adherence**
    - Find: `The behavior of this component when zero category budgets are configured is a known open item pending confirmation against the current build and is not asserted here.`
    - Replace: `When no category budgets have been set, this component [CONFIRM from score_service.dart: awards 0 points / is excluded from the score].`
25. **Peso paragraph**
    - Find and delete the whole sentence: `Present Peso as a design feature, not as evidence of behaviour change, and avoid phrases such as "dopamine reinforcement".`
26. **SUS section, add after the exclusions sentence**
    - `The build evaluated was v[CONFIRM]. Peso and the additional badges were added in later builds.`
27. **After Table 3.3**
    - Find: `which is below the pre-established acceptance threshold of 80 or above and below the 68-point average benchmark.`
    - Replace: `which is below the pre-established acceptance threshold of 80 and below the 68-point average benchmark (Sauro & Lewis, 2016). This places the score between the OK and Good anchors of Bangor et al. (2009), in the marginal acceptability range (Bangor et al., 2008), and a grade of D on the Sauro and Lewis curved scale.`
28. **After Table 3.4**
    - Find: `This score is below the 68-point average benchmark established by Bangor et al. and below`
    - Replace: `This score is below the 68-point average benchmark (Sauro & Lewis, 2016) and below`
    - Add after the group comparison: `Parents, the primary target group, made up only 10 of the 30 valid respondents, so the overall score leans toward young professionals.`
29. **Find:** `which inform the UI/UX recommendations in Chapter IV`
    - Replace: `which inform Recommendation 5 in Chapter IV`
30. **Table 3.5**
    - Find: `(see Chapter IV, Priority 9)`
    - Replace: `(see Chapter IV, Recommendation 6)`
    - Overall row: `91.2% precision, 88.5% recall (preliminary developer testing, N = [CONFIRM] receipts)`
    - If you can't state N or method, delete the figure here, on deck slide 15, and in the script.
31. **Objective 3 closing line (last sentence of the Technical Performance Benchmarks section)**
    - Find: `These results showed that the third objective of the study was achieved: the usability of SmartSpend was evaluated using the System Usability Scale with 30 valid respondents, yielding a mean score of 61.83 (rated “OK”), which is below the 68-point benchmark and the pre-established target of 80.`
    - Replace: `These results showed that the third objective of the study was partially achieved: usability was evaluated using the System Usability Scale with 30 valid respondents, but the mean score of 61.83 fell below the 68-point benchmark and the pre-established target of 80.`

### A5. Chapter IV: replace the three Conclusions paragraphs with these
> The first objective was achieved. The needs assessment of 30 respondents confirmed that 96.7% intended to use an AI-powered financial application and 93.3% already used GCash, and that most respondents tracked expenses through receipts and memory rather than a dedicated app (10.0%), which validated the target population and feature priorities.
>
> The second objective was achieved. SmartSpend v3.1.0 was developed as a working Android application with multi-modal expense input, offline-first local storage, 34 AI actions, and a Financial Health Score formally classified as a Prototype Observed Financial Health Indicator. The comparative evaluation of 20 candidate LLM models led to the selection of Gemini 3.5 Flash-Lite as the primary model, supported by a multi-provider failover chain. Features such as on-device AI, payday-cycle budgeting, and database encryption remain future work.
>
> The third objective was partially achieved. Usability was evaluated with the System Usability Scale using 30 valid respondents screened from 36 responses. The mean score of 61.83 (SD = 17.58, median = 55.00, range 35.0–92.5) corresponds to a grade of D and lies between the OK and Good anchors, below both the 68-point average and the pre-established target of 80. The evaluation therefore identified UI/UX areas for improvement, namely consistency and complexity, rather than confirming the target level of usability.

**Recommendations: replace the list with these 7** (each from a limitation, future tense, who acts):
1. **Payday-cycle-aware budgeting.** The developers may implement budgeting resets aligned with the semi-monthly (15th and 30th) salary cycle common in the Philippines. *(unchanged)*
2. **Backend API proxy, per-user limits, and Google Play release.** The developers may move LLM API key management to a server-side proxy (e.g., Firebase Cloud Function) to remove device-side key exposure and enforce per-user message limits, because the free-tier quotas (Table 3.2) are shared by every user of the prototype, and may then submit SmartSpend to the Google Play Store once a privacy policy is in place.
3. **On-device AI tier.** *(old #4, unchanged)*
4. **SQLite encryption.** *(old #5, unchanged)*
5. **UI/UX refinement.** The developers may revise the interface to improve consistency and reduce perceived complexity, because the SUS results identified consistency (Q6) and complexity (Q2, Q4) as the main concerns.
6. **Formal parsing evaluation.** Future researchers may evaluate OCR and import accuracy with 50 or more standardized receipts across platforms, because the reported precision and recall come from preliminary developer testing.
7. **Longitudinal evaluation.** *(old #7, unchanged)*

Dropped: the household/OFW item. It's already described as long-term, out-of-scope work in Ch. II.

### A6. Appendices and back matter
32. **Appendix B footnote**
    - Find: `Note: The 3 respondents who identified as both parent and young professional were classified by their primary financial role for SUS subgroup analysis, resulting in a final breakdown of 10 parents and 20 young professionals for statistical comparison (Table 8).`
    - Replace: `Note: The SUS sample was separate from the needs-assessment sample. Of the 30 valid SUS respondents, 10 identified as parents and 20 as young professionals (Table 3.4).`
33. **End of the document**
    - **Delete all three** repeated paragraphs beginning `Content validation was performed by subject matter experts…`.
    - They name Maam Abby and your adviser as the technical validator, which contradicts Ch. II.
34. **Validator independence**
    - Make sure Ch. II, the certificates, and the panel's expectation (an independent IT expert) all name the same two people. **[CONFIRM]**

### A7. References
35. **Add:**
    - Bangor, A., Kortum, P. T., & Miller, J. T. (2008). An empirical evaluation of the System Usability Scale. *International Journal of Human–Computer Interaction, 24*(6), 574–594.
    - Deci, E. L., & Ryan, R. M. (2000). The "what" and "why" of goal pursuits: Human needs and the self-determination of behavior. *Psychological Inquiry, 11*(4), 227–268.
    - Sauro, J., & Lewis, J. R. (2016). *Quantifying the user experience: Practical statistics for user research* (2nd ed.). Morgan Kaufmann.
36. **Delete these (never cited in the text):** Anthropic (2024) with its stray URL line, Consumer Financial Protection Bureau (2017), Faulkner (2003), Financial Health Network (2026), MaikuB (2023), Meta AI (2024), Nielsen & Landauer (1993), OpenAI (2024), Wajid et al. (2025).
    - Alternatively, cite them where relevant.
37. **Bitrián et al. (2021)**
    - Keep the visible DOI `10.1108/IJBM-02-2021-0074`.
    - Re-link the hyperlink to `https://doi.org/10.1108/IJBM-02-2021-0074`. It currently points to a different article.

### A8. Lists and TOC (last, after final layout)
38. **List of Tables**
    - Table 2.2 title → `Agile Kanban Workflow Phases and Deliverables`
    - Table 2.1 title → `Distribution of Respondents and Validators`
39. **TOC**
    - Add `Appendix D` and `Appendix E`.
    - Add the heading `Design and Development of the SmartSpend Mobile Application` under Ch. III.
    - Refresh all page numbers. Figure 3.10 (p. 68) and the Evaluation section (p. 68) currently clash.

---

## PART B: DECK (`SmartSpend_Defense.pptx`)

1. **Slide 2**
   - `BSP CFIS 2026` → `BSP CFIS 2025`
   - Replace "basic literacy rose from 69% to 74%" with `the share answering at least half of six literacy questions correctly rose from 69% to 74%`.
2. **Slide 7**
   - First stat: `30 needs-assessment respondents: 13 parents, 14 young professionals, 3 both. Separate SUS sample: 30 valid of 36 (10 parents, 20 young professionals)`
   - Third stat: `10-item SUS after using the app (full or Demo Mode) for 10+ minutes`
3. **Slide 14**
   - Title → `Objective 3: usability scored 61.83 (marginal)`
   - Subtitle → `Grade D; between "OK" and "Good"`
4. **Slide 15**
   - Small, local sample → `30 purposive respondents from one locale; only 10 were parents (primary target); not generalizable.`
   - Parsing accuracy → add N, or delete the figure. **[CONFIRM]**
5. **Slide 16, Objective 3 text**
   - Replace with `SUS 61.83: below the 68 average and the 80 target; UI/UX areas identified.`
6. **Slide 17: replace the 7 items with**
   1. Payday-cycle budgeting
   2. Backend API proxy: server-side keys, per-user limits, then Google Play release
   3. On-device AI tier
   4. SQLite encryption
   5. UI/UX refinement: consistency and complexity
   6. Formal parsing evaluation: 50+ standardized receipts
   7. Longitudinal study
7. **Slide 9**
   - Confirm the version and APK size match your GitHub Release (v3.1.0, ~47.5 MB). **[CONFIRM]**

---

## PART C: Confirm before printing or presenting
- Chairperson's name, and the real instructor in charge.
- The two validators' names, independence, and certificates.
- The build version respondents tested.
- Source and N for 91.2% / 88.5%.
- Objective 1 figures (Q4, Q5, Q6, Q9) from your form export.
- Budget Adherence behavior with no budgets set.
- FHS pillars shown on the live site (it once showed "Budget Setup") match the code.
- Actual redaction targets in the code (mobile numbers only, or also reference numbers and account patterns).
- Gemini 3.7 Flash rejection reason, and current lending-rate ceilings.
- Your raw SUS export, plus the per-respondent computation behind Figure 3.11.
