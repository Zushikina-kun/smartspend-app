import subprocess, os, base64, shutil, time

def img_to_b64(path):
    with open(path, 'rb') as f: data = f.read()
    ext = path.split('.')[-1].lower()
    mime = 'image/jpeg' if ext in ('jpg','jpeg') else 'image/png'
    return f"data:{mime};base64,{base64.b64encode(data).decode()}"

lorma = img_to_b64('docs/tools/extracted_images/logos/lorma_cropped.png')
city  = img_to_b64('docs/tools/extracted_images/logos/seal_sanfernando.png')
ccse  = img_to_b64('docs/tools/extracted_images/logos/habss_ref_p3_img1.jpeg')

css = """
@page { size: Letter; margin: 20mm 25mm 20mm 25mm; }
body { font-family: 'Times New Roman', serif; font-size: 12pt; color: #000; line-height: 1.6; }
.logo-row { display: flex; justify-content: center; align-items: center; gap: 20pt; margin-bottom: 8pt; }
.logo-lorma { height: 56pt; width: auto; }
.logo-city  { height: 60pt; width: auto; }
.logo-ccse  { height: 60pt; width: auto; }
hr { border: none; border-top: 1.5px solid #000; margin: 6pt 0 14pt 0; }
.title { text-align: center; font-size: 14pt; font-weight: bold; letter-spacing: 0.5px; margin: 0 0 16pt 0; text-transform: uppercase; }
p { text-align: justify; margin: 0 0 11pt 0; text-indent: 36pt; font-size: 12pt; }
.no-indent { text-indent: 0; }
.sig-area { margin-top: 28pt; }
.validated-label { font-size: 12pt; margin-bottom: 32pt; text-indent: 0; }
.sig-line { border-top: 1.5px solid #000; width: 260pt; margin-bottom: 4pt; }
.sig-name { font-weight: bold; font-size: 12pt; text-transform: uppercase; margin: 0; text-indent: 0; }
.sig-detail { font-size: 12pt; margin: 0; text-indent: 0; }
"""

html = f"""<!DOCTYPE html>
<html><head><meta charset="utf-8"><style>{css}</style></head>
<body>
<div class="logo-row">
  <img src="{lorma}" class="logo-lorma">
  <img src="{city}"  class="logo-city">
  <img src="{ccse}"  class="logo-ccse">
</div>
<hr>
<div class="title">Certificate of Validation</div>
<p>This is to certify that the survey questionnaire for the study entitled
<em>&ldquo;SmartSpend: An AI-Assisted Mobile Financial Tracking and Advisory Application for
Personal Financial Management,&rdquo;</em> prepared by <strong>Directo, Brix A., Rubis,
Cyrille John M., and Madayag, Djaunathan Albert S.</strong>, BSIT students of Lorma
Colleges, with the guidance of <strong>Dr. Ellen F. Mangaoang, DIT</strong>, research
adviser, has been carefully reviewed, evaluated, and validated by the undersigned.</p>
<p>The instrument was assessed based on its relevance, clarity, accuracy,
appropriateness, and alignment with the objectives of the study. The validator ensured
that the survey items were suitable for measuring the financial management practices,
budgeting challenges, and expense tracking behaviors of the target respondents &mdash;
parents aged 35 to 55 and young professionals aged 21 to 35 in San Fernando City,
La Union.</p>
<p>After thorough evaluation, the survey questionnaire is hereby certified as valid and
appropriate for use in the conduct of the study, subject to the revisions and
recommendations provided, if any.</p>
<p class="no-indent">Issued this ______ day of __________________, 2026.</p>
<div class="sig-area">
  <p class="no-indent validated-label">Validated by:</p>
  <div class="sig-line"></div>
  <p class="sig-name">______________________________________</p>
  <p class="sig-detail">______________________________________</p>
  <p class="sig-detail">______________________________________</p>
</div>
</body></html>"""

ts   = int(time.time()*1000)
tmp  = os.path.join(os.environ.get('TEMP', 'C:/Users/brixa/AppData/Local/Temp'), f'a1_{ts}.html')
tmp2 = os.path.join(os.environ.get('TEMP', 'C:/Users/brixa/AppData/Local/Temp'), f'a1_{ts}.pdf')
out  = os.path.abspath('docs/handsoff/FOR_MAAM_ELLEN/6_CERT_A1_Survey_Questionnaire_Validation.pdf')

with open(tmp, 'w', encoding='utf-8') as f:
    f.write(html)

edge = r'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
if not os.path.exists(edge):
    edge = r'C:\Program Files\Microsoft\Edge\Application\msedge.exe'

subprocess.run([edge,'--headless','--disable-gpu','--no-sandbox','--disk-cache-dir=nul',
    f'--print-to-pdf={tmp2}','--print-to-pdf-no-header','--no-pdf-header-footer',
    f'file:///{tmp.replace(chr(92),"/")}'],
    capture_output=True, timeout=30)

time.sleep(1)
try: os.remove(tmp)
except: pass

if os.path.exists(tmp2) and os.path.getsize(tmp2) > 5000:
    shutil.copy2(tmp2, out)
    os.remove(tmp2)
    from pypdf import PdfReader
    r = PdfReader(out)
    t = r.pages[0].extract_text()
    print(f"PDF ✅ {os.path.getsize(out)//1024}KB")
    print(f"Has survey: {'survey questionnaire' in t.lower()}")
    print(f"Has FHS (wrong): {'financial health score (fhs) formula' in t.lower()}")
else:
    print("PDF ❌ failed")
