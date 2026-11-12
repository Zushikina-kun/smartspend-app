"""
apply_fixes.py — SmartSpend manuscript APPLY_NOW fixes (Nov 16 defense prep)

Applies text replacements from the RECONCILE_PLAN.md APPLY_NOW items.
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
# Main fix sequence
# ---------------------------------------------------------------------------

def main():
    if not MANUSCRIPT.exists():
        print(f"ERROR: Manuscript not found at {MANUSCRIPT}")
        sys.exit(1)

    print(f"=== SmartSpend apply_fixes.py ===")
    print(f"Manuscript : {MANUSCRIPT}")
    print(f"Backup     : {BACKUP}\n")

    # Save backup BEFORE any changes
    BACKUP.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(MANUSCRIPT, BACKUP)
    print(f"[BACKUP] Saved backup to {BACKUP}\n")

    doc = Document(str(MANUSCRIPT))
    total = 0

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
    # Also try without curly quotes
    total += replace_in_doc(
        doc,
        "Present Peso as a design feature, not as evidence of behaviour change, and avoid phrases such as \u201cdopamine reinforcement\u201d.",
        "",
        "A3", "delete instruction sentence (curly quotes)"
    )
    total += replace_in_doc(doc, "These behaviours applied the same ideas", "These behaviors applied the same ideas", "A3", "behaviour→behavior")
    total += replace_in_doc(doc, "so their effect on user behaviour has not been measured", "so their effect on user behavior has not been measured", "A3", "behaviour→behavior")
    # Catch any remaining British spellings in Peso paragraph context
    total += replace_in_doc(doc, " behaviour ", " behavior ", "A3", "behaviour→behavior generic")
    total += replace_in_doc(doc, " behaviours ", " behaviors ", "A3", "behaviours→behaviors generic")

    # ------------------------------------------------------------------
    # A4 — fix remaining Susan Arquisal reference (ALREADY_DONE tag but
    #       reconciliation plan still lists it as APPLY_NOW for the specific sentence)
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
    # A7 — conclusion wording
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
    # Also handle curly-quote variant
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
    # ASCII dash variant
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
    # B6 — SUS exclusions
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
    # B7 — Step 4 criteria + Obj 2 (ALREADY_DONE per plan but apply text fixes)
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
    # B15 — Table 2.1 → Table 1.2 (verify and fix)
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
        "B17", "proxy sentence"
    )
    # Variant without PDF mention
    total += replace_in_doc(
        doc,
        "Additional enhancements included the implementation of a backend proxy server",
        "A backend proxy server for API key handling and SQLite database encryption were identified as enhancements but were not implemented in this study (Chapter IV, Recommendations 3 and 4).",
        "B17", "proxy sentence variant"
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
    # Already partially handled in A4; catch any remaining
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
    # Age range: replace standalone "20–35" (young professionals) with "21–35"
    # Use an exact string to avoid touching larger ranges
    for target in ["20\u201335", "20-35"]:
        total += replace_in_doc(doc, target, "21\u201335", "C", f"age range 20–35→21–35 ({target})")

    # Raposas credential: add MIS if missing
    total += replace_in_doc(doc, "Raposas, MTS (Instructor)", "Raposas, MTS, MIS (Instructor)", "C", "Raposas MIS credential")
    total += replace_in_doc(doc, "Raposas, MTS (Capstone Teacher", "Raposas, MTS, MIS (Capstone Teacher", "C", "Raposas MIS credential 2")

    # ------------------------------------------------------------------
    # A5 — delete stray TOC lines
    # ------------------------------------------------------------------
    print("\n--- A5: Delete stray figure lines ---")
    # These appear as paragraphs with tab-separated page numbers
    stray_lines = [
        "Figure 3.12.  SUS Score Distribution (N = 30)\t70",
        "Figure 3.13.  SUS Scores by Respondent Group (N = 30)\t71",
        "Figure 3.14.  Demographic Distribution of Needs-Assessment Respondents (N = 30)\t44",
        # Variants with single space
        "Figure 3.12. SUS Score Distribution (N = 30)\t70",
        "Figure 3.13. SUS Scores by Respondent Group (N = 30)\t71",
        "Figure 3.14. Demographic Distribution of Needs-Assessment Respondents (N = 30)\t44",
    ]
    for line in stray_lines:
        total += delete_para_if_contains(doc, line, "A5")

    # Also replace using the tab-stripped version
    stray_replacements = [
        ("Figure 3.12.  SUS Score Distribution (N = 30)", ""),
        ("Figure 3.13.  SUS Scores by Respondent Group (N = 30)", ""),
        ("Figure 3.14.  Demographic Distribution of Needs-Assessment Respondents (N = 30)", ""),
    ]
    for old, new in stray_replacements:
        # Only replace if they appear as stand-alone body lines (not captions)
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
    # Delete all occurrences (the reconciliation plan says delete duplicates)
    # We will delete all and let the manual step place one correct note under Table 3.1
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
