# FHS Formula Derivation — Basis Table
**For:** Adviser Validation (Ms. Ellen F. Mangaoang, DIT)
**Prepared by:** Cyrille John M. Rubis · Brix A. Directo
**SmartSpend Capstone 2 — Lucid Frame — Lorma Colleges CCSE — AY 2026–2027**

---

## Table 1. Theoretical and Literature Basis of the Financial Health Score (FHS) Formula

The SmartSpend Financial Health Score (FHS) is formally positioned as a **Prototype Observed Financial Health Indicator (FHI)**. It was not invented from scratch. Each design decision — the 0–100 scale, the equal-weight structure, the four components, and the two adjustment mechanisms — is grounded in an existing academic or institutional framework, adapted for the Philippine mobile application context.

| FHS Design Element | What It Is in SmartSpend | Academic / Institutional Basis | How We Adapted It |
|-------------------|--------------------------|-------------------------------|-------------------|
| **Transaction-based scoring (0–100)** | The FHS is computed entirely from the user's logged expense, income, and budget data — no surveys, no self-report | CBA–Melbourne Institute Observed Financial Health Indicator (Comerton-Forde et al., 2018, Technical Report No. 1) — uses actual bank-record data to derive a 0–100 observed scale | We adapted the transaction-based, observed-data approach to a mobile SQLite database instead of bank records |
| **Equal-weight components** | Each of the 4 FHS components is worth exactly 25 points | CBA–Melbourne Institute (2018) — uses equal-weight summing of transaction-derived components to 100; UNSGSA (Gubbins, Mazzotta & Rhyne, 2021) — endorses equal-weight design when longitudinal differential-weight data is unavailable; OECD/JRC Handbook on Constructing Composite Indicators (2008) — formally establishes equal weighting as the methodologically defensible default when there is insufficient empirical basis for differential weights | We used equal weights because we do not have the multi-year behavioral data needed to justify differential weights for this population |
| **"Prototype Observed FHI" naming** | We call it a Prototype Observed FHI, not a Financial Health Score | Melbourne Institute Terms of Use require modified scales to use a different name. The UNSGSA note (2021) distinguishes Observed FHIs (transaction-derived) from subjective survey-based scales | We renamed our implementation to comply with Melbourne Institute guidance and to accurately distinguish it from the CFPB Financial Well-Being Scale |
| **Component 1: Savings Rate (25 pts)** | Formula: `25 × min(1, savingsRate / 0.20)`. Full score when the user saves ≥20% of income. *Fallback when income is not set:* `20 pts if totalSpent < ₱5,000; 15 pts if < ₱10,000; 10 pts otherwise` — a tiered spending-volume proxy. | Warren & Tyagi (2004) — the 50/30/20 rule establishes 20% savings as the standard personal finance target; FinHealth Score® (Financial Health Network) — Spend pillar includes savings rate as a core health indicator. The tiered fallback is a design accommodation for users in the informal economy who do not track income (UNSGSA, 2021) | We used the 20% threshold directly from the 50/30/20 framework as the benchmark for full points. The no-income fallback uses spending volume as a proxy — users with very low spending in a period are assumed to have relatively healthy spending behavior |
| **Component 2: Overspend Control (25 pts)** | Formula: `25 × (1 − (hardOverDays + softOverDays × 0.5) / activeDays)`. Soft overspend (single large purchase in one day) counts at 0.5×; hard overspend (habitual daily) counts at 1× | Kahneman & Tversky (1979) — Prospect Theory: losses feel ~2× more painful than equivalent gains, making overspend consequences motivationally salient; Thaler & Sunstein (2008) — Nudge Theory: framing spending as a "loss against budget" reinforces behavioral correction | The soft/hard split prevents the app from penalizing a one-time large purchase (e.g., school tuition) the same as daily habitual overspending |
| **Component 3: Budget Adherence (25 pts)** | Formula: `25 × (onBudgetCategories / totalBudgetCategories)`. If no budgets set: auto-award 25 pts | FinHealth Score® (Financial Health Network) — Plan pillar includes budget adherence as a core health behavior; BSP CFIS (2025) — fewer than 50% of Filipino households maintain any written budget, making budget-setting itself a measurable behavior | We auto-award 25 pts when no budgets are configured — not penalizing users for lack of setup, but incentivizing them to add budgets for accurate tracking |
| **Component 4: Logging Consistency (25 pts)** | Formula: `25 × (loggedDays / activeDays)`. Full score when expenses are logged every active day | Deci & Ryan (2000) — Self-Determination Theory (SDT): habit formation requires consistent, intrinsically motivated behavior. Competence (logging every day) drives long-term engagement | We tied the Logging Consistency score directly to the Habit Streak feature and the streak milestone celebrations to reinforce daily logging via SDT's Competence dimension |
| **Warning Decay (−5 pts/day, max −15 pts)** | If the user continues spending on a budget category after receiving an alert, the FHS loses 5 points per day for up to 3 days | Kahneman & Tversky (1979) — Prospect Theory: losses create stronger behavioral responses than equivalent gains. The decay creates a visible consequence grounded in loss-salience, designed to increase the perceived cost of ignoring warnings | Decay only applies to discretionary categories. Bills, Health, and Education are exempt — you cannot always avoid those expenses, so penalizing them would be unfair |
| **Lightweight Mode (4 alternate components)** | Used when income is not set. Replaces Savings Rate → Spending Restraint, Budget Adherence → Category Balance; Logging Consistency stays, adds Habit Streak | UNSGSA (2021) — recommends transaction-derived indicators as an early-stage complement when full income data is unavailable. Not all users track formal income (e.g., students on irregular allowances) | We redesigned 2 of 4 components for income-independent measurement so the app remains useful and non-penalizing for informal-economy users |
| **Lightweight: Spending Restraint (25 pts)** | Formula: `25 × (1 − ((ratio − 0.80) / 1.20))` [clamped 0..25], where ratio = totalSpent / selfSetLimit. Full score at ≤80% of limit; scores 0 at ≥2× limit. Fallback when no limit set: `10 + 15 × (1 − ((wantRatio − 0.30) / 0.40))`, where wantRatio = wantSpending / totalSpending | Kahneman & Tversky (1979) — Prospect Theory: distinguishing discretionary (want) from necessary (need) spending as a behavioral health signal. The 80% grace zone reflects a personal finance buffer principle: budgets function better when users are not on the edge of their limits | The floor of 10 pts prevents total score collapse for users who have not set a spending limit, reflecting BSP CFIS (2025) finding that most informal-economy users do not maintain formal budgets |
| **Lightweight: Category Balance (25 pts)** | Formula: `topRatio = topDiscretionaryCategory / discretionaryTotal`; `25 × (1 − ((topRatio − 0.40) / 0.60))` [clamped 0..25]. Bills, Health, and Education categories are excluded from the denominator (discretionaryTotal). Full score when no single discretionary category exceeds 40% of discretionary spend; scores 0 when one category accounts for 100% | Financial Health Network FinHealth Score® — Spend pillar: spending balance across categories as a health indicator. Exempt categories (Bills, Health, Education) follow BSP CFIS (2025) — these are non-discretionary fixed obligations that legitimately dominate spending without indicating poor financial health | The 40%→100% scaling means a user focused entirely on one discretionary category scores 0, while a reasonably distributed user scores well |
| **Lightweight: Habit Streak (25 pts)** | Formula: `25 × min(1, currentStreak / 14)`. Full score once a 14-day consecutive logging streak is achieved | Deci & Ryan (2000) SDT Competence dimension; Lally et al. (2010) — habit formation begins to anchor in the earliest phase of a consistent behavioral window (~14 days represents the start of initial tracking routines before deeper automaticity at ~66-day mean) | The 14-day target is a calibrated design choice: long enough to build initial consistency, short enough to be achievable by students and new users |
| **Gap Adjustment (+2/−3 pts/day)** | Score adjusts when the user logs many expenses on one day after a gap (+2/day, max +10) or goes multiple days without logging (−3/day, max −15) | Behavioral finance principle: consistency in financial tracking is more predictive of good outcomes than volume on a single day (Ariely, 2008; Duhigg, 2012). The asymmetry (penalty > bonus) follows Prospect Theory's loss > gain principle | We capped the adjustment at +10/−15 pts to prevent gaming (logging 100 expenses in one day) while still rewarding recovery after gaps |

