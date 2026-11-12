"""Fix conclusions section and add 2 more recommendations per Maam Ellen."""
import shutil
from docx import Document
from docx.oxml import OxmlElement
from docx.text.paragraph import Paragraph as DocxParagraph
from docx.shared import Pt

DOCX = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'
shutil.copy(DOCX, DOCX + '.concrec.bak')
doc = Document(DOCX)
fixes = []

# ── 1. Delete orphan "SmartSpend" paragraph (para 300) ───────────────────
p300 = doc.paragraphs[300]
if p300.text.strip() == 'SmartSpend':
    if p300.runs:
        p300.runs[0].text = ''
        for r in p300.runs[1:]: r.text = ''
    fixes.append('Cleared orphan SmartSpend para 300')

# ── 2. Check if Objective 1 conclusion exists ─────────────────────────────
conclusions_start = None
obj1_found = False
obj2_found = False
obj3_found = False
recs_para = None

for i, p in enumerate(doc.paragraphs):
    t = p.text.strip()
    if t == 'Conclusions' and i > 290:
        conclusions_start = i
    if conclusions_start:
        if 'first objective' in t.lower() and 'achieved' in t.lower():
            obj1_found = True
        if 'second objective' in t.lower() and 'achieved' in t.lower():
            obj2_found = True
        if 'third objective' in t.lower() and 'partially achieved' in t.lower():
            obj3_found = True
        if t == 'Recommendations' and i > conclusions_start:
            recs_para = i
            break

print(f'Conclusions at: {conclusions_start}')
print(f'Obj1 found: {obj1_found}, Obj2 found: {obj2_found}, Obj3 found: {obj3_found}')
print(f'Recommendations at: {recs_para}')

# Insert missing conclusion paragraphs before "Recommendations"
def insert_para_before(doc, before_idx, text):
    before_p = doc.paragraphs[before_idx]
    new_p = OxmlElement('w:p')
    before_p._p.addprevious(new_p)
    para_obj = DocxParagraph(new_p, before_p._parent)
    run = para_obj.add_run(text)
    # Match font of surrounding text
    run.font.name = 'Tahoma'
    run.font.size = Pt(12)
    return para_obj

if recs_para is not None:
    inserted = 0
    if not obj3_found:
        insert_para_before(doc, recs_para + inserted,
            "The third objective was to evaluate the usability of SmartSpend using the "
            "System Usability Scale. The evaluation yielded a mean SUS score of 61.83 "
            "(SD = 17.58), which was below the pre-established acceptance threshold of 80 "
            "and the 68-point average benchmark. The third objective was partially achieved.")
        fixes.append('Inserted Objective 3 conclusion paragraph')
        inserted += 1

    if not obj1_found:
        insert_para_before(doc, recs_para - 1 + inserted,
            "The first objective was to assess the financial management practices, "
            "budgeting challenges, and expense tracking behaviors of parents aged 35 to 55 "
            "and young professionals aged 21 to 35. The needs assessment of thirty (30) "
            "respondents revealed that 96.7% expressed positive intent to use an AI-powered "
            "financial application and 93.3% already used GCash. The first objective was achieved.")
        fixes.append('Inserted Objective 1 conclusion paragraph')

# ── 3. Add 2 more recommendations (8 and 9) ──────────────────────────────
# Find the last recommendation (para 309 = rec 7)
rec7_idx = None
for i, p in enumerate(doc.paragraphs):
    t = p.text.strip()
    if t.startswith('7.') and 'Longitudinal' in t and i > 290:
        rec7_idx = i
        break

if rec7_idx:
    # Add rec 8 after rec 7
    rec7_p = doc.paragraphs[rec7_idx]

    # Rec 9
    new_p9 = OxmlElement('w:p')
    rec7_p._p.addnext(new_p9)
    p9 = DocxParagraph(new_p9, rec7_p._parent)
    r9 = p9.add_run(
        "9. Formal parsing evaluation. The researchers recommended that future researchers "
        "conduct a formal evaluation of the OCR and AI parsing accuracy using standardized "
        "test receipts across multiple platforms to establish a reliable performance baseline "
        "for the multimodal import features."
    )
    r9.font.name = 'Tahoma'
    r9.font.size = Pt(12)

    # Rec 8 (insert before rec 9 = right after rec 7)
    new_p8 = OxmlElement('w:p')
    rec7_p._p.addnext(new_p8)
    p8 = DocxParagraph(new_p8, rec7_p._parent)
    r8 = p8.add_run(
        "8. UI/UX refinement. The researchers recommended that the developers address the "
        "main usability concerns identified in the SUS results — particularly system "
        "consistency (Q6) and complexity (Q2) — through interface redesign in a future "
        "iteration to improve the overall usability score."
    )
    r8.font.name = 'Tahoma'
    r8.font.size = Pt(12)

    fixes.append('Added Recommendation 8 (UI/UX refinement)')
    fixes.append('Added Recommendation 9 (Formal parsing evaluation)')

doc.save(DOCX)
print(f'\n{len(fixes)} fixes applied:')
for f in fixes: print(f'  {f}')

# Verify recommendations count
doc2 = Document(DOCX)
rec_count = 0
in_recs = False
for p in doc2.paragraphs:
    t = p.text.strip()
    if t == 'Recommendations':
        in_recs = True
    if in_recs and t and t[0].isdigit() and '. ' in t[:5]:
        rec_count += 1
    if in_recs and 'References' in t:
        break
print(f'\nTotal recommendations: {rec_count}')
