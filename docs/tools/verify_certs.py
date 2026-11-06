from pypdf import PdfReader
files = [
    'docs/handsoff/FOR_MAAM_ELLEN/6_CERT_A1_Survey_Questionnaire_Validation.pdf',
    'docs/handsoff/FOR_MAAM_ELLEN/7_CERT_A3_FHS_Formula_Validation.pdf',
]
for f in files:
    r = PdfReader(f)
    t = r.pages[0].extract_text() or ''
    name = f.split('/')[-1]
    print(f'=== {name} ===')
    print(t[:500])
    print()
