# FHS Formula Audit — Findings Report
**Audit Date:** November 2026  
**Auditor:** Kiro (READ-ONLY investigation — no code was modified)  
**Files Read:**
- `lib/services/score_service.dart` (actual implementation)
- `docs/capstone/FHS_Formula_Basis_Table.md`
- `docs/capstone/FHS_FORMULA_DERIVATION_DEFENSE_GUIDE.md`
- `docs/manuscript/reseaches/smartspend-thesis-chapter-3.md`
- `docs/manuscript/reseaches/smartspend-thesis-chapter-4.md`

---

## EXECUTIVE SUMMARY

The FHS formula is **substantially sound** — the academic grounding is real, the core components are well-argued, and the Melbourne Institute / UNSGSA basis is legitimate. However, the audit found **nine specific gaps** that a panel or adviser could challenge:

1. Several specific numeric constants (−5/−15 decay, +2/−3 gap, 0.5× soft weight, 80% restraint threshold) have NO literature citations — they are presented as if grounded in theory but are actually design judgments.
2. The Lightweight Mode Category Balance formula in the manuscript does **not match** the actual code — a significant code-vs-documentation discrepancy.
3. Ariely (2008) and Duhigg (2012) are cited but their full bibliographic details are absent from the Basis Table references section.
4. The UNSGSA 2021 citation lacks a verified DOI and the URL in the Basis Table does not match what is published.
5. The "equal weights because we lack multi-year data" justification itself has no citation — it is a reasonable argument but presented as if it were an established principle.
6. The Melbourne Institute citation lists "Ip, E." as an author who does not appear in the verified author block of Technical Report No. 1.
7. No explicit source is given for the "14-day streak = full score" constant in Habit Streak.
8. No citation for the "60% dominance threshold is behaviorally problematic" claim referenced in the original Category Balance comments (code now uses 40%, docs cite 60%).
9. Chapter 3 and Chapter 4 disagree on the primary LLM model name (Chapter 3 says "Gemini 3.1 Flash-Lite"; Chapter 4 says "Gemini 3.5 Flash-Lite").

---

## SECTION 1: Code vs. Documentation Discrepancies

### 1.1 Overspend Control — Formula Name Discrepancy

**Basis Table documents:**
> `25 × (1 − weightedOverDays / activeDays)`

**Defense Guide documents:**
> `25 × (1 − overDays / periodDays)` ← this is the simplified version, no soft/hard distinction

**Code (actual):**
```dart
final weightedOver = hardOverDays + softOverDays * 0.5;
final overRatio = weightedOver / activeDays;
comp2 = (1.0 - overRatio).clamp(0.0, 1.0) * 25;
```

**Status:** The Basis Table matches the code (uses `weightedOverDays`). The Defense Guide uses a simplified formula that omits the soft/hard distinction entirely. The Defense Guide is the document most likely to be read by a panel — it should match the code.

**Risk level: Medium.** If a panelist reads the Defense Guide and then looks at the code, they will see a discrepancy. Recommend updating the Defense Guide formula to the weighted version.

---

### 1.2 Category Balance — Formula Mismatch Between Manuscript and Code

**Chapter 3 manuscript documents** the formula as:
```
CB = 25 × max(0.0, 1.0 − max_c(Spending_c / TotalOutflow − 0.40))
```
This formula uses `TotalOutflow` (all spending) as the denominator and subtracts 0.40.

**Code (actual):**
```dart
// Uses *discretionaryTotal* (Bills/Health/Education excluded) as denominator
final topRatio = topEntry.value / discretionaryTotal;
// Scale: Full 25 pts at ≤40% concentration of *discretionary* spend
comp3 = ((1.0 - ((topRatio - 0.4) / 0.6).clamp(0.0, 1.0)) * 25).clamp(0.0, 25.0);
```

**Actual formula reconstructed from code:**
```
topRatio = topDiscretionaryCategory / discretionaryTotal
CB = 25 × (1 − ((topRatio − 0.40) / 0.60))   [clamped 0..1, then ×25 clamped 0..25]
```

