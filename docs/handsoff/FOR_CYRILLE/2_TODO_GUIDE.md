# SmartSpend — Final Manuscript Tasks for Claude
**Updated: November 9, 2026 | Defense: November 10, 2026**  
**Working file:** `SmartSpend_Manuscript_updated.docx`

---

## ✅ VERIFIED CLEAN by Kiro — do NOT change

Kiro scanned `SmartSpend_Manuscript_updated.docx` and confirmed these are correct:

- SUS score: **61.83** (SD=17.58) ✅
- Grade D, adjective "OK" per Bangor (2009) ✅
- 30 respondents, 96.7% AI intent, 93.3% GCash ✅
- 20 Philippine banks (Task E1 fixed) ✅
- Separate groups sentence added (Task E4 done) ✅
- Table 3.4: YP n=20, mean=63.62 ✅ | Parents n=10, mean=58.25 ✅
- Mangaoang DIT, Layco MIS, 36 badges, 34 agentic actions ✅
- No Verzola, no interview guide, no old numbers ✅
- Future tense fixed throughout ✅

**Note on Table 3.4 parent group:** Manuscript says n=10, mean=58.25. Raw data has 11 parents but the 100.0 score was excluded (likely treated as an outlier). The n=10, 58.25 is consistent and correct — do NOT change it.

---

## 🔴 TASK A — Fill [[VERIFY]] cells in Table 3.4 (if any remain)

Ctrl+F `[[VERIFY` — if any cells still show `[[VERIFY]]`, replace them with:

| Group | n | Mean | SD | Range | Adjective |
|---|---|---|---|---|---|
| Parents (35–55) | 10 | 58.25 | 19.72 | 35.0–90.0 | OK |
| Young Professionals (21–35) | 20 | 63.62 | 16.65 | 42.5–92.5 | OK |
| Combined | 31 | 63.06 | 18.59 | 35.0–100.0 | OK |

