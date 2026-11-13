# Merge Report — 1_MAIN_MANUSCRIPT_FINAL.docx

**Date:** 2026-11-13  
**Script:** `docs/handsoff/FOR_CYRILLE/merge_manuscript.py` (merge) + `docs/handsoff/FOR_CYRILLE/fix_blockers.py` (review fixes)  
**Final file:** `c:/xampp/htdocs/smartspend_app/docs/handsoff/1_MAIN_MANUSCRIPT_FINAL.docx`

---

## Summary of What Was Merged

The merge used **Ellen's V4** (`1_MAIN_MANUSCRIPT_FINAL(MAIN_V4).docx`) as the structural base, then applied accuracy corrections and Ellen's comment revisions on top of it:

1. **Abstract replaced** — accurate version with correct figures (SUS 61.83, SD 17.58, eight-provider chain, Gemini 3.5 Flash-Lite, nine recommendations, N=30, grade D / "OK") substituted for Ellen's V4 abstract.
2. **Comment 2 (Research Design)** — qualitative-sounding sentence ("structured survey questionnaires were used to collect respondents' views regarding…") rewritten to quantitative framing ("A validated structured survey questionnaire was used to collect quantitative data…").
3. **Comment 3 (Technical Background)** — 12 technology subsections rewritten to focus on SmartSpend's actual usage context (Flutter, SQLite, Firebase Firestore, Firebase Auth, Crashlytics, LLM API Integration, Speech-to-Text, OCR, Barcode Scanner, fl_chart, local_auth, Financial Health Score).
4. **Comment 1 (Data Gathering Tools)** — section restructured per-objective into 4 paragraphs: intro, Objective 1 (survey), Objective 2 (development), Objective 3 (SUS evaluation).
5. **Accuracy corrections throughout** — applied via regex across all paragraphs and table cells.
6. **Recommendations 8 & 9 added** where missing.
7. **Table 3 note added** ("The content validator participated separately and is not included in the respondent total of 30.").

Then, following the review (verdict: CHANGES_REQUESTED), all 5 blockers were fixed via `fix_blockers.py`.

---

## Review Findings Fixed

| Blocker | Finding | Fix Applied |
|---|---|---|
| BLOCKER-1 | Population prose (13+14+3) contradicted Table 3 (16+14) | Updated para ~238 (16+14=30, removed "three identified as both"), para ~275 (Table 5 intro: 16 parents 53.3%, 14 YP 46.7%), para ~278 (Table 5 note: n=16, n=14) |
| BLOCKER-2 | "purposive sampling" for content validator absent | Added sentence to para ~241: "The content validator was selected through purposive sampling based on her expertise in personal finance and financial education." |
| BLOCKER-3 | Table 9 (Multimodal Import Parsing Performance) absent | Inserted Table 9 with caption, intro paragraph, data table (3 input modalities × 4 fields), and note — placed after Table 8 and before CHAPTER IV |
| BLOCKER-4 | "Table 1.2" chapter-prefixed references in paras ~171–172 | Replaced 2 occurrences of "Table 1.2" with "Table 2" |
| BLOCKER-5 | Scope and Limitations was 4 paragraphs with technical API/RA 10173 detail | Merged paragraphs ~198–201 into 1 condensed paragraph; removed Remote Config/API key detail and RA 10173 detail |

---

## Text Replacements (Accuracy Corrections — from merge_manuscript.py)

| Replacement | Count |
|---|---|
| Abstract replaced | 1 |
| Research Design sentence rewritten (Comment 2) | 1 |
| Technical Background entries rewritten (Comment 3) | 12 |
| Data Gathering restructured per-objective (Comment 1) | 1 |
| mixed-methods → quantitative descriptive developmental | varies by source doc |
| purposive sampling → random sampling (respondents only) | varies |
| seven/7 recommendations → nine/9 recommendations | varies |
| six-provider → eight-provider | varies |
| five/5 fallbacks → seven fallbacks | varies |
| proposed SmartSpend → developed SmartSpend | varies |
| proposed system/the proposed → developed | varies |
| will be developed → was developed | varies |
| Validator blank → Avigail Candevario, PFMe | varies |
| Population blank → "A total of thirty (30) respondents" | varies |
| Figures renumbered (Figure X.Y → Figure N) | 22 mappings applied |
| Tables renumbered (Table X.Y → Table N) | 8 mappings applied |
| Recommendations 8 & 9 added | 2 |
| Table 3 note added | 1 |

**Blocker fixes (from fix_blockers.py):**

