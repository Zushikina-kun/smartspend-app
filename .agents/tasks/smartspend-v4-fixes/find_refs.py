import re
from docx import Document

SRC = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\1_MAIN_MANUSCRIPT_FINAL(MAIN_V4) (2).docx"
doc = Document(SRC)
paras = doc.paragraphs

# Find every in-text reference to a Figure or Table number (e.g., Figure 1.2, Table 2.1, Figure 3, Table 8)
fig_pat = re.compile(r'Figure\s*\d+(?:\.\d+)?', re.IGNORECASE)
tab_pat = re.compile(r'Table\s*\d+(?:\.\d+)?', re.IGNORECASE)
app_pat = re.compile(r'Appendix\s*[A-Z]', re.IGNORECASE)

print("=== FIGURE REFERENCES ===")
for i, p in enumerate(paras):
    t = p.text
    # skip the List of Figures block (¶125-148) and List of Tables (¶150-163) and captions themselves handled separately
    for m in fig_pat.finditer(t):
        ctx = t[max(0,m.start()-40):m.end()+40]
        print(f"[{i:04d}] {m.group()}  ...{ctx}...")

print("\n=== TABLE REFERENCES ===")
for i, p in enumerate(paras):
    t = p.text
    for m in tab_pat.finditer(t):
        ctx = t[max(0,m.start()-40):m.end()+40]
        print(f"[{i:04d}] {m.group()}  ...{ctx}...")

print("\n=== APPENDIX REFERENCES ===")
for i, p in enumerate(paras):
    t = p.text
    for m in app_pat.finditer(t):
        ctx = t[max(0,m.start()-30):m.end()+30]
        print(f"[{i:04d}] {m.group()}  ...{ctx}...")
