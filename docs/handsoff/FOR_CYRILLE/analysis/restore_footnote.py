from docx import Document
from docx.shared import Pt

# Load manuscript
doc = Document('c:/xampp/htdocs/smartspend_app/docs/handsoff/FOR_CYRILLE/1_MAIN_MANUSCRIPT_FINAL.docx')

# Footnote text
footnote_text = "Note: The 3 respondents who identified as both parent and young professional were classified by their primary financial role for SUS subgroup analysis, resulting in a final breakdown of 10 parents and 20 young professionals for statistical comparison (Table 8)."

# Search for demographic section
found = False
insert_index = -1

for i, para in enumerate(doc.paragraphs):
    text = para.text.lower()
    # Look for mentions of demographics and N=30
    if ('parent' in text and 'young professional' in text) or \
       ('demographic' in text and 'breakdown' in text) or \
       ('n=30' in text and 'respondent' in text):
        insert_index = i
        print(f"Found potential location at paragraph {i}: {para.text[:80]}...")

# If found a location, insert after that paragraph
if insert_index >= 0:
    # Insert new paragraph after the demographic mention
    # We'll add it as a new paragraph
    para_element = doc.paragraphs[insert_index]._element
    parent = para_element.getparent()
    new_p = parent.makeelement('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}p')
    parent.insert(parent.index(para_element) + 1, new_p)
    
    # Add the text
    from docx.oxml import OxmlElement
    from docx.oxml.ns import qn
    
    r = OxmlElement('w:r')
    t = OxmlElement('w:t')
    t.text = footnote_text
    r.append(t)
    new_p.append(r)
    
    # Make it italic
    rPr = OxmlElement('w:rPr')
    i_elem = OxmlElement('w:i')
    rPr.append(i_elem)
    r.insert(0, rPr)
    
    found = True
    print(f"✓ Footnote inserted after paragraph {insert_index}")
else:
    # Fallback: add at end of document
    print("⚠ No specific location found, adding to end")
    new_para = doc.add_paragraph(footnote_text)
    new_para.runs[0].font.italic = True
    new_para.runs[0].font.size = Pt(11)

# Save
doc.save('c:/xampp/htdocs/smartspend_app/docs/handsoff/FOR_CYRILLE/1_MAIN_MANUSCRIPT_FINAL.docx')
print("✓ Manuscript saved with footnote restored")
print(f"✓ Footnote added: {footnote_text[:60]}...")
