# SELECTED SURVEY QUESTIONS FOR ADVISER VALIDATION — FINAL VERSION

**SmartSpend: An AI-Assisted Mobile Financial Tracking and Advisory Application**
**Team Lucid Frame · Lorma Colleges — College of Computer Studies and Engineering**
**Prepared by:** Cyrille John M. Rubis | **Date:** November 1, 2026
**Version:** Final (v2) — fixes applied per internal review

---

## 1. What This Document Is

From the 34-question proposed questionnaire, we selected **30 questions** that best fit the final manuscript. Four questions (Q27–Q30) were added from Appendix B of the manuscript because they are needed for Table 3.1 and directly test FHS component hypotheses. Each selected question keeps the original wording and response options, and has a short explanation of why it fits the study.

### How the questions were chosen

1. **Fits Objective 1.** The question answers one of the three themes in Objective 1: financial management practices, budgeting challenges, or expense tracking behaviors of parents (35–55) and young professionals (21–35) in San Fernando City, La Union.
2. **Traceable to the manuscript.** It connects to a gap in Table 1.1, to a Financial Health Score component, or to a SmartSpend feature, so the answers can justify the design.
3. **Analyzable as planned.** It is closed-ended, so it can be reported by frequency and percentage, which is the analysis the manuscript states for survey responses.
4. **Short and not repeated.** With only 30 respondents, overlapping questions were removed.

### Coverage at a glance

| Part of Objective 1 | Questions kept | Main link in manuscript |
|---------------------|---------------|------------------------|
| Respondent profile (Section A) | 7 of 7 (Q1–Q7) | Inclusion criteria; Table 2.1 and Table 3.1 respondent profile |
| Financial management practices (Section B) | 6 of 9 (Q8–Q13) | BSP (2021) budgeting gap; Savings Rate; Budget Adherence |
| Budgeting challenges (Section C) | 7 of 12 (Q14–Q20) | Table 1.1 gaps; Overspend Control; Warning Decay; feature needs |
| Expense tracking behaviors (Section D) | 6 of 6 (Q21–Q26) | Logging Consistency; Gap Adjustment; multi-modal input; Smart Import |
| Supplementary profile & feature needs (Section E) | 4 added (Q27–Q30) | Table 3.1 demographics; Warning Decay test; AI feature need justification |
| **Total** | **30** | |

---

## 2. Selected Questions and Why Each Fits

### INTRODUCTION AND INFORMED CONSENT
*(To appear at the top of the questionnaire given to respondents)*

> Good day! We are conducting a study to understand the financial management practices, budgeting challenges, and expense tracking behaviors of parents and young professionals in San Fernando City, La Union. The findings will be used to identify user needs and requirements for a proposed financial management system.
>
> Participation is voluntary. Your responses will be treated confidentially and used only for the stated research purposes. You may skip questions that you are uncomfortable answering. You are not required to provide your exact salary, bank account details, or other sensitive financial information.
>
> **I confirm that I am 18 years old or above and I voluntarily agree to participate in this research survey.**
> ☐ Yes, I understand and agree
> ☐ I do not agree to participate (end of survey)

---

### SECTION A. Respondent Profile

*Confirms who qualifies and lets the results be reported for the two groups (Table 3.1: 20 parents, 10 young professionals).*

**Classification rule (for sampling):** Ages 35–55 who identify as Parent (Q2) and primary decision-maker (Q6) → Parent group. Ages 21–34 who are working (Q4) → Young Professional group. A 35-year-old respondent who is both a parent and a young professional → classified in the Parent group.

