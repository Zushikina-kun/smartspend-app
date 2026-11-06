"""
Build Certificate of Validation PDF for SmartSpend FHS formula.
Format follows the actual Lorma CCSE validation form from SmartSpend_Manuscript_REVISED_Appendices.docx
Two versions:
  A-1: Content Validation — Survey Questionnaire (for Ma'am Abby as financial management expert)
  A-3: FHS Formula Validation (for Ma'am Abby as financial management expert)
"""
import subprocess, os, sys

css = """
@page { size: A4; margin: 22mm 22mm 20mm 22mm; }
body { font-family: 'Times New Roman', serif; font-size: 11.5pt; color: #111; line-height: 1.55; }
.school-header { text-align: center; margin-bottom: 10pt; }
.school-name { font-size: 13pt; font-weight: bold; text-transform: uppercase; letter-spacing: 0.5px; }
.college-name { font-size: 11pt; }
.address { font-size: 10pt; color: #444; }
hr.thick { border: none; border-top: 2px solid #1a3a5c; margin: 10pt 0 14pt 0; }
hr.thin { border: none; border-top: 1px solid #999; margin: 8pt 0; }
h2.cert-title { text-align: center; font-size: 14pt; text-transform: uppercase; letter-spacing: 1px; margin: 6pt 0 2pt 0; color: #1a3a5c; }
h3.cert-sub { text-align: center; font-size: 11pt; font-weight: normal; color: #555; margin: 0 0 14pt 0; }
.field-row { margin: 6pt 0; font-size: 11.5pt; }
.field-label { font-weight: bold; }
.field-line { border-bottom: 1px solid #333; display: inline-block; min-width: 260pt; }
.field-note { font-size: 10pt; color: #555; margin-left: 16pt; display: block; }
.scale-note { font-size: 10.5pt; margin: 10pt 0 6pt 0; }
table.rating { width: 100%; border-collapse: collapse; font-size: 11pt; margin: 8pt 0 14pt 0; }
table.rating th { background: #1a3a5c; color: white; padding: 5pt 4pt; text-align: center; font-size: 10.5pt; }
table.rating th.criteria-col { text-align: left; width: 72%; }
table.rating td { padding: 5pt 4pt; border-bottom: 1px solid #ddd; vertical-align: top; }
table.rating td.criteria-cell { text-align: left; }
table.rating td.check-cell { text-align: center; }
table.rating tr:nth-child(even) td { background: #f8f8f8; }
.comments-section { margin: 10pt 0; }
.comments-label { font-weight: bold; font-size: 11.5pt; }
.comments-line { border-bottom: 1px solid #999; margin: 10pt 0; }
.recommendation { margin: 12pt 0; }
.rec-label { font-weight: bold; font-size: 11.5pt; }
.rec-row { margin: 4pt 0 4pt 16pt; font-size: 11pt; }
.certification-box { border: 1px solid #1a3a5c; padding: 10pt 12pt; margin: 14pt 0; font-size: 11pt; text-align: justify; }
.cert-label { font-weight: bold; font-size: 11.5pt; margin-bottom: 6pt; }
.sig-area { margin-top: 20pt; }
.sig-row { display: flex; justify-content: space-between; gap: 16pt; margin-top: 24pt; }
.sig-col { flex: 1; text-align: center; }
.sig-line-div { border-top: 1px solid #333; margin: 0 auto; width: 190pt; }
.sig-name { font-size: 11pt; margin-top: 3pt; }
.sig-title { font-size: 10.5pt; color: #444; }
.noted-section { margin-top: 30pt; border-top: 1px solid #ccc; padding-top: 10pt; }
.noted-label { font-size: 11pt; font-weight: bold; margin-bottom: 10pt; }
.footer { font-size: 9pt; color: #666; text-align: center; margin-top: 24pt; border-top: 1px solid #ddd; padding-top: 6pt; }
"""

# ── CERTIFICATE A-1: Survey Questionnaire Content Validation ─────────────────

