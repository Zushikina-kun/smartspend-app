# SmartSpend — MASTER FIX GUIDE (v4)
**Date:** November 14, 2026 · **Defense:** November 16, 2026, 3:00 PM
**Supersedes:** MANUAL_FIX_GUIDE.md, CLAUDE_HANDOFF_FINAL.md, and my earlier two guides.
**Built from:** the real manuscript docx (text, all 40 images, embedded adviser comments) + both handoff files.

Apply top to bottom, in manuscript order. Each edit is FIND → REPLACE. Text in code blocks is paste-ready.

---

## 0. Decisions that differ from the handoff (read first)

**D1. Respondent split: report the ACTUAL 13 / 14 / 3.** (Handoff said 16 + 14.)
- Your Figure 5 chart and Table 5 both show 13 parents, 14 young professionals, 3 "both". Ma'am Ellen's comment on Table 3 says "adjust this based on actual, then adjust also the text."
- "Classified as parents based on their primary financial role" is **not supported by your instrument**. The survey (Appendix A) has no such question: Q2 is a single category item and Q1 is an age bracket. A panelist can ask "how was role determined?" and you have no answer.
- The handoff's 16 + 14 plan also never fixes the Figure 5 image, which would then contradict your own text.
- Going with the actual counts needs fewer edits (Table 5 and Figure 5 stay as they are). If you still want 16 + 14, use **Option B** in Section 9, and only if you can truthfully say how the 3 were classified (for example by age bracket from Q1).

**D2. "Eight-provider failover chain" → "eight-model failover chain."** The chain is 8 models across 3 providers (Google, Groq, Cerebras). Your Conclusions would otherwise say "ten models from four providers" and "eight-provider chain" in the same sentence, and a panelist will catch it. Apply it in the Abstract, Chapter I, Chapter IV, the PPT, and the script.

**D3. Appendix B in the TOC must be Informed Consent.** The handoff's TOC fix would label both B and C as the SUS questionnaire.

**D4. Figure 17 text:** the handoff says each component shows a tip. Only two of the four do. Use the text in E22.

**D5. Items the handoff marked "skip" that are not clean:** Figure 11 text, Figure 21's baked-in chart title, and Figure 14 vs Figure 17 score mismatch (all covered below).

### Protected values (never change)
| Value | Correct form |
|---|---|
| SUS | **61.83**, SD **17.58**, median **55.00**, grade **D**, adjective **"OK"** |
| Objective 3 | **partially achieved** |
| Needs assessment | **N = 30** (13 parents, 14 young professionals, 3 both) |
| SUS evaluation | **30 valid of 36** (10 parents + 20 YP, separate group) |
| AI intent / GCash | **96.7% (29/30)** / **93.3% (28/30)** |
| Model / actions / recs | **Gemini 3.5 Flash-Lite** / **34** / **9** |
| LLM evaluation | **ten candidate models from four providers** (Table 6 has 10 rows) |
| Failover chain | **eight-model cloud failover chain (Gemini 3.5 Flash-Lite as primary, seven fallbacks)** |
| Design / sampling | **quantitative descriptive developmental**; respondents **random**, validator **purposive** |
| Validator | **Avigail Candevario, PFMe** |

---

## 1. Front matter

**E1.** You have **two Tables of Contents**. Delete the first one (the old one that lists "C – Transcript of Interview").

**E2.** In the TOC you keep, set the appendix lines to match the real order:
```
APPENDIX A: Survey Questionnaire
APPENDIX B: Informed Consent Form
APPENDIX C: System Usability Scale (SUS) Questionnaire
APPENDIX D: Content Validation Certificate (Survey Questionnaire)
APPENDIX E: Content Validation Certificate (FHS Formula)
```
Delete "SUS Individual Scores". The TOC lists Acknowledgement and Dedication before Abstract, but the manuscript order is Abstract → Acknowledgement → Dedication. Reorder the TOC to match. Regenerate all page numbers last.

---

## 2. Abstract and Chapter I

**E3.** Find: `Table 3 summarized the key feature differences.`
Replace: `Table 2 summarized the key feature differences.`

