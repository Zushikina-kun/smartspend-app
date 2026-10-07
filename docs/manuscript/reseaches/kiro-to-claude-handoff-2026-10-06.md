# Kiro → Claude Handoff — SmartSpend v2.9.96
**Date:** October 6, 2026
**Purpose:** Full sync of everything done since Claude's last session. Use this as the authoritative brief for all manuscript work going forward. The `docs/reference/CAPSTONE_REFERENCE.md` file in the repo is the single source of truth for all numbers — give it priority over older docs.

---

## 1. CURRENT APP STATE (v2.9.96)

| Metric | Correct Value | Notes |
|--------|--------------|-------|
| Version | **2.9.96** | pubspec.yaml + kAppVersion |
| Platform | Android (Flutter/Dart) | API 21–36 |
| Primary AI | **Gemini 3.5 Flash-Lite** | NOT 3.1 — migrated in v2.9.24 |
| AI providers | **9** | 8 cloud + 1 custom local (Ollama/LM Studio/Jan) |
| Agentic actions | **34** | was 31 in older docs |
| Badges | **25** | was 23 in older docs |
| Daily AI limit | **150** | was 60 in very old docs |
| Color themes | **11** | Blue, Sky Blue, Purple, Orange, Crimson, Deep Navy, Midnight Teal, Rose Pink, Charcoal, Slate, **Emerald** (new-install default since v2.9.76) |
| Screens | **43** | |
| Services | **31** | |
| SQLite schema | **v13, 25 tables** | see table list below |
| APK size | **~45 MB** | arm64-v8a, split, obfuscated |
| AAB size | **~75 MB** | Play Store bundle |
| Website | https://zushikina-kun.github.io/smartspend-app/ | |
| Privacy Policy | https://zushikina-kun.github.io/smartspend-app/privacy.html | |
| GitHub releases | https://github.com/Zushikina-kun/smartspend-app/releases | |
| BSP household financial access | **85%** | NOT 86% — confirmed 5 sources |

---

## 2. NUMBERS TO FIND-AND-REPLACE IN MANUSCRIPT

Every instance of these stale values must be updated:

| Find | Replace with |
|------|-------------|
| Gemini 3.1 Flash-Lite | **Gemini 3.5 Flash-Lite** |
| 31 agentic actions / 31 conversational actions | **34 agentic actions** |
| 23 badges / 23 habit achievement badges | **25 badges** |
| sqflite (v11) | **sqflite (v13)** |
| SQLite version 11 / v11 / 20 tables | **SQLite v13, 25 tables** |
| household access rose to 86% | **household access rose to 85%** |
| 10 color themes | **11 color themes** |

---

## 3. CONFIRMED CORRECT TECHNICAL FACTS (for manuscript)

### FHS Overspend Control formula — SOFT/HARD WEIGHTING IS REAL
Confirmed in `score_service.dart` lines 402–431:
```
Formula: 25 × (1 − (hardOverDays + softOverDays × 0.5) / activeDays)

Hard overspend: multiple items pushed daily total over budget → weight 1.0
Soft overspend: single large one-off item caused overspend,
                rest of day was within budget → weight 0.5
```
The CAPSTONE_REFERENCE.md had a simplified version (`25 × (1 − overDays/activeDays)`) — that was wrong. The full weighted formula above is the real one. Keep the Prospect Theory / Loss Aversion framing in the manuscript — it's correct.

### FHS Category Balance — Bills/Health/Education exemption IS REAL
Confirmed in score_service.dart: the Category Balance component in Lightweight Mode exempts Bills, Health, and Education categories from the concentration penalty. Only discretionary categories count toward the >40% threshold.

### SQLite 25 tables (complete list)
expenses, budgets, settings, savings_goals, income, recurring, debts, score_history, scan_history, installment_plans, custom_categories, category_rules, mood_log, **recurring_candidates**, conversation_summaries, wallets, user_profile, chat_history, installments, insurance_policies, **wallet_history**, **budget_history**, **goal_contribution_history**, **income_history**, **paluwagan**

The 25th table is `recurring_candidates` (auto-detected subscription patterns). v12 added wallet_history; v13 added budget_history, goal_contribution_history, income_history, and a `reason` column on score_history.

