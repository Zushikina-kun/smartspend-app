"""
TASK 3: Update TOC with estimated page numbers
"""
from docx import Document
from docx.shared import Inches, Pt
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml.ns import qn
from docx.oxml import OxmlElement
import lxml.etree as etree
import os
import copy

MANUSCRIPT = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'

# TOC entries with estimated page numbers
# Format: (display_text, page_num, indent_level, search_text_in_doc)
TOC_ENTRIES = [
    # Front matter
    ("Title Page", "i", 0, None),  # Always exists
    ("Approval Sheet", "ii", 0, "Approval"),
    ("Acknowledgement", "iii", 0, "Acknowledgement"),
    ("Dedication", "iv", 0, "Dedication"),
    ("Table of Contents", "v", 0, "TABLE OF CONTENTS"),
    ("List of Figures", "vi", 0, "LIST OF FIGURES"),
    ("List of Tables", "vii", 0, "LIST OF TABLES"),
    ("Abstract", "viii", 0, "Abstract"),
    # Chapter I
    ("CHAPTER I: INTRODUCTION", "1", 0, "CHAPTER I"),
    ("Project Context", "1", 1, "Project Context"),
    ("Statement of the Problem", "3", 1, "Statement of the Problem"),
    ("Statement of Objectives", "5", 1, "Statement of Objectives"),
    ("Significance of the Study", "8", 1, "Significance of the Study"),
    ("Scope and Limitations", "11", 1, "Scope and Limitations"),
    ("Definition of Terms", "14", 1, "Definition of Terms"),
    ("Conceptual Framework", "19", 1, "Conceptual Framework"),
    ("Technical Background", "22", 1, "Technical Background"),
    # Chapter II
    ("CHAPTER II: RESEARCH METHODOLOGY", "28", 0, "CHAPTER II"),
    ("Research Design", "28", 1, "Research Design"),
    ("Population and Locale", "30", 1, "Population and Locale"),
    ("Sampling Procedure", "32", 1, "Sampling Procedure"),
    ("Data Gathering Procedure", "34", 1, "Data Gathering Procedure"),
    ("Statistical Treatment of Data", "36", 1, "Statistical Treatment of Data"),
    # Chapter III
    ("CHAPTER III: RESULTS AND DISCUSSION", "43", 0, "CHAPTER III"),
    ("Objective 1", "43", 1, "Objective 1"),
    ("Objective 2", "55", 1, "Objective 2"),
    ("Objective 3", "65", 1, "Objective 3"),
    # Chapter IV
    ("CHAPTER IV: CONCLUSIONS AND RECOMMENDATIONS", "73", 0, "CHAPTER IV"),
    ("Conclusions", "73", 1, "Conclusions"),
    ("Recommendations", "75", 1, "Recommendations"),
    # References and Appendices
    ("REFERENCES", "78", 0, "REFERENCES"),
    ("APPENDIX A: Survey Questionnaire", "84", 0, "APPENDIX A"),
    ("APPENDIX B: SUS Questionnaire", "86", 0, "APPENDIX B"),
    ("APPENDIX C: SUS Individual Scores", "90", 0, "APPENDIX C"),
    ("APPENDIX D: Content Validation Certificate (Survey Questionnaire)", "96", 0, "APPENDIX D"),
    ("APPENDIX E: Content Validation Certificate (FHS Formula)", "97", 0, "APPENDIX E"),
    ("CURRICULUM VITAE", "99", 0, "CURRICULUM VITAE"),
]

doc = Document(MANUSCRIPT)
paragraphs = doc.paragraphs

# Step 1: Scan all paragraphs to collect heading texts
print("Scanning document for headings...")
doc_texts = set()
for para in paragraphs:
    t = para.text.strip()
    if t:
        doc_texts.add(t.upper())
        # Also add partial matches
        doc_texts.add(t[:30].upper() if len(t) >= 30 else t.upper())

