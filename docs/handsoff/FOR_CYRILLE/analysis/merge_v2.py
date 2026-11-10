"""
merge_v2.py — Merge groupmates V2 into FINAL manuscript
Steps:
  1. Global Joffrey -> Jeoffrey
  2. Para-by-para fuzzy alignment + APPLY/REJECT rules
  3. Save merged DOCX
  4. Post-merge verification
  5. Write MERGE_LOG_GROUPMATES_V2.md
"""

import re
import copy
from difflib import SequenceMatcher
from docx import Document
from docx.oxml.ns import qn
import lxml.etree as etree

BASE_PATH   = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx"
SOURCE_PATH = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\1_MAIN_MANUSCRIPT_FINAL (groupmates) V2.docx"
OUT_PATH    = BASE_PATH  # overwrite in place
LOG_PATH    = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\analysis\MERGE_LOG_GROUPMATES_V2.md"

# ── helpers ──────────────────────────────────────────────────────────────────

def para_text(p):
    return p.text.strip()

def sim(a, b):
    return SequenceMatcher(None, a.lower(), b.lower()).ratio()

def set_para_text(para, new_text):
    """Replace paragraph text while keeping first run's formatting."""
    runs = para.runs
    if not runs:
        # no runs at all — add one
        run = para.add_run(new_text)
        return
    # Put all text in first run, blank the rest
    runs[0].text = new_text
    for r in runs[1:]:
        r.text = ""

def joffrey_fix_para(para):
    """Replace Joffrey -> Jeoffrey in a paragraph's runs (case-insensitive)."""
    count = 0
    for run in para.runs:
        new_text, n = re.subn(r'Joffrey', 'Jeoffrey', run.text, flags=re.IGNORECASE)
        if n:
            run.text = new_text
            count += n
    return count

# ── REJECT rules ──────────────────────────────────────────────────────────────

PROTECTED_STRINGS = [
    "61.83", "17.58", "N=30", "N = 30", "grade of D", "Grade D",
    "partially achieved",
    "Avigail Candevario",
    "sqflite",
    "Mr. Shekiro R. Raposas",
    "Sauro & Lewis, 2016",
    "Recommendation 6",
    "96.7%", "93.3%",
    "35.0", "92.5",
]

PROTECTED_REGEXES = [
    re.compile(r'\bpartially achieved\b', re.I),
    re.compile(r'Avigail Candevario', re.I),
    re.compile(r'\bsqflite\b', re.I),
    re.compile(r'Mr\. Shekiro R\. Raposas', re.I),
    re.compile(r'Sauro & Lewis, 2016', re.I),
    re.compile(r'Recommendation 6\b', re.I),
]

REVERT_PAST_TO_PRESENT = [
    # (past_word, present_word) — if V2 has present where ours has past -> REJECT
    ('acknowledged', 'acknowledge'),
    ('focused', 'focuses'),
    ('allowed', 'allows'),
    ('consisted', 'consists'),
    ('was', 'is'),
    ('were', 'are'),
]

def contains_protected(text):
    """Return (bool, reason) if text is missing a protected value."""
    for s in PROTECTED_STRINGS:
        pass  # we check removal below
    return False, ""

def v2_removes_protected(our_text, v2_text):
    """Return reason string if V2 is removing something protected from our text."""
    for pat in PROTECTED_REGEXES:
        if pat.search(our_text) and not pat.search(v2_text):
            return f"V2 removes protected value matching /{pat.pattern}/"
    return ""

def v2_reverts_past_to_present(our_text, v2_text):
    """Return reason if V2 reverts our past tense back to present."""
    for past, present in REVERT_PAST_TO_PRESENT:
        # crude: if our text has the past word and v2 has the present word more
        our_count_past = len(re.findall(r'\b' + past + r'\b', our_text, re.I))
        v2_count_past  = len(re.findall(r'\b' + past + r'\b', v2_text,  re.I))
        v2_count_pres  = len(re.findall(r'\b' + present + r'\b', v2_text, re.I))
        our_count_pres = len(re.findall(r'\b' + present + r'\b', our_text, re.I))
        if our_count_past > v2_count_past and v2_count_pres > our_count_pres:
            return f"V2 reverts past '{past}' -> present '{present}'"
    return ""

