from docx import Document
import re

DOCX = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\1_MAIN_MANUSCRIPT_FINAL.docx'
doc = Document(DOCX)
paras = [(i, p.text, p.style.name) for i, p in enumerate(doc.paragraphs)]
all_text = '\n'.join(p.text for p in doc.paragraphs)
table_text = '\n'.join(c.text for t in doc.tables for row in t.rows for c in row.cells)
full_doc = all_text + '\n' + table_text

# Count LLM models in table 6
print('=== LLM Table 6 model count ===')
for t in doc.tables:
    flat = ' '.join(c.text for row in t.rows for c in row.cells).lower()
    if 'gemini' in flat and 'groq' in flat:
        print(f'  Rows: {len(t.rows)}')
        for row in t.rows:
            cells = [c.text.strip() for c in row.cells]
            print(f'  {cells[:3]}')  # just first 3 cols

# Check for Table 9 anywhere
print('\n=== Table 9 search ===')
print(f'  "Table 9" in body text: {"Table 9" in all_text}')
print(f'  "Table 9" in table cells: {"Table 9" in table_text}')
print(f'  "Table 9" in full_doc: {"Table 9" in full_doc}')

# Check TOC for Table 9
for i, text, style in paras:
    if 'table 9' in text.lower() or ('9.' in text and 'multimodal' in text.lower()):
        print(f'  [{i}] style={style}: {text[:200]}')

# Check for the TOC entry "3.5" and what number maps to multimodal table
for i, text, style in paras:
    if '3.5' in text and ('multimodal' in text.lower() or 'parsing' in text.lower()):
        print(f'  TOC [{i}]: {text[:200]}')

# Check text around Table 8 for what comes after
print('\n=== After Table 8 caption ===')
for i, text, style in paras:
    if 'Table 8:' in text:
        print(f'  Table 8 at [{i}]: {text[:100]}')
        # Print next 15 paras
        for j in range(i+1, min(len(paras), i+20)):
            pi, pt, ps = paras[j]
            if pt.strip():
                print(f'  [{pi}] style={ps}: {pt[:200]}')

# How many total named tables are there?
print('\n=== All Table captions ===')
for i, text, style in paras:
    if re.match(r'\s*Table \d+[:\s]', text):
        print(f'  [{i}]: {text[:150]}')
        
# Check what text says about 8 LLM APIs
print('\n=== 8 LLM APIs text ===')
for i, text, style in paras:
    if ('eight' in text.lower() or '8' in text) and ('api' in text.lower() or 'llm' in text.lower()):
        if 'evaluat' in text.lower() or 'compar' in text.lower() or 'provider' in text.lower():
            print(f'  [{i}]: {text[:300]}')
