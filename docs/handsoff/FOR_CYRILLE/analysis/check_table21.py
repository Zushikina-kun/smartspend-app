"""Check para 255/257 about Table 2.1 and validators."""
from docx import Document

doc = Document(r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx')
paras = list(doc.paragraphs)

# Check paras 253-262 (0-indexed)
for i in range(252, min(265, len(paras))):
    p = paras[i]
    t = p.text.strip()
    if t:
        print(f"Para {i+1}: {t[:200]}")