---

## Table 2. Alignment with Established Financial Health Frameworks

This table shows how each SmartSpend FHS component maps to the three most widely cited financial health frameworks.

| SmartSpend FHS Component | CBA–Melbourne Institute (2018) | FinHealth Score® (FHN) | CFPB Financial Well-Being Scale (2017) |
|--------------------------|-------------------------------|------------------------|----------------------------------------|
| Savings Rate | Observed savings behavior from bank records | Save pillar: savings rate and buffer | Q7: "I could handle a major unexpected expense" |
| Overspend Control | Observed overspending days (weighted: hard=1×, soft=0.5×) | Spend pillar: spending less than income | Q2: "My finances control my life" (reverse) |
| Budget Adherence | Category-level spending vs. limits | Plan pillar: on track with financial goals | Q9: "My finances are on track" |
| Logging Consistency | Data completeness metric | (Not directly measured) | (Not directly measured) |
| Warning Decay | (Not in framework — our addition) | (Not in framework — our addition) | (Not in framework — our addition) |
| *Lightweight: Spending Restraint* | (Not in framework) | Spend pillar: spending vs. limit | (Not directly measured) |
| *Lightweight: Category Balance* | (Not in framework) | Spend pillar: spending distribution | (Not directly measured) |

**Key difference:** The CFPB scale is self-reported (users rate their own feelings). The Melbourne Institute and FinHealth Score use transaction data like SmartSpend. The Warning Decay mechanism is our original design contribution, grounded in Prospect Theory.

