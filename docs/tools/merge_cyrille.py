"""Apply Cyrille's legitimate changes to the Kiro-fixed version."""
from docx import Document
import re

doc = Document('docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx')
fixes = 0

# Cyrille updated page numbers in the TOC/List entries
# These are the TOC lines he updated - apply the new page numbers
toc_updates = {
    'APPENDICES': ('45', '73'),
    'Appendix A': ('45', '73'),
    'Appendix B': ('52', '81'),
    'Appendix C': ('54', '83'),
    'CURRICULUM VITAE': ('56', '85'),
    'REFERENCES': ('40', '65'),
}

for para in doc.paragraphs:
    t = para.text.strip()
    for keyword, (old_page, new_page) in toc_updates.items():
        if keyword in t and old_page in t:
            for run in para.runs:
                if old_page in run.text:
                    run.text = run.text.replace(old_page, new_page)
                    fixes += 1
                    print(f'Updated TOC page: {t[:80]} ({old_page}→{new_page})')
            # Also try XML
            for elem in para._p.iter():
                if hasattr(elem, 'text') and elem.text and old_page in elem.text and keyword in para.text:
                    elem.text = elem.text.replace(old_page, new_page)
                    fixes += 1

doc.save('docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx')
print(f'\nApplied {fixes} legitimate changes from Cyrille')

# Verify the important fixes are still intact
doc2 = Document('docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx')
full = ' '.join(p.text for p in doc2.paragraphs)
for t in ['Mangaoang, DIT', 'Layco, MIS', '62.50', '34 agentic', '36 achievement']:
    found = t.lower() in full.lower()
    print(f'  {"OK" if found else "MISSING"}: {t}')
for bad in ['Mangaoang, MIT', 'Verzola', '31 agentic', '25 achievement badges']:
    found = bad.lower() in full.lower()
    print(f'  {"CLEAN" if not found else "PROBLEM"}: no {bad}')
