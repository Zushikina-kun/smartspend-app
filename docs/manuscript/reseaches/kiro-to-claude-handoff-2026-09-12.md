# SmartSpend — Kiro → Claude Handoff
**Compiled:** September 12, 2026
**Covers:** All code changes and doc updates from v2.9.38 through v2.9.42 that Claude does not have.
**Context:** The previous handoff (claude-to-kiro-handoff-2026-09-12.md) covered doc corrections up to v2.9.37. This document picks up from there.
**Purpose:** Give Claude the full accurate picture of the app so manuscript/docs updates are grounded in reality.

---

## Quick Summary

| Version | Date | What changed |
|---------|------|-------------|
| v2.9.38 | Sep 12 | AI pipeline fixes + cross-feature integration (major) |
| v2.9.39 | Sep 12 | Pre-defense polish: debug log fixes, data cleanup, FHS overspend nuance |
| v2.9.40 | Sep 12 | Debug log overhaul — comprehensive new sections |
| v2.9.41 | Sep 12 | Pre-defense final polish: About screen version, yearly date bug, docs, is_want rules |
| v2.9.42 | Sep 12 | FHS fairness fixes + RA 10173 PII redaction |

---

## 1. AI System — Changes from v2.9.38

### 1a. Language / persona fix
The AI was defaulting to Filipino even when the user wrote in English. The persona opening line was changed from "Filipino-English companion" (which the model treated as licence to default to Filipino) to "personal finance assistant". The language rule now says:

> **DEFAULT LANGUAGE IS ENGLISH.** Ambiguous words like 'hello', 'ok', 'yes', 'thanks', 'sige', 'oo' do NOT count as Filipino — stay in English. Only switch to Filipino if the user has clearly written multiple full sentences in it.

### 1b. Multi-item token budget
`_estimateMaxTokens()` was rewritten to use currency-aware amount counting (prefers ₱-prefixed numbers, falls back to numbers after commas/and/then, last resort total digit count). This avoids date numbers like "september 9" inflating the item count. Cap raised from 1,200 to **1,400 tokens** for large batches. Formula: `(500 + itemCount * 150).clamp(800, 1400)`.

### 1c. Model routing — multi-item no longer downgraded
`_detectTaskType()` now uses the same currency-aware amount counting as `_estimateMaxTokens()` (consistent). Multi-item expense messages (multiple amounts + connector words) are **no longer routed to `fast` tier** — they stay on the active model. `modelForTask('fast')` returns `_activeModelId` instead of hardcoded `groq_8b`.

### 1d. Action parser hardening
- Pre-processes response to strip triple-backtick code fences before the ACTION regex runs
- Normalises single-quoted JSON to double-quotes before `jsonDecode`
- Unclosed brace fallback now appends exactly `depth` closing braces (not just one)
- `set_budget` fallback now runs per-category (no longer aborts when any budget was already parsed)
- `wasCutOff` warning shown even when no ACTIONs were parsed (previously only shown when actions > 0)

### 1e. Duplicate guard fix
The cross-session duplicate guard was blocking same-day repeated purchases (two jeepney fares). Fixed: only blocks entries where `NOT (ai_generated = 1 AND updated_at >= 5 minutes ago)`. Same-day repeats by the AI are now allowed through; old imports and manual entries still block. Both guards now use `COALESCE(updated_at, '1970-01-01')` to handle pre-migration NULL rows.

### 1f. Time field validation
`customTime` from AI action params is now validated against `RegExp(r'^\d{1,2}:\d{2}(:\d{2})?$')` before being stored. Invalid strings like `"after brunch"` or `"morning"` fall back to current time silently.

### 1g. RA 10173 PII redaction (v2.9.42 — NEW)
Both `AIChatService.sendMessage()` and `LLMService.parseExpense()` now call `_redactPii()` before sending text to the cloud LLM. Strips:
- PH mobile numbers: `09XX-XXX-XXXX`, `+639XX-XXX-XXXX`
- GCash/bank reference numbers: 12–18 digit sequences
- Bank account patterns: `XX-XXXXX-X`
- Replaces with `[REDACTED_MOBILE]`, `[REDACTED_REF]`, `[REDACTED_ACCOUNT]`

This closes the RA 10173 Data Minimization gap. The manuscript can now accurately claim on-device PII redaction before cloud transmission.

---

## 2. Financial Health Score (FHS) — Changes

### 2a. Overspend Control nuance (v2.9.39)
The Overspend Control component no longer treats all overspend days equally. A day where a **single large one-off item** (gadget purchase, concert ticket) caused the total to exceed the daily budget now counts at **0.5 weight** instead of 1.0. Days with scattered multi-item overspending still count at full weight.

