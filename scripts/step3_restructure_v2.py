"""
Step 3–4 (v2): Apply restructuring to SmartSpend FINAL manuscript.

KEY CHANGES FROM v1:
- Distinguish captions (Figure N.  Title) from descriptions (Figure N shows...)
- Only treat body captions (not LoF list entries, not descriptions) as the
  authoritative caption sequence
- Description paragraphs get their "Figure N" prefix updated to match the new
  caption number, not renumbered as new captions
- Fix LoF list entries in-place (they use tab-separated format)

ACTIONS:
1. Remove Figure 6 (Flowchart), Figure 7 (Use Case), Figure 8 (Visual TOC)
   — their body image+caption pairs
2. Update in-text "Figure 6/7/8" references to descriptive text
3. Renumber all BODY figure captions sequentially (1, 2, 3...)
4. Update matching description paragraphs to use the new figure number
5. Renumber all TABLE captions sequentially (1, 2, 3...)
6. Update all in-text "Figure N" and "Table N" references
7. Regenerate LoF and LoT from the new body captions
8. Save once
"""

import re
import copy
from docx import Document
from docx.oxml.ns import qn as _qn
from lxml import etree

DOC_PATH = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx"

doc = Document(DOC_PATH)

# ------------------------------------------------------------------ helpers
def has_image(para):
    xml_str = etree.tostring(para._element, encoding='unicode')
    return 'w:drawing' in xml_str or 'w:pict' in xml_str or 'a:blip' in xml_str

def delete_para(para):
    p = para._element
    parent = p.getparent()
    if parent is not None:
        parent.remove(p)
    else:
        print(f"  WARNING: could not remove para (no parent): {para.text[:60]!r}")

def is_body_caption(text):
    """True if para is a figure caption in body style: 'Figure N.  Title' (period+spaces)."""
    return bool(re.match(r'(?i)^figure\s+(\d+)\.\s{1,}[A-Z\S]', text))

def is_lof_entry(text):
    """True if para is a LoF list entry: 'Figure N.\tTitle' (tab after period)."""
    return bool(re.match(r'(?i)^figure\s+\d+\.\t', text))

def is_description(text):
    """True if para is a figure description paragraph: 'Figure N shows/presents...'."""
    return bool(re.match(r'(?i)^figure\s+\d+\s+(shows|presents|displays|illustrates|depicts)', text))

def set_para_text(para, new_text):
    """Replace all run text in a paragraph with new_text, preserving formatting of first run."""
    if para.runs:
        for j, run in enumerate(para.runs):
            if j == 0:
                run.text = new_text
            else:
                run.text = ''
    else:
        from docx.oxml import OxmlElement
        r = OxmlElement('w:r')
        t = OxmlElement('w:t')
        t.text = new_text
        t.set('{http://www.w3.org/XML/1998/namespace}space', 'preserve')
        r.append(t)
        para._element.append(r)

# ============================================================
# STEP 1: Find and remove Figure 6, 7, 8 body image+caption pairs
# ============================================================
print("=== STEP 1: Finding body image+caption pairs to remove ===")

# Identify body captions for Figures 6, 7, 8
removed_figs = {}  # old_num -> (img_para, cap_para, title)
paras_to_delete = []  # (original_text_for_logging, para_object)

for i, p in enumerate(doc.paragraphs):
    txt = p.text.strip()
    m = re.match(r'(?i)^figure\s+(\d+)\.\s{1,}(.+)', txt)
    if m and m.group(1) in ('6', '7', '8'):
        old_num = m.group(1)
        title = m.group(2).strip()
        cap_para = p
        # Image paragraph is immediately before the caption
        img_para = None
        if i > 0 and has_image(doc.paragraphs[i-1]):
            img_para = doc.paragraphs[i-1]
        removed_figs[old_num] = {'img': img_para, 'cap': cap_para, 'title': title}
        print(f"  Found Figure {old_num}: '{title[:60]}' (cap para {i}, has_img={img_para is not None})")

print(f"\nFigures to remove: {list(removed_figs.keys())}")

# Mark for deletion
paras_to_delete_objs = []
for num, d in removed_figs.items():
    if d['img']:
        paras_to_delete_objs.append(d['img'])
        print(f"  → Mark IMG for Figure {num}")
    paras_to_delete_objs.append(d['cap'])
    print(f"  → Mark CAP for Figure {num}: {d['cap'].text.strip()[:60]!r}")

