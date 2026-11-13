# SmartSpend Defense — Complete Handoff Guide
**Defense: Monday November 16, 2026, 3:00 PM**
**Prepared: November 13, 2026**

---

## 📁 WHERE TO FIND EVERYTHING

All working files are in:
```
c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\
```
Or on GitHub: https://github.com/Zushikina-kun/smartspend-app (branch: master)

| File | Purpose |
|------|---------|
| `1_MAIN_MANUSCRIPT_FINAL.docx` | ✅ MAIN manuscript — use this |
| `SmartSpend_Defense.pptx` | ✅ MAIN presentation — use this |
| `4_DEFENSE_SCRIPT_FINAL.md` | ✅ MAIN defense script — use this |
| `5_DEFENSE_REVIEWER_NOV16.md` | 58 Q&A reviewer for practice |
| `FIGURES/` | All figure images (Figures 1–16) |
| `FIGURES/certificates/` | Validation certificates (App D & E) |
| `analysis/` | All reports and audit logs |

---

## ✅ WHAT IS ALREADY DONE (DO NOT REDO)

### Manuscript
- Scope and Limitations: **2 short paragraphs only** ✅
- Technical Background: **condensed** (Firebase fused into 1 paragraph) ✅
- Research design: **quantitative descriptive developmental** ✅
- Validator: **Avigail Candevario, PFMe** (Susan removed) ✅
- Panelists listed in Acknowledgements with em-dashes ✅
- 9 recommendations (added UI/UX #8 and Parsing eval #9) ✅
- All 3 objective conclusions present ✅
- All figure/table references use continuous numbers ✅
- All 16 figures have embedded images ✅
- All 9 tables verified correct ✅
- Past tense throughout ✅
- 61.83, N=30, Grade D all verified ✅
- Certificates in Appendix D (survey) and Appendix E (FHS formula) ✅

### Presentation (SmartSpend_Defense.pptx, 19 slides)
- Research design: quantitative ✅
- SUS values correct ✅
- Gemini 3.5 Flash-Lite (corrected from 1.5) ✅
- 16 parents + 14 YP language ✅

### Script (4_DEFENSE_SCRIPT_FINAL.md)
- 19-slide structure, Nov 16 3:00 PM ✅
- Correct panel names ✅
- Gemini 3.5 Flash-Lite ✅
- 10 Q&A answers ✅

---

## 🔴 REMAINING MANUAL TASKS (Do in Word)

**Open `1_MAIN_MANUSCRIPT_FINAL.docx` in Microsoft Word only.**

### TASK 1 — TOC page numbers ⏱️ 5 min
Ctrl+A → F9 → "Update entire table"
If that doesn't work: right-click each section → Update Field

### TASK 2 — Verify Appendix D and E images ⏱️ 5 min
Scroll to end of document. Verify certificate images display correctly.
If broken: Insert → Pictures → from `FIGURES/certificates/`
- `AppendixD_Survey_Questionnaire_Certificate.jpg`
- `AppendixE_FHS_Formula_Certificate.jpg`

### TASK 3 — Remove empty Photo Documentation heading ⏱️ 2 min
Find "PHOTO DOCUMENTATION" heading → Delete it and blank lines after it

### TASK 4 — Fix List of Figures/Tables formatting ⏱️ 10 min
The LOF/LOT currently have inconsistent spacing. Format each entry as:
`Figure 1.   Title text.......................  page`
Match the style of existing entries.

### TASK 5 — Save as PDF ⏱️ 2 min  
File → Save As → PDF
**Do this LAST after all Word tasks.**

### TASK 6 — Print 4 copies ⏱️ 10 min
Full manuscript (all chapters + appendices)
1 copy per panel member + 1 extra

---

## ⚠️ REMAINING ISSUES TO FIX (For AI or manual)

These are still present in the manuscript. Priority order:

### HIGH PRIORITY (affects defense quality)

**1. Figure 3 description says wrong SUS zones**
- Current: "Poor (below 60), Marginal (60–69), Acceptable (70–79), Good (80–89), Excellent (90–100)"
- Should be (Bangor 2008): "Not Acceptable (<51), Marginal (51–70), Acceptable (≥71)"
- The figure image itself is correct. Only the description text below it is wrong.
- FIND: `The SUS score ranged from 0 to 100 and is categorized into different levels: Poor (below 60), Marginal (60–69), Acceptable (70–79), Good (80–89), and Excellent (90–100)`
- REPLACE: `The SUS score ranged from 0 to 100 and was categorized into acceptability levels: Not Acceptable (below 51), Marginal (51–70), and Acceptable (71 and above) based on Bangor et al. (2008). Adjective anchors from Bangor et al. (2009) placed "OK" at approximately 51, "Good" at 71, and "Excellent" at 85. The 68-point average benchmark (Sauro & Lewis, 2016) and the pre-established target of 80 are also indicated.`

**2. Figure 5 description still mentions "Both Groups"**
- Figure 5 chart was updated to show 16/14 (no Both bar)
- But the paragraph below Figure 5 says "The 3 respondents who identified as both parent and young professional were reclassified..."
- This is actually CORRECT — keep it as an explanation note

**3. FHS formula — missing item 3 (Budget Adherence)**
- Full Mode lists items 1, 2, then jumps to 4 (Logging Consistency)
- Item 3 (Budget Adherence, 25 pts) is missing
- FIND the FHS section and add: `3. Budget Adherence (25 pts): Score = 25 × (onBudgetCategories / totalBudgetedCategories). Category-level budget limits followed zero-based budgeting principles.`

**4. Population paragraph still says "purposive sampling"**
- Current: "A total of thirty (30) respondents were selected using purposive sampling"
- Should be: "A total of thirty (30) respondents were selected using random sampling, as any parent aged 35–55 or young professional aged 21–35 who met the inclusion criteria was eligible to participate. The content validator was selected through purposive sampling based on her expertise in financial management."
- FIND: `A total of thirty (30) respondents were selected using purposive sampling`
- REPLACE: `A total of thirty (30) respondents were selected using random sampling, as any parent aged 35–55 or young professional aged 21–35 who met the inclusion criteria was eligible. The content validator was selected through purposive sampling based on her expertise in financial management.`

**5. Data Gathering — no Objective 2 paragraph**
- After "For the first objective..." and "For the third objective...", there is no "For the second objective..."
- FIND location after the first objective paragraph
- ADD: `For the second objective, SmartSpend was designed and developed as an Android mobile application. The development utilized Flutter for the user interface, SQLite for local data storage, Firebase for cloud synchronization, and a large language model API for AI-powered features. Candidate LLM APIs were comparatively evaluated using standardized Filipino-English prompts to select the most suitable provider.`

**6. Appendix A reference in body text is lowercase**
- FIND: `see Appendix a)`
- REPLACE: `see Appendix A)`

### MEDIUM PRIORITY

**7. Table 7 appears twice (LLM table and Demographics table both labeled Table 7)**
- Demographic Profile table should be Table 6 (check body)
- LLM Comparative Evaluation should be Table 7

**8. "By combining quantitative and developmental approaches" sentence is awkward**
- FIND: `By combining quantitative and developmental approaches, the study ensured that the system was not only technically functional`
- REPLACE: `By adopting a quantitative developmental approach, the study ensured that the system was not only technically functional`

---

## 📊 KEY NUMBERS (Memorize)

| Value | Number |
|-------|--------|
| SUS Mean | **61.83** |
| SUS SD | **17.58** |
| SUS Grade | **D** |
| SUS Adjective | **"OK"** |
| Sample N | **30** (from 36, excluded 6) |
| Needs-assessment | **16 parents + 14 YP = 30** |
| SUS sample | **10 parents + 20 YP = 30** (separate) |
| AI intent | **96.7%** (29/30) |
| GCash users | **93.3%** (28/30) |
| App version evaluated | **v3.1.0** |
| AI actions | **34** |
| Gemini model | **3.5 Flash-Lite** |
| Objective 3 | **Partially achieved** |

---

## 👥 KEY PEOPLE

| Name | Role | Credentials |
|------|------|-------------|
| **Jeoffrey B. Layco** | Dean / Panel Chairperson | MIS |
| **Shekiro R. Raposas** | TIC / Panel Member | MTS, MIS |
| **Mary-Ann Mzana** | Panel Member | MTS |
| **Ellen Flores Mangaoang** | Capstone Adviser | DIT |
| **Avigail Candevario** | Content Validator | PFMe |

---

## 🖼️ FIGURES (1–16) — All have embedded images

| # | Title | Shows |
|---|-------|-------|
| 1 | Financial Literacy Rates | BSP 2021 chart by demographic group |
| 2 | Conceptual Framework | IPO model diagram |
| 3 | SUS Score Interpretation | Framework with 61.83, 68, 80 marked |
| 4 | Agile Kanban Workflow | 7-column Kanban board |
| 5 | Demographic Distribution | 16 parents, 14 YP bar chart |
| 6 | System Flowchart | Full system flow diagram |
| 7 | Use Case Diagram | User-system interactions |
| 8 | Visual Table of Contents | App navigation tree |
| 9 | Login and Demo Mode | Login screen screenshot |
| 10 | Home Dashboard | Home screen with FHS |
| 11 | Expense Logging (Peso Chat) | AI chat interface |
| 12 | Receipt Scanning | OCR receipt screen (blurred) |
| 13 | FHS Breakdown | FHS score screen |
| 14 | Budgets Screen | Budget management |
| 15 | Local AI Mode Setup | Local LLM setup screen |
| 16 | SUS Computation Table | Sample respondent scoring |

**Image files in `FIGURES/`:**
- `Figure_3.4_Login_Demo_Mode.jpg` → Figure 9
- `Figure_3.5_Home_Dashboard.jpg` → Figure 10
- `Figure_3.6_Peso_Chat_Expense_Logging.jpg` → Figure 11
- `Figure_3.7_Batch_Import_GCash.jpg` → Figure 12 (blurred)
- `Figure_3.8_FHS_Breakdown.jpg` → Figure 13
- `Figure_3.9_Budgets_Savings_Goals.jpg` → Figure 14
- `Figure_3.10_Local_AI_Setup.jpg` → Figure 15
- `Figure_3.11_SUS_Computation_Table.png` → Figure 16
- `Figure_2_1_SUS_Interpretation.png` → Figure 3
- `Figure_SUS_Distribution.png` → SUS distribution (removed from body, available)
- `Figure_SUS_Subgroup.png` → SUS subgroup (removed from body, available)
- `Figure_Demographic_Breakdown.png` → Figure 5 (16/14 version)
- `Peso_Logo.svg` → Peso mascot (vector)
- `SmartSpend_Logo.png` → SmartSpend logo
- `SmartSpend_AppIcon.png` → App icon
- `certificates/AppendixD_Survey_Questionnaire_Certificate.jpg` → Appendix D
- `certificates/AppendixE_FHS_Formula_Certificate.jpg` → Appendix E

---

## 📋 TABLES (1–9)

| # | Title | Key Data |
|---|-------|---------|
| 1 | Three-Level Gap Analysis | International/National/Demographic gaps |
| 2 | Feature Comparison | SmartSpend vs 6 other apps |
| 3 | Distribution of Respondents | 16 parents, 14 YP, 1 validator = 30 |
| 4 | Agile Kanban Workflow | 7 phases, tasks, deliverables |
| 5 | Demographic Distribution | 13 parents (43.3%), 14 YP (46.7%), 3 Both |
| 6 | Demographic Profile + Tracking | Full demographics + tracking methods |
| 7 | LLM API Comparison | 8 models evaluated, Gemini 3.5 Flash-Lite selected |
| 8 | Overall SUS Result | 61.83, Grade D, OK, Not Acceptable |
| 9 | SUS by Respondent Group | Parents 58.25, YP 63.62, Combined 61.83 |

---

## 🔧 HOW TO VERIFY THE MANUSCRIPT IS CORRECT

Run this script anytime to check:
```
python docs\handsoff\FOR_CYRILLE\check_final_state.py
```

Or manually Ctrl+F in Word for:
- "Susan" → should return 0 results
- "EXPLAIN WHAT" → should return 0 results
- "Ano meaning" → should return 0 results
- "mixed-methods" → should return 0 results (only "quantitative descriptive")
- "61.83" → should appear in abstract and results
- "partially achieved" → should appear in results and conclusions

---

## 📝 FOR CLAUDE OR OTHER AI

If you're continuing work on this manuscript, here's the context:

**What it is:** Bachelor of Science in Information Technology capstone project, Lorma Colleges, San Fernando City La Union Philippines. Android mobile app (SmartSpend) for personal finance management targeting parents 35-55 and young professionals 21-35.

**Research type:** Quantitative descriptive developmental (NOT mixed methods — no interviews were conducted)

**Study summary:**
- Needs assessment: 30 respondents, 96.7% intent to use AI finance app, 93.3% GCash users
- Developed SmartSpend v3.1.0 with Gemini 3.5 Flash-Lite as primary LLM
- SUS evaluation: 61.83 mean, Grade D, "OK" adjective, partially achieved

**What NOT to change:**
- SUS numbers (61.83, 17.58, N=30, Grade D, OK)
- 16 parents + 14 YP = 30 for needs-assessment
- 10 parents + 20 YP = 30 for SUS sample (separate)
- Validator: Avigail Candevario, PFMe (NOT Susan Arquisal)
- "partially achieved" for Objective 3

**Key remaining issues (see above section):**
1. Figure 3 description has wrong SUS zones
2. FHS formula missing item 3 (Budget Adherence)
3. Population still says "purposive sampling" (should be random)
4. No "For the second objective" in Data Gathering
5. Appendix a → Appendix A

---

*Created Nov 13, 2026 | Kiro*
*Defense: Nov 16, 2026, 3:00 PM | Print 4 copies (full manuscript)*