### Color themes — 11 confirmed
Enum values in theme_service.dart: blue, green, purple, orange, crimson, navy, teal, rose, charcoal, slate, emerald = **11 themes**. Emerald (`#00C896`) is Peso's signature color and new-install default since v2.9.76.

---

## 4. BIBLIOGRAPHY CORRECTIONS

### ✅ CBA-Melbourne Institute citation — CORRECTED
The old citation ("Measuring financial resilience") was wrong. Use this exact citation:
> Comerton-Forde, C., Ip, E., Ribar, D. C., Ross, J., Salamanca, N., & Tsiaplias, S. (2018). *Using survey and banking data to measure financial wellbeing* (Financial Wellbeing Scales Technical Report No. 1). Commonwealth Bank of Australia & Melbourne Institute.

### ✅ Kahneman & Tversky — ADD to bibliography
This was cited in-text for Warning Decay / Loss Aversion but missing from the reference list. Add:
> Kahneman, D., & Tversky, A. (1979). Prospect theory: An analysis of decision under risk. *Econometrica, 47*(2), 263–292.

### ❌ Sharma, Gaba & Sharma (2026) Atlantis Press — REMOVE
The DOI `10.2991/978-94-6463-IYC-2026_28` has literal text ("IYC-2026") where an ISBN should be — not a valid DOI pattern. Paper unverifiable across 3 independent search methods (direct title, author names, site:atlantis-press.com). Remove this citation entirely. Replace the gamification claim with:
- Bitrián, P., Buil, I., & Catalán, S. (2021). Gamification in sport apps. *European Journal of Management and Business Economics.*
- Wajid, F., et al. (2025). Gamification: Revolutionizing financial planning systems. *World Journal of Advanced Engineering Technology and Sciences.* https://www.wjaets.com/

---

## 5. CLAIMS TO REFRAME (per capstone-verification-report.md)

These must NOT appear as established facts — reframe as hypotheses or remove:

| Remove | Replace with |
|--------|-------------|
| "category-level budgeting reduces overspending by 32%" | "category-level budgeting provides cognitive boundaries that promote spending restraint" |
| "consistent logging reduces discretionary spending by 10–20%" | "frequent self-monitoring increases transaction salience, potentially reducing impulse spending" |
| "gamification boosts saving habits by 22%" | "gamified reinforcements encourage app engagement and logging consistency" |
| "consumers underestimate subscriptions by 2.5× and overpay $133/month" | remove — dollar-based, US market statistic, irrelevant to La Union |
| "first/only/unique" app | "novel integrated bundle of features optimized for Filipino users" |

---

## 6. NEW FEATURES ADDED SINCE CLAUDE'S LAST SESSION (v2.9.82 → v2.9.96)

Claude's docs likely reflect up to ~v2.9.81. Here's everything that was added:

### App-wide QoL (v2.9.82–v2.9.86)
- **Peso mascot** empty states on 10+ screens — `PesoMascot.withSpeech(mood:, text:)` Taglish messages
- **Delete confirmations** on every screen (budget, debt, income, recurring, goals, insurance, wallet, expenses, paluwagan)
- **Goal contribution button** on each savings goal card
- **Budget over-limit red border** on exceeded budget cards
- **Achievement unlock celebration** — amber SnackBar on first badge earn
- **Analytics interpretive labels** — "This month is 23% above your average" / savings rate vs 20% target
- **AI chat date dividers** — Today/Yesterday/date between message groups
- **Transaction filter persists** across navigation (SharedPreferences)
- **Home priority banner** — surfaces over-budget / wallet deficit alert at top
- **Chat history search** bar
- **Bank import "credits/income skipped"** count feedback

### AI improvements (v2.9.78–v2.9.81)
- AI timeout 20s → **35s**
- **Silent auto-fallback** on timeout — tries next provider before showing error
- **13 AI chat fixes**: Enter sends, maxLines 4, suggestion chips fill input (no auto-send), `_topSpendingCategory` excludes Others/Bills/Education, voice 600ms pause, confidence_score 0.65 for Others, model chip merged with remaining count, history → ⋮ menu, clear chat confirmation

