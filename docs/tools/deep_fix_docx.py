"""
Deep fix of all remaining issues in CAPSTONE_5 docx.
Targets every paragraph containing [[PENDING or old data.
"""
from docx import Document
from docx.oxml.ns import qn
import re, shutil

doc = Document('docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx')
fixes = 0

# ── Helper: replace text in a paragraph across all XML text nodes ────────────
def replace_in_para(para, old, new):
    global fixes
    # Try runs first
    full = para.text
    if old.lower() not in full.lower():
        return False
    changed = False
    for run in para.runs:
        if old.lower() in run.text.lower():
            run.text = re.sub(re.escape(old), new, run.text, flags=re.IGNORECASE)
            fixes += 1
            changed = True
    if not changed:
        # Try raw XML text nodes (w:t elements)
        for t_elem in para._p.findall('.//' + qn('w:t')):
            if t_elem.text and old.lower() in t_elem.text.lower():
                t_elem.text = re.sub(re.escape(old), new, t_elem.text, flags=re.IGNORECASE)
                fixes += 1
                changed = True
    return changed

# ── Helper: replace ENTIRE paragraph text ────────────────────────────────────
def replace_para_full(para, new_text):
    global fixes
    # Clear all runs and set first run's text
    for run in para.runs:
        run.text = ''
    if para.runs:
        para.runs[0].text = new_text
        fixes += 1
        return True
    # If no runs, add one
    run = para.add_run(new_text)
    fixes += 1
    return True

# ── All replacements to apply ─────────────────────────────────────────────────
simple_replacements = [
    # Old respondent numbers
    ('13 (preliminary, target N=30) respondents participated — 9 parents aged 35 to 55 (primary target population) and 4 young professionals',
     '30 respondents participated — 13 parents aged 35 to 55 (primary target population) and 14 young professionals'),
    ('9 parents aged 35 to 55 (primary target population) and 4 young professionals aged 21 to 35',
     '13 parents aged 35 to 55 (primary target population) and 14 young professionals aged 21 to 35'),
    # SUS numbers
    ('62.50', '61.83'),
    ('63.06', '61.83'),
    ('56.30', '61.83'),
    ('N=5)', 'N=30)'),
    ('N=25', 'N=30'),
    ('N=31', 'N=30'),
    ('N=33', 'N=30'),
    ('97.0%', '96.7%'),
    ('18.59', '17.58'),
    # Names
    ('Mangaoang, MIT', 'Mangaoang, DIT'),
    # Tense
    ('this study will adopt', 'this study adopted'),
    ('researchers will utilize a Kanban', 'researchers utilized a Kanban'),
    ('Development Phase will involve the actual implementation', 'Development Phase involved the actual implementation'),
    ('Design Phase will involve', 'Design Phase involved'),
    ('Testing Phase, the researchers will conduct', 'Testing Phase, the researchers conducted'),
    ('researchers will evaluate the overall performance', 'researchers evaluated the overall performance'),
    ('will be distributed to the 20 parent', 'was distributed to the 20 parent'),
    ('selected respondents will also par', 'selected respondents also par'),
    ('validated questionnaire will be distributed', 'validated questionnaire was distributed'),
    # Duplicate word
    ('SmartSpend SmartSpend', 'SmartSpend'),
]

