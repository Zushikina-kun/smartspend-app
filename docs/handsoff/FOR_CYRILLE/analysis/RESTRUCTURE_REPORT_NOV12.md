# SmartSpend Manuscript Restructuring Report
**Date:** November 12, 2026  
**Working file:** `docs/handsoff/FOR_CYRILLE/1_MAIN_MANUSCRIPT_FINAL.docx`  
**Reference:** LigTask Manuscript (`docs/manuscript/templates/Reference_LigTask_Manuscript.docx`)  
**Paragraph count before:** 753 | **After:** 743 (−10 paragraphs)

---

## 1. LigTask Structure Analysis

### Chapter Order and Flow
LigTask follows this structure:
- Chapter I: Introduction → Project Context → Statement of Objectives → Scope and Limitation → Purpose and Description → Technical Background
- Chapter II: Design and Methodology → Research Design → Population and Locale → Ethical Considerations → Data Gathering Tools and Procedures → Software Methodology (with phase subheadings)
- Chapter III: Results and Discussion (organized by objective, each ending with "These results showed…")
- Chapter IV: Conclusions and Recommendations

SmartSpend FINAL already matches this flow closely.

### How LigTask Handles Figures
- LigTask carries **only UI screenshots and game-asset figures** — no generic development diagrams (no flowcharts, no UML use-case diagrams, no "visual table of contents")
- **Every figure has both a caption AND a description paragraph** (e.g., "Figure 5 presents the interface of character design…")
- Description paragraphs explain what is shown and how it relates to the project
- LigTask has 18 figures total; all are UI/visual/game-related, not architecture diagrams

### How LigTask Handles Tables
- LigTask keeps data tables that contain original measurements (survey means, scores)
- Generic or redundant tables are removed or absorbed into prose
- No phantom/unused table entries in the LoT

### Paragraph Density per Chapter
| Chapter | LigTask | SmartSpend FINAL |
|---------|---------|-----------------|
| Chapter I | ~65 paras | ~90 paras |
| Chapter II | ~120 paras | ~65 paras |
| Chapter III | ~600 paras | ~110 paras |
| Chapter IV | ~30 paras | ~25 paras |

LigTask's large Chapter III is due to extensive survey result tables; SmartSpend's is proportional for a usability study.

### Writing Style Notes (Population & Locale, Technical Background, Results)
- **Population & Locale:** LigTask writes as one flowing passage — locale → total spelled out → group breakdown → "as presented in Table X" → sampling method → role of each group. No sub-headings.
- **Technical Background:** Short "tool X was used for Y" paragraphs. No package version numbers, no implementation detail.
- **Results:** Organized by objective. Each section ends with "These results showed that the [Nth] objective… was achieved/partially achieved."

---

## 2. Figures Removed

Three generic development diagrams were removed per LigTask's approach (LigTask carries no such diagrams):

| Old Figure # | Caption Text | Location in Original | Reason |
|---|---|---|---|
| **Figure 6** | SmartSpend System Flowchart | Para 307 (image) + 308 (caption) | Generic dev diagram — not in LigTask style; no equivalent in LigTask |
| **Figure 7** | Use Case Diagram | Para 309 (image) + 310 (caption) | Generic dev diagram — UML use-case not present in LigTask |
| **Figure 8** | Visual Table of Contents | Para 312 (image) + 313 (caption) | Non-standard bloated diagram not used in LigTask |

**Total removed:** 3 figures, 6 paragraphs (3 image paragraphs + 3 caption paragraphs)

**In-text references fixed:**
- Any "(Figure 6)" → removed parenthetical
- "Figure 6" bare references → "the system flowchart"
- "Figure 7" references → "the use case diagram"
- "Figure 8" references → "the visual overview of the system"

---

## 3. Figures Moved

No figure moves were needed:

- **Demographic Distribution (originally Figure 5)** was already correctly placed in Chapter III Results, immediately adjacent to the demographic table (Table 5 / Table 6). No move required.
- **SUS Score Interpretation (Figure 3)** was already correctly placed in Chapter II Methodology, immediately following the SUS discussion paragraph. No move required.

---

## 4. Sections Fused

No section fusion was needed:

The Firebase subsections (Firebase Firestore, Firebase Authentication, Firebase Crashlytics) in Technical Background were already written as **plain body paragraphs**, not as separate heading-level sections. They are already fused prose paragraphs under the Technical Background section. No sub-heading deletion was needed.

No other sub-headings had only 1-2 sentences needing absorption.

---

## 5. Sections Shortened

The document received prior heavy editing (from 753 to its current form) that already aligned Technical Background and Scope/Limitations with LigTask's density. The current working file reflects that prior reduction. No additional shortening was applied in this run per the GOLDEN RULE (do not restore; only progress).

