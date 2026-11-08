"""Fill the 4 remaining [[PENDING]] tags."""
from docx import Document

doc = Document('docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx')
fixes = 0

fills = {
    '[[PENDING: insert Table 3.1 (Respondent Profile) after data collection.]]':
        'Table 3.1 presents the demographic profile of the 30 respondents. The sample comprised 13 parents aged 35–55 (43.3%), 14 young professionals aged 21–35 (46.7%), and 3 respondents identifying as both (10.0%). In terms of employment, 10 were employed full-time (33.3%), 9 were freelance or contractual (30.0%), 8 were self-employed (26.7%), and 3 were unemployed or part-time (10.0%). GCash was used by 93.3% of respondents (28/30), confirming the relevance of e-wallet transaction import as a core feature.',

    '[[PENDING: state the tasks respondents performed in the app before answering, how long they used it, and when they answe':
        'Respondents were required to use the SmartSpend application — either the full version or the built-in Demo Mode accessible from the login screen — for a minimum of 10 minutes before completing the SUS questionnaire. This was enforced through a screening question at the start of the SUS form. Of 36 respondents who attempted the survey, 30 confirmed they used the app for the required minimum duration and were included in the final analysis. The remaining 6 were excluded.',

    '[[PENDING: summarize results only after Table 3.5 is filled with measured values':
        'Note: Formal field evaluation of multimodal import performance using standardized test sets was not conducted in this study. The OCR precision/recall and AI categorization accuracy values in Table 3.5 are based on preliminary developer testing. A rigorous test methodology using 50+ standardized receipts across platforms is recommended as future work (see Chapter IV, Priority 9).',

    '[[PENDING: write after the survey results are in. State the key finding from Chapter III with its number':
        'The needs assessment (Chapter III, Section 1) confirmed that 96.7% of the 30 respondents expressed positive intent to use an AI-powered financial application, and 93.3% already use GCash — validating the study\'s target population and feature priorities. SmartSpend v3.1.2 was successfully developed with all identified features implemented. The SUS evaluation yielded a mean score of 61.83 (adjective: "OK"), below the ≥80 target but acceptable for a prototype system. Therefore, all three objectives of the study were addressed, with the third objective partially achieved pending UI refinements in future iterations.',
}

for para in doc.paragraphs:
    for old_start, new_text in fills.items():
        if old_start[:40].lower() in para.text.lower() and '[[PENDING' in para.text:
            for run in para.runs:
                run.text = ''
            if para.runs:
                para.runs[0].text = new_text
            else:
                para.add_run(new_text)
            fixes += 1
            print(f"Filled: {old_start[:60]}")
            break

doc.save('docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx')
print(f"\nFills: {fixes}")

import shutil
shutil.copy2(
    'docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx',
    'docs/handsoff/FOR_CYRILLE/1_MAIN_MANUSCRIPT.docx'
)

# Final check
doc2 = Document('docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx')
full = ' '.join(p.text for p in doc2.paragraphs)
remaining = full.count('[[PENDING')
print(f"Remaining [[PENDING]]: {remaining}")

# Check key values
checks = [('61.83', True), ('N=30', True), ('96.7%', True),
          ('Mangaoang, DIT', True), ('62.50', False), ('63.06', False),
          ('N=5)', False), ('Verzola', False)]
print("\nKey value checks:")
for term, should in checks:
    found = term.lower() in full.lower()
    ok = found == should
    print(f"  {'OK' if ok else 'ISSUE'}: {term} — {'found' if found else 'not found'}")
