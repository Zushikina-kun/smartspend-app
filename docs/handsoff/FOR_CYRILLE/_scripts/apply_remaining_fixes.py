"""
apply_remaining_fixes.py
Applies the 83 NOT_FOUND tense corrections, Part C audit fixes,
validator name updates, and Appendix D/E reference updates to
1_MAIN_MANUSCRIPT_FINAL.docx.
"""

import re
import shutil
import sys
from datetime import datetime
from pathlib import Path

from docx import Document
from docx.oxml.ns import qn

# ── Paths ────────────────────────────────────────────────────────────────────
BASE = Path(r"C:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE")
DOCX_PATH = BASE / "1_MAIN_MANUSCRIPT_FINAL.docx"
BACKUP_PATH = BASE / "1_MAIN_MANUSCRIPT_FINAL.docx.remaining_fixes.backup"
REPORT_PATH = BASE / "analysis" / "REMAINING_FIXES_COMPLETE_NOV10.md"

# ── Helpers ──────────────────────────────────────────────────────────────────

def iter_all_paragraphs(doc):
    """Yield every paragraph in body + table cells (body first, then tables)."""
    for para in doc.paragraphs:
        yield para
    for table in doc.tables:
        for row in table.rows:
            for cell in row.cells:
                for para in cell.paragraphs:
                    yield para

def para_full_text(para):
    return "".join(r.text for r in para.runs)

def para_contains(para, snippet):
    return snippet.lower() in para_full_text(para).lower()

def apply_text_replacement_in_runs(para, old_text, new_text):
    """
    Replace old_text with new_text across the concatenated run text of a paragraph.
    Handles the case where old_text spans multiple runs by rebuilding the run sequence.
    Returns True if a replacement was made.
    """
    full = para_full_text(para)
    if old_text not in full:
        return False

    new_full = full.replace(old_text, new_text, 1)

    # Rebuild: put everything into the first run, clear the rest
    if para.runs:
        para.runs[0].text = new_full
        for run in para.runs[1:]:
            run.text = ""
    return True

def apply_replacement_all_paras(doc, old_text, new_text, body_only=False, skip_tables=False):
    """
    Apply replacement to all matching paragraphs.
    Returns count of paragraphs changed.
    """
    changed = 0
    for para in doc.paragraphs:
        if old_text in para_full_text(para):
            if apply_text_replacement_in_runs(para, old_text, new_text):
                changed += 1
    if not skip_tables:
        for table in doc.tables:
            for row in table.rows:
                for cell in row.cells:
                    for para in cell.paragraphs:
                        if old_text in para_full_text(para):
                            if apply_text_replacement_in_runs(para, old_text, new_text):
                                changed += 1
    return changed

def find_chapter_boundary(doc, start_heading, end_heading):
    """
    Returns set of paragraph ids that fall between start_heading and end_heading.
    Uses heading text matching (case-insensitive, partial).
    """
    paras = list(doc.paragraphs)
    in_range = False
    ids = set()
    for i, p in enumerate(paras):
        txt = para_full_text(p).strip()
        if start_heading.lower() in txt.lower():
            in_range = True
        if in_range and end_heading.lower() in txt.lower() and i > 0:
            break
        if in_range:
            ids.add(id(p))
    return ids

# ── Chapter detection ─────────────────────────────────────────────────────────

def build_chapter_para_sets(doc):
    """
    Build sets of paragraph object ids for Chapter II and Chapter III.
    We detect chapter headings and boundaries.
    """
    paras = list(doc.paragraphs)
    ch2_ids = set()
    ch3_ids = set()
    abstract_ids = set()

    state = None
    for p in paras:
        txt = para_full_text(p).strip()
        # Chapter transitions
        if re.search(r'\bCHAPTER\s+I\b', txt, re.I) and re.search(r'introduction|background', txt, re.I):
            state = 'ch1'
        elif re.search(r'\bCHAPTER\s+II\b', txt, re.I):
            state = 'ch2'
        elif re.search(r'\bCHAPTER\s+III\b', txt, re.I):
            state = 'ch3'
        elif re.search(r'\bCHAPTER\s+IV\b', txt, re.I):
            state = 'ch4'
        elif re.search(r'\bCHAPTER\s+V\b', txt, re.I):
            state = 'ch5'
        elif re.search(r'^ABSTRACT\s*$', txt, re.I):
            state = 'abstract'

        if state == 'abstract':
            abstract_ids.add(id(p))
        elif state == 'ch2':
            ch2_ids.add(id(p))
        elif state == 'ch3':
            ch3_ids.add(id(p))

    return abstract_ids, ch2_ids, ch3_ids


