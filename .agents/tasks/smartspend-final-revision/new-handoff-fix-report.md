# SmartSpend Manuscript — New Handoff Fix Report

**Date:** 2026-11-13  
**Working DOCX:** `docs/handsoff/1_MAIN_MANUSCRIPT_FINAL.docx` (22,846,922 bytes)  
**PPT:** `docs/handsoff/FOR_CYRILLE/SmartSpend_Defense.pptx`  
**Script:** `docs/handsoff/FOR_CYRILLE/4_DEFENSE_SCRIPT_FINAL.md`  
**Verification:** `verify_all_three.py` — 67/67 PASS  
**Review verdict (Pass 2):** BLOCKER-1 found and resolved (see below)

---

## All 10 Fixes — What Was Changed

### FIX 1 — Duplicate Figure 6 deleted; Figures renumbered 6–16
The original manuscript contained a duplicate "Figure 6: Demographic Distribution…" which belonged to Figure 5. The duplicate caption was removed and all figure captions and in-text references were renumbered sequentially from Figure 6 through Figure 16.  
**Result:** 16 unique figure captions confirmed, no duplicate content.

### FIX 2 — Table renumbering (Tables 5–8)
The ghost "Table 5" (Demographic Distribution — content that is Figure 5, not a data table) was removed. Tables were renumbered:
- Former Table 7 (Demographic Profile) → **Table 5** (wait: re-audit resolved to Table 5 → 8 final numbering below)
- Final body numbering: Table 1–4 (unchanged), Table 5 = Demographics, Table 6 = LLM APIs, Table 7 = Overall SUS Result, Table 8 = SUS by Respondent Group.

In-text references to old table numbers were updated throughout the manuscript.  
**Result:** 8 table captions in body matching TOC list of tables.

### FIX 3 — TOC rebuilt (List of Figures, List of Tables, chapter/section outline)
The TOC was entirely empty of figure and table entries. Added:
- 16 figure entries (Figure 1–16) with correct captions
- 8 table entries (Table 1–8) with correct captions, colon style
- Full chapter/section outline: front matter, Chapters I–IV, References, Appendices
- Figure 1 TOC entry: citation "(BSP, 2021; Inquiro, 2024)" correctly removed (body caption retains it)
- No standalone "INTRODUCTION" paragraph left in TOC range

**Result:** 16 figure + 8 table entries in TOC confirmed (P93–P118), chapter outline present (P120–P152).

### FIX 4 — Caption punctuation (table captions: colon style)
All table body captions standardized to `Table N: Title` format.

**Caveat / BLOCKER-1 resolution:** The `apply_all_10_fixes.py` script's FIX 4 `table_cap_fixes` targeted pre-renumber patterns (`Table 8. Overall SUS Result`, `Table 9. …`) that no longer existed by the time FIX 4 ran (FIX 2 had already renumbered them to `Table 7.` and `Table 8.`). The two SUS-result body captions were left in period style. This was caught by Pass 2 review (BLOCKER-1).

**Resolution applied in this handoff:** Body captions at P679 and P690 manually patched:
- `Table 7. Overall SUS Result` → `Table 7: Overall SUS Result`
- `Table 8. System Usability Scale (SUS) Results by Respondent Group` → `Table 8: System Usability Scale (SUS) Results by Respondent Group`

Post-fix verification: zero `Table 7.` or `Table 8.` period-style patterns remain. All 16 figure captions use period style; all 8 table captions use colon style — consistent throughout.

### FIX 5 — Chapter III headings corrected
- P363: `Usability Evaluation of SmartSpend Using the System Usability Scale (SUS)` ✓
- P316: `System Development Results` ✓
- P288: `Assessment of the Financial Management Practices, Budgeting Challenges, and Expense Tracking Behaviors of Parents and Young Professionals` ✓
- TOC entries updated to match (P134, P136, P138) ✓

### FIX 6 — Table 3 note added
P251: `Note. The content validator participated separately and is not included in the respondent total of 30.` ✓

