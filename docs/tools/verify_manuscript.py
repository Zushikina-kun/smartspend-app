from docx import Document
import re

doc = Document('docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx')

print('=== VERIFICATION ===')

# Check key paragraphs
checks = {
    283: 'Research survey N',
    347: 'SUS N',
    353: 'SUS result fill',
    355: 'SUS interpretation',
    368: 'SUS conclusion',
}
for idx, label in checks.items():
    t = doc.paragraphs[idx].text
    print(f'\nP{idx} [{label}]:')
    print(f'  {t[:250]}')

# Check no bad strings remain
print('\n=== Bad string check ===')
bad = ['Verzola', 'Mangaoang, DIT', '31 agentic', '31 conversational',
       '23 achievement', '23 badge', 'Warren.*2004', '\\[\\[N\\]\\]']
found_any = False
for i, para in enumerate(doc.paragraphs):
    t = para.text
    for term in bad:
        if re.search(term, t, re.IGNORECASE):
            print(f'  STILL FOUND P{i} [{term}]: {t[:120]}')
            found_any = True
if not found_any:
    print('  All clean ✅')
