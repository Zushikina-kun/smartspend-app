# SmartSpend — Final Manuscript Tasks for Claude
**Updated: November 9, 2026 | Defense: November 10, 2026**  
**Working file:** `SmartSpend_Manuscript_updated.docx`

---

## ✅ ALREADY DONE — do NOT redo

- Table 3.1, 3.3, 3.5 filled with real data
- Figures 3.1–3.3 (diagrams) inserted
- Future tense fixed throughout (including "will involve")
- Sample split corrected: 13 parents, 14 YP, 3 both
- Interviews removed everywhere
- Chapter I Technical Background → present tense
- Chapter IV: v3.1.2→v3.1.0, Grade C→D, Median 52.50→55.00
- Table 3.2 TBD → "Not measured"
- Approval sheet confirmed correct (Task B done)
- Table 3.4 filled, banks count, appendix reference, separate-groups sentences (Tasks A and E done)

---

## ✅ TASK A — Table 3.4 DONE (filled by Claude)

Important correction to Kiro's note: the manuscript's N=30 (mean 61.83, SD 17.58, median 55.00, range 35.0–92.5) is the raw 31 **minus the parent who scored 100**. Removing that one score reproduces every manuscript number exactly, so Table 3.4 uses N=30, not 31:

| Group | n | Mean | SD | Range | Adjective |
|---|---|---|---|---|---|
| Parents (35–55) | 10 | 58.25 | 19.72 | 35.0–90.0 | OK |
| Young Professionals (21–35) | 20 | 63.62 | 16.65 | 42.5–92.5 | OK |
| Combined | 30 | 61.83 | 17.58 | 35.0–92.5 | OK |

**One thing to confirm (not a typing task):** why was the 31st respondent (score 100) excluded? The manuscript says 36 attempted, 30 passed the 10-minute screening, 6 excluded. The raw sheet has 31 screened. Be ready to answer this at the defense (e.g., "failed the usage-time screen" or "invalid/duplicate entry"). If that respondent was actually valid, ALL SUS numbers in the manuscript would change, so do not use N=31 anywhere.

Grade D and median 55.00 are correct and consistent in Chapters III and IV.

---

## ✅ TASK B — Approval sheet CONFIRMED CORRECT

Current approval sheet is correct:
```
Adviser:           Ellen F. Mangaoang, DIT
Teacher-in-Charge: Shekiro R. Raposas, MIT
Chairperson:       Jeoffrey B. Layco, MIS
Members:           Shekiro R. Raposas, Mary-Ann Mzana
Dean, CCSE:        Jeoffrey B. Layco, MIS
```

One small thing: Acknowledgements says "Dr. Janelli M. Mendez" as instructor in charge. If Mendez was a previous TIC and Raposas is current, change it to Raposas. If Mendez is a different person, leave it. Ask your adviser.

---

## 🔴 TASK C — Screenshots (Figures 3.4–3.11)

Replace each placeholder with the real screenshot. Screenshots are in `docs/debug/screenshots/`.

| Figure | Caption | What to use |
|---|---|---|
| 3.4 | Login and Demo Mode Screen | Login + "Try Demo" button |
| 3.5 | Home Dashboard | Home screen (FHS ring + Peso) |
| 3.6 | Expense Logging Through Peso Chat | "nag-lunch ako 150 pesos" → result |
| 3.7 | Receipt Scanning and Batch Screenshot Import | Batch import with GCash screenshots |
| 3.8 | Financial Health Score Breakdown | Tap FHS score → breakdown |
| 3.9 | Budgets, Safe-to-Spend, and Savings Goals | Budgets or Savings Goals screen |
| 3.10 | Local AI Mode Setup | Local AI setup — OR retitle to "Analytics Dashboard" |
| 3.11 | SUS Computation Table | Screenshot of your SUS scoring sheet |

Caption format: `Figure 3.X. [Title]. Source: Authors' own development.`  
Blurry? → **Upscayl** (free, upscayl.org) to upscale 4x before inserting.

---

## 🔴 TASK D — Table of Contents (typed by hand — Update Field won't work)

After inserting screenshots:
1. Add missing entries for Tables 3.1–3.5 and Figures 3.1–3.11 (currently absent)
2. Re-check every page number manually — figure pages moved
3. Table 2.1 now has a "Both Groups" row — update entry if needed

---

## ✅ TASK E — Inconsistencies (all fixed by Claude)

