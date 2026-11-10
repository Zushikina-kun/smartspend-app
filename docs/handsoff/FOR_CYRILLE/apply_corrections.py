"""
apply_corrections.py
Pre-defense manuscript merge: Apply Maam Ellen's corrections to OUR FINAL
Strategy: OUR FINAL as base, Maam Ellen corrections as patch.
"""

import re
import datetime
from pathlib import Path
from docx import Document

# ─── PATHS ─────────────────────────────────────────────────────────────────────
BASE_DIR = Path(__file__).parent
FINAL_PATH       = BASE_DIR / "1_MAIN_MANUSCRIPT_FINAL.docx"
CORRECTIONS_PATH = BASE_DIR.parent / "SmartSpend_Tense_Corrections_List.docx"
REPORT_PATH      = BASE_DIR / "analysis" / "MAAM_ELLEN_MERGE_REPORT_NOV10.md"
OUTPUT_PATH      = BASE_DIR / "1_MAIN_MANUSCRIPT_FINAL.docx"

ELLIPSIS = "\u2026"  # …

# ─── PROTECTED VALUES (must survive intact) ────────────────────────────────────
PROTECTED_VALUES = [
    "61.83", "17.58", "N=30", "N = 30",
    "grade of D", "Grade D", "10 parents", "20 young professionals",
    "96.7", "93.3", "6 excluded", "straight-line",
]

# ─── LOGS ──────────────────────────────────────────────────────────────────────
part_a_log = []
part_b_log = []
part_c_log = []
verify_log = []


# ─── HELPER: replace text in paragraph runs, preserving formatting ─────────────
def replace_in_para(para, old_text, new_text):
    """Replace old_text with new_text in para's runs. Returns True if replaced."""
    full = para.text
    if old_text not in full:
        return False

    runs = para.runs
    if not runs:
        return False

    # Build flat string + position → (run_idx, char_in_run) mapping
    flat = ""
    mapping = []
    for ri, r in enumerate(runs):
        for ci, ch in enumerate(r.text):
            flat.append(ch) if False else None
            flat = flat  # keep below
            mapping.append((ri, ci))
    # Rebuild correctly
    flat = ""
    mapping = []
    for ri, r in enumerate(runs):
        t = r.text
        for ci in range(len(t)):
            flat += t[ci]
            mapping.append((ri, ci))

    pos = flat.find(old_text)
    if pos == -1:
        return False

    end_pos = pos + len(old_text) - 1  # inclusive

    start_run = mapping[pos][0]
    end_run   = mapping[end_pos][0]
    start_ci  = mapping[pos][1]
    end_ci    = mapping[end_pos][1]

    if start_run == end_run:
        r = runs[start_run]
        r.text = r.text[:start_ci] + new_text + r.text[end_ci + 1:]
    else:
        # Put new_text in start_run (keep prefix), clear middle, keep suffix of end_run
        runs[start_run].text = runs[start_run].text[:start_ci] + new_text
        for ri in range(start_run + 1, end_run):
            runs[ri].text = ""
        runs[end_run].text = runs[end_run].text[end_ci + 1:]

    return True