def is_abstract_para(our_text, v2_text, para_idx):
    """Heuristic: abstract paras are ~para 51-54 (after front-matter)."""
    # We detect by content keywords
    abstract_keywords = [
        "mixed-methods", "developmental research", "purposive sampling",
        "needs assessment", "96.7%", "usability", "SUS",
        "Financial mismanagement", "SmartSpend integrated",
        "Financial Health Score", "agentic large language",
        "multi-provider",
    ]
    # If V2 has only 2 abstract paras (shorter), and our text is in abstract section
    # Detect: if v2 text looks like a rewritten abstract
    v2_lower = v2_text.lower()
    our_lower = our_text.lower()
    # V2 abstract markers
    v2_abstract_markers = [
        "agentic large language model", "multi-provider",
        "financial health score (fhs) — formally positioned",
        "usability was evaluated with the system usability scale",
    ]
    for m in v2_abstract_markers:
        if m in v2_lower:
            return True
    return False

def check_wrong_names(v2_text):
    """Return reason if V2 has wrong names."""
    if re.search(r'Dr\.?\s*Janelli', v2_text, re.I):
        return "V2 has wrong instructor name 'Dr. Janelli M. Mendez'"
    if re.search(r'\bsqlite\b', v2_text, re.I) and not re.search(r'\bsqflite\b', v2_text, re.I):
        return "V2 has wrong package name 'sqlite' (should be 'sqflite')"
    if re.search(r'Shekiro.*Raposas.*MTS.*MIS', v2_text, re.I) is None and \
       re.search(r'Shekiro.*Raposas', v2_text, re.I):
        # Has name but possibly without credentials — not a reason to reject by itself
        pass
    return ""

def check_sus_methodology(v2_text):
    """Reject if V2 has 'live demonstration' in SUS context."""
    if re.search(r'live demonstration', v2_text, re.I):
        return "V2 has 'live demonstration' (SUS methodology; keep 'self-directed use')"
    return ""

def check_no_mr_shekiro(our_text, v2_text):
    """Reject if V2 drops 'Mr.' prefix before Shekiro."""
    if re.search(r'Shekiro R\. Raposas', our_text, re.I):
        if re.search(r'Shekiro R\. Raposas', v2_text, re.I):
            # Both have it — check if V2 is missing 'Mr.'
            if re.search(r'\bMr\.\s+Shekiro', our_text, re.I) and \
               not re.search(r'\bMr\.\s+Shekiro', v2_text, re.I):
                return "V2 is missing 'Mr.' prefix before Shekiro R. Raposas"
    return ""

def check_partially_achieved(our_text, v2_text):
    """Reject if V2 reverts 'partially achieved' -> 'achieved'."""
    if 'partially achieved' in our_text.lower():
        if 'partially achieved' not in v2_text.lower() and 'achieved' in v2_text.lower():
            return "V2 reverts 'partially achieved' -> 'achieved' (protected)"
    return ""

def check_recommendation6(our_text, v2_text):
    """Reject if V2 changes 'Recommendation 6' to 'Priority 9'."""
    if re.search(r'Recommendation 6', our_text, re.I):
        if re.search(r'Priority 9', v2_text, re.I):
            return "V2 changes 'Recommendation 6' -> 'Priority 9' (protected)"
    return ""

def check_toc_fragment(v2_text):
    """Heuristic: TOC entry that is a fragment (no leading Table/Figure number)."""
    # Looks like a fragment if it starts with lowercase or partial title words
    # that obviously continue a previous TOC entry
    fragment_patterns = [
        r'^Methods of Respondents',
        r'^for SmartSpend Integration',
        r'^Results by Respondent Group',
        r'^Field-Level Parsing Performance',
        r'^and Validators',
    ]
    for p in fragment_patterns:
        if re.match(p, v2_text.strip(), re.I):
            return f"V2 TOC fragment: '{v2_text[:60]}'"
    return ""

def should_apply_tense_fix(our_text, v2_text):
    """Return True if V2 is a tense correction (present -> past) with no other harm."""
    # Simple heuristic: check if v2 changes some present-tense words to past
    tense_fixes = [
        ('guides', 'guided'), ('presents', 'presented'), ('is', 'was'),
        ('are', 'were'), ('have been', 'had been'), ('may build', 'might build'),
        ('handle', 'handled'), ('implements', 'implemented'), ('rescales', 'rescaled'),
        ('do not sum', 'did not sum'), ('helps', 'helped'), ('adds', 'added'),
        ('prefer', 'preferred'), ('does', 'did'), ('make', 'made'),
    ]
    for pres, past in tense_fixes:
        if re.search(r'\b' + re.escape(pres) + r'\b', our_text, re.I) and \
           re.search(r'\b' + re.escape(past) + r'\b', v2_text, re.I):
            return True
    return False

