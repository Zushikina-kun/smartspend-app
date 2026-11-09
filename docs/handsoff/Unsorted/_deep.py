import zipfile, re
from docx import Document

SRC = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\CAPSTONE_LucidFrame_-_SMARTSPEND__5_ (1).docx"

# 1) Raw XML grep across ALL parts of the docx (body, headers, footers, footnotes, etc.)
print("=" * 70)
print("RAW XML GREP (all parts)")
print("=" * 70)
NEEDLES = ["November 9", "November 10", "97.0", "96.7", "13.43", "17.58",
           "56.30", "61.83", "63.06", "N=33", "N = 33", "N=5", "N=30",
           "62.50", "7.91", "55.00", "APPENDIX D", "Appendix D", "appendix d",
           "Semi-Structured", "semi-structured", "interview guide",
           "Mangaoang", "MIT", "33", "46.7", "43.3", "10.0"]
with zipfile.ZipFile(SRC) as z:
    names = z.namelist()
    print("Parts:", [n for n in names if n.endswith('.xml')])
    for part in names:
        if not part.endswith('.xml'):
            continue
        data = z.read(part).decode('utf-8', errors='ignore')
        for needle in NEEDLES:
            if needle in data:
                # count occurrences
                cnt = data.count(needle)
                print(f"  [{part}] '{needle}' x{cnt}")

# 2) Run structure of key paragraphs
print()
print("=" * 70)
print("RUN STRUCTURE OF KEY PARAGRAPHS")
print("=" * 70)
doc = Document(SRC)
KEYS = [19, 28, 61, 177, 225, 226, 227, 228, 229, 246, 255, 273, 286, 350,
        356, 358, 371, 610]
for i in KEYS:
    p = doc.paragraphs[i]
    print(f"\n--- P{i} ({p.style.name}) runs={len(p.runs)} ---")
    print(f"   FULL TEXT: {p.text!r}")
    for ri, r in enumerate(p.runs):
        print(f"   run[{ri}] bold={r.bold} italic={r.italic} text={r.text!r}")

# 3) Find every paragraph containing "7.91" or standalone "33" or "November"
print()
print("=" * 70)
print("PARAGRAPHS containing 7.91 / 33 / November / 97 / 13.43 / 56.30 / 63.06")
print("=" * 70)
for i, p in enumerate(doc.paragraphs):
    t = p.text
    if any(s in t for s in ["7.91", "November", "97.0", "13.43", "56.30",
                            "63.06", "N=33", "N = 33"]):
        print(f"[P{i}] {t!r}")
# table cells too
for ti, tbl in enumerate(doc.tables):
    for ri, row in enumerate(tbl.rows):
        for ci, c in enumerate(row.cells):
            t = c.text
            if any(s in t for s in ["7.91", "November", "97.0", "13.43",
                                   "56.30", "63.06", "N=33", "N = 33", "33"]):
                print(f"[T{ti} R{ri} C{ci}] {t!r}")

# 4) Confirm Appendix D absence in body
print()
print("=" * 70)
print("APPENDIX HEADINGS IN BODY")
print("=" * 70)
for i, p in enumerate(doc.paragraphs):
    if re.search(r'appendix', p.text, re.I):
        print(f"[P{i}] ({p.style.name}) {p.text!r}")
