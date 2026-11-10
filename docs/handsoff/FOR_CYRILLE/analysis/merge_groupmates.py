# -*- coding: utf-8 -*-
"""
Paragraph-by-paragraph merge of the groupmates' edits into OUR FINAL manuscript.

Strategy: edit OUR document in place (structure stays ours, 784 paras).
For each aligned (ours, theirs) paragraph pair whose text differs, apply a
pre-classified decision (APPLY / APPLY_PARTIAL / REJECT). Paragraphs that exist
only in ours (added figures, appendices, SUS rows) are kept. Paragraphs that
exist only in theirs are NOT added (preserve our structure).

Protected values are never changed. The groupmates reverted many of Maam
Ellen's past-tense corrections back to present/future tense; those reverts are
REJECTED to keep our past tense.
"""
import re
from difflib import SequenceMatcher
from docx import Document

OURS_PATH = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'
THEIRS_PATH = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\1_MAIN_MANUSCRIPT_FINAL (groupmates).docx'
OUT_PATH = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'
LOG_PATH = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\analysis\MERGE_LOG_GROUPMATES.md'

SIM_THRESHOLD = 0.55


def norm(t):
    return re.sub(r'\s+', ' ', t or '').strip()


def ratio(a, b):
    return SequenceMatcher(None, norm(a), norm(b)).ratio()


def similar(a, b):
    if not norm(a) and not norm(b):
        return True
    if not norm(a) or not norm(b):
        return False
    return ratio(a, b) >= SIM_THRESHOLD


