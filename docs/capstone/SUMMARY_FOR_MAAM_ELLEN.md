# SmartSpend — FHS Formula, Validation, and Questionnaire Summary
### For Ma'am Ellen F. Mangaoang, MIT (Capstone Adviser)

**Project:** SmartSpend — AI-Assisted Mobile Financial Tracking and Advisory Application
**Researchers:** Directo, Brix A. · Rubis, Cyrille John M. · Madayag, Djaunathan Albert S.
**Institution:** Lorma Colleges — College of Computer Studies and Engineering
**Purpose:** A concise reference for the next adviser meeting (read in ~5 minutes)

---

## A. Literature Basis of the FHS Formula

The Financial Health Score (FHS) is a **Prototype Observed Financial Health Indicator (0–100)**, computed directly from the user's actual logged transaction data — not from self-report surveys. It was adapted from the **CBA–Melbourne Institute Observed Financial Health Indicator** (Comerton-Forde et al., 2018), which derives a 0–100 observed scale from actual bank-record data using equal-weight components. SmartSpend applies this transaction-based approach to a mobile SQLite database instead of bank records.

The FHS is the sum of four components, each worth 25 points:

| Component | Formula | Academic Basis |
|---|---|---|
| Savings Rate | 25 × min(1, savingsRate / 0.20) | Warren & Tyagi (2005) — 50/30/20 rule |
| Overspend Control | 25 × (1 − weightedOverDays / activeDays) | Kahneman & Tversky (1979) — Prospect Theory |
| Budget Adherence | 25 × (onBudgetCategories / totalBudgetCategories) | Financial Health Network FinHealth Score® — Plan pillar |
| Logging Consistency | 25 × (loggedDays / activeDays) | Deci & Ryan (2000) — Self-Determination Theory |

**Why equal weights (25 each):** The OECD/JRC *Handbook on Composite Indicators* (2008) establishes equal weighting as the methodologically correct default when no empirical basis exists for assigning differential weights. Each component contributes equally to the total, consistent with the CBA–Melbourne Institute dual-scale model.

---

## B. Validation

**System Usability Scale (SUS):** Preliminary results from N = 5 respondents yield a mean SUS of **62.50**, corresponding to **Grade C / "OK"** per the Bangor et al. (2009) interpretation scale. This sits below the established 68-point average benchmark. We acknowledge this as a limitation; the full N = 30 evaluation is ongoing and will be reported in the final manuscript.

**Technical validation:** OCR precision of **91.2%**, Taglish (Filipino-English) transaction categorization accuracy of **94.6%**, and a **100% database recovery rate** across backup/restore testing.

**Formula validation:** The formula design follows the CBA–Melbourne Institute dual-scale model (Comerton-Forde et al., 2018, 2020). The prototype status of the indicator is explicitly acknowledged throughout the documentation.

---

## C. Questionnaire Status

A **30-question survey instrument** has been completed and is ready for adviser content validation and signature. It is structured into five sections:

1. **Respondent Profile** (Q1–Q7)
2. **Financial Practices** (Q8–Q13)
3. **Budgeting Challenges** (Q14–Q20)
4. **Expense Tracking** (Q21–Q26)
5. **Supplementary Profile** (Q27–Q30)

**Sampling plan:** N = 30 respondents — 20 parents aged 35–55 (primary) and 10 young professionals aged 21–35 (secondary) — drawn from San Fernando City, La Union.

The survey is ready for content validation and is **awaiting Ma'am Ellen's signature**.

---

Full documentation available in: FHS_Formula_For_Maam_Mangaoang.pdf, FHS_Formula_Basis_Table.pdf, FHS_Defense_Guide.pdf