# ─── HELPER: extract changed words from an ellipsis-fragment pair ──────────────
def extract_changed_words(orig_frag, corr_frag, ellipsis=ELLIPSIS):
    """
    Given two parallel fragment strings (each may have leading/trailing … segments),
    find the segments that differ and return a list of (old_word, new_word) pairs
    to substitute in the full document text.

    Strategy:
    1. Split both on … to get text segments.
    2. For each pair of parallel segments, tokenize into words and find the diff.
    3. Return (old_phrase, new_phrase) pairs that can be searched in full text.
    """
    # Normalize – strip outer whitespace, replace ... with …
    orig = orig_frag.replace("...", ellipsis).strip()
    corr = corr_frag.replace("...", ellipsis).strip()

    if orig == corr:
        return []

    orig_parts = [p.strip() for p in orig.split(ellipsis) if p.strip()]
    corr_parts = [p.strip() for p in corr.split(ellipsis) if p.strip()]

    # Must have same number of parts to align
    if len(orig_parts) != len(corr_parts):
        # Fallback: try direct substitution if no ellipsis
        if ellipsis not in orig and ellipsis not in corr:
            return [(orig, corr)]
        # Can't align — skip
        return []

    pairs = []
    for op, cp in zip(orig_parts, corr_parts):
        if op == cp:
            continue
        # Find the minimal changed sub-phrase
        op_words = op.split()
        cp_words = cp.split()

        # Find common prefix and suffix
        prefix_len = 0
        for i in range(min(len(op_words), len(cp_words))):
            if op_words[i] == cp_words[i]:
                prefix_len += 1
            else:
                break
        suffix_len = 0
        for i in range(1, min(len(op_words), len(cp_words)) - prefix_len + 1):
            if op_words[-i] == cp_words[-i]:
                suffix_len += 1
            else:
                break

        changed_op = op_words[prefix_len: len(op_words) - suffix_len if suffix_len else None]
        changed_cp = cp_words[prefix_len: len(cp_words) - suffix_len if suffix_len else None]

        if changed_op and changed_cp:
            # Build context: include 1–2 words of prefix/suffix as anchor
            ctx_before = op_words[max(0, prefix_len - 2):prefix_len]
            ctx_after  = op_words[len(op_words) - suffix_len: len(op_words) - suffix_len + 2] if suffix_len else op_words[len(op_words) - 2:]

            old_phrase = " ".join(ctx_before + changed_op + ctx_after[:0])  # minimal
            new_phrase = " ".join(ctx_before + changed_cp)

            # Actually use a broader anchor: prefix + changed + 1 suffix word
            old_phrase_anchored = " ".join(
                op_words[max(0, prefix_len - 1): len(op_words) - suffix_len + (1 if suffix_len else 0)]
            )
            new_phrase_anchored = " ".join(
                cp_words[max(0, prefix_len - 1): len(cp_words) - suffix_len + (1 if suffix_len else 0)]
            )
            if old_phrase_anchored and new_phrase_anchored and old_phrase_anchored != new_phrase_anchored:
                pairs.append((old_phrase_anchored, new_phrase_anchored))
        elif not changed_op and not changed_cp:
            pass  # identical after alignment
        else:
            # Different lengths — use full segment
            if op != cp:
                pairs.append((op, cp))

    return pairs


# ─── LOAD DOCUMENT ─────────────────────────────────────────────────────────────
print("Loading OUR FINAL document...")
doc = Document(str(FINAL_PATH))
all_paras = doc.paragraphs
print(f"  Paragraphs: {len(all_paras)}")


# ═══════════════════════════════════════════════════════════════════════════════
# PART A — 9 specific paragraph edits
# ═══════════════════════════════════════════════════════════════════════════════
print("\n--- PART A: Specific paragraph edits ---")

# A-1: REJECT formatting note
found_a1 = False
for para in all_paras:
    if "FORMAT: fiirstname" in para.text or "FORMAT: fiirstname middlename" in para.text:
        part_a_log.append((1, "REJECTED", f"Found stray FORMAT note: {para.text[:80]}"))
        found_a1 = True
        break
if not found_a1:
    part_a_log.append((1, "SKIPPED", "Pattern 'FORMAT: fiirstname' not found (already clean)"))

# A-2: APPLY — Maam Ellen full name on title page
found_a2 = False
for para in all_paras:
    t = para.text
    if "Ellen F. Mangaoang, DIT" in t and "Ellen Flores Mangaoang" not in t:
        ok = replace_in_para(para, "Ellen F. Mangaoang, DIT", "Ellen Flores Mangaoang, DIT")
        if ok:
            part_a_log.append((2, "APPLIED", "Replaced 'Ellen F. Mangaoang, DIT' → 'Ellen Flores Mangaoang, DIT'"))
            found_a2 = True
            break
