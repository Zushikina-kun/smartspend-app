import sys
from docx import Document
from docx.oxml.text.paragraph import CT_P
from docx.oxml.table import CT_Tbl
from docx.table import _Cell, Table
from docx.text.paragraph import Paragraph
import re

doc_path = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'
doc = Document(doc_path)

print('='*80)
print('MANUSCRIPT VERIFICATION REPORT')
print('='*80)
print()

# Track all issues
issues = []
checks_performed = []

# 1. CHECK FOR FIGURES 3.4-3.11
print('1. FIGURE VERIFICATION (3.4-3.11)')
print('-'*80)
checks_performed.append('Figure presence check (3.4-3.11)')

figure_captions = {}
figure_images = {}

for i, para in enumerate(doc.paragraphs):
    text = para.text.strip()
    # Look for figure captions
    if re.search(r'Figure 3\.(4|5|6|7|8|9|10|11)', text):
        fig_match = re.search(r'Figure 3\.(\d+)', text)
        if fig_match:
            fig_num = fig_match.group(1)
            figure_captions[fig_num] = text[:100]
    
    # Check for inline images
    if para.runs:
        for run in para.runs:
            if run.element.xpath('.//a:blip'):
                # Found an image
                nearby_text = para.text[:50] if para.text else ''
                # Check previous/next paragraphs for figure number
                context = ''
                if i > 0:
                    context += doc.paragraphs[i-1].text + ' '
                context += para.text + ' '
                if i < len(doc.paragraphs) - 1:
                    context += doc.paragraphs[i+1].text
                
                fig_match = re.search(r'Figure 3\.(\d+)', context)
                if fig_match:
                    fig_num = fig_match.group(1)
                    figure_images[fig_num] = True

print(f'Figure captions found: {sorted(figure_captions.keys())}')
print(f'Figure images found: {sorted(figure_images.keys())}')

# Check which figures are missing images
for fig_num in ['4', '5', '6', '7', '8', '9', '10', '11']:
    if fig_num in figure_captions:
        if fig_num not in figure_images:
            issue = f'Figure 3.{fig_num} has caption but NO IMAGE: {figure_captions[fig_num]}'
            issues.append(issue)
            print(f'ISSUE: {issue}')
        else:
            print(f'OK: Figure 3.{fig_num} - Image present')
    else:
        issue = f'Figure 3.{fig_num} - Caption not found'
        issues.append(issue)
        print(f'ISSUE: {issue}')

print()

# 2. CHECK DATA ACCURACY
print('2. DATA ACCURACY VERIFICATION')
print('-'*80)
checks_performed.append('Statistical values verification')

full_text = '\n'.join([p.text for p in doc.paragraphs])

# Check for specific values
data_checks = {
    '61.83': 'Mean age value',
    '17.58': 'Standard deviation value',
    'N=30': 'Sample size notation (N=30)',
    'n=30': 'Sample size notation (n=30)',
    'Grade D': 'Grade D classification',
    'Grade C': 'Grade C (should be Grade D)',
    '10 parents': 'Parent count',
    'n=10': 'Parent sample notation',
    '20 young professionals': 'Young professionals count',
    'n=20': 'YP sample notation',
    '96.7%': 'AI intent percentage',
    '93.3%': 'GCash usage percentage',
}

for value, description in data_checks.items():
    if value in full_text:
        if value == 'Grade C':
            issue = f'Found INCORRECT value: {value} - should be Grade D'
            issues.append(issue)
            print(f'ISSUE: {issue}')
        else:
            print(f'OK: Found {value} ({description})')
    else:
        if value not in ['Grade C', 'N=30', 'n=10', 'n=20']:
            print(f'WARNING: NOT found: {value} ({description})')

checks_performed.append('Exclusion criteria text check')
if 'time' in full_text.lower() and 'straight' in full_text.lower():
    print(f'OK: Exclusion criteria text present')