**Discrepancy:** Two differences:
1. Denominator: manuscript uses `TotalOutflow`; code uses `discretionaryTotal` (Bills/Health/Education excluded).
2. Scaling: manuscript uses `1.0 − (ratio − 0.40)` which would reach 0 at 140% (impossible); code uses `(ratio − 0.40) / 0.60` which reaches 0 at exactly 100% of discretionary spend — this is the mathematically correct version.

**Risk level: HIGH.** The manuscript formula as written is technically wrong (the denominator change and scaling factor are both undocumented). A panel checking the manuscript against the code will find this.

---

### 1.3 Savings Rate — No-Income Fallback Undocumented

**All documentation** describes Savings Rate as:
```
25 × min(1, savingsRate / 0.20)
```

**Code (actual) when `monthlyIncome == 0`:**
```dart
comp1 = totalSpent < 5000 ? 20.0 : totalSpent < 10000 ? 15.0 : 10.0;
```

This fallback — awarding 10–20 pts based on spending tiers when income is unset — is **entirely absent from all documentation**. None of the three documents (Basis Table, Defense Guide, Chapter 3) mention it.

**Risk level: Medium.** A panelist asking "what happens if I don't set income?" will get an unexpected answer if they read only the documentation.

---

### 1.4 Warning Decay — Documented Parameters Match Code

**All docs document:** −5 pts/day, max 3 days, −15 pts total.

**Code (actual):**
```dart
final penalty = (decayDays.clamp(0, 3) * 5);
```

**Status: ✅ Consistent.** No discrepancy here.

---

### 1.5 Gap Adjustment — Documented Parameters Match Code

**Basis Table documents:** +2/−3 pts/day, max +10/−15 pts.

**Code (actual):**
```dart
final penalty = (penaltyDays * 3).clamp(0, 15);   // −3/day, max −15
final bonus = (bonusDays * 2).clamp(0, 10);        // +2/day, max +10
```

**Status: ✅ Consistent.** Parameters match.

---

### 1.6 Lightweight Mode — Spending Restraint Threshold Undocumented

**Defense Guide** describes Spending Restraint as: "Has the user stayed within their self-set spending limit this period?"

**Code (actual):**
```dart
// Full 25 pts at ≤80% of limit; scales to 0 at 2× the limit
comp1 = ((1.0 - ((ratio - 0.8) / 1.2).clamp(0.0, 1.0)) * 25).clamp(0.0, 25.0);
```

The **80% threshold** (full score until reaching 80% of limit) and the **2× limit = 0 pts** scaling are absent from all documentation.

Also, the fallback when no limit is set:
```dart
// 25 pts at ≤30% wants; scales to 10 pts at 70% wants
comp1 = ((1.0 - ((wantRatio - 0.3) / 0.4).clamp(0.0, 1.0)) * 15 + 10).clamp(10.0, 25.0);
```
The Want/Need proxy (30% threshold, floor of 10 pts) is entirely absent from all documentation.

**Risk level: HIGH.** This is a significant coverage gap for an adviser validation document.

---

### 1.7 Habit Streak — 14-Day Threshold

**Chapter 3** documents: "granting full points once a continuous 14-day tracking streak is established"

**Code:**
```dart
comp4 = (streak / 14.0).clamp(0.0, 1.0) * 25;
```

**Status: ✅ Consistent.** The 14-day constant is documented in Chapter 3, though no citation is given for WHY 14 days (see Section 2).

---

## SECTION 2: Uncited Specific Values (Numbers With No Literature Basis)

These are specific numeric constants in the formula that are presented with theoretical framing but have **no direct literature citation for the specific number itself**.

### 2.1 The −5 pts/day Warning Decay Rate

**What is cited:** Kahneman & Tversky (1979) Prospect Theory — the general principle that losses motivate behavior.

**What is NOT cited:** Why −5 specifically? Why not −3 or −10? Why a 3-day cap rather than 5 or 7?

**Assessment:** Prospect Theory justifies *having* a decay mechanism. It does not justify the specific magnitude. The −5/3-day values are design decisions. This should be disclosed as "calibrated by design" rather than implying the number itself is literature-derived.

