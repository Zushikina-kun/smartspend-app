# SmartSpend — Manual Task Guide
**Updated: November 10, 2026, ~9:00 AM | Defense: TODAY**
**Working file:** `FOR_CYRILLE/1_MAIN_MANUSCRIPT_FINAL.docx`
**Open in Microsoft Word only — not LibreOffice or Google Docs**

---

## STATUS OVERVIEW

| Task | Description | Status |
|------|-------------|--------|
| All automated fixes | 180+ changes applied by Kiro | ✅ DONE |
| Task 1 | Scan validator certificates → Appendix D, E & F | 🔴 YOU DO THIS |
| Task 2 | Update TOC, List of Tables, List of Figures | 🔴 YOU DO THIS |
| Task 3 | Regenerate PDF | 🔴 YOU DO THIS (after Tasks 1 & 2) |
| Task 4 | Copy to USB + email backup | 🔴 YOU DO THIS |
| Optional A | Verify Table 3.5 parsing N | 🔵 Optional |
| Optional B | Verify Gemini 3.7 Flash rejection reason in Table 3.2 | 🔵 Optional |

---

## 🔴 TASK 1 — Insert Validator Certificates (~30 min)

### Validator Information (confirmed from signed certificates)
- **Validator full name:** Avigail Candevario, PFMe (confirmed from signed certificates)
- **Both certificates issued:** November 9, 2026
- **Appendix D** = Content Validation Certificate (Survey Questionnaire)
- **Appendix E** = Content Validation Certificate (FHS Formula and Literature)
- **Appendix F** = Technical Validation Certificate (Maam Ellen Mangaoang, DIT)

### What you need
- Signed scan of **Content Validation Certificate** (Avigail Candevario, PFMe, Finance Expert)
- Signed scan of **Technical Validation Certificate** (Maam Ellen Mangaoang, DIT)