# ----------------------------------------------------------------------------
# Decision table keyed by OUR paragraph index (oi).
#   ('full', new_text)            -> replace whole paragraph text (consolidate to run 0)
#   ('sub', old, new)             -> replace one substring across runs
#   ('partial', [(old,new), ...]) -> replace several substrings, keep the rest
#   ('reject',)                   -> keep ours unchanged
# ----------------------------------------------------------------------------
DECISIONS = {
    17:  ('full',   "Brix A. Directo", "Author name format: Last, F. M. -> F. M. Last"),
    18:  ('full',   "Cyrille John M. Rubis", "Author name format"),
    19:  ('full',   "Djaunathan Albert S. Madayag", "Author name format"),
    42:  ('sub',    "Shekiro R. Raposas", "Shekiro R. Raposas, MTS, MIS",
          "Add credentials MTS, MIS to instructor in signature block (KNOWN APPLY)"),
    51:  ('reject', "Abstract rewritten; removes structured 3-objective format & protected inline values; keep ours"),
    52:  ('reject', "Abstract rewritten; keep ours"),
    53:  ('reject', "Abstract rewritten; theirs drops 96.7%/93.3% & grade D; keep ours"),
    54:  ('reject', "Abstract rewritten; keep ours"),
    60:  ('reject', "Wrong instructor name 'Dr. Janelli M. Mendez' (KNOWN REJECT); keep Mr. Shekiro R. Raposas, MTS, MIS"),
    61:  ('reject', "Stray word 'enumerate' + removed panelist names (KNOWN REJECT); keep ours"),
    62:  ('reject', "Reverts past 'acknowledged'->present 'acknowledge' & lowercases 'Information Technology'; keep ours"),
    67:  ('sub',    "have been", "had been", "Tense: have been -> had been (KNOWN APPLY)"),
    71:  ('sub',    "may build", "might build", "Tense: may build -> might build (KNOWN APPLY)"),
    148: ('reject', "TOC renumbering (Table 2.2 Kanban -> LLM APIs) conflicts with body refs; keep ours"),
    149: ('reject', "TOC entry fragment; keep ours"),
    151: ('reject', "TOC renumbering; keep ours"),
    155: ('reject', "TOC entry fragment; keep ours"),
    157: ('reject', "TOC entry fragment; keep ours"),
    162: ('sub',    "that guides the system design", "that guided the system design",
          "Tense: guides -> guided (present->past consistency)"),
    164: ('reject', "Reverts 'lacked'->'lack' (past->present) & introduces error 'lacked of'; keep ours"),
    165: ('sub',    "74% of Filipinos correctly answered", "74% of Filipinos now correctly answered",
          "Wording: adds 'now' (clarity, consistent with shift narrative)"),
    174: ('partial', [("who prefer manual", "who preferred manual"),
                      ("nor does it compute", "nor did it compute")],
          "Apply tense fixes prefer->preferred & does->did; keep our last sentence (table renumbering conflict)"),
    175: ('sub',    "Agila: Finance Coach adds a business profile", "Agila: Finance Coach added a business profile",
          "Tense: adds -> added (present->past within past paragraph)"),
    178: ('reject', "Typo 'addressesed' + reverts past 'addressed'->present; keep ours"),
    180: ('sub',    "how mobile applications handle user interaction", "how mobile applications handled user interaction",
          "Tense: handle -> handled (present->past consistency in past narrative)"),
    182: ('reject', "Reverts 'was improving'->'is improving' (past->present); keep ours"),
    184: ('reject', "Wrong package name 'sqlite' (correct is 'sqflite'); keep ours"),
    202: ('reject', "Reverts 'was affected'->'will be affected' (past->future); keep ours"),
    207: ('partial', [("that helps users manage", "that helped users manage")],
          "Apply helps->helped (past consistency); keep 'could respond' (reject could->can revert)"),
    227: ('sub',    "if any single provider is unavailable", "if any single provider was unavailable",
          "Tense: is -> was (present->past consistency)"),
    230: ('sub',    "the system implements a conversation summarization mechanism",
          "the system implemented a conversation summarization mechanism",
          "Tense: implements -> implemented (present->past consistency)"),
    242: ('reject', "Reverts 'allowed'->'allows' (past->present) + double spaces; keep ours"),
    244: ('reject', "Reverts 'was a widely used'->'is' (past->present); keep ours"),
    245: ('reject', "Reverts 'focused'->'focuses' (past->present); keep ours"),
    248: ('reject', "Reverts 'consisted'->'consists' (past->present) + double spaces; keep ours"),
    249: ('partial', [("and make independent financial decisions", "and made independent financial decisions")],
          "Apply make->made (present->past); keep 'tracked' (reject tracked->track)"),
    251: ('reject', "Reverts 'were appropriate'->'are appropriate' (past->present); keep ours"),
    253: ('reject', "Removes restated table title inline; keep ours"),
    255: ('partial', [("Table 2.1: Distribution of Respondents and Validators",
                      "Table 2.1. Distribution of Respondents and Validators")],
          "Caption colon->period (APA); keep 'and Validators' (table includes validators)"),
    256: ('reject', "Removes validator name 'Avigail Candevario, PFMe' (protected); keep ours"),
    265: ('sub',    "across six weighted criteria", "across four criteria",
          "Fix inconsistency: 'six weighted criteria' -> 'four criteria' (only 4 listed)"),
    266: ('reject', "Removes validator name 'Avigail Candevario, PFMe' (protected); keep ours"),
    269: ('reject', "Removes validator name 'Avigail Candevario, PFMe' (protected); keep ours"),
    296: ('partial', [("and are proposed for subsequent research", "and were proposed for subsequent research")],
          "Apply are proposed->were proposed (past consistency); keep rest (reject had->has, included->include reverts)"),
    297: ('reject', "Removes restated table title inline; keep ours"),
    298: ('sub',    "Table 2.2: Agile Kanban Workflow Phases and Deliverables",
          "Table 2.2. Agile Kanban Workflow Phases and Deliverables",
          "Caption colon -> period (APA)"),
    304: ('sub',    "Table 3.1 presents the demographic profile", "Table 3.1 presented the demographic profile",
          "Tense: presents -> presented (present->past)"),
    307: ('sub',    "columns therefore do not sum to 100%", "columns therefore did not sum to 100%",
          "Tense: do not sum -> did not sum (present->past)"),
    323: ('sub',    "rescales the total", "rescaled the total", "Tense: rescales -> rescaled (present->past)"),
    327: ('reject', "Corrupted text ':(25 pts):ed as a...' (groupmates merge artifact); keep ours"),
    330: ('reject', "Corrupted text 'Modewere excluded...'; keep ours"),
    331: ('reject', "Corrupted text 'only fireded verified restraint...'; keep ours"),
    333: ('reject', "Major rewrite/addition (platform details); keep ours (our structure intact)"),
    342: ('sub',    "Two further additions worth documenting", "Two further additions were worth documenting",
          "Add past verb 'were' (completes clause in past narrative)"),
    343: ('reject', "Reverts many past->present (stayed->stays, pushed->pushes, were stored->are now stored); keep ours"),
    344: ('reject', "Reverts past->present throughout (existed->exist, stated->state, could->can); keep ours"),
    345: ('reject', "Reverts past->present (had->has, appeared->appears); keep ours"),
    346: ('reject', "Reverts past->present (applied->apply, had not been->has not been); keep ours"),
    347: ('reject', "Reverts past->present (shipped->ships, fell->falls, became->becomes); keep ours"),
    365: ('reject', "Reverts 'might have taken part'->'may have' (past->present); keep ours"),
    370: ('reject', "Removes citation '(Sauro & Lewis, 2016)'; keep ours"),
    380: ('reject', "Reverts 'were derived'->'are derived' (past->present); keep ours"),
    382: ('reject', "Reverts 'were based'->'are based' (past->present); keep ours"),
    384: ('reject', "Reverts 'were based'->'are based' & 'Recommendation 6'->'Priority 9'; keep ours"),
    385: ('reject', "Removes 'partially' (our Objective 3 wording, protected); keep ours"),
    395: ('reject', "Breaks subjunctive 'implement'->'implemented' after 'recommended that'; keep ours"),
}