# ============================================================
# STEP 2: Fix in-text references to removed figures BEFORE deleting
# ============================================================
print("\n=== STEP 2: Fixing in-text references to removed figures ===")

fig_ref_replacements = {
    '6': 'the system flowchart',
    '7': 'the use case diagram',
    '8': 'the visual overview of the system',
}

for p in doc.paragraphs:
    # Skip paragraphs that will be deleted
    if p in paras_to_delete_objs:
        continue
    txt = p.text
    if not txt:
        continue
    
    # Skip LoF entries (they'll be replaced wholesale)
    if is_lof_entry(txt.strip()):
        continue
    
    modified = txt
    for num, replacement in fig_ref_replacements.items():
        # Remove parenthetical "(Figure N)" or "(see Figure N)"
        modified = re.sub(r'\(\s*(?:see\s+)?[Ff]igure\s+' + num + r'[^)]*\)', '', modified)
        # Replace "as seen in Figure N" / "shown in Figure N" / "see Figure N"
        modified = re.sub(
            r'(?i)\b(as\s+seen\s+in|shown\s+in|as\s+shown\s+in|see|refer\s+to)\s+[Ff]igure\s+' + num + r'\b\.?',
            replacement, modified
        )
        # Replace remaining bare "Figure N"
        modified = re.sub(r'(?i)\b[Ff]igure\s+' + num + r'\b', replacement, modified)
    
    modified = modified.strip()
    if modified != txt.strip():
        print(f"  Para: {txt.strip()[:80]!r}")
        print(f"    ->  {modified[:80]!r}")
        set_para_text(p, modified)

# ============================================================
# STEP 3: Delete the image+caption paragraphs
# ============================================================
print("\n=== STEP 3: Deleting removed figure paragraphs ===")
for p in paras_to_delete_objs:
    print(f"  Deleting: {p.text.strip()[:70]!r}")
    delete_para(p)

print(f"\nParagraphs after deletion: {len(doc.paragraphs)}")

# ============================================================
# STEP 4: Collect body captions in document order and assign new numbers
# ============================================================
print("\n=== STEP 4: Building sequential figure numbering ===")

# Body captions are those matching "Figure N.  Title" (not in LoF/LoT area)
# LoF area: between "LIST OF FIGURES" and "LIST OF TABLES"
paras_now = doc.paragraphs

lof_range_start = -1
lot_range_start = -1
for i, p in enumerate(paras_now):
    txt = p.text.strip()
    if txt == 'LIST OF FIGURES':
        lof_range_start = i
    elif txt == 'LIST OF TABLES':
        lot_range_start = i

print(f"LoF section: paras {lof_range_start} to {lot_range_start}")

body_captions = []  # (para_index, para_object, old_fig_num, title)
for i, p in enumerate(paras_now):
    if lof_range_start <= i <= lot_range_start:
        continue  # skip LoF/LoT list section
    txt = p.text.strip()
    m = re.match(r'(?i)^figure\s+(\d+)\.\s{1,}(.+)', txt)
    if m:
        body_captions.append((i, p, m.group(1), m.group(2).strip()))

print(f"Found {len(body_captions)} body figure captions:")
for idx, p, old_n, title in body_captions:
    print(f"  [{idx:04d}] Figure {old_n}: {title[:60]!r}")

# Build old->new mapping (by order of appearance in document)
old_to_new_fig = {}
for new_num, (idx, p, old_n, title) in enumerate(body_captions, start=1):
    old_to_new_fig[old_n] = str(new_num)

print(f"\nFigure mapping: {old_to_new_fig}")

# ============================================================
# STEP 5: Apply new numbers to body captions
# ============================================================
print("\n=== STEP 5: Updating body figure captions ===")
for new_num, (idx, p, old_n, title) in enumerate(body_captions, start=1):
    old_txt = p.text.strip()
    new_txt = re.sub(r'(?i)^figure\s+' + re.escape(old_n) + r'\.', f'Figure {new_num}.', old_txt, count=1)
    if new_txt != old_txt:
        set_para_text(p, new_txt)
        print(f"  [{idx:04d}] Figure {old_n} -> Figure {new_num}: {title[:50]!r}")

