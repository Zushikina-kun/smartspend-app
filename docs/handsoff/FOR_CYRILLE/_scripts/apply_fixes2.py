"""
apply_fixes2.py — Targeted follow-up fixes for skipped items.
"""
import os
import re
from copy import deepcopy
from docx import Document
from docx.oxml.ns import qn

OUTPUT = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx"

doc = Document(OUTPUT)

def get_text(p):
    return ''.join(r.text or '' for r in p.runs)

def set_cell_text(cell, new_text):
    for para in cell.paragraphs:
        for run in para.runs:
            run.text = ''
    if cell.paragraphs:
        cell.paragraphs[0].clear()
        cell.paragraphs[0].add_run(new_text)
    else:
        cell.add_paragraph(new_text)

def set_paragraph_text(p, new_text):
    p.clear()
    p.add_run(new_text)

def replace_in_paragraph(p, old, new):
    full = "".join(r.text or "" for r in p.runs)
    if old in full:
        new_full = full.replace(old, new)
        if p.runs:
            p.runs[0].text = new_full
            for r in p.runs[1:]:
                r.text = ""
        else:
            p.add_run(new_full)
        return True
    return False

# ─── FIX 1: Distribution of Respondents — SKIPPED per correction ─────────────
# NOTE: Parents count stays at 16. The 3 "both" respondents were reclassified as
# parents, so Parents=16, Young Professionals=14, Total=30 is correct. Do NOT
# change 16 to 13, and do NOT add a Both Groups row.
print("=== Fix 1: Table 2 — SKIPPED (Parents=16 is correct per correction) ===")

# ─── FIX 2: LLM Table 5 — delete Mistral 7B and Gemma 2 9B rows ──────────────
print("\n=== Fix 2: LLM Table 5 — delete unwanted model rows ===")

table5 = doc.tables[5]
print("LLM Table 5 before:")
for i, row in enumerate(table5.rows):
    print(f"  Row {i}: {[c.text.strip()[:30] for c in row.cells]}")

MODELS_TO_DELETE = [
    "gpt-4o mini", "claude", "grok", "deepseek", "fin-r1",
    "mistral", "gemma", "llama 4 scout", "llama 3.3", "llama 3.1 8b"
]
MODELS_TO_KEEP_LOWER = [
    "gemini", "gpt-oss", "qwen", "groq compound", "cerebras"
]

rows_to_delete = []
for i, row in enumerate(table5.rows):
    combined = " ".join(c.text.strip().lower() for c in row.cells)
    # Skip header row
    if i == 0:
        continue
    # Check if it should be deleted
    should_del = False
    for del_m in MODELS_TO_DELETE:
        if del_m in combined:
            # Make sure it's not a keep model
            keep_found = any(km in combined for km in MODELS_TO_KEEP_LOWER)
            if not keep_found:
                should_del = True
                break
    if should_del:
        rows_to_delete.append(row)
        print(f"  Marking Row {i} for deletion: {[c.text.strip()[:30] for c in row.cells]}")

for row in rows_to_delete:
    tbl_el = row._tr.getparent()
    tbl_el.remove(row._tr)

print(f"Deleted {len(rows_to_delete)} rows.")
print("LLM Table 5 after:")
for i, row in enumerate(table5.rows):
    print(f"  Row {i}: {[c.text.strip()[:30] for c in row.cells]}")

# ─── FIX 3: SUS benchmark text fix ───────────────────────────────────────────
print("\n=== Fix 3: SUS benchmark description ===")

# The actual text found was: "...which was..." — let's search more broadly
sus_fix_found = False
for p in doc.paragraphs:
    txt = get_text(p)
    # Check for the paragraph containing SUS score and "below"
    if "61.83" in txt and ("below" in txt.lower() or "benchmark" in txt.lower()):
        print(f"Found SUS para: {txt[:200]}")
        # Try exact match first
        old_phrase = "below the ≥80 target but acceptable for a prototype system"
        if old_phrase in txt:
            replace_in_paragraph(p, old_phrase, "below both the 68-point average benchmark and the pre-established target of 80")
            print("  Applied exact SUS benchmark fix")
            sus_fix_found = True
        else:
            # Try variations
            variations = [
                ("below the ≥80 target but acceptable", "below both the 68-point average benchmark and the pre-established target of 80"),
                ("below the 80 target but acceptable for a prototype system", "below both the 68-point average benchmark and the pre-established target of 80"),
            ]
            for old_v, new_v in variations:
                if old_v in txt:
                    replace_in_paragraph(p, old_v, new_v)
                    print(f"  Applied SUS benchmark fix (variant: '{old_v}')")
                    sus_fix_found = True
                    break

# Also search all paragraphs for "prototype system"
if not sus_fix_found:
    for p in doc.paragraphs:
        txt = get_text(p)
        if "prototype system" in txt.lower():
            print(f"  'prototype system' para: {txt[:200]}")

# ─── FIX 4: Scan for 93.3% already use GCash ─────────────────────────────────
print("\n=== Fix 4: 93.3% tense ===")
for p in doc.paragraphs:
    txt = get_text(p)
    if "93.3%" in txt and "GCash" in txt:
        print(f"  Found: {txt[:200]}")

# Also check in tables
for table in doc.tables:
    for row in table.rows:
        for cell in row.cells:
            for p in cell.paragraphs:
                txt = get_text(p)
                if "93.3%" in txt and "GCash" in txt:
                    print(f"  Found in table: {txt[:200]}")

# ─── Save ─────────────────────────────────────────────────────────────────────
doc.save(OUTPUT)
print(f"\nSaved to {OUTPUT}")