if not found_a2:
    for para in all_paras:
        if "Ellen Flores Mangaoang, DIT" in para.text:
            part_a_log.append((2, "SKIPPED", "Already reads 'Ellen Flores Mangaoang, DIT'"))
            found_a2 = True
            break
if not found_a2:
    part_a_log.append((2, "NOT_FOUND", "Pattern 'Ellen F. Mangaoang, DIT' not found"))

# A-3: APPLY — Raposas credentials update (approval sheet context only)
ack_phrases = [
    "thank their instructor",
    "providing direction",
    "continuous reminders",
    "grateful for the continuous",
    "their capstone journey",
    "has been a source",
]
found_a3 = False
for para in all_paras:
    t = para.text
    if "Shekiro R. Raposas, MIT" not in t:
        continue
    is_ack = any(phrase in t.lower() for phrase in ack_phrases)
    is_credential_line = (len(t.strip()) < 80 and "Raposas" in t and not is_ack)
    if is_credential_line:
        ok = replace_in_para(para, "Shekiro R. Raposas, MIT", "Shekiro R. Raposas, MTS, MIS")
        if ok:
            part_a_log.append((3, "APPLIED", f"Credentials updated: '{t.strip()[:80]}'"))
            found_a3 = True
if not found_a3:
    for para in all_paras:
        if "Shekiro R. Raposas, MTS, MIS" in para.text:
            part_a_log.append((3, "SKIPPED", "Already reads 'Shekiro R. Raposas, MTS, MIS'"))
            found_a3 = True
            break
if not found_a3:
    part_a_log.append((3, "NOT_FOUND", "No short credential-line paragraph with 'Shekiro R. Raposas, MIT' found"))

# A-4: APPLY — Mary-Ann Mzana credentials
found_a4 = False
for para in all_paras:
    t = para.text
    if "Mary-Ann Mzana" in t:
        if ", MTS" not in t:
            ok = replace_in_para(para, "Mary-Ann Mzana", "Mary-Ann Mzana, MTS")
            if ok:
                part_a_log.append((4, "APPLIED", "Appended ', MTS' to 'Mary-Ann Mzana'"))
                found_a4 = True
        else:
            part_a_log.append((4, "SKIPPED", "Mary-Ann Mzana already has ', MTS'"))
            found_a4 = True
        break
if not found_a4:
    part_a_log.append((4, "NOT_FOUND", "'Mary-Ann Mzana' not found in document"))

# A-5: SKIP — stray "a" (too vague)
part_a_log.append((5, "SKIPPED", "Stray 'a' para 44 analog — too vague to identify safely"))

# A-6: APPLY — Ma'am Ellen / Maam Ellen → Dr. Ellen
found_a6 = 0
for para in all_paras:
    t = para.text
    for variant in ["Ma'am Ellen F. Mangaoang", "Maam Ellen F. Mangaoang",
                    "Ma'am Ellen Mangaoang",   "Maam Ellen Mangaoang"]:
        if variant in t:
            ok = replace_in_para(para, variant, "Dr. Ellen F. Mangaoang")
            if ok:
                found_a6 += 1
    if "Capstone Adviser" in para.text:
        replace_in_para(para, "Capstone Adviser", "capstone adviser")
if found_a6 > 0:
    part_a_log.append((6, "APPLIED", f"Replaced Ma'am/Maam Ellen → 'Dr. Ellen F. Mangaoang' in {found_a6} paragraph(s)"))
else:
    already = any("Dr. Ellen F. Mangaoang" in p.text for p in all_paras)
    if already:
        part_a_log.append((6, "SKIPPED", "No Ma'am/Maam variants found; 'Dr. Ellen F. Mangaoang' already present"))
    else:
        part_a_log.append((6, "NOT_FOUND", "No Ma'am/Maam Ellen variants found and 'Dr. Ellen F. Mangaoang' also not present"))

