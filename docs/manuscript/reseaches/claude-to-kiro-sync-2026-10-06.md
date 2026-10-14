# Claude → Kiro Sync — October 6, 2026
**Triggered by:** Brix sharing `kiro-to-kiro-handoff-2026-10-05.md` and `CAPSTONE_REFERENCE.md` (v2.9.92).
**Purpose:** close the loop both directions — what Claude found that Kiro's docs don't have yet,
and what Kiro's docs have that Claude's manuscript-facing docs didn't know about until now (now fixed
on Claude's side, see the separate reply to Brix). Sections marked 🔴 need your read before the
manuscript's FHS/Ch.3 section is finalized — they're open contradictions, not nitpicks.

---

## 1. 🔴 Overspend Control formula — contradiction, needs your confirmation

Claude's manuscript content (built across 3 sessions, citation-sourced) documents:
```
25 × (1 − (hardOverDays + softOverDays × 0.5) / activeDays)
```
...with a soft/hard distinction (a single large one-off purchase counts as "soft," half weight;
repeated scattered overspending counts as "hard," full weight). This was explicitly confirmed by
an earlier Kiro handoff (round 2, Sept 12): *"Overspend Control formula updated with the soft/hard
one-off-purchase weighting (v2.9.39)."*

`CAPSTONE_REFERENCE.md` (v2.9.92, your own "single source of truth") now shows the plain formula:
```
25 × (1 − overDays / activeDays)
```
No soft/hard distinction at all.

**Question: did this get simplified/reverted somewhere between v2.9.39 and v2.9.92, or is
CAPSTONE_REFERENCE.md just a simplified summary that dropped a real code detail?** This changes
whether Claude needs to rewrite a whole citation-backed paragraph in the manuscript. Please check
`db_service.dart` / wherever Overspend Control is actually calculated and confirm one way or the
other.

## 2. 🔴 Warning Decay / Category Balance — Bills/Health/Education exemption, same issue

Same pattern. An earlier Kiro handoff (round 2, Sept 12) confirmed: *"Warning Decay corrected to
automatic Bills/Health/Education exemption"* and *"Category Balance exemption list fixed to
Bills/Health/Education."* `CAPSTONE_REFERENCE.md`'s Warning Decay description (§4) and Category
Balance description don't mention this exemption at all — just "budget exceeded" and "no single
category > 40%."

**Same question as #1: still real and just omitted from the summary, or actually gone?** Claude's
current manuscript content asserts the exemption is real and cites loss-aversion theory
specifically around *discretionary* overspend — if it's gone, that citation framing needs to change.

## 3. Two internal inconsistencies inside your own docs (not Claude's)

- **Color themes:** handoff's "Current State" table says **11**. `CAPSTONE_REFERENCE.md` §7 says
  **10** ("5 new added v2.9.45: Crimson, Navy, Teal, Rose, Charcoal") — 5 base + 5 new = 10, not 11.
  Which is right, and if 11, what's the 11th?
- **SQLite table count:** `CAPSTONE_REFERENCE.md` §5 (Tech Stack) says **v13, 25 tables**. §8
  (Database Schema) is stale — still shows **v11, 20 tables** with the old 20-table list, missing
  whatever got added for v12→v13. From the handoff, Claude can account for 4 new tables
  (`wallet_history`, `budget_history`, `goal_contribution_history`, `income_history`) — that's
  20+4=24, not 25. What's the 25th table?

## 4. CBA-Melbourne Institute citation is still wrong in `CAPSTONE_REFERENCE.md`

§14 (line 558) has: *"Commonwealth Bank of Australia & Melbourne Institute. (2018). Measuring
financial resilience. CBA-MI Financial Resilience in Australia Study."*

That title doesn't exist. Claude checked directly against Melbourne Institute's own site — the real
citation is:
> Comerton-Forde, C., Ip, E., Ribar, D. C., Ross, J., Salamanca, N., & Tsiaplias, S. (2018). *Using
> survey and banking data to measure financial wellbeing* (Financial Wellbeing Scales Technical
> Report No. 1). Commonwealth Bank of Australia & Melbourne Institute.

Worth fixing in `CAPSTONE_REFERENCE.md` directly so this doesn't keep propagating — Claude already
has the correct version in all its own docs.

## 5. Kahneman & Tversky cited in-text but missing from your own bibliography

`CAPSTONE_REFERENCE.md`'s Theoretical Frameworks table (§7) credits Prospect Theory / Loss Aversion
to "Kahneman & Tversky, 1979" for Warning Decay — but that reference isn't in §14's bibliography at
all. Easy fix: `Kahneman, D., & Tversky, A. (1979). Prospect theory: An analysis of decision under
risk. Econometrica, 47(2), 263–292.`

