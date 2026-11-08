import openpyxl, statistics
from collections import Counter

fname = 'docs/handsoff/SmartSpend Usability Evaluation — SUS Questionnaire (Responses) (2).xlsx'
wb = openpyxl.load_workbook(fname, read_only=True, data_only=True)
ws = wb.active
rows = list(ws.iter_rows(values_only=True))
headers = rows[0]
data = rows[1:]

print(f"FILE: (2).xlsx")
print(f"Total rows: {len(data)}")
print(f"Columns: {len(headers)}")
print(f"Headers:")
for i, h in enumerate(headers):
    if h: print(f"  {i}: {str(h)[:70]}")

# Find screening column
screen_col = None
for i, h in enumerate(headers):
    if h and '10 minutes' in str(h).lower():
        screen_col = i
        break

if screen_col is not None:
    valid = [r for r in data if r[screen_col] and 'yes' in str(r[screen_col]).lower()]
    print(f"\nScreened (>=10 min): {len(valid)} / {len(data)}")
else:
    valid = data
    print(f"\nNo screening col found — using all {len(data)} rows")

# SUS Q1-Q10 cols 3-12
sus_cols = list(range(3, 13))
sus_scores = []
for r in valid:
    try:
        q = []
        for i, c in enumerate(sus_cols):
            val = r[c]
            if val is None: continue
            v = int(float(str(val)))
            if (i+1) % 2 == 1:
                q.append(v - 1)
            else:
                q.append(5 - v)
        if len(q) == 10:
            sus_scores.append(sum(q) * 2.5)
    except: pass

print(f"\nValid SUS scores: {len(sus_scores)}")
if sus_scores:
    m = statistics.mean(sus_scores)
    sd = statistics.stdev(sus_scores) if len(sus_scores) > 1 else 0
    print(f"Mean: {m:.2f}")
    print(f"SD: {sd:.2f}")
    print(f"Median: {statistics.median(sus_scores):.2f}")
    print(f"Min: {min(sus_scores):.1f}  Max: {max(sus_scores):.1f}")
    print(f"Scores: {sorted([round(s,1) for s in sus_scores], reverse=True)}")
    if m >= 85: adj = 'Excellent'
    elif m >= 72: adj = 'Good'
    elif m >= 52: adj = 'OK'
    elif m >= 39: adj = 'Poor'
    else: adj = 'Awful'
    print(f"Adjective (Bangor 2009): {adj}")
    print(f"Above 68 benchmark: {'YES' if m >= 68 else 'NO'}")

# Demographics
desc_col = None
for i, h in enumerate(headers):
    if h and 'describes you' in str(h).lower():
        desc_col = i
        break
if desc_col:
    descs = [r[desc_col] for r in valid if r[desc_col]]
    print(f"\nRespondent type (N={len(descs)}):")
    for k, v in Counter(descs).most_common():
        print(f"  {k}: {v} ({v/len(descs)*100:.1f}%)")

age_col = None
for i, h in enumerate(headers):
    if h and 'age range' in str(h).lower():
        age_col = i
        break
if age_col:
    ages = [r[age_col] for r in valid if r[age_col]]
    print(f"\nAge groups:")
    for k, v in Counter(ages).most_common():
        print(f"  {k}: {v}")

# Per-item means
print(f"\nPer-item means:")
q_labels = [str(headers[c])[:50] if headers[c] else f'Q{i+1}' for i,c in enumerate(sus_cols)]
for i, c in enumerate(sus_cols):
    vals = [float(str(r[c])) for r in valid if r[c] is not None]
    if vals:
        print(f"  Q{i+1} ({statistics.mean(vals):.2f}): {q_labels[i]}")
