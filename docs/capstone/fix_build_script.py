"""fix_build_script.py — Update stale values in build_presentation.py"""

path = r"c:\xampp\htdocs\smartspend_app\docs\capstone\build_presentation.py"

with open(path, "r", encoding="utf-8") as f:
    content = f.read()

orig_len = len(content)

replacements = [
    # Date on title slide
    ("November 9, 2026", "November 10, 2026"),

    # SUS preliminary notice → final
    (
        "PRELIMINARY DATA \u2014 N=5 of target N=30 (Oct\u2013Nov 2026). Mean SUS = 62.50 \u2014 below the 68-point average benchmark. Final N=30 results may differ.",
        "FINAL DATA \u2014 N=30 screened respondents (from N=36, Oct\u2013Nov 2026). Mean SUS = 61.83 (SD=17.58) \u2014 below the 68-point average benchmark; adjective rating \"OK\" per Bangor et al. (2009)."
    ),

    # Survey status pending notice
    (
        "Survey data collection in progress. SUS scores, frequency tables, and demographic breakdowns will be added here once N=30 responses are complete.",
        "Data collection complete \u2014 N=30 research respondents and N=30 SUS respondents (screened from N=36). All data finalized Oct\u2013Nov 2026."
    ),

    # FHS slide pending notice
    (
        "Objective 1 results [PENDING] \u2014 replace with actual survey frequencies once N=30 is complete.",
        "Final data: 96.7% positive AI intent \u00b7 93.3% use GCash \u00b7 N=30 respondents \u00b7 Data collection complete."
    ),

    # SUS table mean row
    (
        '("Mean SUS (N=5, Preliminary)",          "5", "62.50", "\u2014", "\u2014", "Grade C")',
        '("Mean SUS (N=30, Final)",               "30", "61.83", "17.58", "35\u2013100", "Grade C \u2014 OK")'
    ),

    # Score interpretation box
    (
        "\u00a0 Interpretation: SUS 62.50 = Grade C (OK) per Bangor et al. (2009). Below the 68-point average benchmark.",
        "\u00a0 Final SUS = 61.83 (SD=17.58) = Grade C (OK) per Bangor et al. (2009). Below the 68-point average benchmark \u2014 acknowledged as a prototype limitation."
    ),

    # Individual scores note
    (
        "Individual scores: 60.0, 55.0, 55.0, 75.0, 67.5  \u00b7  Range: 55.0\u201375.0  \u00b7  Below average (68 benchmark) \u2014 acknowledged as a prototype limitation  \u00b7  Preliminary N=5 of target N=30",
        "Final N=30: Mean=61.83, SD=17.58, Median=52.50, Range: 35.0\u2013100.0. Below the 68-point average benchmark \u2014 acknowledged as a prototype limitation."
    ),

    # Conclusions Objective 3
    (
        'Preliminary SUS result (N=5):\\n" +\n     "Mean SUS = 62.50 \u2014 Grade C (OK)\\n" +',
        'Final SUS result (N=30):\\n" +\n     "Mean SUS = 61.83 (SD=17.58) \u2014 Grade C (OK)\\n" +'
    ),
    (
        '"Final SUS result pending N=30 completion.")',
        '"UI friction points identified for refinement.")'
    ),

    # Print statements
    (
        "[PENDING] slides to update when survey data arrives:",
        "All slides updated with final N=30 data:"
    ),
    (
        "Preliminary data added: SUS 62.50 (N=5), Research survey N=13",
        "Final SUS = 61.83 (N=30, SD=17.58), Research N=30 (96.7% AI intent, 93.3% GCash)"
    ),
    (
        "Remaining [PENDING] in .py: SUS breakdown by group (parents vs YP) awaits N=30",
        "All data finalized. PPTX rebuilt with correct values."
    ),
]

# Handle Objective 1 conclusions separately (multiline)
import re

# Objective 1 conclusions block
obj1_old = (
    '"Preliminary findings (N=13, Oct\\u2013Nov 2026):\\n\\n" +\n'
    '     "76.9% struggle with overspending\\n" +\n'
    '     "53.8% use manual/no tracking\\n" +\n'
    '     "69.2% positive intent: AI financial app\\n" +\n'
    '     "46.2% face difficulty before salary/allowance\\n\\n" +\n'
    '     "Note: Preliminary \u2014 final analysis pending N=30.")'
)
obj1_new = (
    '"Final findings (N=30, Oct\\u2013Nov 2026):\\n\\n" +\n'
    '     "96.7% expressed positive AI app intent\\n" +\n'
    '     "93.3% actively use GCash\\n" +\n'
    '     "60% cited bill reminders as top desired feature\\n" +\n'
    '     "Every desired feature is implemented in SmartSpend")'
)

if obj1_old in content:
    content = content.replace(obj1_old, obj1_new)
    print("Fixed Objective 1 conclusions block")
else:
    print("WARNING: Objective 1 block not found (may need manual check)")

# Apply simple replacements
for old, new in replacements:
    if old in content:
        content = content.replace(old, new)
        print(f"Fixed: {old[:60]}...")
    else:
        print(f"NOT FOUND: {old[:60]}...")

with open(path, "w", encoding="utf-8") as f:
    f.write(content)

print(f"\nSaved. Original size: {orig_len}, New size: {len(content)}")
