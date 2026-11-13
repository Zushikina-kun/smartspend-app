"""
Patch the two missing paragraphs that caused verifier failures:
1. "By adopting a quantitative developmental approach..." in Research Design
2. "The first objective was achieved." in Conclusions
"""

import shutil
from docx import Document
from docx.oxml.ns import qn
from docx.oxml import OxmlElement

DOCX_PATH = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\1_MAIN_MANUSCRIPT_FINAL.docx'
FOR_CYRILLE = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'

doc = Document(DOCX_PATH)
paras = doc.paragraphs
all_text = '\n'.join(p.text for p in paras)

QUANT_TEXT = ('By adopting a quantitative developmental approach, the study ensured that the system was '
              ' not only technically functional but also user-centered, effective, and aligned with the actual '
              'needs of the respondents. This integrated research design supported continuous refinement and '
              'validation of the SmartSpend application throughout the development process.')

OBJ1_TEXT = ('The first objective was to assess the financial management practices, budgeting challenges, and '
             'expense tracking behaviors of parents aged 35 to 55 and young professionals aged 21 to 35. The needs '
             'assessment of thirty (30) respondents revealed that 96.7% expressed positive intent to use an '
             'AI-powered financial application and 93.3% already used GCash. The first objective was achieved.')

body = doc.element.body

# ── PATCH 1: Add "By adopting a quantitative developmental approach..." ────────
# It goes AFTER the "Moreover, this study also adopted a developmental research approach..."
# paragraph and BEFORE "This integrated research design..." 
# (or rather it replaces/merges with the sentence that was there)
# Actually: the "This integrated research design..." sentence is PART of the QUANT_TEXT above.
# So we insert the new paragraph after the "Moreover..." paragraph.
# But first check if "This integrated research design..." already exists separately.

if 'quantitative developmental approach' not in all_text:
    # Find the "Moreover, this study also adopted" paragraph
    target_para = None
    for i, p in enumerate(paras):
        if p.text.strip().startswith('Moreover, this study also adopted a developmental research approach'):
            target_para = p
            print(f"Found 'Moreover' paragraph at P{i}")
            break
    
    # Also check if "This integrated research design..." is separate
    integrated_para = None
    for i, p in enumerate(paras):
        if p.text.strip().startswith('This integrated research design supported continuous refinement'):
            integrated_para = p
            print(f"Found 'This integrated research design' paragraph at P{i}")
            break
    
    if target_para is not None:
        # Create new paragraph element
        new_para_el = OxmlElement('w:p')
        new_r = OxmlElement('w:r')
        new_t = OxmlElement('w:t')
        
        if integrated_para is not None:
            # The QUANT_TEXT includes "This integrated research design..." so we just need to insert 
            # the first sentence and then remove the separate "This integrated..." para
            insert_text = ('By adopting a quantitative developmental approach, the study ensured that the system was '
                          ' not only technically functional but also user-centered, effective, and aligned with the actual '
                          'needs of the respondents. This integrated research design supported continuous refinement and '
                          'validation of the SmartSpend application throughout the development process.')
            new_t.text = insert_text
            new_t.set('{http://www.w3.org/XML/1998/namespace}space', 'preserve')
            new_r.append(new_t)
            new_para_el.append(new_r)
            # Insert AFTER target_para
            target_para._element.addnext(new_para_el)
            # Remove the old "This integrated research design..." paragraph since it's now part of the new para
            body.remove(integrated_para._element)
            print("PATCH 1a: Inserted 'By adopting...' paragraph and merged 'This integrated...'")
        else:
            # Just insert the full text
            new_t.text = QUANT_TEXT
            new_t.set('{http://www.w3.org/XML/1998/namespace}space', 'preserve')
            new_r.append(new_t)
            new_para_el.append(new_r)
            target_para._element.addnext(new_para_el)
            print("PATCH 1b: Inserted 'By adopting...' paragraph")
    else:
        print("WARNING: Could not find 'Moreover' paragraph for PATCH 1")
else:
    print("PATCH 1: 'quantitative developmental approach' already present")

# Reload
paras = doc.paragraphs
all_text = '\n'.join(p.text for p in paras)

# ── PATCH 2: Add "The first objective was achieved." in Conclusions ────────────
if 'The first objective was achieved' not in all_text:
    # The paragraph should be in the Conclusions section
    # It goes after the SmartSpend v3.1.0 paragraph and before the SmartSpend obtained SUS paragraph
    # Find the paragraph that starts "SmartSpend v3.1.0 was developed as a working Android application..."
    # and insert after it
    
    # Actually let's look at the structure:
    # Conclusions heading
    # (empty)
    # SmartSpend v3.1.0 was developed... [P382]
    # SmartSpend obtained an overall mean SUS... [P383]
    # Recommendations
    
    # We need to insert OBJ1_TEXT between P382 and P383
    # (This is the first objective conclusion that was present in the backup)
    
    smartspend_v3_para = None
    sus_para = None
    
    for i, p in enumerate(paras):
        if (p.text.strip().startswith('SmartSpend v3.1.0 was developed as a working Android application') 
                and 'eight candidate' in p.text):
            smartspend_v3_para = p
            print(f"Found 'SmartSpend v3.1.0...' paragraph at P{i}")
        if (p.text.strip().startswith('SmartSpend obtained an overall mean SUS score of 61.83') 
                or p.text.strip().startswith('SmartSpend obtained an overall mean SUS')):
            sus_para = p
            print(f"Found 'SmartSpend obtained...' paragraph at P{i}")
    
    if smartspend_v3_para is not None:
        new_para_el = OxmlElement('w:p')
        new_r = OxmlElement('w:r')
        new_t = OxmlElement('w:t')
        new_t.text = OBJ1_TEXT
        new_t.set('{http://www.w3.org/XML/1998/namespace}space', 'preserve')
        new_r.append(new_t)
        new_para_el.append(new_r)
        smartspend_v3_para._element.addnext(new_para_el)
        print("PATCH 2: Inserted 'The first objective was achieved.' paragraph")
    else:
        print("WARNING: Could not find SmartSpend v3.1.0 paragraph for PATCH 2")
else:
    print("PATCH 2: 'The first objective was achieved' already present")

# Save
doc.save(DOCX_PATH)
print(f"Saved to {DOCX_PATH}")

shutil.copy2(DOCX_PATH, FOR_CYRILLE)
print(f"Copied to {FOR_CYRILLE}")

# Verify
doc2 = Document(DOCX_PATH)
all2 = '\n'.join(p.text for p in doc2.paragraphs)
print()
print("Verification:")
print("  'quantitative developmental approach':", 'quantitative developmental approach' in all2)
print("  'The first objective was achieved':", 'The first objective was achieved' in all2)