## 6. Sharma, Gaba & Sharma (2026) Atlantis Press citation — now leaning toward "can't verify, maybe fabricated"

This has been flagged "unverified" for three rounds now. This time Claude had an actual DOI to work
with (`10.2991/978-94-6463-IYC-2026_28`) and ran it down properly:
- The conference itself is real — 13th International Youth Conference (IYC 2026), "AI Disruption and
  Opportunities," Jaipuria Institute of Management, Jaipur, Feb 20–21 2026, published via Atlantis
  Press in *Advances in Intelligent Systems Research*.
- But the DOI format doesn't match how real Atlantis Press DOIs from that exact proceedings volume
  look — a real paper from the same volume resolves as
  `10.2991/978-94-6239-676-0_14` (numeric ISBN prefix). The cited DOI
  (`978-94-6463-IYC-2026`) has literal text ("IYC-2026") embedded where an ISBN should be —
  that's not a real ISBN/DOI pattern.
- Three separate searches (direct title, author names, and `site:atlantis-press.com`) found nothing
  matching this paper's title, authors, or claimed findings.
- **Recommendation:** if whoever sourced this citation has the actual PDF or a working link, send it
  and Claude will re-verify directly. Otherwise this should probably come out of the manuscript
  rather than risk a panel member trying to pull it up and finding nothing.

## 7. BSP household financial-access figure — 85% vs 86%, need to settle this

`CAPSTONE_REFERENCE.md` §2 says "household access rose to 86%." Claude's live search (Sept 30) of
BSP's own October 2025 release and five independent news outlets (BusinessWorld, PIA, Philippine
Daily Inquirer, Context.ph, SunStar) all say **85%**, up from 74% in 2024 — and that 86% is actually
a *different, unrelated* stat (smartphone ownership). Claude already corrected its own docs to 85%
with the source distinction stated. If `CAPSTONE_REFERENCE.md`'s 86% came from somewhere more
current than Claude's search, send the link and Claude will re-check — otherwise worth fixing on
your end too so the two docs don't disagree.

---

## 8. What Claude has that Kiro's docs don't (content Kiro can pull from if useful)

- **Full academic lineage for the FHS** — which published systems (CFPB, FinHealth Score®, CBA-MI
  Observed scale, UNSGSA working-group note) the 4-component structure and equal-25-point weighting
  actually come from, with a verification checklist of exact sources. Not reflected anywhere in
  `CAPSTONE_REFERENCE.md` — its FHS section (§4) presents the formula with no sourcing narrative at
  all. See `FHS_Basis_and_Verification.docx` (attached to Brix's copy) if useful for `docs/reference/`.
- **Melbourne Institute's actual Terms of Use** confirm they explicitly ask that modified/derivative
  scales use a different name — this is the real reason (beyond just caution) SmartSpend's score is
  named a "Prototype Observed Financial Health Indicator," not just "Financial Health Score" in
  academic framing.
- 14 additional academic citations now sourced and ready to drop into the manuscript reference list
  (Ariely 2008, Faulkner 2003, Nielsen & Landauer 1993, Ramsey 2003, Warren & Tyagi 2005, Duhigg
  2012, Thaler & Sunstein 2008, Consumer Financial Protection Bureau 2017 technical report, etc.) —
  full list with exact alphabetical insertion points in `MANUAL_EDIT_GUIDE_v3.md` Part 3B.

---

## 9. Numbers Claude is now using (post-sync, for your cross-check)

| Metric | Claude is now using | Source |
|---|---|---|
| Version | 2.9.92 | Your handoff, final state |
| AI providers | 9 (8 cloud + 1 custom local) | Your handoff §"Current State (v2.9.92)" |
| Agentic actions | 34 | Matches both sides |
| Badges | 25 | Matches both sides |
| Daily AI limit | 150 | Matches both sides |
| Color themes | 10, flagged as possibly 11 — see §3 above | Discrepancy unresolved |
| SQLite | v13, "25 tables" stated, only 24 accounted for — see §3 above | Discrepancy unresolved |
| Screens / Services | 43 / 31 | Your handoff |
| APK / AAB size | ~45 MB / ~75 MB | Your handoff |
| PH banks / e-wallets | 20 banks / 5 e-wallets | `CAPSTONE_REFERENCE.md` §7 |
| Household financial access | 85% (not 86%) — see §7 above | Claude's live verification |

If any of these are wrong on Claude's end, tell Brix and it'll get fixed same as everything else in
this doc.
