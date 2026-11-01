# "Paano Ninyo Nakuha ang Formula Ninyo?" — Defense Answer Guide
**For:** Cyrille John M. Rubis (and the whole team)
**Prepared:** November 1, 2026
**Question asked by:** Panelist (likely Sir Raposas or Ma'am Mzana)

---

## THE SHORT ANSWER (memorize this first)

> *"Our Financial Health Score was not invented from scratch. We derived it by adapting an established academic framework — the CBA–Melbourne Institute Observed Financial Health Indicator — which uses actual transaction data to measure financial health on a 0–100 scale. We selected four components based on what our needs assessment confirmed were the most common problems of our target users — difficulty saving, overspending, not setting budgets, and inconsistent tracking — and assigned 25 points to each, following the equal-weight design of the original framework."*

That's 3 sentences. Practice saying that until it's automatic. Everything below is the expanded defense if they follow up.

---

## THE LONG ANSWER (for follow-up questions)

### Step 1 — We started with a research gap, not a formula

During our needs assessment (N=30 respondents, parents 35–55 and young professionals 21–35 in San Fernando, La Union), we identified four consistent pain points:
1. **They couldn't save** — spending exceeded income regularly
2. **They overspent** on discretionary categories
3. **They didn't set budgets** — no structure to guide decisions
4. **They stopped logging** after a few days — habit friction

These four problems directly map to our four FHS components. The formula didn't come first — the users' problems did.

### Step 2 — We found an academic basis that matched

We reviewed existing financial health measurement frameworks and found three that were relevant:

| Framework | What it does | Why we used it |
|-----------|-------------|----------------|
| **CBA–Melbourne Institute Observed Financial Health Indicator** (Comerton-Forde et al., 2018) | Transaction-based, equal-weight components summing to 0–100 | This is the closest to our approach — uses actual bank records, not surveys, with equal-weight design |
| **UNSGSA Note** (Gubbins, Mazzotta & Rhyne, 2021) | Calls transaction-derived data an "early-stage complement" to survey-based measures | Validates using transaction data as a financial health proxy |
| **Financial Health Network FinHealth Score®** | Measures Spend, Save, Plan, and their sub-components | Inspired our component categories |

The Melbourne Institute framework gives us our **methodological justification**: using transaction data to derive a financial health score is an established practice, not our invention.

**Why we don't call it the Melbourne Institute scale:** Their Terms of Use require modified versions to use a different name. That's why we call it a **"Prototype Observed Financial Health Indicator (FHI)"** in the manuscript — same transaction-based philosophy, different components adapted for Philippine mobile app context.

### Step 3 — We designed the components to match the gaps

Each component was chosen because it directly addresses one of the four problems from Step 1, and because it can be measured from transaction data alone (no surveys, no self-reporting):

| Problem found | Component | Formula | Basis |
|--------------|-----------|---------|-------|
| Can't save | **Savings Rate** (25 pts) | `25 × min(1, savingsRate / 0.20)` | Warren & Tyagi (2004) established 20% savings target in the 50/30/20 rule |
| Overspending daily | **Overspend Control** (25 pts) | `25 × (1 − weightedOverDays / activeDays)` | Kahneman & Tversky (1979) Prospect Theory — loss framing; Thaler & Sunstein nudge theory |
| No budgets | **Budget Adherence** (25 pts) | `25 × (onBudgetCategories / totalBudgetCategories)` | Standard personal finance — budget adherence as behavioral indicator |
| Inconsistent logging | **Logging Consistency** (25 pts) | `25 × (loggedDays / activeDays)` | Deci & Ryan Self-Determination Theory — habit formation requires consistency |

### Step 4 — We validated the equal-weight design

Why 25 points each? Not arbitrary. Three reasons:
1. **Melbourne Institute precedent** — their framework uses equal-weighted components summing to 100
2. **No empirical basis for differential weighting** — we don't have the longitudinal data to say savings rate is "more important" than overspend control for this population; equal weighting is the defensible choice when evidence is insufficient
3. **Transparency** — users can easily understand "each pillar is worth 25 points" without needing a finance degree

### Step 5 — We added two adjustments grounded in theory

**Warning Decay** (−5 pts/day, max −15):
- Based on Kahneman & Tversky's Prospect Theory — if a user keeps spending after a budget warning, the "loss" compounds. This prevents users from gaming the system by setting one warning and ignoring it.

**Lightweight Mode** (different 4 components when income is not set):
- Some users (students, household managers) don't have a regular income to track. Rather than penalizing them, we redesigned the components: Spending Restraint, Category Balance, Logging Consistency, Habit Streak — all measurable without income data.

---

## HOW TO SAY IT IN THE DEFENSE

**Panel:** *"Paano ninyo nakuha yung formula ninyo?"*

**Cyrille:**
> *"Hindi po namin ginawa ang formula mula sa wala. Nag-review po kami ng existing financial health frameworks. Ang pinaka-related ay ang CBA–Melbourne Institute Observed Financial Health Indicator — naggagamit ito ng actual transaction data at nag-eequal-weight ng four components para makuha ang 0–100 score. Ginaya namin yung philosophy — transaction-based, equal weight — pero binago namin ang mga components para tumugma sa mga problema na natuklasan namin sa aming needs assessment. Yung apat na components namin — Savings Rate, Overspend Control, Budget Adherence, at Logging Consistency — direktang nagre-reflect ng apat na pinaka-common na financial challenge ng aming mga respondents sa San Fernando, La Union."*

---

## FOLLOW-UP QUESTIONS THEY MIGHT ASK

**Q: Bakit 25 points each? Bakit hindi mas mataas ang savings rate?**

> *"Equal weighting is the methodologically defensible choice when there is insufficient empirical evidence to assign differential weights. We don't have longitudinal data to prove that savings rate is more important than logging consistency for this population. The Melbourne Institute uses equal weighting for the same reason. If we had multi-year behavioral data from our respondents, we could consider differential weighting in a future version."*

**Q: Nagtry kayo ng ibang weights?**

> *"Sa development phase, nag-explore po kami ng alternative weighting schemes, but we ultimately chose equal weights because: (1) it has academic precedent, (2) it's transparent to users — madaling maintindihan ng user na bawat component ay 25 points, and (3) it avoids the risk of introducing arbitrary bias without empirical justification."*

**Q: Bakit 20% savings target?**

> *"The 20% target comes from Warren & Tyagi's 50/30/20 framework — 50% for needs, 30% for wants, 20% for savings. This is a widely cited personal finance guideline. We use it as the threshold for full points on the Savings Rate component, which means users get full credit when they achieve the minimum recommended savings rate."*

**Q: Ano ang difference ng FHS sa mga existing financial health tools?**

> *"Most existing tools — like CFPB's Financial Well-Being Scale — are survey-based: they ask users to rate their financial feelings. Our FHS is transaction-derived: it calculates from actual spending data. This removes self-reporting bias. The Melbourne Institute framework validates this approach — they call it an 'Observed Financial Health Indicator' to distinguish it from subjective survey scales. We named ours a 'Prototype Observed FHI' following their naming guidance."*

**Q: Validated ba ang formula ninyo?**

> *"The formula follows validated academic frameworks, but the specific implementation is a prototype. Our SUS evaluation validated the usability of the system, not the formula itself. For clinical validation of the FHS as a financial health predictor, we recommend a longitudinal study — which we include in our Chapter IV recommendations. This is an honest scope limitation we acknowledge in the manuscript."*

---

## FOR CYRILLE — HOW TO PREPARE THE LITERATURE REVIEW SECTION

The screenshots you shared from social media are all correct. Here's how to apply them to your RRL:

### ✅ Do this with NotebookLM (use the 7 prompts from the post)

Upload these source documents to NotebookLM:
1. `FHS_Basis_and_Verification.docx` (in docs/handsoff/)
2. `SmartSpend_Comparative_Research_Report.docx` (in docs/handsoff/)
3. `FHS-Comparative-Review-Advantages-and-Disadvantages-FINAL.docx` (in docs/handsoff/)

Then use Prompt #3 (Critical Analysis) to get: *"Compare the FHS approaches in the uploaded sources — where do they agree, where do they differ, and what gaps justify our prototype?"*

Use Prompt #4 (Research Gaps) to get: *"What gaps in existing financial health measurement tools justify building a transaction-derived mobile app indicator for Filipino users?"*

This gives you Chapter II synthesis paragraphs that are based on YOUR actual sources, not AI-invented citations.

### ✅ Verify citations BEFORE submitting (from the LD TechLab post)

Every reference in Chapter II, check all 5:
1. **Title + Authors** — search exact title in Google Scholar in quotes
2. **Publication source** — find the journal on IEEE Xplore, ACM, ResearchGate, or DOAJ
3. **DOI** — paste at doi.org — if it opens a different paper, it's wrong
4. **Abstract** — read it — confirm it's actually about financial health / mobile apps / FHS
5. **Status** — no retraction notices

The three UNVERIFIED references in your current manuscript (FHN 2026, Groq 2026, Li et al. 2024) — do NOT use them until verified. Claude already flagged these. If they can't be found, delete them and replace with a verifiable source.

### ✅ Where to find RRL sources for your topic (from the screenshots)

Best databases for **financial health + mobile apps + Filipino context**:
- **Google Scholar** — search: `"financial health score" mobile app Philippines`
- **ResearchGate** — search: `personal finance app Taglish OR Filipino`
- **DOAJ** (Directory of Open Access Journals) — free full text, no paywall
- **PubMed Central** — for behavioral finance / financial wellness papers
- **ACM Digital Library** — for mobile app usability / HCI papers
- **Mendeley** — good for building your reference library

Search strings to use:
- `"financial health indicator" transaction data`
- `"expense tracking" mobile application usability`
- `"personal finance app" developing countries OR Philippines`
- `gamification personal finance behavior`
- `"financial well-being scale" mobile`

---

## THE BOTTOM LINE FOR THE DEFENSE

**The formula question is actually your strongest question.** You have a real answer:
- Grounded in Melbourne Institute framework (real academic basis)
- Adapted to match your users' actual problems (needs assessment)
- Equal-weighted because that's the defensible choice without longitudinal data
- Acknowledged as a prototype (honest about scope)

The panel will respect that answer because it shows you actually did research, not just built a random scoring system.

Practice saying the short answer (3 sentences at the top of this document) until it's second nature for all three of you.