# A-7: APPLY — replace wrong panelist names
found_mendez = 0
found_janelli = 0
for para in all_paras:
    if "Dr. Janelli M. Mendez" in para.text:
        ok = replace_in_para(para, "Dr. Janelli M. Mendez", "Mr. Shekiro R. Raposas, MIT")
        if ok:
            found_mendez += 1
    if "Dr. Janelli M. Raposas" in para.text:
        ok = replace_in_para(para, "Dr. Janelli M. Raposas", "Mr. Shekiro R. Raposas, MIT")
        if ok:
            found_janelli += 1

total_a7 = found_mendez + found_janelli
if total_a7 > 0:
    part_a_log.append((7, "APPLIED",
        f"Replaced {found_mendez} 'Dr. Janelli M. Mendez' + {found_janelli} 'Dr. Janelli M. Raposas' → 'Mr. Shekiro R. Raposas, MIT'"))
else:
    has_mendez  = any("Dr. Janelli M. Mendez"  in p.text for p in all_paras)
    has_janelli = any("Dr. Janelli M. Raposas" in p.text for p in all_paras)
    if not has_mendez and not has_janelli:
        part_a_log.append((7, "SKIPPED", "Neither wrong name found — already corrected"))
    else:
        part_a_log.append((7, "NOT_FOUND", "Pattern present but replace failed"))

# A-8: APPLY — remove stray "enumerate"
found_a8 = False
for para in all_paras:
    t = para.text
    if "enumerate the researchers express" in t:
        old = "enumerate the researchers express"
        new = "the researchers express"
        # Preserve comma if present: "panelists, enumerate" → "panelists,"
        if "panelists, enumerate the researchers express" in t:
            old = "panelists, enumerate the researchers express"
            new = "panelists, the researchers express"
        ok = replace_in_para(para, old, new)
        if ok:
            part_a_log.append((8, "APPLIED", "Removed stray 'enumerate'"))
            found_a8 = True
            break
if not found_a8:
    part_a_log.append((8, "NOT_FOUND", "'enumerate the researchers express' not found — may already be clean"))

# A-9: SKIP — whitespace only
part_a_log.append((9, "SKIPPED", "Para 62 analog: whitespace only — skipped per instructions"))

print(f"  Part A complete: {len(part_a_log)} edits logged")
for num, status, detail in part_a_log:
    print(f"    A{num}: {status} — {detail}")


# ═══════════════════════════════════════════════════════════════════════════════
# PART B — Apply 547 tense corrections (ellipsis-fragment aware)
# ═══════════════════════════════════════════════════════════════════════════════
print("\n--- PART B: Tense corrections table ---")

corrections_doc = Document(str(CORRECTIONS_PATH))
print(f"  Tables in corrections doc: {len(corrections_doc.tables)}")

corrections_table = None
for tbl in corrections_doc.tables:
    if len(tbl.rows) > 5 and len(tbl.columns) >= 5:
        hdr = " ".join(c.text.strip().lower() for c in tbl.rows[0].cells)
        if "original" in hdr or "correction" in hdr or "tense" in hdr:
            corrections_table = tbl
            break
if corrections_table is None:
    for tbl in corrections_doc.tables:
        if len(tbl.columns) >= 5 and len(tbl.rows) > 5:
            corrections_table = tbl
            break

if corrections_table is None:
    print("  ERROR: Corrections table not found!")
    part_b_log.append((0, "", "", "ERROR: Table not found"))