# ============================================================
# STEP 6: Update description paragraphs (Figure N shows/presents...)
# ============================================================
print("\n=== STEP 6: Updating figure description paragraphs ===")
paras_now = doc.paragraphs
for i, p in enumerate(paras_now):
    txt = p.text.strip()
    m = re.match(r'(?i)^figure\s+(\d+)\s+(shows|presents|displays|illustrates|depicts)', txt)
    if m:
        old_n = m.group(1)
        verb = m.group(2)
        if old_n in old_to_new_fig:
            new_n = old_to_new_fig[old_n]
            new_txt = re.sub(r'(?i)^figure\s+' + re.escape(old_n) + r'\b', f'Figure {new_n}', txt, count=1)
            set_para_text(p, new_txt)
            print(f"  [{i:04d}] Figure {old_n} -> Figure {new_n} (description)")
        elif old_n not in old_to_new_fig:
            print(f"  [{i:04d}] WARNING: description Figure {old_n} has no mapping")

# ============================================================
# STEP 7: Renumber table captions sequentially
# ============================================================
print("\n=== STEP 7: Renumbering table captions ===")

paras_now = doc.paragraphs
body_tbl_captions = []
for i, p in enumerate(paras_now):
    if lof_range_start <= i <= lot_range_start:
        continue
    txt = p.text.strip()
    m = re.match(r'(?i)^table\s+(\d+)\.\s{1,}(.+)', txt)
    if m:
        body_tbl_captions.append((i, p, m.group(1), m.group(2).strip()))
    # Also handle "Table N presented/shows..." description style
    # (SmartSpend has e.g. "Table 6 presented the demographic profile...")
    # These are description paras, NOT captions

old_to_new_tbl = {}
for new_num, (idx, p, old_n, title) in enumerate(body_tbl_captions, start=1):
    old_to_new_tbl[old_n] = str(new_num)

print(f"Table mapping: {old_to_new_tbl}")

for new_num, (idx, p, old_n, title) in enumerate(body_tbl_captions, start=1):
    old_txt = p.text.strip()
    new_txt = re.sub(r'(?i)^table\s+' + re.escape(old_n) + r'\.', f'Table {new_num}.', old_txt, count=1)
    if new_txt != old_txt:
        set_para_text(p, new_txt)
        print(f"  [{idx:04d}] Table {old_n} -> Table {new_num}: {title[:50]!r}")

# ============================================================
# STEP 8: Update table description paragraphs (Table N presented/shows...)
# ============================================================
print("\n=== STEP 8: Updating table description paragraphs ===")
paras_now = doc.paragraphs
for i, p in enumerate(paras_now):
    txt = p.text.strip()
    m = re.match(r'(?i)^table\s+(\d+)\s+(presented|shows|displays|summarizes|indicates)', txt)
    if m:
        old_n = m.group(1)
        if old_n in old_to_new_tbl:
            new_n = old_to_new_tbl[old_n]
            new_txt = re.sub(r'(?i)^table\s+' + re.escape(old_n) + r'\b', f'Table {new_n}', txt, count=1)
            set_para_text(p, new_txt)
            print(f"  [{i:04d}] Table {old_n} -> Table {new_n} (description)")

# ============================================================
# STEP 9: Fix all in-text "Figure N" and "Table N" references in body
# ============================================================
print("\n=== STEP 9: Updating all in-text figure/table references ===")

paras_now = doc.paragraphs
ref_count = 0

for i, p in enumerate(paras_now):
    txt = p.text
    if not txt:
        continue
    # Skip LoF/LoT list entries (we'll regenerate those)
    if lof_range_start <= i <= lot_range_start:
        continue
    # Skip captions and description paras (already handled)
    stripped = txt.strip()
    if is_body_caption(stripped) or is_description(stripped):
        continue
    if re.match(r'(?i)^table\s+\d+\.\s{1,}', stripped):
        continue
    
    modified = txt
    
    # Replace Figure references (sorted by length to avoid partial matches)
    for old_n in sorted(old_to_new_fig.keys(), key=lambda x: -len(x)):
        new_n = old_to_new_fig[old_n]
        # Must match whole word: "Figure 10" not "Figure 100"
        pattern = r'(?i)\b[Ff]igure\s+' + re.escape(old_n) + r'\b'
        modified = re.sub(pattern, f'Figure {new_n}', modified)
    
    # Replace Table references
    for old_n in sorted(old_to_new_tbl.keys(), key=lambda x: -len(x)):
        new_n = old_to_new_tbl[old_n]
        pattern = r'(?i)\b[Tt]able\s+' + re.escape(old_n) + r'\b'
        modified = re.sub(pattern, f'Table {new_n}', modified)
    
    if modified != txt:
        set_para_text(p, modified)
        ref_count += 1
        if len(modified) < 200:
            print(f"  [{i:04d}] {txt.strip()[:60]!r}")
            print(f"         -> {modified.strip()[:60]!r}")