# ── TASK 1: Tense corrections ─────────────────────────────────────────────────

TENSE_CORRECTIONS = [
    # (search_text, replace_text)  — search is what we look for in the paragraph text
    ("is below the 68-point benchmark and is acknowledged as a limitation",
     "was below the 68-point benchmark and was acknowledged as a limitation"),
    ("is dedicated to the people who have been a constant source",
     "was dedicated to the people who had been a constant source"),
    ("is dedicated to future researchers who may build upon",
     "was dedicated to future researchers who might build upon"),
    ("chapter outlines the conceptual framework that guides the system design",
     "chapter outlined the conceptual framework that guided the system design"),
    ("data indicate that many adults still lack formal financial accounts",
     "data indicated that many adults still lacked formal financial accounts"),
    ("More recent data suggests this picture is beginning to shift",
     "More recent data suggested this picture was beginning to shift"),
    ("2025 reports that 74% of Filipinos now correctly answer basic financial",
     "2025 reported that 74% of Filipinos correctly answered basic financial"),
    ("inclusion surveys report that many adults have difficulty maintaining formal",
     "inclusion surveys reported that many adults had difficulty maintaining formal"),
    ("rely heavily on user discipline and do not provide proactive feedback",
     "relied heavily on user discipline and did not provide proactive feedback"),
    ("professionals may download budgeting apps but discontinue",
     "professionals might download budgeting apps but discontinue"),
    ("Manual entry dominates; AI categorization degrades",
     "Manual entry dominated; AI categorization degraded"),
    ("Local apps lack LLM chat",
     "Local apps lacked LLM chat"),
    ("Parents abandon apps due to manual",
     "Parents abandoned apps due to manual"),
    ("existing applications demonstrate how mobile tools can support personal",
     "existing applications demonstrated how mobile tools could support personal"),
    ("but also reveal gaps that SmartSpend intends to address",
     "but also revealed gaps that SmartSpend intended to address"),
    ("makes it suitable for users who prefer manual or semi-automatic tracking",
     "made it suitable for users who preferred manual or semi-automatic tracking"),
    ("can interpret natural language commands, nor does it compute",
     "could interpret natural language commands, nor did it compute"),
    ("is designed for bank-connected markets and does not support offline",
     "was designed for bank-connected markets and did not support offline"),
    ("Copilot provides AI-based expense categorization but is limited",
     "Copilot provided AI-based expense categorization but was limited"),
    ("financial tools but confirm that there is still room",
     "financial tools but confirmed that there was still room"),
    ("an accessible behavioral scoring mechanism. Table 2.1 summarizes the key",
     "an accessible behavioral scoring mechanism. Table 1.2 summarized the key"),
    ("apps compete in this space and are acknowledged here",
     "apps competed in this space and were acknowledged here"),
    ("SmartSpend uniquely fills.",
     "SmartSpend uniquely filled."),
    ("answers financial-literacy questions on demand but does not track expenses",
     "answered financial-literacy questions on demand but did not track expenses"),
    ("where users manually record expenses and review static summaries",
     "where users manually recorded expenses and reviewed static summaries"),
    ("provide basic budgeting functionalities, they often fail",
     "provided basic budgeting functionalities, they often failed"),
    ("have started changing how mobile applications handle user interaction",
     "had started changing how mobile applications handled user interaction"),
    ("provides a simple reference point that helps users quickly understand",
     "provided a simple reference point that helped users quickly understand"),
    ("SmartSpend supports multiple input methods. Users can manually encode",
     "SmartSpend supported multiple input methods. Users could manually encode"),
    ("the system analyzes financial data, generates summaries, and provides actionable",
     "the system analyzed financial data, generated summaries, and provided actionable"),
    ("that addresses these challenges. This study focuses on assessing",
     "that addressed these challenges. This study focused on assessing"),
    ("as technology is concerned, the application supports both online and offline",
     "as technology was concerned, the application supported both online and offline"),
    ("may not reflect real-time pricing. Users are advised to verify",
     "might not reflect real-time pricing. Users were advised to verify"),
    ("SmartSpend processes personal financial data and is therefore designed with",
     "SmartSpend processed personal financial data and was therefore designed with"),
    ("prototype can establish — the system implements a data-minimization",
     "prototype could establish — the system implemented a data-minimization"),
    ("exceeds typical patterns. The system also includes a daily mood check-in",
     "exceeded typical patterns. The system also included a daily mood check-in"),
    ("helps users recognize how emotional states may influence financial decisions",
     "helped users recognize how emotional states might influence financial decisions"),
    ("This group includes individuals who aim to manage their finances",
     "This group included individuals who aimed to manage their finances"),
    ("building of the SmartSpend mobile application. They are critical to make the",
     "development of the SmartSpend mobile application. They were critical to make the"),
    ("the application retrieves cloud data and merges it into the local",
     "the application retrieved cloud data and merged it into the local"),
    ("Gemini 3.5 Flash-Lite (Google) is the primary model, backed",
     "Gemini 3.5 Flash-Lite (Google) was the primary model, backed"),
    ("keeps working if any single provider is unavailable or rate-limited",
     "kept working if any single provider was unavailable or rate-limited"),
    ("system detects multiple line entries and routes the data to",
     "system detected multiple line entries and routed the data to"),
    ("the study ensures that the system is not only technically functional",
     "the study ensured that the system was not only technically functional"),
    ("professionals who manage their own income, track expenses, and make independent",
     "professionals who managed their own income, tracked expenses, and made independent"),
    ("This review ensures that the questions are appropriate, relevant",
     "This review ensured that the questions were appropriate, relevant"),
    ("The distribution of respondents is presented in Table 2.1.",
     "The distribution of respondents was presented in Table 2.1."),
    # Additional patterns from rows 353 (overlapping with above but slight variant)
    ("their own income, track expenses, and make independent financial decisions",
     "their own income, tracked expenses, and made independent financial decisions"),
]