cert_a1 = f"""<div class="school-header">
  <div class="school-name">Lorma Colleges</div>
  <div class="college-name">College of Computer Studies and Engineering</div>
  <div class="address">San Juan Campus, City of San Fernando, La Union, Philippines</div>
</div>
<hr class="thick">
<h2 class="cert-title">Content Validation Form and Certificate</h2>
<h3 class="cert-sub">Survey Questionnaire and Interview Guide (Appendix B)</h3>

<div class="field-row"><span class="field-label">Name of Validator: </span><span class="field-line">&nbsp;</span></div>
<div class="field-row">
  <span class="field-label">Educational Background: </span><span class="field-line">&nbsp;</span>
  <span class="field-note">(e.g., BS Commerce, BS Accountancy, BS Business Administration, or equivalent)</span>
</div>
<div class="field-row">
  <span class="field-label">Present Occupation / Position: </span><span class="field-line">&nbsp;</span>
  <span class="field-note">(e.g., Business Owner, Financial Officer, Accountant, Financial Adviser, etc.)</span>
</div>
<div class="field-row"><span class="field-label">Institution / Business: </span><span class="field-line">&nbsp;</span></div>
<div class="field-row"><span class="field-label">Years of Experience: </span><span class="field-line" style="min-width:40pt;">&nbsp;</span> years in financial management and/or business operations</div>

<p class="scale-note"><strong>Rating scale:</strong> &nbsp; 4 – Strongly Agree &nbsp;&nbsp; 3 – Agree &nbsp;&nbsp; 2 – Disagree &nbsp;&nbsp; 1 – Strongly Disagree</p>

<table class="rating">
  <thead>
    <tr>
      <th class="criteria-col">Criteria</th>
      <th>4</th><th>3</th><th>2</th><th>1</th>
    </tr>
  </thead>
  <tbody>
    <tr><td class="criteria-cell">1. The items are clearly worded and easy to understand for the target respondents (parents and young professionals).</td><td class="check-cell">☐</td><td class="check-cell">☐</td><td class="check-cell">☐</td><td class="check-cell">☐</td></tr>
    <tr><td class="criteria-cell">2. The items are relevant to financial management practices and directly support the study's research objectives.</td><td class="check-cell">☐</td><td class="check-cell">☐</td><td class="check-cell">☐</td><td class="check-cell">☐</td></tr>
    <tr><td class="criteria-cell">3. The response options are appropriate, complete, and do not overlap.</td><td class="check-cell">☐</td><td class="check-cell">☐</td><td class="check-cell">☐</td><td class="check-cell">☐</td></tr>
    <tr><td class="criteria-cell">4. The questions are free from leading, biased, or double-barreled phrasing.</td><td class="check-cell">☐</td><td class="check-cell">☐</td><td class="check-cell">☐</td><td class="check-cell">☐</td></tr>
    <tr><td class="criteria-cell">5. The technology-use and feature-need items are suitable for assessing the demand for an AI-powered personal finance application.</td><td class="check-cell">☐</td><td class="check-cell">☐</td><td class="check-cell">☐</td><td class="check-cell">☐</td></tr>
    <tr><td class="criteria-cell">6. The length and arrangement of the instrument are suitable for the target respondents and research purpose.</td><td class="check-cell">☐</td><td class="check-cell">☐</td><td class="check-cell">☐</td><td class="check-cell">☐</td></tr>
  </tbody>
</table>

<div class="comments-section">
  <div class="comments-label">Comments and suggested revisions:</div>
  <div class="comments-line">&nbsp;</div>
  <div class="comments-line">&nbsp;</div>
  <div class="comments-line">&nbsp;</div>
</div>

<div class="recommendation">
  <div class="rec-label">Overall recommendation:</div>
  <div class="rec-row">☐ &nbsp; Valid and may be used as is</div>
  <div class="rec-row">☐ &nbsp; Valid, subject to the revisions indicated above</div>
  <div class="rec-row">☐ &nbsp; Not yet valid; major revision needed before use</div>
</div>

<div class="cert-label">Certification</div>
<div class="certification-box">
  I certify that I have reviewed the survey questionnaire (Appendix B) for the study
  <em>"SmartSpend: An AI-Assisted Mobile Financial Tracking and Advisory Application for
  Personal Financial Management"</em> and that the ratings and comments above reflect
  my honest professional judgment.
</div>

<div class="sig-area">
  <div class="sig-row">
    <div class="sig-col">
      <div class="sig-line-div"></div>
      <div class="sig-name">Signature over Printed Name</div>
    </div>
    <div class="sig-col">
      <div class="sig-line-div"></div>
      <div class="sig-name">Date</div>
    </div>
  </div>
</div>

<div class="noted-section">
  <div class="noted-label">Noted by:</div>
  <div class="sig-row">
    <div class="sig-col">
      <div class="sig-line-div"></div>
      <div class="sig-name">ELLEN F. MANGAOANG, DIT</div>
      <div class="sig-title">Capstone Project Adviser, Lorma Colleges CCSE</div>
    </div>
    <div class="sig-col">
      <div class="sig-line-div"></div>
      <div class="sig-name">SHEKIRO R. RAPOSAS</div>
      <div class="sig-title">Teacher-in-Charge, Lorma Colleges CCSE</div>
    </div>
  </div>
</div>

<div class="footer">SmartSpend Capstone 2 — Team Lucid Frame — Lorma Colleges CCSE — BSIT AY 2026–2027</div>"""