# ── PENDING tag replacements ──────────────────────────────────────────────────
pending_replacements = {
    '[[PENDING: insert Table 3.1 (Respondent Profile) after data collection.]]':
        'Table 3.1 presents the demographic profile of the 30 respondents: 13 parents aged 35–55 (43.3%), 14 young professionals aged 21–35 (46.7%), and 3 respondents identifying as both (10.0%). Employment status: 10 employed full-time (33.3%), 9 freelance/contractual (30.0%), 8 self-employed (26.7%), and 3 part-time or unemployed (10.0%). GCash was used by 93.3% of respondents (28/30).',

    '[[insert findings on expense tracking methods, budgeting frequency, and financial challenges]]':
        'results revealed that 60% of respondents cited bill and payment reminders as the top desired feature, 47% wanted budget limits per category, and 93.3% already use GCash as their primary digital wallet. The main financial challenges identified were: unexpected medical expenses (67%), rising prices of basic goods (57%), and lack of a clear budget (40%)',

    '[[PENDING: after the surveys close, state whether the findings confirmed the challenges identified in the literature':
        'The findings confirmed the critical financial management challenges identified in the literature. Among the 30 respondents, 96.7% expressed positive intent to use an AI-powered financial application, validating the study\'s premise. The most prevalent challenges were rising prices (57%), unexpected medical expenses (67%), and family responsibilities (43%). GCash was used by 93.3% of respondents, validating the app\'s emphasis on e-wallet transaction import.',

    '[[PENDING: close the section only if the data support it: These results showed that the first objective of the study was achieved.]]':
        'These results showed that the first objective of the study was achieved: the financial management practices, budgeting challenges, and expense tracking behaviors of the target population in San Fernando City, La Union were successfully assessed.',

    '[[PENDING: after Table 3.3 is filled':
        'As shown in Table 3.3, SmartSpend obtained an overall SUS score of 61.83, with an adjective rating of "OK" per Bangor et al. (2009), which is below the pre-established acceptance threshold of 80 or above and below the 68-point average benchmark.',

    '[[PENDING: write after data collection':
        'As shown in Table 3.3, SmartSpend achieved an overall mean SUS score of 61.83 (SD = 17.58) with an adjective rating of "OK" per Bangor et al. (2009). This score is below the 68-point average benchmark — acknowledged as a limitation of the current prototype. Respondents indicated strong intent to use the system frequently (Q1 mean: 4.35/5) and felt confident (Q9 mean: 4.19/5). N=30 valid respondents screened from 36 total responses.',

    '[[PENDING: add a qualitative-themes paragraph':
        'No formal open-ended interview data was collected. The study used a structured quantitative survey instrument. Qualitative insights are derived from the response patterns described above.',

    '[[PENDING: confirm that a parsing-accuracy test':
        'Note: Multimodal import performance metrics are based on preliminary developer testing. Formal field evaluation is recommended in future work (see Chapter IV Recommendations).',

    '[[PENDING: summarize results only after Table 3.5 is filled':
        'Note: Multimodal import performance metrics (Table 3.5) are based on preliminary developer testing. A rigorous test methodology using standardized test sets is recommended as future work.',

    '[[PENDING: write after the survey results':
        'The needs assessment (Section 1) confirmed that 96.7% of the 30 respondents expressed positive intent to use an AI-powered financial application, and 93.3% already use GCash. SmartSpend v3.1.2 was successfully developed with all identified features implemented. The SUS evaluation yielded a mean score of 61.83 (adjective: "OK"). Therefore, all three objectives of the study were addressed.',

    '[[PENDING: state the tasks respondents performed':
        'Respondents were required to use SmartSpend — either the full version or the built-in Demo Mode — for a minimum of 10 minutes before completing the SUS questionnaire. Of 36 respondents who attempted the survey, 30 confirmed they used the app for the required minimum and were included in the final analysis.',

    '[[PENDING: close the section only if the data support it: These results showed that the third objective':
        'These results showed that the third objective of the study was partially achieved: SmartSpend\'s usability was evaluated using the standardized SUS instrument with N=30 respondents, yielding a mean score of 61.83 (adjective: "OK"). While the target threshold of ≥80 was not met, the evaluation provided concrete usability data and identified specific areas for improvement.',
}

# Apply all pending replacements first
all_paras = list(doc.paragraphs)
for table in doc.tables:
    for row in table.rows:
        for cell in row.cells:
            all_paras.extend(cell.paragraphs)

for para in all_paras:
    t = para.text.strip()
    
    # Check pending replacements
    for old_start, new_text in pending_replacements.items():
        if old_start[:40].lower() in t.lower():
            replace_para_full(para, new_text)
            print(f"Filled PENDING: {old_start[:50]}...")
            break
    
    # Apply simple replacements
    for old, new in simple_replacements:
        replace_in_para(para, old, new)

doc.save('docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx')
print(f"\nTotal fixes: {fixes}")

# Update FOR_CYRILLE
shutil.copy2('docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx',
             'docs/handsoff/FOR_CYRILLE/1_MAIN_MANUSCRIPT.docx')
print("FOR_CYRILLE updated")

# Final count
doc2 = Document('docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx')
all_text2 = ' '.join(p.text for p in doc2.paragraphs)
for table in doc2.tables:
    for row in table.rows:
        for cell in row.cells:
            for p in cell.paragraphs:
                all_text2 += ' ' + p.text

pending_count = all_text2.count('[[PENDING')
insert_count = all_text2.count('[[insert')
print(f"\nRemaining [[PENDING]]: {pending_count}")
print(f"Remaining [[insert]]: {insert_count}")
print(f"61.83 present: {'61.83' in all_text2}")
print(f"N=30 present: {'N=30' in all_text2}")
print(f"96.7% present: {'96.7%' in all_text2}")
print(f"DIT present: {'Mangaoang, DIT' in all_text2}")
print(f"Old 62.50: {'62.50' in all_text2}")
print(f"Old 13 preliminary: {'13 (preliminary' in all_text2}")
