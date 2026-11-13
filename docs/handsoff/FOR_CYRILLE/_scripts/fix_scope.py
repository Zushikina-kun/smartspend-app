"""Condense Scope and Limitations to LigTask style — short, plain, no jargon."""
import shutil
from docx import Document

DOCX = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'
shutil.copy(DOCX, DOCX + '.scope.bak')
doc = Document(DOCX)

# Find Scope and Limitations heading in body (not TOC)
scope_heading_idx = None
for i, p in enumerate(doc.paragraphs):
    if 'Scope and Limitations' in p.text and i > 150:
        scope_heading_idx = i
        break

if scope_heading_idx is None:
    print('ERROR: Scope heading not found')
    exit(1)

print(f'Scope heading at para {scope_heading_idx}')

# The body paragraphs are 194-197 (4 paragraphs)
# Replace them with 2 concise paragraphs in LigTask style

NEW_SCOPE = (
    "The study was limited to Android devices. SmartSpend was developed as a "
    "mobile application that operated both online and offline, with local data "
    "storage through SQLite and optional cloud synchronization through Firebase. "
    "All AI-powered features required an active internet connection, as they relied "
    "on an external LLM API. The application did not support direct banking "
    "integration, investment features, or professional financial advice."
)

NEW_LIMITATIONS = (
    "The accuracy of OCR receipt scanning depended on the quality of the receipt "
    "image, and voice input accuracy was affected by background noise. "
    "The application was designed with the Philippine Data Privacy Act of 2012 "
    "in mind and applied on-device redaction of sensitive information before any "
    "data was sent to cloud services. The system was a prototype and was not "
    "intended for commercial deployment."
)

# Replace para 194 with NEW_SCOPE
p194 = doc.paragraphs[scope_heading_idx + 1]
if p194.runs:
    p194.runs[0].text = NEW_SCOPE
    for r in p194.runs[1:]: r.text = ''
print(f'Set para {scope_heading_idx + 1} to new scope text')

# Replace para 195 with NEW_LIMITATIONS
p195 = doc.paragraphs[scope_heading_idx + 2]
if p195.runs:
    p195.runs[0].text = NEW_LIMITATIONS
    for r in p195.runs[1:]: r.text = ''
print(f'Set para {scope_heading_idx + 2} to new limitations text')

# Clear paras 196 and 197 (the technical API key and DPA paragraphs)
for offset in [3, 4]:
    idx = scope_heading_idx + offset
    if idx < len(doc.paragraphs):
        p = doc.paragraphs[idx]
        t = p.text.strip()
        # Only clear if still part of scope section (not next heading)
        if t and 'Purpose' not in t and 'Chapter' not in t.upper():
            if p.runs:
                p.runs[0].text = ''
                for r in p.runs[1:]: r.text = ''
            print(f'Cleared para {idx}: {t[:60]}')

doc.save(DOCX)
print('Saved.')

# Verify
doc2 = Document(DOCX)
print('\nNew Scope and Limitations:')
for i in range(scope_heading_idx, scope_heading_idx + 6):
    t = doc2.paragraphs[i].text.strip()
    if t: print(f'  [{i}] {t[:130]}')
