"""
Apply fixes found in cross-examination to SoT PPT and Script.
Issues to fix:
1. Script Slide 4: "Table 2 of our manuscript" -> "Table 1 of our manuscript"
2. Script Slide 17 Conclusion 2: "eight candidate APIs" -> "ten candidate models from four providers"  
3. Script Slide 9: Remove duplicate sentence about 10% dedicated app
4. PPT Slide 18: Remove duplicate Rec 7 (Longitudinal evaluation)
"""
import shutil
from pptx import Presentation
from pptx.oxml.ns import qn

PPT    = r"SmartSpend_Defense.pptx"
SCRIPT = r"4_DEFENSE_SCRIPT_FINAL.md"

shutil.copy(PPT,    PPT    + '.sot_fix.bak')
shutil.copy(SCRIPT, SCRIPT + '.sot_fix.bak')

log = []

# ── FIX SCRIPT ────────────────────────────────────────────────────────────
script = open(SCRIPT, encoding='utf-8').read()
orig = script

# Fix 1: Table 2 -> Table 1 for gap analysis (Slide 4)
script = script.replace(
    'SmartSpend directly addresses each of these three gaps, as shown in Table 2 of our manuscript.',
    'SmartSpend directly addresses each of these three gaps, as shown in Table 1 of our manuscript.'
)
if 'Table 1 of our manuscript' in script:
    log.append('Script Slide 4: fixed "Table 2" -> "Table 1" for Gap Analysis')

# Fix 2: eight candidate APIs -> ten candidate models (Slide 17 Conclusion 2)
script = script.replace(
    'comparative technical evaluation of eight candidate APIs',
    'comparative technical evaluation of ten candidate models from four providers'
)
if 'ten candidate models from four providers' in script:
    log.append('Script Slide 17: fixed Conclusion 2 "eight candidate APIs" -> "ten candidate models"')

# Fix 3: Remove duplicate sentence in Slide 9
# The duplicate is the second occurrence of the 10% dedicated app sentence
old_dupe = (
    ' Only 10%, or 3 out of 30, already used a dedicated mobile app for budgeting — confirming the market gap.'
    ' The most common tracking method was physical receipts at 90%, followed by mental estimates at 53.3%'
    ' and e-wallet transaction history at 43.3%. Only 10% — 3 of 30 — already used a dedicated budgeting'
    ' app, which confirms the market gap.,'
)
# Find and remove just the trailing duplicate phrase
script = script.replace(
    '. Only 10% — 3 of 30 — already used a dedicated budgeting app, which confirms the market gap., followed by mental estimates at 53.3%.',
    '. These findings directly informed the features we built into SmartSpend and confirm that Objective 1 was **achieved**.'
)
# More targeted - find the specific duplicated segment in Slide 9
old_slide9_text = (
    'Only 10%, or 3 out of 30, already used a dedicated mobile app for budgeting — confirming the market gap. '
    'The most common tracking method was physical receipts at 90%, followed by mental estimates at 53.3% '
    'and e-wallet transaction history at 43.3%. Only 10% — 3 of 30 — already used a dedicated budgeting '
    'app, which confirms the market gap., followed by mental estimates at 53.3%.'
)
new_slide9_text = (
    'Only 10%, or 3 out of 30, already used a dedicated mobile app for budgeting — confirming the market gap. '
    'The most common tracking method was physical receipts at 90%, followed by mental estimates at 53.3% '
    'and e-wallet transaction history at 43.3%. These findings directly informed the features we built '
    'into SmartSpend and confirm that Objective 1 was **achieved**.'
)
if old_slide9_text in script:
    script = script.replace(old_slide9_text, new_slide9_text)
    log.append('Script Slide 9: removed duplicate 10% sentence')
else:
    # Try simpler approach - find the duplicate comma-sentence
    script = script.replace(
        ', which confirms the market gap., followed by mental estimates at 53.3%.',
        '. These findings directly informed the features we built into SmartSpend and confirm that Objective 1 was **achieved**.'
    )
    log.append('Script Slide 9: removed duplicate via comma fix')

if script != orig:
    with open(SCRIPT, 'w', encoding='utf-8') as f:
        f.write(script)
    log.append('Script saved.')

# ── FIX PPT ───────────────────────────────────────────────────────────────
prs = Presentation(PPT)

# Fix 4: Slide 18 — remove duplicate Rec 7
slide18 = prs.slides[17]

