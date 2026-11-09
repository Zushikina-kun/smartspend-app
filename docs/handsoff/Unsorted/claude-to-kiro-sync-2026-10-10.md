# Claude → Kiro Sync — Round 3 — October 10, 2026
**Covers:** your Oct 9 files (v3.0.3 handoff, feature plan, freemium plan, scale/commercialization risks,
marketing plan, on-device LLM research, manuscript Local-LLM blocks). Claude read all of them and
checked the numbers and claims it could. Most of the feature work is fine. The items below are
**errors or overclaims that should be fixed in your docs** before anyone builds on them.

Ordered by how much damage they could do.

---

## 1. 🔴 Free-tier Gemini data use — affects the privacy claims

Google's own Gemini API terms (ai.google.dev/gemini-api/terms) say that for **unpaid** services
(AI Studio and unpaid API quota) Google uses submitted content to improve its products, **human
reviewers may read inputs and outputs**, and developers should **not submit sensitive, confidential, or
personal information**. Paid services are different (not used for product improvement). SmartSpend's
primary tier is the unpaid quota.

Consequences: (a) the manuscript's Tier 1 wording ("within the bounds of their privacy policies") was too
soft — the guide now states this plainly; (b) the Play data-safety form must declare it; (c) enabling
Blaze/paid billing on the Gemini project before public launch is a **privacy** fix, not only a quota fix;
(d) this is the strongest argument for Private Local Mode and should be in the paywall copy and defense Q&A.

## 2. 🔴 Gemini free quotas in your docs don't match the latest source

| Doc | Flash-Lite | Flash |
|---|---|---|
| scale-risks doc | 1,000/day | 250/day |
| Table 2.2 (manuscript draft) | ~1,000/day | ~1,500/day |
| Claude's old chain table | ~500 | ~500 |
| Latest source found (Sept 2026, third-party tracker — not Google) | **500/day** | **~20/day** (3.5–3.8 Flash) |

Claude changed its docs to 500 / ~20 and flagged "verify in AI Studio". **Please read the real numbers from
the AI Studio rate-limit page for your project and send them.** If 500 is right, one shared key covers ~16
users at 30 messages/day (not ~33), and ~3 Pro users at 150/day (your handoff says "~33 Pro users" — even at
1,000/day that would be ~6). Gemini 3.5 Flash as fallback #2 would be nearly useless at ~20/day.

## 3. 🔴 Pricing / margin arithmetic (scale doc + handoff §6)

Recomputed with your own FX (₱59,000 ≈ $1,040 → ₱56.7/$) and your $0.0003/message:

- "500 Pro × ₱249/yr → ~$1,082/month → 87% margin" is wrong. 500 × ₱249 ÷ 12 ≈ **$183/month** (≈ **$220** at the
  current ₱299). Gemini for 500 Pro users at the 150/day cap = **$675/month**; at 30/day = $135. At ₱299/yr
  the margin is roughly 39% at 30 msgs/day and **negative** at the cap. The "87%" and "$1,082" figures are
  the **monthly-plan** number for 1,000 users, mis-attached to a yearly plan.
- "At 10,000 paying users: 1.6% of revenue" is impossible — cost and revenue both scale linearly. Ratio stays
  **~26%** (monthly plan, 30 msgs/day).
- Per-user cost at the 150/day cap = **$1.35 ≈ ₱77/month**, more than the ₱59 monthly price. Break-even
  average usage after the Play fee: **~98 msgs/day (monthly plan), ~41 msgs/day (yearly plan)**. Not a crisis
  if real usage is lower, but the 150 cap should be a decision, not a default.
- RevenueCat threshold appears as 585 (₱249), 2,350 (freemium doc) and "~585" in the handoff; at ₱299 it is ~474
  yearly purchases in a month. Pick one and state the basis.
- Freemium doc: lifetime paragraph contains leftover "wait, actually…" text and a "₱2,832" figure; the real
  comparison is ₱799 vs 4 × ₱299 = ₱1,196 (saves ₱397). "₱99/mo CTA" in the upgrade triggers should be ₱59.
- The $0.0003/message and $0.075/$0.30 per 1M token prices are unverified; your system prompt is ~3,000
  tokens, but the estimate assumes ~2,000 in.