# ── CERTIFICATE A-3: FHS Formula Validation ──────────────────────────────────

cert_a3 = f"""<div class="school-header">
  <div class="school-name">Lorma Colleges</div>
  <div class="college-name">College of Computer Studies and Engineering</div>
  <div class="address">San Juan Campus, City of San Fernando, La Union, Philippines</div>
</div>
<hr class="thick">
<h2 class="cert-title">Content Validation Form and Certificate</h2>
<h3 class="cert-sub">Financial Health Score (FHS) Formula — Academic and Literature Basis</h3>

<div class="field-row"><span class="field-label">Name of Validator: </span><span class="field-line">&nbsp;</span></div>
<div class="field-row">
  <span class="field-label">Educational Background: </span><span class="field-line">&nbsp;</span>
  <span class="field-note">(e.g., BS Commerce, BS Accountancy, MBA, or equivalent)</span>
</div>
<div class="field-row">
  <span class="field-label">Present Occupation / Position: </span><span class="field-line">&nbsp;</span>
  <span class="field-note">(e.g., Business Owner, Financial Officer, Accountant, Faculty — Finance/Business, etc.)</span>
</div>
<div class="field-row"><span class="field-label">Institution / Business: </span><span class="field-line">&nbsp;</span></div>
<div class="field-row"><span class="field-label">Years of Experience: </span><span class="field-line" style="min-width:40pt;">&nbsp;</span> years in financial management, business, or related field</div>

<p class="scale-note"><strong>Rating scale:</strong> &nbsp; 4 – Strongly Agree &nbsp;&nbsp; 3 – Agree &nbsp;&nbsp; 2 – Disagree &nbsp;&nbsp; 1 – Strongly Disagree</p>

<table class="rating">
  <thead>
    <tr>
      <th class="criteria-col">Criteria</th>
      <th>4</th><th>3</th><th>2</th><th>1</th>
    </tr>
  </thead>
  <tbody>
    <tr><td class="criteria-cell">1. The FHS formula components (Savings Rate, Overspend Control, Budget Adherence, Logging Consistency) are relevant and appropriate for measuring personal financial health behavior.</td><td class="check-cell">☐</td><td class="check-cell">☐</td><td class="check-cell">☐</td><td class="check-cell">☐</td></tr>
    <tr><td class="criteria-cell">2. The academic literature cited (CBA–Melbourne Institute, FinHealth Score®, Warren &amp; Tyagi 50/30/20 rule, Prospect Theory, Self-Determination Theory) adequately supports the design of the FHS formula.</td><td class="check-cell">☐</td><td class="check-cell">☐</td><td class="check-cell">☐</td><td class="check-cell">☐</td></tr>
    <tr><td class="criteria-cell">3. The equal-weight design (25 points per component) is a defensible approach given the target population and the absence of longitudinal differential-weight data.</td><td class="check-cell">☐</td><td class="check-cell">☐</td><td class="check-cell">☐</td><td class="check-cell">☐</td></tr>
    <tr><td class="criteria-cell">4. The FHS formula is appropriate for use as a prototype financial health indicator for Filipino parents (aged 35–55) and young professionals (aged 21–35) in La Union.</td><td class="check-cell">☐</td><td class="check-cell">☐</td><td class="check-cell">☐</td><td class="check-cell">☐</td></tr>
    <tr><td class="criteria-cell">5. The FHS formula design is consistent with recognized financial management principles and is suitable for the study's academic purpose.</td><td class="check-cell">☐</td><td class="check-cell">☐</td><td class="check-cell">☐</td><td class="check-cell">☐</td></tr>
  </tbody>
</table>

<div class="comments-section">
  <div class="comments-label">Comments and suggested revisions:</div>
  <div class="comments-line">&nbsp;</div>
  <div class="comments-line">&nbsp;</div>
  <div class="comments-line">&nbsp;</div>
</div>

<div class="recommendation">
  <div class="rec-label">Overall recommendation:</div>
  <div class="rec-row">☐ &nbsp; Valid and may be used as is</div>
  <div class="rec-row">☐ &nbsp; Valid, subject to the revisions indicated above</div>
  <div class="rec-row">☐ &nbsp; Not yet valid; major revision needed before use</div>
</div>

<div class="cert-label">Certification</div>
<div class="certification-box">
  I certify that I have reviewed the Financial Health Score (FHS) formula and its supporting
  academic literature for the study <em>"SmartSpend: An AI-Assisted Mobile Financial Tracking
  and Advisory Application for Personal Financial Management"</em> and that the ratings and
  comments above reflect my honest professional judgment.
</div>

<div class="sig-area">
  <div class="sig-row">
    <div class="sig-col">
      <div class="sig-line-div"></div>
      <div class="sig-name">Signature over Printed Name</div>
    </div>
    <div class="sig-col">
      <div class="sig-line-div"></div>
      <div class="sig-name">Date</div>
    </div>
  </div>
</div>

<div class="noted-section">
  <div class="noted-label">Noted by:</div>
  <div class="sig-row">
    <div class="sig-col">
      <div class="sig-line-div"></div>
      <div class="sig-name">ELLEN F. MANGAOANG, DIT</div>
      <div class="sig-title">Capstone Project Adviser, Lorma Colleges CCSE</div>
    </div>
    <div class="sig-col">
      <div class="sig-line-div"></div>
      <div class="sig-name">SHEKIRO R. RAPOSAS</div>
      <div class="sig-title">Teacher-in-Charge, Lorma Colleges CCSE</div>
    </div>
  </div>
</div>

<div class="footer">SmartSpend Capstone 2 — Team Lucid Frame — Lorma Colleges CCSE — BSIT AY 2026–2027</div>"""


def build_pdf(content, output_path, title):
    html = f"""<!DOCTYPE html><html><head><meta charset="utf-8">
    <style>{css}</style></head><body>{content}</body></html>"""

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

    result = subprocess.run([
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
        size_kb = os.path.getsize(output_path) // 1024
        print(f"✅ {title}: {len(r.pages)} pages, {size_kb}KB → {os.path.basename(output_path)}")
        return True
    else:
        print(f"❌ {title} failed")
        return False


# Build both certificates
build_pdf(
    cert_a1,
    os.path.abspath('docs/handsoff/FOR_MAAM_ELLEN/6_CERT_A1_Survey_Questionnaire_Validation.pdf'),
    'A-1 Survey Questionnaire Validation'
)

build_pdf(
    cert_a3,
    os.path.abspath('docs/handsoff/FOR_MAAM_ELLEN/7_CERT_A3_FHS_Formula_Validation.pdf'),
    'A-3 FHS Formula Validation'
)

# Remove old certificate
old = os.path.abspath('docs/handsoff/FOR_MAAM_ELLEN/6_CERTIFICATE_OF_VALIDATION_FHS.pdf')
if os.path.exists(old):
    os.remove(old)
    print(f"Removed old: {os.path.basename(old)}")
