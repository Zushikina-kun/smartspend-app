from docx import Document
import re

DOCX = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\1_MAIN_MANUSCRIPT_FINAL.docx'
doc = Document(DOCX)

paras = [(i, p.text, p.style.name) for i, p in enumerate(doc.paragraphs)]

# Find Scope and Limitations section in body (not TOC)
print('=== Finding Scope section in body ===')
in_scope = False
scope_content = []
for i, text, style in paras:
    utext = text.upper().strip()
    # Detect scope heading (body, not TOC)
    if ('SCOPE' in utext and ('LIMITATION' in utext or 'DELIMITATION' in utext)) and len(text.strip()) < 80:
        if 'Heading' in style or style in ('Heading 1','Heading 2','Heading 3') or utext == text.upper().strip():
            in_scope = True
            scope_content = []
            print(f'  SCOPE START [{i}] style={style}: {text[:100]}')
            continue
    if in_scope:
        # Stop at next heading
        if 'Heading' in style and len(text.strip()) > 2:
            print(f'  SCOPE END [{i}] style={style}: {text[:80]}')
            in_scope = False
            break
        if text.strip():
            scope_content.append((i, text))

print(f'\n  Scope paragraphs: {len(scope_content)}')
for idx, (i, t) in enumerate(scope_content):
    print(f'  PARA {idx+1} [{i}]: {t[:300]}')
    print()

# Also check Flutter/SQLite for citations
print('\n=== Flutter description with citations ===')
in_flutter = False
flutter_text = []
for i, text, style in paras:
    if text.strip().startswith('Flutter.') and 'Flutter was used' in text:
        in_flutter = True
        flutter_text = []
        print(f'  Flutter heading paragraph [{i}]: {text[:300]}')
        continue
    if in_flutter:
        if text.strip() and text.strip()[0].isupper() and '.' in text[:20] and len(text.strip()) < 80:
            # Next technology heading
            break
        if text.strip():
            flutter_text.append((i, text))

for i, t in flutter_text:
    print(f'  [{i}]: {t[:300]}')

has_flutter_citation = any(re.search(r'\([A-Z][a-z]+.*\d{4}', t) for _, t in flutter_text)
print(f'  Flutter has citations: {has_flutter_citation}')

# SQLite description
print('\n=== SQLite description with citations ===')
in_sqlite = False
sqlite_text = []
for i, text, style in paras:
    if text.strip().startswith('SQLite.') and 'SQLite was used' in text:
        in_sqlite = True
        sqlite_text = []
        print(f'  SQLite heading paragraph [{i}]: {text[:300]}')
        continue
    if in_sqlite:
        if text.strip() and re.match(r'^[A-Z][a-zA-Z\s]+\.', text.strip()) and len(text.strip()) < 100:
            break
        if text.strip():
            sqlite_text.append((i, text))

for i, t in sqlite_text:
    print(f'  [{i}]: {t[:300]}')

has_sqlite_citation = any(re.search(r'\([A-Z][a-z]+.*\d{4}', t) for _, t in sqlite_text)
print(f'  SQLite has citations: {has_sqlite_citation}')

# Check the Flutter. heading paragraph for citations
print('\n=== Full Flutter/SQLite paragraph text (single paragraph entries) ===')
for i, text, style in paras:
    if text.strip().startswith('Flutter.'):
        print(f'[{i}] FLUTTER PARA: {text[:500]}')
        print(f'  Has citation: {bool(re.search(r"\([A-Z][a-z]+", text))}')
    if text.strip().startswith('SQLite.'):
        print(f'[{i}] SQLITE PARA: {text[:500]}')
        print(f'  Has citation: {bool(re.search(r"\([A-Z][a-z]+", text))}')
    if text.strip().startswith('Firebase.'):
        print(f'[{i}] FIREBASE PARA: {text[:500]}')
