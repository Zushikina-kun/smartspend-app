"""
Full cross-examination: SoT PPT + SoT Script vs SoT Manuscript.
Reports every inconsistency found — priority on Chapters 3 and 4.
"""
from docx import Document
from pptx import Presentation

MS   = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\Source of Truth\1_MAIN_MANUSCRIPT_FINAL.docx"
PPT  = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\Source of Truth\Presentation and Script\SmartSpend_Defense.pptx"
SCRIPT = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\Source of Truth\Presentation and Script\4_DEFENSE_SCRIPT_FINAL.md"

doc = Document(MS)
ms_text = '\n'.join(p.text.strip() for p in doc.paragraphs)
ms_tables = '\n'.join(c.text for t in doc.tables for row in t.rows for c in row.cells)
ms = ms_text + '\n' + ms_tables

prs = Presentation(PPT)
def ppt_all():
    t = []
    def g(s):
        if s.has_text_frame: t.append(s.text_frame.text)
        if s.shape_type == 6:
            for x in s.shapes: g(x)
    for slide in prs.slides:
        for s in slide.shapes: g(s)
        t.append(slide.notes_slide.notes_text_frame.text)
    return '\n'.join(t)
pt = ppt_all()
script = open(SCRIPT, encoding='utf-8').read()

issues = []
def issue(severity, location, description, manuscript_says='', current_says=''):
    issues.append((severity, location, description, manuscript_says, current_says))

# ═══════════════════════════════════════════════════════════
# CHAPTER 3 PRIORITY CHECKS
# ═══════════════════════════════════════════════════════════

# Needs assessment figures
if '16 parents aged 35' not in ms and '16 parents' not in ms:
    issue('HIGH', 'MS Ch3', 'Missing 16 parents split in Chapter III')

# Figure references in PPT Slide 11
# MS: Figs 9-15 are production screens
# PPT Slide 11 shows Figs 9-13 — check these are right
slide11_text = ''
for shape in prs.slides[10].shapes:
    if shape.has_text_frame:
        slide11_text += shape.text_frame.text + '\n'
for fig in ['Figure 9', 'Figure 10', 'Figure 11', 'Figure 12', 'Figure 13']:
    if fig not in slide11_text:
        issue('HIGH', 'PPT Slide 11', f'Missing {fig} in app screenshots slide',
              f'{fig} should be in Slide 11', 'Not found in slide 11')

# Check Slide 4 says Table 1 (Gap Analysis) not Table 2
# MS: "Table 1 presented a three-level summary"
slide4_text = '\n'.join(t for shape in prs.slides[3].shapes 
                         for t in ([shape.text_frame.text] if shape.has_text_frame else []))
if 'Table 1' not in slide4_text and 'Table 2' not in slide4_text:
    issue('MED', 'PPT Slide 4', 'Slide 4 gap analysis does not reference Table 1')

# Script Slide 4 says "Table 2" but MS Gap Analysis is Table 1
if 'Table 2 of our manuscript' in script:
    issue('HIGH', 'Script Slide 4', 
          'Script says "Table 2" for gap analysis but MS says it is Table 1',
          'Table 1 presented a three-level summary', 'Table 2 of our manuscript (script)')

# Script Slide 17 Conclusion 2 says "eight candidate APIs"
if 'eight candidate APIs' in script:
    issue('HIGH', 'Script Slide 17',
          'Conclusion 2 still says "eight candidate APIs" — should be ten',
          'ten candidate models from four providers', 'eight candidate APIs (script)')

# Slide 15 — check "Tables 3.3 and 3.4" vs "Tables 7 and 8"
if 'Tables 3.3 and 3.4' in pt:
    issue('HIGH', 'PPT', 'Old table reference "Tables 3.3 and 3.4" in PPT',
          'Tables 7 and 8', 'Tables 3.3 and 3.4')

# Check script Slide 9 for duplicate sentence
dup = 'Only 10%, or 3 out of 30, already used a dedicated mobile app for budgeting — confirming the market gap. The most common tracking method was physical receipts at 90%, followed by mental estimates at 53.3% and e-wallet transaction history at 43.3%. Only 10% — 3 of 30 — already used a dedicated budgeting app, which confirms the market gap.'
if 'confirming the market gap. The most common' in script and 'which confirms the market gap.' in script:
    issue('HIGH', 'Script Slide 9',
          'Duplicate sentence about 10% dedicated app — appears twice in Slide 9 text',
          'State once', 'Appears twice in script')

# Slide 13 FHS — raw formula still on slide body
slide13_body = '\n'.join(t for shape in prs.slides[12].shapes
                          for t in ([shape.text_frame.text] if shape.has_text_frame else []))
if 'Warning Decay' in slide13_body:
    issue('MED', 'PPT Slide 13',
          'Raw formula "Warning Decay" still visible on slide body (should be in notes only)',
          'Plain description of score adjustments on slide', 'Warning Decay text visible on slide')

# Check Slide 18 — Rec 7 appears twice
slide18_text = ''
for shape in prs.slides[17].shapes:
    if shape.has_text_frame:
        slide18_text += shape.text_frame.text + '\n'
