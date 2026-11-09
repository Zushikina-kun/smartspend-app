import re
from docx import Document

SRC = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\CAPSTONE_LucidFrame_-_SMARTSPEND__5_ (1).docx"
doc = Document(SRC)

TERMS = [
    "Mangaoang", "MIT", "62.50", "61.83", "N=5", "N = 5", "N=30", "N = 30",
    "13.43", "17.58", "56.30", "63.06", "97.0%", "96.7%", "N=33", "N = 33",
    "November 9", "November 10",
    "APPENDIX D", "Appendix D", "appendix d", "Semi-Structured Interview",
    "Semi-structured interview", "semi-structured", "interview", "interviews",
    "interview guide", "mixed-method", "mixed method", "mixed-methods",
    "qualitative", "quantitative", "Young Professional", "Parent",
    "55.00", "median", "46.7", "43.3", "10.0", "mean",
]

def norm(s):
    return s

print("# PARAGRAPH HITS")
for i, p in enumerate(doc.paragraphs):
    t = p.text
    if not t.strip():
        continue
    low = t.lower()
    hits = [term for term in TERMS if term.lower() in low]
    if hits:
        print(f"\n[P{i}] ({p.style.name}) hits={hits}")
        print(f"   text={t!r}")

print("\n\n# TABLE HITS")
for ti, tbl in enumerate(doc.tables):
    for ri, row in enumerate(tbl.rows):
        cells = row.cells
        for ci, c in enumerate(cells):
            t = c.text
            if not t.strip():
                continue
            low = t.lower()
            hits = [term for term in TERMS if term.lower() in low]
            if hits:
                print(f"\n[T{ti} R{ri} C{ci}] hits={hits}")
                print(f"   text={t!r}")

# Also list all headings that look like APPENDIX
print("\n\n# ALL APPENDIX-ISH HEADINGS")
for i, p in enumerate(doc.paragraphs):
    t = p.text.strip()
    if re.search(r'appendix', t, re.I):
        print(f"[P{i}] ({p.style.name}) {t!r}")