Formula:
```
weightedOver = hardOverDays + softOverDays * 0.5
overRatio = weightedOver / activeDays
comp2 = (1.0 - overRatio).clamp(0, 1) * 25
```

The reason string in the FHS breakdown now distinguishes: "4 of 8 logged days exceeded daily budget (3 one-off purchases — reduced penalty, 1 habitual)".

### 2b. Category Balance exempts essential categories (v2.9.42 — NEW)
Bills, Health, and Education are now **excluded from the 40% concentration penalty**. The check runs only against discretionary spending. A student whose tuition dominates their budget no longer loses points.

Before: compared all categories against total spend.
After: compares only non-Bills/non-Health/non-Education categories against discretionary-only total.

### 2c. Warning Decay skips essential overspend (v2.9.42 — NEW)
The −5 pts/day decay penalty now only fires when a **discretionary category** is over budget. If only Bills, Health, or Education budgets are exceeded (medical emergency, tuition, utility spike), decay is skipped entirely.

---

## 3. Cross-Feature Integration Fixes (v2.9.38)

These were genuine gaps where AI actions didn't properly update the rest of the app:

| Gap fixed | Detail |
|-----------|--------|
| DebtScreen auto-refresh | Now subscribes to `AppEvent.expenseChanged` — refreshes after AI `add_debt`/`update_debt` |
| SavingsGoalsScreen auto-refresh | Now subscribes to `AppEvent.goalChanged` |
| RecurringScreen auto-refresh | Now subscribes to `AppEvent.expenseChanged` |
| ProfileScreen FHS auto-refresh | Now subscribes to all 4 AppEvents with 600ms debounce — FHS score was stale after AI actions |
| Analytics `goalChanged` | Analytics and AI context now include `goalChanged` in their event subscriptions |
| `update_debt` undo | Now records `{id, prev_paid_amount, prev_due_date}` snapshot before writes; `undo_service.dart` handles the `update_debt` case |
| Chat error metadata | Error messages (auth fail, timeout, limit) now persisted to DB as `||ERR:{json}||text` prefix. On restore, the Retry/Switch Model/Log Manually buttons reappear correctly after app restart. `AIChatService.restoreHistory` strips the prefix before feeding to LLM context. |
| `_initMessageCounter` dead code | Removed identical if/else branches |
| Redundant `_detectTaskType` call | Observability trace now reuses the `taskType` variable computed earlier in `sendMessage()` |

---

## 4. Data Integrity — One-Time Cleanup (v2.9.39)

A one-time DB migration (`dup_cleanup_v2938`) runs on first launch:
- Deletes AI-chat-logged duplicate expenses where a screenshot-imported entry for the same (item_name, amount, date) already exists. Keeps the screenshot-imported one.
- Rounds fractional amounts in the `recurring` table via `ROUND(amount, 2)` SQL (fixes `₱68.538461...` display).

Migration is gated by `dup_cleanup_v2938 = 'true'` in settings — runs exactly once.

---

## 5. Debug Log — New Sections (v2.9.40)

The debug log (`Profile → Debug Log`) now exports these additional sections that didn't exist before:

| New section | What it shows |
|-------------|--------------|
| AI Model State | Active model ID/label, groq limit flag, request trace formatted per-line, last silent action fail, last ungrounded advice |
| User Profile | UID (masked to 8 chars), display name, email |
| Wallets | All wallets with balances + total liquid |
| Savings Goals | Added completion percentage |
| Recurring Candidates | Auto-detected subscription patterns including dismissed ones |
| Insurance & Contributions | All policies with next due dates |
| Paluwagan | Shown when present |
| Mood log | Note text now included per entry |
| Chat history | Decodes `||ERR:` prefix cleanly; marks auth-failed messages as `[ERROR]` |
| AI Conversation Summaries | Last 3 stored context summaries |
| System State (expanded) | All feature toggles, all migration flags including `dup_cleanup_v2938` |

The SUMMARY line at the end of the chat history section now reads the action count from `ai_request_trace` (authoritative) instead of counting stripped ACTION lines (which always gave 0).

Version number in debug log header now reads from `kAppVersion` constant — no longer hardcoded to `2.9.37`.

---

## 6. About Screen (v2.9.41)

`about_screen.dart` now imports `kAppVersion` from `debug_service.dart` and displays `"Version $kAppVersion"` instead of the hardcoded `"Version 2.9.37"`. Will always be correct going forward.

---

## 7. Yearly Recurring Date Bug Fixed (v2.9.41)

