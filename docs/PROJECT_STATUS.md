# SmartSpend — Project Status
**Version:** 2.9.2 | **Academic Year:** 2026–2027, 1st Semester
**Last Updated:** August 2026
**Group:** Lucid Frame — Brix A. Directo · Cyrille John M. Rubis · Djaunathan Albert S. Madayag

> For full technical documentation see `docs/CAPSTONE_REFERENCE.md`

---

## CAPSTONE 2 TIMELINE — REMAINING WORK

| Week | Activity | Our Tasks | Owner |
|------|----------|-----------|-------|
| **Week 1** *(done)* | Project Reorientation | Progress report submitted, consultation form filed | All |
| **Week 2** | Chapter 3 | Finalize Chapter 3 — LLM selection, FHS formula, system architecture | Cyrille + Brix |
| **Week 3** | Chapter 4 | Results & Discussion — screenshots, FHS results, feature walkthrough | Cyrille |
| **Week 4** | Final software check | Regression testing, bug fixes if needed | Brix |
| **Week 5** | Pre-Final Defense prep | Finalize presentation, rehearse demo | All |
| **Week 6** | Pre-Final Defense | Present to panel | All |
| **Week 7** | Testing & debugging | Address panel recommendations, run SUS survey | All |
| **Week 8–10** | Documentation | Complete manuscript Chapters 1–5, abstract, bibliography | Cyrille |
| **Week 11–13** | Final Defense | Present completed system + paper | All |
| **Week 15–17** | Revisions & submission | Revise based on panel feedback, final manuscript | All |

### Pending documentation tasks
- [ ] Complete Chapter 3 — FHS formula write-up, LLM architecture, database schema diagram
- [ ] Complete Chapter 4 — screenshots per feature, testing results table
- [ ] SUS survey — conduct with 30 respondents, tabulate results
- [ ] Chapter 5 — Conclusions & Recommendations
- [ ] Abstract, acknowledgements, bibliography (APA format)
- [ ] Appendices — survey instrument, source code snippets, user manual

---

## WHAT IS DONE ✅

### v2.9.2 — Latest (August 2026)
- [x] Version bump 2.9.1 → 2.9.2 across all source and docs
- [x] Full docs sweep — AY2026-2027, all dates, footers, academic year
- [x] Comprehensive App & LLM Benchmark (BENCHMARK.md) — 14 apps, 10 LLMs
- [x] System Overview doc for adviser/panel (SYSTEM_OVERVIEW.md)
- [x] Manuscript Fix Guide expanded to 19 fixes
- [x] Credential-based anonymous validator certificates (Appendix A)
- [x] Panel recommendations status tracked in progress report
- [x] GitHub release v2.9.2 published

### v2.9.1 — July–August 2026
- [x] Multi-model LLM: Gemini 3.1 Flash-Lite primary + 4 fallbacks (Gemini 3.5, Groq 70B, Groq 8B, Cerebras)
- [x] 29 agentic AI actions (added: suggest_expense_cuts, simulate_what_if, create_debt_payment_plan, split_expense)
- [x] Lightweight Mode — FHS without income/wallet tracking
- [x] Multi-period Spending Limits (daily/weekly/monthly/yearly independently)
- [x] Logging Gap Detection + FHS gap penalty/bonus
- [x] Batch Screenshot Import (40+ platform types, time extraction, dark image enhancement)
- [x] Unified Smart Import (live camera, single photo, batch screenshots, paste text)
- [x] Barcode detection from gallery images
- [x] FHS logging consistency scoped to current month
- [x] Historical transaction date-awareness (no false alerts for backdated entries)
- [x] App lock fixed for gallery/image picker
- [x] Security: google-services.json removed from git + SECURITY.md
- [x] GitHub release v2.9.1 published

### v2.8.0 — May–June 2026
- [x] Insurance & Contributions Tracker + Firestore sync
- [x] Startup Alerts (6 on-open conditions)
- [x] Wallet-first design (gradient card, smart daily allowance)
- [x] PH Banks Comparison Screen (4 tabs)
- [x] Round-up savings, price memory, smart daily allowance
- [x] 23 badges (was 16), 10 daily quests (was 6)
- [x] DTI ratio, Emergency Fund Calculator, PCA Calculator
- [x] Financial Health Certificate, Financial Glossary, BIR Tax Breakdown
- [x] Firebase Remote Config for API key (not in APK binary)
- [x] Backup v9 (includes insurance_policies)

### Core (Sessions 1–27, v1.0–v2.7.0)
- [x] All 29 agentic AI actions
- [x] AI chat (voice, OCR, barcode, manual, screenshots)
- [x] FHS 4-component formula + warning decay system
- [x] Budgets, savings goals, debt tracker, recurring transactions
- [x] Wallet balances (30+ PH banks, auto-deduct, transfers)
- [x] Analytics (10+ charts, 50/30/20, period comparison, heatmap, forecast)
- [x] Gamification (23 badges, 10 daily quests, streaks)
- [x] App lock (PIN + biometric, cold-start only)
- [x] Full Firestore sync with offline-first SQLite
- [x] Demo mode with realistic Filipino sample data
- [x] Help screen (32+ sections), About screen (75+ features)

---

## PANEL CRITICISM — ALL ADDRESSED ✅

