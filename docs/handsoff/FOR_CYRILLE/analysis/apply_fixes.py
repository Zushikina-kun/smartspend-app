"""
apply_fixes.py — SmartSpend manuscript APPLY_NOW fixes (Nov 16 defense prep)
VERSION 2: Addresses BLOCKER-1 through BLOCKER-5 from review.json plus
all APPLY_NOW items from RECONCILE_PLAN.md.

Saves a backup first, then overwrites the original.

Usage:
    python apply_fixes.py

Logs each replacement to stdout as:
    [ITEM_ID] REPLACED: <old snippet> → <new snippet>
    [ITEM_ID] NOT FOUND: <search snippet>
"""

import shutil
import sys
from pathlib import Path

try:
    from docx import Document
    from docx.oxml.ns import qn
except ImportError:
    print("ERROR: python-docx is not installed. Run: pip install python-docx")
    sys.exit(1)

MANUSCRIPT = Path(
    r"c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx"
)
BACKUP = Path(
    r"c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\analysis\MANUSCRIPT_BACKUP_BEFORE_FIXES.docx"
)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _full_text(para):
    """Return the concatenated text of all runs in a paragraph."""
    return "".join(r.text for r in para.runs)


def _replace_in_para(para, old, new):
    """
    Replace `old` with `new` inside a paragraph.
    Strategy:
      1. Try to find `old` within a single run — replace there (preserves formatting).
      2. Fall back to rebuilding the first run with the replaced text and clearing others.
    Returns True if a replacement was made.
    """
    # Pass 1: single-run match
    for run in para.runs:
        if old in run.text:
            run.text = run.text.replace(old, new)
            return True

    # Pass 2: multi-run match (concatenate all run texts)
    full = _full_text(para)
    if old not in full:
        return False

    replaced = full.replace(old, new, 1)  # replace first occurrence only
    # Put everything into the first run, blank the rest
    if para.runs:
        para.runs[0].text = replaced
        for run in para.runs[1:]:
            run.text = ""
    else:
        # No runs at all — add one
        run = para.add_run(replaced)
    return True


def replace_in_doc(doc, old, new, item_id, description="", max_replacements=None):
    """
    Search every paragraph (body + headers/footers + table cells) for `old`
    and replace with `new`.  Logs each hit.
    Returns the number of replacements made.
    """
    count = 0

    def _process_para(para):
        nonlocal count
        if max_replacements is not None and count >= max_replacements:
            return
        full = _full_text(para)
        if old not in full:
            return
        made = _replace_in_para(para, old, new)
        if made:
            count += 1
            snippet_old = old[:80].replace("\n", " ")
            snippet_new = new[:80].replace("\n", " ") if new else "(deleted)"
            tag = description or item_id
            print(f"  [{item_id}] REPLACED ({tag}): «{snippet_old}» → «{snippet_new}»")

    # Body paragraphs
    for para in doc.paragraphs:
        _process_para(para)

    # Table cells
    for table in doc.tables:
        for row in table.rows:
            for cell in row.cells:
                for para in cell.paragraphs:
                    _process_para(para)

    # Headers / footers in each section
    for section in doc.sections:
        for hf in [section.header, section.footer,
                   section.even_page_header, section.even_page_footer,
                   section.first_page_header, section.first_page_footer]:
            if hf is not None:
                for para in hf.paragraphs:
                    _process_para(para)

    if count == 0:
        snippet = old[:80].replace("\n", " ")
        print(f"  [{item_id}] NOT FOUND: «{snippet}»")

    return count


def delete_para_if_contains(doc, substring, item_id):
    """Delete entire paragraphs whose full text contains `substring`."""
    count = 0
    for para in doc.paragraphs:
        if substring in _full_text(para):
            # Remove the paragraph XML node from its parent
            p = para._element
            p.getparent().remove(p)
            count += 1
            print(f"  [{item_id}] DELETED PARAGRAPH containing: «{substring[:80]}»")
    return count


# ---------------------------------------------------------------------------
# Table-cell fix for B8
# ---------------------------------------------------------------------------

def fix_b8_gemini37_table(doc):
    """
    B8: In Table 3.2 find the row for Gemini 3.7 Flash.
    If the Provider cell (col 1) contains a status sentence starting with 'Not used:',
    move it to the Status cell (last column) and set Provider cell to 'Google'.
    """
    item_id = "B8"
    fixed = False
    for tbl_idx, table in enumerate(doc.tables):
        for row in table.rows:
            cells = row.cells
            if not cells:
                continue
            first_cell_text = "".join(p.text for p in cells[0].paragraphs)
            if "3.7 Flash" in first_cell_text or "Gemini 3.7" in first_cell_text:
                # Identify the provider cell (col 1) and status cell (last col)
                if len(cells) < 3:
                    continue
                provider_cell = cells[1]
                status_cell = cells[-1]
                provider_text = "".join(p.text for p in provider_cell.paragraphs)
                if "Not used:" in provider_text:
                    # Move text
                    status_text = "".join(p.text for p in status_cell.paragraphs)
                    # Set provider cell to Google
                    for p in provider_cell.paragraphs:
                        for run in p.runs:
                            run.text = ""
                        if p.runs:
                            p.runs[0].text = "Google"
                        else:
                            p.add_run("Google")
                    # Set status cell: append the moved text if not already there
                    if provider_text.strip() not in status_text:
                        for p in status_cell.paragraphs:
                            for run in p.runs:
                                run.text = ""
                        if status_cell.paragraphs:
                            p = status_cell.paragraphs[0]
                            if p.runs:
                                p.runs[0].text = provider_text.strip()
                            else:
                                p.add_run(provider_text.strip())
                    print(f"  [{item_id}] FIXED table {tbl_idx} Gemini 3.7 Flash row: "
                          f"Provider ← 'Google', Status ← '{provider_text.strip()[:60]}'")
                    fixed = True
    if not fixed:
        print(f"  [{item_id}] NOT FOUND: Gemini 3.7 Flash row with 'Not used:' in Provider cell")