print(f"\nUpdated {ref_count} in-text reference paragraphs")

# ============================================================
# STEP 10: Regenerate List of Figures in LoF section
# ============================================================
print("\n=== STEP 10: Regenerating List of Figures ===")

paras_now = doc.paragraphs

# Re-locate LoF and LoT
lof_idx = lot_idx = -1
for i, p in enumerate(paras_now):
    t = p.text.strip()
    if t == 'LIST OF FIGURES':
        lof_idx = i
    elif t == 'LIST OF TABLES':
        lot_idx = i

print(f"  LoF at {lof_idx}, LoT at {lot_idx}")

# Delete existing LoF figure entries (but keep the header "Figure No.  Figure Name  Page")
lof_col_header = None
to_del_lof = []
for i in range(lof_idx+1, lot_idx):
    p = paras_now[i]
    t = p.text.strip()
    if 'Figure No' in t:
        lof_col_header = p
    elif re.match(r'(?i)^figure\s+\d+', t):
        to_del_lof.append(p)

for p in to_del_lof:
    delete_para(p)
print(f"  Deleted {len(to_del_lof)} old LoF entries")

# Refresh
paras_now = doc.paragraphs
lof_idx = -1
for i, p in enumerate(paras_now):
    if p.text.strip() == 'LIST OF FIGURES':
        lof_idx = i
# Re-find col header
lof_col_header = None
for i in range(lof_idx+1, lof_idx+10):
    if i < len(paras_now) and 'Figure No' in paras_now[i].text:
        lof_col_header = paras_now[i]
        break

# Build ordered list of body captions (now using updated numbers)
paras_now = doc.paragraphs
lof_range_start2 = lot_range_start2 = -1
for i, p in enumerate(paras_now):
    t = p.text.strip()
    if t == 'LIST OF FIGURES': lof_range_start2 = i
    elif t == 'LIST OF TABLES': lot_range_start2 = i

new_lof_entries = []
for i, p in enumerate(paras_now):
    if lof_range_start2 <= i <= lot_range_start2:
        continue
    txt = p.text.strip()
    m = re.match(r'(?i)^(figure\s+\d+)\.\s{1,}(.+)', txt)
    if m:
        new_lof_entries.append((m.group(1), m.group(2)))

print(f"  Inserting {len(new_lof_entries)} LoF entries")

# Insert new LoF entries after the column header
if lof_col_header:
    from docx.oxml import OxmlElement
    insert_anchor = lof_col_header._element
    for fig_label, fig_title in reversed(new_lof_entries):
        entry_text = f"{fig_label}.\t{fig_title}"
        new_p_elem = OxmlElement('w:p')
        # Copy pPr from col header
        col_pPr = lof_col_header._element.find(_qn('w:pPr'))
        if col_pPr is not None:
            new_p_elem.append(copy.deepcopy(col_pPr))
        # Copy rPr from first run of col header
        col_runs = lof_col_header._element.findall('.//' + _qn('w:r'))
        rPr = None
        if col_runs:
            rPr = col_runs[0].find(_qn('w:rPr'))
        new_r = OxmlElement('w:r')
        if rPr is not None:
            new_r.append(copy.deepcopy(rPr))
        new_t = OxmlElement('w:t')
        new_t.text = entry_text
        new_t.set('{http://www.w3.org/XML/1998/namespace}space', 'preserve')
        new_r.append(new_t)
        new_p_elem.append(new_r)
        insert_anchor.addnext(new_p_elem)
    print(f"  Inserted {len(new_lof_entries)} new LoF entries")
else:
    print("  WARNING: could not find LoF column header")

for fig_label, fig_title in new_lof_entries:
    print(f"    {fig_label}: {fig_title[:60]!r}")

# ============================================================
# STEP 11: Regenerate List of Tables
# ============================================================
print("\n=== STEP 11: Regenerating List of Tables ===")

paras_now = doc.paragraphs
lot_idx2 = -1
for i, p in enumerate(paras_now):
    if p.text.strip() == 'LIST OF TABLES':
        lot_idx2 = i

# Find end of LoT area (next "Chapter" or body heading)
lot_end2 = -1
for i in range(lot_idx2+1, min(lot_idx2+40, len(paras_now))):
    t = paras_now[i].text.strip()
    if t.startswith('Chapter') or t == 'INTRODUCTION' or t == 'Chapter I':
        lot_end2 = i
        break

