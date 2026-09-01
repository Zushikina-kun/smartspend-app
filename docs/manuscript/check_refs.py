from docx import Document
doc = Document('SMARTSPEND_UPDATED_MANUSCRIPT.docx')
in_refs = False
count = 0
for i, p in enumerate(doc.paragraphs):
    t = p.text.strip()
    if 'REFERENCES' in t.upper() and len(t) < 20:
        in_refs = True
        print(f"REFS header at para {i}: '{t}'")
        continue
    if in_refs:
        if 'APPENDIX' in t.upper() or 'APPENDICES' in t.upper():
            print(f"Stop at para {i}: '{t[:40]}'")
            break
        if t:
            count += 1
            if count <= 5 or count >= 60:
                print(f"  REF {count}: '{t[:70]}'")
print(f"\nTotal refs: {count}")

# Also show the raw XML around REFERENCES to understand structure
from docx.oxml.ns import qn
body = doc.element.body
found_refs = False
xml_count = 0
for child in body:
    text = "".join(r.text or "" for r in child.findall(".//" + qn("w:t")))
    if "REFERENCES" in text.upper() and len(text.strip()) < 20:
        found_refs = True
        print(f"\nXML REFS anchor: '{text.strip()}'")
        continue
    if found_refs and text.strip():
        xml_count += 1
        if xml_count <= 5:
            print(f"  XML after refs {xml_count}: '{text[:60]}'")
        if xml_count > 65:
            print(f"  XML after refs {xml_count}: '{text[:60]}'")
            break
print(f"\nXML entries after REFERENCES: {xml_count}")
