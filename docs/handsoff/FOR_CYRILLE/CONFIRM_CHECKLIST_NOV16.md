# SmartSpend Defense Prep: Confirm Checklist (Nov 16, 2026)

Items below need raw data, git log, or code verification before the defense. CRITICAL items affect numbers the panel will verify directly. Work through CRITICAL items first; complete them at least two days before the defense so there is time to update the manuscript, script, and reviewer if any number changes.

---

## CRITICAL

### [A1] Figure 3.12 bar heights vs SUS statistics
**What to check:** Export the 30 valid SUS responses from Google Forms (the raw answer sheet, not the summary). Compute each respondent's SUS score using the formula: for each odd-numbered item subtract 1; for each even-numbered item subtract the response from 5; sum all 10 contributions and multiply by 2.5. Save as `scores.csv` with columns `id, group, score` (group = Parent or YoungProf).

**Where to find it:** Google Forms → Responses → Download as CSV. The form is linked in Appendix B/C of the manuscript.

**What to do with the answer:**
- Run `regen_sus_charts.py scores.csv` (from `manuscript_fix_assets/`). It prints mean, SD, median, min, max, and group stats.
- If the printed numbers exactly match the protected values (mean 61.83, SD 17.58, median 55.0, range 35.0–92.5, groups 58.25/63.62), regenerate Fig 3.12 and Fig 3.13 images only. No text changes needed.
- If ANY number differs from the protected values, **stop** and discuss with the full team before changing anything. Do not defend a number you cannot reproduce from the raw file.

---

### [A2] Appendix SUS Individual Scores missing
**What to check:** The TOC lists "Appendix C: SUS Individual Scores" but the manuscript body has no per-respondent table. Figure 3.11 shows only one sample respondent (score 75.0).

**Where to find it:** The same Google Form export from A1.

**What to do with the answer:** Build a 30-row table in Excel: Respondent | Group | Q1–Q10 raw answers | Sum of contributions | Score. Paste into the manuscript as Appendix F. Update the Fig 3.11 caption to: "Sample SUS Computation for One Respondent (individual scores for all 30 respondents are in Appendix F)." Update the TOC/appendix list accordingly. When done, update the Q36 answer in the reviewer: "Appendix F lists all 30 respondents."

---

### [A6] Which build did the 30 SUS respondents evaluate?
**What to check:** The manuscript says the evaluated build was v3.1.0 and that Peso and badges were part of that version. The old defense script (now replaced) said Peso and badges were added in v3.1.1–v3.1.2 after the evaluation. These cannot both be true.

**Where to find it:** Git log (`git log --oneline --tags`), the Google Form submission date range, and the Play Store / APK release notes.

**What to do with the answer:**
- **If Peso and badges were IN v3.1.0 (the evaluated build):** Update the limitation sentence to: "Peso and the achievement badges were part of the evaluated build, but the study did not isolate their effect on usability or behavior." The script Q9 answer becomes: "The evaluated build already included Peso and the badges, but we did not isolate their effect." Figures 3.4–3.6, which show Peso, correctly depict the evaluated build.
- **If Peso and badges were added AFTER the evaluation:** Keep the manuscript sentence that says they were added after, then also note in the defense: "Figures 3.4–3.6 show the current build (which includes Peso); the 30 respondents used v3.1.0 without Peso and badges." Update the reviewer Q42 answer accordingly.
- Use the SAME answer in the manuscript, the script, and the reviewer. Inconsistency here is an immediate panel flag.

---

### [A9] Objective 1 challenges data
**What to check:** Chapter III Objective 1 mentions that the most prevalent challenges were rising prices, unexpected medical expenses, and family responsibilities — but provides no counts or percentages. A panel will ask for exact numbers.

**Where to find it:** Google Form export, question 6 (budgeting challenges). Also tabulate Q4 (budget frequency), Q5 (savings frequency), and Q12 (definitely vs probably use an AI app).

**What to do with the answer:** Add a Table 3.1b (or update the existing Objective 1 discussion paragraph) with counts and percentages per challenge. Update slide 8 and the reviewer Q4 answer with the exact figures. The paste-ready paragraph is in Section A9 of `1_MANUSCRIPT_FIX_GUIDE.md`; fill in the brackets from the export.

---

## INFORMATIONAL

### [A8] Abstract vs Ch IV recommendations count
**What to check:** The abstract now reads "eight recommendations" after the fix. Verify that Chapter IV lists exactly 8 numbered recommendations to match.

**Where to find it:** `1_MAIN_MANUSCRIPT_FINAL.docx`, Chapter IV Recommendations section.

**What to do:** Count the recommendations in Ch IV. If there are not exactly 8, copy the 8-item list from Section A8 of `1_MANUSCRIPT_FIX_GUIDE.md` (or from Section A8 in `RECONCILE_PLAN.md`) and paste it into Ch IV, replacing the current list.

---

### [B9] Fig 3.7 caption vs image content
**What to check:** The fix guide says Fig 3.7 may expose real names (mobile numbers or names visible in the OCR preview of a receipt screenshot).

**Where to find it:** Open `1_MAIN_MANUSCRIPT_FINAL.docx` and inspect Figure 3.7 visually.

**What to do:** If real names or numbers are visible in the receipt OCR preview, replace the image with the pixelated version from `manuscript_fix_assets/Fig_3_7a_Receipt_review_names_pixelated.jpg`. If the batch import screenshot is a separate image (3.7b), also replace it with `manuscript_fix_assets/Fig_3_7b_Batch_screenshot_import.jpg`. If no real names are visible, no change needed.

---