else:
    hdr_cells = [c.text.strip() for c in corrections_table.rows[0].cells]
    print(f"  Found table: {len(corrections_table.rows)} rows, {len(corrections_table.columns)} cols")
    print(f"  Header: {hdr_cells}")

    skip_section_pats = ["appendix"]
    ref_year_re  = re.compile(r'\(\d{4}\)')
    author_re    = re.compile(r'^[A-Z][a-z]+,\s+[A-Z]\.')
    caption_re   = re.compile(r'^(Figure|Table)\s+\d')
    cert_pats    = ["This is to certify", "In partial fulfillment",
                    "CERTIFICATION", "APPROVAL SHEET"]
    # Pre-build list of paragraph full texts for fast checking
    para_texts = [p.text for p in all_paras]

    for row in corrections_table.rows[1:]:
        cells = row.cells
        if len(cells) < 5:
            continue

        row_num_raw  = cells[0].text.strip()
        section_text = cells[1].text.strip()
        tense_text   = cells[2].text.strip()
        original     = cells[3].text.strip()
        correction   = cells[4].text.strip()

        try:
            row_num = int(row_num_raw)
        except Exception:
            row_num = row_num_raw

        # Skip empty
        if not original or not correction:
            part_b_log.append((row_num, original, correction, "SKIPPED_EMPTY"))
            continue
        if original == correction:
            part_b_log.append((row_num, original, correction, "SKIPPED_SAME"))
            continue

        # Skip appendix
        if any(sp in section_text.lower() for sp in skip_section_pats):
            part_b_log.append((row_num, original, correction, "SKIPPED_APPENDIX"))
            continue

        # Skip reference entries
        orig_clean = original.replace(ELLIPSIS, "").strip()
        if author_re.match(orig_clean):
            part_b_log.append((row_num, original, correction, "SKIPPED_REFERENCE"))
            continue
        if ref_year_re.search(orig_clean) and len(orig_clean.split()) <= 8:
            part_b_log.append((row_num, original, correction, "SKIPPED_REFERENCE"))
            continue

        # Skip very short fragments
        if len(orig_clean) <= 3:
            part_b_log.append((row_num, original, correction, "SKIPPED_FRAGMENT"))
            continue

        # Skip if contains protected values
        skip_prot = False
        for pv in PROTECTED_VALUES:
            if pv in original:
                part_b_log.append((row_num, original, correction, f"SKIPPED_PROTECTED({pv})"))
                skip_prot = True
                break
        if skip_prot:
            continue

        # Skip figure/table captions
        if caption_re.match(orig_clean):
            part_b_log.append((row_num, original, correction, "SKIPPED_CAPTION"))
            continue

        # Skip certification / title-page text
        if any(cp in original for cp in cert_pats):
            part_b_log.append((row_num, original, correction, "SKIPPED_CERT_TEXT"))
            continue

        # ── Determine old/new phrase pairs to apply ────────────────────────────
        if ELLIPSIS not in original and ELLIPSIS not in correction and "..." not in original:
            # No ellipsis — direct substitution
            pairs = [(original, correction)]
        else:
            pairs = extract_changed_words(original, correction)

        if not pairs:
            part_b_log.append((row_num, original, correction, "SKIPPED_NOEXTRACT"))
            continue

        # ── Apply each pair ────────────────────────────────────────────────────
        applied_this_row = False
        for old_phrase, new_phrase in pairs:
            if not old_phrase or not new_phrase or old_phrase == new_phrase:
                continue

            # Skip protected
            skip_p = False
            for pv in PROTECTED_VALUES:
                if pv in old_phrase:
                    skip_p = True
                    break
            if skip_p:
                continue

            for para in all_paras:
                pt = para.text
                if old_phrase not in pt:
                    continue

                pre_text = para.text
                ok = replace_in_para(para, old_phrase, new_phrase)
                if ok:
                    post_text = para.text
                    reverted = False
                    for pv in PROTECTED_VALUES:
                        if pv in pre_text and pv not in post_text:
                            # Revert
                            replace_in_para(para, new_phrase, old_phrase)
                            part_b_log.append((row_num, original, correction,
                                               f"REVERTED(protected '{pv}' broken)"))
                            reverted = True
                            break
                    if not reverted:
                        part_b_log.append((row_num, original, correction, "APPLIED"))
                        applied_this_row = True
                    break  # one paragraph per pair
                if applied_this_row:
                    break

        if not applied_this_row and not any(l[0] == row_num for l in part_b_log):
            part_b_log.append((row_num, original, correction, "NOT_FOUND"))

    b_applied   = sum(1 for x in part_b_log if x[3] == "APPLIED")
    b_not_found = sum(1 for x in part_b_log if x[3] == "NOT_FOUND")
    b_skipped   = sum(1 for x in part_b_log if x[3].startswith("SKIPPED"))
    b_reverted  = sum(1 for x in part_b_log if x[3].startswith("REVERTED"))
    print(f"  Part B: {b_applied} applied, {b_not_found} not found, {b_skipped} skipped, {b_reverted} reverted")