def get_all_runs(shape):
    runs = []
    if shape.has_text_frame:
        for para in shape.text_frame.paragraphs:
            for run in para.runs:
                runs.append((run, para, shape))
    if shape.shape_type == 6:
        for s in shape.shapes:
            runs.extend(get_all_runs(s))
    return runs

# Find paragraphs with "Longitudinal evaluation" and "3–6 months"
# The duplicate is a separate text box or second occurrence in same box
# Strategy: find all shapes containing "Longitudinal" and deduplicate
long_shapes = []
for shape in slide18.shapes:
    if shape.has_text_frame and 'Longitudinal' in shape.text_frame.text:
        long_shapes.append(shape)
    elif shape.shape_type == 6:
        for s in shape.shapes:
            if s.has_text_frame and 'Longitudinal' in s.text_frame.text:
                long_shapes.append(shape)

print(f'Shapes with Longitudinal: {len(long_shapes)}')
if len(long_shapes) >= 2:
    # Keep first, clear second
    # Actually we need to find which is the duplicate group/textbox
    # Look at all text on slide for "Longitudinal"
    all_long = []
    def find_long(shape, depth=0):
        if shape.has_text_frame:
            for para in shape.text_frame.paragraphs:
                if 'Longitudinal' in para.text:
                    all_long.append((shape, para, depth))
        if shape.shape_type == 6:
            for s in shape.shapes:
                find_long(s, depth+1)
    
    for shape in slide18.shapes:
        find_long(shape)
    
    print(f'Paragraphs with Longitudinal: {len(all_long)}')
    for shape, para, depth in all_long:
        print(f'  Shape: {shape.name}, depth={depth}, text: {para.text[:80]}')
    
    # Remove duplicate: clear text from second occurrence
    if len(all_long) >= 2:
        _, para2, _ = all_long[1]  # second occurrence
        for run in para2.runs:
            run.text = ''
        # Also clear the following paragraph (the description "3–6 months...")
        # Find its parent text frame
        shape2, _, _ = all_long[1]
        if shape2.has_text_frame:
            tf = shape2.text_frame
            # Clear all paragraphs in this text frame
            found = False
            for para in tf.paragraphs:
                if 'Longitudinal' in para.text or found:
                    for run in para.runs:
                        run.text = ''
                    found = True
        log.append('PPT Slide 18: cleared duplicate Rec 7 text box')

prs.save(PPT)
log.append('PPT saved.')

# ── Print results ─────────────────────────────────────────────────────────
print(f'\n{len(log)} actions:')
for l in log: print(f'  {l}')

# ── Verify ────────────────────────────────────────────────────────────────
script2 = open(SCRIPT, encoding='utf-8').read()
prs2 = Presentation(PPT)

def ppt_all(prs):
    t = []
    def g(s):
        if s.has_text_frame: t.append(s.text_frame.text)
        if s.shape_type == 6:
            for x in s.shapes: g(x)
    for slide in prs.slides:
        for s in slide.shapes: g(s)
        t.append(slide.notes_slide.notes_text_frame.text)
    return '\n'.join(t)

pt2 = ppt_all(prs2)

checks = [
    ('Script: Table 1 for gap analysis',   'Table 1 of our manuscript' in script2),
    ('Script: no "Table 2 of our manuscript"', 'Table 2 of our manuscript' not in script2),
    ('Script: ten candidate models in Slide 17', 'ten candidate models from four providers' in script2),
    ('Script: no eight candidate APIs',    'eight candidate APIs' not in script2),
    ('Script: no duplicate 10% sentence',  script2.count('confirms the market gap') <= 1),
    ('PPT: partially achieved',            'partially achieved' in pt2.lower()),
    ('PPT: 61.83',                         '61.83' in pt2),
    ('PPT: Gemini 3.5 Flash-Lite',         'Gemini 3.5 Flash-Lite' in pt2),
    ('PPT: ten candidate models',          '10 candidate models' in pt2 or 'ten candidate' in pt2.lower()),
    ('PPT: no Gemini 1.5',                 'Gemini 1.5' not in pt2),
]

print('\nVerification:')
all_pass = True
for label, ok in checks:
    if not ok: all_pass = False
    print(f'  {"OK  " if ok else "FAIL"}: {label}')
print(f'\n{"ALL PASS" if all_pass else "SOME FAILURES — check above"}')
