# Financial Health Score (FHS) — Formula Derivation and Literature Basis
### For Adviser Validation

**Project:** SmartSpend — AI-Assisted Mobile Financial Tracking and Advisory Application  
**Researchers:** Directo, Brix A. · Rubis, Cyrille John M. · Madayag, Djaunathan Albert S.  
**Adviser:** Ellen F. Mangaoang, DIT  
**Institution:** Lorma Colleges — College of Computer Studies and Engineering  
**Date:** November 5, 2026  
**Version:** v3.1.2 (current release)

---

## 1. Overview

The SmartSpend Financial Health Score (FHS) is a **Prototype Observed Financial Health Indicator (FHI)** that computes a 0–100 score from the user's actual logged transaction data — not from self-report surveys. The FHS operates in two modes depending on whether the user has set their monthly income.

The FHS was derived by adapting the **CBA–Melbourne Institute Observed Financial Health Indicator** (Comerton-Forde et al., 2018), which uses actual bank-record data to derive a 0–100 observed scale with equal-weight components. SmartSpend adapts this transaction-based approach to a mobile SQLite database instead of bank records.

---

## 2. FHS Score Interpretation Labels

The computed FHS (0–100) maps to a qualitative label and icon displayed in the SmartSpend user interface. The bands are spaced in 10-point increments, consistent with the 0–100 observed scale of the CBA–Melbourne Institute Observed Financial Health Indicator (Comerton-Forde et al., 2018). The "Needs Work" floor (below 60) sits below the Fair band and signals that one or more score components require immediate attention.

| Score Range | Label | Icon |
|---|---|---|
| 90–100 | Excellent | 👑 |
| 80–89 | Great | 🏆 |
| 70–79 | Good | ⭐ |
| 60–69 | Fair | 🌱 |
| Below 60 | Needs Work | 📉 |

---

## 3. The Exact Formulas

All formulas below are verified against the actual source code (`lib/services/score_service.dart`).

### Full Mode (when monthly income is set)

#### Component 1: Savings Rate (25 pts)

```
savingsRate = (monthlyIncome − totalSpent) / monthlyIncome
score = 25 × min(1, savingsRate / 0.20)
```

- Full 25 pts when saving ≥ 20% of income
- Scales proportionally below 20%
- 0 pts when spending equals or exceeds income
- **Literature basis:** Warren & Tyagi (2005) — the 50/30/20 rule establishes 20% savings as the standard personal finance target
- **Framework alignment:** FinHealth Score® Save pillar (Financial Health Network, 2021)

*No-income fallback:* 20 pts if totalSpent < ₱5,000; 15 pts if < ₱10,000; 10 pts otherwise. This tiered proxy accommodates users in the informal economy who do not track formal income (UNSGSA, 2021).

#### Component 2: Overspend Control (25 pts)

```
dailyBudget = monthlyIncome / daysInMonth
hardOverDays = days where daily spending exceeded dailyBudget (multiple items)
softOverDays = days where a single large purchase caused the overspend
weightedOver = hardOverDays + (softOverDays × 0.5)
score = 25 × (1 − weightedOver / activeDays)
```

- Full 25 pts when no days exceeded the daily budget
- Soft overspend (one-off large purchase like tuition) counts at 0.5× penalty
- Hard overspend (habitual daily overspending) counts at 1× penalty
- **Literature basis:** Kahneman & Tversky (1979) — Prospect Theory: losses are more salient than gains; Thaler & Sunstein (2008) — Nudge Theory: framing spending as a "loss against budget" reinforces behavioral correction
- **Framework alignment:** FinHealth Score® Spend pillar — spending less than income

#### Component 3: Budget Adherence (25 pts)

```
score = 25 × (onBudgetCategories / totalBudgetCategories)
```

- Full 25 pts when all category budgets are on track
- 0 pts when all budgets are exceeded
- **If no budgets are set: auto-award 25 pts** (not penalized for lack of setup)
- **Literature basis:** FinHealth Score® Plan pillar (Financial Health Network, 2021) — budget adherence as a core health behavior; BSP CFIS (2025) — fewer than 50% of Filipino households maintain any written budget, making budget-setting itself a measurable behavior

