# SmartSpend — Project Status
**Version:** 2.9.11 | **Academic Year:** 2026–2027, 1st Semester
**Last Updated:** September 3, 2026
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
- [ ] **SUS survey** — conduct with 30 respondents (20 parents, 10 young professionals), tabulate results *(Djaunathan, Week 7)*
- [ ] **Chapter 3 actual data** — insert survey results frequency tables + SUS scores into `SMARTSPEND_REVISED_MANUSCRIPT.md` Chapter III after data collection *(Cyrille, Week 7)*
- [ ] **Figure 1.1 bar chart** — create bar chart of PH financial literacy rates (BSP 2021, Inquiro 2024) and insert in Google Docs *(Cyrille)*
- [ ] **Figure 1.2 IPO diagram** — create conceptual framework IPO diagram and insert in Google Docs *(Cyrille)*
- [ ] **Figure 2.1 SUS interpretation chart** — insert in Google Docs *(Cyrille)*
- [ ] **Figure 2.2 Kanban board diagram** — create and insert in Google Docs *(Cyrille)*
- [ ] **Validator signatures** — have both validators fill in credentials and sign the two Appendix A certificates *(Brix)*
- [ ] **Curriculum Vitae** — add CV section (Brix, Cyrille, Djaunathan) to Google Docs manuscript *(All)*
- [ ] **Confirm new Capstone adviser — ✅ Ellen F. Mangaoang, MIT (Adviser) / Shekiro R. Raposas (Instructor-in-Charge) *(All)*
- [ ] **Apply Google Docs manuscript fixes** — copy revised text from `SMARTSPEND_REVISED_MANUSCRIPT.md` into the Google Docs version (all Fixes 1–19 are already incorporated in the .md file) *(Cyrille)*

### ✅ Already completed (all Fixes 1–19 applied in SMARTSPEND_REVISED_MANUSCRIPT.md):
- [x] Fix 1/9 — "16 achievement badges" → "23 achievement badges"
- [x] Fix 2/8 — "version 8 format" → "version 9 format"
- [x] Fix 3 — API key not embedded, uses Firebase Remote Config
- [x] Fix 4 — Multi-wallet fully implemented (not future development)
- [x] Fix 5 — App lock cold-start only (like GCash/Maya)
- [x] Fix 6 — FHS section: dual-mode (Full + Lightweight) fully explained
- [x] Fix 7 — Table 1.2: 8-app comparison including BudgetPH, Alkansya AI, GCash Pera Coach, 18 features
- [x] Fix 10 — Input methods: Smart Import 6-mode system added
- [x] Fix 11 — Account types: flexible adaptive labels clarified
- [x] Fix 12 — Parents as PRIMARY target (Objectives + Population section)
- [x] Fix 13 — Respondent screening/inclusion criteria (4 bullets each group)
- [x] Fix 14 — Citation justifying 21–35 young professional age range (BSP 2021, PSA 2021)
- [x] Fix 15 (Part A) — Table 2.1: "Technical Validator (System & SUS Process)"
- [x] Fix 16 — Step-by-step 6-procedure data gathering section added
- [x] Fix 17 — Table 1.2: BudgetPH, Alkansya AI, GCash Pera Coach columns added
- [x] Fix 18 — Table 2.2: 15-model LLM comparison (expanded from 4)
- [x] Fix 19 — Credential-based optional-name validation certificates (Appendix A)

---

## WHAT IS DONE ✅

### v2.9.10 — September 3, 2026
- [x] **Behavioral Feedback Layer** — new `lib/services/behavioral_feedback_service.dart` (all 8 UX backlog items): plain-language FHS score narrative, proactive celebration SnackBars, contextual purchase commentary after AI logging, supportive budget alerts with goal-linked loss-aversion framing, FMS next-step guidance card, FHS/FMS coach report (strengths + improvements), streak milestone celebrations, tappable streak badge + Daily Quests InfoButton
- [x] **Docs full reorganization** — renamed all folders (Debug→debug, Screenshots→debug/screenshots, Image Converter→tools/image_converter), structured into reference/, guides/, status/, capstone/, manuscript/{output,progress_reports,builders,templates,archive}/, tools/, debug/
- [x] **Manuscript fixes** — primary/secondary population framing in abstract + Ch.III, validator scope expanded, 29→31 agentic actions (4 locations in builder), v2.9.7→v2.9.9 (3 locations)
- [x] **Progress reports Week 4 & 5** rebuilt with real app screenshots (6 + 8 images, accurate captions from visual inspection)
- [x] GitHub release v2.9.10 published (tag pushed, CI/CD triggered)

