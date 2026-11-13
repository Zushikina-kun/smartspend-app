"""
Step 3–4: Apply restructuring to SmartSpend FINAL manuscript.
- Remove generic dev diagrams (Figure 6 Flowchart, Figure 7 Use Case, Figure 8 Visual TOC)
- Remove in-text references to removed figures
- Renumber figures and tables sequentially
- Update in-text figure/table references
- Regenerate List of Figures and List of Tables
- Technical Background: check Firebase subsection headings (they are plain paras, not headings)
- Demographic Distribution figure: check if it needs moving (it's already near demographic table)
- Save once at end

GOLDEN RULE: Do NOT restore previously removed content.
"""

import re
import copy
from docx import Document
from docx.oxml.ns import qn as _qn
from lxml import etree

DOC_PATH = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx"

doc = Document(DOC_PATH)
paras = doc.paragraphs

def has_image(para):
    xml_str = etree.tostring(para._element, encoding='unicode')
    return 'w:drawing' in xml_str or 'w:pict' in xml_str or 'a:blip' in xml_str

def para_index(para):
    """Get the index of a paragraph in doc.paragraphs list."""
    for i, p in enumerate(doc.paragraphs):
        if p._element is para._element:
            return i
    return -1

def delete_para(para):
    """Delete a paragraph at the XML level."""
    p = para._element
    parent = p.getparent()
    if parent is not None:
        parent.remove(p)

# ============================================================
# STEP 1: Identify paragraphs to remove
# ============================================================

print("=== Scanning document structure ===")
for i, p in enumerate(paras):
    text = p.text.strip()
    if 'Figure 6' in text or 'Figure 7' in text or 'Figure 8' in text or 'Flowchart' in text or 'Use Case' in text or 'Visual Table' in text:
        img = "[IMG]" if has_image(p) else ""
        print(f"  [{i:04d}] {img} {text[:100]}")

print()

# Based on dump analysis:
# Para 307: [IMG] - image for Figure 6 (System Flowchart)
# Para 308: Figure 6.  SmartSpend System Flowchart
# Para 309: [IMG] - image for Figure 7 (Use Case Diagram)
# Para 310: Figure 7.  Use Case Diagram
# Para 311: (blank)
# Para 312: [IMG] - image for Figure 8 (Visual Table of Contents)
# Para 313: Figure 8.  Visual Table of Contents

# We need to find these by text content since indices may shift
def find_para_by_text_prefix(text_prefix, start=0):
    for i, p in enumerate(paras[start:], start=start):
        if p.text.strip().startswith(text_prefix):
            return i, p
    return -1, None

# Find the paragraphs in current doc
fig6_img_idx = -1
fig6_cap_idx = -1
fig7_img_idx = -1
fig7_cap_idx = -1
fig8_img_idx = -1
fig8_cap_idx = -1

for i, p in enumerate(paras):
    txt = p.text.strip()
    if txt.startswith('Figure 6.') and 'Flowchart' in txt:
        fig6_cap_idx = i
        # Image is the paragraph immediately before
        if i > 0 and has_image(paras[i-1]):
            fig6_img_idx = i - 1
    elif txt.startswith('Figure 7.') and 'Use Case' in txt:
        fig7_cap_idx = i
        if i > 0 and has_image(paras[i-1]):
            fig7_img_idx = i - 1
    elif txt.startswith('Figure 8.') and 'Visual Table' in txt:
        fig8_cap_idx = i
        if i > 0 and has_image(paras[i-1]):
            fig8_img_idx = i - 1

print(f"Figure 6 (Flowchart): img={fig6_img_idx}, cap={fig6_cap_idx}")
print(f"Figure 7 (Use Case):  img={fig7_img_idx}, cap={fig7_cap_idx}")
print(f"Figure 8 (Vis TOC):   img={fig8_img_idx}, cap={fig8_cap_idx}")
print()

# Collect paragraph objects to delete (before deleting, as indices shift)
paras_to_delete = []

