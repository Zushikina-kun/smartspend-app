# SmartSpend — Final Manuscript Tasks for Claude
**Updated: November 9, 2026 | Defense: November 10, 2026**  
**Working file:** `SmartSpend_Manuscript_updated.docx` (diagram PNGs also in `figures/`)

---

## ✅ ALREADY DONE — do NOT redo these

- Table 3.1 added (demographics + expense tracking methods, frequency and %)
- Table 3.3 filled: Mean = 61.83 | Grade D | Adjective = OK | Above 68 = No
- Table 3.5 filled: modalities = "Not measured"; Overall = 91.2% precision, 88.5% recall (preliminary developer testing)
- Figures 3.1 (flowchart), 3.2 (use case), 3.3 (navigation map) inserted with captions
- Future tense fixed in Chapter II methodology (including "will involve"), abstract updated with SUS result, "Data are being gathered" fixed
- Table 2.1 and Chapter II text updated to actual sample: 13 parents, 14 young professionals, 3 both
- Interviews removed everywhere (study was survey-only): Objective 1, Ch. II, Table 2.2
- Chapter I Technical Background converted to present tense
- Chapter IV fixed: v3.1.2 → v3.1.0, Grade C → D, Median 52.50 → 55.00
- Table 3.2 note: "TBD" → "Not measured"
- "Third objective achieved" sentence fixed at end of SUS section
- Approval sheet names confirmed correct (Task B)

---

## 🔴 TASK A — Verify SUS numbers (10 min — needs the raw SUS sheet)

**What to do:** The group split in Table 3.4 (Parents vs Young Professionals) is marked `[[VERIFY]]`. The old numbers (20 YP / 10 parents) conflict with the needs-survey split (13/14/3) so do NOT reuse those.

1. Open the SUS response sheet: `docs/handsoff/survey_data/03_SUS_Responses_FINAL_N36.xlsx`
2. Filter by respondent type (column: "Which best describes you?")
3. For each group (Parents and Young Professionals), compute: n, mean SUS, SD, min, max
4. Type the real numbers into Table 3.4 replacing `[[VERIFY]]` cells

**Paste the per-respondent scores to Claude and use this prompt:**
> "Here are SUS scores for SmartSpend respondents grouped by type. Compute n, mean, SD, median, min, max for each group:
> Parents: [paste scores]
> Young Professionals: [paste scores]
> Format as a table row."

**Also check the median:**
- Chapter III says 55.00 and Chapter IV was updated to match — verify this is the true median from the raw data
- SUS mean = 61.83 is confirmed correct

**Grade D is correct:** 61.83 falls in the 60–69 band on the Bangor (2009) grade scale → Grade D, adjective "OK". Keep it.

---

## ✅ TASK B — Approval sheet — CONFIRMED, no change needed

The approval sheet in the manuscript is correct as it stands:
```
Adviser:           Ellen F. Mangaoang, DIT
Teacher-in-Charge: Shekiro R. Raposas, MIT
Chairperson:       Jeoffrey B. Layco, MIS
Members:           Shekiro R. Raposas, Mary-Ann Mzana
Dean, CCSE:        Jeoffrey B. Layco, MIS
```
(The old Reyes / Carbonell names are obsolete — ignore them.)

**One small thing left:** the Acknowledgement page thanks "Dr. Janelli M. Mendez" as the instructor in charge, while the approval sheet lists Raposas as Teacher-in-Charge. If Mendez is a different, real person (e.g., a different course instructor), leave it. If it is a leftover, change it to Raposas.

---

## 🔴 TASK C — Screenshots (Figures 3.4–3.11)

One placeholder per figure. Replace each with the real screenshot, centered, caption stays below.

| Figure | Caption in manuscript | What to capture |
|---|---|---|
| 3.4 | Login and Demo Mode Screen | Login screen + "Try Demo" button |
| 3.5 | Home Dashboard | Home screen (FHS ring + Peso) |
| 3.6 | Expense Logging Through Peso Chat | Type "nag-lunch ako 150 pesos" → show logged result |
| 3.7 | Receipt Scanning and Batch Screenshot Import | Batch import screen with GCash screenshots loaded |
| 3.8 | Financial Health Score Breakdown | Tap the FHS score → breakdown screen |
| 3.9 | Budgets, Safe-to-Spend, and Savings Goals | Budgets or Savings Goals screen |
| 3.10 | Local AI Mode Setup | Local AI setup screen — OR retitle caption to "Analytics Dashboard" if using analytics screenshot |
| 3.11 | SUS Computation Table | Screenshot of your SUS scoring sheet |

**Source:** `docs/debug/screenshots/` folder — use existing screenshots if possible  
**Blurry?** → Use **Upscayl** (free, upscayl.org) to 4x upscale before inserting  
**Note:** If you send the images to Claude, Claude can guide the insertion.