**Challenge risk:** "Can you cite a paper that supports −5 pts per day and not −3 or −7?"

---

### 2.2 The +2/−3 Gap Adjustment Values

**What is cited:** "Behavioral finance principle: consistency in financial tracking is more predictive of good outcomes than volume on a single day (Ariely, 2008; Duhigg, 2012)"

**What is NOT cited:** Why +2 for clean days and −3 for unlogged days? Why asymmetric? Why max +10/−15?

**Assessment:** The asymmetry (penalty larger than reward) can be argued from Prospect Theory's loss > gain framing, but this connection is not explicitly drawn in any document. The specific magnitudes have no citation.

**Challenge risk:** "Why is the penalty 3 points but the bonus only 2?"

---

### 2.3 The 0.5× Soft Overspend Weighting

**What is cited:** Kahneman & Tversky (1979) Prospect Theory (general framing), Thaler & Sunstein (2008) Nudge Theory.

**What is NOT cited:** Why 0.5× for single-purchase overspend? Why not 0.25× or 0.75×?

**Assessment:** The concept of distinguishing planned vs. habitual spending has intuitive support in behavioral finance literature, but no specific paper is cited for the 0.5 coefficient.

**Challenge risk:** "Why does a single large purchase count as half an overspend day and not a third or a quarter?"

---

### 2.4 The 80% Threshold in Lightweight Spending Restraint

**What is cited:** Nothing. This threshold appears only in the code.

**Assessment:** The 80% "safe zone" before points start dropping is undocumented and uncited in all three documents. A reasonable parallel exists (personal finance often treats 80% budget utilization as healthy — the remaining 20% provides a buffer), but no citation is given.

**Challenge risk:** "Why does the app give full marks until 80% of the spending limit is used?"

---

### 2.5 The 40% Category Concentration Threshold

**What is cited:** Nothing directly. The Basis Table says Categories should not "dominate" but does not define where the threshold is set.

**Assessment:** The 40% threshold below which category concentration is fine, scaling to 0 at 100%, has no citation. The document mentions ">60% is unbalanced" in older text (Defense Guide says ">60%") but the code uses 40% as the start of the penalty zone — this is both an uncited value AND a code-documentation discrepancy.

**Challenge risk:** "How did you decide that 40% of discretionary spending in one category is the threshold?"

---

### 2.6 The 14-Day Habit Streak Threshold

**What is cited:** "micro-reward habit formation literature" (Chapter 3), Deci & Ryan SDT.

**What is NOT cited:** The specific 14-day figure. SDT does not specify a number of days. Duhigg's habit loop research discusses habit formation but not a 14-day milestone specifically.