for idx, label in [
    (fig6_img_idx, "Fig6 image"), (fig6_cap_idx, "Fig6 caption"),
    (fig7_img_idx, "Fig7 image"), (fig7_cap_idx, "Fig7 caption"),
    (fig8_img_idx, "Fig8 image"), (fig8_cap_idx, "Fig8 caption"),
]:
    if idx >= 0:
        paras_to_delete.append((idx, label, paras[idx]))

# Also check for a blank paragraph between fig7 and fig8 (para 311 in original)
# It's just an empty para, leave it; deleting the images/captions is enough.

# ============================================================
# STEP 2: Remove in-text references to removed figures
# ============================================================
# Find "Figure 6", "Figure 7", "Figure 8" references in body text
# Replace with descriptive text or delete the clause

removed_fig_numbers = {'6', '7', '8'}

# Map old number → replacement text for in-text references
fig_ref_replacements = {
    'Figure 6': 'the system flowchart',
    'Figure 7': 'the use case diagram',
    'Figure 8': 'the visual overview of the system',
}

print("=== Fixing in-text references to removed figures ===")
for i, p in enumerate(paras):
    text = p.text
    if not text:
        continue
    # Skip if this IS the caption (it will be deleted)
    is_caption = any(p._element is pt._element for _, _, pt in paras_to_delete)
    if is_caption:
        continue
    
    modified = text
    for fig_ref, replacement in fig_ref_replacements.items():
        # Pattern: "as seen in Figure 6", "Figure 6 shows", "(Figure 6)", "Figure 6."
        # We replace the "Figure X" reference with the replacement text
        if fig_ref in modified:
            # For patterns like "as seen in Figure 6" -> "as described by the system flowchart"
            # For "(Figure 6)" -> remove parenthetical entirely
            modified = re.sub(r'\(\s*' + re.escape(fig_ref) + r'[^)]*\)', '', modified)
            # For "as seen in Figure 6" / "shown in Figure 6"
            modified = re.sub(r'(?i)\b(as\s+seen\s+in|shown\s+in|as\s+shown\s+in|refer\s+to|see)\s+' + re.escape(fig_ref) + r'\b\.?', 
                              replacement, modified)
            # Remaining bare references
            modified = re.sub(re.escape(fig_ref) + r'\b', replacement, modified)
    
    if modified != text:
        print(f"  [{i:04d}] REPLACED ref: {text[:80]!r}")
        print(f"         -> {modified[:80]!r}")
        # Apply change to runs
        # Simplest approach: clear runs and set text on the first run
        if p.runs:
            # Preserve formatting of first run, set full text there
            full_new_text = modified
            # Distribute text across runs (just put all in first run)
            for j, run in enumerate(p.runs):
                if j == 0:
                    run.text = full_new_text
                else:
                    run.text = ''
        else:
            # paragraph with no runs - add one
            from docx.oxml import OxmlElement
            r = OxmlElement('w:r')
            t = OxmlElement('w:t')
            t.text = modified
            r.append(t)
            p._element.append(r)

# ============================================================  
# STEP 3: Delete the image+caption paragraphs for removed figures
# ============================================================
print("\n=== Deleting removed figure paragraphs ===")
for idx, label, para in sorted(paras_to_delete, key=lambda x: x[0], reverse=True):
    print(f"  Deleting [{idx:04d}] {label}: {para.text.strip()[:60]!r}")
    delete_para(para)

# Refresh paragraph list after deletions
paras = doc.paragraphs
print(f"\nParagraphs after figure deletion: {len(paras)}")

# ============================================================
# STEP 4: Renumber figure captions sequentially
# ============================================================
print("\n=== Renumbering figure captions ===")

fig_caption_paras = []  # (new_number, para)
for p in paras:
    text = p.text.strip()
    if re.match(r'(?i)^figure\s+\d+[\.\s]', text):
        fig_caption_paras.append(p)

old_to_new_fig = {}
for new_num, p in enumerate(fig_caption_paras, start=1):
    old_text = p.text.strip()
    # Extract old number
    m = re.match(r'(?i)^figure\s+(\d+)', old_text)
    if m:
        old_num = m.group(1)
        old_to_new_fig[old_num] = str(new_num)
        # Build new caption text
        new_text = re.sub(r'(?i)^figure\s+\d+', f'Figure {new_num}', old_text, count=1)
        if new_text != old_text:
            # Apply to runs
            if p.runs:
                full = new_text
                for j, run in enumerate(p.runs):
                    if j == 0:
                        run.text = full
                    else:
                        run.text = ''
            print(f"  Fig caption: {old_text[:60]!r} -> {new_text[:60]!r}")

