# SmartSpend Manuscript — Final Manual To-Do Guide
**For:** Cyrille John M. Rubis · Djaunathan Albert S. Madayag  
**Last updated:** November 5, 2026 (Round 2 — post formatting audit)  
**Deadline:** November 6 (print) · November 9 (defense)

---

## ✅ EVERYTHING KIRO ALREADY FIXED — Do NOT redo these

### Content fixes (applied to `.md` source files AND `CAPSTONE__5_.docx`)
| What was wrong | Fixed to |
|---|---|
| Adviser "Mr. Johnny Flores Verzola, MTS" | Ms. Ellen F. Mangaoang, DIT |
| Abstract: SUS "exceeding ≥80 (Good)" | Honest: 62.50, Grade C, preliminary N=5 |
| "31 agentic/conversational actions" everywhere | 34 everywhere |
| "23 achievement badges" | 25 everywhere |
| Warren & Tyagi (2004) | 2005 (correct year) |
| Tables 3.1–3.3 showing N=30 as final | Added "preliminary N=13" disclaimer |
| Mangaoang MIT (outdated) | DIT (correct — she has a doctorate) |
| SUS placeholders `[[N]]`, `[score]`, `[grade]` | Filled: N=5, 62.50, Grade C, "OK" |
| Research survey `[[N]]` | Filled: 13 respondents (preliminary) |
| Sharma et al. DOI — no flag | ⚠️ flagged for Cyrille to verify |
| Bangor (2009) — no URL | URL added |
| Warren & Tyagi missing from bibliography | Added with correct 2005 year |
| Gemini 3.1 vs 3.5 inconsistency | Clarified: 3.1 benchmarked, 3.5 current |

### Formatting fixes (applied to `CAPSTONE__5_.docx`)
| What was fixed |
|---|
| Times New Roman 12pt applied to all 629 body paragraphs |
| Double-spacing applied to all body paragraphs |
| Single-spacing applied to 430 table cell paragraphs |
| Page margins: left=1.5in (binding), top/right/bottom=1in — all sections |
| Heading 1/2/3 matched to Lorma HABSS template (font, size, bold, spacing) |
| Blurry bar chart (600×371px 12KB) → replaced with 1333×748px high-res version |
| Figures 1.1, 1.2, 2.1, 2.2 — high-res versions inserted |
| Figures 3.1–3.11 — placeholder text inserted with clear instructions |

---

## 🔲 WHAT CYRILLE MUST DO (before printing Nov 6)

### STEP 1 — Open `CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx`
This is the main file. All Kiro's fixes are already applied here. Open this in Word.

### STEP 2 — Insert app screenshots (Figures 3.4–3.10)
Find these placeholders in Word (Ctrl+F: "App screenshot to be inserted"):
- **Figure 3.4** — Login screen + Demo Mode
- **Figure 3.5** — Home Dashboard (FHS ring, Peso)
- **Figure 3.6** — Chat with Peso logging an expense in Taglish
- **Figure 3.7** — Receipt scanning / batch screenshot import
- **Figure 3.8** — FHS breakdown screen
- **Figure 3.9** — Budgets + Savings Goals
- **Figure 3.10** — Local AI Mode setup screen

**How to get the screenshots:**
- Already have 30 screenshots in `docs/debug/screenshots/` — use these
- Or take fresh ones from the app on phone
- Export as PNG at high resolution
- In Word: click placeholder line → Insert → Pictures → select PNG

**Caption format:** `Figure 3.X. [Screen Name]. Source: Authors' own development.`

### STEP 3 — Insert system diagrams (Figures 3.1–3.3)
- **Figure 3.1** — System Flowchart/DFD (draw in Canva or Lucidchart, export PNG)
- **Figure 3.2** — Use Case Diagram (same)
- **Figure 3.3** — Visual Table of Contents / Screen Map

You can use any of these free tools:
- https://www.canva.com — easiest, has flowchart templates
- https://app.diagrams.net — free, good for DFDs
- https://lucidchart.com — free tier works for simple diagrams

Export at 300 DPI PNG. Insert same way as screenshots.

### STEP 4 — Replace your ID photo (optional but recommended)
Your photo (rId60) is only 184×185px — it will look blurry at 2-inch print size.
If you have a better passport photo (at least 600×600px), replace it:
In Word: right-click the photo → Change Picture → select new file

### STEP 5 — Verify the Sharma DOI
Open: https://doi.org/10.2991/978-94-6463-IYC-2026_28
- If it opens the correct paper → find the `[⚠️ DOI TO VERIFY]` note in the bibliography and delete just that warning note
- If it doesn't work → delete the entire Sharma reference and remove any in-text `[2]` citations