def classify_change(para_idx, our_text, v2_text):
    """
    Returns (decision, reason) where decision is 'APPLY', 'REJECT', or 'UNCHANGED'.
    """
    if our_text == v2_text:
        return 'UNCHANGED', 'Identical'

    # ── REJECT checks (order matters: most critical first) ────────────────────

    # 1. Abstract section — V2 has rewritten abstract
    if is_abstract_para(our_text, v2_text, para_idx):
        return 'REJECT', 'V2 rewrites abstract (protected; Maam Ellen rewrite)'

    # 2. Missing 'Mr.' before Shekiro
    r = check_no_mr_shekiro(our_text, v2_text)
    if r: return 'REJECT', r

    # 3. 'also acknowledge' (present) where ours has 'also acknowledged'
    if re.search(r'\balso acknowledge\b', v2_text, re.I) and \
       re.search(r'\balso acknowledged\b', our_text, re.I):
        return 'REJECT', "V2 reverts 'acknowledged' -> 'acknowledge' (past->present)"

    # 4. SUS methodology 'live demonstration'
    r = check_sus_methodology(v2_text)
    if r: return 'REJECT', r

    # 5. Removes protected values
    r = v2_removes_protected(our_text, v2_text)
    if r: return 'REJECT', r

    # 6. 'partially achieved' -> 'achieved'
    r = check_partially_achieved(our_text, v2_text)
    if r: return 'REJECT', r

    # 7. Recommendation 6 -> Priority 9
    r = check_recommendation6(our_text, v2_text)
    if r: return 'REJECT', r

    # 8. Past -> present reverts
    r = v2_reverts_past_to_present(our_text, v2_text)
    if r: return 'REJECT', r

    # 9. TOC fragment
    r = check_toc_fragment(v2_text)
    if r: return 'REJECT', r

    # 10. Wrong names / packages
    r = check_wrong_names(v2_text)
    if r: return 'REJECT', r

    # 11. Corrupted / stray text detection
    corruption_patterns = [
        r'enumerate the researchers',
        r'\w+were excluded',
        r'\w+fireded',
        r'\w+ed as a "soft" overspend',
        r'Lightweight Modewere',
        r'Score Adjustments — Warning Decay',  # only if it merges bullet text
    ]
    for cp in corruption_patterns:
        if re.search(cp, v2_text, re.I):
            return 'REJECT', f"V2 has corrupted/merged text (pattern: {cp})"

    # 12. References subjunctive verb break
    if re.search(r'\brecommended that\b', our_text, re.I):
        # 'recommended that X implement' (subjunctive) is correct; 'implemented' is wrong
        if re.search(r'\brecommended that\b.*\bimplemented\b', v2_text, re.I) and \
           re.search(r'\brecommended that\b.*\bimplement\b', our_text, re.I):
            return 'REJECT', "V2 breaks subjunctive 'implement' -> 'implemented' after 'recommended that'"

    # 13. Removes inline restated table title (heuristic)
    # If our text ends with a full table title ref and v2 cuts it off mid-sentence
    if re.search(r'Table \d+\.\d+[:.]', our_text) and not re.search(r'Table \d+\.\d+', v2_text):
        # Only reject if our text has a table reference that v2 removes entirely
        pass  # allow — may be a valid simplification

    # ── APPLY checks ──────────────────────────────────────────────────────────

    # Compute text similarity to decide if change is small/safe
    similarity = sim(our_text, v2_text)

    # Always APPLY if similarity is very high (minor fix)
    if similarity > 0.92:
        return 'APPLY', 'Minor wording/punctuation/tense fix (similarity > 0.92)'

    # Tense fix (present -> past)
    if should_apply_tense_fix(our_text, v2_text):
        # Double-check no protected value is removed
        r2 = v2_removes_protected(our_text, v2_text)
        if not r2:
            return 'APPLY', 'Tense correction (present -> past)'

    # APA caption colon -> period
    if re.search(r'Table \d+\.\d+:', our_text) and re.search(r'Table \d+\.\d+\.', v2_text):
        return 'APPLY', 'APA caption: colon -> period'
    if re.search(r'Figure \d+\.\d+:', our_text) and re.search(r'Figure \d+\.\d+\.', v2_text):
        return 'APPLY', 'APA caption: colon -> period'

    # Moderate similarity with no reject triggers — apply with caution
    if similarity > 0.80:
        return 'APPLY', f'Wording/grammar improvement (similarity {similarity:.2f})'

    # Low similarity — be conservative
    if similarity > 0.60:
        return 'APPLY', f'Content improvement (similarity {similarity:.2f})'

    # Very different — REJECT to be safe
    return 'REJECT', f'Major rewrite or low similarity ({similarity:.2f}); keep ours'