def replace_substring_in_paragraph(p, old, new):
    """Replace first occurrence of `old` with `new` across the paragraph's runs,
    preserving formatting of runs outside the span. Returns True on success."""
    runs = p.runs
    if not runs:
        return False
    full = ''.join(r.text for r in runs)
    idx = full.find(old)
    if idx == -1:
        return False
    end = idx + len(old)
    pos = 0
    spans = []
    for r in runs:
        spans.append((pos, pos + len(r.text), r))
        pos += len(r.text)
    first_done = False
    for (s, e, r) in spans:
        if e <= idx or s >= end:
            continue
        if not first_done:
            before = r.text[:idx - s]
            if end <= e:
                r.text = before + new + r.text[end - s:]
            else:
                r.text = before + new
            first_done = True
        else:
            if end <= e:
                r.text = r.text[end - s:]
            else:
                r.text = ''
    return True


def set_paragraph_text(p, new_text):
    """Consolidate paragraph text into the first run, clearing the rest."""
    runs = p.runs
    if not runs:
        p.add_run(new_text)
        return True
    runs[0].text = new_text
    for r in runs[1:]:
        r.text = ''
    return True


def excerpt(t, n=90):
    t = (t or '').replace('\n', ' ').replace('\t', ' ')
    t = re.sub(r'\s+', ' ', t).strip()
    return t[:n] + ('…' if len(t) > n else '')


