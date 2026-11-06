"""
Build FHS-only summary PDF for Ma'am Ellen.
Content: FHS formula, academic literature basis, framework alignment.
No SUS, no questionnaire, no validation section.
"""
import subprocess, sys, os

md = """# SmartSpend — Financial Health Score (FHS) Literature Summary
**Prepared for:** Ms. Ellen F. Mangaoang, DIT — Capstone Adviser  
**Prepared by:** Directo, Brix A. · Rubis, Cyrille John M. · Madayag, Djaunathan Albert S.  
**Lorma Colleges — CCSE — BSIT Capstone 2 — AY 2026–2027**

---

## What is the Financial Health Score?

The SmartSpend **Financial Health Score (FHS)** is a **Prototype Observed Financial Health Indicator (FHI)** that computes a **0–100 score entirely from the user's logged transaction data** — no surveys, no self-report. It was not invented from scratch. Every design decision is grounded in an existing academic or institutional framework.

The FHS adapts the approach of the **CBA–Melbourne Institute Observed Financial Health Indicator** (Comerton-Forde et al., 2018), which uses actual bank-record data to derive a 0–100 observed scale with equal-weight components. We adapted the same transaction-based philosophy to a mobile SQLite database instead of bank records.

---

## The Formula

**FHS = Savings Rate + Overspend Control + Budget Adherence + Logging Consistency**  
*(maximum 100 points — 25 points per component)*

| Component | Formula | Academic Basis |
|---|---|---|
| **Savings Rate** (25 pts) | 25 × min(1, savingsRate / 0.20) | Warren & Tyagi (2005) — 50/30/20 rule; 20% savings as the standard personal finance target |
| **Overspend Control** (25 pts) | 25 × (1 − weightedOverDays / activeDays) | Kahneman & Tversky (1979) — Prospect Theory: losses are more motivationally salient than equivalent gains |
| **Budget Adherence** (25 pts) | 25 × (onBudgetCategories / totalBudgetCategories) | Financial Health Network FinHealth Score® Plan pillar; BSP CFIS (2025) — fewer than 50% of Filipino households maintain any written budget |
| **Logging Consistency** (25 pts) | 25 × (loggedDays / activeDays) | Deci & Ryan (2000) — Self-Determination Theory: habit formation requires consistent, intrinsically motivated behavior |

**Adjustments (applied after the 4 components):**
- **Warning Decay:** −5 pts/day, max −15 pts — if user continues spending on a budget category after a warning. Grounded in Prospect Theory's loss-salience principle (Kahneman & Tversky, 1979). Applies to discretionary categories only; Bills, Health, Education are exempt.
- **Gap Adjustment:** −3 pts/day unlogged (max −15); +2 pts/day confirmed no-spend (max +10). Grounded in behavioral consistency principle (Ariely, 2008; Duhigg, 2012).

---

## Why Equal Weights (25 pts each)?

Three justifications:

1. **CBA–Melbourne Institute precedent** — their Observed FHI uses equal-weighted transaction-derived components summing to 100 (Comerton-Forde et al., 2018)
2. **OECD/JRC Handbook on Composite Indicators** (2008) — formally establishes equal weighting as the methodologically correct default when there is insufficient empirical basis for differential weights
3. **Transparency** — users can understand "each pillar is worth 25 points" without a finance degree

We do not have the multi-year longitudinal data needed to justify differential weights for this population. Equal weighting is the honest, defensible choice.

---

## Alignment with Established Financial Health Frameworks

| SmartSpend FHS Component | CBA–Melbourne Institute (2018) | FinHealth Score® (FHN) | CFPB Financial Well-Being Scale (2017) |
|---|---|---|---|
| Savings Rate | Observed savings behavior from bank records | Save pillar: savings rate and buffer | Q7: "I could handle a major unexpected expense" |
| Overspend Control | Observed overspending days (weighted) | Spend pillar: spending less than income | Q2: "My finances control my life" (reverse) |
| Budget Adherence | Category-level spending vs. limits | Plan pillar: on track with financial goals | Q9: "My finances are on track" |
| Logging Consistency | Data completeness metric | (Not directly measured) | (Not directly measured) |

**Key distinction:** The CFPB scale is self-reported (users rate their own feelings). The Melbourne Institute and FinHealth Score use transaction data — the same approach as SmartSpend.

---

## Why Each Component Was Chosen — Linked to Needs Assessment

Each component directly addresses a confirmed user problem from the preliminary needs assessment:

| Problem Found in Needs Assessment | FHS Component |
|---|---|
| Difficulty saving money | Savings Rate — rewards users who save ≥20% of income |
| Regularly exceeds planned budget | Overspend Control — penalizes habitual overspending days |
| Fewer than half maintain any budget | Budget Adherence — incentivizes setting and following budgets |
| Inconsistent or no expense tracking | Logging Consistency — full score only when logging every active day |

---

## References

Comerton-Forde, C., Ip, E., Ribar, D. C., Ross, J., Salamanca, N., & Tsiaplias, S. (2018). *Using survey and banking data to measure financial wellbeing* (CBA–MI Technical Report No. 1). Commonwealth Bank of Australia & Melbourne Institute.

Deci, E. L., & Ryan, R. M. (2000). The "what" and "why" of goal pursuits. *Psychological Inquiry, 11*(4), 227–268.

Financial Health Network. (2021). *FinHealth Score® Toolkit.* https://finhealthnetwork.org/tools/financial-health-score/

Gubbins, P., Mazzotta, B., & Rhyne, E. (2021). *Measuring financial health: Concepts and considerations.* UNSGSA Financial Health Working Group.

Kahneman, D., & Tversky, A. (1979). Prospect theory: An analysis of decision under risk. *Econometrica, 47*(2), 263–292.

OECD & Joint Research Centre. (2008). *Handbook on constructing composite indicators.* OECD Publishing. https://doi.org/10.1787/9789264043466-en

Warren, E., & Tyagi, A. W. (2005). *All your worth: The ultimate lifetime money plan.* Free Press.

Bangko Sentral ng Pilipinas. (2025). *Consumer Finance Inclusion Survey (CFIS) 2025.* https://www.bsp.gov.ph/
"""

