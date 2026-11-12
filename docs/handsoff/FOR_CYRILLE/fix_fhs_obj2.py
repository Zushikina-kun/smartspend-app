import shutil
from docx import Document
from docx.shared import Pt
from docx.oxml import OxmlElement
from docx.text.paragraph import Paragraph as DocxParagraph

DOCX = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'
shutil.copy(DOCX, DOCX + '.fhsobj2.bak')
doc = Document(DOCX)

def insert_after(doc, para_idx, text):
    before_p = doc.paragraphs[para_idx]
    new_p = OxmlElement('w:p')
    before_p._p.addnext(new_p)
    po = DocxParagraph(new_p, before_p._parent)
    r = po.add_run(text)
    r.font.name = 'Tahoma'
    r.font.size = Pt(12)
    return po

# FIX A: Insert FHS item 3 (Budget Adherence) between item 2 (para 241+1) and item 4 (para 243)
# Para 241 = Savings Rate, next is probably Overspend Control, then jumps to 4=Logging
# Check para 242
p242 = doc.paragraphs[242].text.strip()
p243 = doc.paragraphs[243].text.strip()
print(f'Para 242: {p242[:80]}')
print(f'Para 243: {p243[:80]}')

# Insert after para 242 (Overspend Control should be there, then 3 goes before 4)
insert_after(doc, 242,
    "3. Budget Adherence (25 pts): Score = 25 × (onBudgetCategories / "
    "totalBudgetedCategories). Category-level budget limits tracked whether the "
    "user stayed within each spending category for the period."
)
print('Inserted FHS item 3 after para 242')

# FIX B: Insert Objective 2 paragraph between para 195 (For the first obj) and 196 (For the third obj)
insert_after(doc, 195,
    "For the second objective, SmartSpend was designed and developed as an Android "
    "mobile application. The development utilized Flutter for the user interface, "
    "SQLite for local data storage, Firebase for cloud synchronization and "
    "authentication, and a large language model API for AI-powered expense parsing "
    "and financial assistance. Candidate LLM APIs were comparatively evaluated "
    "using standardized Filipino-English prompts to select the most suitable provider."
)
print('Inserted Objective 2 Data Gathering paragraph after para 195')

doc.save(DOCX)
print('Saved.')

# Verify
doc2 = Document(DOCX)
items = [
    ('FHS Budget Adherence', 'Budget Adherence (25 pts)'),
    ('Obj 2 Data Gathering', 'For the second objective, SmartSpend was designed'),
]
for label, term in items:
    found = any(term in p.text for p in doc2.paragraphs)
    print(f'  {"OK" if found else "MISSING"}: {label}')
print(f'Total paras: {len(doc2.paragraphs)}')