### STEP 6 — Verify 3 unverified references
Search on Google Scholar (https://scholar.google.com):
| Reference | Search string |
|---|---|
| FHN (2026) | `"Financial Health Network" 2026 financial health measurement` |
| Groq (2026) | check developer.groq.com directly |
| Li et al. (2024) | search the exact title if you know it |

If NOT found → delete from bibliography + remove in-text citations.

### STEP 7 — Update TOC and Lists
1. Ctrl+A to select all → right-click any field → Update Field → Update entire table
2. Or: References tab → Update Table (for each: TOC, List of Tables, List of Figures)
3. Verify page numbers are correct

### STEP 8 — Approval sheet check
Verify these exact names on the approval/title page:
```
Adviser:        Ms. Ellen F. Mangaoang, DIT
Chairperson:    Ms. Ellen F. Mangaoang, DIT  
Member 1:       Mr. Jopher F. Reyes, MIT
Member 2:       Mr. Gelo Ryann M. Carbonell
Dean:           Mr. Jeoffrey B. Layco, MIS
```
⚠️ Brix to confirm Dean's title before you print.

### STEP 9 — Final Ctrl+F checks before printing
| Search for | Should find | Action if found |
|---|---|---|
| `[[` | 0 results | Fill or remove any remaining PENDING tags |
| `Verzola` | 0 results | Replace with Mangaoang |
| `31 agentic` | 0 results | Change to 34 |
| `23 achievement` | 0 results | Change to 25 |
| `2004` near "Warren" | 0 results | Change to 2005 |
| `App screenshot to be inserted` | 0 results | Insert actual screenshot |

### STEP 10 — Save as PDF and print
1. File → Save As → PDF
2. Scroll through the PDF — check for broken formatting, blank pages, overflowing tables
3. Print 3 copies (Word, not LibreOffice)

---

## 🔲 WHAT DJAUNATHAN MUST DO

### D1 — Study the defense script
Read: `docs/capstone/DEFENSE_QA_PREP.md`
Focus on:
- Your part of the intro/background section
- Questions about the system architecture and LLM selection
- How to answer "Why Gemini 3.5 Flash-Lite?"

### D2 — Study the FHS defense answer
Read: `docs/capstone/FHS_Defense_Guide.pdf`
Memorize the 3-sentence short answer at the top.

### D3 — Demo rehearsal
Read: `docs/capstone/DEMO_DAY_CHECKLIST.md`
Know your part of the Nov 8 rehearsal.

---

## 🔲 WHAT BRIX MUST DO

- [ ] Confirm Dean's title (Jeoffrey B. Layco — MIS confirmed? double-check)
- [ ] Confirm chairperson with Ma'am Ellen (is it also her, or someone else?)
- [ ] Pay defense fee (ask Sir Raposas for amount)
- [ ] Send survey links to more people — need N=30
- [ ] Nov 8 night: install v3.1.2 arm64 APK on demo phone
- [ ] Nov 8 night: reset AI daily limit in app settings
- [ ] Nov 8 night: tap Try Demo, verify all features work

---

## 🔲 SIGNATURES NEEDED (Cyrille to get)

| Document | Who signs | Deadline |
|---|---|---|
| `SmartSpend_Survey_Questionnaire_FOR_VALIDATION.pdf` | Ma'am Ellen | Before survey distribution |
| Informed Consent Forms (30 copies) | Each SUS respondent | Before SUS evaluation |
| Expert Validator Letter — IT/Software | IT professor (ask Sir Raposas) | Nov 7–8 |
| Expert Validator Letter — Finance | Finance/business expert (Susan Arquisal already in manuscript) | Nov 7–8 |
| Approval Sheet | All panel members | Defense day or before |

---

## 📊 SURVEY STATUS

When you have N=30 responses — give the CSV files to Brix → Brix sends to Kiro → Kiro fills all remaining `[[PENDING]]` survey data automatically.

Current: N=13 research, N=5 SUS (preliminary)

Survey links:
- Research: https://docs.google.com/forms/d/e/1FAIpQLSfuDVpOSzTCQ8ICl-FGDjZ9a7iGPpKsh51xxAJ6ajesM36DXQ/viewform
- SUS: https://docs.google.com/forms/d/e/1FAIpQLScs24mLCXnSpCZnqDJt46wSWXQUsxhgu0GBkMAlYcOo8oAf2g/viewform

---

## 📁 Key files — what each one is for

| File | Who uses it | What for |
|---|---|---|
| `docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx` | Cyrille | **THE main manuscript** — all Kiro fixes applied here |
| `docs/capstone/FHS_Formula_For_Maam_Mangaoang.pdf` | Cyrille → Ma'am Ellen | Print and give her (5-page formula doc) |
| `docs/capstone/FHS_Formula_Basis_Table.pdf` | Cyrille → Ma'am Ellen | Give with the above (6-page basis table) |
| `docs/capstone/SmartSpend_Survey_Questionnaire_FOR_VALIDATION.pdf` | Cyrille → Ma'am Ellen | Print, get her signature |
| `docs/capstone/SUMMARY_FOR_MAAM_ELLEN.pdf` | Brix → Ma'am Ellen | Send in GC (2-page summary) |
| `docs/capstone/FHS_Defense_Guide.pdf` | All 3 | Study before defense |
| `docs/capstone/DEFENSE_QA_PREP.md` | All 3 | Study before defense |
| `docs/capstone/DEMO_DAY_CHECKLIST.md` | All 3 | Follow on Nov 8 rehearsal and Nov 9 |
| `docs/capstone/FUTURE_FEATURES_RESEARCH.md` | Djaunathan | Answer "what are your future plans?" |

---

## 🗓 Timeline

| Date | Task | Who |
|---|---|---|
| **Nov 5 (today)** | Send SUMMARY + QUESTIONNAIRE PDF to Ma'am Ellen in GC | Brix |
| **Nov 5 (today)** | Share survey links — push for more responses | All |
| **Nov 5–6** | Steps 1–10 above (Word edits, screenshots, diagrams, TOC) | Cyrille |
| **Nov 6 morning** | Confirm Dean title, then print 3 copies | Brix + Cyrille |
| **Nov 6** | Get Ma'am Ellen signature on questionnaire | Cyrille |
| **Nov 7–8** | Get expert validator signatures | Cyrille |
| **Nov 8 night** | Install APK on demo phone, reset AI limit, full rehearsal | All 3 |
| **Nov 9** | 🎯 DEFENSE DAY | All 3 |

---

*Updated by Kiro — November 5, 2026. All automated fixes applied. Only manual tasks remain.*
