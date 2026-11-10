"""Fix Table 2.1 caption — restore 'and Validators' that V2 removed."""
from docx import Document

FINAL_PATH = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'

doc = Document(FINAL_PATH)
paras = list(doc.paragraphs)

# Para 257 (0-indexed 256): should be 'Table 2.1. Distribution of Respondents and Validators'
p = paras[256]
current = p.text
print(f"Before: {repr(current)}")

for run in p.runs:
    if 'Distribution of Respondents' in run.text and 'and Validators' not in run.text:
        run.text = run.text.rstrip() + ' and Validators'
        print(f"Fixed: added 'and Validators'")
        break

print(f"After:  {repr(p.text)}")

doc.save(FINAL_PATH)
print("Saved.")
