# SmartSpend Manuscript – Full Revision Report

**Script:** revision_script_v2.py  
**Source DOCX:** 1_MAIN_MANUSCRIPT_FINAL.docx  
**Backup:** 1_MAIN_MANUSCRIPT_FINAL.docx.revision.bak  

---

## Fix 1 – List of Figures and List of Tables

### List of Figures — 16 Entries Added
- Figure 1: Financial Literacy Rates by Demographic Group (BSP, 2021; Inquiro, 2024).
- Figure 2: Conceptual Framework (Mobile Application)
- Figure 3: System Usability Scale (SUS) Score Interpretation
- Figure 4: Agile Kanban Workflow for SmartSpend Development
- Figure 5: Demographic Distribution of Needs-Assessment Respondents (N = 30).
- Figure 6: SmartSpend System Flowchart
- Figure 7: Use Case Diagram
- Figure 8: Visual Table of Contents
- Figure 9: Login and Demo Mode Screen
- Figure 10: Home Dashboard
- Figure 11: Expense Logging Through Peso Chat
- Figure 12: Receipt Scanning and Batch Screenshot Import
- Figure 13: Financial Health Score Breakdown
- Figure 14: Budgets, Safe-to-Spend, and Savings Goals
- Figure 15: Local AI Mode Setup
- Figure 16: SUS Computation Table

### List of Tables — 8 Entries Added (ghost Table 5 removed)
- Table 1: Three-Level Gap Analysis of SmartSpend
- Table 2: Feature Comparison of SmartSpend with Existing Financial Applications (including Filipino-context apps)
- Table 3: Distribution of Respondents and Validators
- Table 4: Agile Kanban Workflow Phases and Deliverables
- Table 6: Demographic Profile and Expense Tracking Methods of Respondents (N = 30)
- Table 7: Comparative Evaluation of LLM APIs for SmartSpend Integration
- Table 8: Overall SUS Result
- Table 9: System Usability Scale (SUS) Results by Respondent Group

**Removed:** Ghost "Table 5: Demographic Distribution of Needs-Assessment Respondents (N = 30)" — this content exists as Figure 5 (a chart), not a data table.

---

## Fix 2 – Burned-in Figure Numbers (FLAG ONLY — MANUAL REPLACEMENT REQUIRED)

The following images were flagged as potentially containing wrong figure numbers burned into their pixels. **Do NOT edit these programmatically.** Supply replacement images.

| Image File | Figure # in Manuscript | Suspected Burned-in Text | Correct Number |
|---|---|---|---|
| image2.jpg | Figure 2 | Possibly old "Figure 1.2" or similar | Figure 2 |
| image3.png | Figure 3 | May have burned-in label | Figure 3 |
| image4.png | Figure 4 | Possibly old "Figure 2.X" (Kanban was often in Ch. II) | Figure 4 |
| image7.png | Figure 6 | **Most likely wrong** – system flowcharts renumbered; likely "Figure 3.1" or "Figure 3.X" | Figure 6 |
| image8.png | Figure 7 | Possibly old "Figure 3.2" or "Figure 3.3" | Figure 7 |
| image9.png | Figure 8 | Possibly old "Figure 3.X" | Figure 8 |
| image17.png | Figure 16 | **USER FLAGGED: "Figure 3.14" burned in** – the specific case the user reported | Figure 16 |

> ⚠️ **Action required:** Visually inspect each flagged image. Supply replacement PNG/JPG files with correct figure numbers. The most critical is **image17.png (Figure 16)** which the user explicitly reported contains "Figure 3.14".

---

## Fix 3 – Privacy Blur

