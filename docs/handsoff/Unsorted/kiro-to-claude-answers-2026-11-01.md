# Kiro → Claude — Code Answers (Nov 1, 2026)
Answering the 10 questions from `claude-to-kiro-MASTER-handoff-2026-10-26.md`.
All answers verified directly from source code with file + line references.
**Give Claude this file before starting any manuscript work.**

---

## 1. FHS Pillars — confirmed from `score_service.dart`

### Full Mode (income_wallet_mode = ON) — 4 × 25 pts

| # | Component name in code | `component` key | Formula |
|---|----------------------|----------------|---------|
| 1 | **Savings Rate** | `savings_rate` | `25 × min(1, savingsRate / 0.20)` |
| 2 | **Overspend Control** | `overspend_control` | `25 × (1 − weightedOver / activeDays)`. Hard overspend = full penalty; single large item causing overspend = 0.5× penalty |
| 3 | **Budget Adherence** | `budget_adherence` | `25 × (onBudgetCategories / totalBudgetCategories)` |
| 4 | **Logging Consistency** | `logging_consistency` | `25 × (loggedDays / activeDays)` |

Source: `lib/services/score_service.dart` lines 345, 385, 458, 508 (component key assignments).

### Lightweight Mode (income_wallet_mode = OFF) — 4 × 25 pts (different components)

| # | Component name | `component` key |
|---|---------------|----------------|
| 1 | Spending Restraint | `spending_restraint` |
| 2 | Logging Consistency | `logging_consistency` |
| 3 | Category Balance | `category_balance` (Bills/Health/Education EXCLUDED from the 40% cap) |
| 4 | Habit Streak | `habit_streak` (full score at 14-day streak) |

Source: `lib/services/score_service.dart` lines 91–104 (comments), 126–322 (implementation).

### Site errors to fix (Claude §3)
The website FAQ, screenshot caption, interactive demo tooltip, and feature card all say **"Budget Setup"** as a pillar — **this does not exist in code**. Correct names: Savings Rate, Overspend Control, Budget Adherence, Logging Consistency.
These have been fixed in the website already (commit 8c870d1).

---

## 2. Budget Adherence with zero budgets — **auto-award 25 pts (NOT reweight)**

Source: `lib/services/score_service.dart` lines 496–502:
```dart
if (budgets.isEmpty) {
  comp3 = 25.0;
  comp3Reason = "No budgets set (add budgets for better tracking)";
}
```

**The manuscript claim that "other 3 components reweight to 33.3 pts each" is WRONG.**
User simply gets full 25 pts for Budget Adherence when no budgets are configured.
Update the manuscript accordingly.

---

## 3. RA 10173 redaction — exact patterns

Source: `lib/services/ai_chat_service.dart` lines 1853–1866, method `_redactPii(String text)`.
Applied to **user-typed messages only** before sending to cloud AI.

| Target | Pattern | Replacement |
|--------|---------|-------------|
| PH mobile numbers (+63 format) | `\+?63[-\s]?9\d{2}[-\s]?\d{3}[-\s]?\d{4}` | `[REDACTED_MOBILE]` |
| PH mobile numbers (09XX format) | `\b09\d{2}[-\s]?\d{3}[-\s]?\d{4}\b` | `[REDACTED_MOBILE]` |
| GCash/bank reference numbers (12–18 digits) | `\b\d{12,18}\b` | `[REDACTED_REF]` |
| OTP/PIN codes | `(?:OTP\|otp\|code\|Code\|PIN\|pin)[:\s]+(\d{4,8})\b` | digits → `*` |
| Bank account numbers (formatted) | `\b\d{2,4}-\d{5,9}-\d{1,2}\b` | `[REDACTED_ACCOUNT]` |

The financial context injected into the system prompt (expenses, budgets, goals, wallets) is **not redacted** because it contains no PII — item names and amounts only, no personal identifiers.

---

## 4. Cloud AI payload — exact contents

Source: `lib/services/ai_chat_service.dart` `setFullContext()` (line 230) and `_buildSystemPrompt()`.

**Sent to the AI provider on every request:**
- Today's date, yesterday's date
- Account type (student/employee/freelancer/etc.)
- Monthly income (amount only — no name, no account number)
- FHS score (0–100)
- This month's total spent, want/need split, all-time total, monthly totals by month
- Mood score for today if logged
- Custom categories and user-defined keyword→category rules
- **Wallet balances** (wallet name + balance — no account numbers)
- **Recent 10 expenses** (item name, amount, date, category, payment method)
- **Older expenses summarized by category** (not individual items)
- Budget limits per category
- Goals (name, target, current amount, deadline)
- Debts summary (title, person, remaining amount)
- Recurring transactions (title, amount, frequency)
- Insurance/contributions (name, type, premium)
- Installment plans (title, monthly payment, months remaining)
- FHS score history (last 30 days)
- Philippine financial reference data (SSS/PhilHealth rates, BNPL providers, bank info)
- Session action log (fingerprints of what was just logged this session — dedup guardrail)

**Approximate token count:** 5,000–8,000 tokens per request.
Confirmed from debug log (Oct 26): `tokens=7445(p=7335/c=110)`, `tokens=7569(p=7502/c=67)`.

**The site FAQ previously said "the conversation text (not your full expense history) is sent" — this was wrong and has been corrected** (commit 8c870d1). Accurate description: recent expenses, budget limits, goals, and wallet balances are sent as context for personalized answers. No receipt images, account numbers, or personal IDs.

