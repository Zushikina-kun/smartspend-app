"""Inspect Chapter II for validator and appendix mentions."""
from docx import Document

doc = Document('1_MAIN_MANUSCRIPT_FINAL.docx')

ch2_start, ch3_start = None, None
for i, p in enumerate(doc.paragraphs):
    txt = ''.join(r.text for r in p.runs).strip()
    if 'CHAPTER II' in txt.upper() and ch2_start is None:
        ch2_start = i
    if 'CHAPTER III' in txt.upper() and ch3_start is None:
        ch3_start = i

print(f'Ch II: para {ch2_start} to para {ch3_start}')
print()

keywords = ['validator', 'validat', 'appendix d', 'appendix e', 'appendix f',
            'maam', "ma'am", 'abby', 'avigail', 'certificate', 'content valid',
            'review ensure', 'review ensur']

for i in range(ch2_start, ch3_start):
    p = doc.paragraphs[i]
    txt = ''.join(r.text for r in p.runs).strip()
    if any(kw in txt.lower() for kw in keywords):
        print(f'[{i}] {txt[:250]}')

print()
print("--- All Ch II paragraphs (non-empty) ---")
for i in range(ch2_start, ch3_start):
    p = doc.paragraphs[i]
    txt = ''.join(r.text for r in p.runs).strip()
    if txt:
        print(f'[{i}] {txt[:160]}')