### GCash screenshots blurred (Gaussian radius=15, saved to images/blurred/):
- Screenshot_2026-11-09-09-42-28-585_com.globe.gcash.android.jpg
- Screenshot_2026-11-09-09-42-34-345_com.globe.gcash.android.jpg
- Screenshot_2026-11-09-09-42-42-226_com.globe.gcash.android.jpg
- Screenshot_2026-11-09-09-42-48-630_com.globe.gcash.android.jpg
- Screenshot_2026-11-09-09-42-55-828_com.globe.gcash.android.jpg
- Screenshot_2026-11-09-09-42-58-916_com.globe.gcash.android.jpg
- Screenshot_2026-11-09-09-43-03-953_com.globe.gcash.android.jpg
- Screenshot_2026-11-09-09-43-09-740_com.globe.gcash.android.jpg

### DOCX replacement:
- **image13.png (Figure 12 – Receipt Scanning and Batch Screenshot Import):** Replaced with Gaussian-blurred version in DOCX. This image was flagged HIGH RISK for showing embedded GCash data within the app's batch-import UI.

---

## Fix 4 – TOC Chapter/Section Outline

Chapter and section outline added to the Table of Contents:
- Front matter entries (Title Page through List of Tables)
- Chapter I – Introduction (6 sections)
- Chapter II – Design and Methodology (5 sections)
- Chapter III – Results and Discussion (3 sections + 1 subsection)
- Chapter IV – Conclusions and Recommendations (2 sections)
- References

**Also fixed:** Chapter III heading "Designed and Developed of the SmartSpend Mobile Application" → "Design and Development of the SmartSpend Mobile Application"

---

## Fix 5 – Writing Style Revisions (LigTask Alignment)

1. **Table 7 → Table 6 (Demographic Profile):** Renamed in narrative references and table headings. Resolves duplicate Table 7 conflict.
2. **"Tables 3.3 and 3.4" → "Tables 8 and 9":** Fixed old table reference in Chapter III SUS results (direct XML edit required as text was in complex paragraph with image).
3. **Statement of Objectives lead-in:** Trimmed to one sentence.
4. **Research Design closing paragraph:** Removed redundant restatement sentence.
5. **Population/Locale narrative:** Clarified the 13/14/3 split to match Table 3.
6. **LLM API post-table paragraph:** Condensed to 2 sentences.
7. **FHS formula section:** Lightweight Mode and Score Adjustments detail replaced with condensed note.
8. **Version history paragraph:** Replaced with one-sentence summary.
9. **AI Privacy Tiers paragraph:** Condensed to 3 sentences.
10. **Peso mascot paragraph:** Condensed to 4 sentences.
11. **Local LLM setup paragraph:** Condensed to 2 sentences.
12. **Done/Review Phase paragraph:** Future-features list removed; condensed to focus on evaluation and documentation.
13. **Chapter IV Conclusions:** Removed redundant objective-restatement blocks; fixed orphaned SUS paragraph.

---

## Fix 6 – Figure Descriptions

| Figure | Action |
|---|---|
| Figure 1 | Added 2-sentence description paragraph below caption |
| Figure 5 | Added opening "Figure 5 presents..." sentence before existing analytical text |
| Figure 8 | Added standalone description directly below caption |
| Figure 15 | Removed misplaced description (was after Figure 11); inserted 3-sentence description directly after Figure 15 caption |
| Figures 2–4, 6–7, 9–14, 16 | Verified present; kept as-is |

---

## Verification Summary

| Check | Result |
|---|---|
| List of Figures: 16 entries | True |
| List of Tables: 8 entries, no ghost Table 5 | True |
| Chapter outline in TOC | True |
| No duplicate Table 7 for Demographic Profile | True |
| Tables 8 and 9 reference in SUS section | True |
| Figure 15 description after Figure 15 caption | True |

---

## Files Modified

| File | Change |
|---|---|
| `docs/handsoff/1_MAIN_MANUSCRIPT_FINAL.docx` | Full revision pass |
| `docs/handsoff/1_MAIN_MANUSCRIPT_FINAL.docx.revision.bak` | Backup (pre-revision) |
| `.agents/tasks/smartspend-final-revision/images/` | 40 DOCX images extracted |
| `.agents/tasks/smartspend-final-revision/images/blurred/` | 9 blurred images (8 GCash + 1 Figure 12) |