- **E1 Banks:** Chapter II now says "20 Philippine banks and 5 digital banks, plus e-wallets"; Chapter III's spec line changed from "20 banks + 5 e-wallets" to "20 banks + 5 digital banks, plus e-wallets" to match the README.
- **E2 Appendix reference:** the wrong "(Appendix A)" after Technical Validation Certificate was removed (no appendix holds the certificates).
- **E3 Two SUS scales:** no change needed. Defense line: *"Figure 2.1 is the Brooke/Sauro grade scale; our narrative uses the Bangor (2009) adjective scale. Both place 61.83 in the same band, Grade D and 'OK', so there is no contradiction."*
- **E4 Separate groups:** added to Chapter III (SUS section) and Chapter II (Population). Worded without a SUS count of 31, because the SUS sample is N=30.

---

## 🔴 TASK F — Signatures (physical)

- [ ] `FOR_MAAM_ELLEN/6_CERT_A1_Survey_Questionnaire_Validation.pdf` → Ma'am Abby signs
- [ ] `FOR_MAAM_ELLEN/7_CERT_A3_FHS_Formula_Validation.pdf` → Ma'am Abby signs
- [ ] `FOR_MAAM_ELLEN/5_REVISED_QUESTIONNAIRE_FOR_VALIDATION.pdf` → Ma'am Ellen signs

---

## ✅ Final check before printing

**Ctrl+F in Word — must be 0 results:**
- `[[` → 0 (already 0)
- `to be inserted` → 0 (screenshots inserted)
- `30+ Philippine banks` → 0 (already 0)

**Then:**
1. Open in **Word** only (NOT LibreOffice)
2. Check TOC page numbers by hand (Task D)
3. Check figure sizes and page breaks
4. File → Save As → PDF → scroll every page
5. Print 3 copies

---

## 🤖 Claude prompts — copy-paste ready

### For Task A (if you want Claude to double-check the group stats)
> "Here are SUS scores for my capstone study respondents. Parents (n=11): 100, 90, 87.5, 77.5, 55, 52.5, 50, 50, 47.5, 37.5, 35. Young Professionals (n=20): 92.5, 92.5, 85, 85, 80, 80, 72.5, 62.5, 62.5, 60, 57.5, 55, 55, 50, 50, 50, 47.5, 47.5, 45, 42.5. "

### For Task C (figure captions)
> "Write APA 7th edition figure captions for these SmartSpend app screenshots: Figure 3.4 = Login screen with Demo Mode button, Figure 3.5 = Home dashboard with FHS ring and Peso mascot, Figure 3.6 = AI chat logging an expense in Taglish, Figure 3.7 = Batch screenshot import screen, Figure 3.8 = Financial Health Score breakdown screen, Figure 3.9 = Budgets and Savings Goals screen, Figure 3.10 = Local AI Mode setup screen, Figure 3.11 = SUS scoring computation table. Format: 'Figure 3.X. [Title]. Source: Authors' own development.'"

### For Task E1 (banks fix)
> "I need to fix an inconsistency in my capstone thesis about SmartSpend (a Filipino personal finance app). Chapter II says '30+ Philippine banks and e-wallets' but Chapter III correctly says the app has '20 banks and 5 digital banks'. Help me rewrite the Chapter II sentence to say '20 Philippine banks and 5 digital banks, plus e-wallets' while keeping the sentence grammatically correct and in past tense."

### For Task E4 (separate groups sentence)
> "Write a 2-sentence paragraph for my capstone Chapter III that clarifies: the needs assessment survey (N=30 respondents) and the SUS usability evaluation (N=31 respondents) used separate respondent groups, not the same people. Some overlap is possible but they are analyzed independently. Use formal academic English, past tense."

### For any paragraph fix
> "I need to fix this sentence in my capstone thesis results section. Current: [paste sentence]. Required changes: [describe]. Keep it formal academic English in past tense."

---

## 🎯 Defense talking points

1. **"96.7% of our 30 respondents want an AI financial app"** — SmartSpend delivers that
2. **"93.3% use GCash"** — batch import reads GCash screenshots, zero typing needed
3. **"FHS adapted from CBA-Melbourne Institute (2018)"** — academically grounded, labeled prototype indicator
4. **"SUS = 61.83, Grade D, adjective 'OK' per Bangor 2009"** — below 68 benchmark; acknowledged prototype limitation
5. **"Free, offline-first, runs on budget phones"** — not for rich people only
6. **"OCR numbers = preliminary developer testing"** — stated as such in the manuscript; not a formal evaluation

---

*Defense: November 10, 2026 | You got this 🎯*