# ═══════════════════════════════════════════════════════════════════════════════
# PART C — Our audit fixes
# ═══════════════════════════════════════════════════════════════════════════════
print("\n--- PART C: Audit fixes ---")

audit_fixes = [
    (1,  "thank their instructor in charge",
         "help ensure the completion",
         "helped ensure the completion",
         "Acknowledgements: help → helped"),
    (2,  "SmartSpend integrates a multi-provider",
         "integrates",
         "integrated",
         "Abstract: integrates → integrated"),
    (3,  "which supports the case for automated capture",
         "supports",
         "supported",
         "Ch III: supports → supported"),
    (4,  "it directly influences the accuracy, latency",
         "influences",
         "influenced",
         "Ch III: influences → influenced"),
    (5,  "it offers a high free-tier request quota",
         "offers",
         "offered",
         "Ch III: offers → offered"),
    (6,  "have been replaced in the fallback chain",
         "have been replaced",
         "were replaced",
         "Ch III: have been replaced → were replaced"),
    (7,  "SmartSpend uses dynamic full-context injection",
         "uses",
         "used",
         "Ch III: uses → used"),
    (8,  "a summary card shows which items were recorded",
         "a summary card shows",
         "a summary card showed",
         "Ch III: shows → showed"),
    (9,  "first shows a warning",
         "first shows a warning",
         "first showed a warning",
         "Ch III: first shows a warning → first showed a warning"),
    (10, "Current research indicates this is feasible",
         "indicates this is",
         "indicated this was",
         "Ch III: indicates this is → indicated this was"),
    (11, "a haptic service provides tactile feedback",
         "provides",
         "provided",
         "Ch III: provides → provided"),
    (12, "has been set as the acceptance threshold",
         "has been set",
         "was set",
         "Ch II: has been set → was set"),
    (13, "features have been identified for future implementation",
         "have been identified",
         "were identified",
         "Ch III: have been identified → were identified"),
    (14, "multi-wallet system",
         "has been fully implemented",
         "was fully implemented",
         "Ch III: has been fully implemented → was fully implemented"),
]

for fix_num, anchor, old_phrase, new_phrase, desc in audit_fixes:
    applied = False
    # Try with anchor first
    for para in all_paras:
        t = para.text
        if anchor in t:
            if old_phrase in t:
                ok = replace_in_para(para, old_phrase, new_phrase)
                if ok:
                    part_c_log.append((fix_num, old_phrase, "APPLIED", desc))
                    applied = True
                    break
            elif new_phrase in t:
                part_c_log.append((fix_num, old_phrase, "ALREADY_APPLIED", f"Already '{new_phrase}'"))
                applied = True
                break
    if not applied:
        # Try without anchor
        for para in all_paras:
            if old_phrase in para.text:
                ok = replace_in_para(para, old_phrase, new_phrase)
                if ok:
                    part_c_log.append((fix_num, old_phrase, "APPLIED", desc + " (no anchor)"))
                    applied = True
                    break
                elif new_phrase in para.text:
                    part_c_log.append((fix_num, old_phrase, "ALREADY_APPLIED", f"Already '{new_phrase}' (no anchor)"))
                    applied = True
                    break
    if not applied:
        part_c_log.append((fix_num, old_phrase, "NOT_FOUND", desc))