Two places had a fragile formula for calculating the next date of a yearly recurring item:
```dart
// OLD (fragile — uses month+1 trick):
final lastDay = DateTime(now2.year + 1, now2.month + 1, 0).day;
return DateTime(now2.year + 1, now2.month, now2.day.clamp(1, lastDay));

// NEW (clean — matches recurring_helper.dart):
return DateTime(now2.year + 1, now2.month, now2.day);
```
Fixed in both `ai_screen.dart` (AI `add_recurring` action) and `home_screen.dart` (inline recurring log chip).

---

## 8. AI is_want Rules Expanded (v2.9.41)

The `IMPORTANT is_want rules` in the AI system prompt now explicitly cover:
- Shopping category (gadgets, peripherals, accessories) → `is_want:true` unless user explicitly says "for work" or "for school"
- Named Filipino drink brands (Sting, Cobra, Tropicana, Gatorade, Nestea, Pepsi, Coke) → `is_want:true`

Previously these were ambiguous and the model sometimes classified peripherals (mechanical keyboard) and juice drinks as Need.

---

## 9. kAppVersion Constant + Backup Version

`debug_service.dart` now defines:
```dart
const kAppVersion = '2.9.42';
const _kDebugSha1 = '4D:1C:67:D4:78:7A:30:20:6D:5B:D5:97:6E:F6:EF:87:3D:91:12:E8';
```

`backup_service.dart` now uses `kAppVersion` for the `app_version` field in exported JSON backups instead of the hardcoded `'2.9.37'`.

`about_screen.dart` imports and displays `kAppVersion`.

---

## 10. Recurring Average Amount Display Fixed (v2.9.39)

`detectRecurringCandidates()` in `db_service.dart` now stores `avgAmount` rounded to 2 decimal places using `double.parse(avg.toStringAsFixed(2))`. The Home screen recurring candidate card uses `amt.roundToDouble()` for display. This fixes the `₱68.538461...` display in the recurring detection card.

---

## 11. Current Authoritative Numbers for Manuscript

These are the correct values as of v2.9.42. Replace any older values in the manuscript with these:

| Field | Value |
|-------|-------|
| Version | **2.9.42** |
| AI providers (fallback chain) | **8** |
| Primary AI model | **Gemini 3.5 Flash-Lite** (GA stable, migrated from 3.1 on Sep 10, 2026) |
| Fallback chain | Gemini 3.5 Flash → GPT-OSS 120B (Groq) → Qwen3.6 27B → Qwen3.8 27B → GPT-OSS 20B → Compound Mini → GPT-OSS 120B (Cerebras) |
| LLaMA models on Groq | **RETIRED** Feb–Aug 2026. llama-4-scout, llama-3.3-70b, llama-3.1-8b return 404 on this account. Do NOT include them in the fallback chain description. |
| Agentic actions | **34** |
| Achievement badges | **25** (23 original + No-Spend Day + No-Spend Streak) |
| Daily AI message limit | **150 messages/day** (raised from 60 in v2.9.25) |
| SQLite schema | v11, **20 tables** |
| Paluwagan | **✅ Implemented** (v2.9.35) — remove from Future Work section |
| FHS Category Balance | Now exempts Bills, Health, Education from 40% cap |
| FHS Overspend Control | One-off large purchases count at 0.5x penalty instead of 1.0x |
| FHS Warning Decay | Does NOT fire for Bills/Health/Education overspend |
| RA 10173 PII redaction | **✅ Implemented** — mobile numbers and reference numbers stripped before LLM |
| Capstone Adviser | **Ellen F. Mangaoang, MIT** (NOT Verzola — he was Capstone 1 only) |
| Panel members | Shekiro R. Raposas, Mary-Ann Mzana |
| Dean of CCSE | Jeoffrey B. Layco, MIS |
| Oral committee | Jopher F. Reyes, MIT + Gelo Ryann M. Carbonell |
| Build size | ~45 MB (arm64-v8a, split, obfuscated) |

---

## 12. Claims That Were Fixed in Manuscript (Already Done by Previous Claude Session)

These were corrected before this handoff — do NOT revert:
- FHS described as "Prototype Observed FHI" per CBA-MI (2018) + UNSGSA (2021) — NOT validated by CFPB scale
- "32% overspending reduction", "22% gamification boost", "$133/month subscriptions" — removed as commercial claims
- "first/only" exclusivity claims — softened to "novel integrated bundle"
- Gemini 3.1 Flash-Lite described as migrated due to 404s — not a Google shutdown (EOL is May 2027)
- Paluwagan listed as implemented (not future work)
- CFPB distinction: their scale is subjective psychometric; SmartSpend's FHS is objective transaction-derived

