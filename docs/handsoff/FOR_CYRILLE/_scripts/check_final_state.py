from docx import Document
doc = Document(r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx')
print(f'Paras: {len(doc.paragraphs)}')

checks = [
    ('Scope condensed (2 para)', 'The system was available only on Android'),
    ('Tech BG condensed', 'Flutter was used to build the SmartSpend Android'),
    ('Firebase fused', 'Firebase. Firebase Firestore was used to synchronize'),
    ('Old Firebase split', 'Firebase Firestore. Firebase Firestore was used for bidirectional'),
    ('Old SQLite detail', 'sqflite package (version 11)'),
    ('Old Tech BG long', 'Firebase Crashlytics. Firebase Crashlytics was integrated'),
    ('Old Backup section', 'Backup and Restore. The application implemented backup'),
    ('Mixed methods gone', 'By combining mixed methods and developmental'),
    ('Quantitative correct', 'By combining quantitative and developmental'),
    ('Table 1.1 ref', 'Table 1.1 presented'),
    ('Table 2.1 ref wrong', 'Table 2.1 summarized'),
    ('Table 2 ref correct', 'Table 2 summarized'),
    ('SmartSpend allows (present)', 'SmartSpend allows users'),
    ('SmartSpend allowed (past)', 'SmartSpend allowed users'),
    ('9 recs present', '9. Formal parsing'),
    ('7 recs only', 'The researchers recommended that future researchers measure'),
    ('Avigail present', 'Avigail Candevario'),
    ('Susan gone', 'Susan C. Arquisal'),
    ('partially achieved', 'partially achieved'),
    ('61.83', '61.83'),
]

print()
for label, term in checks:
    found = any(term in p.text for p in doc.paragraphs)
    status = 'YES' if found else 'NO'
    print(f'  {status}: {label}')