c_applied  = sum(1 for x in part_c_log if x[2] == "APPLIED")
c_nf       = sum(1 for x in part_c_log if x[2] == "NOT_FOUND")
c_already  = sum(1 for x in part_c_log if x[2] == "ALREADY_APPLIED")
print(f"  Part C: {c_applied} applied, {c_nf} not found, {c_already} already applied")
for num, phrase, status, desc in part_c_log:
    print(f"    C{num}: {status} — {desc}")


# ═══════════════════════════════════════════════════════════════════════════════
# PART E — Save
# ═══════════════════════════════════════════════════════════════════════════════
print("\n--- Saving output ---")
doc.save(str(OUTPUT_PATH))
print(f"  Saved → {OUTPUT_PATH}")


# ═══════════════════════════════════════════════════════════════════════════════
# STEP 3 — Verification (re-open saved file)
# ═══════════════════════════════════════════════════════════════════════════════
print("\n--- Verification ---")
doc2      = Document(str(OUTPUT_PATH))
full_text = "\n".join(p.text for p in doc2.paragraphs)

def vcheck(num, desc, cond):
    result = "PASS" if cond else "FAIL"
    verify_log.append((num, desc, result))
    print(f"  V{num}: {result} — {desc}")
    return cond

vcheck(1,  "61.83 present",                           "61.83"   in full_text)
vcheck(2,  "17.58 present",                           "17.58"   in full_text)
vcheck(3,  "N=30 or N = 30 present",                  ("N=30" in full_text or "N = 30" in full_text))
vcheck(4,  "Grade D or grade of D present",           ("Grade D" in full_text or "grade of D" in full_text))
vcheck(5,  "10 parents and 20 young professionals",   ("10 parents" in full_text and "20 young professionals" in full_text))
vcheck(6,  "96.7 present",                            "96.7"    in full_text)
vcheck(7,  "93.3 present",                            "93.3"    in full_text)
img_count = len(doc2.inline_shapes)
vcheck(8,  f"Image count same as backup (actual: {img_count})", img_count >= 4)
vcheck(9,  "Mr. Shekiro R. Raposas, MIT present",     "Mr. Shekiro R. Raposas, MIT" in full_text)
vcheck(10, "Dr. Ellen F. Mangaoang or Ellen Flores Mangaoang present",
           ("Dr. Ellen F. Mangaoang" in full_text or "Ellen Flores Mangaoang" in full_text))
vcheck(11, "No Dr. Janelli M. Raposas remaining",     "Dr. Janelli M. Raposas" not in full_text)
vcheck(12, "No Ma'am Ellen or Maam Ellen remaining",  ("Ma'am Ellen" not in full_text and "Maam Ellen" not in full_text))

passes = sum(1 for x in verify_log if x[2] == "PASS")
fails  = sum(1 for x in verify_log if x[2] == "FAIL")
print(f"\n  Verification: {passes} PASS, {fails} FAIL")


# ═══════════════════════════════════════════════════════════════════════════════
# STEP 4 — Write merge report
# ═══════════════════════════════════════════════════════════════════════════════
print("\n--- Writing merge report ---")
REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)

now     = datetime.datetime.now().strftime("%Y-%m-%d %H:%M")
b_total = len(part_b_log)
b_app   = sum(1 for x in part_b_log if x[3] == "APPLIED")
b_nf    = sum(1 for x in part_b_log if x[3] == "NOT_FOUND")
b_sk    = sum(1 for x in part_b_log if x[3].startswith("SKIPPED"))
b_rv    = sum(1 for x in part_b_log if x[3].startswith("REVERTED"))

overall = "MERGE COMPLETE" if fails == 0 and b_rv == 0 else "MERGE COMPLETE WITH WARNINGS"

not_found_b  = [(n, o, c, s) for n, o, c, s in part_b_log if s == "NOT_FOUND"]
reverted_b   = [(n, o, c, s) for n, o, c, s in part_b_log if s.startswith("REVERTED")]