else:
    print(f'WARNING: Exclusion criteria text may be missing')

print()

# 3. LANGUAGE CHECKS
print('3. PROBLEMATIC LANGUAGE CHECK')
print('-'*80)
checks_performed.append('Problematic terminology check')

problematic_terms = {
    'interview': 'Should be "survey"',
    '[PENDING]': 'Placeholder text',
    '[TBD]': 'Placeholder text',
    'to be inserted': 'Placeholder text',
    'Mendez': 'Should be "Raposas"',
}

for term, issue_desc in problematic_terms.items():
    # Case-insensitive search
    if term.lower() in full_text.lower():
        # Find occurrences
        pattern = re.compile(re.escape(term), re.IGNORECASE)
        matches = pattern.findall(full_text)
        count = len(matches)
        issue = f'Found PROBLEMATIC term: {term} ({count} times) - {issue_desc}'
        issues.append(issue)
        print(f'ISSUE: {issue}')
    else:
        print(f'OK: No "{term}" found')

print()

# 4. CONTENT COMPLETENESS
print('4. CONTENT COMPLETENESS')
print('-'*80)
checks_performed.append('Structural completeness check')

# Check for major sections
sections_to_check = [
    ('Abstract', r'\bAbstract\b'),
    ('Chapter 1', r'\bChapter 1\b|\bCHAPTER 1\b'),
    ('Chapter 2', r'\bChapter 2\b|\bCHAPTER 2\b'),
    ('Chapter 3', r'\bChapter 3\b|\bCHAPTER 3\b'),
    ('Chapter 4', r'\bChapter 4\b|\bCHAPTER 4\b'),
    ('Chapter 5', r'\bChapter 5\b|\bCHAPTER 5\b'),
    ('References', r'\bReferences\b|\bREFERENCES\b'),
    ('Appendix', r'\bAppendix\b|\bAPPENDIX\b|\bAppendices\b'),
]

for section_name, pattern in sections_to_check:
    if re.search(pattern, full_text):
        print(f'OK: {section_name} section present')
    else:
        issue = f'{section_name} section not found'
        issues.append(issue)
        print(f'ISSUE: {issue}')

print()

# 5. TABLE CHECK
print('5. TABLE VERIFICATION')
print('-'*80)
checks_performed.append('Table presence and formatting')

table_count = len(doc.tables)
print(f'Total tables found: {table_count}')

if table_count > 0:
    print(f'OK: {table_count} tables present in document')
else:
    issue = 'No tables found - expected multiple tables'
    issues.append(issue)
    print(f'ISSUE: {issue}')

print()

# 6. CITATION CHECK
print('6. CITATION CONSISTENCY')
print('-'*80)
checks_performed.append('Citation format consistency')

# Look for various citation patterns
apa_citations = len(re.findall(r'\([A-Z][a-z]+,?\s+\d{4}\)', full_text))
bracket_citations = len(re.findall(r'\[\d+\]', full_text))

print(f'APA-style citations found: {apa_citations}')
print(f'Bracket-style citations found: {bracket_citations}')

if apa_citations > 0 and bracket_citations > 0:
    issue = 'Mixed citation styles detected (both APA and brackets)'
    issues.append(issue)
    print(f'ISSUE: {issue}')
elif apa_citations > 0 or bracket_citations > 0:
    print(f'OK: Citations appear consistent')
else:
    print(f'WARNING: Few or no citations detected')

print()

# SUMMARY
print('='*80)
print('VERIFICATION SUMMARY')
print('='*80)
print(f'Total checks performed: {len(checks_performed)}')
print(f'Total issues found: {len(issues)}')
print()

if issues:
    print('ISSUES DETECTED:')
    for i, issue in enumerate(issues, 1):
        print(f'{i}. {issue}')
else:
    print('OK: No critical issues detected!')

print()
print('CHECKS PERFORMED:')
for i, check in enumerate(checks_performed, 1):
    print(f'{i}. {check}')
