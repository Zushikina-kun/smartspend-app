# SmartSpend — Claude → Kiro Handoff
**Compiled:** September 12, 2026
**Covers:** Everything Claude verified, changed, or flagged in the manuscript across this session — from the first formatting pass through the full research-dossier revision.
**Purpose:** Keep the app and the manuscript from drifting apart. Sections marked 🔴 need a code check or code change. Sections marked 📄 are documentation-only — no app impact, included for a complete record.

---

## 1. 🔴 People / Credits — if the app has an About screen, credits, or splash mentioning the adviser

Confirmed directly by Brix against the official group-assignment sheet (not from any AI-generated research doc — two of the uploaded dossiers actually got this backwards and should be ignored on this point):

| Role | Name |
|---|---|
| Capstone Adviser | **Ellen F. Mangaoang, MIT** |
| Chairperson | **(To Be Announced)** — not yet assigned |
| Panel Member | Shekiro R. Raposas |
| Panel Member | Mary-Ann Mzana |
| Former Adviser (Capstone 1, no longer with the school) | ~~Johnny Flores Verzola~~ — remove from any current-facing credit |

**Check:** if `AboutScreen`, a splash credits list, or the Play Store listing anywhere names Verzola as adviser, update it.

---

## 2. 🔴 AI Provider / Model Stack — needs code confirmation

### 2a. The Gemini 3.1 Flash-Lite "shutdown" claim — likely a bug, not a real deprecation
Checked Google's own live deprecation page (`ai.google.dev/gemini-api/docs/deprecations`, last updated Sept 5, 2026): `gemini-3.1-flash-lite` is **not** scheduled to shut down until **May 7, 2027**. If the app was getting 404s on it, that's almost certainly something on our side — the most common cause elsewhere has been a model string silently resolving to the dead `gemini-3.1-flash-lite-preview` suffix instead of the GA name.

**Action for Kiro:** grep the actual outgoing request/error logs for the exact model string and status code before assuming Google killed it. Worth ruling out a stale alias, wrong API version path, or expired key before treating this as a hard provider loss.

Regardless of root cause, the manuscript now documents **`gemini-3.5-flash-lite`** as primary — this is Google's own official recommended migration target either way (GA since July 21, 2026), so the doc change holds even if the 404 turns out to be a bug.

### 2b. Groq LLaMA models — confirmed dead, not a bug
`meta-llama/llama-4-scout-17b-16e-instruct`, `llama-3.3-70b-versatile`, and `llama-3.1-8b-instant` are genuinely retired on Groq's free/dev tier (deprecation waves between March and August 2026, per Groq's own docs and changelog). This one really did happen.

**Confirmed current Groq lineup on your account:** `openai/gpt-oss-120b`, `openai/gpt-oss-20b`, `qwen/qwen3.6-27b`, `qwen/qwen3.8-27b`, `groq/compound`, `groq/compound-mini`.

### 2c. New 8-provider fallback chain — documented, order needs your confirmation
The manuscript now documents this chain:

1. Gemini 3.5 Flash-Lite (primary)
2. Gemini 3.5 Flash (fallback 1)
3. GPT-OSS 120B — Groq (fallback 2)
4. GPT-OSS 20B — Groq (fallback 3)
5. Qwen 3.6 27B — Groq (fallback 4)
6. Qwen 3.8 27B — Groq (fallback 5)
7. Groq Compound (fallback 6)
8. Groq Compound Mini (fallback 7)

**This ordering is Claude's best reconstruction, not confirmed against your actual fallback code.** `groq/compound` and `compound-mini` are Groq's own tool-using "agentic" models (built-in web search/code execution) — they may be better suited to a special-purpose role (e.g., the market-price-estimate feature, which already needs web search) rather than a plain linear fallback slot. **Kiro: check `AIProviderService` (or wherever the fallback chain is defined) and correct the order/roles if this doesn't match.**

### 2d. Empirical numbers marked TBD — need real benchmarking, not guesses
The manuscript's LLM comparison table has **Speed** and **Filipino-language accuracy** columns marked `TBD` for GPT-OSS 20B, Qwen 3.6/3.8 27B, and both Compound variants. Claude did not fabricate numbers for these — your existing Chapter 3 methodology says these come from your own benchmarking corpus, so they need to be actually run. Context windows and pricing tiers ARE filled in (sourced from Groq's docs).

### 2e. Version / limits sync
- Docs now reference **v2.9.35** everywhere (was 2.9.19/2.9.20 in older drafts). Confirm this matches the actual `pubspec.yaml` version and what ships for the defense demo.
- Daily AI request limit in docs is now **150** (was 60). Confirm the app's rate-limiter constant matches.

---

## 3. 🔴 Financial Health Score (FHS) formula — three real flaws fixed in the docs; code needs to match or the docs need to be walked back

These aren't cosmetic — they were genuine logical flaws in the *documented* formula that a panel would probe. Claude fixed the documentation. **Whether the app's actual Dart calculation logic already behaves this way is unknown to Claude — this needs Kiro to check.**

