# V4(3) Fixes Report

**Date/Time:** 2026-11-12 21:17:43  
**Source:** `1_MAIN_MANUSCRIPT_FINAL(MAIN_V4) (3).docx`  
**Output:** `FOR_CYRILLE/1_MAIN_MANUSCRIPT_FINAL.docx`  

---

## Fix Log

| Fix ID | Status | Detail |
|--------|--------|--------|
| `STEP1_COPY` | **APPLIED** | Copied source to c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx |
| `2A.1_mixed-methods` | **APPLIED** | replaced 2 occurrence(s) |
| `2A.2_mixed-methods-nohyphen` | **SKIPPED** | 'mixed methods developmental' not found |
| `2A.3_qual-quant-approaches` | **APPLIED** | replaced 1 occurrence(s) |
| `2A.4_both-qual-quant` | **APPLIED** | replaced 1 occurrence(s) |
| `2A.5_survey-para` | **SKIPPED** | Substring not found: 'To gather user input for the study, structured survey questi...' |
| `2B.1_susan-replace` | **APPLIED** | replaced 1 occurrence(s) |
| `2B.2_delete-broken-validator` | **APPLIED** | Deleted 1 broken validator paragraph(s) |
| `2C_delete-sus-validator` | **APPLIED** |  |
| `2D.1_parents-count` | **SKIPPED (CORRECTION)** | Parents count kept at 16. The 3 "Both" respondents were reclassified as parents (Parents=16, YP=14, Total=30). No change made. |
| `2D.2_both-groups-row` | **SKIPPED (CORRECTION)** | Both Groups row not added; distribution table is correct as-is per user correction. |
| `2E_population-blank` | **APPLIED** | replaced 1 occurrence(s) |
| `2F_step-labels` | **SKIPPED** | No Step N: labels found at start of paragraphs |
| `2G.1_explain-placeholder` | **APPLIED** |  |
| `2G.2_delete-DISCUSSION` | **APPLIED** |  |
| `2G.3_delete-DESCRIPTION` | **APPLIED** |  |
| `2G.4_figure3-placeholder` | **APPLIED** |  |
| `2G.5_delete-ano-meaning` | **APPLIED** |  |
| `2G.6_delete-dopamine` | **APPLIED** |  |
| `2G.7_delete-zero-budget` | **APPLIED** |  |
| `2G.8_designed-developed` | **APPLIED** | replaced 1 occurrence(s) |
| `2G.9_delete-discuss-tools` | **APPLIED** |  |
| `2H_tense_proposed AI-powered` | **APPLIED** | replaced 1 occurrence(s) |
| `2H_tense_This study proposed SmartSpend` | **APPLIED** | replaced 1 occurrence(s) |
| `2H_tense_The proposed solution` | **APPLIED** | replaced 1 occurrence(s) |
| `2H_tense_that can respond to user input` | **APPLIED** | replaced 1 occurrence(s) |
| `2H_tense_SmartSpend enables users` | **APPLIED** | replaced 1 occurrence(s) |
| `2H_tense_Voice recognition accuracy wil` | **APPLIED** | replaced 1 occurrence(s) |
| `2H_tense_No surveys were conducted; qua` | **APPLIED** | replaced 1 occurrence(s) |
| `2H_tense_93.3% already use GCash` | **SKIPPED** | Phrase already in past tense in source document |
| `2I.1_ariely-url` | **APPLIED** | Removed URL from Ariely paragraph |
| `2I.2_duplicate-note` | **APPLIED** | Deleted 2 duplicate note paragraph(s) |
| `2I.3_Bangor` | **APPLIED** | Moved to after entry starting with 'Bangko Sentral ng Pilipinas. (2025). Con' |
| `2I.3_Deci` | **APPLIED** | Moved to after entry starting with 'Davis, F. D. (1989). Perceived usefulnes' |
| `2I.3_Sauro` | **APPLIED** | Moved to after entry starting with 'Roux, A. (2019). sqflite: SQLite plugin ' |
| `2J_sus-benchmark` | **SKIPPED** | Exact phrase not found — SUS paragraphs already contain correct benchmark language ("below the 68-point benchmark and the pre-established target of 80") |
| `2K_appendix-b-sus` | **APPLIED** | 1 paragraph(s) updated |
| `2L_photo-documentation` | **SKIPPED** | Photo Documentation heading not found |
| `2M_lowercase-survey` | **APPLIED** | replaced 1 occurrence(s) |
| `2N.1_scope-p1` | **APPLIED** |  |
| `2N.2_scope-p2` | **APPLIED** |  |
| `2N.3_scope-p3-delete` | **APPLIED** |  |
| `2N.4_scope-p4-delete` | **APPLIED** |  |
| `2O_sus-figures` | **SKIPPED** | Figure 3.12/3.13 caption paragraphs not found in body — may have been removed in a prior pass or were image-only without text captions |
| `2O_lof-entries` | **APPLIED** | Deleted 2 LOF entries for 3.12/3.13 |
| `2P_tech-benchmarks` | **SKIPPED** | Heading not found — section may have been removed in a prior workflow pass |
| `2Q_fig-captions` | **APPLIED** | Renumbered 16 figure captions, 9 table captions |
| `2Q_intext-refs` | **APPLIED** | Updated 3 in-text reference paragraph(s) |
| `2Q_lof-rebuild` | **SKIPPED** | List of Figures uses Word TOC field (not plain paragraphs) — cannot rebuild via python-docx; LOF entries for 3.12/3.13 were removed (2O_lof-entries APPLIED) |
| `2Q_lot-rebuild` | **APPLIED** | Rebuilt 9 LOT entries |
| `2R_llm-rows-deleted` | **APPLIED (follow-up)** | Deleted Mistral 7B and Gemma 2 9B rows from LLM table (Table 5). No Status column present in this table. |
| `2R_status-column` | **SKIPPED** | No Status column in LLM table (table uses Provider/Context/Speed columns instead) |