# Write markdown
with open('docs/tools/fhs_summary_temp.md', 'w', encoding='utf-8') as f:
    f.write(md)

# Convert md -> HTML -> PDF via headless Edge
import markdown
html_body = markdown.markdown(md, extensions=['tables'])

html = f"""<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<style>
  @page {{ size: A4; margin: 20mm 18mm 20mm 18mm; }}
  body {{ font-family: 'Times New Roman', serif; font-size: 11pt; color: #1a1a1a; line-height: 1.5; }}
  h1 {{ font-size: 14pt; font-weight: bold; text-align: center; margin-bottom: 4pt; }}
  h2 {{ font-size: 12pt; font-weight: bold; margin-top: 14pt; margin-bottom: 4pt; border-bottom: 1px solid #333; padding-bottom: 2pt; }}
  p {{ margin: 4pt 0 8pt 0; text-align: justify; }}
  table {{ width: 100%; border-collapse: collapse; font-size: 10pt; margin: 8pt 0; page-break-inside: avoid; }}
  th {{ background: #1a3a5c; color: white; padding: 5pt 6pt; text-align: left; font-weight: bold; }}
  td {{ padding: 4pt 6pt; border-bottom: 1px solid #ddd; vertical-align: top; }}
  tr:nth-child(even) td {{ background: #f5f8ff; }}
  hr {{ border: none; border-top: 1px solid #aaa; margin: 10pt 0; }}
  code {{ font-family: Consolas, monospace; background: #f0f0f0; padding: 1pt 3pt; font-size: 10pt; }}
  strong {{ font-weight: bold; }}
  em {{ font-style: italic; }}
  ul, ol {{ margin: 4pt 0 8pt 18pt; }}
  li {{ margin-bottom: 3pt; }}
  .footer {{ font-size: 9pt; color: #666; text-align: center; margin-top: 20pt; border-top: 1px solid #ccc; padding-top: 6pt; }}
</style>
</head>
<body>
{html_body}
<div class="footer">SmartSpend Capstone 2 — Team Lucid Frame — Lorma Colleges CCSE — November 2026</div>
</body>
</html>"""

html_path = os.path.abspath('docs/tools/fhs_summary_temp.html')
pdf_path = os.path.abspath('docs/handsoff/FOR_MAAM_ELLEN/1_SEND_IN_GC_FHS_Summary.pdf')

with open(html_path, 'w', encoding='utf-8') as f:
    f.write(html)

# Find Edge
edge_paths = [
    r'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe',
    r'C:\Program Files\Microsoft\Edge\Application\msedge.exe',
]
edge = next((p for p in edge_paths if os.path.exists(p)), None)
if not edge:
    print("Edge not found")
    sys.exit(1)

result = subprocess.run([
    edge, '--headless', '--disable-gpu', '--no-sandbox',
    f'--print-to-pdf={pdf_path}',
    '--print-to-pdf-no-header',
    f'file:///{html_path.replace(chr(92), "/")}'
], capture_output=True, text=True, timeout=30)

if os.path.exists(pdf_path) and os.path.getsize(pdf_path) > 5000:
    size_kb = os.path.getsize(pdf_path) // 1024
    print(f"PDF created: {pdf_path} ({size_kb} KB)")
    # Verify with pypdf
    try:
        from pypdf import PdfReader
        r = PdfReader(pdf_path)
        print(f"Pages: {len(r.pages)}")
        text = r.pages[0].extract_text()
        checks = ['Financial Health Score', 'Savings Rate', 'Kahneman', 'Warren', 'Melbourne Institute']
        for c in checks:
            print(f"  {'✅' if c in text else '❌'} {c}")
    except Exception as e:
        print(f"Verify error: {e}")
else:
    print(f"PDF failed. stderr: {result.stderr[:300]}")

# Cleanup
for tmp in [html_path, 'docs/tools/fhs_summary_temp.md']:
    try: os.remove(tmp)
    except: pass