### Full audit trail (v2.9.88–v2.9.89)
- `wallet_history` table — every balance change logged with old/new value, delta, reason, source
- `budget_history` — every setBudget/deleteBudget logged
- `goal_contribution_history` — every goal current_amount change logged
- `income_history` — every monthly income setting change logged
- `score_history.reason` — worst FHS component stored with each daily score
- **History viewers**: long-press budget card → history sheet; goal history icon; income AppBar icon
- **`HistorySheet`** — reusable widget at `lib/widgets/history_sheet.dart`

### Data Quality (v2.9.87)
- **Data Quality "View" button** now navigates to TransactionsScreen filtered to affected expenses
- **"Fix All"** for case_dup (merges name variants) and round_amount (delete with confirmation)
- **Installment & Plans** tool tile now opens directly to Plans tab (tab 2) in DebtScreen

### Re-audit fixes (v2.9.90–v2.9.91)
- Delete confirmations: paluwagan, insurance, wallet, single expense (transactions + home)
- Archive ≠ Delete: completed plan "Archive" no longer deletes — shows in Completed section
- **FHS score chart tooltip**: tap a dot to see date + score + "Lowest: X (N/25 pts)"
- **Peso empty states**: insurance, chat history, bill calendar
- **Wallet history from home**: long-press home wallet card → history sheet
- Source tags complete on all audit trail callers (manual/ai/salary_split/auto_deduct/income_allocation/undo)

### Local LLM private mode (v2.9.92)
- Settings → **Local AI** section: URL, model, key fields + Test Connection + Save
- **`LocalAiSetupSheet`** — step-by-step guide (Ollama/LM Studio/Jan tabs, hardware picker 8/16/32GB)
- `custom_local` as 9th provider in AppConfig — auto-falls back to cloud when server unreachable
- **🏠 Local AI chip** + green privacy banner in AI chat when active
- Ollama: port 7555 on MuMu Player; `OLLAMA_HOST=0.0.0.0:11434 ollama serve` for WiFi access

### Transaction date vs logged date (v2.9.93)
- Expense tile now shows "logged Oct 6" when `updated_at` date ≠ expense `date`
- **"Logged Today" filter chip** in Transactions — filters by `updated_at` not expense date
- **Clipboard Paste** auto-sends immediately (was silently filling input only)
- AI context expense rows include `[logged MM-DD]` for backdated entries
- AI system prompt rule 10 updated: AI now distinguishes "when spent" vs "when logged"

### Data bugs fixed (v2.9.94–v2.9.95)
- `_normalizeCategory`: ShopeePayLater, GLoan, HomeCredit, BillEase, Skyro, Akulaku, Maya Loan etc. → **Bills**
- `delete_by_logged_date` action: "DELETE items I logged today" → deletes by `updated_at`
- Note: plan payment duplicate guard was added then reverted — multiple catch-up payments on same date are intentional, not bugs

### AI context + PH lending (v2.9.96)
- `installment_plans` table now loaded into AI context (was loading wrong `installments` table)
- AI now knows about GLoan (4/9 months), ShopeePayLater (3/3 completed), monthly payments, due days
- **PH BNPL/loan knowledge** in system prompt: GLoan 1.59–6.99%/mo, Maya Loan 1.40%/mo, SPayLater, LazPayLater, HomeCredit, BillEase 0–12mo, Skyro 3.9%/mo, Akulaku, Atome, UnaCash, BSP Circular 1133 cap
- Context refresh debounce: 500ms → **200ms** (manual entries reflect faster)
- Debt Plans: **catch-up payment mode** — log multiple missed months atomically
- Savings goals: **deadline nudge** on goals with no deadline and <5% progress

---

## 7. AI STACK — VERIFIED WORKING (Oct 5–6, 2026)

From debug logs:
```
gemini_key_loaded = YES
rc_last_fetch_status = cached (fresh on first open each hour)
active_model_label = Auto · Gemini 3.5 Flash-Lite
model = auto (all requests hitting Gemini)
retries = 0 (no fallbacks needed)
actions = 4 (AI successfully executed 4 agentic actions on Oct 6)
latency = 1.4–2.7s (normal for Gemini Flash-Lite)
```

App Check debug token registered for MuMu Player: `1e2e702b-9243-4fff-9744-91011adf7d58`

---

## 8. DEPLOYMENT STATUS

