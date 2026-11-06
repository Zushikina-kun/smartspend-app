"""
Build final validation certificates — PDF + DOCX versions.
Uses cropped clean Lorma logo, City seal, CCSE seal.
"""
import subprocess, os, sys, base64, shutil, time

# ── Helpers ───────────────────────────────────────────────────────────────────
def img_to_b64(path):
    with open(path, 'rb') as f:
        data = f.read()
    ext = path.split('.')[-1].lower()
    mime = 'image/jpeg' if ext in ('jpg','jpeg') else 'image/png'
    return f"data:{mime};base64,{base64.b64encode(data).decode()}"

lorma = img_to_b64('docs/tools/extracted_images/logos/lorma_cropped.png')
city  = img_to_b64('docs/tools/extracted_images/logos/seal_sanfernando.png')
ccse  = img_to_b64('docs/tools/extracted_images/logos/habss_ref_p3_img1.jpeg')

# ── CSS ───────────────────────────────────────────────────────────────────────
css = """
@page { size: Letter; margin: 20mm 25mm 20mm 25mm; }
* { box-sizing: border-box; }
body {
  font-family: 'Times New Roman', serif;
  font-size: 12pt;
  color: #000;
  line-height: 1.6;
}
.logo-row {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 20pt;
  margin-bottom: 8pt;
}
.logo-lorma { height: 56pt; width: auto; }
.logo-city  { height: 60pt; width: auto; }
.logo-ccse  { height: 60pt; width: auto; }
hr { border: none; border-top: 1.5px solid #000; margin: 6pt 0 14pt 0; }
.title {
  text-align: center;
  font-size: 14pt;
  font-weight: bold;
  letter-spacing: 0.5px;
  margin: 0 0 16pt 0;
  text-transform: uppercase;
}
p {
  text-align: justify;
  margin: 0 0 11pt 0;
  text-indent: 36pt;
  font-size: 12pt;
}
.no-indent { text-indent: 0; }
.sig-area { margin-top: 28pt; }
.validated-label { font-size: 12pt; margin-bottom: 32pt; text-indent: 0; }
.sig-line { border-top: 1.5px solid #000; width: 260pt; margin-bottom: 4pt; }
.sig-name { font-weight: bold; font-size: 12pt; text-transform: uppercase; margin: 0; text-indent: 0; }
.sig-detail { font-size: 12pt; margin: 0; text-indent: 0; }
"""