### v2.9.9 — August 27, 2026
- [x] **App Settings converted to dedicated full screen** (`settings_screen.dart`) — fully scrollable on all devices, no more bottom sheet cutoff
- [x] **All 19 toggles always visible and interactive** — no grayed-out restrictions, always tappable
- [x] **Lite Mode toggle** pinned at top under "QUICK PRESETS" heading — impossible to miss
- [x] **profile_screen.dart** — old 635-line `_showSettingsSheet` + `_settingsTile` removed; replaced with `Navigator.push` to new full screen
- [x] **whats_new_screen.dart** — fixed 2 malformed single-string tuples causing build failures; updated to v2.9.9 entry
- [x] **Full revised manuscript** — `docs/manuscript/SMARTSPEND_REVISED_MANUSCRIPT.md` (1,070 lines, 106KB): complete Chapters 1–4 + Abstract + References (50+ APA) + Appendices A–D; all 19 panel fixes applied; new 2025–2026 research data integrated; follows Lorma 4-chapter template exactly
- [x] **Docs audit** — all doc footers updated v2.9.2→v2.9.6; RESEARCH_BASIS Parts 12–13 added (GCash Pera Coach, EY 2026, Plaid 2026, PSA 2025, NielsenIQ 2026, Deloitte 2026, Spendception)
- [x] GitHub release v2.9.9 published with 3 APKs (arm64: 44.7MB, armeabi: 37.1MB, x86_64: 47.6MB)

### v2.9.6 — August 2026
- [x] **App Settings fully rebuilt** — DraggableScrollableSheet (85% initial height, draggable to full), fully scrollable, all 20+ tiles accessible
- [x] **Lite Mode one-tap toggle** — at the TOP of App Settings, turns off all 10 optional sections simultaneously
- [x] **No more grayed-out toggles** — Auto-deduct wallets and Balance mode always interactive (removed all `onChanged: null` restrictions)
- [x] **Docs sweep** — all 11 docs updated to v2.9.6 version stamps
- [x] **Research expansion** — RESEARCH_BASIS.md Parts 12 & 13 added: GCash Pera Coach competitor, EY 2026 AI consumer stats, Plaid Intelligent Finance 2026, PSA PDESA 2025, NielsenIQ 2026, Deloitte 2026 agentic AI, Spendception (Meyll et al. 2025), WJAETS 2025 gamification study, SWS March 2026 PH inclusion data, Bloomberg GCash 41.5M users
- [x] **BENCHMARK.md** — GCash Pera Coach added to extended comparison table; PART 6 Global AI Stats added; updated to v2.9.6
- [x] **CAPSTONE_REFERENCE.md** — v2.9.6 version history entry, Pera Coach Q&A added, competitor table expanded, references list expanded
- [x] **SYSTEM_OVERVIEW.md** — competitor table expanded with Pera Coach, new PH stats added
- [x] **DEFENSE_GUIDE.md** — Pera Coach Q&A added, key numbers table expanded with 2026 stats *(merged from DEFENSE_REVIEWER.md + DEMO_SCRIPT.md)*
- [x] **All doc footers** — updated from v2.9.2 → v2.9.6
- [x] GitHub release v2.9.6 published with 3 APKs (arm64: 44.7MB, armeabi: 37MB, x86_64: 47.6MB)