---

## 13. New Competitors Claude Should Know About

These were discovered in research during this session and are NOT in Claude's previous context:

| App | Package | Platform | Key strength | Key weakness |
|-----|---------|---------|-------------|-------------|
| **Agila: Finance Coach** | `com.janj.agila` | Android + iOS | Business profile (invoices, inventory, collections); Monthly Wrapped; import from Money Manager/Bluecoins; offline-first; no mandatory account | No Taglish AI; no FHS; no voice/OCR/barcode; no PH gov contributions |
| **PISO Budget Tracker** | `com.daleduque.spendy` | Android | 100% offline, no ads, no subscription, Filipino-made, payday cycle | No AI, no FHS, no gamification |
| **BunnyWise** | bunnywise.io | Android (launching) | PSE stocks + US stocks + UITFs + MP2 + gold + crypto in one offline-first PH dashboard | Still launching as of Sep 2026 |
| **Lista PH** | `com.listaPh` | Android | Weekly/monthly/bi-monthly budgets; credit score access via partner bureaus | No AI, no FHS |
| **Kibo** | `com.kibo.app` | Android | AI-suggested categories from text/receipt/banking alert; offline | Limited PH-specific context |
| **Rocket Money Rowan** | iOS/Android (US) | AI financial assistant via text messages; proactively cancels subscriptions, negotiates bills, sets savings rules | US-only via bank API |

---

## 14. FHS Manuscript Equations — Verified Against Code

These are the exact formulas as implemented in `score_service.dart`. Use these in the manuscript.

### Full Mode

**Savings Rate:**
$$S_{Savings} = 25 \times \min\left(1.0, \frac{\text{savingsRate}}{0.20}\right)$$
where `savingsRate = (income − totalSpent) / income`

**Overspend Control (updated in v2.9.39):**
$$S_{Overspend} = 25 \times \left(1.0 - \frac{hardOverDays + softOverDays \times 0.5}{activeDays}\right)$$
where `hardOverDays` = days with scattered multi-item overspend; `softOverDays` = days where one large item caused the overspend

**Budget Adherence:**
$$S_{Budget} = 25 \times \left(\frac{\text{onBudgetCategories}}{\text{totalBudgetedCategories}}\right)$$

**Logging Consistency:**
$$S_{Logging} = 25 \times \left(\frac{\text{loggedDays}}{\text{activeDays}}\right)$$

### Lightweight Mode

**Spending Restraint:**
$$S_{Restraint} = 25 \times \min\left(1.0, \frac{L_{Limit}}{\text{totalSpent}}\right)$$

**Category Balance (updated in v2.9.42 — excludes Bills/Health/Education):**
$$S_{Balance} = 25 \times \left(1.0 - \max\left(0.0, \frac{\text{topDiscretionaryCategory}}{\text{discretionaryTotal}} - 0.40\right) / 0.60\right)$$
clamped to [0, 25]

**Habit Streak:**
$$S_{Streak} = 25 \times \min\left(1.0, \frac{\text{consecutiveLoggedDays}}{14}\right)$$

### Score Adjustments

**Warning Decay (updated v2.9.42 — only discretionary categories):**
$$Decay = \min(15, 5 \times \text{decayDays})$$
Only increments when a non-Bills/non-Health/non-Education budget is exceeded.

**Gap Adjustment:**
- Confirmed unlogged spending: −3 pts/day (max −15)
- Confirmed no-spend days: +2 pts/day (max +10)

---

## 15. Open Items That Still Need Human Action

| Item | Owner | Status |
|------|-------|--------|
| LLM benchmark TBD cells | Brix | Need actual benchmarking run against Taglish corpus for GPT-OSS 20B, Qwen3.6, Qwen3.8, Compound, Compound Mini |
| Gemini 3.1 Flash-Lite 404 root cause | Brix | Check actual outgoing request logs — was it stale model alias or key issue? Affects how we describe it in manuscript |
| Figures 1.1, 1.2, 2.1, 2.2 | Cyrille | Not created yet — required for defense |
| Compliance Matrix | All | Not filled |
| SUS survey (30 respondents) | Djaunathan | Post-defense |
| Play Store closed testing (12 testers × 14 days) | Brix | Start Week 1 post-defense |
| Privacy policy hosted URL | Cyrille | Needed for Play Store submission |

---

*Compiled by Kiro (Kiro IDE) — September 12, 2026*
*This document covers code and doc changes from v2.9.38 through v2.9.42.*
*The receiving Claude instance should treat all information in this document as ground truth for the current app state.*