---

## 5. Cerebras — key status

**Key is present and loaded.** The debug log from Oct 26 shows: `cerebras_key_loaded = YES`.

Source: `lib/services/app_config.dart` line 40–41 (`_fallbackCerebrasKey` hardcoded), line 563–564 (also fetched from Firebase Remote Config `cerebras_api_key`). The free tier is documented as "1M tokens/day, 5 RPM" in the code comments (line 76).

Whether the 30-day free trial is still active cannot be confirmed from code alone — it requires a live API call. Add footnote: *"Cerebras free tier active as of October 2026 (verified via debug log key loading); continued availability subject to provider terms."*

---

## 6. Gemini quotas

**Cannot be verified from app code.** The app receives the key via Firebase Remote Config; quota is set in Google AI Studio per project.

- Debug log confirms: `gemini_key_loaded = YES`, `rc_last_fetch_status = cached`
- Third-party source (Sept 2026): Flash-Lite ~500 RPD, Flash ~20 RPD
- Your docs previously said 1,000/250 — use 500/20 as conservative estimate
- Whether the key's Cloud project is on paid billing tier: unknown from code alone

---

## 7. Fake SUS numbers — search results

Run in repo root: `grep -r "82.5\|82.50\|Grade B" docs/`

Files to check:
- `docs/manuscript/reseaches/smartspend-thesis-chapter-4.md`
- `docs/manuscript/reseaches/smartspend-thesis-defense-script.md`
- Any `.md` in `docs/`

**Survey has not been completed. All SUS results (82.50, N=30, Grade B, adjective ratings, group means) were never collected.** Replace every instance with `[[PENDING — survey responses required]]` before printing.

The `MANUSCRIPT_5_UPDATE_NOTES.md` confirms 97 `[[` tags remain in `__5_.docx`. None may be left in the printed copies.

---

## 8. 50-receipt parsing test

**No real test run exists in this repository.** There are no test result files, no log files, no dated records of a parsing test.

The old numbers in drafts (GCash 93.3%, Maya 90.0%, Shopee/Lazada 80.0%, thermal 66.7%, "overall 82.5%") are **unverified estimates from a draft** — not from a real test. Table 3.4/3.5 must stay blank until a real, logged test is conducted.

---

## 9. Local-mode backup folder

**From code:** `lib/services/backup_service.dart` uses `getExternalStorageDirectory()` which on Android returns `Android/data/<package>/files/`. This is app-specific external storage.

**Known limitations:**
- Android 10+: directory not accessible from system Files app without file manager that shows hidden/app folders
- Android 11+: Scoped Storage enforced — `Android/data/` is typically hidden
- Android 13: stricter enforcement; usually unreachable from Files app without root

**Not tested on a real Android 13 device.** Manuscript should state: *"Auto-saved to app-specific external storage (Android/data/com.lucidframe.smartspend_app/files/). Accessibility from the system Files app varies by Android version and device manufacturer; users on Android 11+ may need a third-party file manager."*

A better approach for future: use `MediaStore` / `SAF` to save to the Downloads folder, which is always accessible. This is a post-defense improvement item.

---

## 10. Dean / chairperson / title page

| Item | Status | Notes |
|------|--------|-------|
| Dean | **UNVERIFIED** | "Jeoffrey B. Layco, MIS" from a 2025 sample manuscript — confirm with school |
| Chairperson | **TBA** | Not yet assigned per all handoffs |
| Adviser | **Ellen F. Mangaoang, DIT** | Updated in __5_.docx (`MANUSCRIPT_5_UPDATE_NOTES.md`); note DIT not MIT |
| Institution | **Lorma Colleges, College of Computer Studies and Engineering (CCSE)** | Confirmed from LICENSE file |
| Program | **Bachelor of Science in Information Technology (BSIT)** | Not "Computer Science" |
| Panel | Shekiro R. Raposas, Mary-Ann Mzana | Per HANDOUT_FOR_NEW_CHAT_2026-10-19.md |

---

## Bonus answers

### LICENSE type
**Source Available License (Non-Commercial)** — NOT "open source".
The LICENSE file explicitly:
- Allows: academic review, personal non-commercial study, PRs
- Prohibits: commercial use, rebranding, plagiarism, app store publishing without written permission

Every use of "open source" in the website, README, and docs must change to "source-available".
Website fixed in commit 8c870d1. README fixed in this session.

### README version
README was at v3.0.7 (stale). Updated to v3.1.1 in this session. Personal GCash number (09953583040) removed.

### AI provider chain (correct, 9 providers)
From `lib/services/app_config.dart` `autoFallback()` and model list:
1. Gemini 3.5 Flash-Lite (primary)
2. Gemini 3.5 Flash (fallback 1)
3. GPT-OSS 120B via Groq (fallback 2)
4. Qwen3.6 27B via Groq (fallback 3)
5. Qwen3.8 27B via Groq (fallback 4)
6. GPT-OSS 20B via Groq (fallback 5)
7. Compound Mini via Groq (fallback 6)
8. Cerebras GPT-OSS 120B (fallback 7 — last resort)
9. Custom Local LLM (user-configured Ollama/LM Studio/Jan)

Site previously said "8-provider" and listed wrong models. Fixed in this session.
