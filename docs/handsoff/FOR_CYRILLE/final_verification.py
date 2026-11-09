from pptx import Presentation
from docx import Document

print('=' * 60)
print('FINAL DEFENSE MATERIALS VERIFICATION')
print('=' * 60)

# 1. PPTX Verification
print('\n📊 CHECKING PPTX (3_PRESENTATION_FINAL.pptx)...')
prs = Presentation('3_PRESENTATION_FINAL.pptx')
pptx_issues = []
pptx_passed = []

for idx, slide in enumerate(prs.slides):
    slide_num = idx + 1
    slide_text = ' '.join([shape.text for shape in slide.shapes if hasattr(shape, 'text')])
    
    # Check for blockers
    if slide_num == 9:
        if 'in progress' in slide_text.lower() or 'will be added' in slide_text.lower():
            pptx_issues.append('Slide 9: Still has in progress warning')
    elif slide_num == 11:
        if 'n=5' in slide_text.lower() and 'preliminary' in slide_text.lower():
            pptx_issues.append('Slide 11: Still has N=5 preliminary data')
        if '20 parents' in slide_text.lower() and '10 young' in slide_text.lower():
            pptx_issues.append('Slide 11: Demographics inverted (20+10 instead of 10+20)')
        if '10 parents' in slide_text or '10 YP' in slide_text:
            pptx_passed.append('Slide 11: Correct demographics present')
    elif slide_num == 12:
        if 'preliminary' in slide_text.lower() and 'pending' in slide_text.lower():
            pptx_issues.append('Slide 12: Still has preliminary warnings')
        if 'final' in slide_text.lower() and 'n=30' in slide_text.lower():
            pptx_passed.append('Slide 12: Shows final N=30 data')
    
    # Check for correct SUS numbers
    if '61.83' in slide_text:
        pptx_passed.append(f'Slide {slide_num}: Has correct SUS mean (61.83)')
    if 'grade d' in slide_text.lower():
        pptx_passed.append(f'Slide {slide_num}: Has correct Grade D')

print(f'  ✓ Passed: {len(pptx_passed)} checks')
print(f'  ✗ Issues: {len(pptx_issues)} problems')
if pptx_issues:
    for issue in pptx_issues:
        print(f'    - {issue}')

# 2. DOCX Verification
print('\n📄 CHECKING MANUSCRIPT (1_MAIN_MANUSCRIPT_FINAL.docx)...')
doc = Document('1_MAIN_MANUSCRIPT_FINAL.docx')
docx_issues = []
docx_passed = []

full_text = '\n'.join([p.text for p in doc.paragraphs])

# Check for figures
figure_refs = ['Figure 3.4', 'Figure 3.5', 'Figure 3.6', 'Figure 3.7', 
               'Figure 3.8', 'Figure 3.9', 'Figure 3.10', 'Figure 3.11']
for fig_ref in figure_refs:
    if fig_ref in full_text:
        docx_passed.append(f'{fig_ref} referenced in text')

# Check for images
image_count = sum([1 for shape in doc.inline_shapes])
docx_passed.append(f'{image_count} images embedded')

# Check for blockers
if '[PENDING]' in full_text.upper():
    docx_issues.append('Contains [PENDING] placeholders')

# Check for correct numbers
if '61.83' in full_text:
    docx_passed.append('Has correct SUS mean (61.83)')
if 'both parent and young professional were classified' in full_text:
    docx_passed.append('Has demographic footnote explaining 13+14+3 to 10+20')

print(f'  ✓ Passed: {len(docx_passed)} checks')
print(f'  ✗ Issues: {len(docx_issues)} problems')
if docx_issues:
    for issue in docx_issues:
        print(f'    - {issue}')

# 3. Script Verification
print('\n📜 CHECKING DEFENSE SCRIPT (4_DEFENSE_SCRIPT_FINAL.md)...')
with open('4_DEFENSE_SCRIPT_FINAL.md', 'r', encoding='utf-8') as f:
    script = f.read()

script_issues = []
script_passed = []

if '20 parents' in script and '10 young' in script:
    script_issues.append('Demographics inverted (20 parents + 10 YP)')
elif '10 parents' in script or 'parents (n=10)' in script.lower():
    script_passed.append('Has correct demographics (10 parents + 20 YP)')

if '61.83' in script:
    script_passed.append('Has correct SUS mean')
if 'grade d' in script.lower():
    script_passed.append('Has correct SUS grade')

print(f'  ✓ Passed: {len(script_passed)} checks')
print(f'  ✗ Issues: {len(script_issues)} problems')
if script_issues:
    for issue in script_issues:
        print(f'    - {issue}')

# Final Summary
print('\n' + '=' * 60)
total_issues = len(pptx_issues) + len(docx_issues) + len(script_issues)
total_passed = len(pptx_passed) + len(docx_passed) + len(script_passed)

if total_issues == 0:
    print('✅ ALL CHECKS PASSED — DEFENSE READY')
    print(f'   {total_passed} verification checks successful')
else:
    print(f'⚠️  {total_issues} ISSUES FOUND — REVIEW NEEDED')
    print(f'   {total_passed} checks passed, {total_issues} failed')

print('=' * 60)
