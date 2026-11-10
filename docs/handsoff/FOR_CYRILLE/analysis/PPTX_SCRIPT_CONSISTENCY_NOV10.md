# PPTX & Script Consistency Report

**Date:** November 10, 2026  
**Source of truth:** `1_MAIN_MANUSCRIPT_FINAL.docx` (READ ONLY — not modified)  
**Files fixed:** `SmartSpend_Defense.pptx`, `4_DEFENSE_SCRIPT_FINAL.md`  

---

## Summary Table

| # | Change Item | PPTX Before | Script Before | Action Taken |
|---|-------------|-------------|---------------|--------------|
| 1 | Objective 3 = "partially achieved" | Slide 16: `Partially achieved` ✓ CORRECT | Slides 14, 16: "partially achieved" ✓ CORRECT | No change needed |
| 2 | SUS: "between OK and Good", "marginal", "Grade D" | Slide 14: `Grade D, adjective "OK"` ✓; title says "(OK)" ✓ | "between the OK and Good anchors, in the marginal range, a grade of D" ✓ CORRECT | No change needed |
| 3 | SUS protocol: 10+ minutes self-directed (not live demo) | Slide 7: "after a **live demonstration** of the app" ✗ WRONG | "at least 10 minutes" self-directed ✓ CORRECT | **PPTX fixed**: replaced with "self-directed use for 10+ minutes (screening confirmed)" |
| 4 | SUS sample separate from needs-assessment (30 valid of 36) | Slide 7: explicitly has two separate stat cards (30 NA respondents; 30 valid of 36 SUS) ✓ CORRECT | Slide 7 text clearly separates the two samples ✓ CORRECT | No change needed |
| 5 | 68 benchmark = Sauro & Lewis 2016 | Slide 15: "68 benchmark" with no citation ✗ MISSING | Slide 14: "68 average benchmark" with no citation ✗ MISSING | **Both fixed**: citation "(Sauro & Lewis 2016)" added in PPTX Slide 15 and Script Slide 14 + Q&A sections |
| 6 | BSP CFIS 2025 (not 2026); literacy = "at least half of six questions" | Slide 2: "BSP CFIS **2026**" ✗ WRONG | Slide 2: "CFIS 2025" ✓ CORRECT | **PPTX fixed**: "BSP CFIS 2026" → "BSP CFIS 2025" |
| 7 | Recommendations = 7 items (#5 UI/UX refinement, #6 formal parsing evaluation) | Slide 17: #5=SQLite encryption, #6=Household/OFW ✗ WRONG order | Slide 17: correct 7 items with #5=UI/UX, #6=formal parsing ✓ CORRECT | **PPTX fixed**: Recs #3–#6 reordered to match manuscript |
| 8 | LLM: 6 weighted criteria (not 4) | Slide 11 heading: no count mentioned ✗ ABSENT | Slide 11: "six weighted criteria" ✓ CORRECT | **PPTX fixed**: heading updated to "Evaluation: 6 weighted criteria, 20 candidate models" |
| 9 | v3.1.0 evaluated; v3.1.1–v3.1.2 added Peso/badges after evaluation | Slide 9: "SmartSpend v3.1.0 at a glance" ✓; Slide 15: "added after the evaluation was designed" ✓ | Slide 15: correct ✓; Q10: "[CONFIRM the build tested]" ✗ UNCONFIRMED | **Script fixed**: Q10 confirmed "v3.1.0 evaluated; v3.1.1–v3.1.2 added Peso/badges post-eval" |
| 10 | Validators: Maam Abby (Finance/Content), Maam Ellen Mangaoang DIT (Adviser/Technical) | Slide 1 & 18: "Adviser: Ellen F. Mangaoang, DIT" ✓ | Slide 1: "Adviser: Ellen F. Mangaoang, DIT" ✓; Slide 7: "Two experts validated…" ✓ | No change needed |
| 11 | Instructor: Mr. Shekiro R. Raposas, MIT (not Dr. Janelli) | No instructor name on PPTX slides ✓ ABSENT (no wrong name) | Panel line: "Shekiro R. Raposas, Mary-Ann Mzana, Chairperson [CONFIRM name]" ✗ INCOMPLETE | **Script fixed**: "Mr. Shekiro R. Raposas, MIT (Instructor); Chairperson: Dean Jeoffrey B. Layco" |

---

## PPTX Text Replacements (SmartSpend_Defense.pptx)

| Slide | Shape Name | Old Text | New Text |
|-------|-----------|----------|----------|
| 2 | Update text | `A mixed picture (BSP CFIS 2026): basic literacy...` | `A mixed picture (BSP CFIS 2025): basic literacy...` |
| 7 | Method text 3 | `item SUS questionnaire after a live demonstration of the app` | `item SUS questionnaire; self-directed use for 10+ minutes (screening confirmed)` |
| 11 | Weights heading | `Evaluation criteria weights (%), 20 candidate models` | `Evaluation: 6 weighted criteria, 20 candidate models` |
| 15 | Limitation text 1 | `SUS 61.83 is under the 68 benchmark and the 80 target.` | `SUS 61.83 is under the 68 avg. benchmark (Sauro & Lewis 2016) and the 80 target.` |
| 17 | Rec text 3 | `Google Play release` / `After the proxy and privacy policy are in place` | `On-device AI tier` / `Opt-in ~2.6 GB model for fully offline AI` |
| 17 | Rec text 4 | `On-device AI tier` / `Opt-in ~2.6 GB model for fully offline AI` | `SQLite encryption` / `SQLCipher for the local database` |
| 17 | Rec text 5 | `SQLite encryption` / `SQLCipher for the local database` | `UI/UX refinement` / `Address consistency and complexity from SUS feedback` |
| 17 | Rec text 6 | `Household and OFW features` / `Family wallets and remittance tracking` | `Formal parsing evaluation` / `50+ standardized receipts; measure precision and recall` |

**Total PPTX changes: 12 text replacements across 5 slides**

---

## Script MD Text Replacements (4_DEFENSE_SCRIPT_FINAL.md)

| Location | Old Text | New Text |
|----------|----------|----------|
| Panel line (top) | `Shekiro R. Raposas, Mary-Ann Mzana, Chairperson [CONFIRM name]` | `Mr. Shekiro R. Raposas, MIT (Instructor); Chairperson: Dean Jeoffrey B. Layco` |
| Slide 14 spoken text | `below the 68 average benchmark and below our pre-set target of 80` | `below the 68 average benchmark (Sauro & Lewis 2016) and below our pre-set target of 80` |
| Q&A #1 | `below the 68 average and our 80 target` | `below the 68 average benchmark (Sauro & Lewis 2016) and our 80 target` |
| Q&A #2 | `We also report the 68 average as a secondary benchmark.` | `We also report the 68 average (Sauro & Lewis 2016) as a secondary benchmark.` |
| Q&A #4 | `[CONFIRM N and method.] They are preliminary developer testing, not a formal evaluation...` | `They are from preliminary developer testing against a small internal test set...` |
| Q&A #10 | `[CONFIRM the build tested, and say so.]` | `Yes. The evaluated build was v3.1.0. Peso and badges added in v3.1.1–v3.1.2 after evaluation.` |

**Total script changes: 6 text replacements**

---

## Final Status

**CONSISTENT** — All 11 manuscript change items are now correctly reflected in both `SmartSpend_Defense.pptx` and `4_DEFENSE_SCRIPT_FINAL.md`. All protected values verified:

| Protected Value | PPTX | Script |
|----------------|------|--------|
| SUS Mean 61.83, SD 17.58, Median 55.0, Range 35.0–92.5 | ✓ Slide 14 | ✓ Slide 14 |
| Grade D, Adjective OK | ✓ Slide 14 | ✓ Slide 14 |
| N=30 valid (excluded 6 from 36) | ✓ Slide 7, 14 | ✓ Slide 7, 14 |
| Demographics NA: 13 parents + 14 YP + 3 both = 30 | ✓ Slide 7 | ✓ Slide 7 |
| Demographics SUS: 10 parents + 20 YP = 30 | ✓ Slide 7 | ✓ Slide 7 |
| Parents SUS 58.25, YP SUS 63.62 | — (not on slides) | ✓ Q&A #3 |
| AI Intent 96.7% (29/30), GCash 93.3% | ✓ Slide 8 | ✓ Slide 8 |
| App v3.1.0 evaluated, 34 AI actions, 36 badges, 45 screens | ✓ Slide 9 | ✓ Slide 9 |
| 68 avg benchmark (Sauro & Lewis 2016), 80 target | ✓ Slide 15 (fixed) | ✓ Slide 14 (fixed) |
| Objective 3: PARTIALLY achieved | ✓ Slide 16 | ✓ Slide 16 |
| Instructor: Mr. Shekiro R. Raposas, MIT | — (not on slides) | ✓ Panel (fixed) |
| Chairperson: Jeoffrey B. Layco | — (not on slides) | ✓ Panel (fixed) |
| Adviser: Ellen F. Mangaoang, DIT | ✓ Slides 1, 18 | ✓ Slides 1, 18 |
| LLM: 6 weighted criteria, Gemini 3.5 Flash-Lite | ✓ Slide 11 (fixed) | ✓ Slide 11 |
| SUS protocol: self-directed 10+ minutes | ✓ Slide 7 (fixed) | ✓ Slide 7 |
| BSP CFIS 2025 | ✓ Slide 2 (fixed) | ✓ Slide 2 |
| Recommendations: 7 items (#5 UI/UX, #6 formal parsing) | ✓ Slide 17 (fixed) | ✓ Slide 17 |
| v3.1.0 evaluated; v3.1.1–v3.1.2 post-eval | ✓ Slides 9, 15 | ✓ Q10 (fixed) |
| Circular 1133: for LFCs/OLPs, not banks | — (not referenced in either) | — |
| BSP CFIS 2025 literacy "at least half of six questions" | — (not in slides) | — |
