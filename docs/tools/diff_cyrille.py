"""Find what Cyrille added/changed vs the Kiro version."""
from docx import Document

kiro = Document('docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx')
cyrille = Document('docs/handsoff/CAPSTONE_LucidFrame_CYRILLE_VERSION_backup.docx')

kiro_paras = [p.text.strip() for p in kiro.paragraphs if p.text.strip()]
cyrille_paras = [p.text.strip() for p in cyrille.paragraphs if p.text.strip()]

kiro_set = set(kiro_paras)
cyrille_set = set(cyrille_paras)

added = cyrille_set - kiro_set
removed = kiro_set - cyrille_set

print(f'Kiro version: {len(kiro_paras)} non-empty paragraphs')
print(f'Cyrille version: {len(cyrille_paras)} non-empty paragraphs')
print()

print(f'=== ADDED BY CYRILLE ({len(added)} paragraphs) ===')
for p in sorted(added):
    if len(p) > 10:  # skip trivial
        print(f'  + {p[:150]}')

print()
print(f'=== REMOVED BY CYRILLE ({len(removed)} paragraphs) ===')
for p in sorted(removed):
    if len(p) > 10:
        print(f'  - {p[:150]}')