| Channel | Status |
|---------|--------|
| GitHub Releases v2.9.96 | ✅ Live — APKs + AAB |
| GitHub Pages website | ✅ https://zushikina-kun.github.io/smartspend-app/ |
| Privacy Policy | ✅ https://zushikina-kun.github.io/smartspend-app/privacy.html |
| CI (APK + AAB on every tag) | ✅ Automated |
| APKPure | ⏳ Manual submission needed |
| Uptodown | ⏳ Manual submission needed |
| Google Play Store | ❌ Post-defense ($25 + 14-day testing) |

---

## 9. WHAT CLAUDE NEEDS TO FIX IN THE MANUSCRIPT

Based on the new research files (verification-report.md, editorial-checklist.md, chapter files):

### High priority (before defense)
1. **Version**: Update to 2.9.96 throughout
2. **Gemini 3.1 → 3.5 Flash-Lite** everywhere
3. **31 → 34 agentic actions** everywhere
4. **23 → 25 badges** everywhere (including IPO diagram)
5. **86% → 85%** BSP household access
6. **CBA citation**: replace with Comerton-Forde et al. (2018) — see §4 above
7. **Add Kahneman & Tversky (1979)** to bibliography
8. **Remove Sharma/Atlantis Press (2026)** citation — likely fabricated DOI
9. **Remove or reframe**: 32%, 10–20%, 22%, $133/month claims — see §5 above
10. **Overspend Control formula**: use `25 × (1 − (hardOverDays + softOverDays × 0.5) / activeDays)`
11. **SQLite v11/20 tables → v13/25 tables**

### Medium priority (before printing)
- Verify "first/only" exclusivity claims are softened to "novel integrated bundle"
- Confirm SUS 82.50 → "Grade B / Good" per Bangor (2009) — not custom adjectives
- Add Bills/Health/Education exemption note to Category Balance description
- NIST AI Risk Register table in Chapter II (hallucination controls, prompt injection)
- Data Privacy RA 10173 section: phone number regex redaction before API calls

### The editorial checklist file (`smartspend-final-editorial-checklist.md`) is the definitive pre-print checklist — give it to Claude as a task list for the final manuscript pass.

---

## 10. KEY FILE LOCATIONS

| File | Purpose |
|------|---------|
| `docs/reference/CAPSTONE_REFERENCE.md` | ✅ Updated to v2.9.96 — single source of truth |
| `docs/guides/DEFENSE_GUIDE.md` | ✅ Updated — key numbers, FHS formula with soft/hard |
| `docs/status/PROJECT_STATUS.md` | ✅ Updated — defense checklist, demo script |
| `docs/manuscript/reseaches/kiro-to-kiro-handoff-2026-10-05.md` | Full technical changelog v2.9.82–v2.9.96 |
| `docs/manuscript/reseaches/claude-to-kiro-sync-2026-10-06.md` | Claude's 9 issues → all resolved (see §3–4 above) |
| `docs/manuscript/reseaches/smartspend-final-editorial-checklist.md` | Pre-print submission checklist |
| `docs/manuscript/reseaches/smartspend-capstone-verification-report.md` | Academic claim audit |
| `docs/manuscript/reseaches/smartspend-thesis-chapter-1.md` | Has stale numbers — needs v2.9.96 update |
| `lib/services/score_service.dart` | FHS formulas — authoritative source |
| `lib/services/app_config.dart` | AI model routing, 9-provider chain |
| `lib/services/ai_chat_service.dart` | System prompt, PH lending knowledge, action parsing |
| `lib/widgets/history_sheet.dart` | Reusable audit trail viewer |
| `lib/widgets/local_ai_setup_sheet.dart` | Ollama/LM Studio/Jan setup guide |
| `index.html` | GitHub Pages landing page |
| `privacy.html` | Privacy Policy (RA 10173 compliant) |

---

## 11. DEMO PHONE SETUP (v2.9.96)

1. Download `SmartSpend-v2.9.96-arm64-v8a.apk` from GitHub Releases
2. Install → open → let load fully (Remote Config fetches Gemini key on first open)
3. Verify About screen shows **"Version 2.9.96"**
4. Settings → Quick Presets → **Normal or Pro** (Lite Mode OFF)
5. Settings → AI MODEL → **Auto (Recommended)**
6. AI screen → ⋮ → **Reset Daily Limit**
7. Charge to 100%, don't open until demo