### v2.9.5 — August 2026
- [x] **New feature:** Weekly Category Card on home screen — shows each category's spend this week vs 4-week average, labeled High/Normal/Low with color coding and tooltips
- [x] **New feature:** Financial Management Score (0–100) on Profile screen — separate score measuring HOW WELL the user uses SmartSpend (logging, budget setup, goal tracking, data completeness)
- [x] **New feature:** FHS score trend — shows +/−X vs last month on the FHS card
- [x] **Enriched FHS breakdown dialog** — score classification label, top strength, top weakness, per-component Good/Fair/Needs Work labels, actionable tip per weak component
- [x] **Research expansion:** RESEARCH_BASIS.md Part 10 — 9 new sources (Financial Health Network 2026, Rateweb, Elenvo, MindsBudget, WalletHub, FinToolSuite, Khazneh, Foresight, PFScores)
- [x] **Score labels updated** to 5-tier: Excellent/Great/Good/Fair/Needs Work (was Good/Fair/Needs Attention)
- [x] **What's New screen** updated with v2.9.5 features
- [x] **Bug fix:** Gap dialog now triggers FHS score reload immediately after user answers (score was previously stale until next app event)
- [x] **Bug fix:** Subscription summary card and auto-detection prompt no longer both show simultaneously
- [x] **Bug fix:** Analytics FHS breakdown now shows the adjusted score (same as home screen, including decay/gap penalties)
- [x] **Bug fix:** Legacy daily limit card no longer appears alongside the new spending limit card
- [x] **Bug fix:** Lightweight FHS Spending Restraint now uses the correct period-specific spent amount (daily limit no longer compared to monthly expenses)
- [x] **Stale content fixed:** about_screen, ai_screen — Groq LLaMA 3.1 → Gemini 3.1 Flash-Lite, 25 actions → 31 actions, Backup v8 → v9, 2025-2026 → 2026-2027
- [x] **What's New updated:** v2.9.3/v2.9.4 features added to whats_new_screen
- [x] GitHub release v2.9.4 published
- [x] Per-section visibility toggles — 10 new toggles in App Settings under "Home Screen" and "Analytics" sections
- [x] Home: subscription summary, quick-log chips, badges row, mood check-in, cash flow forecast, behavioral prediction — all individually hideable
- [x] Analytics: DTI card, emergency fund calculator, milestones card, market insights — all individually hideable
- [x] All core sections always visible (spending summary, FHS score, pie chart, 50/30/20, wallets, budgets)
- [x] All toggles default ON — existing users unaffected
- [x] Full docs sweep to v2.9.3, RESEARCH_BASIS.md + APPLICATION_PIPELINE.md added
- [x] GitHub release v2.9.3 published
- [x] Version bump 2.9.1 → 2.9.2 across all source and docs
- [x] Full docs sweep — AY2026-2027, all dates, footers, academic year
- [x] Comprehensive App & LLM Benchmark (BENCHMARK.md) — 20+ apps, 19 LLMs, August 2026 data
- [x] System Overview doc for adviser/panel (SYSTEM_OVERVIEW.md)
- [x] Manuscript Fix Guide expanded to 19 fixes
- [x] Credential-based anonymous validator certificates (Appendix A) — applied in manuscript
- [x] Panel recommendations status tracked in PROGRESS_REPORT_WEEK1.md
- [x] Docs folder cleaned up — 6 overlapping files fused, all renamed to short ALL-CAPS names
- [x] GitHub release v2.9.2 published with 3 APKs
- [x] BENCHMARK.md expanded: Monarch 2026 updates, Sentimo, SweldoWise, Lista PH, Cleo, Era, EveryDollar, Honeydue, Empower; LLaMA 4 Scout, Grok 4.6, DeepSeek V4, Qwen3, Gemini 3.7 Flash added
- [x] DEFENSE_GUIDE.md (was DEFENSE_REVIEWER.md): BudgetPH Q&A, paluwagan gap Q&A, validator Q&A added
- [x] DEFENSE_GUIDE.md (was DEMO_SCRIPT.md): Smart Import PART 2 rewritten, badge count fixed 16→23, Q&A expanded
- [x] MANUSCRIPT_GUIDE.md (was MANUSCRIPT_FIXES.md): Fix-15 contradiction with Fix-19 resolved
- [x] Fix-15 vs Fix-19 contradiction resolved — credential-based approach confirmed final
- [x] All version stamps correct (DOCUMENTATION.md, HOWTORUN.md, CAPSTONE_REFERENCE.md version history)

### v2.9.1 — July–August 2026
- [x] Multi-model LLM: Gemini 3.1 Flash-Lite primary + 4 fallbacks (Gemini 3.5, Groq 70B, Groq 8B, Cerebras)
- [x] 31 agentic AI actions (added: suggest_expense_cuts, simulate_what_if, create_debt_payment_plan, split_expense)
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
- [x] All 31 agentic AI actions
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
| "LLM should do something important and heavy" | ✅ Done | 31 agentic actions, salary split, FHS explanation, debt payoff, subscription detection |
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

| # | Issue | File | Status |
|---|-------|------|--------|
| 1 | Google profile picture as default avatar | `login_screen.dart` `_syncAfterLogin()` | ✅ Already implemented — saves `user.photoURL` if no local photo set |
| 2 | `insurance_screen.dart` line 476 | `insurance_screen.dart` | ✅ Already fixed — `initialValue` in place |
| 3 | `insurance_screen.dart` line 489 | `insurance_screen.dart` | ✅ Already fixed — `initialValue` in place |

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

### UX/Behavioral — Future Enhancement Backlog
*(Added Sep 2026 — **all 8 items implemented in v2.9.10** — `lib/services/behavioral_feedback_service.dart`)*

