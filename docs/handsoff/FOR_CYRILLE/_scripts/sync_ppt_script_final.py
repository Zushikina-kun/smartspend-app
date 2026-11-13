"""
Final sync of PPT and script with the merged manuscript.
Key changes to apply:
1. Table numbering: 1=Gap, 2=Feature Comp, 3=Respondents, 4=Kanban,
   5=Demographics, 6=LLM APIs, 7=Overall SUS, 8=SUS by Group, 9=Multimodal Parsing
2. Research design: quantitative descriptive developmental (no mixed-methods)
3. Sampling: random for respondents, purposive for validator
4. Population: 16 parents + 14 YP = 30 (no 13 parents or 3 both)
5. Eight-provider failover, Gemini 3.5 Flash-Lite, seven fallbacks
6. Verify 9 recommendations still present
7. Figure refs: 22 figures now exist (1-16 unchanged, 17-22 new)
"""
import shutil, re
from pptx import Presentation
from pptx.util import Pt
from lxml import etree

PPT    = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\SmartSpend_Defense.pptx'
SCRIPT = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\4_DEFENSE_SCRIPT_FINAL.md'

shutil.copy(PPT,    PPT    + '.finalsync2.bak')
shutil.copy(SCRIPT, SCRIPT + '.finalsync2.bak')

log = []

# ── Helpers ───────────────────────────────────────────────────────────────
def get_all_runs(shape):
    runs = []
    if shape.has_text_frame:
        for para in shape.text_frame.paragraphs:
            for run in para.runs:
                runs.append(run)
    if shape.shape_type == 6:  # group
        for s in shape.shapes:
            runs.extend(get_all_runs(s))
    return runs

def replace_in_run(run, old, new):
    if old in run.text:
        run.text = run.text.replace(old, new)
        return True
    return False

def ppt_full_text(prs):
    parts = []
    for slide in prs.slides:
        for shape in slide.shapes:
            for run in get_all_runs(shape):
                parts.append(run.text)
        # speaker notes
        notes = slide.notes_slide.notes_text_frame.text
        if notes:
            parts.append(notes)
    return '\n'.join(parts)

# ── Load PPT ──────────────────────────────────────────────────────────────
prs = Presentation(PPT)

# Replacements to apply in PPT (old → new)
PPT_REPLACEMENTS = [
    # Research design
    ('mixed-methods', 'quantitative descriptive developmental'),
    ('mixed methods', 'quantitative descriptive developmental'),
    ('Mixed-methods', 'Quantitative descriptive developmental'),
    ('Mixed methods', 'Quantitative descriptive developmental'),
    # Sampling
    ('purposive sampling for respondents', 'random sampling'),
    ('selected through purposive sampling', 'selected through random sampling'),
    # Population - old split
    ('13 parents', '16 parents'),
    ('13 Parents', '16 Parents'),
    ('3 respondents identified as both', ''),
    ('3 who identified as both', ''),
    # Failover
    ('six-provider', 'eight-provider'),
    ('six provider', 'eight-provider'),
    ('5 fallbacks', 'seven fallbacks'),
    ('five fallbacks', 'seven fallbacks'),
    # Table old refs (from previous numbering before merge)
    # Table 6 was demographics in old scheme, now Table 5
    # Table 7 was LLM in old scheme, now Table 6
    # Tables 8 and 9 were SUS, now Tables 7 and 8
    # Only fix if the context makes it clear (avoid false positives)
    # Gemini version
    ('Gemini 1.5', 'Gemini 3.5 Flash-Lite'),
]

for i, slide in enumerate(prs.slides):
    for shape in slide.shapes:
        for run in get_all_runs(shape):
            for old, new in PPT_REPLACEMENTS:
                if old in run.text:
                    run.text = run.text.replace(old, new)
                    log.append(f'PPT Slide {i+1}: "{old}" → "{new}"')
    # Also check speaker notes
    notes_tf = slide.notes_slide.notes_text_frame
    for para in notes_tf.paragraphs:
        for run in para.runs:
            for old, new in PPT_REPLACEMENTS:
                if old in run.text:
                    run.text = run.text.replace(old, new)
                    log.append(f'PPT Slide {i+1} notes: "{old}" → "{new}"')

prs.save(PPT)
print('PPT saved.')

# ── Fix Script ────────────────────────────────────────────────────────────
script = open(SCRIPT, encoding='utf-8').read()
orig = script