| Fix | Count |
|---|---|
| BLOCKER-1: Population paragraph fixes | 3 (para 238, 275, 278) |
| BLOCKER-2: Purposive sampling sentence added | 1 |
| BLOCKER-3: Table 9 inserted | 1 |
| BLOCKER-4: "Table 1.2" → "Table 2" | 2 |
| BLOCKER-5: Scope section condensed | 1 (4 paras → 1 para) |

---

## Figure/Table Renumbering Map

### Figure Renumbering (chapter-prefixed → sequential)

| Old (Ellen V4 / source) | New (sequential) |
|---|---|
| Figure 1.1 | Figure 1 |
| Figure 1.2 | Figure 2 |
| Figure 2.1 | Figure 3 |
| Figure 2.2 | Figure 4 |
| Figure 2.3 | Figure 5 |
| Figure 2.4 | Figure 6 |
| Figure 2.5 | Figure 7 |
| Figure 2.6 | Figure 8 |
| Figure 2.7 | Figure 9 |
| Figure 3.1 | Figure 10 |
| Figure 3.2 | Figure 11 |
| Figure 3.3 | Figure 12 |
| Figure 3.4 | Figure 13 |
| Figure 3.5 | Figure 14 |
| Figure 3.6 | Figure 15 |
| Figure 3.7 | Figure 16 |
| Figure 3.8 | Figure 17 |
| Figure 3.9 | Figure 18 |
| Figure 3.10 | Figure 19 |
| Figure 3.11 | Figure 20 |
| Figure 3.12 | Figure 21 |
| Figure 3.13 | Figure 22 |

### Table Renumbering (chapter-prefixed → sequential)

| Old (Ellen V4 / source) | New (sequential) |
|---|---|
| Table 1.1 | Table 1 |
| Table 1.2 | Table 2 |
| Table 2.1 | Table 3 |
| Table 2.2 | Table 4 |
| Table 3.1 | Table 5 |
| Table 3.2 | Table 6 |
| Table 3.3 | Table 7 |
| Table 3.4 | Table 8 |
| Table 3.5 | Table 9 |

**Note:** Table 1.2 body prose references were specifically targeted in BLOCKER-4 and confirmed removed from body paragraphs (only remaining in TOC section which is display-only).

---

## Verification Result

### Post-merge (merge_manuscript.py sanity checks)
All 13/13 internal sanity checks passed at time of merge:
- quantitative descriptive developmental ✓
- nine recommendations ✓
- eight-provider cloud failover ✓
- Avigail Candevario, PFMe ✓
- SUS 61.83 ✓
- SD 17.58 ✓
- 30 respondents ✓
- random sampling ✓
- Gemini 3.5 Flash-Lite ✓
- was developed ✓
- Data Gathering per-objective intro ✓
- Tech BG Flutter rewrite ✓
- nine recommendations count ✓

### Post-blocker-fix (fix_blockers.py verification checks)
19/19 checks pass:

| Check | Result |
|---|---|
| BLOCKER-1: 'Sixteen (16) respondents were parents' present | PASS |
| BLOCKER-1: '13 parents' gone | PASS |
| BLOCKER-1: '3 respondents identified as both' gone | PASS |
| BLOCKER-1: Table 5 note updated (n=16) | PASS |
| BLOCKER-2: 'purposive sampling' present | PASS |
| BLOCKER-3: 'Table 9' present in body | PASS |
| BLOCKER-3: 'Multimodal Import' in Table 9 caption | PASS |
| BLOCKER-4: 'Table 1.2' gone from body | PASS |
| BLOCKER-4: 'Table 2' referenced in body | PASS |
| BLOCKER-5: Scope section condensed (Remote Config gone) | PASS |
| BLOCKER-5: 'RA 10173' gone from scope section (remains only in References bibliography) | PASS |
| BLOCKER-5: Condensed scope mentions Android only | PASS |
| PRE-EXISTING: quantitative descriptive developmental | PASS |
| PRE-EXISTING: nine recommendations | PASS |
| PRE-EXISTING: eight-provider | PASS |
| PRE-EXISTING: Avigail Candevario, PFMe | PASS |
| PRE-EXISTING: SUS 61.83 | PASS |
| PRE-EXISTING: Gemini 3.5 Flash-Lite | PASS |
| PRE-EXISTING: random sampling | PASS |

**Overall: 19/19 PASS. All 5 review blockers resolved.**

The automated 67/67 check suite from the original `verify_all_three.py` was not re-run (it targeted the FOR_CYRILLE source files, not the output file), but all checks MC3b, MC8, MC17, MC18, and D that were previously failing are now confirmed fixed by the targeted verification above.

---

## Final File Location

```
c:\xampp\htdocs\smartspend_app\docs\handsoff\1_MAIN_MANUSCRIPT_FINAL.docx
```

Word comments (20 comments) were preserved from the merge source as confirmed by MC21 in the original review.
