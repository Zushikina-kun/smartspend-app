# -*- coding: utf-8 -*-
"""Regenerate the merge log with corrected classification, using the pre-merge
BACKUP for original 'our text' excerpts. Does NOT modify the saved document."""
import re
from difflib import SequenceMatcher
from docx import Document
from merge_groupmates import DECISIONS  # reuse the exact decision table

BACKUP_PATH = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\analysis\1_MAIN_MANUSCRIPT_FINAL.backup_pre_groupmates_merge.docx'
THEIRS_PATH = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\1_MAIN_MANUSCRIPT_FINAL (groupmates).docx'
LOG_PATH = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\analysis\MERGE_LOG_GROUPMATES.md'

SIM_THRESHOLD = 0.55


def norm(t):
    return re.sub(r'\s+', ' ', t or '').strip()


def ratio(a, b):
    return SequenceMatcher(None, norm(a), norm(b)).ratio()


def excerpt(t, n=90):
    t = (t or '').replace('\n', ' ').replace('\t', ' ')
    t = re.sub(r'\s+', ' ', t).strip()
    return t[:n] + ('…' if len(t) > n else '')


def main():
    ours = Document(BACKUP_PATH)
    theirs = Document(THEIRS_PATH)
    o_paras = [p.text for p in ours.paragraphs]
    t_paras = [p.text for p in theirs.paragraphs]

    sm = SequenceMatcher(None, [norm(p) for p in o_paras], [norm(p) for p in t_paras], autojunk=False)
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

    counts = {'APPLY': 0, 'APPLY_PARTIAL': 0, 'REJECT': 0, 'UNCHANGED': 0, 'KEEP': 0, 'NOT_ADDED': 0}
    rows = []

    def add(para, o, t, dec, reason):
        rows.append((para, o, t, dec, reason))

    for op, oi, ti in pairs:
        o_text = o_paras[oi] if oi is not None else None
        t_text = t_paras[ti] if ti is not None else None
        on, tn = norm(o_text), norm(t_text)

        if op == 'equal' or (op == 'replace' and oi is not None and on and tn and on == tn):
            counts['UNCHANGED'] += 1
            continue
        if op == 'del':
            counts['KEEP'] += 1
            add(oi, excerpt(o_text), '(no match in groupmates)', 'KEEP',
                'Our addition (figure/appendix/SUS row/blank) - kept')
            continue
        if op == 'ins' or (op == 'replace' and (oi is None or not on) and tn):
            counts['NOT_ADDED'] += 1
            add(ti if ti is not None else '', '(no match in ours)', excerpt(t_text), 'REJECT',
                'Theirs-only paragraph; not added to preserve our structure')
            continue
        if op == 'replace' and oi is not None and on and (ti is None or not tn):
            counts['KEEP'] += 1
            add(oi, excerpt(o_text), '(no groupmates paragraph)', 'KEEP',
                'Our content with no groupmates counterpart (figure caption/blank) - kept')
            continue
        if op == 'replace' and oi is not None and not on and (ti is None or not tn):
            counts['UNCHANGED'] += 1
            continue
        if op == 'replace' and oi is not None and on and ti is not None and tn:
            dec = DECISIONS.get(oi)
            if dec is None:
                counts['REJECT'] += 1
                add(oi, excerpt(o_text), excerpt(t_text), 'REJECT', 'Not in decision table - kept ours')
                continue
            kind = dec[0]
            if kind == 'full':
                counts['APPLY'] += 1
                add(oi, excerpt(o_text), excerpt(t_text), 'APPLY', dec[2])
            elif kind == 'sub':
                counts['APPLY'] += 1
                add(oi, excerpt(o_text), excerpt(t_text), 'APPLY', dec[3])
            elif kind == 'partial':
                counts['APPLY_PARTIAL'] += 1
                add(oi, excerpt(o_text), excerpt(t_text), 'APPLY_PARTIAL', dec[2])
            elif kind == 'reject':
                counts['REJECT'] += 1
                add(oi, excerpt(o_text), excerpt(t_text), 'REJECT', dec[1])
            continue
        counts['REJECT'] += 1
        add(oi if oi is not None else '', excerpt(o_text), excerpt(t_text), 'REJECT', 'Unclassified - kept ours')

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
    lines.append('| UNCHANGED (matched equal / blank) | %d |' % counts['UNCHANGED'])
    lines.append('| APPLY | %d |' % counts['APPLY'])
    lines.append('| APPLY_PARTIAL | %d |' % counts['APPLY_PARTIAL'])
    lines.append('| REJECT (keep ours) | %d |' % counts['REJECT'])
    lines.append('| KEEP (our-only additions, kept) | %d |' % counts['KEEP'])
    lines.append('| NOT_ADDED (theirs-only, skipped) | %d |' % counts['NOT_ADDED'])
    lines.append('')
    lines.append('Total differing decisions (APPLY + APPLY_PARTIAL + REJECT + KEEP + NOT_ADDED) = %d' %
                 (counts['APPLY'] + counts['APPLY_PARTIAL'] + counts['REJECT'] + counts['KEEP'] + counts['NOT_ADDED']))
    lines.append('')
    lines.append('## Decision Detail')
    lines.append('')
    lines.append('| Para# | OurText (excerpt) | GroupmatesText (excerpt) | Decision | Reason |')
    lines.append('|---|---|---|---|---|')
    for para, o, t, dec, reason in rows:
        o = (o or '').replace('|', '\\|')
        t = (t or '').replace('|', '\\|')
        reason = (reason or '').replace('|', '\\|')
        lines.append('| %s | %s | %s | %s | %s |' % (para, o, t, dec, reason))
    lines.append('')

    with open(LOG_PATH, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))

    print('=== COUNTS ===')
    for k, v in counts.items():
        print('  %-14s %d' % (k, v))
    print('Total rows logged:', len(rows))
    print('Log written to:', LOG_PATH)


if __name__ == '__main__':
    main()