def main():
    ours = Document(OURS_PATH)
    theirs = Document(THEIRS_PATH)
    o_paras = [p.text for p in ours.paragraphs]
    t_paras = [p.text for p in theirs.paragraphs]

    sm = SequenceMatcher(None, [norm(p) for p in o_paras], [norm(p) for p in t_paras], autojunk=False)

    # Build pair list: (oi, ti, our_text, their_text, op_kind)
    pairs = []
    for tag, i1, i2, j1, j2 in sm.get_opcodes():
        if tag == 'equal':
            for k in range(i2 - i1):
                pairs.append(('equal', i1 + k, j1 + k))
        elif tag == 'replace':
            a_block = o_paras[i1:i2]
            b_block = t_paras[j1:j2]
            n = max(len(a_block), len(b_block))
            for k in range(n):
                oi = i1 + k if k < len(a_block) else None
                ti = j1 + k if k < len(b_block) else None
                pairs.append(('replace', oi, ti))
        elif tag == 'delete':
            for k in range(i2 - i1):
                pairs.append(('del', i1 + k, None))
        elif tag == 'insert':
            for k in range(j2 - j1):
                pairs.append(('ins', None, j1 + k))

    counts = {'APPLY': 0, 'APPLY_PARTIAL': 0, 'REJECT': 0, 'UNCHANGED': 0,
              'KEEP_OURS': 0, 'NOT_ADDED': 0, 'DEFAULT_REJECT': 0, 'SUBFAIL': 0}
    log_rows = []
    warnings = []

    for op, oi, ti in pairs:
        o_text = o_paras[oi] if oi is not None else None
        t_text = t_paras[ti] if ti is not None else None

        if op == 'equal':
            counts['UNCHANGED'] += 1
            continue

        if op == 'del':
            # ours-only: our addition -> keep
            counts['KEEP_OURS'] += 1
            log_rows.append((oi if oi is not None else '', excerpt(o_text), '(no match in groupmates)',
                             'KEEP', 'Our addition (figure/appendix/SUS row/blank) - kept'))
            continue

        if op == 'ins' or (op == 'replace' and (oi is None or not norm(o_text)) and norm(t_text)):
            # theirs-only content -> do not add
            counts['NOT_ADDED'] += 1
            log_rows.append((ti if ti is not None else '', '(no match in ours)', excerpt(t_text),
                             'REJECT', 'Theirs-only paragraph; not added to preserve our structure'))
            continue

        if op == 'replace' and oi is not None and norm(o_text) and ti is not None and not norm(t_text):
            # groupmates deleted our content -> keep ours
            counts['KEEP_OURS'] += 1
            log_rows.append((oi, excerpt(o_text), '(deleted in groupmates)', 'KEEP',
                             'Our content removed by groupmates - kept'))
            continue

        if op == 'replace' and oi is not None and norm(o_text) and ti is not None and norm(t_text):
            if norm(o_text) == norm(t_text):
                counts['UNCHANGED'] += 1
                continue
            dec = DECISIONS.get(oi)
            if dec is None:
                counts['DEFAULT_REJECT'] += 1
                log_rows.append((oi, excerpt(o_text), excerpt(t_text), 'REJECT',
                                 'Not in decision table - defaulted to keep ours'))
                warnings.append('DEFAULT_REJECT oi=%d' % oi)
                continue
            kind = dec[0]
            p = ours.paragraphs[oi]
            if kind == 'full':
                new_text = dec[1]
                set_paragraph_text(p, new_text)
                counts['APPLY'] += 1
                log_rows.append((oi, excerpt(o_text), excerpt(t_text), 'APPLY', dec[2]))
            elif kind == 'sub':
                old, new, reason = dec[1], dec[2], dec[3]
                ok = replace_substring_in_paragraph(p, old, new)
                if ok:
                    counts['APPLY'] += 1
                    log_rows.append((oi, excerpt(o_text), excerpt(t_text), 'APPLY', reason))
                else:
                    counts['SUBFAIL'] += 1
                    log_rows.append((oi, excerpt(o_text), excerpt(t_text), 'REJECT',
                                     'SUBSTRING NOT FOUND: %r - kept ours' % old[:40]))
                    warnings.append('SUBFAIL oi=%d old=%r' % (oi, old[:40]))
            elif kind == 'partial':
                subs = dec[1]
                reason = dec[2]
                all_ok = True
                for old, new in subs:
                    if not replace_substring_in_paragraph(p, old, new):
                        all_ok = False
                        warnings.append('SUBFAIL(PARTIAL) oi=%d old=%r' % (oi, old[:40]))
                if all_ok:
                    counts['APPLY_PARTIAL'] += 1
                    log_rows.append((oi, excerpt(o_text), excerpt(t_text), 'APPLY_PARTIAL', reason))
                else:
                    counts['SUBFAIL'] += 1
                    log_rows.append((oi, excerpt(o_text), excerpt(t_text), 'APPLY_PARTIAL*',
                                     'Partial apply - some substring(s) not found; see warnings'))
            elif kind == 'reject':
                counts['REJECT'] += 1
                log_rows.append((oi, excerpt(o_text), excerpt(t_text), 'REJECT', dec[1]))
            continue

        # any other case -> keep ours
        counts['REJECT'] += 1
        log_rows.append((oi if oi is not None else '', excerpt(o_text), excerpt(t_text), 'REJECT', 'Unclassified - kept ours'))

    # Save document
    ours.save(OUT_PATH)

    # Build markdown log
    lines = []
    lines.append('# Merge Log: Groupmates Edits -> FINAL Manuscript')
    lines.append('')
    lines.append('**Base (modified):** `1_MAIN_MANUSCRIPT_FINAL.docx` (784 paragraphs)')
    lines.append('**Source of edits:** `1_MAIN_MANUSCRIPT_FINAL (groupmates).docx` (758 paragraphs)')
    lines.append('')
    lines.append('## Summary')
    lines.append('')
    lines.append('| Metric | Count |')
    lines.append('|---|---|')
    lines.append('| Paragraphs in OUR FINAL | 784 |')
    lines.append('| Paragraphs in groupmates | 758 |')
    lines.append('| Compared (aligned) pairs | %d |' % len(pairs))
    lines.append('| UNCHANGED (matched equal) | %d |' % counts['UNCHANGED'])
    lines.append('| APPLY | %d |' % counts['APPLY'])
    lines.append('| APPLY_PARTIAL | %d |' % counts['APPLY_PARTIAL'])
    lines.append('| REJECT (keep ours) | %d |' % counts['REJECT'])
    lines.append('| KEEP (our-only additions) | %d |' % counts['KEEP_OURS'])
    lines.append('| NOT_ADDED (theirs-only, skipped) | %d |' % counts['NOT_ADDED'])
    if counts['DEFAULT_REJECT']:
        lines.append('| DEFAULT_REJECT (not in table) | %d |' % counts['DEFAULT_REJECT'])
    if counts['SUBFAIL']:
        lines.append('| SUBFAIL (substring not found) | %d |' % counts['SUBFAIL'])
    lines.append('')
    lines.append('## Decision Detail')
    lines.append('')
    lines.append('| Para# | OurText (excerpt) | GroupmatesText (excerpt) | Decision | Reason |')
    lines.append('|---|---|---|---|---|')
    for row in log_rows:
        para, o, t, dec, reason = row
        o = (o or '').replace('|', '\\|')
        t = (t or '').replace('|', '\\|')
        reason = (reason or '').replace('|', '\\|')
        lines.append('| %s | %s | %s | %s | %s |' % (para, o, t, dec, reason))
    lines.append('')

    with open(LOG_PATH, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))

    # Verification of protected values in the SAVED document
    saved = Document(OUT_PATH)
    saved_full = '\n'.join(p.text for p in saved.paragraphs)
    checks = {
        'SUS 61.83': saved_full.count('61.83'),
        'SD 17.58': saved_full.count('17.58'),
        'AI Intent 96.7': saved_full.count('96.7'),
        'GCash 93.3': saved_full.count('93.3'),
        'Parents 58.25': saved_full.count('58.25'),
        'Parents SD 19.72': saved_full.count('19.72'),
        'YP 63.62': saved_full.count('63.62'),
        'YP SD 16.65': saved_full.count('16.65'),
        'range 35.0': saved_full.count('35.0'),
        'range 92.5': saved_full.count('92.5'),
        'Avigail': saved_full.count('Avigail'),
        'Candevario': saved_full.count('Candevario'),
        'Shekiro': saved_full.count('Shekiro'),
        'Mangaoang': saved_full.count('Mangaoang'),
        'Layco': saved_full.count('Layco'),
        'Mzana': saved_full.count('Mzana'),
        'partially achieved': saved_full.count('partially achieved'),
        'WRONG: Mendez': saved_full.count('Mendez'),
        'WRONG: Janelli': saved_full.count('Janelli'),
        'WRONG: enumerate': saved_full.count('enumerate'),
        'sqflite (correct pkg)': saved_full.count('sqflite'),
    }
    print('=== COUNTS ===')
    for k, v in counts.items():
        print('  %-16s %d' % (k, v))
    print('=== WARNINGS ===')
    if warnings:
        for w in warnings:
            print('  ' + w)
    else:
        print('  (none)')
    print('=== PROTECTED-VALUE VERIFICATION (saved doc) ===')
    for k, v in checks.items():
        print('  %-26s %d' % (k, v))
    print('Saved to:', OUT_PATH)
    print('Log to:', LOG_PATH)


if __name__ == '__main__':
    main()
