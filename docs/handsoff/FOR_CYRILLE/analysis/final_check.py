"""Final comprehensive check of the merged document."""
from docx import Document
import re

FINAL_PATH = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'
doc = Document(FINAL_PATH)
paras = list(doc.paragraphs)

# Build full text
full = '\n'.join(p.text for p in paras)
for table in doc.tables:
    for row in table.rows:
        for cell in row.cells:
            full += '\n'.join(p.text for p in cell.paragraphs)

print("=== Protected Values Check ===")
checks = [
    ("61.83",                          bool(re.search(r'61\.83', full))),
    ("N=30 or N = 30",                 bool(re.search(r'N\s*=\s*30', full))),
    ("grade of D",                     bool(re.search(r'grade of D|Grade D', full, re.I))),
    ("partially achieved",             bool(re.search(r'partially achieved', full, re.I))),
    ("Avigail Candevario",             bool(re.search(r'Avigail Candevario', full, re.I))),
    ("Jeoffrey appears",               bool(re.search(r'Jeoffrey', full))),
    ("Joffrey NOT present",            not bool(re.search(r'Joffrey', full))),
    ("sqflite",                        bool(re.search(r'sqflite', full, re.I))),
    ("Mr. Shekiro R. Raposas",         bool(re.search(r'Mr\.\s*Shekiro R\. Raposas', full))),
    ("Sauro & Lewis, 2016",            bool(re.search(r'Sauro & Lewis, 2016', full))),
    ("Recommendation 6 present",       bool(re.search(r'Recommendation 6', full))),
    ("Priority 9 NOT present",         not bool(re.search(r'Priority 9', full))),
    ("Dr. Janelli NOT present",        not bool(re.search(r'Dr\. Janelli', full))),
    ("live demonstration NOT present", not bool(re.search(r'live demonstration', full, re.I))),
    ("Table 2.1 and Validators",       bool(re.search(r'Table 2\.1\. Distribution of Respondents and Validators', full))),
    ("behaviours applied (past)",      bool(re.search(r'behaviours applied', full))),
    ("shipped with (past)",            bool(re.search(r'shipped with', full))),
    ("96.7%",                          bool(re.search(r'96\.7%', full))),
    ("93.3%",                          bool(re.search(r'93\.3%', full))),
    ("SD 17.58",                       bool(re.search(r'17\.58', full))),
]

all_pass = True
for name, result in checks:
    status = "PASS" if result else "FAIL"
    if not result:
        all_pass = False
    print(f"  [{status}] {name}")

print(f"\nAll checks passed: {all_pass}")
print(f"Total paragraphs: {len(paras)}")

# Check TOC entries are clean
print("\n=== TOC Entry Check ===")
toc_entries = [
    'Figure 1.1.  Financial Literacy Rates',
    'Figure 3.1.  SmartSpend System Flowchart',
    'Figure 3.6.  Expense Logging',
    'Figure 3.7.  Receipt Scanning',
    'Figure 3.8.  Financial Health Score',
    'Figure 3.9.  Budgets',
    'Table 1.1.  Three-Level Gap',
    'Table 1.2.  Feature Comparison',
    'Table 2.1.  Distribution of Respondents and Validators',
    'Table 3.1.  Demographic Profile',
    'Table 3.2.  Comparative Evaluation',
]
for entry in toc_entries:
    found = any(entry in p.text for p in paras)
    print(f"  [{'OK' if found else 'MISSING'}] {entry}")
