"""
Build both validation certificates matching the sample photo format exactly.
Logo row: Lorma banner (left) | City seal (center) | CCSE seal (right)
"""
import subprocess, os, sys, base64, shutil, time
from PIL import Image

def img_to_b64(path):
    with open(path, 'rb') as f:
        data = f.read()
    ext = path.split('.')[-1].lower()
    mime = 'image/jpeg' if ext in ('jpg','jpeg') else 'image/png'
    return f"data:{mime};base64,{base64.b64encode(data).decode()}"

lorma  = img_to_b64('docs/tools/extracted_images/logos/lorma_banner_clean.png')
city   = img_to_b64('docs/tools/extracted_images/logos/seal_sanfernando.png')
ccse   = img_to_b64('docs/tools/extracted_images/logos/habss_ref_p3_img1.jpeg')

css = """
@page { size: Letter; margin: 20mm 25mm 20mm 25mm; }
* { box-sizing: border-box; }
body {
  font-family: 'Times New Roman', serif;
  font-size: 12pt;
  color: #000;
  line-height: 1.6;
}
/* ── Logo row ── */
.logo-row {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 16pt;
  margin-bottom: 8pt;
}
.logo-lorma { height: 44pt; width: auto; }
.logo-city  { height: 52pt; width: auto; }
.logo-ccse  { height: 52pt; width: auto; }

/* ── Divider ── */
hr {
  border: none;
  border-top: 1.5px solid #000;
  margin: 6pt 0 14pt 0;
}

/* ── Title ── */
.title {
  text-align: center;
  font-size: 14pt;
  font-weight: bold;
  letter-spacing: 0.5px;
  margin: 0 0 16pt 0;
  text-transform: uppercase;
}

/* ── Body paragraphs ── */
p {
  text-align: justify;
  margin: 0 0 11pt 0;
  text-indent: 36pt;
  font-size: 12pt;
}
.no-indent { text-indent: 0; }

/* ── Signature area ── */
.sig-area { margin-top: 30pt; }
.validated-label {
  font-size: 12pt;
  margin-bottom: 28pt;
}
.sig-line {
  border-top: 1.5px solid #000;
  width: 240pt;
  margin-bottom: 4pt;
}
.sig-name {
  font-weight: bold;
  font-size: 12pt;
  text-transform: uppercase;
  margin: 0;
}
.sig-detail {
  font-size: 12pt;
  margin: 0;
}
"""

def build(out_final, para1, para2, para3):
    logo_html = f"""
  <img src="{lorma}" class="logo-lorma" alt="Lorma Colleges">
  <img src="{city}"  class="logo-city"  alt="City of San Fernando">
  <img src="{ccse}"  class="logo-ccse"  alt="CCSE">"""

    html = f"""<!DOCTYPE html>
<html><head><meta charset="utf-8"><style>{css}</style></head>
<body>
<div class="logo-row">{logo_html}
</div>
<hr>
<div class="title">Certificate of Validation</div>
<p>{para1}</p>
<p>{para2}</p>
<p>{para3}</p>
<p class="no-indent">Issued this ______ day of __________________, 2026.</p>
<div class="sig-area">
  <p class="no-indent validated-label">Validated by:</p>
  <div class="sig-line"></div>
  <p class="sig-name">______________________________________</p>
  <p class="sig-detail">______________________________________</p>
  <p class="sig-detail">______________________________________</p>
</div>
</body></html>"""

    # Use unique short temp paths to avoid Edge cache
    ts = int(time.time() * 1000)
    tmp = os.path.abspath(f'docs/tools/c_{ts}.html')
    out_tmp = os.path.abspath(f'docs/tools/c_{ts}.pdf')

    with open(tmp, 'w', encoding='utf-8') as f:
        f.write(html)

    edge = r'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
    if not os.path.exists(edge):
        edge = r'C:\Program Files\Microsoft\Edge\Application\msedge.exe'

    subprocess.run([
        edge, '--headless', '--disable-gpu', '--no-sandbox',
        '--disk-cache-dir=nul',
        f'--print-to-pdf={out_tmp}',
        '--print-to-pdf-no-header',
        '--no-pdf-header-footer',
        f'file:///{tmp.replace(chr(92), "/")}',
    ], capture_output=True, timeout=30)

    time.sleep(1)
    try: os.remove(tmp)
    except: pass

    if os.path.exists(out_tmp) and os.path.getsize(out_tmp) > 5000:
        shutil.copy2(out_tmp, out_final)
        os.remove(out_tmp)
        from pypdf import PdfReader
        r = PdfReader(out_final)
        print(f"  ✅ {os.path.basename(out_final)}: {len(r.pages)}p, {os.path.getsize(out_final)//1024}KB")
    else:
        print(f"  ❌ Failed: {out_final}")


# ── CERT A-1: Survey Questionnaire ───────────────────────────────────────────
print("Building A-1 — Survey Questionnaire...")
build(
    out_final=os.path.abspath('docs/handsoff/FOR_MAAM_ELLEN/6_CERT_A1_Survey_Questionnaire_Validation.pdf'),
    para1="""This is to certify that the survey questionnaire for the study entitled
<em>"SmartSpend: An AI-Assisted Mobile Financial Tracking and Advisory Application for
Personal Financial Management,"</em> prepared by <strong>Directo, Brix A., Rubis,
Cyrille John M., and Madayag, Djaunathan Albert S.</strong>, BSIT students of Lorma
Colleges, with the guidance of <strong>Dr. Ellen F. Mangaoang, DIT</strong>, research
adviser, has been carefully reviewed, evaluated, and validated by the undersigned.""",
    para2="""The instrument was assessed based on its relevance, clarity, accuracy,
appropriateness, and alignment with the objectives of the study. The validator ensured
that the survey items were suitable for measuring the financial management practices,
budgeting challenges, and expense tracking behaviors of the target respondents —
parents aged 35 to 55 and young professionals aged 21 to 35 in San Fernando City,
La Union.""",
    para3="""After thorough evaluation, the survey questionnaire is hereby certified as valid
and appropriate for use in the conduct of the study, subject to the revisions and
recommendations provided, if any."""
)

# ── CERT A-3: FHS Formula ────────────────────────────────────────────────────
print("Building A-3 — FHS Formula...")
build(
    out_final=os.path.abspath('docs/handsoff/FOR_MAAM_ELLEN/7_CERT_A3_FHS_Formula_Validation.pdf'),
    para1="""This is to certify that the Financial Health Score (FHS) formula and its
supporting academic literature for the study entitled <em>"SmartSpend: An AI-Assisted
Mobile Financial Tracking and Advisory Application for Personal Financial Management,"</em>
prepared by <strong>Directo, Brix A., Rubis, Cyrille John M., and Madayag, Djaunathan
Albert S.</strong>, BSIT students of Lorma Colleges, with the guidance of
<strong>Dr. Ellen F. Mangaoang, DIT</strong>, research adviser, has been carefully
reviewed, evaluated, and validated by the undersigned.""",
    para2="""The FHS formula was assessed based on its relevance, academic grounding,
accuracy, appropriateness, and alignment with established financial health measurement
frameworks. The validator ensured that the formula components — Savings Rate, Overspend
Control, Budget Adherence, and Logging Consistency — and their supporting literature
are suitable for use as a prototype financial health indicator for the study's target
population in San Fernando City, La Union.""",
    para3="""After thorough evaluation, the Financial Health Score formula and its academic
literature basis are hereby certified as valid and appropriate for use in the conduct
of the study, subject to the revisions and recommendations provided, if any."""
)

print("\nDone.")
