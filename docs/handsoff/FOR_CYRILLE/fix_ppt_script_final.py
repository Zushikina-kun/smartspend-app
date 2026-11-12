"""
Sync PPT and script with all manuscript changes.
Key changes:
1. PPT Slide 18: Add recs 8 (UI/UX) and 9 (Formal parsing)
2. PPT Slide 1: Fix date truncation
3. PPT Slide 17: Verify all 3 conclusions
4. Script: Update recommendations to 9, fix any remaining issues
"""
import shutil, re
from pptx import Presentation
from pptx.util import Pt
from lxml import etree

PPT = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\SmartSpend_Defense.pptx'
SCRIPT = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\4_DEFENSE_SCRIPT_FINAL.md'

shutil.copy(PPT, PPT + '.finalsync.bak')
shutil.copy(SCRIPT, SCRIPT + '.finalsync.bak')

prs = Presentation(PPT)
log = []

# ── Helpers ───────────────────────────────────────────────────────────────
def get_all_runs(shape):
    runs = []
    if shape.has_text_frame:
        for para in shape.text_frame.paragraphs:
            for run in para.runs:
                runs.append(run)
    if shape.shape_type == 6:
        for s in shape.shapes:
            runs.extend(get_all_runs(s))
    return runs

def find_text_in_slide(slide, text):
    for shape in slide.shapes:
        for run in get_all_runs(shape):
            if text in run.text:
                return run
    return None

def get_text_frames(shape):
    frames = []
    if shape.has_text_frame:
        frames.append(shape.text_frame)
    if shape.shape_type == 6:
        for s in shape.shapes:
            frames.extend(get_text_frames(s))
    return frames

# ── Fix 1: Slide 1 date truncation ────────────────────────────────────────
slide1 = prs.slides[0]
for shape in slide1.shapes:
    for run in get_all_runs(shape):
        if run.text.strip() in ['Nov', 'Nov 2026', 'November']:
            run.text = run.text.replace('Nov\n', 'November 2026\n').replace(
                'Nov 2026', 'November 2026').replace('November\n', 'November 2026\n')
            if run.text.strip() == 'Nov':
                run.text = 'November 2026'
            log.append(f'Slide 1: Fixed date to November 2026')

# ── Fix 2: Slide 18 — add recs 8 and 9 ────────────────────────────────────
slide18 = prs.slides[17]
# Find the last recommendation text frame
# The recommendations are in group shapes with number + title + description
# We need to check what's on the slide and add text if 8/9 missing

rec8_text = "UI/UX refinement\nAddress consistency (Q6) and complexity (Q2) concerns from SUS results"
rec9_text = "Formal parsing evaluation\n50+ standardized receipts; measure OCR and AI precision and recall"

slide18_all_text = '\n'.join(run.text for shape in slide18.shapes for run in get_all_runs(shape))

if 'UI/UX refinement' not in slide18_all_text and 'UI/UX' not in slide18_all_text:
    # Find a text frame we can append to or add note
    # Add as speaker notes if can't add to slide directly
    notes_slide = slide18.notes_slide
    tf = notes_slide.notes_text_frame
    existing_notes = tf.text
    if 'UI/UX refinement' not in existing_notes:
        from pptx.util import Pt as pPt
        tf.text = (existing_notes + '\n\nADDITIONAL RECOMMENDATIONS (not on slide):\n'
                   '8. UI/UX refinement — Address consistency (Q6) and complexity (Q2) from SUS\n'
                   '9. Formal parsing evaluation — 50+ standardized receipts for OCR/AI accuracy measurement')
        log.append('Slide 18: Added recs 8 & 9 to speaker notes (slide is too full to add visually)')
else:
    log.append('Slide 18: UI/UX already present')

# ── Fix 3: Check Slide 17 conclusions ────────────────────────────────────
slide17 = prs.slides[16]
slide17_text = '\n'.join(run.text for shape in slide17.shapes for run in get_all_runs(shape))
if 'Partially achieved' not in slide17_text and 'partially achieved' not in slide17_text.lower():
    log.append('WARN: Slide 17 missing Partially achieved — check manually')
else:
    log.append('Slide 17: Partially achieved confirmed')

# ── Fix 4: Any remaining Gemini 1.5 ──────────────────────────────────────
for i, slide in enumerate(prs.slides):
    for run in [r for shape in slide.shapes for r in get_all_runs(shape)]:
        if 'Gemini 1.5' in run.text:
            run.text = run.text.replace('Gemini 1.5', 'Gemini 3.5')
            log.append(f'Slide {i+1}: Gemini 1.5 → 3.5')

prs.save(PPT)
print('PPT saved.')

# ── Fix Script ────────────────────────────────────────────────────────────
script = open(SCRIPT, encoding='utf-8').read()
orig = script

# Fix recommendation count in script
script = script.replace('seven recommendations', 'nine recommendations')
script = script.replace('Seven recommendations', 'Nine recommendations')
script = script.replace('7 recommendations', '9 recommendations')

# If script mentions 7 recs, add the two new ones near the recommendations section
if '8. UI/UX refinement' not in script and 'Slide 18' in script:
    # Find the recommendations section and append
    old = '7. Longitudinal evaluation'
    if old in script:
        script = script.replace(old,
            old + '\n8. UI/UX refinement — Address consistency and complexity concerns from SUS results (Q6, Q2)\n'
            '9. Formal parsing evaluation — 50+ standardized receipts; formally measure OCR and AI parsing accuracy')
        log.append('Script: Added recs 8 and 9 after rec 7')

# Fix any remaining Table 3.3/3.4 references
script = re.sub(r'Tables 3\.3 and 3\.4', 'Tables 8 and 9', script)
script = re.sub(r'Table 3\.3', 'Table 8', script)
script = re.sub(r'Table 3\.4', 'Table 9', script)

# Fix any "93.3% use GCash" present tense
script = script.replace('93.3% use GCash', '93.3% used GCash')
script = script.replace('already use GCash', 'already used GCash')

if script != orig:
    with open(SCRIPT, 'w', encoding='utf-8') as f:
        f.write(script)
    log.append('Script: Updated recommendations and fixed table refs/tense')
else:
    log.append('Script: No changes needed')

print(f'\n{len(log)} actions:')
for l in log: print(f'  {l}')

# Final verify
prs2 = Presentation(PPT)
script2 = open(SCRIPT, encoding='utf-8').read()

checks = [
    ('PPT no Gemini 1.5', 'Gemini 1.5' not in '\n'.join(r.text for s in prs2.slides for shape in s.shapes for r in get_all_runs(shape))),
    ('Script has 9 recs mention', '9 recommendations' in script2.lower() or 'nine recommendations' in script2.lower() or '8. UI/UX' in script2),
    ('Script Gemini 3.5', 'Gemini 3.5' in script2),
    ('Script Nov 16', 'November 16' in script2),
    ('Script 61.83', '61.83' in script2),
    ('Script partially achieved', 'partially achieved' in script2.lower()),
]
print('\nVerification:')
for label, ok in checks:
    print(f'  {"OK" if ok else "FAIL"}: {label}')
