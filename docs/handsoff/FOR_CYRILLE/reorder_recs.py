"""Reorder recommendation paragraphs physically in the document XML."""
import shutil, copy
from docx import Document
from lxml import etree

DOCX = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'
shutil.copy(DOCX, DOCX + '.reorder.backup')
doc = Document(DOCX)

# Find the 8 recommendation paragraphs by number prefix
rec_map = {}  # number -> paragraph index
in_recs = False
for i, para in enumerate(doc.paragraphs):
    t = para.text.strip()
    if 'Recommendations' in t and 'In view' not in t and i > 390 and i < 420:
        in_recs = True
        continue
    if in_recs:
        if 'References' in t and i > 400: break
        if not t: continue
        import re
        m = re.match(r'^(\d+)\. ', t)
        if m:
            num = int(m.group(1))
            rec_map[num] = i
            print(f'  Rec {num} at para {i}: {t[:60]}')

print(f'\nFound {len(rec_map)} recs: {sorted(rec_map.keys())}')

# Check if already in order
indices = [rec_map[k] for k in sorted(rec_map.keys())]
if indices == sorted(indices):
    print('Already in correct order!')
else:
    print(f'Out of order: {indices}')
    # Reorder paragraphs in the document body XML
    body = doc.element.body
    # Get the actual paragraph elements in correct order (1,2,3,4,5,6,7,8)
    ordered_p_elements = []
    for num in sorted(rec_map.keys()):
        idx = rec_map[num]
        p_elem = doc.paragraphs[idx]._p
        ordered_p_elements.append((num, p_elem))

    # Find the first rec para position in the body
    first_rec_p = doc.paragraphs[indices[0]]._p
    first_rec_parent = first_rec_p.getparent()
    first_rec_pos = list(first_rec_parent).index(first_rec_p)

    # Remove all rec paragraphs from their current positions
    for num, p_elem in ordered_p_elements:
        p_elem.getparent().remove(p_elem)

    # Re-insert them in correct order at the original first position
    # Need to find insertion point again (after removal, positions shifted)
    # Find the "In view of the results" intro paragraph
    insert_after = None
    for i, para in enumerate(doc.paragraphs):
        if 'In view of the results' in para.text:
            insert_after = para._p
            break

    if insert_after is not None:
        parent = insert_after.getparent()
        insert_pos = list(parent).index(insert_after) + 1
        for num, p_elem in reversed(ordered_p_elements):
            parent.insert(insert_pos, p_elem)
        print('Reordered successfully')
    else:
        print('ERROR: Could not find insertion point')

doc.save(DOCX)

# Verify
doc2 = Document(DOCX)
print('\nFinal order:')
in_recs = False
for i, p in enumerate(doc2.paragraphs):
    t = p.text.strip()
    if 'Recommendations' in t and i > 390 and i < 425:
        in_recs = True
    if in_recs and t and len(t) > 2 and t[0].isdigit() and '. ' in t[:5]:
        print(f'  [{i}] {t[:120]}')
    if in_recs and 'References' in t and i > 400:
        break
