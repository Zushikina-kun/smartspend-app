from pptx import Presentation
prs = Presentation(r'FOR_CYRILLE\SmartSpend_Defense.pptx')

print('CURRENT PRESENTATION STRUCTURE:')
for i, slide in enumerate(prs.slides):
    shapes = [s for s in slide.shapes if s.has_text_frame]
    title = next((s.text_frame.text.strip() for s in shapes if s.text_frame.text.strip() and len(s.text_frame.text.strip()) < 100), '(no title)')
    print(f'Slide {i+1:2d}: {title[:80]}')
    
print()
print('=== CHAPTER COVERAGE CHECK ===')

# Read manuscript to see what's in each chapter
from docx import Document
doc = Document(r'Source of Truth\1_MAIN_MANUSCRIPT_FINAL.docx')
lines = [p.text.strip() for p in doc.paragraphs]

# Find chapter boundaries
ch1_idx = next(i for i,l in enumerate(lines) if l == 'CHAPTER I')
ch2_idx = next(i for i,l in enumerate(lines) if l == 'CHAPTER II')
ch3_idx = next(i for i,l in enumerate(lines) if l == 'CHAPTER III')
ch4_idx = next(i for i,l in enumerate(lines) if l == 'CHAPTER IV')

ch1_text = ' '.join(lines[ch1_idx:ch2_idx]).lower()
ch2_text = ' '.join(lines[ch2_idx:ch3_idx]).lower()

print('\nChapter I key topics in manuscript:')
if 'project context' in ch1_text: print('  - Project Context')
if 'purpose of the study' in ch1_text: print('  - Purpose')
if 'conceptual framework' in ch1_text: print('  - Conceptual Framework')
if 'statement of objectives' in ch1_text or 'objectives' in ch1_text: print('  - Statement of Objectives')
if 'scope and limitations' in ch1_text: print('  - Scope and Limitations')
if 'significance' in ch1_text: print('  - Significance of the Study')
if 'definition of terms' in ch1_text: print('  - Definition of Terms')

print('\nChapter II key topics in manuscript:')
if 'research design' in ch2_text: print('  - Research Design')
if 'population' in ch2_text or 'locale' in ch2_text: print('  - Population and Locale')
if 'data gathering' in ch2_text: print('  - Data Gathering')
if 'related literature' in ch2_text or 'review of related' in ch2_text: print('  - Related Literature')
if 'theoretical framework' in ch2_text or 'conceptual framework' in ch2_text: print('  - Theoretical/Conceptual Framework')

# Check what's in PPT
slides_text = []
for slide in prs.slides:
    for shape in slide.shapes:
        if shape.has_text_frame:
            slides_text.append(shape.text_frame.text)
ppt_full = ' '.join(slides_text).lower()

print('\nWhat PPT currently covers:')
coverage = {
    'Title/Opening': '✓' if 'smartspend' in ppt_full and 'prayer' in ppt_full else '✗',
    'Problem statement (Ch1 intro)': '✓' if 'financial literacy' in ppt_full and '2%' in ppt_full else '✗',
    'Gap analysis (Ch1)': '✓' if 'three levels' in ppt_full or 'international' in ppt_full else '✗',
    'Feature comparison/Table 2 (Ch1)': '✓' if 'tarsi' in ppt_full or 'ynab' in ppt_full else '✗',
    'Objectives (Ch1)': '✓' if 'three objectives' in ppt_full else '✗',
    'Conceptual Framework IPO (Ch1 or Ch2)': '✓' if 'input-process-output' in ppt_full else '✗',
    'Research Design/Methodology (Ch2)': '✓' if 'quantitative descriptive developmental' in ppt_full else '✗',
    'Needs assessment results (Ch3 Obj1)': '✓' if '96.7%' in ppt_full else '✗',
    'System overview (Ch3 Obj2)': '✓' if 'v3.1.0' in ppt_full else '✗',
    'Screenshots (Ch3 Obj2)': '✓' if 'figure 9' in ppt_full or 'login' in ppt_full else '✗',
    'LLM selection (Ch3 Obj2)': '✓' if 'gemini 3.5' in ppt_full else '✗',
    'Financial Health Score (Ch3 Obj2)': '✓' if 'financial health score' in ppt_full else '✗',
    'Privacy tiers (Ch3 Obj2)': '✓' if 'privacy' in ppt_full else '✗',
    'SUS results (Ch3 Obj3)': '✓' if '61.83' in ppt_full else '✗',
    'Limitations (Ch3)': '✓' if 'limitations' in ppt_full else '✗',
    'Conclusions (Ch4)': '✓' if 'conclusions' in ppt_full else '✗',
    'Recommendations (Ch4)': '✓' if 'payday-cycle' in ppt_full else '✗',
}

for topic, status in coverage.items():
    print(f'  {status} {topic}')

print()
print('MISSING FROM PPT (typically in defense presentations):')
missing = []
if 'significance' not in ppt_full: missing.append('- Significance of the Study (Ch1)')
if 'definition of terms' not in ppt_full: missing.append('- Definition of Terms (Ch1) — usually skipped, OK')
if 'theoretical' not in ppt_full and 'thaler' not in ppt_full: missing.append('- Theoretical Framework (Ch2) — behavioral econ foundations')
if 'related literature' not in ppt_full: missing.append('- Related Literature review (Ch2) — usually brief or skipped')
if 'scope' not in ppt_full: missing.append('- Scope and Limitations slide — covered in Slide 16 as "Limitations"')

for m in missing:
    print(f'  {m}')

if not missing:
    print('  None — all major defense topics covered')
