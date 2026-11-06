from pypdf import PdfReader
import os, datetime

files = [
    'docs/handsoff/FOR_MAAM_ELLEN/6_CERT_A1_Survey_Questionnaire_Validation.pdf',
    'docs/handsoff/FOR_MAAM_ELLEN/7_CERT_A3_FHS_Formula_Validation.pdf',
]
for f in files:
    mtime = datetime.datetime.fromtimestamp(os.path.getmtime(f)).strftime("%H:%M:%S")
    size = os.path.getsize(f) // 1024
    r = PdfReader(f)
    t = r.pages[0].extract_text() or ''
    lines = [l.strip() for l in t.split('\n') if l.strip()][:10]
    name = f.split('/')[-1]
    print(f'{name} | {size}KB | {mtime}')
    for line in lines:
        print(f'  {line}')
    print()