# ---------------------------------------------------------------------------
# BLOCKER fixes (from review.json CHANGES_REQUESTED findings)
# ---------------------------------------------------------------------------

def fix_blocker1_abstract(doc):
    """
    BLOCKER-1: Remove duplicate benchmark tail from abstract.
    Also fix 'a an eight-provider' → 'an eight-provider'.
    """
    item_id = "BLOCKER-1"
    count = 0
    # Fix double article: 'a an eight-provider' → 'an eight-provider'
    count += replace_in_doc(doc, "a an eight-provider", "an eight-provider", item_id, "double article fix")
    # Remove trailing duplicate: '— below the 68-point benchmark (Sauro & Lewis, 2016) and the pre-established target of 80.'
    # This tail appears after the main benchmark sentence
    tail = " \u2014 below the 68-point benchmark (Sauro & Lewis, 2016) and the pre-established target of 80."
    count += replace_in_doc(doc, tail, ".", item_id, "remove duplicate benchmark tail")
    # Also em-dash variants
    tail2 = " — below the 68-point benchmark (Sauro & Lewis, 2016) and the pre-established target of 80."
    count += replace_in_doc(doc, tail2, ".", item_id, "remove duplicate benchmark tail (ASCII)")
    # Variant: ends without period on tail
    tail3 = "— below the 68-point benchmark (Sauro & Lewis, 2016) and the pre-established target of 80"
    count += replace_in_doc(doc, tail3, "", item_id, "remove duplicate tail (no period)")
    return count


def fix_blocker2_abstract_overclaim(doc):
    """
    BLOCKER-2: Fix 'successfully developed' overclaim in abstract.
    """
    item_id = "BLOCKER-2"
    count = 0
    # The abstract reads: 'SmartSpend version 3.1.0 was successfully developed as an offline-first Android application'
    count += replace_in_doc(
        doc,
        "SmartSpend version 3.1.0 was successfully developed as an offline-first Android application",
        "SmartSpend v3.1.0 was developed as a working Android prototype",
        item_id, "abstract overclaim fix"
    )
    # Also catch variant with 'SmartSpend v3.1.0'
    count += replace_in_doc(
        doc,
        "SmartSpend v3.1.0 was successfully developed as an offline-first Android application",
        "SmartSpend v3.1.0 was developed as a working Android prototype",
        item_id, "abstract overclaim fix (v3.1.0 variant)"
    )
    return count


def fix_blocker3_chiv_conclusions(doc):
    """
    BLOCKER-3: Replace truncated/incomplete Ch IV Conclusions with full 3-paragraph block.
    The current para is 'SmartSpend ' (exactly, as an isolated truncated para).
    Replace it with Obj 3 conclusion. Also fix the Obj 2 paragraph and insert Obj 1 before it.
    """
    item_id = "BLOCKER-3"
    count = 0
    from docx.oxml import OxmlElement
    from copy import deepcopy

    obj1_conclusion = (
        "Objective 1 was to assess the financial management practices, budgeting challenges, and "
        "expense-tracking behaviors of parents aged 35 to 55 and young professionals aged 21 to 35 "
        "in San Fernando City. The needs assessment of 30 respondents showed that 90.0% track expenses "
        "through receipts, 53.3% through mental estimates, and only 10.0% through a mobile app, while "
        "96.7% intend to use an AI-powered financial app and 93.3% already use GCash. The first objective "
        "was achieved."
    )

    obj2_conclusion = (
        "Objective 2 was to design and develop SmartSpend, with an LLM API chosen through comparative "
        "technical evaluation. SmartSpend v3.1.0 was developed as a working Android application with "
        "34 autonomous AI actions, Gemini 3.5 Flash-Lite as the primary model with seven fallback providers, "
        "an optional private local model, and a Financial Health Score. The second objective was achieved. "
        "Security remains prototype-grade, and accuracy figures come from preliminary developer testing."
    )

    obj3_conclusion = (
        "Objective 3 was to evaluate usability and performance using the System Usability Scale and user "
        "feedback. The mean SUS score of 61.83 (SD = 17.58, N = 30) corresponds to an adjective rating "
        "of \u201cOK\u201d (Bangor et al., 2009) and Grade D on the Sauro and Lewis (2016) scale, below "
        "the 68 average benchmark and the pre-set target of 80, and is marginal under the acceptability "
        "criteria. Users reported strong intent to use the app often (4.35 out of 5) and confidence (4.19), "
        "while consistency (Q6), complexity (Q2), and need for technical support (Q4) were the main concerns. "
        "Because usability was evaluated but the target was not met, and performance was assessed only "
        "preliminarily, the third objective was partially achieved."
    )

    # Step 1: Replace the EXACT truncated 'SmartSpend ' paragraph (body paragraphs only,
    # matching paragraphs whose stripped text is exactly 'SmartSpend' or 'SmartSpend ')
    truncated_found = False
    for para in doc.paragraphs:
        full = _full_text(para)
        if full.strip() == "SmartSpend":
            if para.runs:
                para.runs[0].text = obj3_conclusion
                for run in para.runs[1:]:
                    run.text = ""
            else:
                para.add_run(obj3_conclusion)
            print(f"  [{item_id}] REPLACED exact truncated 'SmartSpend' para → Obj 3 conclusion")
            count += 1
            truncated_found = True
            break
    if not truncated_found:
        print(f"  [{item_id}] NOT FOUND: exact truncated 'SmartSpend' paragraph")

    # Step 2: Fix the existing Obj 2 paragraph
    for para in doc.paragraphs:
        full = _full_text(para)
        if (full.startswith("SmartSpend v3.1.0 was developed as a working Android application") and
                "Prototype Observed Financial Health Indicator" in full):
            if para.runs:
                para.runs[0].text = obj2_conclusion
                for run in para.runs[1:]:
                    run.text = ""
            else:
                para.add_run(obj2_conclusion)
            print(f"  [{item_id}] REPLACED Obj 2 conclusion paragraph")
            count += 1
            break

    # Step 3: Insert Obj 1 before Obj 2 (find Obj 2 by its new text)
    obj2_para_ref = None
    for para in doc.paragraphs:
        full = _full_text(para)
        if full.startswith("Objective 2 was to design and develop SmartSpend"):
            obj2_para_ref = para
            break

    if obj2_para_ref is not None:
        # Only insert if Obj 1 is not already present just before Obj 2
        # Check the paragraph just before by traversing the XML
        prev_elem = obj2_para_ref._element.getprevious()
        prev_text = ""
        if prev_elem is not None:
            # Try to get text from previous sibling
            from docx.oxml.ns import qn as _qn
            for t in prev_elem.iter(_qn('w:t')):
                prev_text += t.text or ""

        if "Objective 1 was to assess" not in prev_text:
            new_para_elem = OxmlElement('w:p')
            pPr = obj2_para_ref._element.find(qn('w:pPr'))
            if pPr is not None:
                new_para_elem.insert(0, deepcopy(pPr))
            r_elem = OxmlElement('w:r')
            t_elem = OxmlElement('w:t')
            t_elem.text = obj1_conclusion
            t_elem.set('{http://www.w3.org/XML/1998/namespace}space', 'preserve')
            r_elem.append(t_elem)
            new_para_elem.append(r_elem)
            obj2_para_ref._element.addprevious(new_para_elem)
            print(f"  [{item_id}] INSERTED Obj 1 conclusion paragraph before Obj 2")
            count += 1
        else:
            print(f"  [{item_id}] Obj 1 already present before Obj 2, skipping insert")
    else:
        print(f"  [{item_id}] NOTE: Could not find Obj 2 conclusion paragraph for Obj 1 insertion")

    return count