**E4.** Technical Background → LLM API Integration.
Find: `selected after a comparative evaluation of eight providers based on`
Replace: `selected after a comparative evaluation of ten candidate models from four providers (see Table 6) based on`

**E5. Technical Background (per Cyrille's and Ma'am Ellen's comments).** Delete these citations from the end of their sentences:
`(Google, 2024c)`, `(Google, 2024a)`, `(Google, 2024b)`, `(Sloane, 2022)`, `(Google, 2024e)`, `(Bociek, 2023; ZXing, 2023)`, `(Flutter 4 Fun, 2022)`, `(The Flutter Authors, 2013)`.
Then trim every entry to 2–3 sentences about what it did in SmartSpend. Example for the two commented entries:
```
Flutter. Flutter was used to build the SmartSpend Android application, including all screens, navigation, the chat interface, and analytics charts, from a single codebase. The app was compiled to an APK and installed on respondents' devices for evaluation.

SQLite. SQLite, through the sqflite package, stored every expense, budget, goal, income record, and chat message on the device, so core features worked offline. Local data was merged with Firebase on reconnection.
```
Change `sqflite package (version 11)` to the real version in your `pubspec.yaml` (almost certainly 2.x). Then resolve the Cyrille and Ellen comment threads.

**E6. "Eight-provider" → "eight-model"** (decision D2). Find every `eight-provider cloud failover chain` and replace with `eight-model cloud failover chain`. Locations: Abstract, Technical Background (LLM API Integration), Chapter IV conclusions. In the same entry, if it says "across Google, Groq, and Cerebras", keep that.

---

## 3. Chapter II — Research Design

**E7. Paragraph 1.** Replace the entire paragraph (it begins "This study applied a quantitative descriptive developmental design, which integrated both qualitative and quantitative...") with:
```
This study applied a quantitative descriptive developmental research design, which relied on quantitative approaches in collecting and analyzing data. This design was appropriate because it allowed the researchers to describe the financial management practices of the target population and to measure the usability of the developed system through standardized numerical scores. Through this approach, the researchers were able to capture measurable trends in user behavior, preferences, and challenges.
```
This also removes the Creswell & Plano Clark citation (a mixed-methods text, and it is missing from your References).

**E8. Paragraph 3.** Find: `On the other hand, the quantitative aspect of the study involved the use of validated structured survey questionnaires, which underwent content validation by subject matter experts to ensure clarity, relevance, and alignment with the objectives of the study.`
Replace: `The survey questionnaire underwent content validation by a subject matter expert to ensure clarity, relevance, and alignment with the objectives of the study.`
Delete the next two sentences (`These questionnaires were used to collect measurable data...` and `The collected data were analyzed to identify patterns...`). Keep the SUS sentences that follow.

**E9.** Find: `based on the data gathered from both qualitative and quantitative methods.`
Replace: `based on the survey and usability data gathered.`

**E10.** Find: `By combining quantitative descriptive developmental and developmental approaches, the study ensured`
Replace: `By adopting a quantitative descriptive developmental approach, the study ensured`
Then find `This integrated research design supported` → replace `This research design supported`.
Resolve Ellen's "qualitative is for interviews" thread.

---

## 4. Chapter II — Population, tables, ethics, data gathering, methodology

**E11. Population, opening sentence.**
Find: `A total of thirty (30) respondents participated which included parents aged 35 to 55, young professionals aged 21 to 35, 1 content validator as seen in Table 3.`
Replace:
```
A total of thirty (30) respondents participated, composed of parents aged 35 to 55, young professionals aged 21 to 35, and respondents who identified as both, as seen in Table 3. One content validator participated separately.
```

**E12. Sampling paragraph.** Replace the first four sentences (from `A total of thirty (30) respondents were selected using random sampling.` through `...independent financial decisions.`) with:
```
A total of thirty (30) respondents were selected using random sampling, as any parent aged 35 to 55 or young professional aged 21 to 35 who met the inclusion criteria was eligible to participate. Thirteen (13) respondents were parents who regularly handled household budgeting, bill payments, and daily expense decisions. Fourteen (14) respondents were young professionals who managed their own income, tracked expenses, and made independent financial decisions. Three (3) respondents identified as both a parent and a young professional.
```
In the sentence that follows, delete the citation `(Creswell & Plano Clark, 2011)`. Resolve Ellen's "edit" thread.

**E13. Table 3.** Change the title to `Table 3: Distribution of Respondents`. Replace the table with (and fix the stray text so Total reads `30`):

| Category | Number of Respondents |
|---|---|
| Parents (Ages 35–55) | 13 |
| Young Professionals (Ages 21–35) | 14 |
| Both parent and young professional | 3 |
| **Total** | **30** |

Add below it:
```
Note. One content validator (survey) participated separately for instrument validation and is not counted among the 30 respondents.
```
Delete the stray `Note. The content validator participated separately...` line above Figure 4. Resolve Ellen's Table 3 thread.

**E14. Last two Population paragraphs.**
- In the validator paragraph, change `...appropriateness of the instrument.` to `...appropriateness of the instrument (see Appendix D).`
- Delete `whose qualifications were documented in the Technical Validation Certificate.` and the following sentence `This expert validation covered...`. No such certificate exists in your appendices.
- Replace the whole paragraph `The researchers utilized random sampling in selecting participants. This method allowed the intentional selection of...` with:
```
Any parent aged 35 to 55 or young professional aged 21 to 35 who managed personal or household finances was eligible to participate, and respondents were selected at random from among those who met these criteria.
```
("Intentional selection" is the definition of purposive sampling and contradicts your own random-sampling claim.)

**E15. Ethical Considerations.** Find: `before their involvement in the study.`
Replace: `before their involvement in the study (see Appendix B).`

**E16. Data Gathering.** Find: `...experience in financial management and business operations. Survey responses were tallied`
Replace: `...experience in financial management and business operations (see Appendix D). Survey responses were tallied`
Your per-objective structure already satisfies Ellen's "per objective, what you did and tools used" comment; resolve that thread.

**E17. Software Methodology.**
- Find: `as seen in Figure #.` → Replace: `as seen in Figure 4.`
- Done/Review Phase: find `such as adding bank integration or improving AI accuracy.` and replace with `.` so the sentence ends at "future development." Then delete everything after it in that paragraph, from `Based on the iterative development process...` through `...proposed for subsequent research.`
- Optional: keep the multi-wallet detail by pasting this into Chapter III after the Paluwagan paragraph:
```
A multi-wallet system was also implemented, supporting 20 Philippine banks and 5 digital banks plus e-wallets such as GCash, Maya, GrabPay, and ShopeePay, with automatic balance deduction upon expense logging and wallet-to-wallet transfers.
```

---

## 5. Chapter III — Objective 1

**E18. Table 5 and its text.**
- Keep Table 5 as it is (13 / 14 / 3). Delete the `†` marks.
- Fix the table note. Find `(parents n = 16, young professionals n = 14)` → Replace `(parents n = 13, young professionals n = 14, both n = 3)`.
- Find: `The sample comprised 16 parents aged 35–55 (53.3%) and 14 young professionals aged 21–35 (46.7%).`
  Replace: `The sample comprised 13 parents aged 35–55 (43.3%), 14 young professionals aged 21–35 (46.7%), and 3 respondents who identified as both (10.0%).`
- Replace the sentence `The 3 respondents who identified as both parent and young professional were reclassified... yielding 10 parents and 20 young professionals.` with:
```
The SUS evaluation used a separate group of respondents, who identified their own group on the SUS form (see Table 8).
```

---

## 6. Chapter III — Objective 2

**E19. Heading and placeholder.**
- Replace `Designed and Developed of the SmartSpend Mobile Application - see objective` with `Design and Development of the SmartSpend Mobile Application`.
- Replace the line `EXPLAIN WHAT DID IN THE DESIGN AND DEVELOPMENT` with:
```
Guided by the needs assessment results, the researchers designed SmartSpend as an offline-first Flutter application for Android. A local SQLite database stored all financial records, with optional Firebase Firestore synchronization and Firebase Authentication for signed-in users. Because most respondents tracked expenses through receipts and e-wallet histories, expense input was designed around multiple modalities: natural-language text and voice, receipt OCR, barcode scanning, and batch screenshot import of e-wallet transactions. An LLM-powered assistant, Peso, was integrated to parse these inputs and execute 34 financial actions, and a Financial Health Score was designed to summarize budgeting behavior. The selection of the LLM API, the computation of the Financial Health Score, and the resulting system are presented in the sections that follow.
```

**E20. LLM paragraph.** Find: `Gemini 3.5 Flash-Lite was selected as the primary model because`
Replace: `From the ten candidate models in Table 6, Gemini 3.5 Flash-Lite was selected as the primary model because`

**E21. Delete leftover editor notes.**
- `The behavior of this component when zero category budgets were configured was a known open item pending confirmation against the current build and was not asserted here.`
- `Present Peso as a design feature, not as evidence of behaviour change, and avoid phrases such as "dopamine reinforcement".` (an instruction to Kiro, not manuscript text)
- `Introductory paragraph then table then discussion of the table`

**E22. Figure texts** (checked against the actual screenshots).

*Figure 11.* Find: `The dashed include relationship between the user's interactions and the FHS calculation indicates that logging expenses and setting budgets automatically trigger a recalculation of the score, ensuring it reflects the user's most current financial behavior without requiring manual updates.`
Replace:
```
The dashed include relationship between "View FHS Score" and "Calculate FHS" indicates that viewing the score always triggers a calculation from the user's most recent transactions and budgets, so the score reflects current behavior without manual updates.
```

*Figure 14.* Find: `A management score of 97 out of 100 with a "Consistent Saver" achievement badge is displayed, followed by`
Replace: `A management score of 97 out of 100 with an "Expert Tracker" label is displayed, followed by a "Consistent Saver" card and`

*Figure 15.* Replace the whole paragraph (it currently describes Local AI setup, which is a duplicate of Figure 19) with:
```
Figure 15 presents expense logging through the Peso chat. The user typed "nag-lunch ako 150 pesos," and Peso replied conversationally in Taglish while recording the expense. A summary card confirmed one recorded item (Lunch, ₱150), and the amount was automatically deducted from the Cash on Hand wallet with an Undo option. A banner at the top detected GCash or bank text and offered to paste it for logging. This shows the system parsing and recording a natural-language entry in a single step, without manual form filling.
```

*Figure 17.* Replace the whole paragraph (it currently describes SUS scores) with:
```
Figure 17 presents the Financial Health Score breakdown for the demo account, which showed 64 out of 100 (Fair tier). The screen lists a strength (all nine budgets on track) and a focus area (spending exceeded income), then the four scored components: savings (0/25), overspend control (17/25), budget adherence (25/25), and logging consistency (22/25). Where a component needs work, a short tip explains how to improve it.
```

*Figure 18.* Rename the caption to `Figure 18. Budgets Screen` (the old caption mentions Safe-to-Spend and Savings Goals, which are not shown). Replace the whole paragraph (it currently describes SUS by group) with:
```
Figure 18 presents the Budgets screen. The header summarizes total budgeted (₱13,600), spent (₱8,184), and income (₱6,600) for day 9 of 30, with a warning that total budgets exceed income. Each category card (Food, Transportation, Bills, Entertainment) shows spending against its limit, the amount remaining, and whether spending is under the expected pace. Users can add, edit, transfer, or delete budgets from this screen.
```

*SUS distribution.* The "scores ranging from 35.0 to 92.5" paragraph has no image anywhere in the docx. It is already deleted by the Figure 17 replacement above. Also delete the "SUS Score Distribution (Figure 3.12)" line from the List of Figures.

---

## 7. Chapter III — Objective 3

**E23.**
- Find: `As shown in Tables 3.3 and 3.4,` → Replace: `As shown in Tables 7 and 8,`
- Find: `No formal open-ended Survey data was collected. The study used a structured quantitative survey instrument, and no open-ended or interview data were collected.`
  Replace: `No formal open-ended survey data was collected. The study used a structured quantitative survey instrument only; no interviews were conducted.`

---

## 8. Chapter IV, References, images

**E24. Conclusions.** Delete all existing conclusion paragraphs and paste these four:
```
The needs assessment confirmed that 96.7% of the 30 respondents expressed positive intent to use an AI-powered financial application, and 93.3% already used GCash, validating the study's target population and feature priorities. SmartSpend v3.1.0 was successfully developed with its core planned features implemented. The SUS evaluation yielded a mean score of 61.83 (adjective: "OK"), below the ≥80 target. Therefore, all three objectives of the study were addressed, with the third objective partially achieved.

The first objective was to assess the financial management practices, budgeting challenges, and expense tracking behaviors of parents aged 35 to 55 and young professionals aged 21 to 35. The needs assessment of thirty (30) respondents revealed that 96.7% expressed positive intent to use an AI-powered financial application and 93.3% already used GCash. The first objective was achieved.

The second objective was to design and develop the SmartSpend mobile application with the integration of a suitable LLM API. SmartSpend v3.1.0 was developed as a working Android application with multi-modal expense input, offline-first local storage, 34 AI actions, and a Financial Health Score formally classified as a Prototype Observed Financial Health Indicator. A comparative technical evaluation of ten candidate models from four providers led to the selection of Gemini 3.5 Flash-Lite as the primary model, supported by an eight-model cloud failover chain (Gemini 3.5 Flash-Lite as primary, seven fallbacks). The second objective was achieved.

The third objective was to evaluate the usability of SmartSpend using the System Usability Scale. The evaluation yielded a mean SUS score of 61.83 (SD = 17.58, Median = 55.00) from 30 valid respondents, which was below the pre-established acceptance threshold of 80 and the 68-point average benchmark (Sauro & Lewis, 2016). The third objective was partially achieved.
```

**E25. References.**
1. **Cited but missing:** add Google (2024f). Verify the URL before submitting: `Google. (2024f). Gemini API documentation. https://ai.google.dev/gemini-api/docs`
2. **Wrong author:** the in-text cite is Gubbins, Mazzotta & Rhyne (2021), but the entry says UNSGSA. Change the entry to: `Gubbins, E., Mazzotta, B., & Rhyne, E. (2021). Measuring financial health: Concepts and considerations. UNSGSA. https://www.unsgsa.org`
3. **Never cited (delete or cite):** Roux 2019, Google 2024d, Davis 1989, Groq 2026, Bangor et al. 2008, National Privacy Commission 2012, Creswell & Plano Clark 2011 (if any remain).
4. **Become uncited after E5:** Sloane, Bociek, ZXing, Flutter 4 Fun, The Flutter Authors, Google 2024b, Google 2024e. Search each name; delete the entry if nothing else cites it.

**E26. Images to fix** (baked-in labels and content).
| Image | Problem | Fix |
|---|---|---|
| Fig 1 chart | Title says "Figure 1.1." | Remove from the image title |
| Fig 4 Kanban | Has "Figure X…" and a description box inside the image | Crop them out |
| Fig 5 chart | Title "Figure 3.14", and a footnote about "SUS subgroup analysis" | Re-export without them (keeps 13 / 14 / 3) |
| Fig 21 chart | Title "Figure 3.13." | Re-export without the number |
| Fig 16 receipt | Shows your student number and receipt number | Blur them |
| Fig 14 vs 17 | FHS shows 96 (Excellent) in Fig 14 but 64 (Fair) in Fig 17, both demo data | Retake one, or add a sentence that they were captured at different demo states |
| Fig 12 | Diagram lists 7 sections, but app nav is Home / Analytics / Peso / Tools / Profile | Confirm the other sections sit under Tools and Profile; add one clause saying so |
| Fig 20 | SUS item wording is paraphrased vs Appendix C | Optional: match Appendix C wording |

Final step: **Review → Delete All Comments** in Word (after resolving the threads above).

---

## 9. Option B — only if you insist on 16 + 14

Skip this section if you follow E11–E13 and E18.
1. Table 3: Parents 16, Young Professionals 14, Total 30, with the note `Includes 3 respondents who identified as both parent and young professional, counted with the parent group.` State the real basis for the classification (for example, age bracket from Q1). Do **not** write "primary financial role".
2. Table 5 columns become Parents (n = 16) / Young Professionals (n = 14) / Total (N = 30). Part A: parents 16 (53.3%), YP 14 (46.7%). Part B (parents / YP / total): Receipts 14 (87.5%) / 13 (92.9%) / 27 (90.0%); Mental estimates 9 (56.3%) / 7 (50.0%) / 16 (53.3%); E-wallet history 7 (43.8%) / 6 (42.9%) / 13 (43.3%); Notes app 4 (25.0%) / 5 (35.7%) / 9 (30.0%); Notebook 4 (25.0%) / 3 (21.4%) / 7 (23.3%); Mobile app 1 (6.3%) / 2 (14.3%) / 3 (10.0%). Keep the note's `n = 16` wording.
3. Figure 5 must be regenerated as 16 / 14 (or kept at 13 / 14 / 3 with a footnote).
4. Replace E12's counts with 16 / 14 and the classification sentence from item 1; replace E18's text accordingly.

---

## 10. PPT and script

**PPT:** Slide 12 → `10 candidate models from four providers`. Slide 17 Conclusion 2 → `Gemini 3.5 Flash-Lite (selected from 10 candidate models)`. Every "eight-provider chain" → "eight-model chain". Slide 8 notes: add `Purposive sampling was used for the content validator (Avigail Candevario, PFMe). Random sampling was used for all 30 respondents.` Slide 18 notes: Rec 8 = UI/UX refinement, Rec 9 = formal parsing evaluation (the manuscript gives no "50+ receipts" number, so remove it or add it to Rec 9). Any slide quoting respondent counts must match the table you chose.

**Script:**
- Slide 12 spoken text → `ten candidate models from four providers: Google, Groq, Cerebras, and Mistral`.
- Q6 answer → same wording. Do not claim Anthropic or OpenAI proprietary models (only the open-weight GPT-OSS models were evaluated).
- Any mention of "eight candidate LLM APIs" → `ten candidate models from four providers`.
- The SAY/DON'T SAY table: "quantitative descriptive developmental" belongs in the SAY column, never in DON'T SAY. Final reminders: `Always say "quantitative descriptive developmental"; the study is purely quantitative and no interviews were conducted.`
- Q1 and Q5: the UI/UX redesign is **Recommendation 8**, not 1.
- Any respondent-count mention must match your final choice (13 + 14 + 3, or Option B).

---

## 11. Final verification checklist

- [ ] Research Design: "quantitative descriptive developmental", no qualitative or mixed wording, no Creswell cite
- [ ] Table 3 shows 13 / 14 / 3 = 30, with the validator note; Table 5, Figure 5, text, and PPT/script all agree
- [ ] Table 6 has 10 rows; every mention says "ten candidate models from four providers"; chain says "eight-model"
- [ ] TOC: one TOC only, B = Informed Consent, C = SUS Questionnaire, front-matter order matches the manuscript
- [ ] Figures 11, 14, 15, 17, 18 texts match their images; Figure 18 caption renamed
- [ ] No leftover notes: `EXPLAIN WHAT DID`, `see objective`, `Introductory paragraph...`, Peso/dopamine note, zero-budget note, `Figure #`, "Technical Validation Certificate"
- [ ] `Tables 7 and 8`, `Table 2` in Chapter I, `Figure 4`
- [ ] Technical Background: citations removed, entries shortened, sqflite version corrected
- [ ] References: Google 2024f added, UNSGSA/Gubbins fixed, uncited entries removed
- [ ] Image labels cleaned (E26); student number blurred
- [ ] SUS values unchanged: 61.83, SD 17.58, median 55.00, N = 30, D, "OK", partially achieved
- [ ] All 9 recommendations present
- [ ] Comments resolved and deleted
