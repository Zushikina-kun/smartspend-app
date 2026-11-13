"""Check where Part C terms appear in the manuscript."""
from docx import Document
import re

doc = Document('1_MAIN_MANUSCRIPT_FINAL.docx')

terms = [
    'supports', 'influences', 'offers', 'have been replaced',
    'shows', 'first shows', 'indicates this is', 'has been set',
    'have been identified', 'has been fully implemented',
    'integrates',
]

print("=== Searching for Part C terms in body paragraphs ===")
for i, p in enumerate(doc.paragraphs):
    txt = ''.join(r.text for r in p.runs)
    for term in terms:
        if term.lower() in txt.lower():
            print(f"[{i}] FOUND '{term}': {txt[:160]}")
            break

print()
print("=== Checking Chapter III range ===")
ch3_start = ch4_start = None
for i, p in enumerate(doc.paragraphs):
    txt = ''.join(r.text for r in p.runs).strip()
    if 'CHAPTER III' in txt.upper() and ch3_start is None:
        ch3_start = i
    if 'CHAPTER IV' in txt.upper() and ch4_start is None:
        ch4_start = i
print(f"Ch3 start: {ch3_start}, Ch4 start: {ch4_start}")

if ch3_start and ch4_start:
    print(f"\n=== Ch III paragraphs {ch3_start} to {ch4_start} ===")
    for i in range(ch3_start, ch4_start):
        p = doc.paragraphs[i]
        txt = ''.join(r.text for r in p.runs).strip()
        for term in terms:
            if term.lower() in txt.lower():
                print(f"  [{i}] FOUND '{term}': {txt[:160]}")
                break
