#!/usr/bin/env python3
"""Find key text passages in the manuscript for audit."""
from docx import Document
import re

MANUSCRIPT = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx"
doc = Document(MANUSCRIPT)
paras = doc.paragraphs

print("=== SEARCHING FOR 'Paluwagan' in body text ===")
for i, p in enumerate(paras):
    if 'Paluwagan' in p.text or 'paluwagan' in p.text:
        print(f"  [{i}]: {p.text.strip()[:200]}")

print("\n=== SEARCHING FOR 'Priority 9' ===")
for i, p in enumerate(paras):
    if 'Priority 9' in p.text:
        print(f"  [{i}]: {p.text.strip()[:200]}")

print("\n=== SEARCHING FOR 'Recommendation 6' ===")
for i, p in enumerate(paras):
    if 'Recommendation 6' in p.text or 'Recommendation 5' in p.text:
        print(f"  [{i}]: {p.text.strip()[:200]}")

print("\n=== SEARCHING FOR '36 badges' OR 'badge' near '36' ===")
for i, p in enumerate(paras):
    t = p.text.strip()
    if ('36 badge' in t.lower() or ('badge' in t.lower() and '36' in t)) and len(t) > 10:
        print(f"  [{i}]: {t[:200]}")

print("\n=== SEARCHING FOR '34 AI' or '34 agentic' ===")
for i, p in enumerate(paras):
    t = p.text.strip()
    if ('34 AI' in t or '34 agentic' in t.lower() or '34 ai' in t.lower()) and len(t) > 5:
        print(f"  [{i}]: {t[:200]}")

print("\n=== SEARCHING FOR 'v3.1.0' ===")
for i, p in enumerate(paras):
    t = p.text.strip()
    if 'v3.1.0' in t or 'v3.1' in t or '3.1.0' in t:
        print(f"  [{i}]: {t[:200]}")

print("\n=== FIGURE 2.1 SURROUNDING CONTEXT (para 278-285) ===")
for i in range(278, 286):
    t = paras[i].text.strip() if i < len(paras) else "(OOB)"
    from docx.oxml.ns import qn
    has_img = bool(list(paras[i]._p.iter(qn('a:blip')))) if i < len(paras) else False
    print(f"  [{i}] img={has_img}: {t[:120]}")

print("\n=== SEARCHING FOR Figure 3.12/3.13/3.14 captions ===")
for i, p in enumerate(paras):
    t = p.text.strip()
    if re.search(r'Figure\s*3\.1[234]', t):
        print(f"  [{i}]: {t[:200]}")

print("\n=== SEARCHING FOR SUS result/discussion area (para 360-400) ===")
for i in range(358, 380):
    if i < len(paras):
        t = paras[i].text.strip()
        if t:
            print(f"  [{i}]: {t[:120]}")