| Component | Old documented behavior | New documented behavior | Check in code |
|---|---|---|---|
| **Budget Adherence** (Full Mode) | No budgets configured → full 25/25 awarded automatically | No active budgets → component marked "Not Assessed"; the other three components (Savings Rate, Overspend Control, Logging Consistency) reweight to 33.3 pts each | Does the FHS calculator already skip-and-reweight, or still auto-award 25? |
| **Category Balance** (Lightweight Mode) | 40% single-category cap applied uniformly | Rent, Tuition, Utilities, and Medical are **excluded** from the 40% cap so legitimate fixed costs aren't penalized | Does the category-balance logic have a category exemption list? If not, needs one. |
| **Warning Decay** | −5 pts/day (max −15) whenever a budget warning is ignored, no exceptions | Decay is suspended when the overspend is tied to a user-flagged "verified emergency" category (e.g., Medical) | Does the app have any "this was an emergency" flag on an expense or budget breach? If not, this is a real feature gap — either build a minimal version (a tag/checkbox the decay logic checks) or tell Claude to soften the docs back to unconditional decay. |

**If any of these three don't match the app today, decide per-item: implement the fix in code, or tell Claude to revert that specific doc change so the manuscript describes what actually ships.** Don't leave it silently mismatched — that's exactly the disconnect you're trying to avoid.

---

## 4. 🔴 Privacy/security claims — confirm these exist in the app, not just in prose

Two corrections were documentation-only rewordings (no code needed):
- Firebase Remote Config is now described honestly as *not* a secure key-hiding mechanism (a decompiled APK can read it) — just a prototype-stage placeholder until a server-side proxy exists. No action needed unless marketing copy elsewhere (Play Store listing, in-app About text) still claims the key is "secure."

But one addition **asserts specific app behavior** that needs verifying against actual code:
- New Data Privacy Act (RA 10173) paragraph states the app does **on-device regex redaction of mobile numbers and e-wallet reference numbers before any receipt/screenshot text is sent to a cloud LLM**, has **separate consent toggles for local storage vs. cloud backup**, and **deletes cached receipt images immediately after a transaction is confirmed**.

**Kiro: confirm all three of these actually exist in the codebase.** If any of them don't (e.g., no regex redaction layer yet), that's a real docs/app mismatch that needs to be resolved one way or the other — either build the missing piece, or tell Claude which claim to walk back.

---

## 5. 📄 Bibliography / citation corrections (docs-only, no app impact)

- Fixed a real miscitation: the "N=30 finds most usability problems" claim was attached to the wrong Nielsen paper (a 2006 article about an unrelated UI pattern called "progressive disclosure"). Replaced with the correct **Nielsen & Landauer (1993)**, plus **Faulkner (2003)**, both now properly cited in-text.
- Removed an orphaned **Strivecloud (2026)** bibliography entry (a marketing blog, no longer cited in-text after the "22% gamification boost" claim was removed).
- Softened the **Ramsey (2003)** citation — kept as a note on popular practice, no longer implying peer-reviewed validation.
- Dropped **Mindfulsuite (2026)** (commercial blog) from the Logging Consistency citation.
- Added: National Privacy Commission (RA 10173), and put your previously-orphaned **BSP 2025 CFIS** reference to actual use in Chapter 1 (newer literacy/account-ownership trend data, doesn't replace the 2021 baseline).
- Added three more Philippine competitor apps to the competitive-landscape discussion (not the fixed comparison table): **Agila: Finance Coach, Lista, P1SO** — acknowledged as competitors Claude hasn't hands-on tested, framed to avoid an implied "we checked everyone" claim.

---

## 6. 📄 Formatting/structural fixes (docs-only, no app impact — background only)

Earlier in this session, before any of the research-dossier content: fixed a corrupted page-numbering section (was showing "page 26" on the actual cover page), replaced ~8 instances of manual blank-paragraph "spacers" with real page breaks (they were creating occasional genuine blank pages), added proper roman-numeral front matter (i, ii, iii...) separate from arabic body numbering starting at Chapter I. None of this touches app behavior — mentioned only so the full session history is in one place.

---

## 7. Open items — need a decision or a benchmark run, not more research

- [ ] Confirm the actual model-string bug behind the Gemini 3.1 Flash-Lite 404s (§2a) before the thesis asserts *why* it was swapped.
- [ ] Confirm/correct the 8-provider fallback order and roles (§2c) against real code.
- [ ] Run the actual benchmark corpus against GPT-OSS 20B, Qwen 3.6/3.8 27B, Compound, and Compound Mini to fill the `TBD` cells (§2d).
- [ ] Check all three FHS formula fixes against the calculator code (§3) — implement or revert per item.
- [ ] Check the three RA 10173 privacy claims against actual code (§4) — implement or revert per item.
- [ ] Reconcile: the manuscript's Recommendations/Future Work section still lists "Paluwagan tracker" as a future feature, but the changelog says it already shipped in v2.9.20–2.9.35. Move it to implemented features once confirmed.