### FIX 7 — "eight candidate LLM APIs" text
Replaced incorrect `20 candidate LLM models` with `eight candidate LLM APIs` in body.  
**Result:** No `20 candidate LLM models` found; `eight candidate LLM APIs` confirmed present.

### FIX 8 — Appendix cross-references
- P261: `(see Appendix B)` in informed consent paragraph ✓
- P255: `(see Appendix D)` in Avigail Candevario paragraph ✓

### FIX 9 — "Adviser:" label on title page
**Complexity note:** The title page uses a structured table/paragraph layout. The `Adviser:` label was inserted as a distinct paragraph (P20) immediately before the adviser name paragraph (P22: `Ellen Flores Mangaoang, DIT`). No formatting or layout disruption detected.  
**Result:** `Adviser:` label present at P20 ✓

### FIX 10 — PPT and defense script synchronized
- All figure/table renumbering reflected in PPT slides and script
- `Gemini 1.5` occurrences replaced with `Gemini 3.5 Flash-Lite` in PPT (slides 12 & 17, including group shapes) and script
- Table number references in script updated to match manuscript final numbering
- `verify_all_three.py`: PPT 10/10 PASS, SCRIPT 9/9 PASS ✓

---

## verify_all_three.py Results — 67/67 PASS

All 67 checks passed on the final DOCX + PPT + script:

| Suite | Checks | Result |
|---|---|---|
| DOCX protected values | 48 | PASS |
| PPT sync | 10 | PASS |
| Script sync | 9 | PASS |
| **Total** | **67** | **67/67 PASS** |

Note: `verify_all_three.py` does not include a caption-punctuation check for body table captions. The BLOCKER-1 period-style captions were not caught by this suite; they were caught by manual review and have since been patched.

---

## Protected Values — Confirmed Intact

| Value | Status |
|---|---|
| SUS score 61.83 | ✓ preserved |
| SD 17.58 | ✓ preserved |
| Sample N = 30 | ✓ preserved |
| SUS grade D / "OK" | ✓ preserved |
| "partially achieved" | ✓ preserved |
| Needs-assessment split: 16 parents + 14 YP = 30 | ✓ preserved |
| SUS subgroup split: 10 parents + 20 YP = 30 | ✓ preserved |
| GCash usage 93.3% (28/30) | ✓ preserved |
| AI intent 96.7% (29/30) | ✓ preserved |
| Avigail Candevario, PFMe | ✓ preserved |
| Jeoffrey B. Layco, MIS (panel chair) | ✓ preserved |
| Shekiro R. Raposas MTS/MIS | ✓ preserved |
| Mary-Ann Mzana MTS | ✓ preserved |
| Ellen Flores Mangaoang, DIT (adviser) | ✓ preserved |
| Gemini 3.5 Flash-Lite | ✓ preserved (Gemini 1.5 → corrected) |
| 9 recommendations | ✓ preserved |

---

## Review Verdict

**Pass 1:** APPROVED (all 10 fixes applied, 67/67 pass)  
**Pass 2:** CHANGES_REQUESTED — 1 blocker found

### BLOCKER-1 (resolved)
- **Finding:** Body captions at P369/P372 (now P679/P690 after full rebuild) used period style (`Table 7. …`, `Table 8. …`) instead of required colon style.  
- **Root cause:** FIX 4 script targeted pre-renumber patterns that FIX 2 had already changed.  
- **Resolution:** Direct XML patch replacing both period-style strings. Verified zero period-style table captions remain.  
- **Status:** RESOLVED ✓

---

## Files Delivered

| File | Description |
|---|---|
| `docs/handsoff/1_MAIN_MANUSCRIPT_FINAL.docx` | Final manuscript — all 10 fixes + BLOCKER-1 resolved |
| `docs/handsoff/FOR_CYRILLE/SmartSpend_Defense.pptx` | Defense presentation — synced with manuscript |
| `docs/handsoff/FOR_CYRILLE/4_DEFENSE_SCRIPT_FINAL.md` | Defense script — synced with manuscript |
