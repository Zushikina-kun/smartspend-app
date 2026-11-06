"""
Build Content Validation Certificates for SmartSpend.
Format follows the actual LucidFrame/Lorma CCSE format from Template_LucidFrame_SmartSpend.pdf:
- Portrait A4
- Simple one-page
- School header
- "CONTENT VALIDATION CERTIFICATE" title
- One statement paragraph
- Fields: Educational Background, Occupation, Years of Experience
- Signature, Name, Date
"""
import subprocess, os, sys

css = """
@page { size: A4; margin: 25mm 25mm 25mm 30mm; }
body {
  font-family: 'Times New Roman', serif;
  font-size: 12pt;
  color: #000;
  line-height: 1.6;
}
.header {
  text-align: center;
  margin-bottom: 6pt;
}
.school-name {
  font-size: 13pt;
  font-weight: bold;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}
.college-line {
  font-size: 11.5pt;
}
.address-line {
  font-size: 10.5pt;
}
.divider {
  border: none;
  border-top: 1.5px solid #000;
  margin: 10pt 0 18pt 0;
}
.cert-title {
  text-align: center;
  font-size: 14pt;
  font-weight: bold;
  text-transform: uppercase;
  letter-spacing: 1px;
  margin: 0 0 20pt 0;
}
.body-text {
  text-align: justify;
  margin-bottom: 20pt;
  font-size: 12pt;
  text-indent: 36pt;
}
.field-block {
  margin: 10pt 0;
  font-size: 12pt;
}
.field-row {
  display: flex;
  align-items: flex-end;
  margin: 12pt 0;
  gap: 6pt;
}
.field-label {
  white-space: nowrap;
  font-size: 12pt;
}
.field-line {
  flex: 1;
  border-bottom: 1px solid #000;
  min-height: 14pt;
}
.field-note {
  font-size: 10pt;
  font-style: italic;
  color: #333;
  margin: 2pt 0 10pt 16pt;
}
.sig-section {
  margin-top: 30pt;
}
.sig-row {
  margin: 14pt 0;
  display: flex;
  align-items: flex-end;
  gap: 6pt;
}
.sig-label {
  white-space: nowrap;
  font-size: 12pt;
}
.sig-line {
  flex: 1;
  border-bottom: 1px solid #000;
  min-height: 14pt;
}
"""

def make_cert(title_sub, statement, fields_html, output_path, cert_title="CONTENT VALIDATION CERTIFICATE"):
    html = f"""<!DOCTYPE html>
<html><head><meta charset="utf-8"><style>{css}</style></head>
<body>

<div class="header">
  <div class="school-name">Lorma Colleges</div>
  <div class="college-line">College of Computer Studies and Engineering</div>
  <div class="address-line">San Juan Campus, City of San Fernando, La Union, Philippines</div>
</div>

<hr class="divider">

<div class="cert-title">{cert_title}</div>

<p class="body-text">{statement}</p>

{fields_html}

<div class="sig-section">
  <div class="sig-row">
    <span class="sig-label">Signature :</span>
    <div class="sig-line"></div>
  </div>
  <div class="sig-row">
    <span class="sig-label">Name&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;:</span>
    <div class="sig-line"></div>
  </div>
  <div class="sig-row">
    <span class="sig-label">Date&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;:</span>
    <div class="sig-line"></div>
  </div>
</div>

</body></html>"""

    html_path = os.path.abspath('docs/tools/cert_temp.html')
    with open(html_path, 'w', encoding='utf-8') as f:
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
        f'file:///{html_path.replace(chr(92), "/")}'
    ], capture_output=True, text=True, timeout=30)

    try:
        os.remove(html_path)
    except:
        pass

    if os.path.exists(output_path) and os.path.getsize(output_path) > 5000:
        from pypdf import PdfReader
        r = PdfReader(output_path)
        print(f"✅ {os.path.basename(output_path)}: {len(r.pages)} page(s), {os.path.getsize(output_path)//1024}KB")
    else:
        print(f"❌ Failed: {output_path}")


# ── CERTIFICATE A-1: Survey Questionnaire Content Validation ─────────────────
make_cert(
    title_sub="Survey Questionnaire",
    statement="""This survey questionnaire for the study entitled <em>"SmartSpend: An AI-Assisted Mobile
    Financial Tracking and Advisory Application for Personal Financial Management"</em> by
    <strong>Directo, Brix A., Rubis, Cyrille John M., and Madayag, Djaunathan Albert S.</strong>,
    BSIT students of Lorma Colleges, has been reviewed for content validity and is deemed
    appropriate and relevant to the financial management experiences of the target population.""",
    fields_html="""
    <div class="field-block">
      <div class="field-row">
        <span class="field-label">Educational Background :</span>
        <div class="field-line"></div>
      </div>
      <div class="field-note">(e.g., BS Commerce, BS Accountancy, BS Business Administration, or equivalent)</div>

      <div class="field-row">
        <span class="field-label">Occupation&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;:</span>
        <div class="field-line"></div>
      </div>
      <div class="field-note">(e.g., Business Owner, Financial Officer, Accountant, Financial Adviser, etc.)</div>

      <div class="field-row">
        <span class="field-label">Years of Experience :</span>
        <div class="field-line"></div>
      </div>
      <div class="field-note">years in financial management and/or business operations</div>
    </div>
    """,
    output_path=os.path.abspath('docs/handsoff/FOR_MAAM_ELLEN/6_CERT_A1_Survey_Questionnaire_Validation.pdf')
)

# ── CERTIFICATE A-3: FHS Formula Content Validation ──────────────────────────
make_cert(
    title_sub="FHS Formula",
    statement="""This Financial Health Score (FHS) formula and its supporting academic literature for
    the study entitled <em>"SmartSpend: An AI-Assisted Mobile Financial Tracking and Advisory
    Application for Personal Financial Management"</em> by <strong>Directo, Brix A., Rubis,
    Cyrille John M., and Madayag, Djaunathan Albert S.</strong>, BSIT students of Lorma Colleges,
    has been reviewed for content validity and is deemed appropriate, academically grounded, and
    relevant to the financial management context of the target population.""",
    fields_html="""
    <div class="field-block">
      <div class="field-row">
        <span class="field-label">Educational Background :</span>
        <div class="field-line"></div>
      </div>
      <div class="field-note">(e.g., BS Commerce, BS Accountancy, MBA, BS Business Administration, or equivalent)</div>

      <div class="field-row">
        <span class="field-label">Occupation&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;:</span>
        <div class="field-line"></div>
      </div>
      <div class="field-note">(e.g., Business Owner, Financial Officer, Accountant, Faculty — Finance/Business, etc.)</div>

      <div class="field-row">
        <span class="field-label">Years of Experience :</span>
        <div class="field-line"></div>
      </div>
      <div class="field-note">years in financial management, business, or related field</div>
    </div>
    """,
    output_path=os.path.abspath('docs/handsoff/FOR_MAAM_ELLEN/7_CERT_A3_FHS_Formula_Validation.pdf')
)