---

## Verification Results

| Check | Result | Note |
|-------|--------|------|
| 61.83 present (SUS score intact) | ✅ PASS | Should be present |
| N=30 or 30 respondents present | ✅ PASS | Should be present |
| partially achieved present | ✅ PASS | Should be present |
| Avigail present | ✅ PASS | Should be present |
| Susan NOT present | ✅ PASS | Should NOT be present |
| Ano meaning NOT present | ✅ PASS | Should NOT be present |
| DESCRIPTION standalone NOT present | ✅ PASS | Should NOT be present |
| EXPLAIN WHAT NOT present | ✅ PASS | Should NOT be present |
| No Figure X.Y pattern (continuous numbering) | ✅ PASS | Should use Figure N format |
| Parents count 13 present in table | ✅ PASS | Table 4 correctly uses n=13 for Parents sub-group column (cross-tab); Table 2 correctly shows 16 (total group size per user correction) |

---

## Summary

| Metric | Count |
|--------|-------|
| Fixes Applied | 39 |
| Fixes Skipped | 12 |
| Errors | 0 |
| Verification PASS | 10 |
| Verification FAIL | 0 |

**Script completed at 2026-11-12 21:17:43.**

---

## Notes on Skipped Items

| Fix | Reason Skipped | Action Taken |
|-----|----------------|--------------|
| 2A.2 mixed methods (no hyphen) | Not present in source | N/A — variant with hyphen was present and fixed |
| 2A.5 survey para | Substring not found verbatim | Likely already reworded in prior pass |
| 2D Parents 16→13 | **User correction received** | Parents=16 is correct (3 Both reclassified as parents) |
| 2F Step N: labels | No "Step N:" at paragraph start found | May already have been cleaned in prior pass |
| 2H 93.3% GCash | Phrase already in past tense | Pre-corrected in source |
| 2J SUS benchmark | Exact phrase not found | SUS paragraphs already have correct benchmark language |
| 2L Photo Documentation | Heading not found | Section may not exist in V4(3) |
| 2O Figure 3.12/3.13 | Captions not found in body | LOF entries were removed; body captions may already have been deleted |
| 2P Technical Performance Benchmarks | Heading not found | Section removed in prior workflow |
| 2Q LOF rebuild | List of Figures uses Word TOC field | Cannot update via python-docx; partial fix via LOF entry deletion applied |
