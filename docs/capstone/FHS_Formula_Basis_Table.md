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
| **Equal-weight components** | Each of the 4 FHS components is worth exactly 25 points | CBA–Melbourne Institute (2018) — uses equal-weight summing of transaction-derived components to 100; UNSGSA (Gubbins, Mazzotta & Rhyne, 2021) — endorses equal-weight design when longitudinal differential-weight data is unavailable | We used equal weights because we do not have the multi-year behavioral data needed to justify differential weights for this population |
| **"Prototype Observed FHI" naming** | We call it a Prototype Observed FHI, not a Financial Health Score | Melbourne Institute Terms of Use require modified scales to use a different name. The UNSGSA note (2021) distinguishes Observed FHIs (transaction-derived) from subjective survey-based scales | We renamed our implementation to comply with Melbourne Institute guidance and to accurately distinguish it from the CFPB Financial Well-Being Scale |
| **Component 1: Savings Rate (25 pts)** | Formula: 25 × min(1, savingsRate / 0.20). Full score when the user saves ≥20% of income | Warren & Tyagi (2004) — the 50/30/20 rule establishes 20% savings as the standard personal finance target; FinHealth Score® (Financial Health Network) — Spend pillar includes savings rate as a core health indicator | We used the 20% threshold directly from the 50/30/20 framework as the benchmark for full points |
| **Component 2: Overspend Control (25 pts)** | Formula: 25 × (1 − weightedOverDays / activeDays). Soft overspend (single large purchase) counts at 0.5×; hard overspend (habitual) counts at 1× | Kahneman & Tversky (1979) — Prospect Theory: losses feel ~2× more painful than equivalent gains, making overspend consequences motivationally salient; Thaler & Sunstein (2008) — Nudge Theory: framing spending as a "loss against budget" reinforces behavioral correction | The soft/hard split prevents the app from penalizing a one-time large purchase (e.g., school tuition) the same as daily habitual overspending |
| **Component 3: Budget Adherence (25 pts)** | Formula: 25 × (onBudgetCategories / totalBudgetCategories). If no budgets set: auto-award 25 pts | FinHealth Score® (Financial Health Network) — Plan pillar includes budget adherence as a core health behavior; BSP CFIS (2025) — fewer than 50% of Filipino households maintain any written budget, making budget-setting itself a measurable behavior | We auto-award 25 pts when no budgets are configured — not penalizing users for lack of setup, but incentivizing them to add budgets for accurate tracking |
| **Component 4: Logging Consistency (25 pts)** | Formula: 25 × (loggedDays / activeDays). Full score when expenses are logged every active day | Deci & Ryan (2000) — Self-Determination Theory (SDT): habit formation requires consistent, intrinsically motivated behavior. Competence (logging every day) drives long-term engagement | We tied the Logging Consistency score directly to the Habit Streak feature and the streak milestone celebrations to reinforce daily logging via SDT's Competence dimension |
| **Warning Decay (−5 pts/day, max −15 pts)** | If the user continues spending on a budget category after receiving an alert, the FHS loses 5 points per day for up to 3 days | Kahneman & Tversky (1979) — Prospect Theory: losses create stronger behavioral responses than equivalent gains. The decay makes the consequence of ignoring warnings concrete and visible | Decay only applies to discretionary categories. Bills, Health, and Education are exempt — you cannot always avoid those expenses, so penalizing them would be unfair |
| **Lightweight Mode (4 alternate components)** | Used when income is not set. Replaces Savings Rate → Spending Restraint, Budget Adherence → Category Balance, Logging Consistency stays, adds Habit Streak | UNSGSA (2021) — recommends transaction-derived indicators as an early-stage complement when full income data is unavailable. Not all users track formal income (e.g., students on irregular allowances) | We redesigned 2 of 4 components for income-independent measurement so the app remains useful and non-penalizing for informal-economy users |
| **Gap Adjustment (+2/−3 pts/day)** | Score adjusts when the user logs many expenses on one day after a gap (positive) or goes multiple days without logging (negative) | Behavioral finance principle: consistency in financial tracking is more predictive of good outcomes than volume on a single day (Ariely, 2008; Duhigg, 2012) | We capped the adjustment at +10/−15 pts to prevent gaming (logging 100 expenses in one day) while still rewarding recovery after gaps |

---

## Table 2. Alignment with Established Financial Health Frameworks

This table shows how each SmartSpend FHS component maps to the three most widely cited financial health frameworks.

| SmartSpend FHS Component | CBA–Melbourne Institute (2018) | FinHealth Score® (FHN) | CFPB Financial Well-Being Scale (2017) |
|--------------------------|-------------------------------|------------------------|----------------------------------------|
| Savings Rate | Observed savings behavior from bank records | Save pillar: savings rate and buffer | Q7: "I could handle a major unexpected expense" |
| Overspend Control | Observed overspending days | Spend pillar: spending less than income | Q2: "My finances control my life" (reverse) |
| Budget Adherence | Category-level spending vs. limits | Plan pillar: on track with financial goals | Q9: "My finances are on track" |
| Logging Consistency | Data completeness metric | (Not directly measured) | (Not directly measured) |
| Warning Decay | (Not in framework — our addition) | (Not in framework — our addition) | (Not in framework — our addition) |

**Key difference:** The CFPB scale is self-reported (users rate their own feelings). The Melbourne Institute and FinHealth Score use transaction data like SmartSpend. The Warning Decay mechanism is our original design contribution, grounded in Prospect Theory.

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

Comerton-Forde, C., Ip, E., Ribar, D. C., Ross, J., Salamanca, N., & Tsiaplias, S. (2018). *Using survey and banking data to measure financial wellbeing* (CBA–MI Technical Report No. 1, executive summary). Commonwealth Bank of Australia & Melbourne Institute.

Deci, E. L., & Ryan, R. M. (2000). The "what" and "why" of goal pursuits: Human needs and the self-determination of behavior. *Psychological Inquiry, 11*(4), 227–268.

Financial Health Network. (2021). *FinHealth Score® Toolkit.* https://finhealthnetwork.org/tools/financial-health-score/

Gubbins, P., Mazzotta, B., & Rhyne, E. (2021). *Measuring financial health: Concepts and considerations.* UNSGSA Financial Health Working Group.

Kahneman, D., & Tversky, A. (1979). Prospect theory: An analysis of decision under risk. *Econometrica, 47*(2), 263–292.

Thaler, R. H., & Sunstein, C. R. (2008). *Nudge: Improving decisions about health, wealth, and happiness.* Yale University Press.

Warren, E., & Tyagi, A. W. (2004). *All your worth: The ultimate lifetime money plan.* Free Press.

---

*This table was prepared to support adviser validation of the FHS formula derivation. All citations are verifiable via DOI or official publication page.*