#### Component 4: Logging Consistency (25 pts)

```
loggedDays = number of distinct days with at least one expense entry
activeDays = days elapsed in current month (capped at daysInMonth)
score = 25 × (loggedDays / activeDays)
```

- Full 25 pts when logging every active day
- Scales proportionally with missed days
- **Literature basis:** Deci & Ryan (2000) — Self-Determination Theory: habit formation requires consistent, intrinsically motivated behavior; the Competence dimension drives long-term engagement
- **Framework alignment:** CBA–Melbourne Institute data completeness metric (Comerton-Forde et al., 2018)

#### Adjustments (applied after the 4 components)

| Adjustment | Formula | Basis |
|---|---|---|
| **Warning Decay** | −5 pts/day, max 3 days (−15 pts total) | Kahneman & Tversky (1979) — Prospect Theory: losses create stronger behavioral responses than equivalent gains. Applied only to discretionary categories (Bills, Health, Education are exempt). |
| **Gap Adjustment** | −3 pts/day unlogged (max −15); +2 pts/day clean (max +10) | Behavioral finance consistency principle (Ariely, 2008; Duhigg, 2012). Penalty > reward follows Prospect Theory asymmetry. Capped to prevent gaming. |

---

### Lightweight Mode (when income is NOT set)

Used when the user has not configured monthly income. Redesigns 2 of 4 components to use only spending data.

#### Component 1: Spending Restraint (25 pts)

```
With spending limit set:
  ratio = totalSpent / spendingLimit
  score = 25 × (1 − ((ratio − 0.80) / 1.20))   [clamped 0–25]

Without spending limit:
  wantRatio = wantSpending / totalSpending
  score = 10 + 15 × (1 − ((wantRatio − 0.30) / 0.40))   [clamped 10–25]
```

- Full 25 pts at ≤80% of spending limit (grace zone)
- Scores 0 at 2× the limit
- No-limit fallback: 25 pts at ≤30% wants; 10 pts at ≥70% wants
- **Literature basis:** Kahneman & Tversky (1979) — distinguishing discretionary from necessary spending as a behavioral health signal. The 80% grace zone reflects a personal finance buffer principle.

#### Component 2: Logging Consistency (25 pts)

Same formula as Full Mode Component 4.

#### Component 3: Category Balance (25 pts)

```
discretionaryTotal = total spending excluding Bills, Health, Education
topRatio = topDiscretionaryCategory / discretionaryTotal
score = 25 × (1 − ((topRatio − 0.40) / 0.60))   [clamped 0–25]
```

- Full 25 pts when no single discretionary category exceeds 40% of discretionary spend
- Scores 0 when one category accounts for 100%
- Bills, Health, and Education are **exempt** (non-discretionary fixed obligations)
- **Literature basis:** Financial Health Network FinHealth Score® Spend pillar — spending distribution as a health indicator. BSP CFIS (2025) confirms exempt categories dominate Filipino household budgets for legitimate reasons.

#### Component 4: Habit Streak (25 pts)

```
currentStreak = consecutive days ending today (or yesterday) with ≥1 expense logged
score = 25 × min(1, currentStreak / 14)
```

- Full 25 pts at a 14-day consecutive logging streak
- Scales proportionally below 14 days
- **Literature basis:** Deci & Ryan (2000) SDT Competence dimension; Lally et al. (2010) — habit formation begins to anchor in the earliest phase of consistent behavior (~14 days represents initial tracking routines before deeper automaticity at ~66-day mean)

---

## 4. Why Equal Weights (25 pts each)?

Three academic justifications:

1. **CBA–Melbourne Institute precedent** — their Observed FHI uses equal-weighted transaction-derived components summing to 100 (Comerton-Forde et al., 2018)
2. **OECD/JRC Handbook on Composite Indicators** (2008) — formally establishes equal weighting as the methodologically defensible default when there is insufficient empirical basis for differential weights
3. **Transparency** — users can understand "each pillar is worth 25 points" without needing a finance degree

We do not have the multi-year longitudinal behavioral data needed to justify differential weights for this population. Equal weighting is the honest, defensible choice.

---

## 5. Alignment with Established Frameworks

