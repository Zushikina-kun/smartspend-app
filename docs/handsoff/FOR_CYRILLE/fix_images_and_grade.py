"""
Fix:
1. Re-embed 3 missing images (SUS Distribution, SUS Subgroup, Demographic Breakdown)
2. Find and confirm Grade D text
"""
import shutil
from docx import Document
from docx.oxml.ns import qn
from docx.oxml import OxmlElement
from docx.text.paragraph import Paragraph as DocxParagraph
from docx.shared import Inches

DOCX = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'
FIGS = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\FIGURES'

shutil.copy(DOCX, DOCX + '.prefix.backup')
doc = Document(DOCX)

# Check which images are missing by finding captions without preceding images
def prev_has_image(doc, caption_text):
    for i, para in enumerate(doc.paragraphs):
        if caption_text in para.text:
            if i == 0: return i, False
            has = bool(doc.paragraphs[i-1]._p.findall('.//' + qn('a:blip')))
            return i, has
    return -1, False

checks = [
    ('Figure 3.11', f'{FIGS}/Figure_SUS_Distribution.png', 'SUS Distribution'),
    ('Table 3.4. System Usability Scale', f'{FIGS}/Figure_SUS_Subgroup.png', 'SUS Subgroup'),
    ('Table 3.1. Demographic Profile and Expense Tracking Methods', f'{FIGS}/Figure_Demographic_Breakdown.png', 'Demographics'),
]

fixes = []
for caption, img_path, label in checks:
    idx, has = prev_has_image(doc, caption)
    if idx == -1:
        fixes.append(f"CAPTION NOT FOUND: {caption}")
        continue
    if has:
        fixes.append(f"OK (already has image): {label} before para {idx}")
        continue
    # Insert image before caption
    caption_para = doc.paragraphs[idx]
    new_p = OxmlElement('w:p')
    pPr = OxmlElement('w:pPr')
    jc = OxmlElement('w:jc')
    jc.set(qn('w:val'), 'center')
    pPr.append(jc)
    new_p.append(pPr)
    caption_para._p.addprevious(new_p)
    para_obj = DocxParagraph(new_p, caption_para._parent)
    run = para_obj.add_run()
    run.add_picture(img_path, width=Inches(5.2))
    fixes.append(f"INSERTED {label} before '{caption}' (para {idx})")

# Check Grade D
grade_found = []
for i, p in enumerate(doc.paragraphs):
    t = p.text
    if ('grade' in t.lower() or 'Grade' in t) and ('D' in t) and '61' in t:
        grade_found.append(f"[{i}] {t[:150]}")

doc.save(DOCX)

print("Fixes:")
for f in fixes: print(f"  {f}")

# Verify
doc2 = Document(DOCX)
imgs = sum(len(p._p.findall('.//' + qn('a:blip'))) for p in doc2.paragraphs)
print(f"\nImages after fix: {imgs}")
print(f"Grade D in doc: {'YES' if grade_found else 'NOT FOUND'}")
for g in grade_found: print(f"  {g}")
print(f"Paras: {len(doc2.paragraphs)}")
