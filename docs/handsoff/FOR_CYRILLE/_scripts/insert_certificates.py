"""
Append Appendix D and Appendix E with certificate images to the manuscript.
Looks for existing Appendix D/E headings first; if found, inserts images after them.
If not found, creates new appendix sections at the end.
"""
import shutil
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml.ns import qn
from docx.oxml import OxmlElement

DOCX  = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'
CERT_D = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\FIGURES\certificates\AppendixD_Survey_Questionnaire_Certificate.jpg'
CERT_E = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\FIGURES\certificates\AppendixE_FHS_Formula_Certificate.jpg'

shutil.copy(DOCX, DOCX + '.precert.backup')
doc = Document(DOCX)

# ── Scan for existing Appendix D / E paragraphs ───────────────────────────
appD_idx = appE_idx = None
for i, para in enumerate(doc.paragraphs):
    t = para.text.strip()
    if t in ('Appendix D', 'APPENDIX D') or t.startswith('Appendix D ') or t.startswith('APPENDIX D '):
        appD_idx = i
    if t in ('Appendix E', 'APPENDIX E') or t.startswith('Appendix E ') or t.startswith('APPENDIX E '):
        appE_idx = i

print(f"Appendix D heading at para: {appD_idx}")
print(f"Appendix E heading at para: {appE_idx}")

def add_page_break(doc):
    """Add a page break paragraph."""
    p = OxmlElement('w:p')
    r = OxmlElement('w:r')
    br = OxmlElement('w:br')
    br.set(qn('w:type'), 'page')
    r.append(br)
    p.append(r)
    return p

def insert_cert_after(doc, heading_idx, img_path, appendix_label, title):
    """Insert a centered image after the heading paragraph."""
    heading_para = doc.paragraphs[heading_idx]
    
    # Check if next non-empty para already has an image
    next_idx = heading_idx + 1
    while next_idx < len(doc.paragraphs) and not doc.paragraphs[next_idx].text.strip():
        next_idx += 1
    if next_idx < len(doc.paragraphs):
        next_para = doc.paragraphs[next_idx]
        if next_para._p.findall('.//' + qn('a:blip')):
            print(f"  {appendix_label}: image already present after heading — replacing")
            # Replace existing image
            for run in next_para.runs:
                run._element.getparent().remove(run._element)
            run = next_para.add_run()
            run.add_picture(img_path, width=Inches(5.5))
            next_para.alignment = WD_ALIGN_PARAGRAPH.CENTER
            return True

    # Insert new paragraph with image right after heading
    from docx.text.paragraph import Paragraph as DocxParagraph
    new_p = OxmlElement('w:p')
    pPr = OxmlElement('w:pPr')
    jc = OxmlElement('w:jc')
    jc.set(qn('w:val'), 'center')
    pPr.append(jc)
    new_p.append(pPr)
    heading_para._p.addnext(new_p)
    para_obj = DocxParagraph(new_p, heading_para._parent)
    run = para_obj.add_run()
    run.add_picture(img_path, width=Inches(5.5))
    print(f"  {appendix_label}: inserted image after heading (para {heading_idx})")
    return True

def append_cert_section(doc, appendix_label, title, img_path, add_page_break_before=True):
    """Add a new appendix section at end of document."""
    body = doc.element.body

    # Page break before
    if add_page_break_before:
        pb_p = add_page_break(doc)
        # Insert before last paragraph (usually the final empty para)
        body.append(pb_p)

    # Appendix heading
    heading = doc.add_paragraph()
    heading.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run = heading.add_run(appendix_label)
    run.bold = True
    run.font.size = Pt(12)

    # Title
    title_para = doc.add_paragraph()
    title_para.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run2 = title_para.add_run(title)
    run2.bold = True
    run2.font.size = Pt(12)

    # Image
    img_para = doc.add_paragraph()
    img_para.alignment = WD_ALIGN_PARAGRAPH.CENTER
    img_para.add_run().add_picture(img_path, width=Inches(5.5))

    print(f"  {appendix_label}: appended new section at end of document")

# ── Insert or append ──────────────────────────────────────────────────────
if appD_idx is not None:
    insert_cert_after(doc, appD_idx, CERT_D, 'Appendix D', 'Content Validation Certificate (Survey Questionnaire)')
else:
    append_cert_section(doc, 'Appendix D',
        'Content Validation Certificate (Survey Questionnaire)', CERT_D,
        add_page_break_before=True)

if appE_idx is not None:
    insert_cert_after(doc, appE_idx, CERT_E, 'Appendix E', 'Content Validation Certificate (FHS Formula and Literature)')
else:
    append_cert_section(doc, 'Appendix E',
        'Content Validation Certificate (FHS Formula and Literature)', CERT_E,
        add_page_break_before=True)

doc.save(DOCX)
print(f"\nSaved: {DOCX}")

# Verify
doc2 = Document(DOCX)
img_count = sum(len(p._p.findall('.//' + qn('a:blip'))) for p in doc2.paragraphs)
print(f"Total images now: {img_count} (was 28, should be 30)")
print(f"Total paragraphs: {len(doc2.paragraphs)}")