| SmartSpend FHS Component | CBA–Melbourne Institute (2018) | FinHealth Score® (FHN) | CFPB Financial Well-Being Scale (2017) |
|---|---|---|---|
| Savings Rate | Observed savings behavior from bank records | Save pillar: savings rate and buffer | Q7: "I could handle a major unexpected expense" |
| Overspend Control | Observed overspending days (weighted) | Spend pillar: spending less than income | Q2: "My finances control my life" (reverse) |
| Budget Adherence | Category-level spending vs. limits | Plan pillar: on track with financial goals | Q9: "My finances are on track" |
| Logging Consistency | Data completeness metric | (Not directly measured) | (Not directly measured) |
| Warning Decay | (Our addition) | (Our addition) | (Our addition) |

**Key distinction:** The CFPB scale is self-reported (users rate their own feelings). The Melbourne Institute and FinHealth Score use transaction data like SmartSpend. The Warning Decay mechanism is our original design contribution, grounded in Prospect Theory.

---

## 6. Comparison with Other Financial Health Score Systems

To position the SmartSpend FHS within the broader landscape of financial health measurement tools, the table below compares it with established and emerging score systems. Comparison dimensions include data source, score scale, formula transparency, and the specific advantage SmartSpend offers — particularly its fully disclosed formula and offline, transaction-based computation suited to the Filipino context.

| System | Organization | Scale | Data Source | Formula Disclosed | SmartSpend Advantage |
|---|---|---|---|---|---|
| FinHealth Score® | Financial Health Network (US) | 0–100 | 8 survey indicators | Partially disclosed | Transaction-based, not survey; fully disclosed |
| CFPB Financial Well-Being Scale | CFPB (US) | 0–100 | 10-question survey | Standardized scoring table | Measures behavioral outcomes, not psychological states |
| MindsBudget | MindsBudget (web) | 0–100 | Uploaded bank statements | Component structure disclosed | Offline computation; no bank API needed |
| Wingman Money | Wingman (AU) | 0–100 | Linked bank accounts | Not disclosed | Fully disclosed formula |
| BudgetPH / KindlyF | KindlyF (PH) | 0–850 | User-entered data | Not disclosed | Only direct PH competitor with behavioral score; SmartSpend formula is fully disclosed |
| Alkansya AI | Alkansya (PH) | 0–100 (claimed) | Transactions | Not disclosed | SmartSpend's formula is fully documented; Alkansya's is undisclosed |
| Artha Engine | Artha (India) | 0–100 | Income, debt, savings, investments | Weighted formula disclosed | Broader investment orientation; SmartSpend is expense-tracking focused |
| SmartSpend (Full Mode) | Lucid Frame (PH) | 0–100 | Recorded transactions + income | Fully disclosed | Offline, dual-mode, Filipino context |
| SmartSpend (Lightweight Mode) | Lucid Frame (PH) | 0–100 | Spending behavior only | Fully disclosed | For students, irregular-income users |

**Transparency note:** SmartSpend is the only system in this comparison whose complete scoring formula — including every calibrated constant and adjustment rule — is fully documented and reproducible from the source code (`lib/services/score_service.dart`). Competitor formulas marked "Not disclosed" are proprietary; where SmartSpend claims an advantage, it rests on this transparency and on the offline, no-bank-API design that avoids linking external accounts.

---

## 7. Linkage to Needs Assessment

Each FHS component directly addresses a confirmed user problem:

| Needs Assessment Finding | FHS Component | Survey Question |
|---|---|---|
| Difficulty saving money | Savings Rate — rewards ≥20% savings | Q11: "Do you set aside money for savings?" |
| Regularly exceeds planned budget | Overspend Control — penalizes habitual overspend | Q14: "How often do expenses exceed budget?" |
| Fewer than half maintain any budget | Budget Adherence — incentivizes budgeting | Q8: "Do you prepare a budget?" |
| Inconsistent or no expense tracking | Logging Consistency — rewards daily logging | Q21: "Do you currently record expenses?" |

---

## 8. Calibrated Constants (Design Choices)

The following numeric constants are design calibrations informed by the referenced frameworks but not directly derived from any single paper. They are disclosed as reasonable prototype values subject to empirical calibration in future longitudinal studies.

