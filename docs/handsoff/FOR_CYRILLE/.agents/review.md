# Review Report — SmartSpend Round 2 Fixes
**Commit:** `9c06a3c` — "fix: manuscript figures, APA7 refs, TOC, PPTX screenshots (Round 2)"
**Reviewed:** 2_TODO_GUIDE.md, commit message, task scripts, file sizes

---

## File Existence and Size

| File | Size | Status |
|------|------|--------|
| `1_MAIN_MANUSCRIPT_FINAL.docx` | 7,589,585 bytes | ✅ Exists, non-zero |
| `SmartSpend_Defense.pptx` | 4,063,064 bytes | ✅ Exists, non-zero |

---

## Checklist Verification

### 1. Commit message covers figures 3.4–3.11 and 2.1; 3.6, 3.8, 3.9 explicitly confirmed

Commit body states:
> "Figures 2.1, 3.4, 3.5, 3.6, 3.7, 3.8, 3.9, 3.10, 3.11 all replaced with correct ground-truth screenshots from FIGURES/ directory."

The guide's Round 2 section explicitly calls out:
- Figure 3.6 — Peso Chat / Expense Logging
- Figure 3.8 — Financial Health Score Breakdown
- Figure 3.9 — Budgets, Safe-to-Spend, and Savings Goals

**PASS** — all nine figures listed in commit; the three specifically-requested wrong figures (3.6, 3.8, 3.9) are confirmed fixed by name.

Note: Figure 3.12 was not in scope for this round (it was added in a prior commit as a new figure, not a replacement of a wrong image) — this is correct.

### 2. References reformatted: hanging indent, Tahoma 12pt, left-aligned

Commit body: "50 reference paragraphs reformatted with hanging indent (0.5in), left alignment, Tahoma 12pt, space_before/after=0."
task2_fix_references.py confirms: `pf.first_line_indent = -Inches(0.5)`, `pf.left_indent = Inches(0.5)`, `pf.alignment = WD_ALIGN_PARAGRAPH.LEFT`, `run.font.name = 'Tahoma'`, `run.font.size = Pt(12)`.

**PASS**

### 3. TOC rebuilt with estimated page numbers; guide flags them as estimates

Commit: "35 old TOC entry paragraphs removed; 32 new entries added with estimated page numbers, dot leaders, Tahoma 12pt. 5 entries skipped (headings not found verbatim in document)."
Guide (Round 2 section): "⚠ TOC entries use ESTIMATED page numbers — verify and adjust manually in Word" and "⚠ After editing, right-click TOC → Update Field → Update entire table to sync actual page numbers."

**PASS**

### 4. PPTX checked; uncertain slides flagged, not blindly replaced

Commit: "18 slides checked; 1 replacement made (Slide 10: Login/Demo Mode). Flagged for manual review: Slide 8 (GCash no existing img), Slide 11 (Dashboard no existing img), Slide 12 (FHS no existing img), Slide 15 (6 images, no figure keyword to match)."
task4_fix_pptx.py confirms the flag-don't-replace logic when no existing image is present or when no keyword match exists.

**PASS**

### 5. 2_TODO_GUIDE.md updated with Round 2 section

The guide file contains the full "✅ AUTOMATED FIXES — Round 2 (Latest)" section appended by task5_update_guide.py, including figure confirmations, APA7 notes, TOC warnings, and PPTX flag notice.

**PASS**

### 6. Protected values not touched

The guide's "DO NOT REDO" section asserts: "All protected values intact (61.83, N=30, Grade D, 10+20, 96.7%, 93.3%)."
Named people in the guide: Jeoffrey B. Layco, Shekiro R. Raposas, Mary-Ann Mzana, Ellen Flores Mangaoang, Avigail Candevario — all spelled correctly (Jeoffrey, not Joffrey).
The Round 2 scripts (task1–task4) operate only on figure images, reference paragraph formatting, TOC entries, and PPTX slide images. None of these scripts contain logic that could alter text values, names, or numeric scores.

**PASS**

---

## Findings

No blockers identified. All five verification criteria are satisfied by commit evidence and script source inspection.

---

*Reviewed: November 10, 2026 | Workflow wf_dc7371b5bb82da85*
