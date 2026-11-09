from docx import Document
import re

doc_path = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'
doc = Document(doc_path)

print('='*80)
print('COMPREHENSIVE MANUSCRIPT VERIFICATION')
print('='*80)
print()

issues = []
checks_performed = []

# 1. FIGURE VERIFICATION - Enhanced
print('1. FIGURE VERIFICATION (3.4-3.11)')
print('-'*80)
checks_performed.append('Figure presence check (Figures 3.4-3.11)')

figure_captions = {}
for i, para in enumerate(doc.paragraphs):
    match = re.search(r'Figure 3\.(\d+)', para.text)
    if match:
        fig_num = match.group(1)
        if fig_num in ['4', '5', '6', '7', '8', '9', '10', '11']:
            figure_captions[fig_num] = {
                'index': i,
                'caption': para.text.strip()[:100]
            }

# Check for images near each caption
for fig_num in ['4', '5', '6', '7', '8', '9', '10', '11']:
    if fig_num in figure_captions:
        idx = figure_captions[fig_num]['index']
        caption = figure_captions[fig_num]['caption']
        
        # Check 2 paragraphs before and 1 after for images
        has_image = False
        for offset in [-2, -1, 0, 1]:
            check_idx = idx + offset
            if 0 <= check_idx < len(doc.paragraphs):
                para = doc.paragraphs[check_idx]
                if any(run.element.xpath('.//a:blip') for run in para.runs):
                    has_image = True
                    break
        
        if has_image:
            print(f'OK: Figure 3.{fig_num} - Image found')
        else:
            issue = f'Figure 3.{fig_num} has caption but NO IMAGE nearby'
            issues.append(issue)
            print(f'ISSUE: {issue}')
            print(f'  Caption: {caption}')
    else:
        issue = f'Figure 3.{fig_num} - Caption not found'
        issues.append(issue)
        print(f'ISSUE: {issue}')

print()

# 2. DATA ACCURACY
print('2. DATA ACCURACY VERIFICATION')
print('-'*80)
checks_performed.append('Statistical values check (61.83, 17.58, etc.)')
checks_performed.append('Sample size notation check (N=30, n=10, n=20)')
checks_performed.append('Grade classification check')
checks_performed.append('Percentage values check (96.7%, 93.3%)')

full_text = '\n'.join([p.text for p in doc.paragraphs])

# Required values
required_values = [
    ('61.83', 'Mean age'),
    ('17.58', 'Standard deviation'),
    ('96.7%', 'AI intent percentage'),
    ('93.3%', 'GCash usage percentage'),
]

for value, desc in required_values:
    if value in full_text:
        print(f'OK: {value} found ({desc})')
    else:
        issue = f'Missing expected value: {value} ({desc})'
        issues.append(issue)
        print(f'ISSUE: {issue}')

# Check for sample size notations (various formats acceptable)
if 'N=30' in full_text or 'n=30' in full_text or 'N = 30' in full_text or 'n = 30' in full_text:
    print(f'OK: Sample size N=30 found')
else:
    print(f'WARNING: N=30 notation not found (may use different format)')

if '10 parents' in full_text or 'n=10' in full_text or 'n = 10' in full_text:
    print(f'OK: Parent count (10) found')
else:
    print(f'WARNING: Parent count notation unclear')

if '20 young professionals' in full_text or 'n=20' in full_text or 'n = 20' in full_text:
    print(f'OK: Young professional count (20) found')
else:
    print(f'WARNING: YP count notation unclear')

# Check Grade D vs Grade C
if 'Grade D' in full_text:
    print(f'OK: Grade D found (correct classification)')
elif 'Grade C' in full_text:
    issue = 'Found "Grade C" - should be "Grade D"'
    issues.append(issue)
    print(f'ISSUE: {issue}')
else:
    print(f'WARNING: Neither Grade C nor Grade D found')

# Exclusion criteria
if re.search(r'(time|straight)', full_text, re.IGNORECASE):
    print(f'OK: Exclusion criteria keywords present')
else:
    print(f'WARNING: Exclusion criteria text unclear')

print()

# 3. LANGUAGE PROBLEMS
print('3. PROBLEMATIC LANGUAGE CHECK')
print('-'*80)
checks_performed.append('Problematic terminology scan')

problematic = {
    'interview': 'Should be "survey" or "questionnaire"',
    '[PENDING]': 'Placeholder',
    '[TBD]': 'Placeholder',
    'to be inserted': 'Placeholder',
    'Mendez': 'Should be "Raposas"',
}

for term, explanation in problematic.items():
    count = len(re.findall(re.escape(term), full_text, re.IGNORECASE))
    if count > 0:
        issue = f'Found "{term}" ({count}x) - {explanation}'
        issues.append(issue)
        print(f'ISSUE: {issue}')
    else:
        print(f'OK: No "{term}" found')

print()

# 4. CONTENT STRUCTURE
print('4. CONTENT STRUCTURE')
print('-'*80)
checks_performed.append('Document structure completeness')

sections = [
    ('Abstract', r'\bABSTRACT\b'),
    ('Chapter I', r'\bChapter I\b|\bCHAPTER I\b'),
    ('Chapter II', r'\bChapter II\b|\bCHAPTER II\b'),
    ('Chapter III', r'\bChapter III\b|\bCHAPTER III\b'),
    ('Chapter IV', r'\bChapter IV\b|\bCHAPTER IV\b'),
    ('Chapter V', r'\bChapter V\b|\bCHAPTER V\b'),
    ('References', r'\bReferences\b|\bREFERENCES\b'),
    ('Appendix', r'\bAppendix\b|\bAppendices\b|\bAPPENDIX\b'),
]

for section_name, pattern in sections:
    if re.search(pattern, full_text):
        print(f'OK: {section_name} present')
    else:
        issue = f'{section_name} section not found'
        issues.append(issue)
        print(f'ISSUE: {issue}')

print()

# 5. TABLES
print('5. TABLE VERIFICATION')
print('-'*80)
checks_performed.append('Table count and completeness')

table_count = len(doc.tables)
print(f'Total tables: {table_count}')

if table_count >= 5:
    print(f'OK: {table_count} tables present')
else:
    issue = f'Only {table_count} tables found - may be incomplete'
    issues.append(issue)
    print(f'ISSUE: {issue}')

print()

# 6. CITATIONS
print('6. CITATION FORMAT')
print('-'*80)
checks_performed.append('Citation style consistency')

apa_count = len(re.findall(r'\([A-Z][a-z]+,?\s+\d{4}\)', full_text))
bracket_count = len(re.findall(r'\[\d+\]', full_text))

print(f'APA-style citations: {apa_count}')
print(f'Bracket citations: {bracket_count}')

if apa_count > 0 and bracket_count > 0:
    issue = 'Mixed citation styles detected'
    issues.append(issue)
    print(f'ISSUE: {issue}')
elif apa_count > 0 or bracket_count > 0:
    print(f'OK: Citation style appears consistent')
else:
    print(f'WARNING: Few citations detected')

print()

# SUMMARY
print('='*80)
print('SUMMARY')
print('='*80)
print(f'Total checks: {len(checks_performed)}')
print(f'Total issues: {len(issues)}')
print()

if issues:
    print('ISSUES FOUND:')
    for i, issue in enumerate(issues, 1):
        print(f'  {i}. {issue}')
else:
    print('OK: No critical issues detected!')

print()
print('CHECKS PERFORMED:')
for i, check in enumerate(checks_performed, 1):
    print(f'  {i}. {check}')