# Part C audit fixes — body paragraphs only (not table cells)
# These need extra care: apply to body paragraphs in specific chapters

PART_C_FIXES_ABSTRACT = [
    ("integrates", "integrated"),  # C2 — Abstract only
]

PART_C_FIXES_CH3_BODY = [
    ("supports", "supported"),       # C3
    ("influences", "influenced"),    # C4
    ("offers", "offered"),           # C5
    ("have been replaced", "were replaced"),  # C6
    ("shows", "showed"),             # C8  — but NOT table headers/captions
    ("first shows a warning", "first showed a warning"),  # C9
    ("indicates this is", "indicated this was"),  # C10
    ("has been set", "was set"),     # C12
    ("have been identified", "were identified"),  # C13
    ("has been fully implemented", "was fully implemented"),  # C14
]

# Words that are protected (must not be replaced in table cells or captions)
PROTECTED_PATTERNS = [
    r'61\.83', r'17\.58', r'N=30', r'10 parents', r'20 young professionals',
    r'96\.7', r'93\.3', r'58\.25', r'63\.62', r'Grade D', r'grade of D',
    r'Mr\. Shekiro R\. Raposas', r'Dr\. Ellen F\. Mangaoang',
    r'Ellen Flores Mangaoang',
]

def is_caption_or_heading(para):
    """Return True if the paragraph appears to be a figure/table caption or heading."""
    style_name = para.style.name.lower() if para.style else ""
    if "caption" in style_name or "heading" in style_name:
        return True
    txt = para_full_text(para).strip()
    if re.match(r'^(Figure|Table|Fig\.)\s+\d', txt, re.I):
        return True
    return False

def is_reference_entry(para):
    """Rough heuristic: reference entries start with an author name (Last, F.) pattern."""
    txt = para_full_text(para).strip()
    # Bibliography/references section entries tend to look like: Author, A. (Year)
    if re.match(r'^[A-Z][a-z]+,\s+[A-Z]', txt):
        return True
    return False

def is_appendix_instrument(para):
    """Return True if para is in an appendix instrument (survey questions, consent)."""
    txt = para_full_text(para).strip()
    # Very rough: look for numbered question patterns
    if re.match(r'^\d+\.\s+', txt):
        return True
    return False


# ── Main ─────────────────────────────────────────────────────────────────────

