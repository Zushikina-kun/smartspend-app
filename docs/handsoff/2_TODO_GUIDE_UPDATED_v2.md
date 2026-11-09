# SmartSpend: Final Manuscript Tasks (for groupmates)
**Updated: November 9, 2026 | Defense: November 10, 2026**
**Working file:** `SmartSpend_Manuscript_updated_v2.docx` (use this one, not the older copies)

Open and edit in **Microsoft Word only**, not LibreOffice or Google Docs.

---

## Already done in v2 (don't redo)

- Conclusions now say the score range is **35.0 to 92.5** (matches Table 3.4).
- "Content Validation Certificate" in Chapter II now says **(Appendix A)**. The certificate is inside Appendix A.
- Checked and consistent: SUS 61.83 (SD 17.58), 30 respondents, 96.7% AI intent, 93.3% GCash, 20 banks, 36 badges, 34 agentic actions, Table 3.4 rows (Parents n=10 / 58.25, Young Professionals n=20 / 63.62, Combined n=30 / 61.83).

---

## TASK 1: Decide about the 100.0 parent score (MUST do first, whoever did the SUS analysis)

**The problem:** the numbers in the manuscript (61.83, N=30) only work if one parent's SUS score of **100.0** is left out.

| Version | N | Mean | SD | Range |
|---|---|---|---|---|
| Manuscript now (100.0 left out) | 30 | 61.83 | 17.58 | 35.0–92.5 |
| All screened respondents | 31 | 63.06 | 18.59 | 35.0–100.0 |

The manuscript says the 6 removed responses were "excluded for insufficient app usage time". But only **5** failed the 10-minute screening question (36 − 31). The sixth is the 100.0, removed for a different reason. A panelist checking the raw data will notice.

**What to do:**
1. Open `03_SUS_Responses_FINAL_N36.xlsx` and find that respondent. Confirm it is the 100.0 parent.
2. Write down the actual reason it was left out (e.g., straight-lining, duplicate entry, did not finish).
3. **If there is a valid reason:** add one sentence saying so in Chapter III (Evaluation section, near "The remaining 6 were excluded") and fix the Chapter IV sentence "6 excluded for insufficient app usage time" to say 5 were excluded for insufficient usage time and 1 for [reason].
4. **If there is no valid reason:** include all 31 and update every place that shows the numbers: Abstract, Chapter III text, Tables 3.3 and 3.4, Chapter IV conclusions. Use N=31, mean 63.06, SD 18.59, range 35.0–100.0, parents n=11 (mean 62.05, SD 22.55, range 35.0–100.0). Also fix "N=30 valid respondents screened from 36" wherever it appears. Median is 55.0 in both versions.
5. Tell everyone in the GC which option you chose so the slides and defense answers match.

Defense answer if asked: be ready to say exactly which response was removed and why.

---

## TASK 2: Insert screenshots, Figures 3.4–3.11 (Cyrille)

Search for `to be inserted` in Word. There are 8 placeholders. Replace each with the real screenshot, centered, with the existing caption staying below it.

| Figure | Caption (already in the manuscript) | Screenshot to use |
|---|---|---|
| 3.4 | Login and Demo Mode Screen | Login screen with "Try Demo" button |
| 3.5 | Home Dashboard | Home screen (FHS ring + Peso) |
| 3.6 | Expense Logging Through Peso Chat | Type "nag-lunch ako 150 pesos", then the result |
| 3.7 | Receipt Scanning and Batch Screenshot Import | Batch import with GCash screenshots |
| 3.8 | Financial Health Score Breakdown | Tap the FHS score, then the breakdown screen |
| 3.9 | Budgets, Safe-to-Spend, and Savings Goals | Budgets or Savings Goals screen |
| 3.10 | Local AI Mode Setup | Local AI setup screen (or retitle the caption, e.g. "Analytics Dashboard", to match the screenshot you use) |
| 3.11 | SUS Computation Table | Screenshot of the SUS scoring sheet |

