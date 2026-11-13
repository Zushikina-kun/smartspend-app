"""
Replace the existing Figure 2.1 image in the manuscript with the newly generated one.
Uses python-docx to find the paragraph containing "Figure 2.1" and replace the inline image.
"""
from docx import Document
from docx.shared import Inches, Pt
from docx.oxml.ns import qn
from docx.oxml import OxmlElement
import copy, os, shutil

DOCX = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'
IMG  = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\FIGURES\Figure_2_1_SUS_Interpretation.png'

# backup
shutil.copy(DOCX, DOCX + '.fig21.backup')

doc = Document(DOCX)

# ── Find the paragraph that holds the existing Figure 2.1 image ───────────
# Strategy: locate caption "Figure 2.1" paragraph, then look at the paragraph
# immediately before it for the drawing/inline image and replace it.
# Fall-back: insert a new paragraph with the image before the caption.

fig21_caption_idx = None
for i, para in enumerate(doc.paragraphs):
    if 'Figure 2.1' in para.text and 'SUS' in para.text.upper():
        fig21_caption_idx = i
        print(f"Found Figure 2.1 caption at paragraph {i}: {para.text[:80]}")
        break

if fig21_caption_idx is None:
    # broader search
    for i, para in enumerate(doc.paragraphs):
        if 'Figure 2.1' in para.text:
            fig21_caption_idx = i
            print(f"Found Figure 2.1 caption (broad) at paragraph {i}: {para.text[:80]}")
            break

if fig21_caption_idx is None:
    print("ERROR: Could not find Figure 2.1 caption paragraph.")
    exit(1)

# ── Check the paragraph before caption for an existing image ──────────────
def has_image(para):
    return para._p.findall('.//' + qn('a:blip')) != []

image_para_idx = None
# Search up to 5 paragraphs before caption
for offset in range(1, 6):
    idx = fig21_caption_idx - offset
    if idx < 0:
        break
    if has_image(doc.paragraphs[idx]):
        image_para_idx = idx
        print(f"Found existing image paragraph at index {idx}")
        break

# ── Replace or insert ─────────────────────────────────────────────────────
caption_para = doc.paragraphs[fig21_caption_idx]

if image_para_idx is not None:
    # Clear the old image paragraph and insert new image
    old_para = doc.paragraphs[image_para_idx]
    # Remove all runs from the old paragraph
    for run in old_para.runs:
        run._element.getparent().remove(run._element)
    # Add new image run into the now-empty paragraph
    run = old_para.add_run()
    run.add_picture(IMG, width=Inches(5.5))
    old_para.alignment = 1  # center
    print(f"Replaced existing image at paragraph {image_para_idx}")
else:
    # Insert a new paragraph with the image just before the caption
    # python-docx doesn't have insert_paragraph_before natively, use XML
    new_para = OxmlElement('w:p')
    pPr = OxmlElement('w:pPr')
    jc = OxmlElement('w:jc')
    jc.set(qn('w:val'), 'center')
    pPr.append(jc)
    new_para.append(pPr)
    caption_para._p.addprevious(new_para)

    # Now get the actual paragraph object and add picture through a run
    # We need a fresh reference — the paragraph list is stale after XML manip
    # Reload paragraphs to get fresh index
    doc2 = Document(DOCX)  # re-open won't help; manipulate via run on new element
    # Instead: add a temporary paragraph, save, reload is complex.
    # Use the direct XML approach to add a drawing to new_para:
    from docx.oxml.ns import nsmap
    import docx.opc.constants
    # Simpler: just use the paragraph we inserted by adding a real run via doc object
    # The appended XML paragraph is now in the doc's body — find it by position
    body = doc.element.body
    body_paras = body.findall(qn('w:p'))
    # find our new_para in body_paras
    new_idx = list(body_paras).index(new_para)
    # Use a workaround: temporarily wrap in a Document-level paragraph
    from docx.text.paragraph import Paragraph as DocxParagraph
    para_obj = DocxParagraph(new_para, caption_para._parent)
    run = para_obj.add_run()
    run.add_picture(IMG, width=Inches(5.5))
    print(f"Inserted new image paragraph before caption (index {new_idx})")

doc.save(DOCX)
print("Saved manuscript with Figure 2.1 updated.")
