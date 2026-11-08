from docx import Document
from docx.oxml.ns import qn
import re, shutil

fname = 'docs/handsoff/1_MAIN_MANUSCRIPT (FINAL).docx'
doc = Document(fname)
fixes = 0

all_paras = list(doc.paragraphs)
for table in doc.tables:
    for row in table.rows:
        for cell in row.cells:
            all_paras.extend(cell.paragraphs)

# Fix 1: SmartSpend SmartSpend — spans multiple runs, fix via XML
for para in all_paras:
    if 'SmartSpend' in para.text:
        # Get full paragraph text from all w:t elements
        full_text = ''.join(
            (t_elem.text or '') for t_elem in para._p.findall('.//' + qn('w:t'))
        )
        if 'SmartSpend SmartSpend' in full_text:
            # Find the runs with SmartSpend and fix
            t_elems = para._p.findall('.//' + qn('w:t'))
            combined = ''
            for i, t in enumerate(t_elems):
                combined += (t.text or '')
            # Clear all and rewrite first
            if t_elems:
                new_full = full_text.replace('SmartSpend SmartSpend', 'SmartSpend')
                # Simple approach: put all text in first t element, clear rest
                t_elems[0].text = new_full
                for t in t_elems[1:]:
                    t.text = ''
                fixes += 1
                print(f"Fixed duplicate SmartSpend in: {full_text[:80]}")

# Fix 2: Add N=30 where survey sample is described
# Look for paragraphs mentioning "30 respondents" and ensure N=30 notation
for para in all_paras:
    t = para.text
    if '30 respondents participated' in t and 'N=30' not in t and '(N=30)' not in t:
        # Add N=30 notation
        for run in para.runs:
            if '30 respondents participated' in run.text:
                run.text = run.text.replace(
                    '30 respondents participated',
                    '30 respondents (N=30) participated'
                )
                fixes += 1
                print(f"Added N=30 notation")
                break
        for t_elem in para._p.findall('.//' + qn('w:t')):
            if t_elem.text and '30 respondents participated' in t_elem.text:
                t_elem.text = t_elem.text.replace(
                    '30 respondents participated',
                    '30 respondents (N=30) participated'
                )
                fixes += 1
                print(f"Added N=30 notation (xml)")
                break

# Fix 3: SUS N=30 — The SUS section should mention N=30
for para in all_paras:
    t = para.text
    if 'screened from 36 total responses' in t and 'N=30' not in t:
        for t_elem in para._p.findall('.//' + qn('w:t')):
            if t_elem.text and 'N=30' not in t_elem.text and '30 valid respondents' in t_elem.text:
                # already has 30, add N=30 explicitly
                pass

doc.save(fname)
print(f"\nTotal fixes: {fixes}")

# Final verification
doc2 = Document(fname)
full2 = ' '.join(p.text for p in doc2.paragraphs)
for table in doc2.tables:
    for row in table.rows:
        for cell in row.cells:
            for p in cell.paragraphs:
                full2 += ' ' + p.text

print("\n=== FINAL VERIFICATION ===")
checks = [
    ('61.83', True, 'SUS score'),
    ('N=30', True, 'sample size'),
    ('96.7%', True, 'AI intent'),
    ('Mangaoang, DIT', True, 'adviser DIT'),
    ('Layco, MIS', True, 'dean MIS'),
    ('36 achievement', True, '36 badges'),
    ('34 agentic', True, '34 actions'),
    ('62.50', False, 'old SUS'),
    ('63.06', False, 'old SUS'),
    ('Mangaoang, MIT', False, 'wrong title'),
    ('Verzola', False, 'removed adviser'),
    ('SmartSpend SmartSpend', False, 'duplicate'),
    ('[[PENDING', False, 'pending tags'),
    ('[[VERIFY', False, 'verify tags'),
]
all_ok = True
for term, should, label in checks:
    found = term.lower() in full2.lower()
    ok = found == should
    if not ok:
        all_ok = False
    status = 'OK' if ok else 'STILL ISSUE'
    print(f"  {status}: {label} ({term})")

print(f"\n{'ALL CLEAN ✅' if all_ok else 'SOME ISSUES REMAIN'}")