# ── Main merge logic ──────────────────────────────────────────────────────────

def build_index(doc):
    """Return list of (paragraph_object, text) for all paragraphs."""
    return [(p, para_text(p)) for p in doc.paragraphs]

def fuzzy_align(base_paras, src_paras):
    """
    Align base paras to src paras using SequenceMatcher on text.
    Returns list of (base_idx, src_idx_or_None) pairs.
    """
    base_texts = [t for _, t in base_paras]
    src_texts  = [t for _, t in src_paras]

    matcher = SequenceMatcher(None, base_texts, src_texts, autojunk=False)
    opcodes = matcher.get_opcodes()

    alignment = {}  # base_idx -> src_idx or None
    for tag, i1, i2, j1, j2 in opcodes:
        if tag == 'equal':
            for di, dj in enumerate(range(j1, j2)):
                alignment[i1 + di] = j1 + di
        elif tag == 'replace':
            # Pair up as many as possible by similarity
            base_slice = base_texts[i1:i2]
            src_slice  = src_texts[j1:j2]
            for bi, bt in enumerate(base_slice):
                best_j = None
                best_s = 0.0
                for sj, st in enumerate(src_slice):
                    s = sim(bt, st)
                    if s > best_s:
                        best_s = s
                        best_j = sj
                if best_j is not None and best_s > 0.3:
                    alignment[i1 + bi] = j1 + best_j
                # else: no src counterpart
        elif tag == 'delete':
            pass  # base only, no src counterpart
        elif tag == 'insert':
            pass  # src only, no base counterpart
    return alignment


