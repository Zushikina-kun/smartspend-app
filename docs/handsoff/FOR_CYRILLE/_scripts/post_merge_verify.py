from docx import Document
from docx.oxml.ns import qn

doc = Document(r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx')

print("=== NAMES ===")
for i, p in enumerate(doc.paragraphs[55:75], start=55):
    t = p.text.strip()
    if any(k in t for k in ['instructor', 'Janelli', 'Shekiro', 'Mendez', 'Mangaoang', 'adviser', 'Adviser']):
        print(f"[{i}] {t[:160]}")

print()
print("=== ABSTRACT (para 51) ===")
print(doc.paragraphs[51].text[:300])

print()
print("=== PROTECTED VALUES ===")
vals = ['61.83', '17.58', 'Grade D', 'N = 30', '96.7', '93.3', 'Mr. Shekiro']
for v in vals:
    found = any(v in p.text for p in doc.paragraphs)
    status = "OK" if found else "MISSING"
    print(f"  {v}: {status}")

print()
print("=== IMAGES ===")
img_count = sum(len(p._p.findall('.//' + qn('a:blip'))) for p in doc.paragraphs)
print(f"  Embedded images: {img_count}")
print(f"  Total paragraphs: {len(doc.paragraphs)}")

print()
print("=== ACKNOWLEDGEMENTS PARA 60 ===")
print(doc.paragraphs[60].text[:200])