def heading_exists_in_doc(search_text):
    """Check if a heading/section with this text exists anywhere in the document."""
    if search_text is None:
        return True
    su = search_text.upper()
    for para in paragraphs:
        if su in para.text.upper():
            return True
    return False

# Step 2: Find the TOC section
toc_start_idx = None
for i, para in enumerate(paragraphs):
    t = para.text.strip().upper()
    if 'TABLE OF CONTENTS' in t:
        toc_start_idx = i
        print(f"Found TOC at paragraph index {i}: '{para.text.strip()}'")
        break

if toc_start_idx is None:
    print("WARNING: Could not find TABLE OF CONTENTS heading. Searching broader...")
    for i, para in enumerate(paragraphs):
        t = para.text.strip().upper()
        if 'CONTENTS' in t and len(t) < 40:
            toc_start_idx = i
            print(f"Found potential TOC at paragraph index {i}: '{para.text.strip()}'")
            break

if toc_start_idx is None:
    print("ERROR: Could not find TOC section!")
    exit(1)

# Find TOC end (next major section after TOC)
toc_end_idx = toc_start_idx + 1
for i in range(toc_start_idx + 1, min(toc_start_idx + 80, len(paragraphs))):
    t = paragraphs[i].text.strip().upper()
    # TOC ends when we hit a section that's clearly not a TOC entry
    if ('LIST OF FIGURES' in t or 'LIST OF TABLES' in t or 
        'ABSTRACT' in t or 'CHAPTER I' in t):
        toc_end_idx = i
        print(f"TOC ends at paragraph index {i}: '{paragraphs[i].text.strip()}'")
        break
    toc_end_idx = i + 1

print(f"TOC range: {toc_start_idx} to {toc_end_idx}")

# Step 3: Analyze existing TOC entries
existing_entries = []
for i in range(toc_start_idx + 1, toc_end_idx):
    t = paragraphs[i].text.strip()
    if t:
        existing_entries.append((i, t))
        print(f"  Existing TOC entry [{i}]: {t[:70]}")

# Step 4: Clear existing TOC entries and rebuild
# We'll remove all existing TOC content paragraphs and insert fresh ones
# Find the paragraph element of the TOC heading to insert after
toc_heading_para = paragraphs[toc_start_idx]

# Remove existing TOC entry paragraphs (from end to start to preserve indices)
removed = 0
for i in range(toc_end_idx - 1, toc_start_idx, -1):
    para = paragraphs[i]
    t = para.text.strip()
    # Only remove paragraphs that look like TOC entries (have dots or tab+number)
    if t and ('....' in t or '\t' in t or any(char.isdigit() for char in t[-5:])):
        para._element.getparent().remove(para._element)
        removed += 1

print(f"Removed {removed} existing TOC entry paragraphs")

# Reload paragraphs after removal
doc_paragraphs_fresh = doc.paragraphs
toc_heading_para_fresh = None
for para in doc_paragraphs_fresh:
    if 'TABLE OF CONTENTS' in para.text.upper():
        toc_heading_para_fresh = para
        break

if toc_heading_para_fresh is None:
    print("ERROR: Lost TOC heading after removal!")
    exit(1)

# Step 5: Insert new TOC entries after the TOC heading
# We insert them after the TOC heading paragraph
# Use XML manipulation to insert paragraphs