| New Q | Original Q | Question and response options | Why it fits |
|-------|-----------|------------------------------|-------------|
| 1 | 1 | **What is your age?**<br>☐ 21–25<br>☐ 26–30<br>☐ 31–34<br>☐ 35–40<br>☐ 41–45<br>☐ 46–50<br>☐ 51–55<br>☐ Below 21 / Above 55 (not eligible for this study) | Checks eligibility against the manuscript's definitions (parents 35–55, young professionals 21–35) and separates the two groups for reporting. |
| 2 | 2 | **Which category best describes you?**<br>☐ Parent<br>☐ Young professional<br>☐ Both a parent and a young professional<br>☐ Neither | Classifies each respondent as part of the primary (parent) or secondary (young professional) population, which the 20/10 sampling plan requires. |
| 3 | 3 | **Do you currently reside in San Fernando City, La Union?**<br>☐ Yes<br>☐ No | The study locale is San Fernando City, La Union (Objective 1; Scope and Limitations). |
| 4 | 4 | **What is your current employment status?**<br>☐ Employed full-time<br>☐ Employed part-time<br>☐ Self-employed / business owner<br>☐ Freelance / contractual<br>☐ Government employee<br>☐ Unemployed<br>☐ Other | Young professionals are defined as working individuals. Freelance and informal workers are also the users Lightweight Mode was built for. |
| 5 | 5 | **How many people, including yourself, depend on your income or financial support?**<br>☐ None<br>☐ 1<br>☐ 2–3<br>☐ 4–5<br>☐ 6 or more | The manuscript describes parents as carrying the highest household financial responsibility. This measures that claim. |
| 6 | 6 | **Who usually makes financial decisions in your household or personal life?**<br>☐ I make the decisions independently<br>☐ I share decisions with my spouse or partner<br>☐ I share decisions with parents or other family members<br>☐ Someone else primarily makes the decisions<br>☐ Other | Confirms the inclusion criterion that respondents are principal household financial decision-makers (BSP, 2021). |
| 7 | 7 | **How often do you receive income?**<br>☐ Weekly<br>☐ Every two weeks<br>☐ Twice a month<br>☐ Monthly<br>☐ Irregularly<br>☐ Other | Irregular income is the reason for Full Mode versus Lightweight Mode. Pay frequency also affects the daily, weekly and monthly budget limits. |

---

### SECTION B. Existing Financial Management Practices

*Objective 1, theme 1: how respondents plan, save and manage money today.*

| New Q | Original Q | Question and response options | Why it fits |
|-------|-----------|------------------------------|-------------|
| 8 | 8 | **Do you prepare a budget for your personal or household finances?**<br>☐ Always<br>☐ Often<br>☐ Sometimes<br>☐ Rarely<br>☐ Never | Measures the lack of structured budgeting that the manuscript cites from BSP (2021). It is the baseline for the Budget Adherence component. |
| 9 | 9 | **How do you usually manage your budget?** *(Select all that apply.)*<br>☐ Written budget in a notebook<br>☐ Spreadsheet (e.g., Excel or Google Sheets)<br>☐ Mobile application<br>☐ Notes application on my phone<br>☐ Calculator<br>☐ Mental estimates or memory<br>☐ Advice or assistance from another person<br>☐ Other | Shows how much respondents still budget by hand or from memory, which is the manual-effort burden SmartSpend is meant to remove. |
| 10 | 10 | **How often do you review your financial situation?**<br>☐ Daily<br>☐ Weekly<br>☐ Every two weeks<br>☐ Monthly<br>☐ Only when necessary<br>☐ Never | Indicates how often users would check summaries and the 30-day Financial Health Score trend. |
| 11 | 12 | **Do you set aside money for savings before spending on other expenses?**<br>☐ Always<br>☐ Often<br>☐ Sometimes<br>☐ Rarely<br>☐ Never | Baseline for the Savings Rate component (25 points, 20% target). |
| 12 | 14 | **How do you manage unexpected expenses?**<br>☐ Use an emergency fund<br>☐ Use money allocated for other expenses<br>☐ Borrow money<br>☐ Use credit cards or other credit facilities<br>☐ Use additional income<br>☐ Ask family or friends for financial assistance<br>☐ Other | Shows reliance on emergency funds versus borrowing and informal credit, which the manuscript says Filipino users rely on. |
| 13 | 15 | **Do you usually know how much money remains available for spending before your next payday or income receipt?**<br>☐ Always<br>☐ Often<br>☐ Sometimes<br>☐ Rarely<br>☐ Never | Awareness of remaining spendable money is the behavior that Overspend Control and Spending Restraint reward. |

---

### SECTION C. Common Budgeting Challenges

*Objective 1, theme 2: problems the system should help solve.*

**For Questions 14–17:** Rate on a 1–5 scale where **1 = Never, 2 = Rarely, 3 = Sometimes, 4 = Often, 5 = Always.**