| Panel Concern | Status | Evidence |
|---|---|---|
| "LLM should do something important and heavy" | ✅ Done | 29 agentic actions, salary split, FHS explanation, debt payoff, subscription detection |
| "Users can't modify dates" | ✅ Fixed | Date/time picker in Edit Expense + AI date changes |
| "LLM comparative analysis needed" | ✅ Done | BENCHMARK.md — 13 models, 6 criteria |
| "Insurance is a gap" | ✅ Done | Full Insurance Tracker + AI Q&A |
| "Income/allowance roles are confusing" | ✅ Improved | Lightweight Mode toggle, wallet-first design |
| "Make it general — remove rigid account types" | ✅ In paper | Manuscript Fix 11 — adaptive labels clarification |
| "Parents as primary population" | ✅ In paper | Manuscript Fix 12 — population reframing |
| "FHS bounded 0–100" | ✅ Done | Code + paper both confirm bounded |
| "Consequence for ignoring warnings" | ✅ Done | Warning Decay: −5pts/day |
| "Behavioral analysis" | ✅ Done | Mood tracking, impulse pause, velocity alerts |
| See `docs/PROGRESS_REPORT_WEEK1.md` for full 29-item status table | | |

---

## DEFENSE TESTING CHECKLIST (Before Pre-Final Defense)

**Lead: Djaunathan (QA) — on Poco X6 Pro, Android 16**

- [ ] FHS formula verification — check calculation matches paper formula
- [ ] Groq API failover — WiFi off → send AI message → verify friendly error + retry button
- [ ] Offline mode — WiFi off → add expense → WiFi on → verify sync
- [ ] AI chat end-to-end — "spent 30 pesos for jeepney" → verify logs as Transport
- [ ] Multi-model fallback — simulate rate limit → verify fallback to next model
- [ ] App Lock — cold start → verify biometric/PIN prompt shows once only
- [ ] Batch screenshot import — pick Steam + Shopee screenshots → verify extraction

---

## PENDING CODE ISSUES (Low priority — pre-defense if time allows)

| # | Issue | File | Fix |
|---|-------|------|-----|
| 1 | Google profile picture as default avatar | `login_screen.dart` `_syncAfterLogin()` | Check `user.photoURL` and save to profile if no photo set |
| 2 | `insurance_screen.dart` line 476 | `insurance_screen.dart` | Change `value:` → `initialValue:` in DropdownButtonFormField |
| 3 | `insurance_screen.dart` line 489 | `insurance_screen.dart` | Same fix — second DropdownButtonFormField |

---

## POST-CAPSTONE ROADMAP

### High priority (Summer 2026)
| Feature | Why | Effort |
|---------|-----|--------|
| Paluwagan tracker | Core Filipino behavior — BudgetPH has it, we don't | Medium |
| 15th & 30th payday cycle | Payday-aware budgeting reset | Medium |
| Backend API proxy | Move API key off device entirely | Medium |
| Play Store submission | After proxy + privacy policy | Low |

### Medium priority
| Feature | Why | Effort |
|---------|-----|--------|
| Business Mode (revenue, P&L, AI) | 99.5% of PH businesses are MSMEs | High |
| Couple/Family sharing | Parents managing household with spouse | Very High |
| PDF export (monthly summary) | Clean printable report | Medium |
| Spending heatmap (calendar intensity) | Visual pattern recognition | Medium |
| Market Insights (PSEi, fuel, CPI) | Needs external APIs | Medium |

### Blocked (external dependency)
| Feature | Reason |
|---------|--------|
| SQLite encryption | SQLCipher breaks current v11 schema — needs DB v12 migration |
| Profile photo cross-device | Firebase Storage requires Blaze paid plan |
| Agentic bill payment | Requires BSP payment processing license |
| Bank notification auto-parsing | Sensitive Android permission, Play policy risk |
| Offline AI | Local LLM needs 4–8GB RAM — not feasible on budget phones |

---

## KNOWN CONSTRAINTS (for defense Q&A)

| Constraint | Explanation | Mitigation |
|-----------|-------------|-----------|
| No bank sync | No open banking API in PH yet (BSP pilot July 2025) | Manual import + GCash/bank text paste |
| API key in APK | Free-tier key; Remote Config reduces exposure | 60 msg/day cap limits abuse |
| 60 AI messages/day | Shared free-tier API protection | Resets at midnight; Reset option in ⋮ menu |
| Offline AI unavailable | Groq requires internet | Manual entry works 100% offline |
| Profile photo local-only | Firebase Storage costs $$$ | Stored on device; sync post-capstone |
| SQLite not encrypted | SQLCipher risky migration | Data behind Firebase Auth + app lock PIN |

---

## CODING CONVENTIONS (for Brix)

- All DB writes fire `AppEvent` via `event_bus` for cross-screen refresh
- Theme colors: always `Theme.of(context).colorScheme.primary` — never hardcode hex
- Currency: always `CurrencyService.format()` and `CurrencyService.symbol`
- Amounts stored in PHP internally, converted for display only
- AI context injected before every message via `AIChatService.setFullContext()`
- Parallelized DB reads using `Future.wait` pattern
- Error handling: try-catch on all async, show SnackBar on error
- NEVER put `await` inside `setState()`
- Build command: `flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/debug-info`
- Test APK: `app-arm64-v8a-release.apk` (Poco X6 Pro)

---

## DB VERSION ROADMAP

| Version | Status | Contents |
|---------|--------|----------|
| v11 | ✅ Current (20 tables) | All features including wallets, installments, insurance, conversation summaries |
| v12 | Future | `account_id` on expenses — needed for multi-wallet system |

---

*SmartSpend v2.9.2 — Lucid Frame*
*Lorma Colleges, CCSE, BSIT 4th Year — 2026–2027 (1st Semester)*
