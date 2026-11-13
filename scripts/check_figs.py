from docx import Document
import re
doc = Document(r'docs/handsoff/FOR_CYRILLE/1_MAIN_MANUSCRIPT_FINAL.docx')
paras = doc.paragraphs
print(f'Total paragraphs: {len(paras)}')
for i, p in enumerate(paras):
    t = p.text.strip()
    if re.match(r'(?i)^figure\s+\d+', t):
        # Caption: "Figure N.  Title" or "Figure N\tTitle"
        # Description: "Figure N shows/presents/displays..."
        is_cap = bool(re.match(r'(?i)^figure\s+\d+\s*[\.]\s+[A-Z]', t)) or bool(re.match(r'(?i)^figure\s+\d+\s*\t', t))
        label = 'CAP' if is_cap else 'DESC'
        print(f'[{i:04d}] {label} {t[:110]!r}')
