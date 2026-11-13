"""
Apply Maam Ellen's corrections (Nov 12):
- Qualitative aspect = interviews (not surveys)
- Quantitative aspect = SUS questionnaire
"""
import shutil
from docx import Document

DOCX = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'
shutil.copy(DOCX, DOCX + '.nov12.backup')
doc = Document(DOCX)
fixes = []

for i, para in enumerate(doc.paragraphs):
    t = para.text

    # Fix 1: Para 246 — qualitative aspect = interviews
    # Maam Ellen: "qualitative is yng mga interview"
    if 'qualitative aspect' in t.lower() and 'survey' in t.lower():
        old = t
        new_t = (
            'To address the qualitative aspect of the study, interviews were used to gather '
            'respondents\' views regarding the features and functionality of the developed '
            'application. The qualitative data provided descriptive information that guided '
            'the design and improvement of the application.'
        )
        if para.runs:
            para.runs[0].text = new_t
            for r in para.runs[1:]: r.text = ''
        fixes.append(f'[{i}] FIXED qualitative sentence: surveys → interviews (Maam Ellen)')

    # Fix 2: Para 247 — quantitative aspect = SUS questionnaire
    # Maam Ellen: "quantitative is sa sus questionnaire"
    # Current text says "structured survey questionnaires" for quantitative — this is the
    # needs-assessment survey, which IS quantitative, so the existing text is actually correct.
    # Maam Ellen is clarifying that the SUS specifically = quantitative measurement.
    # The paragraph already describes structured survey questionnaires for quantitative data.
    # We just need to make sure the SUS is explicitly mentioned as the quantitative instrument.
    if ('quantitative aspect' in t.lower() and
            'System Usability Scale' not in t and 'SUS' not in t):
        # Add SUS reference to the quantitative paragraph
        old_end = 'These questionnaires were used to collect measurable data regarding financial habits, expense tracking practices, and common difficulties encountered by the respondents.'
        new_end = ('These questionnaires were used to collect measurable data regarding financial '
                   'habits, expense tracking practices, and common difficulties encountered by the '
                   'respondents. Additionally, the System Usability Scale (SUS) served as the '
                   'quantitative instrument for evaluating the usability of SmartSpend.')
        if old_end in t:
            new_t2 = t.replace(old_end, new_end, 1)
            if para.runs:
                para.runs[0].text = new_t2
                for r in para.runs[1:]: r.text = ''
            fixes.append(f'[{i}] ADDED SUS as quantitative instrument to quantitative paragraph')
        else:
            # Append the SUS sentence at end of para
            current = para.text.rstrip()
            new_t2 = current + (' Additionally, the System Usability Scale (SUS) served as '
                                 'the quantitative instrument for evaluating the usability of SmartSpend.')
            if para.runs:
                para.runs[0].text = new_t2
                for r in para.runs[1:]: r.text = ''
            fixes.append(f'[{i}] APPENDED SUS quantitative note to quantitative paragraph')

doc.save(DOCX)
print(f'{len(fixes)} fixes applied:')
for f in fixes:
    print(f'  {f}')

# Verify
doc2 = Document(DOCX)
print('\nVerification:')
for i, p in enumerate(doc2.paragraphs):
    t = p.text
    if 'qualitative aspect' in t.lower() or 'quantitative aspect' in t.lower():
        print(f'\n[{i}] {t[:300]}')
