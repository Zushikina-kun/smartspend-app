import shutil
from docx import Document

DOCX = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'
shutil.copy(DOCX, DOCX + '.susfig.bak')
doc = Document(DOCX)

# Para 340 — replace the long SUS computation description
NEW_DESC = (
    "Figure 13 shows a sample SUS computation for one respondent, used to "
    "illustrate how the SUS formula is applied. This particular respondent "
    "scored 75.0, which corresponds to the adjective rating of \"Good.\" "
    "This is a single example only. The overall mean SUS score of 61.83 "
    "shown in Table 7 is the average of all 30 valid respondents — each with "
    "their own individual score — and is different from this sample."
)

p340 = doc.paragraphs[340]
if p340.runs:
    p340.runs[0].text = NEW_DESC
    for r in p340.runs[1:]: r.text = ''
    print(f'Updated para 340')
    print(f'New text: {NEW_DESC[:120]}...')

doc.save(DOCX)
print('Saved.')

# Verify
doc2 = Document(DOCX)
print(f'\nPara 340: {doc2.paragraphs[340].text[:200]}')