# Delete existing LoT table entries
lot_col_header = None
to_del_lot = []
for i in range(lot_idx2+1, lot_end2 if lot_end2 > 0 else lot_idx2+30):
    p = paras_now[i]
    t = p.text.strip()
    if 'Table No' in t:
        lot_col_header = p
    elif re.match(r'(?i)^table\s+\d+', t):
        to_del_lot.append(p)

for p in to_del_lot:
    delete_para(p)
print(f"  Deleted {len(to_del_lot)} old LoT entries")

# Refresh
paras_now = doc.paragraphs
lot_idx3 = -1
for i, p in enumerate(paras_now):
    if p.text.strip() == 'LIST OF TABLES':
        lot_idx3 = i

lot_col_header2 = None
for i in range(lot_idx3+1, lot_idx3+15):
    if i < len(paras_now) and 'Table No' in paras_now[i].text:
        lot_col_header2 = paras_now[i]
        break

# Collect body table captions (updated)
paras_now = doc.paragraphs
lof_s3 = lot_s3 = -1
for i, p in enumerate(paras_now):
    t = p.text.strip()
    if t == 'LIST OF FIGURES': lof_s3 = i
    elif t == 'LIST OF TABLES': lot_s3 = i

lot_end3 = -1
for i in range(lot_s3+1, min(lot_s3+40, len(paras_now))):
    t = paras_now[i].text.strip()
    if t.startswith('Chapter') or t == 'INTRODUCTION':
        lot_end3 = i
        break

new_lot_entries = []
for i, p in enumerate(paras_now):
    if lof_s3 <= i <= (lot_end3 if lot_end3 > 0 else lot_s3+30):
        continue
    txt = p.text.strip()
    m = re.match(r'(?i)^(table\s+\d+)\.\s{1,}(.+)', txt)
    if m:
        new_lot_entries.append((m.group(1), m.group(2)))

print(f"  Inserting {len(new_lot_entries)} LoT entries")

if lot_col_header2:
    from docx.oxml import OxmlElement
    insert_anchor = lot_col_header2._element
    for tbl_label, tbl_title in reversed(new_lot_entries):
        entry_text = f"{tbl_label}.\t{tbl_title}"
        new_p_elem = OxmlElement('w:p')
        col_pPr = lot_col_header2._element.find(_qn('w:pPr'))
        if col_pPr is not None:
            new_p_elem.append(copy.deepcopy(col_pPr))
        col_runs = lot_col_header2._element.findall('.//' + _qn('w:r'))
        rPr = None
        if col_runs:
            rPr = col_runs[0].find(_qn('w:rPr'))
        new_r = OxmlElement('w:r')
        if rPr is not None:
            new_r.append(copy.deepcopy(rPr))
        new_t = OxmlElement('w:t')
        new_t.text = entry_text
        new_t.set('{http://www.w3.org/XML/1998/namespace}space', 'preserve')
        new_r.append(new_t)
        new_p_elem.append(new_r)
        insert_anchor.addnext(new_p_elem)
    print(f"  Inserted {len(new_lot_entries)} new LoT entries")

for tbl_label, tbl_title in new_lot_entries:
    print(f"    {tbl_label}: {tbl_title[:60]!r}")

# ============================================================
# STEP 12: Save the document
# ============================================================
doc.save(DOC_PATH)
print(f"\n=== Saved to {DOC_PATH} ===")
print(f"Final paragraph count: {len(doc.paragraphs)}")

# ============================================================
# PRINT FULL SUMMARY
# ============================================================
print("\n" + "="*60)
print("RESTRUCTURING SUMMARY")
print("="*60)
print("\nFIGURES REMOVED:")
for n, d in removed_figs.items():
    print(f"  - Figure {n}: {d['title']}")

print(f"\nFIGURE MAPPING (old -> new):")
for old, new in sorted(old_to_new_fig.items(), key=lambda x: int(x[0])):
    print(f"  {old} -> {new}")

print(f"\nTABLE MAPPING (old -> new):")
for old, new in sorted(old_to_new_tbl.items(), key=lambda x: int(x[0])):
    print(f"  {old} -> {new}")

print(f"\nFINAL LIST OF FIGURES ({len(new_lof_entries)} entries):")
for lbl, ttl in new_lof_entries:
    print(f"  {lbl}: {ttl[:70]}")

print(f"\nFINAL LIST OF TABLES ({len(new_lot_entries)} entries):")
for lbl, ttl in new_lot_entries:
    print(f"  {lbl}: {ttl[:70]}")
