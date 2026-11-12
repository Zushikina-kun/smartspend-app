"""Apply the 5 remaining issues from HANDOFF_COMPLETE_NOV13.md"""
import shutil
from docx import Document
from docx.shared import Pt
from docx.oxml import OxmlElement
from docx.text.paragraph import Paragraph as DocxParagraph

DOCX = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'
shutil.copy(DOCX, DOCX + '.remaining5.bak')
doc = Document(DOCX)
log = []

def rp(para, new_text):
    if para.runs:
        para.runs[0].text = new_text
        for r in para.runs[1:]: r.text = ''
    else:
        para.add_run(new_text)

def insert_after(doc, para_idx, text):
    before_p = doc.paragraphs[para_idx]
    new_p = OxmlElement('w:p')
    before_p._p.addnext(new_p)
    po = DocxParagraph(new_p, before_p._parent)
    r = po.add_run(text)
    r.font.name = 'Tahoma'
    r.font.size = Pt(12)
    return po

# ── FIX 1: Figure 3 description — wrong SUS zones ────────────────────────
NEW_FIG3_DESC = (
    "Figure 3 shows the SUS Score Interpretation Framework used to evaluate the "
    "usability of SmartSpend. SUS scores range from 0 to 100 and were categorized "
    "into acceptability levels: Not Acceptable (below 51), Marginal (51 to 70), and "
    "Acceptable (71 and above) based on Bangor et al. (2008). Adjective anchors from "
    "Bangor et al. (2009) placed 'OK' at approximately 51, 'Good' at 71, and "
    "'Excellent' at 85. The dashed line marks the 68-point average benchmark "
    "(Sauro & Lewis, 2016) and the dotted line marks the pre-established target of 80. "
    "SmartSpend's mean score of 61.83 is marked with a red line, falling in the "
    "Marginal range."
)

for i, p in enumerate(doc.paragraphs):
    t = p.text
    if ('Poor (below 60)' in t or 'Marginal (60' in t or
            'Acceptable (70' in t) and 'SUS' in t:
        rp(p, NEW_FIG3_DESC)
        log.append(f'[{i}] FIX 1: Figure 3 description updated with correct zones')
        break

# ── FIX 2: FHS formula — add missing item 3 (Budget Adherence) ───────────
for i, p in enumerate(doc.paragraphs):
    t = p.text.strip()
    # Find "2. Overspend Control" para
    if t.startswith('2.') and 'Overspend Control' in t:
        # Check next para — if it jumps to "4. Logging Consistency", insert item 3
        next_t = doc.paragraphs[i+1].text.strip() if i+1 < len(doc.paragraphs) else ''
        if next_t.startswith('4.') and 'Logging' in next_t:
            insert_after(doc, i,
                "3. Budget Adherence (25 pts): Score = 25 × (onBudgetCategories / "
                "totalBudgetedCategories). Category-level budget limits followed "
                "zero-based budgeting principles, tracking whether the user stayed "
                "within each spending category for the period."
            )
            log.append(f'[{i}] FIX 2: Inserted FHS item 3 (Budget Adherence) after para {i}')
        break

# ── FIX 3: Population — purposive → random sampling ──────────────────────
for i, p in enumerate(doc.paragraphs):
    t = p.text
    if ('thirty (30) respondents were selected using purposive sampling' in t and
            i > 150):
        new_t = t.replace(
            'A total of thirty (30) respondents were selected using purposive sampling.',
            'A total of thirty (30) respondents were selected using random sampling, '
            'as any parent aged 35 to 55 or young professional aged 21 to 35 who met '
            'the inclusion criteria was eligible to participate. The content validator '
            'was selected through purposive sampling based on her expertise in '
            'financial management.'
        )
        if new_t != t:
            rp(p, new_t)
            log.append(f'[{i}] FIX 3: purposive → random sampling')
        break

# ── FIX 4: Data Gathering — add Objective 2 paragraph ────────────────────
obj2_missing = True
for i, p in enumerate(doc.paragraphs):
    if 'For the second objective' in p.text and i > 200:
        obj2_missing = False
        log.append(f'[{i}] FIX 4: Objective 2 paragraph already present — skipped')
        break

if obj2_missing:
    # Find "For the third objective" in Data Gathering section
    for i, p in enumerate(doc.paragraphs):
        t = p.text.strip()
        if t.startswith('For the third objective') and 'SUS' in t and i > 200:
            insert_after(doc, i - 1,
                "For the second objective, SmartSpend was designed and developed as an "
                "Android mobile application. The development utilized Flutter for the "
                "user interface, SQLite for local data storage, Firebase for cloud "
                "synchronization and authentication, and a large language model API for "
                "AI-powered expense parsing and financial assistance. Candidate LLM APIs "
                "were comparatively evaluated using standardized Filipino-English prompts "
                "to select the most suitable provider for the system."
            )
            log.append(f'FIX 4: Inserted Objective 2 Data Gathering paragraph before para {i}')
            break

# ── FIX 5: Appendix a → Appendix A ───────────────────────────────────────
for i, p in enumerate(doc.paragraphs):
    if 'Appendix a)' in p.text or 'see Appendix a' in p.text:
        new_t = p.text.replace('Appendix a)', 'Appendix A)').replace(
            'see Appendix a', 'see Appendix A')
        rp(p, new_t)
        log.append(f'[{i}] FIX 5: Appendix a → Appendix A')

# ── FIX 6: "By combining quantitative and developmental approaches" awkward ─
for i, p in enumerate(doc.paragraphs):
    if 'By combining quantitative and developmental approaches' in p.text:
        new_t = p.text.replace(
            'By combining quantitative and developmental approaches',
            'By adopting a quantitative developmental approach'
        )
        rp(p, new_t)
        log.append(f'[{i}] FIX 6: quantitative sentence smoothed')

# ── FIX 7: Photo Documentation empty heading ─────────────────────────────
for i, p in enumerate(doc.paragraphs):
    t = p.text.strip()
    if t == 'PHOTO DOCUMENTATION' or t == 'Photo Documentation':
        # Clear heading and following blank paras
        if p.runs:
            p.runs[0].text = ''
            for r in p.runs[1:]: r.text = ''
        # Clear up to 10 following blank paras
        for j in range(i+1, min(i+12, len(doc.paragraphs))):
            t2 = doc.paragraphs[j].text.strip()
            if t2 and t2 != '':  # stop at non-blank
                break
            if doc.paragraphs[j].runs:
                doc.paragraphs[j].runs[0].text = ''
                for r in doc.paragraphs[j].runs[1:]: r.text = ''
        log.append(f'[{i}] FIX 7: Removed empty Photo Documentation section')
        break

doc.save(DOCX)
print(f'\nApplied {len(log)} fixes:')
for l in log: print(f'  {l}')
print('\nDone.')