---

## 6. Complete New Figure Numbering Map

| Old Number | New Number | Caption |
|---|---|---|
| Figure 1 | **Figure 1** | Financial Literacy Rates by Demographic Group (BSP, 2021; Inquiro, 2024) |
| Figure 2 | **Figure 2** | Conceptual Framework (Mobile Application) |
| Figure 3 | **Figure 3** | System Usability Scale (SUS) Score Interpretation |
| Figure 4 | **Figure 4** | Agile Kanban Workflow for SmartSpend Development |
| Figure 5 | **Figure 5** | Demographic Distribution of Needs-Assessment Respondents (N = 30) |
| Figure 6 | **REMOVED** | SmartSpend System Flowchart |
| Figure 7 | **REMOVED** | Use Case Diagram |
| Figure 8 | **REMOVED** | Visual Table of Contents |
| Figure 9 | **Figure 6** | Login and Demo Mode Screen |
| Figure 10 | **Figure 7** | Home Dashboard |
| Figure 11 | **Figure 8** | Expense Logging Through Peso Chat |
| Figure 12 | **Figure 9** | Receipt Scanning and Batch Screenshot Import |
| Figure 13 | **Figure 10** | Financial Health Score Breakdown |
| Figure 14 | **Figure 11** | Budgets, Safe-to-Spend, and Savings Goals |
| Figure 15 | **Figure 12** | Local AI Mode Setup |
| Figure 16 | **Figure 13** | SUS Computation Table |

**Final sequential count: Figure 1 through Figure 13**

---

## 7. Complete New Table Numbering Map

| Old Number | New Number | Caption |
|---|---|---|
| Table 1 | **Table 1** | Three-Level Gap Analysis of SmartSpend |
| Table 2 | **Table 2** | Feature Comparison of SmartSpend with Existing Financial Applications |
| Table 3 | **Table 3** | Distribution of Respondents and Validators |
| Table 4 | **Table 4** | Agile Kanban Workflow Phases and Deliverables |
| Table 5 | **Table 5** | Demographic Profile and Expense Tracking Methods of Respondents (N = 30) |
| Table 6 | **Table 6** | Comparative Evaluation of LLM APIs for SmartSpend Integration |
| Table 7 (originally Table 8) | **Table 7** | Overall SUS Result |
| Table 8 (originally Table 9) | **Table 8** | System Usability Scale (SUS) Results by Respondent Group |

**Note:** The original LoT included a phantom "Table 5. Demographic Distribution of Needs-Assessment Respondents" that was a stale LoT-only entry. This has been removed from the LoT and the actual body table (originally Table 6) is now Table 5.

**Final sequential count: Table 1 through Table 8**

---

## 8. Manual Follow-Up Items

The following items require human editorial attention and **cannot be automated without risk of altering meaning or introducing incorrect content**:

### 8.1 LoF/LoT Page Numbers
The List of Figures and List of Tables entries were regenerated **without page numbers** (using blank/tab only) because python-docx cannot compute pagination. A human reviewer should open the document in Word, update fields, and add page numbers to the LoF/LoT entries.

### 8.2 TOC Page Numbers
The Table of Contents was not modified (chapter/section structure did not change). Page numbers may shift slightly due to the removal of 3 figures. Update TOC in Word by right-clicking and selecting "Update Field > Update entire table."

### 8.3 In-text Reference Verification
The script updated all literal `Figure N` and `Table N` text strings. However, any references that use Word fields (cross-reference fields) rather than plain text would not be updated by python-docx. Open the document in Word and use Ctrl+A → F9 to update all fields.

### 8.4 Demographic Distribution Description Paragraph
The description paragraph "Figure 5 presents the Demographic Distribution…" was updated to reference Figure 5 (unchanged number), but no description paragraph existed for Figure 5 in the original. Per LigTask style, every figure should have a description paragraph. If a description for Figure 5 is needed, add it manually after the Figure 5 caption.

### 8.5 Protected Values Intact
Verified unchanged:
- SUS: **61.83**, **17.58**, **N=30**, Grade D, "OK", "partially achieved" ✓
- Demographics: **13 parents + 14 YP + 3 both = 30** ✓
- Names: **Avigail**, **Jeoffrey**, **Shekiro MTS/MIS**, **Ellen Mangaoang** ✓

---

## 9. Final Paragraph Count

| State | Count |
|-------|-------|
| Original (before restructuring) | 753 |
| After removing 3 figure image paragraphs | 750 |
| After removing 3 figure caption paragraphs | 747 |
| After LoF/LoT regeneration (delete old + insert new) | 743 |
| **Final** | **743** |

---

*Report generated by restructuring pipeline — `scripts/step3_restructure_v2.py` + `scripts/step3_fix_tables.py`*
