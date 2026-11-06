"""Build CERT A-1: Survey Questionnaire Validation"""
import subprocess, os, sys, base64

def img_to_b64(path):
    with open(path, 'rb') as f:
        data = f.read()
    ext = path.split('.')[-1].lower()
    mime = 'image/jpeg' if ext in ('jpg','jpeg') else 'image/png'
    return f"data:{mime};base64,{base64.b64encode(data).decode()}"

lorma = img_to_b64('docs/tools/extracted_images/logos/lorma_clean.png')
city  = img_to_b64('docs/tools/extracted_images/logos/seal_sanfernando.png')
ccse  = img_to_b64('docs/tools/extracted_images/logos/habss_ref_p3_img1.jpeg')

css = """
@page { size: Letter; margin: 22mm 25mm 20mm 25mm; }
body { font-family: 'Times New Roman', serif; font-size: 12pt; color: #000; line-height: 1.65; }
.logo-row { display: flex; justify-content: center; align-items: center; gap: 24pt; margin-bottom: 10pt; }
.logo-lorma { height: 56pt; width: auto; }
.logo-city  { height: 56pt; width: auto; }
.logo-ccse  { height: 56pt; width: auto; }
hr { border: none; border-top: 1.5px solid #000; margin: 8pt 0 14pt 0; }
.title { text-align: center; font-size: 14pt; font-weight: bold; letter-spacing: 0.5px; margin: 0 0 14pt 0; text-transform: uppercase; }
p { text-align: justify; margin: 0 0 10pt 0; text-indent: 36pt; font-size: 12pt; }
.issued { text-indent: 0; margin-top: 6pt; }
.validated { text-indent: 0; margin-top: 32pt; }
.sig-line { border-top: 1px solid #000; width: 220pt; margin: 36pt 0 3pt 0; }
.sig-name { font-weight: bold; font-size: 12pt; }
.sig-detail { font-size: 12pt; }
"""

html = f"""<!DOCTYPE html><html><head><meta charset="utf-8"><style>{css}</style></head><body>
<div class="logo-row">
  <img src="{lorma}" class="logo-lorma">
  <img src="{city}"  class="logo-city">
  <img src="{ccse}"  class="logo-ccse">
</div>
<hr>
<div class="title">Certificate of Validation</div>
<p>This is to certify that the survey questionnaire for the study entitled
<em>"SmartSpend: An AI-Assisted Mobile Financial Tracking and Advisory Application for
Personal Financial Management,"</em> prepared by <strong>Directo, Brix A., Rubis,
Cyrille John M., and Madayag, Djaunathan Albert S.</strong>, BSIT students of Lorma
Colleges, with the guidance of <strong>Dr. Ellen F. Mangaoang, DIT</strong>, research
adviser, has been carefully reviewed, evaluated, and validated by the undersigned.</p>
<p>The instrument was assessed based on its relevance, clarity, accuracy,
appropriateness, and alignment with the objectives of the study. The validator ensured
that the survey items were suitable for measuring the financial management practices,
budgeting challenges, and expense tracking behaviors of the target respondents —
parents aged 35 to 55 and young professionals aged 21 to 35 in San Fernando City,
La Union.</p>
<p>After thorough evaluation, the survey questionnaire is hereby certified as valid
and appropriate for use in the conduct of the study, subject to the revisions and
recommendations provided, if any.</p>
<p class="issued">Issued this ______ day of __________________, 2026.</p>
<p class="validated">Validated by:</p>
<div class="sig-line"></div>
<div class="sig-name">______________________________________</div>
<div class="sig-detail">______________________________________</div>
<div class="sig-detail">______________________________________</div>
</body></html>"""

import time
tmp = os.path.abspath(f'docs/tools/a1_{int(time.time())}.html')
out = os.path.abspath('docs/handsoff/FOR_MAAM_ELLEN/6_CERT_A1_Survey_Questionnaire_Validation.pdf')
out_tmp = os.path.abspath('docs/tools/cert_a1_out.pdf')

with open(tmp, 'w', encoding='utf-8') as f:
    f.write(html)

edge = r'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
if not os.path.exists(edge):
    edge = r'C:\Program Files\Microsoft\Edge\Application\msedge.exe'

result = subprocess.run([edge, '--headless', '--disable-gpu', '--no-sandbox',
    '--disk-cache-dir=nul', '--disable-application-cache',
    f'--print-to-pdf={out_tmp}', '--print-to-pdf-no-header', '--no-pdf-header-footer',
    f'file:///{tmp.replace(chr(92), "/")}?t=a1'],
    capture_output=True, timeout=30)
print(f"Edge exit: {result.returncode}")
import shutil, time
time.sleep(1)
if os.path.exists(out_tmp) and os.path.getsize(out_tmp) > 5000:
    shutil.copy2(out_tmp, out)
    os.remove(out_tmp)
    print(f"Copied to: {out}")

os.remove(tmp)

from pypdf import PdfReader
r = PdfReader(out)
t = r.pages[0].extract_text()
print(f"A-1 cert: {len(r.pages)}p {os.path.getsize(out)//1024}KB")
print(f"First line: {t.split(chr(10))[0].strip()}")
has_survey = 'survey questionnaire' in t.lower()
has_fhs = 'financial health score (fhs) formula' in t.lower()
print(f"Has 'survey questionnaire': {has_survey}")
print(f"Has FHS formula text (wrong): {has_fhs}")