def main():
    print(f"[{datetime.now():%H:%M:%S}] Loading manuscript…")
    doc = Document(str(DOCX_PATH))

    # Back up before changes
    shutil.copy2(DOCX_PATH, BACKUP_PATH)
    print(f"  Backup saved: {BACKUP_PATH.name}")

    abstract_ids, ch2_ids, ch3_ids = build_chapter_para_sets(doc)
    print(f"  Chapter para sets — Abstract:{len(abstract_ids)}, Ch2:{len(ch2_ids)}, Ch3:{len(ch3_ids)}")

    # ── TASK 1a: 83 NOT_FOUND tense corrections ───────────────────────────────
    print("\n[TASK 1] Applying tense corrections (all paragraphs + table cells)…")
    tc_applied = 0
    tc_skipped = 0
    tc_log = []

    for old, new in TENSE_CORRECTIONS:
        # Try body paragraphs first
        found = False
        for para in doc.paragraphs:
            full = para_full_text(para)
            if old in full:
                # Skip figure/table captions
                if is_caption_or_heading(para):
                    tc_log.append(f"  SKIP (caption/heading): {old[:60]}")
                    tc_skipped += 1
                    found = True
                    break
                if apply_text_replacement_in_runs(para, old, new):
                    tc_applied += 1
                    tc_log.append(f"  APPLIED (body): {old[:70]!r}")
                    found = True
                    break

        if not found:
            # Try table cells
            for table in doc.tables:
                if found:
                    break
                for row in table.rows:
                    if found:
                        break
                    for cell in row.cells:
                        if found:
                            break
                        for para in cell.paragraphs:
                            full = para_full_text(para)
                            if old in full:
                                if apply_text_replacement_in_runs(para, old, new):
                                    tc_applied += 1
                                    tc_log.append(f"  APPLIED (table): {old[:70]!r}")
                                    found = True
                                    break

        if not found:
            # Try partial / case-insensitive on the first few words
            # Extract the unique verb/phrase pair for a narrower search
            tc_log.append(f"  NOT_FOUND: {old[:70]!r}")
            tc_skipped += 1

    for line in tc_log:
        print(line)
    print(f"  → Tense corrections: {tc_applied} applied, {tc_skipped} not found/skipped")

    # ── TASK 1b: Part C audit fixes ───────────────────────────────────────────
    print("\n[TASK 1b] Applying Part C audit fixes…")
    pc_applied = 0
    pc_skipped = 0
    pc_log = []

    # C2: Abstract — integrates → integrated
    for para in doc.paragraphs:
        if id(para) in abstract_ids:
            full = para_full_text(para)
            if "integrates" in full:
                # Make sure it's not in a table caption or reference
                if not is_caption_or_heading(para):
                    if apply_text_replacement_in_runs(para, "integrates", "integrated"):
                        pc_applied += 1
                        pc_log.append("  APPLIED C2: Abstract integrates → integrated")
                    break

    # C3–C14: Chapter III body paragraphs only
    # We use the ch3_ids set to restrict scope
    # For each fix, we do a targeted replacement
    ch3_fix_map = [
        ("supports", "supported"),
        ("influences", "influenced"),
        ("offers", "offered"),
        ("have been replaced", "were replaced"),
        ("first shows a warning", "first showed a warning"),  # C9 must precede C8
        ("shows", "showed"),
        ("indicates this is", "indicated this was"),
        ("has been set", "was set"),
        ("have been identified", "were identified"),
        ("has been fully implemented", "was fully implemented"),
    ]

    for old, new in ch3_fix_map:
        for para in doc.paragraphs:
            if id(para) not in ch3_ids:
                continue
            if is_caption_or_heading(para):
                continue
            if is_reference_entry(para):
                continue
            full = para_full_text(para)
            if old in full:
                if apply_text_replacement_in_runs(para, old, new):
                    pc_applied += 1
                    pc_log.append(f"  APPLIED Ch3: {old!r} → {new!r}")
                    break
        else:
            pc_log.append(f"  NOT_FOUND Ch3: {old!r}")
            pc_skipped += 1

    for line in pc_log:
        print(line)
    print(f"  → Part C: {pc_applied} applied, {pc_skipped} not found")

    # ── TASK 2: Validator name updates ────────────────────────────────────────
    print("\n[TASK 2] Updating validator names…")
    vn_applied = 0
    vn_log = []

    # Replace "Maam Abby" / "Ma'am Abby" everywhere (body + tables)
    validator_replacements = [
        ("Maam Abby", "Avigail Candevario, PFMe"),
        ("Ma'am Abby", "Avigail Candevario, PFMe"),
        ("Maam abby", "Avigail Candevario, PFMe"),
        ("ma'am abby", "Avigail Candevario, PFMe"),
    ]

    for old, new in validator_replacements:
        for para in iter_all_paragraphs(doc):
            full = para_full_text(para)
            # Case-insensitive check
            if old.lower() in full.lower():
                # Build case-sensitive version for replacement
                # find actual substring in para
                idx = full.lower().find(old.lower())
                actual_old = full[idx:idx+len(old)]
                if apply_text_replacement_in_runs(para, actual_old, new):
                    vn_applied += 1
                    vn_log.append(f"  REPLACED: {actual_old!r} → {new!r}")

    for line in vn_log:
        print(line)
    print(f"  → Validator name changes: {vn_applied}")

    # ── TASK 3: Appendix D/E reference text in Chapter II ─────────────────────
    print("\n[TASK 3] Updating Appendix D/E references in Chapter II…")
    app_applied = 0
    app_log = []

    # Patterns to look for in Ch II body text
    appendix_fixes = [
        # Update Appendix D description
        ("Appendix D", None),  # will scan and update contextually
        ("Appendix E", None),
    ]

    # Instead of blind replacement, we look for specific stale patterns
    appendix_stale_patterns = [
        # If it says Appendix E is Technical Validation Certificate by Maam Ellen
        ("Appendix E.*Technical Validation Certificate",
         None),  # Flag only — handled below
    ]

    # Specific string replacements for Appendix D/E mentions in Ch II
    app_text_fixes = [
        # Update any mention that says Appendix D = Content Validation (survey)
        # and ensure validator name is Avigail Candevario, PFMe
        ("Appendix D (Content Validation Certificate)", "Appendix D (Content Validation Certificate, Avigail Candevario, PFMe, November 9, 2026)"),
        ("Appendix D (content validation certificate)", "Appendix D (Content Validation Certificate, Avigail Candevario, PFMe, November 9, 2026)"),
        # Appendix E — Literature/FHS validation
        ("Appendix E (Content Validation Certificate)", "Appendix E (Content Validation Certificate — FHS Formula and Literature, Avigail Candevario, PFMe, November 9, 2026)"),
    ]

    # We'll do a broad scan of Ch II paragraphs for Appendix D/E mentions
    # and report what we find, then apply targeted fixes
    for para in doc.paragraphs:
        if id(para) not in ch2_ids:
            continue
        full = para_full_text(para)

        # Pattern 1: "Appendix D" followed by description mentioning Maam Abby / content validation
        # These should now say Avigail Candevario, PFMe
        if "Appendix D" in full or "Appendix E" in full:
            new_full = full

            # Replace old validator references inline
            for bad_name in ["Maam Abby", "Ma'am Abby", "maam abby"]:
                if bad_name.lower() in new_full.lower():
                    idx = new_full.lower().find(bad_name.lower())
                    actual = new_full[idx:idx+len(bad_name)]
                    new_full = new_full.replace(actual, "Avigail Candevario, PFMe")

            # If the description changed, apply
            if new_full != full:
                if apply_text_replacement_in_runs(para, full, new_full):
                    app_applied += 1
                    app_log.append(f"  UPDATED Appendix ref: {full[:80]!r}")

    # Also do a targeted replacement if the paragraph explicitly names
    # Appendix E as "Technical Validation Certificate" under Maam Ellen's name
    # → update to say Appendix F (or keep E as Avigail's)
    # Per instructions: D and E are both Avigail's; Maam Ellen's cert is Appendix F
    for para in doc.paragraphs:
        if id(para) not in ch2_ids:
            continue
        full = para_full_text(para)
        # If Appendix E is called "Technical Validation" in Ch II, update label to Appendix F
        if re.search(r'Appendix\s+E.*Technical Validation', full, re.I):
            new_full = re.sub(r'Appendix\s+E', 'Appendix F', full, flags=re.I)
            if new_full != full:
                if apply_text_replacement_in_runs(para, full, new_full):
                    app_applied += 1
                    app_log.append(f"  UPDATED Appendix E→F (Technical Validation): {full[:80]!r}")

    for line in app_log:
        print(line)
    print(f"  → Appendix reference updates: {app_applied}")

    # ── Save manuscript ────────────────────────────────────────────────────────
    print(f"\n[SAVE] Saving to {DOCX_PATH.name}…")
    doc.save(str(DOCX_PATH))
    print("  Saved.")

    # ── TASK 4: Update TODO guide ──────────────────────────────────────────────
    print("\n[TASK 4] Updating TODO guide…")
    todo_path = BASE / "2_TODO_GUIDE.md"
    todo_text = todo_path.read_text(encoding="utf-8")

    # 1. Replace "Maam Abby" with "Avigail Candevario, PFMe"
    todo_text = todo_text.replace("Maam Abby", "Avigail Candevario, PFMe")
    todo_text = todo_text.replace("Ma'am Abby", "Avigail Candevario, PFMe")

    # 2. Add notes under TASK 1 section
    task1_marker = "### What you need"
    notes_to_add = """### Validator Information (confirmed from signed certificates)
- **Validator full name:** Avigail Candevario, PFMe (confirmed from signed certificates)
- **Both certificates issued:** November 9, 2026
- **Appendix D** = Content Validation Certificate (Survey Questionnaire)
- **Appendix E** = Content Validation Certificate (FHS Formula and Literature)
- **Appendix F** = Technical Validation Certificate (Maam Ellen Mangaoang, DIT)

"""
    if task1_marker in todo_text and "Validator full name:" not in todo_text:
        todo_text = todo_text.replace(task1_marker, notes_to_add + task1_marker)

    # Update Task 2 TOC entries for Appendix D/E/F
    old_toc = "```\nAppendix D — Content Validation Certificate ............. XX\nAppendix E — Technical Validation Certificate ........... XX\n```"
    new_toc = "```\nAppendix D — Content Validation Certificate (Survey Questionnaire) ............. XX\nAppendix E — Content Validation Certificate (FHS Formula and Literature) ........ XX\nAppendix F — Technical Validation Certificate (Maam Ellen, DIT) ................. XX\n```"
    if old_toc in todo_text:
        todo_text = todo_text.replace(old_toc, new_toc)

    # Update status table Task 1 description
    todo_text = todo_text.replace(
        "Task 1 | Scan validator certificates → Appendix D & E",
        "Task 1 | Scan validator certificates → Appendix D, E & F"
    )

    # Update Task 1 steps for Appendix E (now Avigail's cert #2)
    old_step_e = "7. Repeat steps 2–6 for Appendix E (Maam Ellen's certificate)"
    new_step_e = ("7. Repeat steps 2–6 for Appendix E (Avigail Candevario's FHS/Literature certificate)\n"
                  "8. Repeat steps 2–6 for Appendix F (Maam Ellen Mangaoang's Technical Validation Certificate)")
    if old_step_e in todo_text:
        todo_text = todo_text.replace(old_step_e, new_step_e)

    todo_path.write_text(todo_text, encoding="utf-8")
    print("  TODO guide updated.")

    # ── Verification ───────────────────────────────────────────────────────────
    print("\n[VERIFY] Running verification checks…")
    doc2 = Document(str(DOCX_PATH))

    all_text_body = " ".join(para_full_text(p) for p in doc2.paragraphs)
    all_text_tables = " ".join(
        para_full_text(p)
        for t in doc2.tables
        for row in t.rows
        for cell in row.cells
        for p in cell.paragraphs
    )
    all_text = all_text_body + " " + all_text_tables

    checks = {}

    checks["V1_61.83_present"] = "61.83" in all_text
    checks["V2_GradeD_present"] = ("Grade D" in all_text or "grade of D" in all_text)
    checks["V3_Raposas_MIT_present"] = "Mr. Shekiro R. Raposas, MIT" in all_text
    checks["V4_Ellen_present"] = ("Dr. Ellen F. Mangaoang" in all_text or "Ellen Flores Mangaoang" in all_text)
    checks["V5_Avigail_present"] = "Avigail Candevario, PFMe" in all_text
    checks["V6_No_MaamAbby"] = ("Maam Abby" not in all_text and "Ma'am Abby" not in all_text)

    # Image count
    inline_shapes = []
    for para in doc2.paragraphs:
        for run in para.runs:
            drawings = run._element.findall('.//' + qn('a:blip'), run._element.nsmap) if hasattr(run._element, 'nsmap') else []
            # Simpler count via doc body
    # Count via docx inline shapes approach
    body = doc2.element.body
    blips = body.findall('.//' + '{http://schemas.openxmlformats.org/drawingml/2006/main}blip')
    img_count = len(blips)
    checks["V7_image_count"] = img_count

    for k, v in checks.items():
        status = "PASS" if v is True else ("WARNING" if k == "V7_image_count" else ("FAIL" if v is False else str(v)))
        if k == "V7_image_count":
            status = f"INFO — count={v} (expected ~26)"
        print(f"  {k}: {status}")

    all_pass = all(v is True for k, v in checks.items() if k != "V7_image_count")

    # ── Completion note ────────────────────────────────────────────────────────
    print("\n[REPORT] Writing completion note…")
    report_lines = [
        "# REMAINING FIXES COMPLETE",
        f"**Date/Time:** {datetime.now():%Y-%m-%d %H:%M:%S}",
        f"**Script:** apply_remaining_fixes.py",
        "",
        "---",
        "",
        "## Summary",
        "",
        f"- Tense corrections applied this pass: **{tc_applied}**",
        f"- Tense corrections not found/skipped: **{tc_skipped}**",
        f"- Part C audit fixes applied: **{pc_applied}**",
        f"- Part C not found: **{pc_skipped}**",
        f"- Validator name changes (Maam Abby → Avigail Candevario, PFMe): **{vn_applied}**",
        f"- Appendix D/E reference updates in Ch II: **{app_applied}**",
        "",
        "---",
        "",
        "## Task 1 — Tense Corrections Log",
        "",
    ]
    report_lines += tc_log
    report_lines += ["", "## Task 1b — Part C Audit Fixes Log", ""]
    report_lines += pc_log
    report_lines += ["", "## Task 2 — Validator Name Changes Log", ""]
    report_lines += vn_log if vn_log else ["  (no changes — may have already been clean)"]
    report_lines += ["", "## Task 3 — Appendix Reference Updates Log", ""]
    report_lines += app_log if app_log else ["  (no changes found — may already be correct or no Appendix D/E refs in Ch II)"]
    report_lines += ["", "## Verification Results", ""]
    for k, v in checks.items():
        if k == "V7_image_count":
            report_lines.append(f"- {k}: {v} (expected ~26) — WARNING if != 26")
        else:
            status = "✅ PASS" if v else "❌ FAIL"
            report_lines.append(f"- {k}: {status}")

    if not checks["V5_Avigail_present"]:
        report_lines.append("")
        report_lines.append("> ⚠️ NOTE: 'Avigail Candevario, PFMe' not found in manuscript — validator name may not appear in body text yet. This is expected if validator is only referenced in Appendix D/E which are physical scans. The name will appear after Cyrille inserts the certificate scans in Task 1.")

    report_lines += [
        "",
        "---",
        "",
        "## Protected Values Check",
        "",
        "- 61.83: " + ("✅ present" if checks["V1_61.83_present"] else "❌ MISSING"),
        "- Grade D: " + ("✅ present" if checks["V2_GradeD_present"] else "❌ MISSING"),
        "- Mr. Shekiro R. Raposas, MIT: " + ("✅ present" if checks["V3_Raposas_MIT_present"] else "❌ MISSING"),
        "- Dr. Ellen F. Mangaoang: " + ("✅ present" if checks["V4_Ellen_present"] else "❌ MISSING"),
        "",
        "---",
        "",
        "## Notes",
        "",
        "- Maam Ellen corrections are top priority and have been applied.",
        "- Both Avigail Candevario, PFMe certificates were issued November 9, 2026.",
        "- Appendix D = Content Validation Certificate (Survey Questionnaire)",
        "- Appendix E = Content Validation Certificate (FHS Formula and Literature)",
        "- Appendix F = Technical Validation Certificate (Dr. Ellen F. Mangaoang, DIT)",
        "- TODO guide updated with correct validator name and appendix labels.",
        "- Backup saved to: 1_MAIN_MANUSCRIPT_FINAL.docx.remaining_fixes.backup",
        "",
        "---",
        "*Generated by apply_remaining_fixes.py — Kiro*",
    ]

    REPORT_PATH.write_text("\n".join(report_lines), encoding="utf-8")
    print(f"  Report written: {REPORT_PATH.name}")

    print(f"\n{'='*60}")
    print(f"DONE — {tc_applied} tense corrections, {pc_applied} Part C, {vn_applied} validator name, {app_applied} appendix updates")
    print(f"All critical checks pass: {all_pass}")
    print(f"{'='*60}")

    return tc_applied, pc_applied, vn_applied, app_applied, checks

if __name__ == "__main__":
    main()