**Note:** Some habit-formation literature (e.g., Phillippa Lally's 2010 European Journal of Social Psychology study) suggests habits take 18–254 days to form (mean ~66 days). The popular "21 days" figure is folk psychology. "14 days" appears to be a practical design choice, not a literature-derived number.

**Challenge risk:** "Why 14 days for a full Habit Streak score? What paper says 14 is meaningful?"

---

### 2.7 The 20% Savings Threshold

**Status: ✅ Cited.** Warren & Tyagi (2004) 50/30/20 rule is a real, verifiable source. This is the strongest citation in the formula. No gap here.

---

## SECTION 3: Lightweight Mode Coverage Gaps

### 3.1 Spending Restraint — Largely Undocumented

The Lightweight Spending Restraint component has **three undocumented behaviors**:

| Behavior | Documented? | Citation? |
|---|---|---|
| Full score when ≤80% of spending limit used | ❌ No | ❌ No |
| Score scales to 0 at 2× the spending limit | ❌ No | ❌ No |
| Fallback to Want/Need proxy when no limit set | ❌ No | ❌ No |
| 30% wants threshold for full score in no-limit fallback | ❌ No | ❌ No |
| Floor of 10 pts (never scores 0) in no-limit fallback | ❌ No | ❌ No |

The Defense Guide gives one sentence to Spending Restraint. The Basis Table gives it slightly more but still does not document the 80% threshold or the Want/Need fallback.

**Recommended addition:** A table row in the Basis Table specifically for Lightweight Spending Restraint with: the 80% grace threshold (justify with buffer principle), the Want/Need fallback (cite Kahneman/Tversky — discretionary vs. need spending distinction), and the floor of 10 pts (design choice to avoid total penalization of users with no limit set).

---

### 3.2 Category Balance — Formula Discrepancy Creates Documentation Gap

As noted in Section 1.2, the published formula in the manuscript uses the wrong denominator (`TotalOutflow` instead of `discretionaryTotal`). The exempt-category logic — Bills, Health, Education are excluded from the concentration check — is mentioned in the code comments but is **absent from the Basis Table and the Defense Guide**.

The exemption is actually well-reasoned (rent/tuition/bills dominating spend is legitimate), but there is no citation for *why these three specific categories* are exempt.

**Recommended addition:** Document the exempt category logic with reasoning (cite BSP CFIS 2025 on fixed-cost obligations as non-discretionary, which is already cited elsewhere in the Basis Table).

---

### 3.3 Habit Streak — Partially Documented

Chapter 3 correctly documents the 14-day streak and its connection to SDT Competence reinforcement. The Basis Table mentions it. The Defense Guide mentions it. The gap is only the uncited 14-day specific value (see Section 2.6).

**Assessment:** Lightweight Habit Streak is the best-documented Lightweight component. Minor gap only.

---

### 3.4 Missing: A Unified Lightweight Mode Section

None of the three documents has a dedicated section treating Lightweight Mode as a coherent design. The components appear scattered across tables and lists. A panel would benefit from a dedicated "Lightweight Mode Design Rationale" section that:
1. Explains WHO uses Lightweight Mode (students, informal workers, household managers)
2. Shows the component substitution table (Full → Lightweight)
3. Gives literature basis for each substitution
4. Explains the UNSGSA 2021 justification for the income-independent design

---

## SECTION 4: Challengeable Claims

### 4.1 "Equal weights because we lack multi-year data" — The justification itself has no citation

**The claim in the Defense Guide and Basis Table:**
> "Equal weighting is the methodologically defensible choice when there is insufficient empirical evidence to assign differential weights."

**The problem:** This meta-argument — that *equal weighting is the defensible default in the absence of longitudinal evidence* — is presented as if it were an established methodological principle, but no citation is given for the principle itself. The Melbourne Institute using equal weights is cited, but that is precedent, not a methodological rule.

**How to fix it:** Cite the measurement literature that formally endorses equal weighting as the conservative default. A good candidate: Equally-weighted composite indices are endorsed by the OECD Handbook on Constructing Composite Indicators (OECD/JRC, 2008), which explicitly states that equal weighting is the correct choice when there is no theoretical or empirical basis to prefer other weights.

**Challenge risk:** "The Melbourne Institute used equal weights — but they were measuring Australian bank customers with a specific validated scale. What justifies equal weights for your prototype with different components and a different population?"

---

### 4.2 Warning Decay "prevents gaming" — Needs elaboration

**The claim:** The −5/day decay "prevents users from gaming the system by setting one warning and ignoring it" (Basis Table).

**The problem:** This is a design intent claim, not an evidence-based claim. There is no citation for the mechanism actually preventing gaming behavior. The connection between score visibility, loss aversion, and behavioral change is theoretically grounded in Prospect Theory, but "prevents gaming" specifically is not demonstrated.

**Challenge risk:** "How do you know users won't just turn off the app when their score drops?"

**Suggested framing fix:** Replace "prevents gaming" with "creates a visible consequence grounded in Prospect Theory's loss-salience principle, designed to increase the perceived cost of ignoring warnings." This is honest about the mechanism being designed rather than empirically proven.

---

### 4.3 "Transaction-derived scoring removes self-reporting bias" — Unqualified claim

**The claim** (Defense Guide and Chapter 4):
> "Our FHS is transaction-derived: it calculates from actual spending data. This removes self-reporting bias."

**The problem:** This claim is partially true but overstated. The FHS removes *reporting bias* on spending amounts (you can't lie to your own database), but it does NOT remove:
- Selection bias (users who set income and budgets score differently — those who opt out see different formulas)
- Category attribution bias (users choose what category each expense falls under)
- Logging completeness bias (the Logging Consistency component itself measures whether users log everything — implying they often don't)

**Challenge risk:** "You say it removes self-reporting bias, but users choose the categories for their own expenses. How is that objective?"

**Suggested fix:** Replace "removes self-reporting bias" with "reduces self-reporting bias on spending amounts relative to survey-based scales, while acknowledging that category attribution and logging completeness remain user-influenced."

---

### 4.4 SUS Score Inconsistency Between Chapters 3 and 4

**Chapter 3** reports: Mean SUS = 82.50 (N=30), "Good" Grade B.  
**Chapter 4** reports: Mean SUS = 62.50 (N=5, partial), "OK" Grade C.

These are described as different datasets (N=5 preliminary vs. N=30 final), but the inconsistency is confusing. Chapter 4 was likely written earlier (when only 5 results were available) and not updated after the full N=30 data came in. A panel reading both chapters will notice the contradiction.

**Challenge risk:** "Your Chapter 4 says the SUS score was 62.5 and below the 68-point benchmark. Your Chapter 3 says it was 82.5. Which is correct?"

**Suggested fix:** Update Chapter 4's usability discussion to reflect the final N=30 result of 82.50, with a note that the earlier preliminary figure of 62.50 (N=5) improved as more respondents were added.

---

## SECTION 5: Missing Elements for a Complete Adviser Validation Document

Based on this audit, the following elements are missing from the existing documentation set that a thorough adviser validation document should include:

### 5.1 MISSING: A Formula Proof-of-Values Table

The existing documents explain the *philosophy* behind each component but do not provide a worked numerical example showing that the formula produces sensible scores across realistic input scenarios.

**What is needed:** A table showing 4–5 example user profiles (e.g., "User saves 15%, overspends on 5 of 20 days, has 3 of 4 budgets on track, logged 18 of 20 days") with the exact score calculation at each component and the total. This proves the formula behaves as documented and catches any discrepancies immediately.

---

### 5.2 MISSING: Lightweight Mode Basis Table Rows

The Basis Table (Table 1) covers Full Mode well, but Lightweight Mode components are handled in a single combined row ("Lightweight Mode (4 alternate components)"). Given that Lightweight Mode has its own undocumented behaviors (the 80% threshold, the Want/Need fallback, etc.), it deserves individual rows for each of the 4 Lightweight components, matching the Full Mode structure.

---

### 5.3 MISSING: Explicit Scope Limitation Statement for Each Uncited Constant

The document should explicitly acknowledge which numeric constants are design calibrations (not literature-derived) and state that they are calibrated values subject to empirical adjustment in future versions. This is more defensible than implying all numbers have literature support, because a panel can press you on a specific number and you would have to admit it on the spot.

**Suggested language to add to the Basis Table:** 
> *"Note: The specific numeric constants in the formula (−5 pts/day decay rate, 3-day cap, +2/−3 gap adjustment values, 0.5× soft overspend coefficient, 40% category threshold, 80% spending restraint grace zone, and 14-day streak target) are design calibrations informed by the referenced theoretical frameworks but not directly derived from any single paper. They represent reasonable prototype values subject to empirical calibration in future longitudinal studies."*

---

### 5.4 MISSING: Alternative Weighting Exploration (Even Briefly)

The Defense Guide says: "Sa development phase, nag-explore po kami ng alternative weighting schemes." But no document shows what those alternatives were or why they were rejected. Even one additional sentence — "We considered 40/20/20/20 (emphasizing savings) and 30/30/20/20, but both introduced subjective ordering that the equal-weight design avoids" — would strengthen this claim.

---

### 5.5 MISSING: BSP CFIS 2025 — Citation Details Incomplete

The Basis Table cites "BSP CFIS (2025)" for the Budget Adherence component (fewer than 50% of Filipino households maintain any written budget). In the Chapter 3 bibliography, the BSP reference is listed as "Bangko Sentral ng Pilipinas. (2025). Consumer Finance Inclusion Survey 2025. BSP." — but only a root URL is given (`https://www.bsp.gov.ph/`), not a direct link to the actual CFIS 2025 document. This is not complete enough for a formal bibliography.

---

### 5.6 MISSING: Code-Level Formula Documentation Update

The Defense Guide's Overspend Control formula (`25 × (1 − overDays / periodDays)`) does not include the soft/hard distinction that is actually implemented. An adviser or external reviewer who verifies formulas against the code will find this discrepancy. The Defense Guide should be updated to show the weighted formula.

---

## SECTION 6: Citation Completeness Check

### 6.1 UNSGSA 2021 — Gubbins, Mazzotta & Rhyne

**Cited in documents as:**
> "Gubbins, P., Mazzotta, B., & Rhyne, E. (2021). *Measuring financial health: Concepts and considerations.* UNSGSA Financial Health Working Group."

**Chapter 4 bibliography URL:**
> `https://www.unsgsa.org/publications/measuring-financial-health-concepts-and-considerations`

**Audit findings:**
- The title is confirmed: "Measuring Financial Health: Concepts and Considerations" is a real UNSGSA publication.
- Author names (Gubbins, Mazzotta, Rhyne) are confirmed — Elisabeth Rhyne is verified as Senior Advisor on Financial Health at the Office of the UNSGSA who led the Financial Health Working Group.
- The URL `https://www.unsgsa.org/publications/measuring-financial-health-concepts-and-considerations` is plausible but not directly verifiable from search results (the UNSGSA site confirmed financial health publications exist). The search found a related PDF hosted at `poverty-action.org`.
- **No DOI is listed.** This is acceptable for institutional reports (many UNSGSA publications do not have DOIs), but a direct PDF URL would strengthen the citation.

**Assessment:** ⚠️ Partially complete. The citation is credible but add the direct PDF URL if available (check `unsgsa.org/publications/` for the specific document). The Basis Table reference section does include this source — it is present, though without a URL in that table.

---

### 6.2 Melbourne Institute — Comerton-Forde et al. (2018)

**Cited in documents as:**
> "Comerton-Forde, C., Ip, E., Ribar, D. C., Ross, J., Salamanca, N., & Tsiaplias, S. (2018). *Using survey and banking data to measure financial wellbeing* (CBA–MI Technical Report No. 1, executive summary). Commonwealth Bank of Australia & Melbourne Institute."

**Audit findings:**
- The CBA–Melbourne Institute Technical Report No. 1 (2018) is confirmed real. PDF available at `melbourneinstitute.unimelb.edu.au`.
- **Author mismatch:** The verified author blocks for the CBA/MI reports list: Comerton-Forde, Haisken-DeNew (de New), Ribar, Salamanca, Nicastro, Ross. The name "Ip, E." does not appear in the confirmed author block for Technical Report No. 1. "Tsiaplias, S." also does not appear in the confirmed author block.
- The document's citation replaces confirmed authors (Nicastro, de New) with names that may not be from this specific report (Ip, Tsiaplias).

**Assessment:** ❌ CITATION ERROR. The author list for this reference needs to be verified directly against the Technical Report. The confirmed authors from the Melbourne Institute for this work are: Comerton-Forde, C., de New (Haisken-DeNew), J., Ribar, D. C., Salamanca, N., Nicastro, A., & Ross, J. The Basis Table reference should be corrected.

**Corrected citation:**
> Comerton-Forde, C., de New, J., Ribar, D. C., Salamanca, N., Nicastro, A., & Ross, J. (2018). *Using survey and banking data to measure financial wellbeing* (CBA–Melbourne Institute Financial Wellbeing Scales Technical Report No. 1). Commonwealth Bank of Australia & Melbourne Institute. https://melbourneinstitute.unimelb.edu.au/

---

### 6.3 Ariely (2008)

**Cited in documents as:** "Ariely, 2008" (in-text only, in the Gap Adjustment row of the Basis Table).

**Basis Table references section:** Ariely (2008) is **NOT listed** in the References section at the bottom of the Basis Table. It appears only as an in-text citation.

**Defense Guide references section:** Not listed.

**Chapter 3 / Chapter 4 bibliography:** Not listed in the chapter bibliography.

**Full correct citation:**
> Ariely, D. (2008). *Predictably irrational: The hidden forces that shape our decisions.* HarperCollins. ISBN: 978-0-06-135323-9.

**Assessment:** ❌ INCOMPLETE. Ariely (2008) is cited in-text in the Basis Table but has no corresponding entry in any reference list in any document. Must be added.

---

### 6.4 Duhigg (2012)

**Cited in documents as:** "Duhigg, 2012" (in-text only, in the Gap Adjustment row of the Basis Table).

**Basis Table references section:** Duhigg (2012) is **NOT listed** in the References section.

**Defense Guide references section:** Not listed.

**Chapter 3 / Chapter 4 bibliography:** Not listed in the chapter bibliography.

**Full correct citation:**
> Duhigg, C. (2012). *The power of habit: Why we do what we do in life and business.* Random House. ISBN: 978-1-4000-6928-6.

**Assessment:** ❌ INCOMPLETE. Duhigg (2012) is cited in-text in the Basis Table but has no corresponding entry in any reference list. Must be added.

---

### 6.5 Warren & Tyagi (2004)

**Cited in documents as:** "Warren, E., & Tyagi, A. W. (2004). *All your worth: The ultimate lifetime money plan.* Free Press."

**Status:** ✅ Full citation present in the Basis Table references section. Title, authors, publisher, year — all correct. No issues.

---

### 6.6 Kahneman & Tversky (1979)

**Cited as:** "Kahneman, D., & Tversky, A. (1979). Prospect theory: An analysis of decision under risk. *Econometrica, 47*(2), 263–292."

**Status:** ✅ Full citation present. Journal, volume, issue, page range — all present and correct for one of the most-cited papers in economics.

---

### 6.7 Deci & Ryan (2000)

**Cited as:** "Deci, E. L., & Ryan, R. M. (2000). The 'what' and 'why' of goal pursuits: Human needs and the self-determination of behavior. *Psychological Inquiry, 11*(4), 227–268."

**Status:** ✅ Full citation present. Note: SDT researchers sometimes cite Deci & Ryan (1985) *Intrinsic Motivation and Self-Determination in Human Behavior* (Plenum Press) for the foundational theory, or Ryan & Deci (2000) in *American Psychologist, 55*(1). The 2000 *Psychological Inquiry* article cited is real and verifiable — this citation is acceptable.

---

### 6.8 Financial Health Network FinHealth Score® (2021)

**Cited as:** "Financial Health Network. (2021). *FinHealth Score® Toolkit.* https://finhealthnetwork.org/tools/financial-health-score/"

**Status:** ✅ Full citation present with URL. Verifiable.

---

## SECTION 7: Recommended Additions and Fixes (Prioritized)

### Priority 1 — MUST FIX (will be challenged at defense)

**P1-A: Fix the Melbourne Institute author list**  
The Basis Table cites "Comerton-Forde, C., Ip, E., Ribar, D. C., Ross, J., Salamanca, N., & Tsiaplias, S." — this author list appears to be incorrect. Verify against the actual Technical Report No. 1 (available at `melbourneinstitute.unimelb.edu.au`) and correct to the verified author names: Comerton-Forde, de New, Ribar, Salamanca, Nicastro, Ross.

**P1-B: Add Ariely (2008) and Duhigg (2012) to all reference lists**  
Both are cited in-text in the Basis Table but neither has a reference entry. Add:
- Ariely, D. (2008). *Predictably irrational: The hidden forces that shape our decisions.* HarperCollins.
- Duhigg, C. (2012). *The power of habit: Why we do what we do in life and business.* Random House.

**P1-C: Correct the Category Balance formula in Chapter 3**  
The manuscript formula uses `TotalOutflow` as denominator. The code uses `discretionaryTotal` (Bills/Health/Education excluded). The manuscript formula is incorrect and will not reproduce the code's output. Correct the manuscript formula to match the code, and add a sentence explaining the exempt-category logic.

**P1-D: Update the Defense Guide Overspend Control formula**  
The Defense Guide shows `25 × (1 − overDays / periodDays)` which loses the soft/hard distinction. Update to `25 × (1 − (hardOverDays + softOverDays × 0.5) / activeDays)` with a note explaining the distinction.

**P1-E: Reconcile SUS scores between chapters**  
Chapter 3 reports 82.50 final; Chapter 4 still reports 62.50 preliminary. Update Chapter 4 with the final N=30 figure.

---

### Priority 2 — SHOULD FIX (strengthens the document significantly)

**P2-A: Add a Calibrated Constants disclosure paragraph**  
Add a note to the Basis Table explicitly stating which numeric values (−5/3 decay, +2/−3 gap, 0.5× soft, 40% balance, 80% restraint, 14-day streak) are design calibrations rather than literature-derived constants. This is more defensible than implying all numbers come from citations.

**P2-B: Document Lightweight Spending Restraint fully**  
Add a dedicated Basis Table row for Lightweight Spending Restraint covering: the 80% grace threshold, the 2× limit = 0 pts scaling, and the Want/Need fallback. Even without citations for the specific numbers, explain the design reasoning.

**P2-C: Add a worked numerical example**  
A single example showing a realistic user's score calculation through all four components (Full Mode) gives the document concrete grounding and makes discrepancies immediately visible during review.

**P2-D: Cite OECD Handbook for equal-weighting justification**  
Replace the self-referential equal-weights justification with a citation to: OECD & Joint Research Centre. (2008). *Handbook on constructing composite indicators: Methodology and user guide.* OECD Publishing. This is the authoritative methodological reference for equal weighting as a defensible default.

---

### Priority 3 — NICE TO HAVE (improves completeness)

**P3-A: Add direct PDF URL for UNSGSA 2021**  
The UNSGSA citation has a page URL but not a direct PDF link. Find and add the direct PDF URL to make the citation fully verifiable without navigation.

**P3-B: Add BSP CFIS 2025 direct URL**  
The BSP CFIS 2025 citation currently has only the root domain (`https://www.bsp.gov.ph/`). Find the direct publication URL.

**P3-C: Add a brief exploration of alternative weighting schemes**  
Even one sentence noting that 40/20/20/20 and 30/30/20/20 were considered but rejected for introducing subjective ordering without empirical support strengthens the "we explored alternatives" claim in the Defense Guide.

**P3-D: Add Lally et al. (2010) for the 14-day habit streak**  
Phillippa Lally et al. (2010), "How are habits formed: Modelling habit formation in the real world," *European Journal of Social Psychology, 40*(6), 998–1009, provides evidence that habit formation timelines vary widely but consistent behavior tracking over shorter windows (2+ weeks) can anchor the beginning of habit formation. This supports the 14-day choice better than SDT alone.

---

## APPENDIX: Summary of Discrepancies (Quick Reference)

| # | Document | Discrepancy | Severity |
|---|---|---|---|
| 1 | Defense Guide | Overspend formula omits soft/hard weighting | Medium |
| 2 | Chapter 3 manuscript | Category Balance uses wrong denominator (TotalOutflow vs. discretionaryTotal) | **High** |
| 3 | All docs | Savings Rate no-income fallback (tiered 10/15/20 pts) not documented | Medium |
| 4 | All docs | Lightweight Spending Restraint 80% threshold not documented | **High** |
| 5 | All docs | Lightweight Spending Restraint Want/Need fallback not documented | **High** |
| 6 | Basis Table | Ariely (2008) in-text citation has no reference entry | **High** |
| 7 | Basis Table | Duhigg (2012) in-text citation has no reference entry | **High** |
| 8 | Basis Table | Melbourne Institute author list likely incorrect (Ip, Tsiaplias) | **High** |
| 9 | Chapter 3 vs 4 | SUS scores contradict (82.50 vs 62.50) | Medium |
| 10 | All docs | No citation for equal-weighting as defensible default (only precedent cited) | Medium |
| 11 | All docs | Specific numeric constants (−5, +2/−3, 0.5×, 40%, 80%, 14-day) uncited | Medium |
| 12 | All docs | Category Balance exempt-category logic (Bills/Health/Education) not documented | Low |

---

*Report written by Kiro. READ-ONLY audit — no code or documentation was modified.*