count_rec7 = slide18_text.count('Longitudinal evaluation')
if count_rec7 > 1:
    issue('HIGH', 'PPT Slide 18',
          f'Recommendation 7 (Longitudinal evaluation) appears {count_rec7} times on slide — duplicate',
          'Once', f'{count_rec7} times')

# Check if Recs 8 & 9 are ONLY in notes (not on slide body)
if 'UI/UX refinement' in slide18_text or 'Formal parsing' in slide18_text:
    issue('LOW', 'PPT Slide 18',
          'Recs 8 or 9 visible in slide body — these are currently in speaker notes only',
          'In notes', 'On slide body')

# Figure 17 in MS = SUS by Group, PPT Slide 15 should reference it
# Check script references correct figure numbers
if 'Figure 16' in script and 'SUS Computation' in script:
    # This is correct — Fig 16 is SUS computation
    pass
if 'Figure 3.14' in script or 'Figure 3.13' in script:
    issue('HIGH', 'Script', 'Old chapter-prefixed figure numbers in script',
          'Sequential (Figure 17)', 'Figure 3.13/3.14')

# Check script Slide 16 — rec reference
if 'Recommendation 1' in script and 'UI/UX' in script:
    # Find context
    idx = script.find('Recommendation 1')
    ctx = script[max(0,idx-20):idx+100]
    if 'UI/UX' in ctx:
        issue('MED', 'Script Slide 16',
              'Script Slide 16 Limitations references "Recommendation 1" for UI/UX — should be Rec 8',
              'Recommendation 8', 'Recommendation 1 (Slide 16 limitations)')

# Check "Limitation" slide — SUS score
if '61.83 is under the 68' not in pt and '61.83' not in pt:
    issue('HIGH', 'PPT Slide 16', 'Missing SUS score 61.83 on Limitations slide')

# ═══════════════════════════════════════════════════════════
# CHAPTER 4 PRIORITY CHECKS
# ═══════════════════════════════════════════════════════════

# MS Conclusions
ms_concl_lines = [l for l in ms_text.split('\n') 
                  if any(k in l for k in ['first objective', 'second objective', 'third objective',
                                          'achieved', 'partially achieved'])]
for l in ms_concl_lines[:10]:
    if '20 candidate LLM' in l:
        issue('HIGH', 'MS Conclusions', '"20 candidate LLM models" still in manuscript conclusions',
              'ten candidate models from four providers', '20 candidate LLM models')

# PPT Conclusions slide
if 'ten candidate models' not in pt and '10 candidate models' not in pt:
    issue('HIGH', 'PPT Slide 17',
          'Conclusions slide missing "ten candidate models" — still says "8"?',
          'ten candidate models from four providers', 'Check slide 17')

# Script conclusions
if 'eight candidate APIs' in script:
    issue('HIGH', 'Script Ch4',
          'Script Conclusion for Obj 2 says "eight candidate APIs"',
          'ten candidate models from four providers', 'eight candidate APIs')

# ═══════════════════════════════════════════════════════════
# GENERAL CONSISTENCY CHECKS  
# ═══════════════════════════════════════════════════════════

protected = [
    ('61.83', 'SUS score 61.83'),
    ('17.58', 'SD 17.58'),
    ('Grade D', 'Grade D'),
    ('partially achieved', 'partially achieved'),
    ('Gemini 3.5 Flash-Lite', 'Gemini 3.5 Flash-Lite'),
    ('Avigail Candevario', 'Avigail Candevario'),
    ('Jeoffrey', 'Jeoffrey B. Layco'),
    ('November 16', 'November 16'),
]
for val, label in protected:
    if val not in pt:
        issue('HIGH', 'PPT', f'Missing protected value: {label}')
    if val not in script:
        issue('HIGH', 'Script', f'Missing protected value: {label}')

if 'Gemini 1.5' in pt:
    issue('HIGH', 'PPT', 'Gemini 1.5 still present in PPT', 'Gemini 3.5 Flash-Lite', 'Gemini 1.5')
if 'Gemini 1.5' in script.replace('"Gemini 1.5"', '').replace('| "Gemini 1.5"', ''):
    issue('HIGH', 'Script', 'Gemini 1.5 outside of dont-say table in script')

if 'mixed methods' in pt.lower() or 'mixed-methods' in pt.lower():
    issue('HIGH', 'PPT', 'mixed-methods language in PPT')

# ═══════════════════════════════════════════════════════════
# PRINT RESULTS
# ═══════════════════════════════════════════════════════════
print(f'\n{"="*65}')
print(f'CROSS-EXAMINATION RESULTS: {len(issues)} issues found')
print(f'{"="*65}')

high = [x for x in issues if x[0] == 'HIGH']
med  = [x for x in issues if x[0] == 'MED']
low  = [x for x in issues if x[0] == 'LOW']

for severity, items in [('🔴 HIGH', high), ('🟡 MED', med), ('🟢 LOW', low)]:
    if items:
        print(f'\n{severity} ({len(items)}):')
        for _, loc, desc, ms_says, curr in items:
            print(f'  [{loc}] {desc}')
            if ms_says: print(f'    MS says: {ms_says}')
            if curr:    print(f'    Found:   {curr}')