**Note on Category Balance formula:** The Category Balance formula uses `discretionaryTotal` (Bills, Health, and Education excluded) as the denominator — not total outflow. This means the formula measures concentration within *discretionary* spending only. Fixed obligations are excluded because BSP CFIS (2025) confirms these dominate Filipino household budgets for legitimate, non-behavioral reasons. Full formula: `topRatio = topDiscretionaryCategory / discretionaryTotal; CB = 25 × (1 − ((topRatio − 0.40) / 0.60))` [clamped 0..25].

---

## Table 3. Why Each Component Was Chosen — Linked to Needs Assessment Findings

The four components were not chosen arbitrarily. Each one directly addresses a pain point confirmed by the preliminary needs assessment (Objective 1).

| Needs Assessment Finding | FHS Component That Addresses It | Survey Question That Measured It |
|--------------------------|---------------------------------|----------------------------------|
| Filipino respondents find it difficult to save (Q16: difficulty setting aside savings) | **Savings Rate** — rewards users who save ≥20% of income | Q11: "Do you set aside money for savings before spending?" |
| Respondents regularly exceed their planned budget (Q14) | **Overspend Control** — penalizes days of habitual overspending | Q14: "How often do your expenses exceed your budget?" |
| Fewer than half of respondents maintain any budget (Q8) | **Budget Adherence** — incentivizes setting and following category budgets | Q8: "Do you prepare a budget?" |
| Respondents track expenses inconsistently or not at all (Q21, Q23) | **Logging Consistency** — full score only when logging every active day | Q21: "Do you currently record your expenses?" Q23: "How soon after purchase do you record?" |

---

## References for This Table