def fix_blocker4_recommendations(doc):
    """
    BLOCKER-4: Add Rec 1 (UI/UX refinement) and Rec 2 (formal parsing evaluation)
    to Ch IV Recommendations, then renumber existing items.
    Current order: 1=payday cycle, 2=backend proxy, 3=Google Play, 4=on-device AI,
                   5=SQLite, 6=household, 7=longitudinal
    Target order:  1=UI/UX, 2=parsing eval, 3=payday cycle, ... renumbered
    Strategy: Find item 1 (payday cycle), insert Rec 1 and 2 before it, renumber.
    """
    item_id = "BLOCKER-4"
    count = 0

    rec1_text = (
        "1. UI/UX refinement. The researchers recommended that the developers address the main usability "
        "concerns identified in the SUS evaluation: consistency (Q6), complexity (Q2), and the need for "
        "technical support (Q4). Specific improvements include simplifying navigation for first-time users, "
        "improving visual consistency across the 45 screens, and adding contextual help or tooltips to "
        "reduce the need for technical assistance."
    )

    rec2_text = (
        "2. Formal parsing evaluation. The researchers recommended that the developers conduct a formal "
        "evaluation of the AI parsing and OCR features using at least 50 standardized receipts and "
        "GCash screenshots, replacing the preliminary developer testing figures of 91.2% precision and "
        "88.5% recall with results from a reproducible test protocol."
    )

    # Find the paragraph for Rec 1 (payday cycle) — currently numbered "1."
    payday_para_idx = None
    for i, para in enumerate(doc.paragraphs):
        full = _full_text(para)
        if full.strip().startswith("1. Payday-cycle") or \
           (full.strip().startswith("1.") and "Payday-cycle" in full) or \
           (full.strip().startswith("1.") and "payday-cycle" in full.lower()):
            payday_para_idx = i
            break

    if payday_para_idx is not None:
        payday_para = doc.paragraphs[payday_para_idx]
        # Renumber existing items: 1→3, 2→4 (but actually we want 1-payday→3, so renumber 1-7 → 3-9... but plan says 8 total)
        # Per RECONCILE_PLAN.md A8 ordering:
        # 1=UI/UX, 2=parsing eval, 3=backend proxy+Google Play, 4=SQLite, 5=on-device AI,
        # 6=payday cycle, 7=household, 8=longitudinal
        # Current: 1=payday, 2=backend proxy, 3=Google Play, 4=on-device, 5=SQLite, 6=household, 7=longitudinal
        # Let's renumber:
        renumber_map = [
            ("1. Payday-cycle-aware budgeting.", "6. Payday-cycle-aware budgeting."),
            ("2. Backend API proxy and per-user keys.", "3. Backend API proxy and per-user keys."),
            ("3. Google Play release.", "4. Google Play release."),
            ("4. On-device AI tier.", "5. On-device AI tier."),
            ("5. SQLite encryption.", "4. SQLite encryption."),
            ("6. Household and remittance features.", "7. Household and remittance features."),
            ("7. Longitudinal evaluation.", "8. Longitudinal evaluation."),
        ]
        # Actually, per plan A8, the 8 items are:
        # 1=UI/UX, 2=formal parsing, 3=backend proxy, 4=SQLite, 5=on-device AI,
        # 6=payday cycle, 7=household/remittance, 8=longitudinal
        # So renumber:
        renumber_map = [
            ("1. Payday-cycle-aware budgeting.", "6. Payday-cycle-aware budgeting."),
            ("2. Backend API proxy and per-user keys.", "3. Backend API proxy and per-user keys."),
            ("3. Google Play release.", "— A Google Play release."),  # merge with proxy rec
            ("4. On-device AI tier.", "5. On-device AI tier."),
            ("5. SQLite encryption.", "4. SQLite encryption."),
            ("6. Household and remittance features.", "7. Household and remittance features."),
            ("7. Longitudinal evaluation.", "8. Longitudinal evaluation."),
        ]

        for old_num, new_num in renumber_map:
            count += replace_in_doc(doc, old_num, new_num, item_id, f"renumber {old_num[:20]}")

        from docx.oxml import OxmlElement
        from copy import deepcopy

        # Re-find payday para (now numbered "6.")
        payday_para_new_idx = None
        for i, para in enumerate(doc.paragraphs):
            full = _full_text(para)
            if "6. Payday-cycle-aware budgeting." in full:
                payday_para_new_idx = i
                break

        if payday_para_new_idx is None:
            # Fall back: find near the recommendations header
            for i, para in enumerate(doc.paragraphs):
                full = _full_text(para)
                if "Payday-cycle-aware" in full:
                    payday_para_new_idx = i
                    break

        if payday_para_new_idx is not None:
            payday_para = doc.paragraphs[payday_para_new_idx]
            # Insert Rec 2 before the payday paragraph
            new_para2 = OxmlElement('w:p')
            pPr = payday_para._element.find(qn('w:pPr'))
            if pPr is not None:
                new_para2.insert(0, deepcopy(pPr))
            r2 = OxmlElement('w:r')
            t2 = OxmlElement('w:t')
            t2.text = rec2_text
            t2.set('{http://www.w3.org/XML/1998/namespace}space', 'preserve')
            r2.append(t2)
            new_para2.append(r2)
            payday_para._element.addprevious(new_para2)
            print(f"  [{item_id}] INSERTED Rec 2 (formal parsing evaluation) before payday cycle")
            count += 1

            # Now re-find and insert Rec 1 before Rec 2
            # Find the new Rec 2 paragraph
            for i, para in enumerate(doc.paragraphs):
                full = _full_text(para)
                if "2. Formal parsing evaluation." in full:
                    new_para1 = OxmlElement('w:p')
                    pPr = para._element.find(qn('w:pPr'))
                    if pPr is not None:
                        new_para1.insert(0, deepcopy(pPr))
                    r1 = OxmlElement('w:r')
                    t1 = OxmlElement('w:t')
                    t1.text = rec1_text
                    t1.set('{http://www.w3.org/XML/1998/namespace}space', 'preserve')
                    r1.append(t1)
                    new_para1.append(r1)
                    para._element.addprevious(new_para1)
                    print(f"  [{item_id}] INSERTED Rec 1 (UI/UX refinement) before Rec 2")
                    count += 1
                    break
        else:
            print(f"  [{item_id}] WARNING: Could not find payday-cycle paragraph to insert before")
    else:
        print(f"  [{item_id}] NOT FOUND: payday-cycle recommendation paragraph (Rec 1)")

    return count