How to insert in Word:
1. Click the placeholder line, select it, and delete the text (keep the empty paragraph).
2. Insert > Pictures > This Device, then pick the file.
3. Click the picture, set Wrap Text to **In Line with Text**, and center it (Ctrl+E).
4. Keep the width within the margins (about 6 inches max for phone screenshots, narrower is fine).
5. Put the cursor on the picture's paragraph and turn on Paragraph > "Keep with next" so the picture and caption stay on the same page.

Source images: `docs/debug/screenshots/`. If blurry, upscale with Upscayl (upscayl.org, 4x).

---

## TASK 3: Table of Contents / List of Tables / List of Figures (Cyrille, do AFTER Task 2)

The TOC is typed by hand, so Update Field will not work.

1. Add the missing entries. The full list with exact titles is in `TOC_ENTRIES_TO_ADD.md`. Missing now: Chapter III, Tables 2.2 and 3.1–3.5, Figures 3.1–3.11.
2. Copy the formatting of an existing entry (dot leader, right-aligned page number).
3. After inserting screenshots, find each heading, table, and figure in the document and write down its real page number. Then re-check **every** existing page number, since pages have shifted.
4. Check that Chapter IV and the Appendix/CV page numbers are correct.

---

## TASK 4: Small text decisions (anyone, ~10 min)

- [ ] **Acknowledgements:** it thanks "Dr. Janelli M. Mendez" as instructor in charge, but the approval sheet lists Shekiro R. Raposas as teacher-in-charge. Confirm who the instructor in charge is and make both pages agree.
- [ ] **"Acceptable" wording:** Chapter IV Conclusions say 61.83 is "acceptable for a prototype system", but Table 3.3 says "Acceptable: No". Pick one wording and make them match (suggested: "below the target, acknowledged as a prototype limitation").
- [ ] **Technical Validation Certificate:** Chapter II mentions it, but no appendix contains it (Appendix A = Survey Questionnaire + Content Validation Certificate, B = Consent Form, C = SUS Questionnaire). Either add an Appendix D with the signed certificate (and list it in the TOC), or remove the mention. Decide as a group.

---

## TASK 5: Signatures (physical, today)

- [ ] `FOR_MAAM_ELLEN/6_CERT_A1_Survey_Questionnaire_Validation.pdf` → Ma'am Abby signs
- [ ] `FOR_MAAM_ELLEN/7_CERT_A3_FHS_Formula_Validation.pdf` → Ma'am Abby signs
- [ ] `FOR_MAAM_ELLEN/5_REVISED_QUESTIONNAIRE_FOR_VALIDATION.pdf` → Ma'am Ellen signs

---

## Final check before printing

Ctrl+F in Word, each must be 0 results:
- `[[` → 0
- `to be inserted` → 0
- `VERIFY` → 0

Then:
1. Re-check TOC page numbers (Task 3).
2. Scroll the whole document: figure sizes, page breaks, no picture split from its caption.
3. File > Save As > PDF and scroll every page of the PDF.
4. Print 3 copies.

---

## Defense notes

1. **96.7% of our 30 respondents** want an AI financial app.
2. **93.3% use GCash**, and batch import reads GCash screenshots.
3. **FHS** is adapted from CBA-Melbourne Institute (2018) and labeled a prototype indicator.
4. **SUS = 61.83, Grade D, adjective "OK"** (use whatever Task 1 ends up with). It is below the 68 benchmark and the 80 target, and we acknowledge this as a prototype limitation.
5. **Two SUS scales:** Figure 2.1 uses the grade scale, and the results use the Bangor (2009) adjective scale. Both put the score in the same band (Grade D, "OK").
6. **Free, offline-first, runs on budget phones.**
7. **Be ready to explain** how many responses were excluded and why (Task 1).

*Defense: November 10, 2026. Good luck.*
