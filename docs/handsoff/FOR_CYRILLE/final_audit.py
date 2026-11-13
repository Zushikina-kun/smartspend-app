from docx import Document
from pptx import Presentation

DOCX = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\1_MAIN_MANUSCRIPT_FINAL.docx'
PPT  = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\SmartSpend_Defense.pptx'
SCRIPT = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\4_DEFENSE_SCRIPT_FINAL.md'

doc = Document(DOCX)
ms = '\n'.join(p.text for p in doc.paragraphs)
ms_tables = '\n'.join(c.text for t in doc.tables for row in t.rows for c in row.cells)
ms_full = ms + '\n' + ms_tables

prs = Presentation(PPT)
def ppt_all():
    t = []
    def g(s):
        if s.has_text_frame: t.append(s.text_frame.text)
        if s.shape_type == 6:
            for x in s.shapes: g(x)
    for slide in prs.slides:
        for s in slide.shapes: g(s)
        t.append(slide.notes_slide.notes_text_frame.text)
    return '\n'.join(t)
pt = ppt_all()

script = open(SCRIPT, encoding='utf-8').read()

checks = [
    # ── MANUSCRIPT ──────────────────────────────────────────────────────────
    ('MS: quantitative descriptive developmental', 'quantitative descriptive developmental' in ms_full),
    ('MS: nine recommendations in abstract', 'Nine recommendations' in ms_full),
    ('MS: eight-provider chain in abstract', 'eight-provider' in ms_full),
    ('MS: Gemini 3.5 Flash-Lite', 'Gemini 3.5 Flash-Lite' in ms_full),
    ('MS: SUS 61.83', '61.83' in ms_full),
    ('MS: SD 17.58', '17.58' in ms_full),
    ('MS: median in SUS results', 'median' in ms_full.lower()),
    ('MS: Grade D', 'Grade D' in ms_full or 'grade of D' in ms_full),
    ('MS: adjective OK in SUS', '"OK"' in ms_full),
    ('MS: partially achieved Obj3', 'partially achieved' in ms_full),
    ('MS: No mixed-methods research design', 'mixed-methods research design' not in ms_full),
    ('MS: No mixed-methods developmental', 'mixed-methods developmental' not in ms_full),
    ('MS: random sampling respondents', 'random sampling' in ms_full),
    ('MS: purposive for validator', 'purposive sampling' in ms_full),
    ('MS: Avigail Candevario PFMe', 'Avigail Candevario, PFMe' in ms_full),
    ('MS: No Susan Arquisal', 'Susan Arquisal' not in ms_full),
    ('MS: 96.7%', '96.7' in ms_full),
    ('MS: 93.3%', '93.3' in ms_full),
    ('MS: 30 valid of 36', '36' in ms_full),
    ('MS: eight candidate LLM APIs', 'eight candidate LLM' in ms_full),
    ('MS: No 20 candidate LLM models', '20 candidate LLM' not in ms_full),
    ('MS: 34 agentic actions', '34 autonomous' in ms_full or '34 agentic' in ms_full),
    ('MS: Rec 9 Formal parsing', '9. Formal parsing' in ms_full),
    ('MS: Rec 8 UI/UX refinement', '8. UI/UX' in ms_full),
    ('MS: Table 3 validator note', 'content validator participated separately' in ms_full),
    ('MS: Scope Android only', 'The system was available only on Android' in ms_full),
    ('MS: No proposed system', 'proposed system' not in ms_full),
    ('MS: Appendix B cross-ref', 'Appendix B' in ms_full),
    ('MS: Appendix D cross-ref', 'Appendix D' in ms_full),
    ('MS: Jeoffrey B. Layco MIS', 'Jeoffrey B. Layco, MIS' in ms_full),
    ('MS: Shekiro Raposas MTS MIS', 'Shekiro R. Raposas, MTS, MIS' in ms_full),
    ('MS: Mary-Ann Mzana MTS', 'Mary-Ann Mzana, MTS' in ms_full),
    ('MS: Ellen Mangaoang DIT', 'DIT' in ms_full and 'Mangaoang' in ms_full),
    ('MS: No duplicate conclusions', ms_full.count('The first objective was') <= 2),
    ('MS: Data Gathering per objective', 'For the first objective' in ms_full and 'For the second objective' in ms_full and 'For the third objective' in ms_full),
    ('MS: No interviews conducted', 'No interviews were conducted' in ms_full),
    ('MS: No future features in Kanban', 'multi-wallet system enabling' not in ms_full),
    # ── PPT ─────────────────────────────────────────────────────────────────
    ('PPT: No Gemini 1.5', 'Gemini 1.5' not in pt),
    ('PPT: Gemini 3.5 Flash-Lite', 'Gemini 3.5 Flash-Lite' in pt),
    ('PPT: 8 candidate LLM APIs', '8 candidate LLM APIs' in pt),
    ('PPT: quantitative descriptive developmental', 'quantitative descriptive developmental' in pt.lower()),
    ('PPT: random sampling', 'random sampling' in pt.lower()),
    ('PPT: purposive in notes Slide 8', 'purposive' in pt.lower()),
    ('PPT: 16 parents needs-assessment', '16 parents' in pt),
    ('PPT: 10 parents 20 YP SUS split', '10 parents' in pt and '20 young professionals' in pt),
    ('PPT: 96.7%', '96.7' in pt),
    ('PPT: 93.3%', '93.3' in pt),
    ('PPT: 61.83', '61.83' in pt),
    ('PPT: SD 17.58', '17.58' in pt),
    ('PPT: Grade D', 'Grade D' in pt),
    ('PPT: adjective OK', '"OK"' in pt),
    ('PPT: partially achieved', 'Partially achieved' in pt or 'partially achieved' in pt.lower()),
    ('PPT: Rec 8 UI/UX in notes', 'UI/UX refinement' in pt),
    ('PPT: Rec 9 formal parsing in notes', 'Formal parsing' in pt),
    ('PPT: Slide 17 eight candidate LLM', '8 candidate LLM' in pt or 'eight candidate' in pt.lower()),
    ('PPT: No mixed-methods', 'mixed-methods' not in pt and 'mixed methods' not in pt.lower()),
    ('PPT: 34 AI actions', '34' in pt),
    ('PPT: Nov 16 2026', 'November 16' in pt),
    ('PPT: Jeoffrey Layco', 'Jeoffrey' in pt),
    ('PPT: Raposas MTS MIS', 'Raposas' in pt),
    ('PPT: Mzana MTS', 'Mzana' in pt),
    ('PPT: Ellen Flores Mangaoang DIT', 'Ellen Flores Mangaoang, DIT' in pt),
    # ── SCRIPT ──────────────────────────────────────────────────────────────
    ('SCRIPT: quantitative descriptive', 'quantitative descriptive developmental' in script.lower()),
    ('SCRIPT: random sampling', 'random sampling' in script.lower()),
    ('SCRIPT: purposive for validator', 'purposive sampling' in script.lower()),
    ('SCRIPT: 16 parents + 14 YP', '16 parents' in script),
    ('SCRIPT: 10 parents + 20 YP SUS', '10 parents and 20 young professionals' in script),
    ('SCRIPT: 61.83', '61.83' in script),
    ('SCRIPT: SD 17.58', '17.58' in script),
    ('SCRIPT: Grade D', 'Grade D' in script),
    ('SCRIPT: partially achieved', 'partially achieved' in script.lower()),
    ('SCRIPT: eight candidate LLM APIs', 'eight candidate LLM APIs' in script),
    ('SCRIPT: Gemini 3.5 Flash-Lite', 'Gemini 3.5 Flash-Lite' in script),
    ('SCRIPT: No Gemini 1.5 (outside table)', 'Gemini 1.5' not in script.replace('"Gemini 1.5"', '').replace('| "Gemini 1.5"', '')),
    ('SCRIPT: 9 recommendations', 'nine recommendations' in script.lower() or '9 recommendations' in script.lower()),
    ('SCRIPT: Rec 8 UI/UX', '8. **UI/UX refinement' in script),
    ('SCRIPT: Rec 9 Formal parsing', '9. **Formal parsing' in script),
    ('SCRIPT: No mixed methods (outside table)', 'mixed methods' not in script.replace('"mixed methods"', '').replace('mixed methods" (no interviews', '')),
    ('SCRIPT: Avigail Candevario PFMe', 'Avigail Candevario, PFMe' in script),
    ('SCRIPT: Nov 16 2026', 'November 16' in script),
    ('SCRIPT: Jeoffrey Layco', 'Jeoffrey' in script),
    ('SCRIPT: Raposas', 'Raposas' in script),
    ('SCRIPT: Mzana', 'Mzana' in script),
]

fails = []
passes = []
for label, ok in checks:
    if ok: passes.append(label)
    else: fails.append(label)

print(f'PASS: {len(passes)}/{len(checks)}')
print(f'FAIL: {len(fails)}')
if fails:
    print('\nFAILURES:')
    for f in fails:
        print(f'  FAIL: {f}')
else:
    print('\nALL PASS')
