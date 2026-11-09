"""
Compute individual-item frequencies from multi-select responses.
"""
import openpyxl
from collections import Counter

wb_r = openpyxl.load_workbook(
    'docs/handsoff/SmartSpend_ AI-Assisted Mobile Financial Tracking Evaluation Questionnaire (Responses).xlsx',
    read_only=True, data_only=True
)
ws_r = wb_r.active
rows_r = list(ws_r.iter_rows(values_only=True))
headers_r = rows_r[0]
data_r = rows_r[1:]
N = len(data_r)

def col(headers, keyword):
    for i, h in enumerate(headers):
        if h and keyword.lower() in str(h).lower():
            return i
    return None

def count_items(col_idx):
    counter = Counter()
    for r in data_r:
        if r[col_idx]:
            items = str(r[col_idx]).split(';')
            for item in items:
                item = item.strip()
                if item:
                    counter[item] += 1
    return counter

print(f"N = {N}")
print()

# Q6: Challenges - individual items
chal_col = col(headers_r, 'main challenges')
chal_counts = count_items(chal_col)
print("Q6 Main challenges (individual items):")
for k, v in chal_counts.most_common():
    print(f"  {k}: {v} ({v/N*100:.1f}%)")

print()
# Q7: Exceed budget - individual items
exceed_col = col(headers_r, 'exceeded your budget')
exceed_counts = count_items(exceed_col)
print("Q7 When exceed budget (individual items):")
for k, v in exceed_counts.most_common():
    print(f"  {k}: {v} ({v/N*100:.1f}%)")

print()
# Q8: What would help - individual items
help_col = col(headers_r, 'manage your budget more effectively')
help_counts = count_items(help_col)
print("Q8 What would help (individual items):")
for k, v in help_counts.most_common():
    print(f"  {k}: {v} ({v/N*100:.1f}%)")

print()
# Q10: How record - individual items
how_col = col(headers_r, 'how do you record')
how_counts = count_items(how_col)
print("Q10 How record expenses (individual items):")
for k, v in how_counts.most_common():
    print(f"  {k}: {v} ({v/N*100:.1f}%)")

print()
# Q11: Track - individual items  
track_col = col(headers_r, 'usually track')
track_counts = count_items(track_col)
print("Q11 Which expenses tracked (individual items):")
for k, v in track_counts.most_common():
    print(f"  {k}: {v} ({v/N*100:.1f}%)")

print()
# Q13: Wallets - individual items
wallet_col = col(headers_r, 'digital wallets')
wallet_counts = count_items(wallet_col)
print("Q13 Digital wallets (individual items):")
for k, v in wallet_counts.most_common():
    print(f"  {k}: {v} ({v/N*100:.1f}%)")
