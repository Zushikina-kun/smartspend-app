from docx import Document
from docx.oxml.ns import qn
doc = Document('SMARTSPEND_UPDATED_MANUSCRIPT.docx')
body = doc.element.body
ns = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
all_els = list(body)

# Find where REFERENCES and Arcila are in the XML
refs_idx = -1
arcila_idx = -1
appendix_idx = -1

for i, child in enumerate(all_els):
    text = "".join(r.text or "" for r in child.findall(".//{%s}t" % ns))
    t = text.strip()
    if t == "REFERENCES":
        refs_idx = i
    if "Arcila" in t:
        arcila_idx = i
    if t == "APPENDICES":
        appendix_idx = i
    if "Bangko Sentral ng Pilipinas. (2021)" in t and i > 200:
        print(f"  BSP 2021 at XML[{i}]: {t[:60]}")

print(f"\nREFERENCES at XML[{refs_idx}]")
print(f"Arcila at XML[{arcila_idx}]")
print(f"APPENDICES at XML[{appendix_idx}]")

# Show 3 elements after REFERENCES
print("\n3 XML elements after REFERENCES:")
for j in range(refs_idx+1, min(refs_idx+4, len(all_els))):
    text = "".join(r.text or "" for r in all_els[j].findall(".//{%s}t" % ns))
    print(f"  [{j}]: {text[:70]}")

# Show 3 elements before APPENDICES
print("\n3 XML elements before APPENDICES:")
for j in range(max(0, appendix_idx-3), appendix_idx):
    text = "".join(r.text or "" for r in all_els[j].findall(".//{%s}t" % ns))
    print(f"  [{j}]: {text[:70]}")
