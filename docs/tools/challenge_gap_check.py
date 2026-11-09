"""Cross-check survey challenges vs app solutions."""
import openpyxl
from collections import Counter

wb = openpyxl.load_workbook('docs/handsoff/survey_data/01_Research_Survey_Responses_N33.xlsx', read_only=True, data_only=True)
ws = wb.active
rows = list(ws.iter_rows(values_only=True))
headers = rows[0]
data = rows[1:31]

def get_col(keyword):
    for i, h in enumerate(headers):
        if h and keyword.lower() in str(h).lower():
            return i
    return None

def count_individual(col_idx):
    counter = Counter()
    for r in data:
        if r[col_idx]:
            items = str(r[col_idx]).split(';')
            for item in items:
                for sub in item.split(','):
                    sub = sub.strip()
                    if sub:
                        counter[sub] += 1
    return counter

N = 30

# Q6: Main challenges
chal_col = get_col('main challenges')
chal = count_individual(chal_col)
print(f'Q6 Top financial challenges (N={N}):')
for k, v in chal.most_common(10):
    print(f'  {v:2d}/30 ({v/N*100:.0f}%): {k}')

print()

# Q10: How they record now
how_col = get_col('how do you record')
how = count_individual(how_col)
print(f'Q10 Current recording methods (N={N}):')
for k, v in how.most_common():
    print(f'  {v:2d}/30 ({v/N*100:.0f}%): {k}')

print()

# Q13: Digital wallets used
wallet_col = get_col('digital wallets')
wallets = count_individual(wallet_col)
print(f'Q13 Digital wallets (N={N}):')
for k, v in wallets.most_common():
    print(f'  {v:2d}/30 ({v/N*100:.0f}%): {k}')
