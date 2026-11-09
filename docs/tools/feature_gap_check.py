"""Cross-check survey desired features vs actual app features."""
import openpyxl
from collections import Counter

wb = openpyxl.load_workbook('docs/handsoff/survey_data/01_Research_Survey_Responses_N33.xlsx', read_only=True, data_only=True)
ws = wb.active
rows = list(ws.iter_rows(values_only=True))
headers = rows[0]
data = rows[1:31]

# Q8: desired features - individual items
help_col = None
for i, h in enumerate(headers):
    if h and 'manage your budget more effectively' in str(h).lower():
        help_col = i
        break

feature_counter = Counter()
for r in data:
    if r[help_col]:
        items = str(r[help_col]).split(';')
        for item in items:
            item = item.strip()
            if item:
                for sub in item.split(','):
                    sub = sub.strip()
                    if sub:
                        feature_counter[sub] += 1

N = 30
print(f'Q8 Desired features — individual items (N={N}):')
for k, v in feature_counter.most_common():
    print(f'  {v:2d}/30 ({v/N*100:.0f}%): {k}')