### Steps in Word
1. Scroll to the very end of the manuscript (after Appendix C / References)
2. Add a new page: **Insert → Page Break** (or Ctrl+Enter)
3. Type `Appendix D` → format as **Heading 1** (match existing Appendix headings)
4. Next line: type `Content Validation Certificate`
5. Press Enter → **Insert → Pictures → This Device** → select your scan of Avigail Candevario, PFMe's certificate
6. Click the image → **Layout Options → In Line with Text** (keeps it in-flow)
7. Repeat steps 2–6 for Appendix E (Avigail Candevario's FHS/Literature certificate)
8. Repeat steps 2–6 for Appendix F (Maam Ellen Mangaoang's Technical Validation Certificate)

### If you don't have scans yet
Type `(Certificate on file with the researchers)` as placeholder text.
You can replace it with the actual scan later before final printing.

---

## 🔴 TASK 2 — Update TOC, List of Tables, List of Figures (~20 min)

### Why it needs updating
New figures were embedded and new sections added. Page numbers have shifted.
The TOC, List of Tables, and List of Figures all need to reflect these changes.

### Quick method (try this first)
1. Press **Ctrl+A** to select all
2. Press **F9**
3. Word will ask: "Update Table of Contents?"
4. Choose **"Update entire table"** → OK
5. Do this for each field (TOC, List of Tables, List of Figures) if separate

### Manual method (if automatic doesn't work)
Scroll through and update page numbers by hand. Use dot leaders (`....`) matching the style of existing entries.

### New entries to add manually if missing
**Add to Table of Contents:**
```
Appendix D — Content Validation Certificate (Survey Questionnaire) ............. XX
Appendix E — Content Validation Certificate (FHS Formula and Literature) ........ XX
Appendix F — Technical Validation Certificate (Maam Ellen, DIT) ................. XX
```
Under Chapter III, verify this subheading exists:
```
Design and Development of the SmartSpend Mobile Application ..... XX
```

**Add to List of Figures (if not auto-generated):**
```
Figure 2.1  SUS Score Interpretation Framework .............. XX
Figure before 3.11  SUS Score Distribution (N=30) ........... XX
Figure before Table 3.4  SUS Subgroup Comparison ............ XX
Figure before Table 3.1  Demographic Breakdown .............. XX
```

**Verify these List of Tables titles match exactly:**
```
Table 2.1  Distribution of Respondents and Validators
Table 2.2  Agile Kanban Workflow Phases and Deliverables
```

### Final check
- Figure 3.10 (Local AI Setup, p.68) and Evaluation section (p.68) — these may now be on different pages. Verify.
- No two entries share the same page number if they're on different pages.

---

## 🔴 TASK 3 — Regenerate PDF (2 min)

**Do this AFTER completing Tasks 1 and 2.**

1. In Word: **File → Save As**
2. Change file type to **PDF**
3. Save as: `1_MAIN_MANUSCRIPT_FINAL.docx.pdf` (overwrite existing)
4. Scroll through the PDF quickly to verify all 4 new figures display correctly

---

## 🔴 TASK 4 — USB + Email Backup (5 min)

1. Copy to USB drive:
   - `SmartSpend_Defense.pptx`
   - `1_MAIN_MANUSCRIPT_FINAL.docx.pdf` (after regenerating)
2. Email both to yourself as backup
3. At defense venue: test PPTX on the projector laptop before panel arrives

---

## 🔵 OPTIONAL A — Table 3.5: Parsing Accuracy N

**Location:** Chapter III, Table 3.5 "SmartSpend Multimodal Import"
**Current text in Overall row:** `91.2% precision, 88.5% recall (preliminary developer testing, N = ___)`

**Options:**
- If you know N: Fill in the number (e.g., "N = 50 receipts")
- If you don't: Delete the precision/recall figures from Table 3.5 and from Slide 15

**Why it matters:** The panel may ask "where does 91.2% come from?" and you need an answer.

---

## 🔵 OPTIONAL B — Table 3.2: Gemini 3.7 Flash

**Location:** Chapter III, Table 3.2, Gemini 3.7 Flash row
**Current status text:** "Not used: same ~20/day quota as 3.5 Flash with no added benefit in trials"

Confirm this is accurate. If the actual reason was different, update the cell.

---

## ✅ DO NOT REDO — These are already done by Kiro

Everything below is **confirmed applied and verified** in the DOCX. Do not touch.

### Figures (28 images embedded)
- ✅ Figure 2.1: New SUS interpretation chart (Bangor zones, adjective anchors, 61.83 marker)
- ✅ Before Figure 3.11: SUS score distribution bar chart (N=30)
- ✅ Before Table 3.4: SUS subgroup comparison chart (Parents 58.25 vs YP 63.62)
- ✅ Before Table 3.1: Demographic breakdown chart (13P + 14YP + 3Both)
- ✅ Figures 3.4–3.11: Original app screenshots and SUS table (preserved, not touched)

### Tables
- ✅ Table 1.2: Paluwagan = Yes, 36 badges, 34 AI actions
- ✅ Table 2.1: SUS sample row added (10 parents + 20 YP = 30)
- ✅ Table 3.1: Footnote added (†)
- ✅ Table 3.3: 61.83, D, OK, No
- ✅ Table 3.4: Parents 10/58.25/19.72, YP 20/63.62/16.65, Combined 30/61.83/17.58
- ✅ Table 3.5: "Recommendation 6" (was: Priority 9)
- ✅ Table 2.2: Description says "26 tables, v3.1.0 deliverable"

### Text fixes (selected highlights)
- ✅ Instructor: "Mr. Shekiro R. Raposas, MIT"
- ✅ Objective 3: "partially achieved"
- ✅ 68 benchmark: "(Sauro & Lewis, 2016)"
- ✅ OK/Good anchors: "(Bangor et al., 2009)"
- ✅ BSP CFIS 2025
- ✅ LLM: "six weighted criteria"
- ✅ SUS protocol: "10+ minutes self-directed, screening confirmed"
- ✅ Build: "v3.1.0 evaluated; v3.1.1–v3.1.2 added Peso/badges after"
- ✅ Chapter IV Conclusions: 3 paragraphs rewritten
- ✅ Chapter IV Recommendations: 7-item list (UI/UX #5, formal parsing #6)
- ✅ References: Bangor 2008, Deci & Ryan 2000, Sauro & Lewis 2016 added
- ✅ References: 9 uncited entries deleted
- ✅ Bitrián DOI hyperlink fixed

### Presentation (SmartSpend_Defense.pptx)
- ✅ Slides 2, 7, 11, 14, 15, 16, 17 all updated and consistent with manuscript

### Script (4_DEFENSE_SCRIPT_FINAL.md)
- ✅ All [CONFIRM] placeholders resolved
- ✅ Panel names confirmed
- ✅ Sauro & Lewis citations added
- ✅ Build version confirmed in Q&A

---

## 🎯 Pre-Defense Checklist (Morning of Defense)

- [ ] Task 1: Insert certificates (or write placeholder)
- [ ] Task 2: Update TOC / List of Tables / List of Figures
- [ ] Task 3: Save as PDF
- [ ] Task 4: Copy to USB, email backup
- [ ] Open PPTX, test on projector laptop
- [ ] Check Slides 14–17 display correctly
- [ ] Verify font sizes readable from back of room
- [ ] Set laptop to Do Not Disturb (no notifications during defense)
- [ ] Read through 4_DEFENSE_SCRIPT_FINAL.md one more time
- [ ] Review Q&A answers for the 10 likely hard questions

---

*Manual task guide — November 10, 2026 | Kiro*
