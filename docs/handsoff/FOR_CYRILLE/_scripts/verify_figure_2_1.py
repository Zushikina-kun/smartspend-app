"""Quick check: confirm the paragraph before Figure 2.1 caption contains an image."""
from docx import Document
from docx.oxml.ns import qn

DOCX = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'
doc = Document(DOCX)

for i, para in enumerate(doc.paragraphs):
    if 'Figure 2.1' in para.text and 'SUS' in para.text.upper():
        prev = doc.paragraphs[i - 1] if i > 0 else None
        has_img = prev is not None and prev._p.findall('.//' + qn('a:blip')) != []
        print(f"Caption at para {i}: {para.text[:60]}")
        print(f"Prev para has image: {has_img}")
        if prev:
            print(f"Prev para text: '{prev.text[:60]}'")
        break
