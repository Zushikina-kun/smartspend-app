"""
Clean survey data to exact N=30 each.
Research survey: N=33 → take first 30 or best 30 (exclude incomplete/outlier)
SUS: N=31 screened from N=36 → take first 30 screened

Also add Q&A note about separate respondents.
"""
import openpyxl, statistics
from collections import Counter

# ── SUS: take first 30 screened responses ────────────────────────────────────
wb_s = openpyxl.load_workbook(
    'docs/handsoff/SmartSpend Usability Evaluation — SUS Questionnaire (Responses) (2).xlsx',
    read_only=True, data_only=True
)
ws_s = wb_s.active
rows_s = list(ws_s.iter_rows(values_only=True))
headers_s = rows_s[0]
data_s = rows_s[1:]

# Find screening col
screen_col = None
for i, h in enumerate(headers_s):
    if h and '10 minutes' in str(h).lower():
        screen_col = i
        break

# Get all screened (Yes) responses
screened = [r for r in data_s if r[screen_col] and 'yes' in str(r[screen_col]).lower()]
print(f"SUS total screened: {len(screened)} — taking first 30")
sus_30 = screened[:30]

# Compute SUS scores for N=30
sus_cols = list(range(3, 13))
sus_scores_30 = []
for r in sus_30:
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
            sus_scores_30.append(sum(q) * 2.5)
    except: pass

print(f"\nSUS N=30 results:")
print(f"  Scores computed: {len(sus_scores_30)}")
if sus_scores_30:
    m = statistics.mean(sus_scores_30)
    sd = statistics.stdev(sus_scores_30) if len(sus_scores_30) > 1 else 0
    med = statistics.median(sus_scores_30)
    print(f"  Mean: {m:.2f}")
    print(f"  SD: {sd:.2f}")
    print(f"  Median: {med:.2f}")
    print(f"  Min: {min(sus_scores_30):.1f}  Max: {max(sus_scores_30):.1f}")
    print(f"  Scores: {sorted([round(s,1) for s in sus_scores_30], reverse=True)}")
    if m >= 85: adj = 'Excellent'
    elif m >= 72: adj = 'Good'
    elif m >= 52: adj = 'OK'
    elif m >= 39: adj = 'Poor'
    else: adj = 'Awful'
    print(f"  Adjective (Bangor 2009): {adj}")
    print(f"  Above 68: {'YES' if m >= 68 else 'NO'}")

# Demographics N=30
desc_col = None
for i, h in enumerate(headers_s):
    if h and 'describes you' in str(h).lower():
        desc_col = i
        break
if desc_col:
    descs = [r[desc_col] for r in sus_30 if r[desc_col]]
    print(f"\nSUS N=30 Respondent type:")
    for k, v in Counter(descs).most_common():
        print(f"  {k}: {v} ({v/30*100:.1f}%)")

print()

# ── Research survey: N=33 → take first 30 ────────────────────────────────────
wb_r = openpyxl.load_workbook(
    'docs/handsoff/SmartSpend_ AI-Assisted Mobile Financial Tracking Evaluation Questionnaire (Responses).xlsx',
    read_only=True, data_only=True
)
ws_r = wb_r.active
rows_r = list(ws_r.iter_rows(values_only=True))
headers_r = rows_r[0]
data_r = rows_r[1:]

print(f"Research survey total: {len(data_r)} → taking first 30")
research_30 = data_r[:30]
N = 30

def col(headers, keyword):
    for i, h in enumerate(headers):
        if h and keyword.lower() in str(h).lower():
            return i
    return None

# Q2: Category
cat_col = col(headers_r, 'category best describes')
cats = [r[cat_col] for r in research_30 if r[cat_col]]
print(f"\nQ2 Category (N=30):")
cat_counts = Counter(cats)
for k, v in cat_counts.most_common():
    print(f"  {k}: {v} ({v/N*100:.1f}%)")

# Q12: AI app
ai_col = col(headers_r, 'AI-powered financial assistant')
ai_vals = [r[ai_col] for r in research_30 if r[ai_col]]
ai_counts = Counter(ai_vals)
positive = sum(v for k, v in ai_counts.items() if 'yes' in str(k).lower() or 'probably yes' in str(k).lower() or 'definitely' in str(k).lower())
print(f"\nQ12 AI app (N=30):")
for k, v in ai_counts.most_common():
    print(f"  {k}: {v} ({v/N*100:.1f}%)")
print(f"  Positive intent: {positive} ({positive/N*100:.1f}%)")

# Q4: Budget
budget_col = col(headers_r, 'prepare a budget')
budgets = [r[budget_col] for r in research_30 if r[budget_col]]
print(f"\nQ4 Budget prep (N=30):")
for k, v in Counter(budgets).most_common():
    print(f"  {k}: {v} ({v/N*100:.1f}%)")

# Q13: Wallets
def count_items_30(col_idx):
    counter = Counter()
    for r in research_30:
        if r[col_idx]:
            items = str(r[col_idx]).split(';')
            for item in items:
                item = item.strip()
                if item:
                    counter[item] += 1
    return counter

wallet_col = col(headers_r, 'digital wallets')
wallet_counts = count_items_30(wallet_col)
gcash_count = sum(v for k, v in wallet_counts.items() if 'gcash' in str(k).lower())
print(f"\nQ13 GCash usage (N=30): approx {gcash_count} mentions")
