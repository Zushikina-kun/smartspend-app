import openpyxl, statistics

wb = openpyxl.load_workbook('docs/handsoff/survey_data/03_SUS_Responses_FINAL_N36.xlsx', read_only=True, data_only=True)
ws = wb.active
rows = list(ws.iter_rows(values_only=True))
headers = rows[0]
data = rows[1:]

def col(kw):
    for i, h in enumerate(headers):
        if h and kw.lower() in str(h).lower(): return i
    return None

screen_col = col('10 minutes')
desc_col = col('describes you')
sus_cols = list(range(3, 13))

screened = [r for r in data if r[screen_col] and 'yes' in str(r[screen_col]).lower()]

def sus_score(r):
    try:
        q = []
        for i, c in enumerate(sus_cols):
            val = r[c]
            if val is None: return None
            v = int(float(str(val)))
            q.append(v-1 if (i+1)%2==1 else 5-v)
        return sum(q)*2.5 if len(q)==10 else None
    except: return None

# All screened with scores
scored = [(r, sus_score(r)) for r in screened if sus_score(r) is not None]
print(f"Total screened with valid scores: {len(scored)}")

# Show all respondent types
for r, s in scored:
    desc = str(r[desc_col]) if r[desc_col] else 'Unknown'
    print(f"  {s:.1f} — {desc[:40]}")

print()

# Group analysis
parents, yp, both = [], [], []
for r, s in scored:
    desc = str(r[desc_col]).lower() if r[desc_col] else ''
    if 'parent' in desc and 'young' not in desc:
        parents.append(s)
    elif 'young' in desc and 'parent' not in desc:
        yp.append(s)
    else:
        both.append(s)

print(f"Parents only (n={len(parents)}): mean={statistics.mean(parents):.2f if parents else 0}")
print(f"  scores: {sorted(parents)}")
print()
print(f"YP only (n={len(yp)}): mean={statistics.mean(yp):.2f if yp else 0}")
print(f"  scores: {sorted(yp)}")
print()
print(f"Both/other (n={len(both)}): {both}")
print()
print("The manuscript says: Parents n=10, mean=58.25; YP n=20, mean=63.62")
print("Kiro computed: Parents n=11, mean=62.05; YP n=20, mean=63.62")
print()
print("YP matches. Parent discrepancy. Checking if n=10 means they excluded someone...")
# Try removing highest parent score to get closer to 58.25
if parents:
    test = sorted(parents)[:-1]  # remove highest
    if len(test) == 10:
        m = statistics.mean(test)
        print(f"Without highest parent score: n=10, mean={m:.2f}")
    test2 = sorted(parents)[1:]  # remove lowest
    if len(test2) == 10:
        m2 = statistics.mean(test2)
        print(f"Without lowest parent score: n=10, mean={m2:.2f}")
