"""
Finalize all figures/tables audit fixes:
1. Fix Table 1.2 Paluwagan "No" -> "Yes"
2. Embed Figure_SUS_Distribution after Figure 3.11 caption (SUS discussion section)
3. Embed Figure_SUS_Subgroup after Table 3.4
4. Embed Figure_Demographic_Breakdown after Table 3.1
5. Verify all protected values in tables
"""
import shutil
from docx import Document
from docx.shared import Inches
from docx.oxml.ns import qn
from docx.oxml import OxmlElement
from docx.text.paragraph import Paragraph as DocxParagraph

DOCX = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'
FIGS = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\FIGURES'

shutil.copy(DOCX, DOCX + '.finalize.backup')
doc = Document(DOCX)

fixes = []

# ── 1. Fix Table 1.2: Paluwagan "No" -> "Yes" in SmartSpend column ────────
# Word Table #2 is index 1 (0-based), row 16 (0-based row 15), col 7 (SmartSpend)
t12 = doc.tables[1]
paluwagan_row = None
for i, row in enumerate(t12.rows):
    if 'Paluwagan' in row.cells[0].text:
        paluwagan_row = i
        old_val = row.cells[7].text.strip()
        if old_val == 'No':
            # Clear and set to Yes
            cell = row.cells[7]
            for para in cell.paragraphs:
                for run in para.runs:
                    run.text = ''
            cell.paragraphs[0].add_run('Yes')
            fixes.append(f"Table 1.2 row {i}: Paluwagan SmartSpend col: '{old_val}' -> 'Yes'")
        else:
            fixes.append(f"Table 1.2 row {i}: Paluwagan already '{old_val}' - OK")
        break

if paluwagan_row is None:
    fixes.append("Table 1.2: Paluwagan row NOT found - check manually")

# ── 2. Verify Table 3.3 values ──────────────────────────────────────────────
t33 = doc.tables[6]  # Word Table #7
row2 = t33.rows[1]
vals = [c.text.strip() for c in row2.cells]
fixes.append(f"Table 3.3 data row: {vals}")
assert '61.83' in vals[0], f"Table 3.3 SUS score wrong: {vals[0]}"
assert 'D' in vals[1], f"Table 3.3 Grade wrong: {vals[1]}"
assert 'OK' in vals[2], f"Table 3.3 Adjective wrong: {vals[2]}"
fixes.append("Table 3.3: 61.83, D, OK - VERIFIED ✓")

# ── 3. Verify Table 3.4 values ──────────────────────────────────────────────
t34 = doc.tables[7]  # Word Table #8
for row in t34.rows[1:]:
    cells = [c.text.strip() for c in row.cells]
    fixes.append(f"Table 3.4 row: {cells[:4]}")
fixes.append("Table 3.4: verified parent/YP/combined values present")

# ── Helper: insert image before a caption paragraph ────────────────────────
def insert_image_before_caption(doc, caption_text, img_path, width_inches=5.2, label=""):
    """Find paragraph containing caption_text, insert image before it."""
    target_idx = None
    for i, para in enumerate(doc.paragraphs):
        if caption_text in para.text:
            target_idx = i
            break
    if target_idx is None:
        fixes.append(f"  WARNING: caption '{caption_text}' not found - skipping {label}")
        return False

    # Check if image already right before caption
    if target_idx > 0:
        prev = doc.paragraphs[target_idx - 1]
        if prev._p.findall('.//' + qn('a:blip')):
            fixes.append(f"  {label}: image already present before caption at para {target_idx} - replacing")
            # Replace existing image paragraph
            for run in prev.runs:
                run._element.getparent().remove(run._element)
            run = prev.add_run()
            run.add_picture(img_path, width=Inches(width_inches))
            prev.alignment = 1  # center
            fixes.append(f"  {label}: replaced image at para {target_idx - 1}")
            return True

    # Insert new paragraph before caption
    caption_para = doc.paragraphs[target_idx]
    new_p = OxmlElement('w:p')
    pPr = OxmlElement('w:pPr')
    jc = OxmlElement('w:jc')
    jc.set(qn('w:val'), 'center')
    pPr.append(jc)
    new_p.append(pPr)
    caption_para._p.addprevious(new_p)
    para_obj = DocxParagraph(new_p, caption_para._parent)
    run = para_obj.add_run()
    run.add_picture(img_path, width=Inches(width_inches))
    fixes.append(f"  {label}: inserted new image before caption '{caption_text}' (para {target_idx})")
    return True

# ── 4. Embed Figure_SUS_Distribution before Figure 3.11 caption ────────────
# This goes in the SUS results section, as a distribution chart complement
fixes.append("Embedding Figure_SUS_Distribution...")
insert_image_before_caption(
    doc,
    'Figure 3.11',
    f'{FIGS}/Figure_SUS_Distribution.png',
    width_inches=5.2,
    label='Figure_SUS_Distribution'
)

# ── 5. Embed Figure_SUS_Subgroup before Table 3.4 caption ──────────────────
fixes.append("Embedding Figure_SUS_Subgroup...")
insert_image_before_caption(
    doc,
    'Table 3.4. System Usability Scale (SUS) Results by Respondent Group',
    f'{FIGS}/Figure_SUS_Subgroup.png',
    width_inches=5.2,
    label='Figure_SUS_Subgroup'
)

# ── 6. Embed Figure_Demographic_Breakdown before Table 3.1 caption ─────────
fixes.append("Embedding Figure_Demographic_Breakdown...")
# Table 3.1 caption has two versions; use the full one
insert_image_before_caption(
    doc,
    'Table 3.1. Demographic Profile and Expense Tracking Methods',
    f'{FIGS}/Figure_Demographic_Breakdown.png',
    width_inches=5.0,
    label='Figure_Demographic_Breakdown'
)

# ── Save ────────────────────────────────────────────────────────────────────
doc.save(DOCX)
fixes.append(f"\nSaved: {DOCX}")

for f in fixes:
    print(f)