# ── PDF builder ───────────────────────────────────────────────────────────────
def build_pdf(out_final, para1, para2, para3):
    html = f"""<!DOCTYPE html>
<html><head><meta charset="utf-8"><style>{css}</style></head>
<body>
<div class="logo-row">
  <img src="{lorma}" class="logo-lorma" alt="Lorma">
  <img src="{city}"  class="logo-city"  alt="City of San Fernando">
  <img src="{ccse}"  class="logo-ccse"  alt="CCSE">
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

    ts = int(time.time() * 1000)
    import tempfile
    tmp  = os.path.join(tempfile.gettempdir(), f'ct_{ts}.html')
    tmp2 = os.path.join(tempfile.gettempdir(), f'ct_{ts}.pdf')

    with open(tmp, 'w', encoding='utf-8') as f:
        f.write(html)

    edge = r'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
    if not os.path.exists(edge):
        edge = r'C:\Program Files\Microsoft\Edge\Application\msedge.exe'

    subprocess.run([
        edge, '--headless', '--disable-gpu', '--no-sandbox',
        '--disk-cache-dir=nul',
        f'--print-to-pdf={tmp2}',
        '--print-to-pdf-no-header', '--no-pdf-header-footer',
        f'file:///{tmp.replace(chr(92), "/")}',
    ], capture_output=True, timeout=30)

    time.sleep(1)
    try: os.remove(tmp)
    except: pass

    if os.path.exists(tmp2) and os.path.getsize(tmp2) > 5000:
        shutil.copy2(tmp2, out_final)
        os.remove(tmp2)
        from pypdf import PdfReader
        r = PdfReader(out_final)
        print(f"  PDF ✅ {os.path.basename(out_final)}: {len(r.pages)}p {os.path.getsize(out_final)//1024}KB")
        return True
    else:
        print(f"  PDF ❌ {out_final}")
        return False

# ── DOCX builder ─────────────────────────────────────────────────────────────
def build_docx(out_path, title_label, para1_text, para2_text, para3_text):
    from docx import Document
    from docx.shared import Inches, Pt, RGBColor, Cm
    from docx.enum.text import WD_ALIGN_PARAGRAPH
    from docx.enum.table import WD_TABLE_ALIGNMENT
    from docx.oxml.ns import qn
    from docx.oxml import OxmlElement
    import lxml.etree as etree

    doc = Document()

    # Page margins
    for section in doc.sections:
        section.top_margin    = Cm(2.0)
        section.bottom_margin = Cm(2.0)
        section.left_margin   = Cm(2.5)
        section.right_margin  = Cm(2.5)

    # ── Logo row ── use a 1-row 3-col table
    tbl = doc.add_table(rows=1, cols=3)
    tbl.alignment = WD_TABLE_ALIGNMENT.CENTER
    tbl.style = 'Table Grid'
    # Remove all borders
    for row in tbl.rows:
        for cell in row.cells:
            tc = cell._tc
            tcPr = tc.get_or_add_tcPr()
            tcBorders = OxmlElement('w:tcBorders')
            for side in ['top','left','bottom','right','insideH','insideV']:
                border = OxmlElement(f'w:{side}')
                border.set(qn('w:val'), 'none')
                tcBorders.append(border)
            tcPr.append(tcBorders)

    # Insert logos
    logo_files = [
        ('docs/tools/extracted_images/logos/lorma_cropped.png', Inches(1.5)),
        ('docs/tools/extracted_images/logos/seal_sanfernando.png', Inches(0.85)),
        ('docs/tools/extracted_images/logos/habss_ref_p3_img1.jpeg', Inches(0.85)),
    ]
    for col_idx, (logo_path, width) in enumerate(logo_files):
        cell = tbl.rows[0].cells[col_idx]
        cell.paragraphs[0].alignment = WD_ALIGN_PARAGRAPH.CENTER
        run = cell.paragraphs[0].add_run()
        run.add_picture(logo_path, width=width)

    # Spacing after table
    doc.add_paragraph()

    # ── Divider (horizontal rule via paragraph border) ──
    hr_para = doc.add_paragraph()
    pPr = hr_para._p.get_or_add_pPr()
    pBdr = OxmlElement('w:pBdr')
    bottom = OxmlElement('w:bottom')
    bottom.set(qn('w:val'), 'single')
    bottom.set(qn('w:sz'), '6')
    bottom.set(qn('w:space'), '1')
    bottom.set(qn('w:color'), '000000')
    pBdr.append(bottom)
    pPr.append(pBdr)
    hr_para.paragraph_format.space_before = Pt(0)
    hr_para.paragraph_format.space_after  = Pt(6)

    # ── Title ──
    title_p = doc.add_paragraph()
    title_p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    title_p.paragraph_format.space_after = Pt(12)
    title_run = title_p.add_run('CERTIFICATE OF VALIDATION')
    title_run.bold = True
    title_run.font.size = Pt(14)

    # ── Body paragraphs ──
    def add_body(text):
        p = doc.add_paragraph()
        p.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
        p.paragraph_format.first_line_indent = Cm(1.27)
        p.paragraph_format.space_after = Pt(8)
        # Parse simple bold/italic markers
        import re
        parts = re.split(r'(<strong>.*?</strong>|<em>.*?</em>)', text)
        for part in parts:
            if part.startswith('<strong>'):
                run = p.add_run(part[8:-9])
                run.bold = True
                run.font.size = Pt(12)
            elif part.startswith('<em>'):
                run = p.add_run(part[4:-5])
                run.italic = True
                run.font.size = Pt(12)
            else:
                run = p.add_run(part)
                run.font.size = Pt(12)
        return p

    add_body(para1_text)
    add_body(para2_text)
    add_body(para3_text)

    # ── Issued line ──
    issued = doc.add_paragraph('Issued this ______ day of __________________, 2026.')
    issued.paragraph_format.first_line_indent = Pt(0)
    issued.paragraph_format.space_after = Pt(6)
    for run in issued.runs:
        run.font.size = Pt(12)

    # ── Validated by ──
    vby = doc.add_paragraph()
    vby.paragraph_format.space_before = Pt(18)
    vby.paragraph_format.space_after  = Pt(24)
    r = vby.add_run('Validated by:')
    r.font.size = Pt(12)

    # ── Signature line ──
    sig = doc.add_paragraph('_' * 38)
    sig.paragraph_format.first_line_indent = Pt(0)
    sig.paragraph_format.space_after = Pt(4)
    for r in sig.runs:
        r.font.size = Pt(12)

    # Name / title / institution blank lines
    for _ in range(3):
        bl = doc.add_paragraph('_' * 38)
        bl.paragraph_format.first_line_indent = Pt(0)
        bl.paragraph_format.space_after = Pt(4)
        for r in bl.runs:
            r.font.size = Pt(12)

    doc.save(out_path)
    print(f"  DOCX ✅ {os.path.basename(out_path)}: {os.path.getsize(out_path)//1024}KB")


# ── Content ───────────────────────────────────────────────────────────────────
certs = [
    {
        'label': 'A-1 Survey Questionnaire',
        'pdf':  'docs/handsoff/FOR_MAAM_ELLEN/6_CERT_A1_Survey_Questionnaire_Validation.pdf',
        'docx': 'docs/handsoff/FOR_MAAM_ELLEN/6_CERT_A1_Survey_Questionnaire_Validation.docx',
        'p1': 'This is to certify that the survey questionnaire for the study entitled <em>"SmartSpend: An AI-Assisted Mobile Financial Tracking and Advisory Application for Personal Financial Management,"</em> prepared by <strong>Directo, Brix A., Rubis, Cyrille John M., and Madayag, Djaunathan Albert S.</strong>, BSIT students of Lorma Colleges, with the guidance of <strong>Dr. Ellen F. Mangaoang, DIT</strong>, research adviser, has been carefully reviewed, evaluated, and validated by the undersigned.',
        'p2': 'The instrument was assessed based on its relevance, clarity, accuracy, appropriateness, and alignment with the objectives of the study. The validator ensured that the survey items were suitable for measuring the financial management practices, budgeting challenges, and expense tracking behaviors of the target respondents — parents aged 35 to 55 and young professionals aged 21 to 35 in San Fernando City, La Union.',
        'p3': 'After thorough evaluation, the survey questionnaire is hereby certified as valid and appropriate for use in the conduct of the study, subject to the revisions and recommendations provided, if any.',
    },
    {
        'label': 'A-3 FHS Formula',
        'pdf':  'docs/handsoff/FOR_MAAM_ELLEN/7_CERT_A3_FHS_Formula_Validation.pdf',
        'docx': 'docs/handsoff/FOR_MAAM_ELLEN/7_CERT_A3_FHS_Formula_Validation.docx',
        'p1': 'This is to certify that the Financial Health Score (FHS) formula and its supporting academic literature for the study entitled <em>"SmartSpend: An AI-Assisted Mobile Financial Tracking and Advisory Application for Personal Financial Management,"</em> prepared by <strong>Directo, Brix A., Rubis, Cyrille John M., and Madayag, Djaunathan Albert S.</strong>, BSIT students of Lorma Colleges, with the guidance of <strong>Dr. Ellen F. Mangaoang, DIT</strong>, research adviser, has been carefully reviewed, evaluated, and validated by the undersigned.',
        'p2': 'The FHS formula was assessed based on its relevance, academic grounding, accuracy, appropriateness, and alignment with established financial health measurement frameworks. The validator ensured that the formula components — Savings Rate, Overspend Control, Budget Adherence, and Logging Consistency — and their supporting literature are suitable for use as a prototype financial health indicator for the study\'s target population in San Fernando City, La Union.',
        'p3': 'After thorough evaluation, the Financial Health Score formula and its academic literature basis are hereby certified as valid and appropriate for use in the conduct of the study, subject to the revisions and recommendations provided, if any.',
    },
]

for cert in certs:
    print(f"\nBuilding {cert['label']}...")
    build_pdf(os.path.abspath(cert['pdf']), cert['p1'], cert['p2'], cert['p3'])
    build_docx(os.path.abspath(cert['docx']), cert['label'], cert['p1'], cert['p2'], cert['p3'])

print("\nAll done.")