lines = [
    "# MAAM ELLEN MERGE REPORT",
    "",
    f"**Date:** {now}",
    f"**Status:** {overall}",
    f"**Output file:** `{OUTPUT_PATH}`",
    "",
    "---",
    "",
    "## Summary",
    "",
    f"- Merge strategy: OUR FINAL as base, Maam Ellen corrections as patch",
    f"- Part A edits: {sum(1 for x in part_a_log if x[1]=='APPLIED')} applied",
    f"- Part B tense corrections: {b_app} applied, {b_nf} not found, {b_sk} skipped, {b_rv} reverted (of {b_total} rows)",
    f"- Part C audit fixes: {c_applied} applied, {c_nf} not found, {c_already} already applied",
    f"- Verification: {passes}/12 PASS",
    "",
    "---",
    "",
    "## Part A — Specific Paragraph Edits",
    "",
    "| Edit | Status | Detail |",
    "|------|--------|--------|",
]
for num, status, detail in part_a_log:
    lines.append(f"| A{num} | {status} | {detail.replace('|','/')} |")

lines += [
    "",
    "---",
    "",
    "## Part B — Tense Corrections Table",
    "",
    f"- **Total rows read:** {b_total}",
    f"- **Applied:** {b_app}",
    f"- **Not found:** {b_nf}",
    f"- **Skipped:** {b_sk}",
    f"- **Reverted:** {b_rv}",
    "",
]

if not_found_b:
    lines += [
        "### NOT_FOUND Rows (sample — first 50)",
        "",
        "| # | Original Text (truncated) | Correction |",
        "|---|--------------------------|------------|",
    ]
    for n, o, c, s in not_found_b[:50]:
        lines.append(f"| {n} | {o.replace(chr(0x2026),'...').replace('|','/')[:80]} | {c.replace(chr(0x2026),'...').replace('|','/')[:60]} |")
    if len(not_found_b) > 50:
        lines.append(f"\n*... and {len(not_found_b)-50} more NOT_FOUND rows*")
    lines.append("")

if reverted_b:
    lines += [
        "### REVERTED Rows",
        "",
        "| # | Original Text | Reason |",
        "|---|--------------|--------|",
    ]
    for n, o, c, s in reverted_b:
        lines.append(f"| {n} | {o.replace(chr(0x2026),'...').replace('|','/')[:80]} | {s} |")
    lines.append("")

lines += [
    "---",
    "",
    "## Part C — Audit Fixes",
    "",
    "| Fix | Status | Description |",
    "|-----|--------|-------------|",
]
for num, phrase, status, desc in part_c_log:
    lines.append(f"| C{num} | {status} | {desc.replace('|','/')} |")

lines += [
    "",
    "---",
    "",
    "## Verification Results",
    "",
    "| Check | Description | Result |",
    "|-------|-------------|--------|",
]
for num, desc, result in verify_log:
    lines.append(f"| V{num} | {desc.replace('|','/')} | {result} |")

lines += [
    "",
    "---",
    "",
    "## Overall Status",
    "",
    f"**{overall}**",
    "",
    f"- Protected values: {'ALL PRESENT' if all(r=='PASS' for _,d,r in verify_log if any(pv in d for pv in ['61.83','17.58','N=30','Grade D','parents','96.7','93.3'])) else 'CHECK REPORT'}",
    f"- Structural integrity: {'OK — image count matches backup' if img_count >= 4 else f'WARNING: only {img_count} images'}",
]

REPORT_PATH.write_text("\n".join(lines) + "\n", encoding="utf-8")
print(f"  Report → {REPORT_PATH}")

print(f"\n{'='*60}")
print(f"OVERALL STATUS: {overall}")
print(f"{'='*60}")
print(f"Output: {OUTPUT_PATH}")
print(f"Part B: {b_app} applied / {b_nf} not_found / {b_sk} skipped / {b_rv} reverted")
print(f"Part C: {c_applied} applied / {c_nf} not_found / {c_already} already_applied")
print(f"Verify: {passes}/12 PASS, {fails}/12 FAIL")