---

## 🔴 TASK D — Table of Contents (manually typed — Update Field will NOT work)

The TOC, List of Tables, and List of Figures are typed by hand (not Word fields). After inserting screenshots:

1. **Add missing entries for Chapter III:** Tables 3.1–3.5 and Figures 3.1–3.11 are currently absent — add them to the List of Tables and List of Figures
2. **Re-check every page number** against the final layout — figure pages in Chapter III will have moved
3. **Table 2.1 note:** it now has a "Both Groups" row — update the List of Tables entry if needed

---

## 🔴 TASK E — Inconsistencies that need your decision

These need a human call — Claude or Kiro cannot decide for you:

1. **Banks/e-wallets count:** Chapter II says "30+ Philippine banks and e-wallets" but Chapter III says "20 banks + 5 e-wallets" — pick one and fix the other
2. **Appendix reference:** Technical Validation Certificate is cited as "(Appendix A)" but Appendix A is the survey questionnaire — fix the reference to the correct appendix letter
3. **Two SUS scales:** Figure 2.1 labels 60–69 as "Marginal" (Brooke grade scale) but results use "OK" (Bangor adjective scale). Both are correct but different systems. At the defense: *"Figure 2.1 shows the Brooke/Sauro grade scale; our results section uses the Bangor (2009) adjective scale. Both place 61.83 in the same band."*
4. **Same group or different?** Chapter III opening still implies the 30 needs-survey respondents and the 30 SUS respondents are the same group. If they are different people, add a sentence clarifying this (see Task A)

---

## 🔴 TASK F — Signatures (physical — bring to Ma'am Abby and Ma'am Ellen)

- [ ] `FOR_MAAM_ELLEN/6_CERT_A1_Survey_Questionnaire_Validation.pdf` → Ma'am Abby signs
- [ ] `FOR_MAAM_ELLEN/7_CERT_A3_FHS_Formula_Validation.pdf` → Ma'am Abby signs
- [ ] `FOR_MAAM_ELLEN/5_REVISED_QUESTIONNAIRE_FOR_VALIDATION.pdf` → Ma'am Ellen signs

---

## ✅ Final check before printing

**Ctrl+F in Word — must be 0 results:**
- `[[` → 0 (currently the [[VERIFY]] cells in Table 3.4 — fill those first)
- `to be inserted` → 0 (screenshot placeholders)
- `will involve` → 0 (already fixed)

**Then:**
1. Open in **Word** (NOT LibreOffice — LibreOffice cannot render this file's layout reliably)
2. Check TOC page numbers by hand (Task D)
3. Check figure sizes and page breaks visually
4. File → Save As → PDF
5. Scroll through every page in the PDF before printing
6. **Print 3 copies**

---

## 🤖 Claude prompts for remaining tasks

**For Task A (SUS group stats):**
> "Here are per-respondent SUS scores for SmartSpend. Group A (Parents): [paste scores]. Group B (Young Professionals): [paste scores]. Compute for each group: n, mean, SD, median, min, max. Format as a table."

**For Task C (screenshot captions):**
> "I need APA-style figure captions for these SmartSpend app screenshots. Format: 'Figure 3.X. [Descriptive title]. Adapted from the SmartSpend mobile application (Lucid Frame, 2026).' Figures: 3.4 Login screen, 3.5 Home dashboard, 3.6 AI chat logging, 3.7 Batch import, 3.8 FHS breakdown, 3.9 Budgets, 3.10 Local AI, 3.11 SUS scoring sheet."

**For Task E (inconsistency fixes):**
> "I have two conflicting numbers in my capstone thesis: Chapter II says '30+ Philippine banks and e-wallets' but Chapter III says '20 banks + 5 e-wallets = 25 total'. The app currently has [insert real number]. Help me write a consistent sentence for both chapters."

**For any paragraph writing:**
> "I need a 2-sentence paragraph in formal academic English for my capstone thesis. Topic: [describe what the paragraph should say]. It should be in past tense since this is in the Results section."

---

## 🎯 Defense talking points (November 10, 2026)

1. **"96.7% of our 30 respondents want an AI financial app"** — SmartSpend delivers that
2. **"93.3% use GCash"** — batch import reads GCash screenshots, zero typing needed
3. **"FHS adapted from CBA-Melbourne Institute (2018)"** — academically grounded, labeled a prototype indicator
4. **"SUS = 61.83, adjective 'OK' per Bangor 2009"** — below 68 benchmark; acknowledged prototype limitation
5. **"Free, offline-first, runs on budget phones"** — not for rich people only
6. **"OCR numbers are preliminary developer testing"** — not a formal evaluation; stated as such in the manuscript

---

*Defense: November 10, 2026*
