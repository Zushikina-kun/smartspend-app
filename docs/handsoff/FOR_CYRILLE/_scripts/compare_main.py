from docx import Document
from docx.oxml.ns import qn

MAIN_PATH = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\1_MAIN_MANUSCRIPT_FINAL(MAIN).docx'
OURS_PATH = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'

main = Document(MAIN_PATH)
ours = Document(OURS_PATH)

main_imgs = sum(len(p._p.findall('.//' + qn('a:blip'))) for p in main.paragraphs)
our_imgs  = sum(len(p._p.findall('.//' + qn('a:blip'))) for p in ours.paragraphs)

print(f'YOUR MAIN: {len(main.paragraphs)} paras, {len(main.tables)} tables, {main_imgs} images')
print(f'OUR FINAL: {len(ours.paragraphs)} paras, {len(ours.tables)} tables, {our_imgs} images')

vals = ['61.83','Avigail','Jeoffrey','Shekiro','MTS, MIS','partially achieved','sqflite','grade of D']
print()
print('=== Protected values in YOUR MAIN ===')
for v in vals:
    found = any(v in p.text for p in main.paragraphs)
    status = "OK" if found else "MISSING"
    print(f'  {status}: {v}')

print()
print('=== Abstract YOUR MAIN (paras 50-56) ===')
for i in range(50, 57):
    t = main.paragraphs[i].text.strip()
    if t: print(f'  [{i}] {t[:130]}')

print()
print('=== Acknowledgements YOUR MAIN (paras 54-66) ===')
for i in range(54, 67):
    t = main.paragraphs[i].text.strip()
    if t: print(f'  [{i}] {t[:130]}')

print()
print('=== Recommendations YOUR MAIN ===')
in_recs = False
for i, p in enumerate(main.paragraphs):
    t = p.text.strip()
    if 'Recommendation' in t and i > 380:
        in_recs = True
    if in_recs and t:
        print(f'  [{i}] {t[:130]}')
    if in_recs and 'References' in t:
        break

print()
print('=== References first 10 entries in YOUR MAIN ===')
in_refs = False
count = 0
for i, p in enumerate(main.paragraphs):
    t = p.text.strip()
    if t == 'References' and i > 380:
        in_refs = True
        print(f'  [{i}] REFERENCES HEADING')
        continue
    if in_refs and t:
        print(f'  [{i}] {t[:120]}')
        count += 1
        if count >= 12:
            break

print()
print('=== Figure 3.8 and 3.9 captions in YOUR MAIN ===')
for i, p in enumerate(main.paragraphs):
    t = p.text.strip()
    if 'Figure 3.8' in t or 'Figure 3.9' in t:
        print(f'  [{i}] {t[:150]}')
        # Check if prev para has an image
        if i > 0:
            has = bool(main.paragraphs[i-1]._p.findall('.//' + qn('a:blip')))
            print(f'       prev para has image: {has}')