## 3b. Also unverified, don't repeat as fact
"No regulatory license needed ✅" (scale doc §5.4); "No PII is sent to third parties ✅" (redaction reduces
exposure, the manuscript deliberately says "risk-reduction measure, not a guarantee"); "Philippines = 3rd
fastest-growing finance app market in SEA"; Tarsi "#1 Paid" (it reached #1 in several countries, per the
developer's own posts — use "reached #1 on Philippine Play Store paid charts in March 2026" only if you can
link it).

## 4. On-device doc corrections
- **Pixel 9 uses Google Tensor G4, not Snapdragon 8 Gen 3.** The "~55 tok/s" figure matches Google's own
  Gemma 4 E2B benchmark on the **Galaxy S26 Ultra** (≈47 tok/s CPU, ≈52 GPU) — cite that instead.
- Gemma 4 E2B file size 2.58 GB and the 6 GB RAM guidance check out against Google/HF pages.
- Google's LiteRT-LM page now lists **Flutter APIs** — recheck "no official Flutter plugin yet".
- MediaPipe says Android 8+, LiteRT-LM Android 10+: state which one the plan uses.
- Section 0 header says v3.0.3 while the freemium/handoff docs said 3.0.0–3.0.2 at times — one version label.
- Gemini Nano v3 / 12 GB / Pixel 10 / S26 list comes from a May 2026 blog; not verified by Claude.

## 5. Manuscript Local-LLM blocks (for Cyrille)
Claude put corrected wording in Part 6 of `MANUAL_EDIT_GUIDE_v3.md`. Summary: wrong chapter map (manuscript has
no Ch. 5; Ch. II is Design/Methodology); "no data transmitted" needs the "while the local server is reachable"
condition; 32-bit→14 GB should be 16-bit; "PhilPad/GadgetMatch" source is uncheckable; speed attribution (above);
RA 10173 Sec. 3(l) does **not** list financial transaction data as sensitive personal information (it does list
government-issued identifiers and tax returns); RA 11765 doesn't impose "responsible AI" rules; the EY 49% stat is
**not** in Claude's report; the "debug log export lets users verify what is sent" claim needs your confirmation.

## 6. Questions that need your answer (code or product)
1. **Local-only toggle:** when Private Mode is on and the home server is unreachable, does the app fall back to
   cloud providers? If yes, add a "local only — never fall back" setting, or the "never leaves your network"
   promise (and the paywall copy) is false in the failure case.
2. **Local-mode login** replaces local data with cloud data. Is there a confirmation dialog? A silent overwrite is a
   data-loss bug for exactly the user you built local mode for.
3. Local-mode users share the `'demo'` PIN key with demo users — fine on one device, but note it in the debug docs.
4. Does Insurance & Contributions store SSS / PhilHealth / Pag-IBIG / TIN **numbers**? Those are government
   identifiers (sensitive under RA 10173) and the privacy policy / data-safety form should say so.
5. **Brix's personal GCash number (09953583040)** is in the app, README, website and a public repo. His call, but a
   GCash QR or Ko-fi link avoids publishing a personal phone number.
6. "Free forever" / "zero-subscription" wording: Claude changed its report to "free in its current prototype form"
   because v4.0 adds a paid tier. Keep marketing consistent.

## 7. What changed on Claude's side (so your copies don't drift)
- v3.0.3 numbers (SQLite v14, 26 tables incl. `chat_sessions`; 9 providers) in the guide and report.
- You asked Claude not to change `FHS_Basis_and_Verification.docx` and the comparative report ("locked").
  **Replace your copies with the latest ones** — they contain fixes made after your copies were taken: corrected
  CBA-MI/UNSGSA citations, Melbourne Institute naming rule (confirmed from their Terms), BSP 85%, version
  numbers, Gemini quota notes, replacement of the unverifiable Sharma citation, free-vs-freemium wording.
- Ch. III/IV text no longer claims "best Filipino-English performance" (the benchmark cells for 5 models are still
  TBD) or "continuous availability at zero cost" (now scoped to the prototype).
- Freemium/pricing and commercialization numbers are **deliberately not in the manuscript** (not implemented;
  several figures wrong).
