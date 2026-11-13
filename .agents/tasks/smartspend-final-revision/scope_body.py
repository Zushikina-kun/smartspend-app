from docx import Document
import re

DOCX = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\1_MAIN_MANUSCRIPT_FINAL.docx'
doc = Document(DOCX)

paras = [(i, p.text, p.style.name) for i, p in enumerate(doc.paragraphs)]

# Print all paragraphs with their styles around the Scope section in body
# (not the TOC) - look for heading styles
print('=== Headings near Scope ===')
for i, text, style in paras:
    if 'Heading' in style or 'heading' in style.lower():
        if i > 150 and i < 280:
            print(f'  [{i}] style={style}: {text[:100]}')

# Find actual body Scope section by heading style
print('\n=== Scope body content ===')
in_scope = False
scope_paras = []
for i, text, style in paras:
    utext = text.upper().strip()
    if ('SCOPE' in utext and 'LIMITATION' in utext) and ('Heading' in style or utext == text.strip().upper()):
        if i > 150:  # skip TOC area
            in_scope = True
            scope_paras = []
            print(f'  BODY SCOPE START [{i}] style={style}: {text}')
            continue
    if in_scope:
        if ('Heading' in style) and len(text.strip()) > 2 and text.strip() != text.strip().upper() == False:
            if re.match(r'^(CHAPTER|POPULATION|RESEARCH DESIGN|DATA|METHODOLOGY|BACKGROUND|REVIEW|CONCEPTUAL)', utext):
                print(f'  BODY SCOPE END [{i}] style={style}: {text[:80]}')
                in_scope = False
                break
        if text.strip():
            scope_paras.append((i, text, style))

print(f'\n  Scope body paragraphs found: {len(scope_paras)}')
for idx, (i, t, s) in enumerate(scope_paras[:20]):
    print(f'  PARA {idx+1} [{i}] style={s}: {t[:300]}')

# Also look for "Scope" heading outside TOC
print('\n=== All "scope" occurrences with style ===')
for i, text, style in paras:
    if 'scope' in text.lower() and 'limitation' in text.lower() and i > 150:
        print(f'  [{i}] style={style}: {text[:150]}')

# Flutter citation check - what appears after Flutter. paragraph
print('\n=== Flutter paragraph and following paragraphs ===')
for i, text, style in paras:
    if text.strip().startswith('Flutter.') and i > 150:
        print(f'[{i}] style={style}: {text[:600]}')
        # Check if any citation (Author, Year) in it
        citations = re.findall(r'\([A-Z][a-z]+[^)]*\d{4}[^)]*\)', text)
        print(f'  Citations found: {citations}')
        break

# Population paragraph - 13 parents issue
print('\n=== Population paragraph with 13 ===')
for i, text, style in paras:
    if 'thirteen (13)' in text.lower() or ('13' in text and 'parent' in text.lower()):
        print(f'[{i}] style={style}: {text[:400]}')

# Check Table 5 note text
print('\n=== Table 5 note ===')
for i, text, style in paras:
    if 'table 5' in text.lower() and ('note' in text.lower() or '13' in text):
        print(f'[{i}] style={style}: {text[:400]}')

# The note in Table 5
for t in doc.tables:
    flat = ' '.join(c.text for row in t.rows for c in row.cells)
    if 'demographic' in flat.lower() or ('13' in flat and 'parent' in flat.lower()):
        print(f'\n=== Table with 13/parents ===')
        for row in t.rows[-3:]:
            cells = [c.text.strip()[:60] for c in row.cells]
            if any(cells):
                print(f'  {cells}')
        # Check note in next paragraph
        break