| # | Feature | Status |
|---|---------|--------|
| 1 | **Proactive praise & celebration** | ✅ Done — celebration SnackBar on score +5pts, streak milestones, all-budgets-on-track |
| 2 | **Plain-language score narrative** | ✅ Done — italic 1-2 sentence summary below FHS score on home screen |
| 3 | **Purchase commentary / real-time feedback** | ✅ Done — contextual SnackBar after AI expense logging (tone-coded) |
| 4 | **FHS/FMS "What did I do wrong/right?" breakdown** | ✅ Done — coach report in Analytics with strengths + improvements |
| 5 | **Smart encouragement on negative decisions** | ✅ Done — supportive per-category budget card with goal-linked framing |
| 6 | **Goal milestone celebrations** | ✅ Done (was already in savings_goals_screen.dart at 25/50/75/100%) |
| 7 | **"Here's what to do next" FMS guidance** | ✅ Done — next-step card below FMS in Analytics + Profile |
| 8 | **Contextual score explanations on every screen** | ✅ Done — InfoButton on Daily Quests; streak badge tappable with dialog |

### Blocked (external dependency)
| Feature | Reason |
|---------|--------|
| SQLite encryption | SQLCipher breaks current v11 schema — needs DB v12 migration |
| Profile photo cross-device | Firebase Storage requires Blaze paid plan |
| Agentic bill payment | Requires BSP payment processing license |
| Bank notification auto-parsing | Sensitive Android permission, Play policy risk |
| Offline AI | Local LLM needs 4–8GB RAM — not feasible on budget phones |

---

## DOCUMENT TOOLING BACKLOG
*(Added Sep 2026 — research needed before implementation)*

The main capstone manuscript (`SMARTSPEND_FINAL_V5.docx`, `SMARTSPEND_REVISED_MANUSCRIPT.md`, template PDFs) currently requires manual round-trips: edit in `.md`, rebuild via `build_final_docx.py`, check visually. This section lists tools and approaches to research and plan for faster, more reliable document work.

### Tools to Research & Evaluate

| # | Tool / Approach | What to Investigate | Priority |
|---|----------------|---------------------|----------|
| 1 | **MCP Filesystem + python-docx** | Whether setting up a filesystem MCP server + python-docx gives Kiro the ability to read, diff, and write `.docx` files directly without a build script round-trip | High |
| 2 | **Pandoc integration** | Pandoc can convert between `.md` ↔ `.docx` ↔ `.pdf` preserving styles. Research: can it apply Lorma template styles reliably? Can it be driven from the build script? | High |
| 3 | **PDF reading (pdfplumber / pymupdf)** | Research tools that can extract text + layout from the template PDFs so Kiro can read the actual formatting rules (margins, fonts, line spacing) from the files rather than inferring them | High |
| 4 | **Mammoth.js / docx2python** | Libraries for reading existing `.docx` files and comparing them to our output — useful for automated formatting audits against Lorma templates | Medium |
| 5 | **LibreOffice CLI headless** | `soffice --headless --convert-to pdf` can render `.docx` to `.pdf` for visual checking. Research: can this run on Windows in this environment and be piped into a diff tool? | Medium |
| 6 | **Google Docs API** | Research whether the Google Docs API can be used to push changes from our `.md` source directly into the Google Doc version (Cyrille's working copy) — avoiding the manual copy-paste workflow entirely | Medium |
| 7 | **Diff-based manuscript revision** | Instead of rebuilding the full DOCX every time, research a patch/diff approach: detect only changed sections in the `.md` and apply targeted `python-docx` mutations, preserving existing formatting | Medium |
| 8 | **APA citation validator** | Research Python libraries (e.g. `citeproc-py`, `pybtex`) that can validate APA formatting of all references in `SMARTSPEND_REVISED_MANUSCRIPT.md` automatically | Low |

### Research Questions to Answer Before Implementing

1. Can `build_final_docx.py` be extended to accept a diff/patch rather than full rebuild — reducing build time from ~30s to ~5s?
2. Can Pandoc produce output that passes visual inspection against the Lorma CCSE template (margins, header styles, TOC format)?
3. What is the best way to give Kiro persistent read access to `.docx` and `.pdf` files — MCP server, a helper script that extracts to `.txt`, or a dedicated tool?
4. Can the Google Docs API be authenticated via a service account for automated pushes, without requiring manual OAuth every session?
5. Is LibreOffice headless viable in the `C:\xampp` environment for automated PDF rendering and visual diff?

### Next Step
When ready: research items 1–3 first (highest leverage), then design a unified "doc pipeline" that can: read template → compare output → apply targeted fixes → export PDF for visual review — all triggerable from a single command.

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

*SmartSpend v2.9.11 — Lucid Frame*
*Lorma Colleges, CCSE, BSIT 4th Year — 2026–2027 (1st Semester)*
