"""
Build Certificate of Validation PDFs following the Lorma CCSE sample format.
Three logos at top: Lorma banner | City of San Fernando seal | CCSE seal
Portrait Letter, 1 page each, no watermarks.
"""
import subprocess, os, sys, base64

def img_to_b64(path):
    with open(path, 'rb') as f:
        data = f.read()
    ext = path.split('.')[-1].lower()
    mime = 'image/jpeg' if ext in ('jpg','jpeg') else 'image/png'
    return f"data:{mime};base64,{base64.b64encode(data).decode()}"

# Logos
lorma_banner  = img_to_b64('docs/tools/extracted_images/logos/habss_ref_p3_img0.png')
ccse_seal     = img_to_b64('docs/tools/extracted_images/logos/habss_ref_p3_img1.jpeg')

city_seal_path = 'docs/tools/extracted_images/logos/seal_sanfernando.png'
has_city_seal  = os.path.exists(city_seal_path) and os.path.getsize(city_seal_path) > 5000
city_seal      = img_to_b64(city_seal_path) if has_city_seal else None
print(f"City seal: {'✅ found' if has_city_seal else '⚠️ not found — using 2 logos'}")

css = """
@page { size: Letter; margin: 22mm 25mm 20mm 25mm; }
body {
  font-family: 'Times New Roman', serif;
  font-size: 12pt;
  color: #000;
  line-height: 1.65;
}
.logo-row {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 24pt;
  margin-bottom: 10pt;
}
.logo-lorma  { height: 48pt; width: auto; }
.logo-city   { height: 56pt; width: auto; }
.logo-ccse   { height: 56pt; width: auto; }
.divider {
  border: none;
  border-top: 1.5px solid #000;
  margin: 8pt 0 14pt 0;
}
.title {
  text-align: center;
  font-size: 14pt;
  font-weight: bold;
  letter-spacing: 0.5px;
  margin: 0 0 14pt 0;
  text-transform: uppercase;
}
p {
  text-align: justify;
  margin: 0 0 10pt 0;
  text-indent: 36pt;
  font-size: 12pt;
}
.issued {
  text-indent: 0;
  margin-top: 6pt;
  margin-bottom: 0;
}
.validated-label {
  text-indent: 0;
  margin-top: 32pt;
  margin-bottom: 0;
  font-size: 12pt;
}
.sig-section { margin-top: 32pt; }
.sig-line {
  border-top: 1px solid #000;
  width: 220pt;
  margin: 2pt 0 3pt 0;
}
.sig-name { font-weight: bold; font-size: 12pt; text-transform: uppercase; }
.sig-detail { font-size: 12pt; }
"""

def build(output_path, para1, para2, para3):
    if has_city_seal:
        logo_html = f"""
  <img src="{lorma_banner}" class="logo-lorma" alt="Lorma">
  <img src="{city_seal}"   class="logo-city"  alt="City Seal">
  <img src="{ccse_seal}"   class="logo-ccse"  alt="CCSE">"""
    else:
        logo_html = f"""
  <img src="{lorma_banner}" class="logo-lorma" alt="Lorma">
  <img src="{ccse_seal}"    class="logo-ccse"  alt="CCSE">"""

    html = f"""<!DOCTYPE html>
<html><head><meta charset="utf-8"><style>{css}</style></head>
<body>
<div class="logo-row">{logo_html}
</div>
<hr class="divider">
<div class="title">Certificate of Validation</div>
<p>{para1}</p>
<p>{para2}</p>
<p>{para3}</p>
<p class="issued">Issued this ______ day of __________________, 2026.</p>
<p class="validated-label">Validated by:</p>
<div class="sig-section">
  <div class="sig-line"></div>
  <div class="sig-name">______________________________________</div>
  <div class="sig-detail">______________________________________</div>
  <div class="sig-detail">______________________________________</div>
</div>
</body></html>"""

    tmp = os.path.abspath(f'docs/tools/cert_temp_{os.path.basename(output_path)}.html')
    with open(tmp, 'w', encoding='utf-8') as f:
        f.write(html)

    edge_paths = [
        r'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe',
        r'C:\Program Files\Microsoft\Edge\Application\msedge.exe',
    ]
    edge = next((p for p in edge_paths if os.path.exists(p)), None)
    if not edge:
        print("Edge not found"); sys.exit(1)

    subprocess.run([
        edge, '--headless', '--disable-gpu', '--no-sandbox',
        f'--print-to-pdf={output_path}',
        '--print-to-pdf-no-header',
        '--no-pdf-header-footer',
        f'file:///{tmp.replace(chr(92), "/")}'
    ], capture_output=True, timeout=30)

    try: os.remove(tmp)
    except: pass

    if os.path.exists(output_path) and os.path.getsize(output_path) > 5000:
        from pypdf import PdfReader
        r = PdfReader(output_path)
        print(f"  ✅ {os.path.basename(output_path)}: {len(r.pages)}p, {os.path.getsize(output_path)//1024}KB")
    else:
        print(f"  ❌ Failed: {output_path}")


# ── CERT A-1: Survey Questionnaire ───────────────────────────────────────────
print("\nBuilding A-1 — Survey Questionnaire Validation...")
build(
    output_path=os.path.abspath('docs/handsoff/FOR_MAAM_ELLEN/6_CERT_A1_Survey_Questionnaire_Validation.pdf'),
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
print("\nBuilding A-3 — FHS Formula Validation...")
build(
    output_path=os.path.abspath('docs/handsoff/FOR_MAAM_ELLEN/7_CERT_A3_FHS_Formula_Validation.pdf'),
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