def make_toc_paragraph(doc, display_text, page_num, indent_level, verified):
    """Create a formatted TOC paragraph with dot leaders."""
    if not verified:
        return None
    
    para = OxmlElement('w:p')
    pPr = OxmlElement('w:pPr')
    
    # Indentation
    ind = OxmlElement('w:ind')
    left_twips = int(indent_level * 720)  # 720 twips = 0.5 inch
    ind.set(qn('w:left'), str(left_twips))
    ind.set(qn('w:firstLine'), '0')
    pPr.append(ind)
    
    # Tab stop at right margin for page number
    tabs = OxmlElement('w:tabs')
    tab = OxmlElement('w:tab')
    tab.set(qn('w:val'), 'right')
    tab.set(qn('w:leader'), 'dot')
    tab.set(qn('w:pos'), '8640')  # ~6 inches from left
    tabs.append(tab)
    pPr.append(tabs)
    
    # Alignment
    jc = OxmlElement('w:jc')
    jc.set(qn('w:val'), 'left')
    pPr.append(jc)
    
    # Spacing
    spacing = OxmlElement('w:spacing')
    spacing.set(qn('w:before'), '0')
    spacing.set(qn('w:after'), '0')
    pPr.append(spacing)
    
    para.append(pPr)
    
    # Run with entry text
    r1 = OxmlElement('w:r')
    rPr1 = OxmlElement('w:rPr')
    rFonts1 = OxmlElement('w:rFonts')
    rFonts1.set(qn('w:ascii'), 'Tahoma')
    rFonts1.set(qn('w:hAnsi'), 'Tahoma')
    rPr1.append(rFonts1)
    sz1 = OxmlElement('w:sz')
    sz1.set(qn('w:val'), '24')  # 12pt = 24 half-points
    rPr1.append(sz1)
    r1.append(rPr1)
    t1 = OxmlElement('w:t')
    t1.set('{http://www.w3.org/XML/1998/namespace}space', 'preserve')
    t1.text = display_text + ' '
    r1.append(t1)
    para.append(r1)
    
    # Tab run
    r2 = OxmlElement('w:r')
    rPr2 = OxmlElement('w:rPr')
    rFonts2 = OxmlElement('w:rFonts')
    rFonts2.set(qn('w:ascii'), 'Tahoma')
    rFonts2.set(qn('w:hAnsi'), 'Tahoma')
    rPr2.append(rFonts2)
    sz2 = OxmlElement('w:sz')
    sz2.set(qn('w:val'), '24')
    rPr2.append(sz2)
    r2.append(rPr2)
    tab_elem = OxmlElement('w:tab')
    r2.append(tab_elem)
    para.append(r2)
    
    # Page number run
    r3 = OxmlElement('w:r')
    rPr3 = OxmlElement('w:rPr')
    rFonts3 = OxmlElement('w:rFonts')
    rFonts3.set(qn('w:ascii'), 'Tahoma')
    rFonts3.set(qn('w:hAnsi'), 'Tahoma')
    rPr3.append(rFonts3)
    sz3 = OxmlElement('w:sz')
    sz3.set(qn('w:val'), '24')
    rPr3.append(sz3)
    r3.append(rPr3)
    t3 = OxmlElement('w:t')
    t3.text = page_num
    r3.append(t3)
    para.append(r3)
    
    return para

# Insert TOC entries after the TOC heading
parent_body = toc_heading_para_fresh._element.getparent()
insert_after = toc_heading_para_fresh._element

added_count = 0
skipped_count = 0

for display_text, page_num, indent_level, search_text in TOC_ENTRIES:
    verified = heading_exists_in_doc(search_text)
    if not verified:
        print(f"  SKIP (not found in doc): {display_text}")
        skipped_count += 1
        continue
    
    new_para_elem = make_toc_paragraph(doc, display_text, page_num, indent_level, verified)
    if new_para_elem is not None:
        insert_after.addnext(new_para_elem)
        insert_after = new_para_elem
        added_count += 1
        print(f"  ADDED TOC: {display_text} ... {page_num}")

print(f"\nAdded {added_count} TOC entries, skipped {skipped_count}")

# Save
doc.save(MANUSCRIPT)
print(f"\nSaved: {MANUSCRIPT}")

size = os.path.getsize(MANUSCRIPT)
print(f"File size after save: {size:,} bytes")
if size < 100000:
    print("WARNING: File size suspiciously small!")
else:
    print("File size OK.")
