"""Compute SUS group stats for Table 3.4 from the actual final Excel file."""
import openpyxl, statistics
from collections import Counter

wb = openpyxl.load_workbook(
    'docs/handsoff/survey_data/03_SUS_Responses_FINAL_N36.xlsx',
    read_only=True, data_only=True
)
ws = wb.active
rows = list(ws.iter_rows(values_only=True))
headers = rows[0]
data = rows[1:]

# Find columns
def col(keyword):
    for i, h in enumerate(headers):
        if h and keyword.lower() in str(h).lower():
            return i
    return None

screen_col = col('10 minutes')
desc_col = col('describes you')
sus_cols = list(range(3, 13))

# Get screened respondents
screened = [r for r in data if r[screen_col] and 'yes' in str(r[screen_col]).lower()]
print(f"Total screened: {len(screened)}")

# Compute SUS score per respondent
def sus_score(r):
    try:
        q = []
        for i, c in enumerate(sus_cols):
            val = r[c]
            if val is None: return None
            v = int(float(str(val)))
            if (i+1) % 2 == 1:
                q.append(v - 1)
            else:
                q.append(5 - v)
        if len(q) == 10:
            return sum(q) * 2.5
    except:
        return None

# Group by respondent type
groups = {'Parents': [], 'Young Professionals': [], 'Both': [], 'Other': []}
for r in screened:
    score = sus_score(r)
    if score is None:
        continue
    desc = str(r[desc_col]).lower() if r[desc_col] else ''
    if 'parent' in desc and 'young' not in desc:
        groups['Parents'].append(score)
    elif 'young' in desc and 'parent' not in desc:
        groups['Young Professionals'].append(score)
    elif 'both' in desc or ('parent' in desc and 'young' in desc):
        groups['Both'].append(score)
    else:
        groups['Other'].append(score)

print()
for group, scores in groups.items():
    if not scores:
        continue
    n = len(scores)
    mean = statistics.mean(scores)
    sd = statistics.stdev(scores) if n > 1 else 0
    med = statistics.median(scores)
    mn = min(scores)
    mx = max(scores)
    print(f"{group} (n={n}):")
    print(f"  Mean={mean:.2f}, SD={sd:.2f}, Median={med:.2f}, Min={mn:.1f}, Max={mx:.1f}")
    print(f"  Scores: {sorted([round(s,1) for s in scores], reverse=True)}")
    print()

# Overall
all_scores = [s for g in groups.values() for s in g]
print(f"Overall (n={len(all_scores)}):")
print(f"  Mean={statistics.mean(all_scores):.2f}, SD={statistics.stdev(all_scores):.2f}, Median={statistics.median(all_scores):.2f}")

# Check the "separate groups" question
print()
print("NOTE: These are the SUS respondents.")
print("The needs-survey respondents are in a different file.")
print("They may overlap but are treated as separate populations.")