def run_merge():
    print("Loading documents…")
    base_doc = Document(BASE_PATH)
    src_doc  = Document(SOURCE_PATH)

    base_paras = build_index(base_doc)
    src_paras  = build_index(src_doc)

    print(f"Base paragraphs: {len(base_paras)}")
    print(f"Source paragraphs: {len(src_paras)}")

    # ── STEP 1: Global Joffrey -> Jeoffrey ──────────────────────────────────
    global_replace_count = 0
    for p in base_doc.paragraphs:
        global_replace_count += joffrey_fix_para(p)
    # Also fix in tables
    for table in base_doc.tables:
        for row in table.rows:
            for cell in row.cells:
                for p in cell.paragraphs:
                    global_replace_count += joffrey_fix_para(p)
    print(f"Global Joffrey -> Jeoffrey replacements: {global_replace_count}")

    # Rebuild base index after fix
    base_paras = build_index(base_doc)

    # ── STEP 2: Align and compare ────────────────────────────────────────────
    alignment = fuzzy_align(base_paras, src_paras)
    print(f"Aligned pairs: {len(alignment)}")

    decisions = []  # list of dicts for log
    apply_count = 0
    reject_count = 0
    unchanged_count = 0

    for base_idx, (base_para, our_text) in enumerate(base_paras):
        src_idx = alignment.get(base_idx)
        if src_idx is None:
            # No counterpart in V2 — keep ours
            decisions.append({
                'para_idx': base_idx + 1,
                'our_text': our_text,
                'v2_text': '(no V2 counterpart)',
                'decision': 'KEEP',
                'reason': 'Our content with no V2 counterpart; kept',
            })
            unchanged_count += 1
            continue

        _, v2_text = src_paras[src_idx]

        if not our_text and not v2_text:
            unchanged_count += 1
            continue

        decision, reason = classify_change(base_idx, our_text, v2_text)

        if decision == 'APPLY':
            # Apply V2 text to base paragraph (preserve formatting)
            if v2_text != our_text:
                set_para_text(base_para, v2_text)
                apply_count += 1
            else:
                decision = 'UNCHANGED'
                reason = 'Identical after global fix'
                unchanged_count += 1
        elif decision == 'UNCHANGED':
            unchanged_count += 1
        else:  # REJECT
            reject_count += 1

        if decision != 'UNCHANGED' or our_text != v2_text:
            decisions.append({
                'para_idx': base_idx + 1,
                'our_text': our_text[:120],
                'v2_text': v2_text[:120],
                'decision': decision,
                'reason': reason,
            })

    print(f"APPLY: {apply_count}, REJECT: {reject_count}, UNCHANGED: {unchanged_count}")

    # ── STEP 3: Save ──────────────────────────────────────────────────────────
    print(f"Saving to {OUT_PATH}…")
    base_doc.save(OUT_PATH)
    print("Saved.")

    # ── STEP 4: Verification ─────────────────────────────────────────────────
    print("Verifying…")
    verify_doc = Document(OUT_PATH)
    full_text = "\n".join(p.text for p in verify_doc.paragraphs)
    # Also check tables
    for table in verify_doc.tables:
        for row in table.rows:
            for cell in row.cells:
                full_text += "\n" + "\n".join(p.text for p in cell.paragraphs)

    checks = [
        ("'61.83' appears (SUS score)",         bool(re.search(r'61\.83', full_text))),
        ("'N=30' or 'N = 30' appears",           bool(re.search(r'N\s*=\s*30', full_text))),
        ("'grade of D' or 'Grade D' appears",   bool(re.search(r'grade of D|Grade D', full_text, re.I))),
        ("'partially achieved' appears",         bool(re.search(r'partially achieved', full_text, re.I))),
        ("'Avigail Candevario' appears",         bool(re.search(r'Avigail Candevario', full_text, re.I))),
        ("'Jeoffrey' appears",                   bool(re.search(r'Jeoffrey', full_text))),
        ("'Joffrey' does NOT appear",            not bool(re.search(r'Joffrey', full_text))),
        ("'sqflite' appears",                    bool(re.search(r'sqflite', full_text, re.I))),
        ("'Mr. Shekiro R. Raposas' appears",     bool(re.search(r'Mr\.\s*Shekiro R\. Raposas', full_text))),
    ]

    print("\n--- Verification Results ---")
    for name, result in checks:
        status = "PASS" if result else "FAIL"
        print(f"  [{status}] {name}")

    # ── STEP 5: Write merge log ───────────────────────────────────────────────
    total_compared = len(decisions)
    log_lines = []
    log_lines.append("# Merge Log: Groupmates V2 → FINAL Manuscript\n")
    log_lines.append(f"**Base (modified):** `1_MAIN_MANUSCRIPT_FINAL.docx` ({len(base_paras)} paragraphs)  ")
    log_lines.append(f"**Source:** `1_MAIN_MANUSCRIPT_FINAL (groupmates) V2.docx` ({len(src_paras)} paragraphs)\n")
    log_lines.append("## Summary\n")
    log_lines.append("| Metric | Count |")
    log_lines.append("|---|---|")
    log_lines.append(f"| Paragraphs in OUR FINAL | {len(base_paras)} |")
    log_lines.append(f"| Paragraphs in groupmates V2 | {len(src_paras)} |")
    log_lines.append(f"| Aligned pairs compared | {total_compared} |")
    log_lines.append(f"| APPLY | {apply_count} |")
    log_lines.append(f"| REJECT | {reject_count} |")
    log_lines.append(f"| UNCHANGED / KEEP | {unchanged_count} |")
    log_lines.append(f"| Global Joffrey→Jeoffrey replacements | {global_replace_count} |")
    log_lines.append("")

    log_lines.append("## Decision Detail\n")
    log_lines.append("| Para# | OurText (excerpt) | V2Text (excerpt) | Decision | Reason |")
    log_lines.append("|---|---|---|---|---|")
    for d in decisions:
        our_exc = d['our_text'].replace('|', '\\|').replace('\n', ' ')[:100]
        v2_exc  = d['v2_text'].replace('|', '\\|').replace('\n', ' ')[:100]
        reason  = d['reason'].replace('|', '\\|')
        log_lines.append(f"| {d['para_idx']} | {our_exc} | {v2_exc} | {d['decision']} | {reason} |")

    log_lines.append("")
    log_lines.append("## Verification Results\n")
    log_lines.append("| Check | Result |")
    log_lines.append("|---|---|")
    for name, result in checks:
        status = "✅ PASS" if result else "❌ FAIL"
        log_lines.append(f"| {name} | {status} |")

    log_content = "\n".join(log_lines)
    with open(LOG_PATH, 'w', encoding='utf-8') as f:
        f.write(log_content)
    print(f"\nMerge log written to: {LOG_PATH}")

    return checks, apply_count, reject_count, unchanged_count, global_replace_count

if __name__ == '__main__':
    run_merge()
