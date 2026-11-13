"""
TASK 1: Fix wrong figure images in manuscript
"""
from docx import Document
from docx.shared import Inches
from docx.enum.text import WD_ALIGN_PARAGRAPH
import lxml.etree as etree
import os
import re

MANUSCRIPT = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'
FIGURES_DIR = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\FIGURES'

FIGURE_MAP = {
    'Figure 3.4': 'Figure_3.4_Login_Demo_Mode.jpg',
    'Figure 3.5': 'Figure_3.5_Home_Dashboard.jpg',
    'Figure 3.6': 'Figure_3.6_Peso_Chat_Expense_Logging.jpg',
    'Figure 3.7': 'Figure_3.7_Batch_Import_GCash.jpg',
    'Figure 3.8': 'Figure_3.8_FHS_Breakdown.jpg',
    'Figure 3.9': 'Figure_3.9_Budgets_Savings_Goals.jpg',
    'Figure 3.10': 'Figure_3.10_Local_AI_Setup.jpg',
    'Figure 3.11': 'Figure_3.11_SUS_Computation_Table.png',
    'Figure 2.1': 'Figure_2_1_SUS_Interpretation.png',
}

# DO NOT TOUCH: 1.1, 1.2, 2.2, 3.1, 3.2, 3.3

def caption_matches_key(text, key):
    """Check if caption text starts with the key followed by ., :, space, or end."""
    stripped = text.strip()
    if not stripped.startswith(key):
        return False
    after = stripped[len(key):]
    if after == '' or after[0] in '.': 
        return True
    if after[0] in ': ':
        return True
    return False

def remove_all_runs(para):
    """Remove all <w:r> and <w:hyperlink> children from a paragraph XML element."""
    p_elem = para._p
    ns = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
    # Remove all runs
    for r in p_elem.findall(f'{{{ns}}}r'):
        p_elem.remove(r)
    # Remove hyperlinks that might contain runs
    for hl in p_elem.findall(f'{{{ns}}}hyperlink'):
        p_elem.remove(hl)

doc = Document(MANUSCRIPT)
paragraphs = doc.paragraphs
replaced = []

for i, para in enumerate(paragraphs):
    text = para.text.strip()
    for key, img_file in FIGURE_MAP.items():
        if caption_matches_key(text, key):
            # The paragraph immediately before should be the image paragraph
            if i == 0:
                print(f"  WARNING: {key} caption is at index 0, no preceding paragraph")
                continue
            img_para = paragraphs[i - 1]
            img_path = os.path.join(FIGURES_DIR, img_file)
            if not os.path.exists(img_path):
                print(f"  ERROR: Image file not found: {img_path}")
                continue
            # Clear the image paragraph
            remove_all_runs(img_para)
            # Set alignment to center
            img_para.alignment = WD_ALIGN_PARAGRAPH.CENTER
            # Add new run with the image
            run = img_para.add_run()
            run.add_picture(img_path, width=Inches(4.5))
            replaced.append(key)
            print(f"  REPLACED: {key} -> {img_file} (caption at para index {i})")
            break

print(f"\nTotal figures replaced: {len(replaced)}")
print(f"Figures: {replaced}")

# Save
doc.save(MANUSCRIPT)
print(f"\nSaved: {MANUSCRIPT}")

# Verify file size
size = os.path.getsize(MANUSCRIPT)
print(f"File size after save: {size:,} bytes")
if size < 100000:
    print("WARNING: File size suspiciously small!")
else:
    print("File size OK.")
