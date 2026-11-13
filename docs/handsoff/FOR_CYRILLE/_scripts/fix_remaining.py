from docx import Document
from docx.oxml.ns import qn
from docx.oxml import OxmlElement
from docx.text.paragraph import Paragraph as DocxParagraph
from docx.shared import Inches
import shutil

DOCX = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'
FIGS = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\FIGURES'

shutil.copy(DOCX, DOCX + '.fix2.backup')
doc = Document(DOCX)

fixes = []

# ── Fix 1: Embed SUS Subgroup before Table 3.4 (find actual caption) ──────
fixes.append("=== Fix 1: embed SUS Subgroup figure ===")
target_idx = None
for i, para in enumerate(doc.paragraphs):
    if 'Table 3.4' in para.text:
        fixes.append(f"  Found Table 3.4 at para {i}: {para.text[:80]!r}")
        # check if prev already has image
        if i > 0 and doc.paragraphs[i-1]._p.findall('.//' + qn('a:blip')):
            fixes.append("  Already has image before it - OK")
            target_idx = None
            break
        target_idx = i
        break

if target_idx is not None:
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
    run.add_picture(f'{FIGS}/Figure_SUS_Subgroup.png', width=Inches(5.2))
    fixes.append(f"  Inserted SUS Subgroup image before Table 3.4 at para {target_idx}")

# ── Fix 2: Scan for the actual text of the "MISSING" key fixes ────────────
fixes.append("\n=== Scanning for key text fixes ===")

# Check for "partially achieved" anywhere
pa_found = []
for i, para in enumerate(doc.paragraphs):
    if 'partially achieved' in para.text.lower():
        pa_found.append(f"  para {i}: {para.text[:100]!r}")
if pa_found:
    fixes.append("  'partially achieved' found at:")
    fixes.extend(pa_found)
else:
    fixes.append("  'partially achieved' NOT FOUND in any paragraph")

# Check for CFIS year
cfis_found = []
for i, para in enumerate(doc.paragraphs):
    if 'CFIS' in para.text:
        cfis_found.append(f"  para {i}: {para.text[:100]!r}")
if cfis_found:
    fixes.append("  CFIS mentions:")
    fixes.extend(cfis_found[:5])

# Check for 68 + Sauro
sus_bench_found = []
for i, para in enumerate(doc.paragraphs):
    if '68' in para.text and 'Sauro' in para.text:
        sus_bench_found.append(f"  para {i}: {para.text[:120]!r}")
if sus_bench_found:
    fixes.append("  '68 + Sauro' found:")
    fixes.extend(sus_bench_found[:3])
else:
    fixes.append("  '68 + Sauro' NOT found together — checking separately...")
    for i, para in enumerate(doc.paragraphs):
        if 'Sauro' in para.text and 'benchmark' in para.text.lower():
            fixes.append(f"    Sauro+benchmark para {i}: {para.text[:100]!r}")
        if '68-point' in para.text or '68 average' in para.text or '68 benchmark' in para.text:
            fixes.append(f"    68-benchmark para {i}: {para.text[:100]!r}")

# Check v3.1.0 evaluated
v310_found = []
for i, para in enumerate(doc.paragraphs):
    if 'v3.1.0' in para.text:
        v310_found.append(f"  para {i}: {para.text[:120]!r}")
if v310_found:
    fixes.append("  v3.1.0 found:")
    fixes.extend(v310_found[:3])
else:
    fixes.append("  v3.1.0 NOT FOUND")

# Check LLM 6 criteria
llm6_found = []
for i, para in enumerate(doc.paragraphs):
    if 'criteria' in para.text.lower() and ('6' in para.text or 'six' in para.text.lower()):
        llm6_found.append(f"  para {i}: {para.text[:100]!r}")
if llm6_found:
    fixes.append("  LLM 6 criteria mentions:")
    fixes.extend(llm6_found[:3])
else:
    fixes.append("  LLM 6 criteria NOT FOUND — checking for 'weighted'...")
    for i, para in enumerate(doc.paragraphs):
        if 'weighted' in para.text.lower() and 'criteria' in para.text.lower():
            fixes.append(f"    weighted-criteria para {i}: {para.text[:100]!r}")

doc.save(DOCX)
fixes.append("\nSaved.")
for f in fixes:
    print(f)
