"""
Fix the text changes that the earlier automation scripts didn't apply correctly.
Works by finding the exact paragraph and doing targeted text replacement.
"""
from docx import Document
import shutil, re

DOCX = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'
shutil.copy(DOCX, DOCX + '.fix3.backup')
doc = Document(DOCX)

fixes_applied = []
fixes_failed = []

def replace_in_para(para, old, new, label):
    """Replace text across runs in a paragraph, preserving formatting of first run."""
    full = para.text
    if old not in full:
        return False
    # Rebuild using first run to carry formatting
    if para.runs:
        # Clear all runs, put corrected text in first
        new_text = full.replace(old, new, 1)
        for i, run in enumerate(para.runs):
            run.text = new_text if i == 0 else ''
        fixes_applied.append(f"  FIXED [{label}]: '{old[:60]}' -> '{new[:60]}'")
        return True
    return False

# ── 1. Objective 3: "was achieved" -> "was partially achieved" ────────────
# Para 385 (may shift slightly after figure inserts)
found = False
for para in doc.paragraphs:
    if ('third objective of the study was achieved' in para.text and
            'third objective of the study was partially achieved' not in para.text):
        ok = replace_in_para(
            para,
            'the third objective of the study was achieved: the usability of SmartSpend',
            'the third objective of the study was partially achieved: usability was evaluated with the System Usability Scale with 30 valid respondents, but the mean score of 61.83 fell below',
            'Obj3-partial'
        )
        if not ok:
            # Try shorter match
            ok = replace_in_para(para, 'was achieved: the usability', 'was partially achieved: usability', 'Obj3-short')
        if ok:
            found = True
            break
if not found:
    # Try broader
    for para in doc.paragraphs:
        if 'third objective' in para.text and 'was achieved' in para.text and 'partially' not in para.text:
            replace_in_para(para, 'was achieved', 'was partially achieved', 'Obj3-broad')
            found = True
            break
    if not found:
        fixes_failed.append("Objective 3 'partially achieved' - paragraph not found")

# ── 2. After Table 3.3: add Sauro & Lewis 2016 attribution ────────────────
found = False
for para in doc.paragraphs:
    t = para.text
    # Look for the specific sentence about 68 benchmark without Sauro attribution
    if '68-point' in t and ('benchmark' in t or 'average' in t) and 'Sauro' not in t:
        old = None
        if 'below the 68-point average benchmark' in t:
            old = 'below the 68-point average benchmark'
            new = 'below the 68-point average benchmark (Sauro & Lewis, 2016)'
        elif 'below the 68 benchmark' in t:
            old = 'below the 68 benchmark'
            new = 'below the 68 benchmark (Sauro & Lewis, 2016)'
        if old:
            ok = replace_in_para(para, old, new, '68-Sauro-attr')
            if ok:
                found = True
                # Only fix the first occurrence (Table 3.3 discussion)
                break

# Also find "between the OK and Good anchors" and add Bangor ref if missing
for para in doc.paragraphs:
    t = para.text
    if 'between the OK and Good' in t and 'Bangor' not in t:
        replace_in_para(para,
            'between the OK and Good anchors',
            'between the OK and Good anchors of Bangor et al. (2009)',
            'OK-Good-Bangor')
        break

if not found:
    fixes_failed.append("68 Sauro & Lewis attribution - could not find bare '68-point' sentence")

# ── 3. LLM criteria: expand 4 -> 6 weighted ───────────────────────────────
found = False
for para in doc.paragraphs:
    t = para.text
    # Look for the 4-criteria description
    if 'four criteria' in t.lower() and ('inference speed' in t.lower() or 'criteria:' in t.lower()):
        ok = replace_in_para(para,
            'four criteria',
            'six weighted criteria',
            'LLM-4to6-criteria')
        if ok:
            found = True
            break
    # Also look for the weighted criteria paragraph that was supposed to be added
    if 'Each candidate was assessed across' in t and 'six' not in t.lower() and 'weighted' not in t.lower():
        replace_in_para(para,
            'Each candidate was assessed across',
            'Each candidate was assessed across six weighted criteria (Filipino-English accuracy 25%, speed/latency 20%, tool use and JSON reliability 20%, free-tier availability 15%, context window 10%, and financial reasoning quality 10%) using',
            'LLM-6-weighted-inject')
        found = True
        break

# Check the weighted criteria paragraph we found before at para 317
for i, para in enumerate(doc.paragraphs):
    if i < 310 or i > 330:
        continue
    t = para.text
    if 'criteria' in t.lower() and 'LLM' not in t and 'Filipino-English' not in t:
        if 'Each candidate' in t or 'assessed' in t.lower():
            fixes_applied.append(f"  LLM criteria para {i}: {t[:100]!r}")

if not found:
    fixes_failed.append("LLM 6 weighted criteria - could not find 4-criteria sentence to replace")

# ── 4. CFIS 2025 in body text ─────────────────────────────────────────────
found_cfis_body = False
for para in doc.paragraphs:
    t = para.text
    if 'CFIS' in t and ('2026' in t or '2025' in t) and 'Bangko Sentral' not in t:
        fixes_applied.append(f"  CFIS body para: {t[:120]!r}")
        found_cfis_body = True
        # If it says CFIS 2026, fix to 2025
        if 'CFIS 2026' in t:
            replace_in_para(para, 'CFIS 2026', 'CFIS 2025', 'CFIS-year')

# ── 5. Build version note in SUS section ──────────────────────────────────
found_build = False
for para in doc.paragraphs:
    if 'v3.1.0' in para.text and ('evaluated' in para.text.lower() or 'badges' in para.text.lower()):
        fixes_applied.append(f"  Build version note found: {para.text[:100]!r}")
        found_build = True
        break
if not found_build:
    # Find SUS evaluation paragraph and add build note nearby
    for i, para in enumerate(doc.paragraphs):
        if 'valid respondents' in para.text and '61.83' in para.text:
            # This is the SUS results paragraph - add build note to next para if not present
            if i+1 < len(doc.paragraphs):
                next_p = doc.paragraphs[i+1]
                if 'v3.1.0' not in next_p.text and 'build' not in next_p.text.lower():
                    # Insert new paragraph after this one
                    from docx.oxml import OxmlElement
                    new_p_elem = OxmlElement('w:p')
                    para._p.addnext(new_p_elem)
                    from docx.text.paragraph import Paragraph as DocxParagraph
                    new_para = DocxParagraph(new_p_elem, para._parent)
                    run = new_para.add_run(
                        'The build evaluated was v3.1.0. Peso mascot prominence and the expanded badge system (36 badges) were added in subsequent releases (v3.1.1 and v3.1.2) after the SUS evaluation was completed.'
                    )
                    # Match font size of surrounding paragraph
                    if para.runs:
                        run.font.size = para.runs[0].font.size
                    fixes_applied.append(f"  Inserted build version note after para {i}")
                    found_build = True
                    break
    if not found_build:
        fixes_failed.append("Build version note - could not insert")

# ── Save and report ────────────────────────────────────────────────────────
doc.save(DOCX)

print("FIXES APPLIED:")
for f in fixes_applied:
    print(f)
print("\nFIXES FAILED:")
for f in fixes_failed:
    print(f"  FAILED: {f}")
print("\nDone.")
