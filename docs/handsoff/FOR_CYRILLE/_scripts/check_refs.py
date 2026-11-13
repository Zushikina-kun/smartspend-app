"""Check PPT and script for old table/figure references and new ones."""
from pptx import Presentation

prs = Presentation('SmartSpend_Defense.pptx')

def get_all_text_deep(shape):
    texts = []
    if shape.has_text_frame:
        texts.append(shape.text_frame.text)
    if shape.has_table:
        for row in shape.table.rows:
            for cell in row.cells:
                texts.append(cell.text_frame.text)
    if hasattr(shape, 'shapes'):
        for s in shape.shapes:
            texts.extend(get_all_text_deep(s))
    return texts

all_ppt_texts = []
for slide in prs.slides:
    for shape in slide.shapes:
        all_ppt_texts.extend(get_all_text_deep(shape))

full_ppt = '\n'.join(all_ppt_texts)

print("=== PPT CHECKS ===")
old_refs = ['Table 3.3', 'Table 3.4', 'Gemini 1.5', 'Figure 2.1']
for ref in old_refs:
    found = ref in full_ppt
    print(f'  {"FOUND (BAD)" if found else "NOT FOUND (OK)"}: {ref}')

print()

# Check script
script = open('4_DEFENSE_SCRIPT_FINAL.md', encoding='utf-8').read()
print("=== SCRIPT CHECKS ===")
old_refs2 = ['Table 3.3', 'Table 3.4', 'Gemini 1.5', 'Figure 2.1', 'Table 7 show', 'as Table 7']
for ref in old_refs2:
    found = ref in script
    print(f'  {"FOUND (BAD)" if found else "NOT FOUND (OK)"}: {ref}')

print()
print("=== FHS in script ===")
if 'four components' in script.lower():
    idx = script.lower().find('four components')
    print('  Found: ' + script[max(0,idx-20):idx+100])
elif 'savings rate' in script.lower() and 'overspend' in script.lower():
    idx = script.lower().find('savings rate')
    print('  FHS 4-component (savings rate found): ' + script[max(0,idx-20):idx+200])
else:
    print('  FHS 4-component NOT found')

print()
print("=== LLM rationale in script ===")
if 'free tier' in script.lower() or 'free-tier' in script.lower():
    s = script.lower()
    idx = s.find('free tier')
    if idx < 0:
        idx = s.find('free-tier')
    print('  Found free tier mention: ' + script[max(0,idx-50):idx+150])

print()
print("=== 9 recs in script ===")
for i in range(1, 10):
    marker = str(i) + '.'
    # find in recommendations section
    recs_idx = script.find('## Slide 18')
    if recs_idx > 0:
        section = script[recs_idx:recs_idx+2000]
        if marker + ' **' in section or '\n' + str(i) + '. ' in section:
            print(f'  Rec {i}: FOUND in slide 18 section')
        else:
            print(f'  Rec {i}: NOT FOUND in slide 18 section')

print()
print("=== DONE ===")