| Constant | Value | Theoretical Basis | Design Rationale |
|---|---|---|---|
| Warning Decay rate | −5 pts/day | Prospect Theory (loss salience) | Felt but not catastrophic in a 30-day cycle |
| Warning Decay cap | 3 days / −15 pts max | Prospect Theory | Prevents total wipe-out from single breach |
| Gap bonus | +2 pts/day (max +10) | Consistency principle | Smaller than penalty (loss-aversion asymmetry) |
| Gap penalty | −3 pts/day (max −15) | Prospect Theory asymmetry | Penalty > reward mirrors loss > gain finding |
| Soft overspend weight | 0.5× | Nudge Theory (planned vs. habitual) | One-time large purchases ≠ daily excess |
| Category Balance threshold | 40% | Concentration risk principle | Below 40%, dominance is minimal |
| Spending Restraint grace zone | 80% | Personal finance buffer principle | 20% safety buffer before penalty |
| Habit Streak target | 14 days | SDT Competence + Lally et al. (2010) | Earliest reliable range for habit anchoring |
| Savings Rate target | 20% | Warren & Tyagi 50/30/20 rule | Standard personal finance savings benchmark |

---

## 9. References

All citations are verifiable via DOI, official publication page, or direct link.

Bangko Sentral ng Pilipinas. (2025). *Consumer Finance Inclusion Survey (CFIS) 2025.* https://www.bsp.gov.ph/SitePages/MediaAndResearch/SurveysDisplay.aspx?ItemId=82

Comerton-Forde, C., Ip, E., Ribar, D. C., Ross, J., Salamanca, N., & Tsiaplias, S. (2018). *Using survey and banking data to measure financial wellbeing* (CBA–MI Technical Report No. 1). Commonwealth Bank of Australia & Melbourne Institute.

Comerton-Forde, C., de New, J., Salamanca, N., Ribar, D. C., Nicastro, A., & Ross, J. (2020). *Measuring financial wellbeing with self-reported and bank-record data* (IZA Discussion Paper No. 13884). https://docs.iza.org/dp13884.pdf

Consumer Financial Protection Bureau. (2017). *CFPB Financial Well-Being Scale: Scale development technical report.* https://files.consumerfinance.gov/f/documents/201705_cfpb_financial-well-being-scale-technical-report.pdf

Deci, E. L., & Ryan, R. M. (2000). The "what" and "why" of goal pursuits: Human needs and the self-determination of behavior. *Psychological Inquiry, 11*(4), 227–268.

Financial Health Network. (2021). *FinHealth Score® Toolkit.* https://finhealthnetwork.org/tools/financial-health-score/

Gubbins, P., Mazzotta, B., & Rhyne, E. (2021). *Measuring financial health: Concepts and considerations.* UNSGSA Financial Health Working Group. https://www.unsgsa.org/sites/default/files/resources-files/2021-09/UNSGSA%20Measuring-Financial-Health%20Policy%20Note.pdf

Kahneman, D., & Tversky, A. (1979). Prospect theory: An analysis of decision under risk. *Econometrica, 47*(2), 263–292.

Lally, P., van Jaarsveld, C. H. M., Potts, H. W. W., & Wardle, J. (2010). How are habits formed: Modelling habit formation in the real world. *European Journal of Social Psychology, 40*(6), 998–1009. https://doi.org/10.1002/ejsp.674

OECD & Joint Research Centre. (2008). *Handbook on constructing composite indicators: Methodology and user guide.* OECD Publishing. https://doi.org/10.1787/9789264043466-en

Thaler, R. H., & Sunstein, C. R. (2008). *Nudge: Improving decisions about health, wealth, and happiness.* Yale University Press.

Warren, E., & Tyagi, A. W. (2005). *All your worth: The ultimate lifetime money plan.* Free Press.

Ariely, D. (2008). *Predictably irrational: The hidden forces that shape our decisions.* HarperCollins.

Duhigg, C. (2012). *The power of habit: Why we do what we do in life and business.* Random House.

---

*This document was prepared for adviser validation of the FHS formula derivation. All formulas are verified against the SmartSpend source code (`lib/services/score_service.dart`). All citations are verifiable.*