print(f"\nFigure mapping (old->new): {old_to_new_fig}")

# ============================================================
# STEP 5: Renumber table captions sequentially
# ============================================================
print("\n=== Renumbering table captions ===")

tbl_caption_paras = []
for p in paras:
    text = p.text.strip()
    if re.match(r'(?i)^table\s+\d+[\.\s]', text):
        tbl_caption_paras.append(p)

old_to_new_tbl = {}
for new_num, p in enumerate(tbl_caption_paras, start=1):
    old_text = p.text.strip()
    m = re.match(r'(?i)^table\s+(\d+)', old_text)
    if m:
        old_num = m.group(1)
        old_to_new_tbl[old_num] = str(new_num)
        new_text = re.sub(r'(?i)^table\s+\d+', f'Table {new_num}', old_text, count=1)
        if new_text != old_text:
            if p.runs:
                for j, run in enumerate(p.runs):
                    if j == 0:
                        run.text = new_text
                    else:
                        run.text = ''
            print(f"  Tbl caption: {old_text[:60]!r} -> {new_text[:60]!r}")

print(f"\nTable mapping (old->new): {old_to_new_tbl}")

# ============================================================
# STEP 6: Fix in-text figure and table references
# ============================================================
print("\n=== Updating in-text references ===")

def replace_refs_in_para(para, fig_map, tbl_map):
    """Replace Figure X and Table X references using the mapping."""
    if not para.text:
        return False
    
    changed = False
    
    # Build the full text from runs
    full_text = para.text
    new_text = full_text
    
    # Replace Figure references (old number -> new number)
    # Sort by length of old number descending to avoid partial replacements
    for old_n, new_n in sorted(fig_map.items(), key=lambda x: -len(x[0])):
        # Match "Figure X" but not "Figure X.Y" style (since we already converted all to simple)
        pattern = r'(?i)\bfigure\s+' + re.escape(old_n) + r'\b'
        replacement = f'Figure {new_n}'
        new_text2 = re.sub(pattern, replacement, new_text)
        if new_text2 != new_text:
            changed = True
            new_text = new_text2
    
    for old_n, new_n in sorted(tbl_map.items(), key=lambda x: -len(x[0])):
        pattern = r'(?i)\btable\s+' + re.escape(old_n) + r'\b'
        replacement = f'Table {new_n}'
        new_text2 = re.sub(pattern, replacement, new_text)
        if new_text2 != new_text:
            changed = True
            new_text = new_text2
    
    if changed and new_text != full_text:
        if para.runs:
            for j, run in enumerate(para.runs):
                if j == 0:
                    run.text = new_text
                else:
                    run.text = ''
        return True
    return False

ref_update_count = 0
for p in paras:
    if replace_refs_in_para(p, old_to_new_fig, old_to_new_tbl):
        ref_update_count += 1

print(f"Updated {ref_update_count} paragraphs with in-text reference fixes")

# ============================================================
# STEP 7: Regenerate List of Figures
# ============================================================
print("\n=== Regenerating List of Figures ===")

# Find LoF header and LoT header to know the range to clear
lof_start = -1
lot_start = -1
lof_header_para = None

for i, p in enumerate(paras):
    txt = p.text.strip()
    if txt == 'LIST OF FIGURES':
        lof_start = i
        lof_header_para = p
    elif txt == 'LIST OF TABLES':
        lot_start = i

print(f"List of Figures at para {lof_start}, List of Tables at para {lot_start}")