### [B11] Fig 3.5 vs 3.8 score discrepancy — "Management Score"
**What to check:** Figure 3.5 shows a "Management Score 97/100 (Expert Tracker)" label that does not appear anywhere in the manuscript text. The score in Fig 3.5 (96) differs from Fig 3.8 (64) — the reconciliation plan says both are correct (Demo Mode at different data states) and a one-sentence note was added under Fig 3.8. But "Management Score" still needs an explanation.

**Where to find it:** Check the Flutter codebase for a `ManagementScore` or similar widget/model. Search for "Expert Tracker" or "Management Score" in the codebase.

**What to do:** If "Management Score" is a separate metric from the Financial Health Score, add one sentence defining it in the manuscript near Fig 3.5. If it is a UI label for a data-tier badge (e.g., a tier shown in Demo Mode), crop it from Fig 3.5 or add a one-sentence footnote: "The 'Expert Tracker' label in Figure 3.5 reflects the Demo Mode data tier, not a separately scored metric." Prepare a one-sentence spoken answer for the panel: "That label is [your explanation]."

---

### [B12] Fig 3.1 flowchart label
**What to check:** The fix guide says the Fig 3.1 decision diamond may read "Local-only mode on?" when it should read "Local AI server reachable, or Local-only on?"

**Where to find it:** Open `1_MAIN_MANUSCRIPT_FINAL.docx` and inspect Figure 3.1 visually.

**What to do:** If the diamond reads "Local-only mode on?", redraw or replace the flowchart image with one that reads "Local AI server reachable, or Local-only on?" This requires image editing (Figma, draw.io, etc.), not a text find/replace. If it already reads correctly, no change needed.

---

### [B19] App facts needing code verification
**What to check:** Slide 9 and the manuscript (after fix B19) state: 34 AI actions, 7 input modalities, 40+ screenshot platforms, 26-table SQLite database, 45 screens, 36 badges, 9 AI providers, 57 currencies, ~47.5 MB.

**Where to find it:** Flutter codebase — count screens in the navigation tree; count badges in the badge definitions file; count currencies in the currency list file; check the SQLite schema for table count; check the AI provider config for provider count; build the APK and check the file size.

**What to do:** If any number differs from what the manuscript or script states, update the manuscript (the Ch III Obj 2 paragraph), Slide 9 of the deck, and the reviewer Numbers to Know table. Do not defend a number you cannot verify.

---

### [B21] Parsing test set size (n=?)
**What to check:** The manuscript and script say parsing accuracy is 91.2% precision and 88.5% recall from "preliminary developer testing." The panel will ask how many test items this covers.

**Where to find it:** The internal test log or spreadsheet where the developer recorded parsing results (the receipt images or text samples tested, and whether the extracted data was correct). Check the codebase or development notes.

**What to do:** Note the exact number of test items (n). Add "(n = [number])" after "91.2% precision and 88.5% recall" in the manuscript Table 3.5 discussion and in the reviewer Q22 answer. If n is very small (fewer than 10), say so honestly: "Tested against [n] receipts in a developer run; Recommendation 2 is a formal evaluation with 50+ standardized receipts."

---

### [C] Raposas title: Mr. or Engr.?
**What to check:** The manuscript uses "Mr. Shekiro R. Raposas." The ORDINEX deck uses "Engr." Confirm his preferred title.

**Where to find it:** Ask Raposas directly, or check his official faculty profile or approval sheet signature.

**What to do:** Use only the confirmed title everywhere: manuscript title page, panel listing in the script, panel listing in the reviewer. The fixed script now reads "Mr. Shekiro R. Raposas, MTS, MIS." If "Engr." is correct, do a find/replace for "Mr. Shekiro" → "Engr. Shekiro" in both the manuscript and the script.

---

### [C] sqflite schema version
**What to check:** The fix script replaced "sqflite package (version 11)" with "sqflite package (database schema version 14)" in two places in the manuscript. Confirm that schema version 14 is indeed the current version in the codebase.

**Where to find it:** Flutter codebase — search for `version:` in the SQLite database helper file (likely `database_helper.dart` or similar). The schema version is set when the database is opened.

**What to do:** If the current schema version is not 14, update the manuscript text to match the actual version number.

---

### [C] Brix email / validator surname conflict
**What to check:** Brix's CV lists `brix.arquisal@lorma.edu`. The validator is Avigail Candevario, PFMe. If the Arquisal surname on the email is Brix's real surname, the panel may ask about independence from the validator (now confirmed as Candevario, so this is less of a concern, but prepare an answer).

**Where to find it:** Confirm with Brix whether the email surname is correct or a typo/alias.

**What to do:** If it is a typo in the CV, correct it. Prepare a one-sentence answer: "My email uses a different name; Ms. Candevario is unrelated to me."

---

### [C] Fig 1.2 and Fig 2.2 baked-in captions
**What to check:** The fix guide says Figures 1.2 and 2.2 may have "Figure 1." or "Figure X." text baked into the image (not as a Word caption below the image).

**Where to find it:** Open `1_MAIN_MANUSCRIPT_FINAL.docx` and inspect Figures 1.2 and 2.2 visually.

**What to do:** If captions are baked into the image, replace with the clean versions: `manuscript_fix_assets/Fig_1_2_IPO_no_baked_caption.png` and `manuscript_fix_assets/Fig_2_2_Kanban_no_baked_caption.png`. If not baked in, no change needed.

---

*After completing each CRITICAL item: update the manuscript, the defense script (4_DEFENSE_SCRIPT_FINAL.md), and the reviewer (5_DEFENSE_REVIEWER_NOV16.md) so all three files are consistent. Right-click each TOC / List of Tables / List of Figures in Word → Update Field → Update entire table.*