| New Q | Original Q | Question and response options | Why it fits |
|-------|-----------|------------------------------|-------------|
| 14 | 18 | **How often do your actual expenses exceed your planned budget?**<br>1 = Never · 2 = Rarely · 3 = Sometimes · 4 = Often · 5 = Always | Baseline for the Overspend Control component and for budget-limit alerts. |
| 15 | 21 | **How often do you spend money on nonessential items that were not included in your budget?**<br>1 = Never · 2 = Rarely · 3 = Sometimes · 4 = Often · 5 = Always | Discretionary overspending is what Warning Decay penalizes. Bills, health and education are exempt. |
| 16 | 22 | **How often do you find it difficult to set aside money for savings after paying your expenses?**<br>1 = Never · 2 = Rarely · 3 = Sometimes · 4 = Often · 5 = Always | Supports having savings goals and round-up savings, and explains why Savings Rate is a score component. |
| 17 | 23 | **How often do you have difficulty keeping track of bills, loan payments, or payment deadlines?**<br>1 = Never · 2 = Rarely · 3 = Sometimes · 4 = Often · 5 = Always | Supports the recurring-transaction, debt and bill-tracking features that the app stores. |
| 18 | 24 | **What are the main challenges you experience when managing your finances?** *(Select all that apply.)*<br>☐ Insufficient income<br>☐ Increasing prices of basic goods and services<br>☐ Unexpected medical or emergency expenses<br>☐ Family responsibilities or dependents<br>☐ Difficulty controlling discretionary spending<br>☐ Debt or loan repayments<br>☐ Irregular income<br>☐ Lack of a clear budget<br>☐ Difficulty recording expenses<br>☐ Difficulty tracking several financial obligations<br>☐ Lack of time to manage finances<br>☐ Lack of knowledge about budgeting<br>☐ I do not experience significant budgeting challenges<br>☐ Other | This is the main test of the gaps in Table 1.1: manual effort (difficulty recording), irregular tracking, and no clear budget. |
| 19 | 27 | **What do you usually do when you realize that you have exceeded your budget?** *(Select all that apply.)*<br>☐ Reduce spending in other categories<br>☐ Use savings<br>☐ Delay nonessential purchases<br>☐ Borrow money<br>☐ Use credit<br>☐ Seek additional income<br>☐ Continue spending without adjusting the budget<br>☐ Other | The option "continue spending without adjusting" tests the manuscript's claim that warnings are ignored without consequences, which Warning Decay addresses. |
| 20 | 28 | **What would help you manage your budget more effectively?** *(Select all that apply.)*<br>☐ Automatic expense categorization<br>☐ Budget limits for each category<br>☐ Notifications when approaching a budget limit<br>☐ Bill and payment reminders<br>☐ Savings goal tracking<br>☐ Monthly financial summaries<br>☐ Spending trend reports<br>☐ Debt and loan tracking<br>☐ Financial education or budgeting tips<br>☐ Other | Gives evidence from respondents for the Requirements Phase. The options match SmartSpend features: AI categorization, budget alerts, summaries, and goal and debt tracking. |

---

### SECTION D. Expense Tracking Behaviors

*Objective 1, theme 3: how respondents record and monitor spending.*

| New Q | Original Q | Question and response options | Why it fits |
|-------|-----------|------------------------------|-------------|
| 21 | 29 | **Do you currently record your personal or household expenses?**<br>☐ Always<br>☐ Often<br>☐ Sometimes<br>☐ Rarely<br>☐ Never | Baseline for Logging Consistency, the fourth score component, and for the irregular-tracking problem in the manuscript. |
| 22 | 30 | **How do you record your expenses?** *(Select all that apply.)*<br>☐ Notebook or diary<br>☐ Spreadsheet<br>☐ Mobile financial management application<br>☐ Notes application<br>☐ Receipts<br>☐ Banking or e-wallet transaction history<br>☐ Mental estimates or memory<br>☐ I do not record expenses<br>☐ Other | Justifies the multi-modal input (text, voice, receipt OCR, barcode, import) by showing what respondents use now. |
| 23 | 31 | **How soon after making a purchase do you usually record the expense?**<br>☐ Immediately<br>☐ Within the same day<br>☐ Within a few days<br>☐ At the end of the week<br>☐ At the end of the month<br>☐ I do not record expenses | Delayed logging is why the score is date-aware and why a Gap Adjustment exists for unlogged days. |
| 24 | 32 | **Which expenses do you usually track?** *(Select all that apply.)*<br>☐ Cash purchases<br>☐ Debit card transactions<br>☐ Credit card transactions<br>☐ Bank transfers<br>☐ E-wallet transactions<br>☐ Online purchases<br>☐ Recurring bills<br>☐ Loan repayments<br>☐ Savings contributions<br>☐ All of the above<br>☐ None of the above | The manuscript says Filipino users mix cash, e-wallets and informal credit. This supports offline cash entry and GCash/Maya Smart Import. |
| 25 | 33 | **How do you categorize your expenses?**<br>☐ I use predefined categories<br>☐ I create my own categories<br>☐ I record expenses without categorizing them<br>☐ I estimate spending by category<br>☐ I do not track expenses | Shows the need for AI automatic categorization and supports the Category Balance and 50/30/20 analytics. |
| 26 | 34 | **How often do you compare your actual spending with your planned budget?**<br>☐ Daily<br>☐ Weekly<br>☐ Every two weeks<br>☐ Monthly<br>☐ Only when necessary<br>☐ Never | Baseline for Budget Adherence (staying within category budgets) and for how often alerts should appear. |