# Delete existing LoF entries (between LIST OF FIGURES and LIST OF TABLES)
# but keep the header paragraphs themselves
if lof_start >= 0 and lot_start >= 0:
    # Collect paras between lof_start and lot_start (exclusive, excluding header rows)
    # We keep: "LIST OF FIGURES" header, the "Figure No. / Figure Name / Page" header row
    # We delete: all figure entries
    paras_to_delete_lof = []
    for p in paras[lof_start+1:lot_start]:
        txt = p.text.strip()
        # Keep the column header row
        if txt.startswith('Figure No.') or txt.startswith('Figure No'):
            continue
        if re.match(r'(?i)^figure\s+\d+', txt):
            paras_to_delete_lof.append(p)
    
    for p in paras_to_delete_lof:
        delete_para(p)
    
    print(f"  Deleted {len(paras_to_delete_lof)} old LoF entries")

# Refresh paras
paras = doc.paragraphs

# Find the "Figure No." header row in LoF to insert after it
lof_header_row = None
for i, p in enumerate(paras):
    if p.text.strip().startswith('Figure No.') or p.text.strip() == 'Figure No.\t\t\tFigure Name\t\t\t\tPage':
        # Check it's in the LoF section
        lof_start2 = -1
        lot_start2 = -1
        for j, pp in enumerate(paras):
            if pp.text.strip() == 'LIST OF FIGURES':
                lof_start2 = j
            elif pp.text.strip() == 'LIST OF TABLES':
                lot_start2 = j
        if lof_start2 <= i < lot_start2:
            lof_header_row = p
            break

# Build new LoF entries from actual figure captions in the body
# Figure captions in body (not in the LoF/LoT section)
lof_entries = []
in_lof_lot = False
lof_range_start = -1
lot_range_end = -1

for i, p in enumerate(paras):
    if p.text.strip() == 'LIST OF FIGURES':
        lof_range_start = i
    elif p.text.strip() == 'LIST OF TABLES':
        lot_range_end = i

# Collect figure captions that are NOT in the LoF/LoT section
for i, p in enumerate(paras):
    if lof_range_start <= i <= lot_range_end:
        continue  # skip LoF/LoT area
    txt = p.text.strip()
    if re.match(r'(?i)^figure\s+\d+[\.\s]', txt):
        # Skip description paragraphs like "Figure 9 shows..."
        m = re.match(r'(?i)^(figure\s+\d+)\s*[\.\:]\s*(.+)', txt)
        if m:
            lof_entries.append((m.group(1).strip(), m.group(2).strip()))

print(f"  Found {len(lof_entries)} body figure captions for LoF")

# Insert new LoF entries after the header row
# Use the same style as the header row or "normal"
if lof_header_row:
    insert_after_elem = lof_header_row._element
    for fig_num, fig_title in reversed(lof_entries):
        entry_text = f"{fig_num}.\t{fig_title}"
        # Create new paragraph
        from docx.oxml import OxmlElement
        new_p = OxmlElement('w:p')
        # Copy paragraph properties from header row (style)
        pPr = lof_header_row._element.find(_qn('w:pPr'))
        if pPr is not None:
            new_pPr = copy.deepcopy(pPr)
            new_p.append(new_pPr)
        # Add run with text
        new_r = OxmlElement('w:r')
        new_t = OxmlElement('w:t')
        new_t.text = entry_text
        new_t.set('{http://www.w3.org/XML/1998/namespace}space', 'preserve')
        new_r.append(new_t)
        new_p.append(new_r)
        # Insert after header
        insert_after_elem.addnext(new_p)
    print(f"  Inserted {len(lof_entries)} new LoF entries")

# ============================================================
# STEP 8: Regenerate List of Tables
# ============================================================
print("\n=== Regenerating List of Tables ===")

# Refresh paras
paras = doc.paragraphs

lot_start3 = -1
for i, p in enumerate(paras):
    if p.text.strip() == 'LIST OF TABLES':
        lot_start3 = i

# Find "Chapter I" or "Chapter" section that comes after LoT
# The LoT ends at "Chapter I" or similar
lot_end = -1
for i, p in enumerate(paras[lot_start3+1:], start=lot_start3+1):
    txt = p.text.strip()
    if txt in ('Chapter I', 'Chapter I\n', 'Chapter 1') or txt.startswith('Chapter I') and not txt.startswith('Chapter I:'):
        lot_end = i
        break
    # Also stop at "INTRODUCTION" heading
    if txt == 'INTRODUCTION' and i > lot_start3 + 5:
        lot_end = i
        break

