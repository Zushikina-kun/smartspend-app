"""
Compute all survey statistics from the Excel response files.
Research survey: N=33
SUS survey: N=30
"""
import openpyxl
from collections import Counter
import statistics

# ── RESEARCH SURVEY ───────────────────────────────────────────────────────────
wb_r = openpyxl.load_workbook(
    'docs/handsoff/SmartSpend_ AI-Assisted Mobile Financial Tracking Evaluation Questionnaire (Responses).xlsx',
    read_only=True, data_only=True
)
ws_r = wb_r.active
rows_r = list(ws_r.iter_rows(values_only=True))
headers_r = rows_r[0]
data_r = rows_r[1:]  # skip header

print(f"=== RESEARCH SURVEY (N={len(data_r)}) ===\n")

# Helper: column index by keyword
def col(headers, keyword):
    for i, h in enumerate(headers):
        if h and keyword.lower() in str(h).lower():
            return i
    return None

# Q1: Age
age_col = col(headers_r, 'age')
ages = [r[age_col] for r in data_r if r[age_col]]
print(f"Q1 Age distribution:")
age_counts = Counter(ages)
for k in sorted(age_counts.keys()):
    n = age_counts[k]
    pct = n/len(data_r)*100
    print(f"  {k}: {n} ({pct:.1f}%)")

# Q2: Category
cat_col = col(headers_r, 'category best describes')
cats = [r[cat_col] for r in data_r if r[cat_col]]
print(f"\nQ2 Category:")
cat_counts = Counter(cats)
for k, v in cat_counts.most_common():
    print(f"  {k}: {v} ({v/len(data_r)*100:.1f}%)")

# Q3: Employment
emp_col = col(headers_r, 'employment status')
emps = [r[emp_col] for r in data_r if r[emp_col]]
print(f"\nQ3 Employment:")
emp_counts = Counter(emps)
for k, v in emp_counts.most_common():
    print(f"  {k}: {v} ({v/len(data_r)*100:.1f}%)")

# Q4: Budget preparation
budget_col = col(headers_r, 'prepare a budget')
budgets = [r[budget_col] for r in data_r if r[budget_col]]
print(f"\nQ4 Do you prepare a budget?")
for k, v in Counter(budgets).most_common():
    print(f"  {k}: {v} ({v/len(data_r)*100:.1f}%)")

# Q5: Savings
savings_col = col(headers_r, 'set aside money for savings')
savings = [r[savings_col] for r in data_r if r[savings_col]]
print(f"\nQ5 Set aside savings before spending?")
for k, v in Counter(savings).most_common():
    print(f"  {k}: {v} ({v/len(data_r)*100:.1f}%)")

# Q6: Challenges (multi-select)
chal_col = col(headers_r, 'main challenges')
challenges_all = []
for r in data_r:
    if r[chal_col]:
        items = str(r[chal_col]).split(';')
        for item in items:
            item = item.strip()
            if item:
                challenges_all.append(item)
print(f"\nQ6 Main financial challenges (multi-select, N responses={len(challenges_all)}):")
for k, v in Counter(challenges_all).most_common(10):
    print(f"  {k}: {v} ({v/len(data_r)*100:.1f}%)")

# Q7: What do you do when exceed budget (multi-select)
exceed_col = col(headers_r, 'exceeded your budget')
exceed_all = []
for r in data_r:
    if r[exceed_col]:
        items = str(r[exceed_col]).split(';')
        for item in items:
            item = item.strip()
            if item:
                exceed_all.append(item)
print(f"\nQ7 When you exceed budget (multi-select):")
for k, v in Counter(exceed_all).most_common():
    print(f"  {k}: {v} ({v/len(data_r)*100:.1f}%)")

# Q8: What would help
help_col = col(headers_r, 'manage your budget more effectively')
help_all = []
for r in data_r:
    if r[help_col]:
        items = str(r[help_col]).split(';')
        for item in items:
            item = item.strip()
            if item:
                help_all.append(item)
print(f"\nQ8 What would help budget management (multi-select):")
for k, v in Counter(help_all).most_common():
    print(f"  {k}: {v} ({v/len(data_r)*100:.1f}%)")

# Q9: Record expenses
record_col = col(headers_r, 'currently record')
records = [r[record_col] for r in data_r if r[record_col]]
print(f"\nQ9 Do you currently record expenses?")
for k, v in Counter(records).most_common():
    print(f"  {k}: {v} ({v/len(data_r)*100:.1f}%)")

# Q10: How record (multi-select)
how_col = col(headers_r, 'how do you record')
how_all = []
for r in data_r:
    if r[how_col]:
        items = str(r[how_col]).split(';')
        for item in items:
            item = item.strip()
            if item:
                how_all.append(item)
print(f"\nQ10 How do you record expenses (multi-select):")
for k, v in Counter(how_all).most_common():
    print(f"  {k}: {v} ({v/len(data_r)*100:.1f}%)")

# Q11: Which expenses track (multi-select)
track_col = col(headers_r, 'usually track')
track_all = []
for r in data_r:
    if r[track_col]:
        items = str(r[track_col]).split(';')
        for item in items:
            item = item.strip()
            if item:
                track_all.append(item)
print(f"\nQ11 Which expenses do you track (multi-select):")
for k, v in Counter(track_all).most_common():
    print(f"  {k}: {v} ({v/len(data_r)*100:.1f}%)")

