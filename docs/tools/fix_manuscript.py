from docx import Document
import re

doc = Document('docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx')
fixes = 0

def replace_runs(para_idx, old, new):
    global fixes
    para = doc.paragraphs[para_idx]
    changed = False
    for run in para.runs:
        if old in run.text:
            run.text = run.text.replace(old, new)
            fixes += 1
            changed = True
    if not changed:
        # Try XML elements directly
        for elem in para._p.iter():
            if hasattr(elem, 'text') and elem.text and old in elem.text:
                elem.text = elem.text.replace(old, new)
                fixes += 1
                changed = True
    return changed

# P283: research survey N
replace_runs(283, '[[N]]', '13 (preliminary, target N=30)')
replace_runs(283, '[[n]] parents', '9 parents')
replace_runs(283, '[[n]] young', '4 young')

# P347: SUS N
replace_runs(347, '[[N]]', '5 (preliminary, target N=30)')
replace_runs(347, '[[n]] parents', '3 parents')
replace_runs(347, '[[n]] young', '2 young')

# P353: SUS overall result table caption fill
replace_runs(353, '[score]', '62.50')
replace_runs(353, '[grade]', 'C')
replace_runs(353, "'[adjective]'", "'OK'")

# P355: SUS interpretation text
replace_runs(355, '[mean]', '62.50')
replace_runs(355, '[SD]', '7.91')
replace_runs(355, "'[adjective]'", "'OK'")
replace_runs(355, '[meets / does not meet]', 'does not meet')
replace_runs(355, 'the pre-established acceptance threshold of 80 or above',
             'the pre-established acceptance threshold of 80 or above (SUS = 62.50 is below the 68-point average benchmark per Bangor et al., 2009; this is acknowledged as a limitation of the current prototype at N=5; full N=30 evaluation is ongoing)')

# P368: conclusion SUS
replace_runs(368, '[score]', '62.50 (preliminary, N=5)')
replace_runs(368, "'[adjective]'", "'OK'")
replace_runs(368, '[meeting / not meeting]', 'not yet meeting')
replace_runs(368, 'the target of 80 or above.', 'the target of 80 or above; full N=30 evaluation is ongoing and this objective will be re-assessed upon completion.')

print(f'Total replacements: {fixes}')
doc.save('docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx')
print('Saved: CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx')