SCRIPT_REPLACEMENTS = [
    # Research design
    ('mixed-methods', 'quantitative descriptive developmental'),
    ('mixed methods', 'quantitative descriptive developmental'),
    ('Mixed-methods', 'Quantitative descriptive developmental'),
    # Sampling
    ('purposive sampling for all respondents', 'random sampling for respondents'),
    ('purposive sampling for the respondents', 'random sampling for the respondents'),
    # Population
    ('13 parents', '16 parents'),
    ('13 Parents', '16 Parents'),
    ('3 respondents identified as both', ''),
    # Failover
    ('six-provider', 'eight-provider'),
    ('five fallbacks', 'seven fallbacks'),
    ('5 fallbacks', 'seven fallbacks'),
    # Gemini
    ('Gemini 1.5', 'Gemini 3.5 Flash-Lite'),
    # Old table refs in script
    # "Tables 3.3 and 3.4" already fixed before, but just in case
    ('Tables 3.3 and 3.4', 'Tables 7 and 8'),
    ('Table 3.3', 'Table 7'),
    ('Table 3.4', 'Table 8'),
    # "Table 1.2" leftover
    ('Table 1.2', 'Table 2'),
    # seven/9 recs (should already be 9 but verify)
    ('seven recommendations', 'nine recommendations'),
    ('Seven recommendations', 'Nine recommendations'),
    ('7 recommendations', '9 recommendations'),
]

for old, new in SCRIPT_REPLACEMENTS:
    if old in script:
        script = script.replace(old, new)
        log.append(f'Script: "{old}" → "{new}"')

if script != orig:
    with open(SCRIPT, 'w', encoding='utf-8') as f:
        f.write(script)
    log.append('Script: saved with changes')
else:
    log.append('Script: no changes needed')

# ── Print log ─────────────────────────────────────────────────────────────
print(f'\n{len(log)} changes:')
for l in log:
    print(f'  {l}')

# ── Verify ────────────────────────────────────────────────────────────────
prs2 = Presentation(PPT)
script2 = open(SCRIPT, encoding='utf-8').read()
all_ppt_text = ppt_full_text(prs2)

checks = [
    ('PPT: no mixed-methods',          'mixed-methods' not in all_ppt_text.lower() and 'mixed methods' not in all_ppt_text.lower()),
    ('PPT: no Gemini 1.5',             'Gemini 1.5' not in all_ppt_text),
    ('PPT: 9 recs or nine',            '9 recommendations' in all_ppt_text.lower() or 'nine recommendations' in all_ppt_text.lower() or 'Slide 18' in SCRIPT),
    ('PPT: SUS 61.83',                 '61.83' in all_ppt_text),
    ('PPT: partially achieved',        'partially achieved' in all_ppt_text.lower()),
    ('PPT: Nov 16 2026',               'November 16' in all_ppt_text),
    ('PPT: Gemini 3.5',                'Gemini 3.5' in all_ppt_text),
    ('Script: no mixed-methods',       'mixed-methods' not in script2.lower() and 'mixed methods' not in script2.lower()),
    ('Script: no Gemini 1.5',          'Gemini 1.5' not in script2),
    ('Script: 9 recs',                 '9 recommendations' in script2.lower() or 'nine recommendations' in script2.lower() or '8. UI/UX' in script2),
    ('Script: SUS 61.83',              '61.83' in script2),
    ('Script: partially achieved',     'partially achieved' in script2.lower()),
    ('Script: Nov 16',                 'November 16' in script2),
    ('Script: Gemini 3.5',             'Gemini 3.5' in script2),
    ('Script: random sampling',        'random sampling' in script2.lower()),
    ('Script: 16 parents',             '16 parents' in script2.lower() or '16 Parents' in script2),
    ('Script: Avigail Candevario',     'Avigail Candevario' in script2 or 'Avigail' in script2),
    ('Script: quantitative',           'quantitative' in script2.lower()),
    ('Script: Jeoffrey',               'Jeoffrey' in script2),
]

print('\nVerification:')
all_pass = True
for label, ok in checks:
    status = 'OK  ' if ok else 'FAIL'
    if not ok:
        all_pass = False
    print(f'  {status}: {label}')

print(f'\n{"ALL PASS" if all_pass else "SOME FAILURES — check above"}')