# Q12: Would use AI app
ai_col = col(headers_r, 'AI-powered financial assistant')
ai_vals = [r[ai_col] for r in data_r if r[ai_col]]
print(f"\nQ12 Would use AI financial app?")
ai_counts = Counter(ai_vals)
for k, v in ai_counts.most_common():
    print(f"  {k}: {v} ({v/len(data_r)*100:.1f}%)")
positive = sum(v for k, v in ai_counts.items() if 'yes' in str(k).lower() or 'probably yes' in str(k).lower() or 'definitely' in str(k).lower())
print(f"  Positive intent (Yes + Probably): {positive} ({positive/len(data_r)*100:.1f}%)")

# Q13: Digital wallets (multi-select)
wallet_col = col(headers_r, 'digital wallets')
wallet_all = []
for r in data_r:
    if r[wallet_col]:
        items = str(r[wallet_col]).split(';')
        for item in items:
            item = item.strip()
            if item:
                wallet_all.append(item)
print(f"\nQ13 Digital wallets used (multi-select):")
for k, v in Counter(wallet_all).most_common():
    print(f"  {k}: {v} ({v/len(data_r)*100:.1f}%)")

print("\n" + "="*60)

# ── SUS SURVEY ────────────────────────────────────────────────────────────────
wb_s = openpyxl.load_workbook(
    'docs/handsoff/SmartSpend Usability Evaluation — SUS Questionnaire (Responses) (1).xlsx',
    read_only=True, data_only=True
)
ws_s = wb_s.active
rows_s = list(ws_s.iter_rows(values_only=True))
headers_s = rows_s[0]
data_s = rows_s[1:]

print(f"\n=== SUS EVALUATION (N={len(data_s)} raw responses) ===\n")

# Filter: only "Yes" to screening question (used app ≥10 min)
screen_col = col(headers_s, 'at least 10 minutes')
valid_s = [r for r in data_s if r[screen_col] and 'yes' in str(r[screen_col]).lower()]
print(f"Screened (used app ≥10 min): {len(valid_s)} valid / {len(data_s)} total")

# SUS Q1-Q10 columns (cols 3-12, 0-indexed)
sus_cols = list(range(3, 13))  # columns D through M
sus_q_labels = [str(headers_s[c])[:60] if headers_s[c] else f'Q{i+1}' for i, c in enumerate(sus_cols)]

# Compute SUS scores
# Odd-indexed (1,3,5,7,9) = score - 1; Even-indexed (2,4,6,8,10) = 5 - score
sus_scores = []
respondent_scores = []

for r in valid_s:
    try:
        q_scores = []
        for i, c in enumerate(sus_cols):
            val = r[c]
            if val is None:
                continue
            val = int(float(str(val)))
            if (i+1) % 2 == 1:  # odd question (1,3,5,7,9)
                q_scores.append(val - 1)
            else:  # even question (2,4,6,8,10)
                q_scores.append(5 - val)
        if len(q_scores) == 10:
            raw = sum(q_scores)
            sus = raw * 2.5
            sus_scores.append(sus)
            respondent_scores.append(sus)
    except (ValueError, TypeError) as e:
        pass

print(f"\nValid SUS scores computed: {len(sus_scores)}")
if sus_scores:
    mean_sus = statistics.mean(sus_scores)
    sd_sus = statistics.stdev(sus_scores) if len(sus_scores) > 1 else 0
    med_sus = statistics.median(sus_scores)
    print(f"Mean SUS: {mean_sus:.2f}")
    print(f"SD: {sd_sus:.2f}")
    print(f"Median: {med_sus:.2f}")
    print(f"Min: {min(sus_scores):.1f}, Max: {max(sus_scores):.1f}")
    print(f"Individual scores: {[round(s,1) for s in sus_scores]}")
    
    # Bangor adjective
    if mean_sus >= 85: adj = 'Excellent'
    elif mean_sus >= 72: adj = 'Good'
    elif mean_sus >= 52: adj = 'OK'
    elif mean_sus >= 39: adj = 'Poor'
    else: adj = 'Awful'
    print(f"Adjective (Bangor 2009): {adj}")
    print(f"Above 68 benchmark: {'Yes' if mean_sus >= 68 else 'No'}")

# Demographics from SUS form
age_col_s = col(headers_s, 'age range')
ages_s = [r[age_col_s] for r in valid_s if r[age_col_s]]
print(f"\nSUS Age groups:")
for k, v in Counter(ages_s).most_common():
    print(f"  {k}: {v}")

desc_col_s = col(headers_s, 'describes you')
descs_s = [r[desc_col_s] for r in valid_s if r[desc_col_s]]
print(f"\nSUS Respondent type:")
for k, v in Counter(descs_s).most_common():
    print(f"  {k}: {v}")

# Per-item means
print(f"\nSUS Per-item means (Likert 1-5):")
for i, c in enumerate(sus_cols):
    vals = [r[c] for r in valid_s if r[c] is not None]
    try:
        nums = [float(str(v)) for v in vals if v]
        if nums:
            mean_val = statistics.mean(nums)
            print(f"  Q{i+1}: {mean_val:.2f} — {sus_q_labels[i][:50]}")
    except:
        pass

print("\nDone.")
