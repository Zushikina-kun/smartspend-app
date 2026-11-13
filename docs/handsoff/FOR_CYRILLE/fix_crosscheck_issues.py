"""
Fix the 5 issues found in the deep cross-check:
1. PPT Slide 8 notes: add purposive sampling for validator mention
2. Manuscript: "comparative technical evaluation" -> "comparative technical evaluation of eight candidate LLM APIs"
3. Manuscript: add median 55.0 to SUS results paragraph
4. PPT Slide 17 Conclusion 2: add "eight candidate LLM APIs evaluated"
5. Manuscript Conclusions: fix "20 candidate LLM models" -> "eight candidate LLM APIs"
"""
import shutil, re
from docx import Document
from docx.oxml.ns import qn
from pptx import Presentation

DOCX   = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\1_MAIN_MANUSCRIPT_FINAL.docx"
PPT    = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\SmartSpend_Defense.pptx"

shutil.copy(DOCX, DOCX + '.crosscheck.bak')
shutil.copy(PPT,  PPT  + '.crosscheck.bak')

log = []

# ════════════════════════════════════════════════════════
# FIX MANUSCRIPT
# ════════════════════════════════════════════════════════
doc = Document(DOCX)

for i, para in enumerate(doc.paragraphs):
    t = para.text

    # Fix 2: "comparative technical evaluation" -> add "of eight candidate LLM APIs"
    if 'comparative technical evaluation' in t and 'eight' not in t and 'LLM API' not in t:
        for run in para.runs:
            if 'comparative technical evaluation' in run.text:
                run.text = run.text.replace(
                    'comparative technical evaluation',
                    'comparative technical evaluation of eight candidate LLM APIs'
                )
                log.append(f'MS para[{i}]: added "eight candidate LLM APIs" to comparative evaluation sentence')
                break

    # Fix 3: add median to SUS results paragraph
    if '61.83' in t and 'SD' in t and '17.58' in t and 'median' not in t.lower():
        for run in para.runs:
            if 'SD' in run.text and '17.58' in run.text:
                # Find the SD 17.58 reference and add median after it
                run.text = run.text.replace(
                    'SD = 17.58',
                    'SD = 17.58, median = 55.00'
                ).replace(
                    'SD\u00a0=\u00a017.58',
                    'SD = 17.58, median = 55.00'
                )
                log.append(f'MS para[{i}]: added median 55.00 to SUS results')
                break

    # Fix 5: "20 candidate LLM models" in conclusions
    if '20 candidate LLM models' in t or 'twenty candidate' in t.lower():
        for run in para.runs:
            if '20 candidate LLM models' in run.text:
                run.text = run.text.replace('20 candidate LLM models', 'eight candidate LLM APIs')
                log.append(f'MS para[{i}]: fixed "20 candidate LLM models" -> "eight candidate LLM APIs"')
            if 'twenty candidate' in run.text.lower():
                run.text = run.text.replace('twenty candidate', 'eight candidate')
                log.append(f'MS para[{i}]: fixed "twenty candidate" -> "eight candidate"')

    # Also fix in tables
for table in doc.tables:
    for row in table.rows:
        for cell in row.cells:
            for para in cell.paragraphs:
                for run in para.runs:
                    if '20 candidate LLM models' in run.text:
                        run.text = run.text.replace('20 candidate LLM models', 'eight candidate LLM APIs')
                        log.append(f'MS table: fixed "20 candidate LLM models"')

doc.save(DOCX)
log.append('Manuscript saved.')

# ════════════════════════════════════════════════════════
# FIX PPT
# ════════════════════════════════════════════════════════
prs = Presentation(PPT)

def get_all_runs(shape):
    runs = []
    if shape.has_text_frame:
        for para in shape.text_frame.paragraphs:
            for run in para.runs:
                runs.append(run)
    if shape.shape_type == 6:
        for s in shape.shapes:
            runs.extend(get_all_runs(s))
    return runs

# Fix 1: Slide 8 notes — add purposive sampling mention
slide8 = prs.slides[7]
notes_tf = slide8.notes_slide.notes_text_frame
existing_notes = notes_tf.text.strip()
if 'purposive' not in existing_notes.lower():
    new_note = (existing_notes + '\n\nNote: Purposive sampling was used for the content validator (Avigail Candevario, PFMe) — selected based on her expertise in personal financial management. Random sampling was used for all 30 respondents.').strip()
    notes_tf.text = new_note
    log.append('PPT Slide 8 notes: added purposive sampling for validator')

# Fix 4: Slide 17 — update Conclusion 2 text to mention eight candidate LLMs
slide17 = prs.slides[16]
for shape in slide17.shapes:
    for run in get_all_runs(shape):
        if 'Gemini 3.5 Flash-Lite with failover' in run.text:
            run.text = run.text.replace(
                'v3.1.0 working Android app: 34 AI actions, Gemini 3.5 Flash-Lite with failover, Financial Health Score.',
                'v3.1.0 working Android app: 34 AI actions, Gemini 3.5 Flash-Lite (selected from 8 candidate LLM APIs) with failover, Financial Health Score.'
            )
            log.append('PPT Slide 17: updated Conclusion 2 to mention 8 candidate LLM APIs')

prs.save(PPT)
log.append('PPT saved.')

# ════════════════════════════════════════════════════════
# PRINT LOG
# ════════════════════════════════════════════════════════
print(f'\n{len(log)} actions:')
for l in log: print(f'  {l}')

# ════════════════════════════════════════════════════════
# VERIFY
# ════════════════════════════════════════════════════════
doc2 = Document(DOCX)
ms2 = '\n'.join(p.text for p in doc2.paragraphs)

prs2 = Presentation(PPT)
def ppt_text_all(prs):
    t=[]
    def g(s):
        if s.has_text_frame: t.append(s.text_frame.text)
        if s.shape_type==6:
            for x in s.shapes: g(x)
    for slide in prs.slides:
        for s in slide.shapes: g(s)
        t.append(slide.notes_slide.notes_text_frame.text)
    return '\n'.join(t)
pt2 = ppt_text_all(prs2)

checks = [
    ('MS: eight candidate LLM APIs', 'eight candidate LLM APIs' in ms2 or 'eight candidate LLM' in ms2),
    ('MS: no 20 candidate LLM models', '20 candidate LLM models' not in ms2),
    ('PPT Slide 8 notes: purposive', 'purposive' in pt2.lower()),
    ('PPT Slide 17: 8 candidate mention', '8 candidate LLM' in pt2 or 'eight candidate' in pt2.lower()),
    ('MS: SUS 61.83 still correct', '61.83' in ms2),
    ('MS: SD 17.58 still correct', '17.58' in ms2),
    ('PPT: Gemini 3.5 still correct', 'Gemini 3.5' in pt2),
    ('PPT: No Gemini 1.5', 'Gemini 1.5' not in pt2),
]
print('\nVerification:')
for label, ok in checks:
    print(f'  {"OK  " if ok else "FAIL"}: {label}')
