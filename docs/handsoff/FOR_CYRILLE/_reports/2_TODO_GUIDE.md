# SmartSpend — Manual Tasks for Groupmates
**Updated: November 12, 2026 | Defense: November 16, 2026**

**Source working file (Maam Ellen's group — keep untouched as backup):**
`docs/handsoff/1_MAIN_MANUSCRIPT_FINAL(MAIN_V4) (1).docx`

**Continue editing the NEW FINAL (V4 with Kiro's fixes already applied):**
`docs/handsoff/FOR_CYRILLE/1_MAIN_MANUSCRIPT_FINAL.docx`
*(built from V4's content — page numbers and paragraph text match V4)*

**Open in Microsoft Word only — not LibreOffice or Google Docs**

> 📋 The full, authoritative fix list (what Kiro already did + every remaining manual
> fix with exact FIND/REPLACE text) is in **`WORD_FIXGUIDE_V4_NOV12.md`** (same folder).
> Read that first. This TODO guide is the quick task checklist.

---

## STATUS OVERVIEW

| Task | Description | Who | Status |
|------|-------------|-----|--------|
| Automated fixes (this round) | Susan→Avigail, Table 2.1 (13/Both/1 validator), qualitative→interviews, ack em-dashes, recs 7→8, abstract Eight, figures/certs verified, objectives kept | Kiro | ✅ DONE |
| **Task 0** | **Resolve 2 content contradictions (Maam Ellen) — see WORD_FIXGUIDE M1, M2** | Groupmate | 🔴 YOU DO THIS |
| Task 1 | Verify page number position | Groupmate | 🔴 YOU DO THIS |
| Task 2 | Fix Technical Background indents | Groupmate | 🔴 YOU DO THIS |
| Task 3 | Fix Table 2.1 / 2.2 caption alignment | Groupmate | 🔴 YOU DO THIS |
| Task 4 | Verify References heading | Groupmate | 🔴 YOU DO THIS |
| Task 5 | Verify certificate images (App D & E) | Groupmate | 🟢 YOU DO THIS |
| Task 6 | Update TOC / LOF / LOT page numbers | Groupmate | 🔴 YOU DO THIS |
| Task 7 | Verify Roman numeral front matter | Groupmate | 🔴 YOU DO THIS |
| Task 8 | Save as PDF (last step) | Groupmate | 🔴 YOU DO THIS |

---

## 🔴 TASK 0 — Resolve 2 content contradictions (Maam Ellen) ⏱️ 10 min

Kiro applied Maam Ellen's table/paragraph fixes, but two spots still contradict them.
**These must be reconciled before the defense** — full FIND/REPLACE is in
`WORD_FIXGUIDE_V4_NOV12.md` (Fix M1 and Fix M2).

1. **Interviews vs. "no interviews."** The qualitative paragraph now says **interviews**
   were used (per Maam Ellen: "qualitative e yng interview"). But a Chapter III paragraph
   still says **"no open-ended or interview data were collected."** Confirm with Maam
   Ellen whether interviews were actually conducted, then make both paragraphs agree
   (WORD_FIXGUIDE Fix M1).

2. **"Separate IT expert / Technical Validation Certificate."** Table 2.1 now lists
   **Total Validators = 1** (Avigail only — Maam Ellen: "wala po" / "pinag isa nalang").
   But a Research Methodology paragraph still claims a separate IT expert reviewed the
   SUS process and the system, documented in a "Technical Validation Certificate" (which
   does not exist — appendices are D = survey cert, E = FHS cert). Delete or reword that
   sentence so Avigail is the sole validator (WORD_FIXGUIDE Fix M2).

---

## 🔴 TASK 1 — Verify page numbers don't overlap header ⏱️ 5 min

**Problem:** Page numbers are in the header of body sections. The institutional college
header (Lorma, CCSE) also lives in the header — they might share the same line.

**Steps:**
1. Go to any Chapter I–IV page (e.g., press Ctrl+End, scroll back a few pages)
2. Look at the **very top** of the page — do you see the page number AND the college header?
3. **If they overlap or look crowded:**
   - Double-click the header area
   - Delete the page number from the header
   - Close header/footer (Esc)
   - Insert → Page Number → Bottom of Page → Plain Number 2
4. **If they look fine:** ✅ skip

---

## 🔴 TASK 2 — Fix Technical Background paragraph indents ⏱️ 10 min

**Problem:** Body paragraphs in the "Technical Background" subsection (Chapter I, around
pages 26–29) have no first-line indent. All other body text has 0.5 inch first-line indent.

**Steps:**
1. Ctrl+F → type "Technical Background" → Enter
2. Look for the body paragraphs below that heading (describing Flutter, sqflite, Firebase, etc.)
3. Click at the start of the first body paragraph there
4. Shift+click at the end of the last body paragraph in that subsection
5. Home tab → click the small arrow at bottom-right of "Paragraph" group
6. Under "Indentation" → Special: **First line** → By: **0.5"** → OK

---

## 🔴 TASK 3 — Fix Table 2.1 and 2.2 caption alignment ⏱️ 5 min

**Problem:** "Table 2.1. Distribution of Respondents and Validators" and
"Table 2.2. Agile Kanban Workflow Phases and Deliverables" captions need to be centered.
(Note: Table 2.1 was restructured by Kiro — Parents 13, Both Groups 3, Total Validators 1,
no Technical Validator row. Just center the caption line.)

**Steps:**
1. Ctrl+F → search "Table 2.1." → Enter
2. Click on that caption line
3. Press **Ctrl+E** to center it
4. Ctrl+F → search "Table 2.2." → Enter
5. Click that caption line → Ctrl+E

---

## 🔴 TASK 4 — Verify References heading ⏱️ 2 min

**Steps:**
1. Ctrl+F → search "References" → Enter (go to the References section heading, not an in-text citation)
2. Click on the "References" heading paragraph
3. Check: is it **centered**? Is it **bold**?
4. If not: Ctrl+E (center) and Ctrl+B (bold)

---

## 🟢 TASK 5 — Verify certificate images in Appendices D & E ⏱️ 5 min

**What:** The certificate images (Avigail Candevario, PFMe) were **already embedded in V4**
and Kiro verified they are present with valid file links. This is just a visual check.

**Steps:**
1. Ctrl+End → go to end of document
2. Scroll up to find "APPENDIX D" — check the certificate image:
   - Is it visible? Does it fit the page (not cut off)? Is it readable?
3. Check "APPENDIX E" the same way
4. **If image is too large or misaligned:**
   - Click the image
   - Picture Format tab → Size group → set Width to **5.5 inches** (height adjusts automatically)
5. **If an image is broken/missing:** Insert → Pictures → This Device →
   `FOR_CYRILLE/FIGURES/certificates/`
   - `AppendixD_Survey_Questionnaire_Certificate.jpg` for Appendix D
   - `AppendixE_FHS_Formula_Certificate.jpg` for Appendix E

---

## 🔴 TASK 6 — Update TOC, List of Figures, List of Tables ⏱️ 15 min

**Why:** Page numbers shift after edits. The figures 3.12, 3.13, 3.14 are already in the
List of Figures (they were already in V4) — just refresh page numbers.

**Steps — Quick method (try this first):**
1. Press **Ctrl+A** (select all)
2. Press **F9** → choose "Update entire table" → OK for each TOC/LOF/LOT prompt
3. Scroll through TOC and LOF to verify numbers look right

**Steps — Manual method (if Ctrl+A + F9 doesn't work):**
1. For each section (TOC, List of Figures, List of Tables):
   - Scroll to it
   - Right-click anywhere in the table → Update Field → Update entire table

**Figures already in the List of Figures (verify page numbers after refresh):**
- Figure 3.12. SUS Score Distribution (N = 30)
- Figure 3.13. SUS Scores by Respondent Group (N = 30)
- Figure 3.14. Demographic Distribution of Needs-Assessment Respondents (N = 30)

---

## 🔴 TASK 7 — Verify front matter page numbers (Roman numerals) ⏱️ 5 min

**What:** Pages before Chapter I (title page, approval sheet, acknowledgements,
dedication, TOC, LOF, LOT, abstract) should use Roman numerals (i, ii, iii...).

**Steps:**
1. Go to page 3 or 4 (Acknowledgement or Dedication page)
2. Look for the page number — is it a Roman numeral?
3. **If Arabic numbers on front matter pages:**
   - Double-click the footer/header where the page number is
   - Insert → Page Number → Format Page Numbers
   - Number format: **i, ii, iii...**
   - Start at: **i**
   - OK
4. **If correct already:** ✅ skip

---

## 🔴 TASK 8 — Save as PDF (LAST STEP) ⏱️ 2 min

**Do this AFTER all tasks above (especially Task 0).**

1. File → **Save As**
2. Change file type to **PDF**
3. Save as `1_MAIN_MANUSCRIPT_FINAL.docx.pdf` (overwrite the existing one)
4. Scroll through the PDF quickly:
   - All pages have correct margins? ✅
   - All images visible? (figures + 2 certificate images) ✅
   - No pages with tiny bottom margins? ✅
   - Page numbers correct? ✅

---

## ✅ DO NOT REDO — Already done by Kiro (in the new FINAL, built from V4)

### What Kiro automated this round
- ✅ Susan C. Arquisal → **Avigail Candevario, PFMe** (validator paragraph); the stray
  duplicate Susan sentence in Data Gathering was deleted
- ✅ Table 2.1: Parents **16 → 13**, added **Both Groups (3)**, needs-assessment
  **Total 30**, **Total Validators = 1**, no Technical Validator row
- ✅ Qualitative paragraph → **interviews were used** (per Maam Ellen)
- ✅ Acknowledgements panelists line → **em-dashes** around the names
- ✅ Recommendations expanded **7 → 8**: 1 UI/UX refinement, 2 formal parsing, 3 backend
  proxy + Google Play, 4 SQLite, 5 on-device AI, 6 payday-cycle, 7 household &
  remittance, 8 longitudinal
- ✅ Abstract: **Seven → Eight recommendations**
- ✅ Figures 3.12, 3.13, 3.14 **verified already present in V4** with intact images
  (not re-embedded — re-embedding would duplicate)
- ✅ Appendix D & E certificate images **verified already present in V4** with intact links
- ✅ Objectives **kept as V4's** (Maam Ellen's shortened version — not replaced)
- ✅ All protected values intact (61.83, 17.58, N=30, Grade D, OK, partially achieved,
  13/14/3, 10/20, 96.7%, 93.3%)

### What was true of V4 already (no action needed)
- ✅ Tense: V4 is already at parity with the reference doc (0 missing past-tense fixes) —
  no tense pass needed
- ✅ Names/credentials in V4: Shekiro R. Raposas MTS/MIS, Jeoffrey B. Layco MIS,
  Mary-Ann Mzana MTS, Ellen F. Mangaoang DIT
- ✅ Objective 3: "partially achieved"

### Presentation (SmartSpend_Defense.pptx) — separate file, verify separately
- ⚠️ Slide with recommendations should match the manuscript's **8** recommendations now
  (was 7). Update the slide if it still lists 7.
- Verify credentials and "partially achieved" language on the deck independently.

---

## 📋 Pre-Defense Final Checklist

Print this and check each box before the defense:

- [ ] Task 0: Resolved the interviews contradiction and the technical-validator sentence
- [ ] Task 1: Page numbers verified (not overlapping header)
- [ ] Task 2: Technical Background indents fixed
- [ ] Task 3: Table 2.1 and 2.2 captions centered
- [ ] Task 4: References heading centered and bold
- [ ] Task 5: Appendix D and E certificates look correct
- [ ] Task 6: TOC, LOF, LOT page numbers updated
- [ ] Task 7: Roman numerals on front matter pages
- [ ] Task 8: PDF exported (overwrite old file)
- [ ] Presentation recommendations updated to 8 (if needed)
- [ ] Copy `SmartSpend_Defense.pptx` and PDF to USB
- [ ] Email both files to yourself as backup
- [ ] Test PPTX on projector laptop before panel arrives
- [ ] Phone on silent
- [ ] Water bottle

---

## 👥 Key People for the Defense

| Name | Role | Credentials |
|------|------|-------------|
| **Jeoffrey B. Layco** | Dean / Panel Chairperson | MIS |
| **Shekiro R. Raposas** | TIC / Panel Member | MTS, MIS |
| **Mary-Ann Mzana** | Panel Member | MTS |
| **Ellen Flores Mangaoang** | Capstone Adviser | DIT |
| **Avigail Candevario** | Content Validator | PFMe |

---

*Manual task guide — November 12, 2026 | Kiro | See WORD_FIXGUIDE_V4_NOV12.md for the
full fix list with exact FIND/REPLACE text.*
