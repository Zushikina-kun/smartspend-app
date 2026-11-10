"""Fix remaining 'live demonstration' instances — replace with correct SUS protocol."""
import shutil
from docx import Document

DOCX = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'
shutil.copy(DOCX, DOCX + '.livedemo.backup')
doc = Document(DOCX)

fixes = []

for i, para in enumerate(doc.paragraphs):
    t = para.text

    # Para 245 — Research Design: "following a live demonstration of the SmartSpend application"
    if 'following a live demonstration of the SmartSpend application' in t:
        old = 'following a live demonstration of the SmartSpend application'
        new = 'after respondents used the SmartSpend application (the full version or the built-in Demo Mode) for at least 10 minutes, confirmed by a screening question'
        new_text = t.replace(old, new, 1)
        if para.runs:
            para.runs[0].text = new_text
            for r in para.runs[1:]: r.text = ''
        fixes.append(f'[{i}] Research Design: replaced "live demonstration" with correct protocol')

    # Para 245 — also fix "had been set" → "was set" (tense) while we're here
    if 'had been set as the acceptance threshold' in para.text:
        new_text2 = para.text.replace('had been set as the acceptance threshold', 'was set as the acceptance threshold')
        if para.runs:
            para.runs[0].text = new_text2
            for r in para.runs[1:]: r.text = ''
        fixes.append(f'[{i}] Also fixed: "had been set" → "was set"')

    # Para 278 — Step 5: "respondents were given a live demonstration"
    if 'were given a live demonstration of SmartSpend using the built-in Demo Mode' in t:
        old2 = 'After system development, respondents were given a live demonstration of SmartSpend using the built-in Demo Mode. They then independently completed the 10-item SUS questionnaire.'
        new2 = 'Respondents used SmartSpend (the full version or the built-in Demo Mode) for at least 10 minutes, confirmed by a screening question, and then independently completed the 10-item SUS questionnaire online.'
        if old2 in t:
            new_text3 = t.replace(old2, new2, 1)
            if para.runs:
                para.runs[0].text = new_text3
                for r in para.runs[1:]: r.text = ''
            fixes.append(f'[{i}] Step 5: replaced full "live demonstration" sentence with correct protocol')
        else:
            # Partial match
            new_text3 = t.replace(
                'were given a live demonstration of SmartSpend using the built-in Demo Mode',
                'used SmartSpend (the full version or the built-in Demo Mode) for at least 10 minutes, confirmed by a screening question'
            )
            if para.runs:
                para.runs[0].text = new_text3
                for r in para.runs[1:]: r.text = ''
            fixes.append(f'[{i}] Step 5: replaced partial "live demonstration" with correct protocol')

doc.save(DOCX)

print(f'Fixed {len(fixes)} items:')
for f in fixes: print(f'  {f}')

# Verify no more live demonstration
doc2 = Document(DOCX)
remaining = [(i, p.text[:150]) for i, p in enumerate(doc2.paragraphs) if 'live demonstration' in p.text.lower()]
print(f'\nRemaining "live demonstration" instances: {len(remaining)}')
for i, t in remaining: print(f'  [{i}] {t}')