# If not found, find the first "Chapter" paragraph after LoT
if lot_end < 0:
    for i, p in enumerate(paras[lot_start3+1:], start=lot_start3+1):
        txt = p.text.strip()
        if txt.startswith('Chapter') and i > lot_start3 + 3:
            lot_end = i
            break

print(f"LoT range: para {lot_start3} to {lot_end}")

# Delete existing LoT entries
paras_to_delete_lot = []
lot_header_row = None
for p in paras[lot_start3+1:lot_end if lot_end > 0 else lot_start3+30]:
    txt = p.text.strip()
    if txt.startswith('Table No.'):
        lot_header_row = p
        continue
    if re.match(r'(?i)^table\s+\d+', txt):
        paras_to_delete_lot.append(p)

for p in paras_to_delete_lot:
    delete_para(p)

print(f"  Deleted {len(paras_to_delete_lot)} old LoT entries")

# Refresh
paras = doc.paragraphs
lot_start4 = -1
for i, p in enumerate(paras):
    if p.text.strip() == 'LIST OF TABLES':
        lot_start4 = i

# Find LoT header row again
lot_header_row2 = None
for p in paras[lot_start4:lot_start4+10]:
    if p.text.strip().startswith('Table No.'):
        lot_header_row2 = p
        break

# Collect table captions from body (not in LoF/LoT area)
# Find LoF/LoT range
lof_s = lot_s = -1
for i, p in enumerate(paras):
    if p.text.strip() == 'LIST OF FIGURES': lof_s = i
    elif p.text.strip() == 'LIST OF TABLES': lot_s = i

# Find end of LoT area (body starts)
lot_end2 = -1
for i, p in enumerate(paras[lot_s+1:], start=lot_s+1):
    if p.text.strip().startswith('Chapter') or p.text.strip() == 'INTRODUCTION':
        lot_end2 = i
        break

lot_body_entries = []
for i, p in enumerate(paras):
    if lof_s <= i <= (lot_end2 if lot_end2 > 0 else lot_s+30):
        continue
    txt = p.text.strip()
    if re.match(r'(?i)^table\s+\d+[\.\s]', txt):
        m = re.match(r'(?i)^(table\s+\d+)\s*[\.\:]\s*(.+)', txt)
        if m:
            lot_body_entries.append((m.group(1).strip(), m.group(2).strip()))

print(f"  Found {len(lot_body_entries)} body table captions for LoT")

if lot_header_row2:
    insert_after_elem = lot_header_row2._element
    from docx.oxml import OxmlElement
    for tbl_num, tbl_title in reversed(lot_body_entries):
        entry_text = f"{tbl_num}.\t{tbl_title}"
        new_p = OxmlElement('w:p')
        pPr = lot_header_row2._element.find(_qn('w:pPr'))
        if pPr is not None:
            new_pPr = copy.deepcopy(pPr)
            new_p.append(new_pPr)
        new_r = OxmlElement('w:r')
        new_t = OxmlElement('w:t')
        new_t.text = entry_text
        new_t.set('{http://www.w3.org/XML/1998/namespace}space', 'preserve')
        new_r.append(new_t)
        new_p.append(new_r)
        insert_after_elem.addnext(new_p)
    print(f"  Inserted {len(lot_body_entries)} new LoT entries")

# ============================================================
# STEP 9: Save the document
# ============================================================
doc.save(DOC_PATH)
print(f"\n=== Document saved to {DOC_PATH} ===")
print(f"Final paragraph count: {len(doc.paragraphs)}")

# ============================================================
# STEP 10: Print summary for report
# ============================================================
print("\n=== SUMMARY ===")
print(f"Figures REMOVED:")
print(f"  - Figure 6: SmartSpend System Flowchart")
print(f"  - Figure 7: Use Case Diagram")  
print(f"  - Figure 8: Visual Table of Contents")
print(f"\nFigure mapping (old->new): {old_to_new_fig}")
print(f"Table mapping (old->new): {old_to_new_tbl}")
print(f"\nLoF entries: {lof_entries}")
print(f"LoT entries: {lot_body_entries}")
