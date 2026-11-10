from docx import Document
import re

doc = Document(r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx')
full = '\n'.join(p.text for p in doc.paragraphs)
for table in doc.tables:
    for row in table.rows:
        for cell in row.cells:
            full += '\n'.join(p.text for p in cell.paragraphs)

checks = [
    ("61.83 appears (SUS score)",             bool(re.search(r'61\.83', full))),
    ("N=30 or N = 30 appears",                bool(re.search(r'N\s*=\s*30', full))),
    ("grade of D or Grade D appears",         bool(re.search(r'grade of D|Grade D', full, re.I))),
    ("partially achieved appears",            bool(re.search(r'partially achieved', full, re.I))),
    ("Avigail Candevario appears",            bool(re.search(r'Avigail Candevario', full, re.I))),
    ("Jeoffrey appears",                      bool(re.search(r'Jeoffrey', full))),
    ("Joffrey does NOT appear",               not bool(re.search(r'Joffrey', full))),
    ("sqflite appears",                       bool(re.search(r'sqflite', full, re.I))),
    ("Mr. Shekiro R. Raposas appears",        bool(re.search(r'Mr\.\s*Shekiro R\. Raposas', full))),
]

print("\n--- Verification Results ---")
all_pass = True
for name, result in checks:
    status = "PASS" if result else "FAIL"
    if not result:
        all_pass = False
    print(f"  [{status}] {name}")

joff = re.findall(r'Joffrey', full, re.I)
jeff = re.findall(r'Jeoffrey', full, re.I)
print(f"\nJoffrey occurrences: {len(joff)}")
print(f"Jeoffrey occurrences: {len(jeff)}")
print(f"\nAll checks passed: {all_pass}")
