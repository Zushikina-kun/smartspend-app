"""
Fix table numbering: body tables are currently 10-17, should be 1-8.
Also fix LoT entries, in-text references, and description paras.
"""
import re
import copy
from docx import Document
from docx.oxml.ns import qn as _qn
from lxml import etree

DOC_PATH = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx"
doc = Document(DOC_PATH)

def set_para_text(para, new_text):
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

paras = doc.paragraphs

# Find LoT area
lot_idx = -1
for i, p in enumerate(paras):
    if p.text.strip() == 'LIST OF TABLES':
        lot_idx = i

lot_end = -1
for i in range(lot_idx+1, min(lot_idx+20, len(paras))):
    t = paras[i].text.strip()
    if t.startswith('Chapter') or t == 'INTRODUCTION':
        lot_end = i
        break

print(f"LoT at {lot_idx}, ends at {lot_end}")

# Build correction map: current number -> correct number
# Body tables are currently 10-17, need to be 1-8
correction_map = {str(i): str(i-9) for i in range(10, 18)}
print(f"Correction map: {correction_map}")

# 1. Fix body table captions (Table 10. -> Table 1.)
print("\n=== Fixing body table captions ===")
for i, p in enumerate(paras):
    if lot_idx <= i <= lot_end:
        continue  # skip LoT section for now
    txt = p.text.strip()
    m = re.match(r'(?i)^table\s+(\d+)\.\s{1,}(.+)', txt)
    if m and m.group(1) in correction_map:
        old_n = m.group(1)
        new_n = correction_map[old_n]
        new_txt = re.sub(r'(?i)^table\s+' + re.escape(old_n) + r'\.', f'Table {new_n}.', txt, count=1)
        set_para_text(p, new_txt)
        print(f"  [{i:04d}] Table {old_n} -> Table {new_n}: {m.group(2)[:50]!r}")

# 2. Fix table description paragraphs (Table 14 presented... -> Table 4 presented...)
print("\n=== Fixing table description paragraphs ===")
paras = doc.paragraphs
for i, p in enumerate(paras):
    if lot_idx <= i <= lot_end:
        continue
    txt = p.text.strip()
    m = re.match(r'(?i)^table\s+(\d+)\s+(presented|shows|displays|summarizes|indicates)', txt)
    if m and m.group(1) in correction_map:
        old_n = m.group(1)
        new_n = correction_map[old_n]
        new_txt = re.sub(r'(?i)^table\s+' + re.escape(old_n) + r'\b', f'Table {new_n}', txt, count=1)
        set_para_text(p, new_txt)
        print(f"  [{i:04d}] Table {old_n} -> Table {new_n} (description)")

# 3. Fix in-text references to tables in body
print("\n=== Fixing in-text table references ===")
paras = doc.paragraphs
count = 0
for i, p in enumerate(paras):
    if lot_idx <= i <= lot_end:
        continue
    txt = p.text
    if not txt:
        continue
    # Skip captions
    stripped = txt.strip()
    if re.match(r'(?i)^table\s+\d+[\.\t]', stripped):
        continue
    if re.match(r'(?i)^table\s+\d+\s+(presented|shows|displays)', stripped):
        continue
    
    modified = txt
    for old_n in sorted(correction_map.keys(), key=lambda x: -len(x)):
        new_n = correction_map[old_n]
        pattern = r'(?i)\b[Tt]able\s+' + re.escape(old_n) + r'\b'
        modified = re.sub(pattern, f'Table {new_n}', modified)
    
    if modified != txt:
        set_para_text(p, modified)
        count += 1
        print(f"  [{i:04d}] {txt.strip()[:70]!r}")
        print(f"         -> {modified.strip()[:70]!r}")

print(f"Updated {count} in-text reference paragraphs")

# 4. Update LoT entries
print("\n=== Updating LoT entries ===")
paras = doc.paragraphs
# Re-locate LoT
lot_idx2 = -1
for i, p in enumerate(paras):
    if p.text.strip() == 'LIST OF TABLES':
        lot_idx2 = i

for i in range(lot_idx2+1, min(lot_idx2+20, len(paras))):
    p = paras[i]
    txt = p.text.strip()
    if not txt:
        continue
    if txt.startswith('Chapter') or txt == 'INTRODUCTION':
        break
    m = re.match(r'(?i)^(table\s+(\d+))\.(.*)', txt)
    if m and m.group(2) in correction_map:
        old_n = m.group(2)
        new_n = correction_map[old_n]
        new_txt = f'Table {new_n}.{m.group(3)}'
        set_para_text(p, new_txt)
        print(f"  [{i:04d}] LoT: Table {old_n} -> Table {new_n}")

# Save
doc.save(DOC_PATH)
print(f"\n=== Saved. Paragraphs: {len(doc.paragraphs)} ===")

# Verify
doc2 = Document(DOC_PATH)
paras2 = doc2.paragraphs
lot_idx3 = -1
for i, p in enumerate(paras2):
    if p.text.strip() == 'LIST OF TABLES':
        lot_idx3 = i

print("\n=== LoT VERIFICATION ===")
for i in range(lot_idx3, min(lot_idx3+15, len(paras2))):
    t = paras2[i].text.strip()
    if t:
        print(f"  [{i:04d}] {t[:90]!r}")

print("\n=== All Table captions in body ===")
for i, p in enumerate(paras2):
    t = p.text.strip()
    if re.match(r'(?i)^table\s+\d+', t):
        print(f"  [{i:04d}] {t[:90]!r}")
