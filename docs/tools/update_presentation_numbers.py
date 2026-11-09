"""
Update all presentation and defense script files with final manuscript numbers:
- SUS: 61.83 (SD=17.58), Grade D, adjective "OK"
- N=30 (5 excluded for time, 1 for straight-line bias)
- Parents: n=10, mean=58.25, SD=19.72
- Young Professionals: n=20, mean=63.62, SD=16.65
- Median: 55.00
- Range: 35.0-92.5
"""
import re

# Final numbers from manuscript
FINAL_NUMBERS = {
    'sus_mean': '61.83',
    'sus_sd': '17.58',
    'sus_median': '55.00',
    'sus_grade': 'D',
    'sus_adjective': 'OK',
    'sus_n': '30',
    'parent_n': '10',
    'parent_mean': '58.25',
    'parent_sd': '19.72',
    'yp_n': '20',
    'yp_mean': '63.62',
    'yp_sd': '16.65',
    'sus_min': '35.0',
    'sus_max': '92.5',
    'excluded_total': '6',
    'excluded_time': '5',
    'excluded_bias': '1',
}

files_to_update = [
    'docs/capstone/SmartSpend_Defense_Presentation.html',
    'docs/manuscript/reseaches/smartspend-thesis-defense-script.md',
]

def update_file(fpath):
    with open(fpath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original = content
    
    # Update SUS mean (various formats)
    content = re.sub(r'\b62\.50\b', FINAL_NUMBERS['sus_mean'], content)
    content = re.sub(r'\b63\.06\b', FINAL_NUMBERS['sus_mean'], content)
    content = re.sub(r'SUS\s+(?:score|mean)?\s*[=:]?\s*\d+\.?\d*', f'SUS score = {FINAL_NUMBERS["sus_mean"]}', content, flags=re.IGNORECASE)
    
    # Update SD
    content = re.sub(r'SD\s*[=:]?\s*\d+\.?\d*', f'SD = {FINAL_NUMBERS["sus_sd"]}', content)
    
    # Update median
    content = re.sub(r'\b52\.50\b', FINAL_NUMBERS['sus_median'], content)
    content = re.sub(r'Median\s*[=:]?\s*\d+\.?\d*', f'Median = {FINAL_NUMBERS["sus_median"]}', content)
    
    # Update grade references
    content = re.sub(r'Grade\s+[CF](?!\w)', f'Grade {FINAL_NUMBERS["sus_grade"]}', content)
    
    # Update range
    content = re.sub(r'\b35\.0\s*[-–]\s*100\.0\b', f'{FINAL_NUMBERS["sus_min"]}–{FINAL_NUMBERS["sus_max"]}', content)
    
    # Update exclusion text
    content = re.sub(
        r'6\s+(?:were\s+)?excluded\s+for\s+insufficient\s+app\s+usage\s+time',
        f'{FINAL_NUMBERS["excluded_time"]} excluded for insufficient app usage time and {FINAL_NUMBERS["excluded_bias"]} excluded for straight-line response bias',
        content
    )
    
    # Update parent stats
    content = re.sub(r'Parents.*?n\s*[=:]?\s*\d+', f'Parents (n={FINAL_NUMBERS["parent_n"]})', content)
    content = re.sub(r'Young\s+Professionals.*?n\s*[=:]?\s*\d+', f'Young Professionals (n={FINAL_NUMBERS["yp_n"]})', content)
    
    # Update acceptance threshold text
    content = re.sub(
        r'acceptance\s+threshold\s+at\s+a\s+score\s+of\s+\*\*80\s+or\s+above\*\*',
        f'acceptance threshold at a score of **68 or above** (industry benchmark)',
        content
    )
    content = re.sub(
        r'adjective\s+rating\s+of\s+\*\*[\'"]?Good[\'"]?\*\*',
        f'adjective rating of **"OK"** (Bangor et al., 2009)',
        content
    )
    
    if content != original:
        with open(fpath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f'✓ Updated: {fpath}')
        return True
    else:
        print(f'○ No changes: {fpath}')
        return False

print("Updating presentation and defense files with final numbers...")
print()
for fpath in files_to_update:
    try:
        update_file(fpath)
    except FileNotFoundError:
        print(f'✗ Not found: {fpath}')
    except Exception as e:
        print(f'✗ Error in {fpath}: {e}')

print()
print("Final numbers applied:")
for k, v in FINAL_NUMBERS.items():
    print(f"  {k}: {v}")
