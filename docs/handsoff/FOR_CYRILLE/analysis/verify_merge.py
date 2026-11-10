# -*- coding: utf-8 -*-
"""Verify the SAVED document contains the intended applied changes and that
REJECTED paragraphs kept our protected content."""
from docx import Document
SAVED = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'
doc = Document(SAVED)
paras = [p.text for p in doc.paragraphs]


def chk(idx, label, needle, should=True):
    if idx >= len(paras):
        print('  [MISS idx] %s' % label)
        return
    present = needle in paras[idx]
    ok = present if should else (not present)
    flag = 'OK ' if ok else 'FAIL'
    print('  [%s] p%d %s -> %r present=%s (want %s)' % (flag, idx, label, needle[:50], present, should))


print('=== APPLIED changes present in saved doc ===')
chk(17, 'name', 'Brix A. Directo')
chk(18, 'name', 'Cyrille John M. Rubis')
chk(19, 'name', 'Djaunathan Albert S. Madayag')
chk(42, 'MTS MIS', 'Shekiro R. Raposas, MTS, MIS')
chk(67, 'had been', 'had been')
chk(71, 'might build', 'might build')
chk(162, 'guided', 'guided the system design')
chk(165, 'now', 'now correctly answered')
chk(174, 'preferred', 'preferred manual')
chk(174, 'did it compute', 'did it compute')
chk(175, 'added', 'added a business profile')
chk(180, 'handled', 'handled user interaction')
chk(207, 'helped', 'helped users manage')
chk(207, 'could kept', 'could respond')
chk(227, 'was unavail', 'was unavailable')
chk(230, 'implemented', 'implemented a conversation summarization')
chk(249, 'made', 'made independent financial decisions')
chk(249, 'tracked kept', 'tracked expenses')
chk(255, 'caption period', 'Table 2.1. Distribution of Respondents and Validators')
chk(265, 'four criteria', 'four criteria')
chk(296, 'were proposed', 'were proposed for subsequent research')
chk(298, 'caption period', 'Table 2.2. Agile Kanban Workflow Phases and Deliverables')
chk(304, 'presented', 'Table 3.1 presented')
chk(307, 'did not sum', 'did not sum to 100%')
chk(323, 'rescaled', 'rescaled the total')
chk(342, 'were worth', 'were worth documenting')

print('=== REJECTED -> protected content kept ===')
chk(60, 'instructor name kept', 'Mr. Shekiro R. Raposas, MTS, MIS')
chk(60, 'no Dr Janelli', 'Janelli', should=False)
chk(61, 'no enumerate', 'enumerate', should=False)
chk(61, 'panelists kept', 'Jeoffrey B. Layco')
chk(256, 'Avigail kept', 'Avigail Candevario, PFMe')
chk(269, 'Avigail kept', 'Avigail Candevario, PFMe')
chk(385, 'partially achieved kept', 'partially achieved')
chk(184, 'sqflite kept', 'sqflite')
chk(370, 'citation kept', 'Sauro & Lewis, 2016')
chk(51, 'abstract obj structure', 'aimed to: (1) assess')
chk(52, 'abstract methods', 'mixed-methods, developmental research design')
chk(53, 'abstract 96.7', '96.7%')
chk(53, 'abstract grade D', 'grade of D')

print('=== Corrupted-text paragraphs stayed clean (ours) ===')
chk(327, 'overspend heading', '2. Overspend Control (25 pts):')
chk(330, 'lightweight heading', 'Lightweight Mode')
chk(331, 'score adj heading', 'Score Adjustments')

print('=== Figure captions / appendices still present (kept) ===')
for i in [310, 373, 376, 776, 779]:
    print('  p%d: %r' % (i, paras[i][:80] if i < len(paras) else 'MISS'))
