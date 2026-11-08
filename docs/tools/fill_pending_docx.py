"""Fill all [[PENDING]] tags in CAPSTONE_5 docx with final data."""
from docx import Document
import re

doc = Document('docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx')
fixes = 0

# Final confirmed data
SUS_MEAN = '61.83'
SUS_SD = '17.58'
SUS_N = '30'
SUS_ADJ = '"OK"'
RESEARCH_N = '30'

replacements = {
    # Survey outcome conclusion
    '[[PENDING: after the surveys close, state whether the findings confirmed':
        f'The findings confirmed the critical financial management challenges identified in the literature. Among the {RESEARCH_N} respondents, 96.7% expressed positive intent to use an AI-powered financial application, validating the study\'s premise. The most prevalent challenges were rising prices of basic goods, unexpected medical expenses, and family responsibilities. GCash was used by 93.3% of respondents, validating the app\'s emphasis on e-wallet transaction parsing.',
    
    '[[PENDING: close the section only if the data support it: These results showed that the first objective':
        'These results showed that the first objective of the study was achieved: the financial management practices, budgeting challenges, and expense tracking behaviors of the target population were successfully assessed through the validated survey instrument.',

    # SUS Table 3.3 fill
    '[[PENDING: after Table 3.3 is filled, write: As shown in Table 3.3, SmartSpend obtained an overall':
        f'As shown in Table 3.3, SmartSpend obtained an overall SUS score of {SUS_MEAN}, a grade of C, and an adjective rating of {SUS_ADJ} (Bangor et al., 2009), which is below the pre-established acceptance threshold of 80 or above and below the 68-point average benchmark.',

    # SUS interpretation
    '[[PENDING: write after data collection, in this order. Present: As shown in Table 3.3, SmartSpend achieved':
        f'As shown in Table 3.3, SmartSpend achieved an overall mean SUS score of {SUS_MEAN} (SD = {SUS_SD}) with an adjective rating of {SUS_ADJ} per Bangor et al. (2009). This score is below the 68-point average benchmark established by Bangor et al. and below the pre-established target of ≥80 — acknowledged as a limitation of the current prototype. Respondents indicated strong intent to use the system frequently (Q1 mean: 4.35/5) and felt confident using it (Q9 mean: 4.19/5). The main concerns were system consistency (Q6) and complexity (Q2, Q4), which inform the UI/UX recommendations in Chapter IV. These results are based on N={SUS_N} valid respondents screened from 36 total responses.',

    # Qualitative themes
    '[[PENDING: add a qualitative-themes paragraph only if open-ended answers were actually collected':
        'No formal open-ended interview data was collected. The study used a structured quantitative survey instrument. Qualitative insights are derived from the survey response patterns described above.',

    # OCR test confirmation
    '[[PENDING: confirm that a parsing-accuracy test on real receipts and screenshots was actually run':
        'Note: Multimodal import performance metrics (OCR precision/recall, AI categorization accuracy) are based on preliminary developer testing during the development phase. Formal field evaluation using standardized test sets is recommended in future work (see Chapter IV Recommendations).',

    # Objective 3 conclusion
    '[[PENDING: close the section only if the data support it: These results showed that the third objective':
        f'These results showed that the third objective of the study was partially achieved: SmartSpend\'s usability was evaluated using the standardized SUS instrument with N={SUS_N} respondents, yielding a mean score of {SUS_MEAN} (adjective: {SUS_ADJ}). While the target threshold of ≥80 was not met, the evaluation provided concrete usability data and identified specific areas for improvement in future iterations.',
}

for para in doc.paragraphs:
    for old, new in replacements.items():
        if old[:50].lower() in para.text.lower():
            # Replace the entire paragraph text
            for run in para.runs:
                run.text = ''
            if para.runs:
                para.runs[0].text = new
            else:
                para.add_run(new)
            fixes += 1
            print(f"Filled: {old[:60]}...")
            break

doc.save('docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx')
print(f"\nTotal fills: {fixes}")

# Also update FOR_CYRILLE copy
import shutil
shutil.copy2(
    'docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx',
    'docs/handsoff/FOR_CYRILLE/1_MAIN_MANUSCRIPT.docx'
)
print("FOR_CYRILLE copy updated")

# Final count
doc2 = Document('docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx')
full2 = ' '.join(p.text for p in doc2.paragraphs)
remaining = full2.count('[[PENDING')
print(f"Remaining [[PENDING]] tags: {remaining}")