---

### SECTION E. Supplementary Profile and Feature Needs

*Four questions added from the manuscript's Appendix B. Required for Table 3.1 respondent profile and for testing Warning Decay and AI feature adoption hypotheses.*

| New Q | Source | Question and response options | Why it fits |
|-------|--------|------------------------------|-------------|
| 27 | Appendix B | **What is your gender?**<br>☐ Male<br>☐ Female<br>☐ Prefer not to say | Table 3.1 respondent profile requires gender breakdown. Standard demographic item. |
| 28 | Appendix B | **What is your monthly income range?**<br>☐ Below ₱10,000<br>☐ ₱10,000 – ₱20,000<br>☐ ₱20,000 – ₱40,000<br>☐ Above ₱40,000<br>☐ Prefer not to say / Not applicable | Table 3.1 respondent profile. Also validates income range assumptions in the Savings Rate and Safe-to-Spend formula (20% savings target). |
| 29 | Appendix B | **Have you ever exceeded your monthly budget and then continued spending without adjusting or ignoring a spending warning or alert?**<br>☐ Yes<br>☐ No<br>☐ Not applicable (I do not have a budget) | Directly tests the Warning Decay hypothesis — the manuscript claims users ignore negative spending alerts without consequences. This question measures that behavior. |
| 30 | Appendix B | **Would you use an AI-powered financial assistant application to help manage your finances?**<br>☐ Yes, definitely<br>☐ Probably yes<br>☐ Not sure<br>☐ Probably not<br>☐ No | Validates the Technology Acceptance Model (TAM) dimension: Perceived Usefulness. Required for Objective 1 → feature needs justification and system acceptance rationale. |

---

## 3. Questions Not Selected

Eight questions from the original 34 were left out.

| Original Q | Reason left out |
|-----------|----------------|
| Q11 | Long list of planned expenses; overlaps with Q8 (budgeting) and Q24 (challenges). |
| Q13 | How money is allocated across categories; too detailed and overlaps with Q8 and Q34. |
| Q16 | Activity checklist that repeats Q8, Q10, Q29 and Q34. |
| Q17 | General "income covers expenses" question; captured more specifically by Q18 and Q22. |
| Q19 | Unexpected expenses disrupting the budget; covered by Q14 and Q24. |
| Q20 | Difficulty prioritizing expenses; not tied to a SmartSpend feature or score component. |
| Q25 | Causes of exceeding the budget; overlaps with Q24 and Q21. |
| Q26 | Hardest financial goals; savings-goal need already captured by Q22 and Q28. |

---

## 4. Points for the Adviser to Decide

1. **Respondent classification at age 35.** The groups overlap at age 35. Proposed rule: ages 35–55 who identify as Parent (Q2) and primary decision-maker (Q6) go to the parent group; ages 21–34 who are working (Q4) go to the young-professional group; a 35-year-old who is both goes to the parent group. Adviser confirmation needed.

2. **Reporting format for Q14–Q17 (1–5 scale).** The manuscript states frequency and percentage analysis. For Likert items, we recommend reporting both: (a) frequency table per response level, and (b) mean and standard deviation. This matches standard practice and gives richer data for Chapter III. Adviser confirmation needed.

3. **Section E addition.** Q27–Q30 were not in the original proposed questionnaire but are already in the live Google Forms Research Survey. They are included here because the manuscript's Table 3.1 and the Warning Decay discussion require them. Adviser confirmation needed.

4. **Q26 completion.** The original proposed questionnaire file (Q34) was cut off after "Weekly." The remaining options (Every two weeks, Monthly, Only when necessary, Never) were completed using the same wording as the review-frequency question (Q10). Adviser should confirm these options are acceptable.

---

## 5. Final Questionnaire Summary (30 questions)

| Section | Questions | Count |
|---------|-----------|-------|
| A — Respondent Profile | Q1–Q7 | 7 |
| B — Financial Management Practices | Q8–Q13 | 6 |
| C — Budgeting Challenges | Q14–Q20 | 7 |
| D — Expense Tracking Behaviors | Q21–Q26 | 6 |
| E — Supplementary Profile & Feature Needs | Q27–Q30 | 4 |
| **Total** | | **30** |

Estimated completion time: **5–7 minutes**

---

*Prepared by Cyrille John M. Rubis for adviser validation.*
*SmartSpend Capstone 2 — Lucid Frame — Lorma Colleges CCSE — AY 2026–2027*