def fix_blocker5_exclusion_paragraph(doc):
    """
    BLOCKER-5: Fix the doubled/garbled exclusion paragraph in Ch III SUS section.
    The current text has the opening phrase doubled and an orphaned tail.
    Replace the whole garbled paragraph with the correct single-sentence text.
    """
    item_id = "BLOCKER-5"
    count = 0

    # The garbled text pattern:
    garbled_markers = [
        "Of 36 respondents who attempted the survey, Of 36 respondents",
        "and were included in the final analysis. The remaining 6 were excluded: 5 for insufficient app usage time and 1 for straight-line response bias",
    ]

    correct_exclusion = (
        "Of 36 respondents who attempted the survey, 31 confirmed using the app for the required "
        "minimum duration; 1 of these was excluded for straight-line responding, leaving 30 valid "
        "respondents. The other 5 were excluded for insufficient usage time."
    )

    for para in doc.paragraphs:
        full = _full_text(para)
        if "Of 36 respondents who attempted the survey, Of 36" in full:
            if para.runs:
                para.runs[0].text = correct_exclusion
                for run in para.runs[1:]:
                    run.text = ""
            else:
                para.add_run(correct_exclusion)
            print(f"  [{item_id}] FIXED doubled exclusion paragraph")
            count += 1
            break

    # Also check for the orphaned tail fragment
    for para in doc.paragraphs:
        full = _full_text(para)
        if "and were included in the final analysis. The remaining 6 were excluded: 5 for insufficient app usage time and 1 for straight-line response bias" in full:
            # This is the orphaned tail - delete it
            p = para._element
            p.getparent().remove(p)
            print(f"  [{item_id}] DELETED orphaned exclusion tail paragraph")
            count += 1
            break

    if count == 0:
        # Try to find and fix without exact doubled text (might be a single garbled sentence)
        for para in doc.paragraphs:
            full = _full_text(para)
            if ("Of 36 respondents" in full and
                "and were included in the final analysis" in full and
                "The remaining 6 were excluded" in full):
                if para.runs:
                    para.runs[0].text = correct_exclusion
                    for run in para.runs[1:]:
                        run.text = ""
                print(f"  [{item_id}] FIXED garbled exclusion paragraph (single-para variant)")
                count += 1
                break
        if count == 0:
            print(f"  [{item_id}] NOT FOUND: garbled exclusion paragraph (may already be fixed)")

    return count


# ---------------------------------------------------------------------------
# Main fix sequence
# ---------------------------------------------------------------------------