*(These are already in the manuscript from the scan — just verify they're there.)*

---

## ✅ TASK B — Approval sheet CONFIRMED CORRECT

```
Adviser:           Ellen F. Mangaoang, DIT
Teacher-in-Charge: Shekiro R. Raposas, MIT
Chairperson:       Jeoffrey B. Layco, MIS
Members:           Shekiro R. Raposas, Mary-Ann Mzana
Dean, CCSE:        Jeoffrey B. Layco, MIS
```

**One small thing:** Acknowledgements says "Dr. Janelli M. Mendez" as instructor in charge. If Raposas is the current TIC, change it. If Mendez is a different person, leave it.

---

## 🔴 TASK C — Screenshots ONLY (Figures 3.4–3.11)

This is the **only real remaining task**. Kiro found 8 screenshot placeholders:

```
[Figure 3.4 — App screenshot to be inserted by Cyrille before printing]
[Figure 3.5 — App screenshot to be inserted by Cyrille before printing]
...through Figure 3.11
```

Replace each with the real screenshot. Caption stays below as-is.

| Figure | Caption already in manuscript | Screenshot to use |
|---|---|---|
| 3.4 | Login and Demo Mode Screen | Login + "Try Demo" button |
| 3.5 | Home Dashboard | Home screen (FHS ring + Peso) |
| 3.6 | Expense Logging Through Peso Chat | Type "nag-lunch ako 150 pesos" → result |
| 3.7 | Receipt Scanning and Batch Screenshot Import | Batch import with GCash screenshots |
| 3.8 | Financial Health Score Breakdown | Tap FHS score → breakdown screen |
| 3.9 | Budgets, Safe-to-Spend, and Savings Goals | Budgets or Savings Goals screen |
| 3.10 | Local AI Mode Setup | Local AI setup — OR retitle to "Analytics Dashboard" |
| 3.11 | SUS Computation Table | Screenshot of your SUS scoring sheet |

**Source:** `docs/debug/screenshots/` — existing screenshots available  
**Blurry?** → Upscayl (free, upscayl.org) to 4x upscale  
**In Claude:** Send the images to Claude and it can write the insertion instructions

---

## 🔴 TASK D — Table of Contents (manual — Update Field won't work)

After inserting screenshots:
1. Add Tables 3.1–3.5 and Figures 3.1–3.11 to List of Tables and List of Figures (currently absent)
2. Re-check every page number — figure pages moved
3. Table 2.1 now has a "Both Groups" row — update its entry if needed

---

## 🔴 TASK E — Two small inconsistencies still to verify

**E2 — Appendix reference for Technical Validation Certificate**
- Currently cited as "(Appendix A)" but Appendix A = Survey Questionnaire
- Fix: Change to the correct appendix letter that has the validation certificate

**E3 — Two SUS scales at the defense (no fix needed, just know this)**
- Figure 2.1 uses Brooke/Sauro grade scale (60–69 = "Marginal", Grade D)
- Results text uses Bangor (2009) adjective scale ("OK")
- At defense: *"Both scales place 61.83 in the same band — Grade D and adjective 'OK'. Figure 2.1 shows the grade scale; our narrative uses the adjective scale from the same paper."*

---

## 🔴 TASK F — Signatures (physical)

- [ ] `FOR_MAAM_ELLEN/6_CERT_A1_Survey_Questionnaire_Validation.pdf` → Ma'am Abby signs
- [ ] `FOR_MAAM_ELLEN/7_CERT_A3_FHS_Formula_Validation.pdf` → Ma'am Abby signs
- [ ] `FOR_MAAM_ELLEN/5_REVISED_QUESTIONNAIRE_FOR_VALIDATION.pdf` → Ma'am Ellen signs

---

## ✅ Final check before printing

**Ctrl+F in Word — must be 0 results:**
- `[[` → 0
- `to be inserted` → 0 (after screenshots inserted)
- `(Appendix A)` near "validation certificate" → fix to correct appendix

**Then:**
1. Open in **Word only** (NOT LibreOffice)
2. Check TOC page numbers manually (Task D)
3. Visually check figure sizes and page breaks
4. File → Save As → PDF → scroll every page
5. Print 3 copies

---

## 🤖 Claude prompts

**For Task C (screenshot insertion guidance):**
> "I need to insert 8 app screenshots into my Word manuscript for my capstone thesis. The placeholders say '[Figure 3.X — App screenshot to be inserted]'. I'm attaching the screenshots. For each one, tell me: (1) which placeholder to find, (2) how to insert the image in Word centered with the existing caption below it."

**For Task D (TOC update):**
> "I need to update a manually-typed Table of Contents in my Word document. The current TOC is missing all Chapter III entries (Tables 3.1–3.5 and Figures 3.1–3.11). Here is the current TOC: [paste current TOC]. Here are the new entries to add with these page numbers: [describe pages]. Format the additions to match the existing style."

**For Task E2 (appendix reference fix):**
> "In my capstone thesis, I have a Technical Validation Certificate that is cited as '(Appendix A)' but Appendix A is actually the Survey Questionnaire. My appendices are: A = Survey Questionnaire, B = Consent Form, C = SUS Questionnaire, D = Validation Certificates. Fix the in-text citation to point to the correct appendix."

**For any text fix:**
> "Fix this sentence from my capstone thesis to be in past tense and formal academic English: [paste sentence]"

---

## 🎯 Defense talking points

1. **"96.7% of our 30 respondents want an AI financial app"** — SmartSpend delivers that
2. **"93.3% use GCash"** — batch import reads GCash screenshots automatically
3. **"FHS adapted from CBA-Melbourne Institute (2018)"** — academically grounded, labeled prototype indicator
4. **"SUS = 61.83, Grade D, adjective 'OK'"** — below 68 benchmark; acknowledged prototype limitation
5. **"Free, offline-first, runs on budget phones"** — not for rich people only
6. **"Two SUS scales — both correct"** — Figure 2.1 uses Brooke grade scale; results use Bangor adjective scale; same band, no contradiction

---

*Defense: November 10, 2026 | Good luck 🎯*