Comerton-Forde, C., de New, J., Ribar, D. C., Salamanca, N., Nicastro, A., & Ross, J. (2018). *Using survey and banking data to measure financial wellbeing* (CBA–Melbourne Institute Financial Wellbeing Scales Technical Report No. 1). Commonwealth Bank of Australia & Melbourne Institute. https://melbourneinstitute.unimelb.edu.au/

Deci, E. L., & Ryan, R. M. (2000). The "what" and "why" of goal pursuits: Human needs and the self-determination of behavior. *Psychological Inquiry, 11*(4), 227–268.

Financial Health Network. (2021). *FinHealth Score® Toolkit.* https://finhealthnetwork.org/tools/financial-health-score/

Gubbins, P., Mazzotta, B., & Rhyne, E. (2021). *Measuring financial health: Concepts and considerations.* UNSGSA Financial Health Working Group.

Kahneman, D., & Tversky, A. (1979). Prospect theory: An analysis of decision under risk. *Econometrica, 47*(2), 263–292.

Thaler, R. H., & Sunstein, C. R. (2008). *Nudge: Improving decisions about health, wealth, and happiness.* Yale University Press.

Warren, E., & Tyagi, A. W. (2004). *All your worth: The ultimate lifetime money plan.* Free Press.

Ariely, D. (2008). *Predictably irrational: The hidden forces that shape our decisions.* HarperCollins. ISBN: 978-0-06-135323-9.

Duhigg, C. (2012). *The power of habit: Why we do what we do in life and business.* Random House. ISBN: 978-1-4000-6928-6.

OECD & Joint Research Centre. (2008). *Handbook on constructing composite indicators: Methodology and user guide.* OECD Publishing. https://doi.org/10.1787/9789264043466-en

Lally, P., van Jaarsveld, C. H. M., Potts, H. W. W., & Wardle, J. (2010). How are habits formed: Modelling habit formation in the real world. *European Journal of Social Psychology, 40*(6), 998–1009. https://doi.org/10.1002/ejsp.674

BSP. (2025). *Consumer Finance Inclusion Survey (CFIS) 2025.* Bangko Sentral ng Pilipinas. https://www.bsp.gov.ph/SitePages/MediaAndResearch/SurveysDisplay.aspx?ItemId=82

---

## Note on Calibrated Numeric Constants

The following specific numeric constants in the FHS formula are **design calibrations** informed by the referenced theoretical frameworks but not directly derived from any single paper. They represent reasonable prototype values that are subject to empirical calibration in future longitudinal studies:

| Constant | Value | Theoretical Basis | Design Rationale |
|---|---|---|---|
| Warning Decay rate | −5 pts/day | Prospect Theory (Kahneman & Tversky, 1979) — loss salience | Calibrated to be felt but not catastrophic in a 30-day cycle |
| Warning Decay cap | 3 days / −15 pts max | Prospect Theory | Cap prevents total wipe-out from a single budget breach |
| Gap Adjustment bonus | +2 pts/day (max +10) | Consistency principle (Ariely, 2008; Duhigg, 2012) | Smaller than penalty to match loss-aversion asymmetry |
| Gap Adjustment penalty | −3 pts/day (max −15) | Prospect Theory asymmetry | Penalty > reward mirrors loss > gain finding |
| Soft overspend weight | 0.5× | Prospect Theory / Nudge Theory — planned vs. habitual distinction | Single large purchases (tuition, medical) differ from habitual daily excess |
| Category Balance threshold | 40% of discretionary | Concentration risk design principle | Below 40%, any single category dominates minimally; above 40%, imbalance becomes behaviorally relevant |
| Spending Restraint grace zone | 80% of limit | Personal finance buffer principle | Remaining 20% provides a behavioral safety buffer before penalty begins |
| Habit Streak target | 14 days | SDT Competence (Deci & Ryan, 2000); Lally et al. (2010) habit formation research | 14 days is within the earliest reliable range (18–254 days mean ~66) for anchoring initial habit formation behavior |

---

*This table was prepared to support adviser validation of the FHS formula derivation. All citations are verifiable via DOI or official publication page.*