def main():
    if not MANUSCRIPT.exists():
        print(f"ERROR: Manuscript not found at {MANUSCRIPT}")
        sys.exit(1)

    print(f"=== SmartSpend apply_fixes.py (v2 — BLOCKERS + APPLY_NOW) ===")
    print(f"Manuscript : {MANUSCRIPT}")
    print(f"Backup     : {BACKUP}\n")

    # Save backup BEFORE any changes
    BACKUP.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(MANUSCRIPT, BACKUP)
    print(f"[BACKUP] Saved backup to {BACKUP}\n")

    doc = Document(str(MANUSCRIPT))
    total = 0

    # ==================================================================
    # PRIORITY: Fix BLOCKERS from review.json first
    # ==================================================================

    print("=== BLOCKER FIXES (from review.json CHANGES_REQUESTED) ===\n")

    print("--- BLOCKER-1: Abstract — double article + duplicate benchmark tail ---")
    total += fix_blocker1_abstract(doc)

    print("\n--- BLOCKER-2: Abstract — 'successfully developed' overclaim ---")
    total += fix_blocker2_abstract_overclaim(doc)

    print("\n--- BLOCKER-3: Ch IV — truncated Conclusions (insert Obj 1 + Obj 3) ---")
    total += fix_blocker3_chiv_conclusions(doc)

    print("\n--- BLOCKER-4: Ch IV — add Rec 1 and Rec 2, renumber existing ---")
    total += fix_blocker4_recommendations(doc)

    print("\n--- BLOCKER-5: Ch III SUS — fix doubled/garbled exclusion paragraph ---")
    total += fix_blocker5_exclusion_paragraph(doc)

    # ==================================================================
    # APPLY_NOW items from RECONCILE_PLAN.md
    # ==================================================================

    print("\n=== APPLY_NOW FIXES (RECONCILE_PLAN.md) ===\n")

    # ------------------------------------------------------------------
    # A3 — delete leftover instruction + British spellings
    # ------------------------------------------------------------------
    print("--- A3: Leftover instruction + British spellings ---")
    total += replace_in_doc(
        doc,
        'Present Peso as a design feature, not as evidence of behaviour change, and avoid phrases such as "dopamine reinforcement".',
        "",
        "A3", "delete instruction sentence"
    )
    total += replace_in_doc(
        doc,
        "Present Peso as a design feature, not as evidence of behaviour change, and avoid phrases such as \u201cdopamine reinforcement\u201d.",
        "",
        "A3", "delete instruction sentence (curly quotes)"
    )
    total += replace_in_doc(doc, "These behaviours applied the same ideas", "These behaviors applied the same ideas", "A3", "behaviour→behavior")
    total += replace_in_doc(doc, "so their effect on user behaviour has not been measured", "so their effect on user behavior has not been measured", "A3", "behaviour→behavior")
    total += replace_in_doc(doc, " behaviour ", " behavior ", "A3", "behaviour→behavior generic")
    total += replace_in_doc(doc, " behaviours ", " behaviors ", "A3", "behaviours→behaviors generic")

    # ------------------------------------------------------------------
    # A4 — fix remaining Susan Arquisal reference
    # ------------------------------------------------------------------
    print("\n--- A4: Validator name fix ---")
    total += replace_in_doc(
        doc,
        "The survey questionnaire was reviewed by Susan C. Arquisal, a graduate of Bachelor of Science in Commerce major in Management and an active business owner with experience in financial management and business operations, prior to distribution. This review ensured that the questions were appropriate, relevant, and grounded in the actual financial management experiences of the target population.",
        "The survey questionnaire was reviewed by Avigail Candevario, PFMe, a subject matter expert in financial management and business operations, prior to distribution. This review ensured that the questions were appropriate, relevant, and grounded in the actual financial management experiences of the target population.",
        "A4", "Susan Arquisal → Avigail Candevario"
    )
    total += replace_in_doc(
        doc,
        "The expert's credentials was recorded in the Content Validation Certificate (Appendix A).",
        "The expert's credentials were recorded in the Content Validation Certificate (Appendix D). The same content validator also reviewed the Financial Health Score formula (Appendix E).",
        "A4", "Appendix A→D cross-ref"
    )
    total += replace_in_doc(
        doc,
        "Content Validation Certificate (Appendix A)",
        "Content Validation Certificate (Appendix D)",
        "A4", "Appendix A→D"
    )

    # ------------------------------------------------------------------
    # A7 — conclusion wording (the BLOCKER-2/3 fixes cover most; catch remainder)
    # ------------------------------------------------------------------
    print("\n--- A7: Conclusion wording ---")
    total += replace_in_doc(
        doc,
        "below target but acceptable for a prototype system",
        "below the 68 average benchmark and the pre-set target of 80, and rated marginal (not acceptable) under our criteria",
        "A7", "marginal/acceptable fix"
    )
    total += replace_in_doc(
        doc,
        "successfully developed with all identified features implemented",
        "developed as a working Android prototype with the features reported in Chapter III; on-device AI, a backend proxy, and database encryption remain future work",
        "A7", "overclaim fix"
    )

    # ------------------------------------------------------------------
    # A8 — abstract + Table 3.5 recommendations references
    # ------------------------------------------------------------------
    print("\n--- A8: Recommendations references ---")
    total += replace_in_doc(
        doc,
        "Seven recommendations were identified for future development, including UI/UX refinement, a backend API proxy, on-device AI, SQLite encryption, formal parsing evaluation, and a longitudinal study.",
        "Eight recommendations were identified for future development: UI/UX refinement, formal parsing evaluation, a backend API proxy followed by a Google Play release, SQLite encryption, an on-device AI tier, payday-cycle budgeting, household and remittance features, and a longitudinal evaluation.",
        "A8", "abstract recommendations sentence"
    )
    total += replace_in_doc(doc, "Chapter IV, Recommendation 6", "Chapter IV, Recommendation 2", "A8", "Table 3.5 ref fix")
    total += replace_in_doc(doc, "inform the UI/UX recommendations in Chapter IV", "informed Recommendation 1 in Chapter IV", "A8", "SUS paragraph ref fix")

    # ------------------------------------------------------------------
    # B1 — provider count in abstract
    # ------------------------------------------------------------------
    print("\n--- B1: Provider count ---")
    total += replace_in_doc(
        doc,
        "six-provider AI failover chain",
        "an eight-provider cloud failover chain (Gemini 3.5 Flash-Lite as primary, seven fallbacks) plus an optional private local model",
        "B1", "provider count"
    )

    # ------------------------------------------------------------------
    # B2 — grade attribution
    # ------------------------------------------------------------------
    print("\n--- B2: Grade attribution ---")
    total += replace_in_doc(
        doc,
        'corresponding to a grade of D and an adjective rating of "OK" under the Bangor et al. (2009) scale',
        'corresponding to an adjective rating of "OK" (Bangor et al., 2009) and a Grade D on the Sauro and Lewis (2016) curved scale, which is below the 68-point average benchmark (Sauro & Lewis, 2016) and the pre-set target of 80',
        "B2", "abstract grade attribution"
    )
    total += replace_in_doc(
        doc,
        "corresponding to a grade of D and an adjective rating of \u201cOK\u201d under the Bangor et al. (2009) scale",
        "corresponding to an adjective rating of \u201cOK\u201d (Bangor et al., 2009) and a Grade D on the Sauro and Lewis (2016) curved scale, which is below the 68-point average benchmark (Sauro & Lewis, 2016) and the pre-set target of 80",
        "B2", "abstract grade attribution (curly quotes)"
    )
    total += replace_in_doc(
        doc,
        'Per Bangor, Kortum, and Miller (2009), this corresponds to an adjective rating of "OK" (Grade D)',
        'an adjective rating of "OK" (Bangor et al., 2009) and Grade D on the Sauro and Lewis (2016) scale',
        "B2", "Ch III grade attribution"
    )
    total += replace_in_doc(
        doc,
        "Per Bangor, Kortum, and Miller (2009), this corresponds to an adjective rating of \u201cOK\u201d (Grade D)",
        "an adjective rating of \u201cOK\u201d (Bangor et al., 2009) and Grade D on the Sauro and Lewis (2016) scale",
        "B2", "Ch III grade attribution (curly quotes)"
    )
    total += replace_in_doc(
        doc,
        "the 68-point average benchmark established by Bangor et al.",
        "the 68-point average benchmark established by Sauro and Lewis (2016)",
        "B2", "benchmark attribution"
    )

    # ------------------------------------------------------------------
    # B3 — target 80 not "Good"
    # ------------------------------------------------------------------
    print("\n--- B3: Target 80 description ---")
    total += replace_in_doc(
        doc,
        "corresponding to the adjective rating of Good",
        "which lies between the Good (about 71) and Excellent (about 85) adjective anchors of Bangor et al. (2009); it was set as an aspirational threshold before data collection, and the 68 average benchmark (Sauro & Lewis, 2016) served as a secondary reference",
        "B3", "target 80 not Good"
    )

    # ------------------------------------------------------------------
    # B4 — Fig 2.1 description paragraph (text only)
    # ------------------------------------------------------------------
    print("\n--- B4: Fig 2.1 description ---")
    total += replace_in_doc(
        doc,
        "The SUS score ranged from 0 to 100 and is categorized into different levels: Poor (below 60), Marginal (60\u201369), Acceptable (70\u201379), Good (80\u201389), and Excellent (90\u2013100). Higher scores indicated better usability, user satisfaction, and system performance, while lower scores suggested the need for improvements. This scale served as a standardized tool to assess how effectively and efficiently users could interact with the system.",
        "Figure 2.1 shows how SUS scores were interpreted. Scores below 51 were considered not acceptable, 51 to 70 marginal, and 71 and above acceptable (Bangor et al., 2008). The adjective anchors of Bangor et al. (2009) are marked on the scale: OK (about 51), Good (about 71), and Excellent (about 85). The dashed line marks the 68-point average benchmark (Sauro & Lewis, 2016) and the pre-set target is 80.",
        "B4", "Fig 2.1 description"
    )
    total += replace_in_doc(
        doc,
        "The SUS score ranged from 0 to 100 and is categorized into different levels: Poor (below 60), Marginal (60-69), Acceptable (70-79), Good (80-89), and Excellent (90-100). Higher scores indicated better usability, user satisfaction, and system performance, while lower scores suggested the need for improvements. This scale served as a standardized tool to assess how effectively and efficiently users could interact with the system.",
        "Figure 2.1 shows how SUS scores were interpreted. Scores below 51 were considered not acceptable, 51 to 70 marginal, and 71 and above acceptable (Bangor et al., 2008). The adjective anchors of Bangor et al. (2009) are marked on the scale: OK (about 51), Good (about 71), and Excellent (about 85). The dashed line marks the 68-point average benchmark (Sauro & Lewis, 2016) and the pre-set target is 80.",
        "B4", "Fig 2.1 description (ASCII dash)"
    )

    # ------------------------------------------------------------------
    # B5 — SUS item labels
    # ------------------------------------------------------------------
    print("\n--- B5: SUS item labels ---")
    total += replace_in_doc(doc, "complexity (Q2, Q4)", "complexity (Q2) and need for technical support (Q4)", "B5", "Q4 label")

    # ------------------------------------------------------------------
    # B6 — SUS exclusions (the BLOCKER-5 fix handles the garbled para;
    #       this catches remaining simpler variants)
    # ------------------------------------------------------------------
    print("\n--- B6: SUS exclusions ---")
    total += replace_in_doc(
        doc,
        "30 confirmed they used the app for the required minimum duration",
        "Of 36 respondents who attempted the survey, 31 confirmed using the app for the required minimum duration; 1 of these was excluded for straight-line responding, leaving 30 valid respondents. The other 5 were excluded for insufficient usage time.",
        "B6", "exclusion sentence"
    )
    total += replace_in_doc(
        doc,
        "6 excluded for insufficient app usage time",
        "6 excluded (5 for insufficient usage time, 1 for straight-line responding)",
        "B6", "Ch IV exclusion note"
    )

    # ------------------------------------------------------------------
    # B7 — Step 4 criteria + Obj 2
    # ------------------------------------------------------------------
    print("\n--- B7: LLM criteria wording ---")
    total += replace_in_doc(
        doc,
        "inference speed, response accuracy for Filipino-English natural language processing, context window capacity, and cost feasibility for academic deployment",
        "Filipino-English accuracy, inference speed, tool use and JSON reliability, free-tier availability, context window capacity, and financial reasoning quality",
        "B7", "Objective 2 criteria"
    )
    total += replace_in_doc(
        doc,
        "Response latency, accuracy, context window, and cost were recorded and compared.",
        "Latency, Filipino-English accuracy, tool-use reliability, free-tier availability, context window, and financial reasoning were recorded and compared.",
        "B7", "Step 4 criteria"
    )

    # ------------------------------------------------------------------
    # B8 — Table 3.2 Gemini 3.7 provider cell
    # ------------------------------------------------------------------
    print("\n--- B8: Table 3.2 Gemini 3.7 Flash provider cell ---")
    fix_b8_gemini37_table(doc)

    # ------------------------------------------------------------------
    # B14 — Fig 1.1 contradiction
    # ------------------------------------------------------------------
    print("\n--- B14: Fig 1.1 contradiction ---")
    total += replace_in_doc(
        doc,
        "exhibited the lowest rates of formal account ownership and structured budgeting among all adult demographics",
        "carry the main household financial responsibility, yet, as Figure 1.1 shows, fewer than half of Filipino adults kept a household budget (46%) and only 2% answered all six financial literacy questions correctly",
        "B14", "lowest-rates claim fix",
    )

    # ------------------------------------------------------------------
    # B15 — Table 2.1 → Table 1.2
    # ------------------------------------------------------------------
    print("\n--- B15: Table reference fix ---")
    total += replace_in_doc(
        doc,
        "Table 2.1 summarized the key feature differences",
        "Table 1.2 summarized the key feature differences",
        "B15", "Table 2.1→1.2"
    )

    # ------------------------------------------------------------------
    # B16 — garbled sentences
    # ------------------------------------------------------------------
    print("\n--- B16: Garbled sentences ---")
    total += replace_in_doc(doc, "only surveys, not surveys, were used", "only structured survey questionnaires were used", "B16", "garbled sentence 1")
    total += replace_in_doc(doc, "No surveys were conducted; qualitative insights", "No interviews or focus groups were conducted; qualitative insights", "B16", "garbled sentence 2")
    total += replace_in_doc(
        doc,
        "No formal open-ended Survey data was collected. The study used a structured quantitative survey instrument. Qualitative insights were derived from the survey response patterns described above.",
        "Optional comments were invited in the SUS form (Appendix C) but were not analyzed thematically. The study used a structured quantitative survey instrument; qualitative insights were derived from survey response patterns.",
        "B16", "open-ended data sentence"
    )

    # ------------------------------------------------------------------
    # B17 — proxy/encryption sentence
    # ------------------------------------------------------------------
    print("\n--- B17: Proxy/encryption sentence ---")
    total += replace_in_doc(
        doc,
        "Additional enhancements included the implementation of a backend proxy server for secure LLM API key handling, PDF export functionality for financial summaries, and SQLite database encryption.",
        "A backend proxy server for API key handling and SQLite database encryption were identified as enhancements but were not implemented in this study (Chapter IV, Recommendations 3 and 4).",
        "B17", "proxy sentence (full)"
    )
    total += replace_in_doc(
        doc,
        "Additional enhancements included the implementation of a backend proxy server",
        "A backend proxy server for API key handling and SQLite database encryption were identified as enhancements but were not implemented in this study (Chapter IV, Recommendations 3 and 4).",
        "B17", "proxy sentence (partial variant)"
    )

    # ------------------------------------------------------------------
    # B18 — truncated sentence
    # ------------------------------------------------------------------
    print("\n--- B18: Truncated sentence ---")
    total += replace_in_doc(
        doc,
        "(Table 2.2: Agile Kanban Workflow Phases and Deliverables",
        "(see Table 2.2). The system architecture, use-case view, and navigation structure are shown in Figures 3.1 to 3.3.",
        "B18", "truncated parenthetical"
    )

    # ------------------------------------------------------------------
    # B19 — sqflite version + FHS open-item deletion
    # ------------------------------------------------------------------
    print("\n--- B19: sqflite version + FHS open-item ---")
    total += replace_in_doc(doc, "sqflite package (version 11)", "sqflite package (database schema version 14)", "B19", "sqflite version")
    total += replace_in_doc(
        doc,
        "The behavior of this component when zero category budgets were configured was a known open item pending confirmation against the current build and was not asserted here.",
        "",
        "B19", "delete FHS open-item note"
    )

    # ------------------------------------------------------------------
    # B20 — Appendix A→D fix
    # ------------------------------------------------------------------
    print("\n--- B20: Appendix reference fix ---")
    total += replace_in_doc(doc, "Content Validation Certificate (Appendix A)", "Content Validation Certificate (Appendix D)", "B20", "Appendix A→D")

    # ------------------------------------------------------------------
    # B21 — performance disclaimer
    # ------------------------------------------------------------------
    print("\n--- B21: Performance disclaimer ---")
    total += replace_in_doc(
        doc,
        "91.2% precision and 88.5% recall",
        "91.2% precision and 88.5% recall (Performance was assessed only through preliminary developer testing; no formal performance evaluation was conducted, which is why Recommendation 2 proposes one.)",
        "B21", "performance disclaimer addition"
    )

    # ------------------------------------------------------------------
    # C Polish — age range, Raposas credential
    # ------------------------------------------------------------------
    print("\n--- C: Polish fixes ---")
    for target in ["20\u201335", "20-35"]:
        total += replace_in_doc(doc, target, "21\u201335", "C", f"age range 20–35→21–35 ({target})")

    total += replace_in_doc(doc, "Raposas, MTS (Instructor)", "Raposas, MTS, MIS (Instructor)", "C", "Raposas MIS credential")
    total += replace_in_doc(doc, "Raposas, MTS (Capstone Teacher", "Raposas, MTS, MIS (Capstone Teacher", "C", "Raposas MIS credential 2")

    # ------------------------------------------------------------------
    # A5 — delete stray TOC lines
    # ------------------------------------------------------------------
    print("\n--- A5: Delete stray figure lines ---")
    stray_lines = [
        "Figure 3.12.  SUS Score Distribution (N = 30)\t70",
        "Figure 3.13.  SUS Scores by Respondent Group (N = 30)\t71",
        "Figure 3.14.  Demographic Distribution of Needs-Assessment Respondents (N = 30)\t44",
        "Figure 3.12. SUS Score Distribution (N = 30)\t70",
        "Figure 3.13. SUS Scores by Respondent Group (N = 30)\t71",
        "Figure 3.14. Demographic Distribution of Needs-Assessment Respondents (N = 30)\t44",
    ]
    for line in stray_lines:
        total += delete_para_if_contains(doc, line, "A5")

    stray_replacements = [
        ("Figure 3.12.  SUS Score Distribution (N = 30)", ""),
        ("Figure 3.13.  SUS Scores by Respondent Group (N = 30)", ""),
        ("Figure 3.14.  Demographic Distribution of Needs-Assessment Respondents (N = 30)", ""),
    ]
    for old, new in stray_replacements:
        for para in doc.paragraphs:
            full = _full_text(para)
            if full.strip().startswith(old.strip()) and len(full.strip()) < len(old) + 20:
                made = _replace_in_para(para, full.strip(), new)
                if made:
                    total += 1
                    print(f"  [A5] DELETED stray line: «{full.strip()[:80]}»")

    # ------------------------------------------------------------------
    # A5 — relocate/delete duplicate footnotes
    # ------------------------------------------------------------------
    print("\n--- A5: Duplicate footnote notes ---")
    dup_note = "Note: The 3 respondents who identified as both parent and young professional were classified by their primary financial role for SUS subgroup analysis, resulting in a final breakdown of 10 parents and 20 young professionals for statistical comparison (Table 8)."
    count_dups = 0
    for para in doc.paragraphs:
        if dup_note in _full_text(para) or "resulting in a final breakdown of 10 parents and 20 young professionals for statistical comparison (Table 8)" in _full_text(para):
            p = para._element
            p.getparent().remove(p)
            count_dups += 1
            print(f"  [A5] DELETED duplicate footnote note (occurrence {count_dups})")
    total += count_dups

    # ------------------------------------------------------------------
    # C polish — Ariely URL, Gubbins/UNSGSA, NPC citation
    # ------------------------------------------------------------------
    print("\n--- C: References polish ---")
    total += replace_in_doc(doc, "https://www.anthropic.com/claude", "", "C", "Ariely URL deletion")
    total += replace_in_doc(
        doc,
        "UNSGSA. (2021). Measuring financial health: Concepts and considerations.",
        "Gubbins, P., Mazzotta, B., & Rhyne, E. (2021). Measuring financial health: Concepts and considerations. UNSGSA.",
        "C", "Gubbins/UNSGSA citation"
    )
    total += replace_in_doc(
        doc,
        "Republic Act No. 10173",
        "Republic Act No. 10173 (National Privacy Commission, 2012)",
        "C", "NPC citation"
    )

    # ------------------------------------------------------------------
    # C polish — Adviser label on title page
    # ------------------------------------------------------------------
    print("\n--- C: Adviser label ---")
    total += replace_in_doc(doc, "Ellen Flores Mangaoang, DIT", "Adviser: Ellen F. Mangaoang, DIT", "C", "Adviser label")
    total += replace_in_doc(doc, "Ellen F. Mangaoang DIT", "Adviser: Ellen F. Mangaoang, DIT", "C", "Adviser label variant")

    # ------------------------------------------------------------------
    # C polish — Capstone Teacher-in-Charge role name
    # ------------------------------------------------------------------
    total += replace_in_doc(doc, "instructor in charge", "Capstone Teacher-in-Charge", "C", "role name fix")

    # ------------------------------------------------------------------
    # Save
    # ------------------------------------------------------------------
    print(f"\n=== Total replacements made: {total} ===")
    doc.save(str(MANUSCRIPT))
    print(f"[SAVED] {MANUSCRIPT}")
    print("Done.")


if __name__ == "__main__":
    main()
