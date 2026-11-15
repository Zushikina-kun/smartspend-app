from docx import Document
doc = Document(r'Source of Truth\1_MAIN_MANUSCRIPT_FINAL.docx')
lines = [p.text.strip() for p in doc.paragraphs]
ms = '\n'.join(lines)

checks = [
    ('Duplicate validator note gone (<=1)', ms.count('content validator participated separately') <= 1),
    ('Appendix C = SUS Questionnaire in TOC', 'APPENDIX C: System Usability Scale' in ms or 'Appendix C: System Usability Scale' in ms),
    ('Old TOC with Transcript of Interview gone', 'Transcript of Interview' not in ms),
    ('Figure 3 caption present in body', 'Figure 3.' in ms or 'Figure 3:' in ms),
    ('Figure 3 description present', 'Figure 3 presents the SUS' in ms),
    ('Reclassification uses Q1 age bracket', 'Q1 age bracket' in ms),
    ('No "primary financial role" reclassification', 'reclassified by primary financial role' not in ms),
    ('Figure 5 period style', 'Figure 5.' in ms),
    ('Figure 4 period style', 'Figure 4.' in ms),
    ('Figure 1 period style (not colon)', 'Figure 1.' in ms),
    ('No old-style chapter figures in TOC (3.14)', '3.14' not in ms[:5000]),
    ('No old-style chapter figures in TOC (1.1)', '1.1.' not in ms[:5000]),
    ('Sequential List of Figures 1-17 in TOC', 'Figure 1.' in ms[:5000] and 'Figure 17.' in ms[:5000]),
    ('Table 5 note parents n=16', '(parents n = 16' in ms),
    ('Scope is clean 1 paragraph', 'The system was available only on Android' not in ms),  # old version
    ('Figure 4 description present', 'Figure 4 presents the Agile Kanban' in ms or 'Agile Kanban Workflow used in the development' in ms),
    ('Figure 5 description present', 'Figure 5 presents the demographic distribution' in ms),
    ('Figure 6 is Flowchart (not Figure 5)', 'Figure 6. SmartSpend System Flowchart' in ms or 'Figure 6 presents the system flowchart' in ms),
    ('No Figure 1: colon style caption', 'Figure 1:' not in ms),
    ('All 9 recommendations present', '9. Formal parsing' in ms),
]

print('CURRENT STATE OF SOURCE OF TRUTH MANUSCRIPT:')
done = [l for l,ok in checks if ok]
needed = [l for l,ok in checks if not ok]
print(f'  DONE: {len(done)}/{len(checks)}')
print(f'  STILL NEEDED: {len(needed)}')
if needed:
    print('\nStill needed:')
    for l in needed:
        print(f'  MISSING: {l}')
else:
    print('\nAll previously flagged items are DONE.')
