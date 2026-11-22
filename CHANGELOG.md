# Changelog

All notable changes to SmartSpend are documented here.

## [3.5.3] - 2026-11-22

### Added
- **Firebase Analytics**: model usage, OCR scan, voice command, AI chat, and feature-entry events (no PII — model IDs and boolean success only).
- **OpenRouter rate-limit warning UX**: amber dismissible banner in AI chat when fewer than 100 daily requests remain; auto-reads `X-RateLimit-Remaining` header from every OpenRouter call.
- **Analyze CI workflow** (`.github/workflows/analyze.yml`): runs `flutter analyze --no-fatal-infos` on every push/PR to `master`.
- Stable APK asset names (`SmartSpend-latest-*.apk`) in release workflow and website download links — links now survive version bumps.

### Fixed
- **OCR model routing**: `BankImportScreen._parse()` and `BatchImageImportScreen` now wrap the LLM parse call with `OCRService.preferredModelForOcr()` / try-finally restore, ensuring vision-capable models are used for receipt and screenshot parsing.
- **Voice model routing**: `_startVoiceInput` in `ai_screen.dart` now wraps `await _send()` with `PesoVoiceService.preferredModelForVoice()` / try-finally restore, using the fastest available model for voice commands.
- **Cerebras excluded from fast pool**: `isFast` changed to `false` for `cerebras_120b` (5 RPM free-tier cap makes it unsuitable for voice latency).
- **SMS Auto-sync toggle hidden** behind `kDebugMode` until the SMS MethodChannel is implemented; Notification Access card likewise hidden.
- Website version badges updated: `v3.5.0`/`v3.5.1` → `v3.5.3` across hero meta, SUS stat, screenshots section, research findings title, and download version note.
- README model counts corrected: "20 AI Models" → 16; "16-model fallback chain" → 15; Cerebras `Fast` column ⚡ → —.

### Changed
- `_buildComingSoonSection` renamed to `_buildResearchFindingsSection`; call-site comment updated to `// Research Findings — SUS 61.83, N=30`.
- Score-history comment: "placeholder" → "empty state".

### Technical
- `firebase_analytics: ^11.3.0` added to `pubspec.yaml`.
- New services: `AnalyticsService`, `RateLimitService`.

## [3.5.2] - 2026-11-22

### Fixed
- Corrected OpenRouter model IDs — removed invalid `:free` suffixes that caused 404 errors.
- Continuous fallback chain walks all 15 models without stopping on the first failure.
- CI: split `APP_CONFIG_DART` secret into A+B parts to stay within GitHub secret size limits.

### Changed
- Website: alignment, background canvas, and version-badge layout fixes.
- Research section title centering corrected.

### Technical
- Version: 3.5.1+129 → 3.5.2+130.

## [3.5.1] - 2026-11-22

### Fixed
- Update cache now invalidates on version change (previously stale cache persisted across upgrades).
- Voice input uses a `Completer` to await the final speech result — fixes the empty-voice-result bug where the input text was sent before speech recognition finished.

### Technical
- Cache TTL: 6 hours.
- Version: 3.5.0+128 → 3.5.1+129.

## [3.5.0] - 2026-11-22

### Added
- Investment portfolio tracker with real-time PnL.
- Smart recurring expense detector.
- BIR quarterly tax reminders + Tax screen (income tax estimator, percentage tax calculator).
- Multi-currency support — 57 currencies.
- Price Intelligence Phase 2: price history charts, trend alerts, best-deal finder.
- Notification listener service + GCash/Maya SMS parsing.
- Authentic app theming + Peso SVG mascot.
- Savings streak and weekly challenges.
- Government receipt OCR detection.
- Net worth tracker.

### Technical
- Version: 3.4.0+127 → 3.5.0+128.

## [3.4.0] - 2026-11-21

### Added
- Cash Flow Forecasting (FEAT-001).
- Price Intelligence Phase 1 (FEAT-002).
- eGov contributions: SSS, PhilHealth, Pag-IBIG screens (FEAT-003/4/5).
- Bill payment reminders (FEAT-006).
- OFW remittance tracker (FEAT-007).
- Balikbayan box tracker (FEAT-008).
- Auto-categorization (FEAT-009).
- Transaction filters (FEAT-010).
- Debt payoff calculator (FEAT-011).
- Animated goal progress (FEAT-012).
- Spending insights dashboard (FEAT-013).
- CSV export (FEAT-014).
- Backup/restore JSON (FEAT-015).
- Spending heatmap.

### Technical
- `kAppVersion` → 3.4.0.
- Version: 3.3.9+126 → 3.4.0+127.

## [3.3.9] - 2026-11-21

### Added
- 7 individual OpenRouter free models added to the model list.
- OpenRouter HTTP headers (`HTTP-Referer`, `X-Title`) applied to all `or_*` model requests.
- Safe-to-Spend dashboard card.

### Fixed
- Model-selector scrolling issues resolved.

### Changed
- README: "16 AI models" → "18 AI models" (later corrected to 16 in v3.5.3).

### Technical
- Version: 3.3.8+125 → 3.3.9+126.

## [3.3.8] - 2026-11-20

### Fixed
- Global search rewritten: uses `textContent`, fires on `DOMContentLoaded`, deduplicates results.
- OpenRouter blocked from background AI tasks (budget analysis, nudges) to conserve free quota.
- Empty-key fallback: app no longer silently falls back to Groq when OpenRouter key is blank.
- 25 new reviewer Q&A entries added.

### Technical
- Version: 3.3.7+124 → 3.3.8+125.

## [3.3.7] - 2026-11-20

### Changed
- AI reliability overhaul: Gemini is tried first; OpenRouter moved to last in the fallback order.
- Reviewer HTML updated with 13-provider fallback chain.

### Technical
- Version: 3.3.6+123 → 3.3.7+124.

## [3.3.6] - 2026-11-19

### Added
- OpenRouter 5-model internal fallback chain (tries multiple models before giving up).

### Fixed
- Corrected OpenRouter model ID to `gemma-4-31b-it:free`.

### Technical
- Version: 3.3.5+122 → 3.3.6+123.

## [3.3.5] - 2026-11-19

### Fixed
- Critical null-content crash: app no longer crashes when the AI returns a null body.
- OpenRouter reviewer model changed to Gemma for better reliability.
- Defense time rescheduled to 11:00 AM in HTML.

### Technical
- Version: 3.3.4+121 → 3.3.5+122.

## [3.3.4] - 2026-11-19

### Changed
- Reviewer Q&A reordered — most important questions shown first.
- Core Essentials tab added: plain-language fundamentals for evaluators.
- Overstated uniqueness claims corrected; "first Filipino app" claim removed.
- Version Discrepancy block updated to reference v3.3.3.

### Technical
- Version: 3.3.3+120 → 3.3.4+121.

## [3.3.3] - 2026-11-18

### Fixed (Final Defense Audit)
- Reviewer HTML `<title>` tag updated from v3.3.0 to v3.3.3
- Reviewer Version Discrepancy section: 4× v3.3.1 → v3.3.3
- Reviewer auto-update Q&A: added panel tip for browser fallback on Android 7+
- README note updated from v3.3.1 → v3.3.3
- README Research section: "November 16" → "November 20"
- index.html Research Complete banner: "November 16" → "November 20"
- Duplicate `_spentInPeriod` assignment in `home_screen.dart` removed
- WhatsNew screen `_version` and `_prefKey` updated to 3.3.3

### Added
- CHANGELOG entries for v3.3.1 and v3.3.2 (were missing)

### Technical
- Version: 3.3.2+119 → 3.3.3+120

---

## [3.3.2] - 2026-11-17

### Added
- **In-app auto-update checker** — detects new GitHub releases automatically on startup (3-sec non-blocking delay)
- **Auto-download APK with progress bar** — downloads arm64-v8a APK directly to app cache using `dio` with real-time progress
- **Android package installer trigger** — launches installer after download; falls back to GitHub releases page on Android 7+ (file URI restriction)
- **Settings → Check for Updates tile** — shows current version + update status; force re-check button clears 24-hr cache
- **About screen version badge** — "✓ Up to date" or "🆕 Update available" next to version number
- **New permission:** `REQUEST_INSTALL_PACKAGES` in AndroidManifest
- **FileProvider** configured for APK sharing (`file_provider_paths.xml`)

### Fixed
- `WhatsNew` screen `_version` and `_prefKey` updated to 3.3.2
- Duplicate `_spentInPeriod` assignment in home screen removed (code smell)
- GCash example amounts in `llm_service.dart` clarified as illustrative, not user data

### Technical
- New: `lib/services/update_service.dart` (UpdateService, UpdateInfo, DownloadProgress)
- New: `android/app/src/main/res/xml/file_provider_paths.xml`
- Added: `dio: ^5.4.0` to pubspec.yaml
- Version: 3.3.1+118 → 3.3.2+119

---

## [3.3.1] - 2026-11-17

### Added
- **Quick Stats and streak badge moved to top of home screen** — now immediately visible after balance card without scrolling
- **Reviewer: Research Relevance block** — "Why Our Research Matters" highlighted panel with 7 reasons to pass
- **Reviewer: Version Discrepancy block** — 6 Q&A covering every version mismatch question (manuscript vs app)
- **Reviewer: global search bar** permanently visible above all tabs, searches all 4 tabs simultaneously

### Changed
- kAppVersion → 3.3.1
- Defense date updated to November 20 throughout reviewer

### Technical
- Version: 3.3.0+117 → 3.3.1+118

---

## [3.3.0] - 2026-11-17

### Added
- **Payday-cycle budget reset** (Recommendation 1) — Budgets reset on actual pay dates. Bi-monthly users (15th & 30th) get period start of 15th; all others keep 1st-of-month. Affects budget screen, FHS adherence, home alerts, add-expense bar.
  - New: `lib/services/budget_period_util.dart` — `budgetPeriodStart(now, incomeFreq)`
  - `score_service.dart` — FHS comp3 scoped to payday period; `incomeFrequency` threaded through all call sites
- **Quick Stats "This Month at a Glance" home card** — total spent, avg/day, top category, days logged
- **Expense logging streak badge** — 🔥 consecutive-day logging streak on home screen
- **Home screen section headers** — "YOUR FINANCES", "QUICK ACTIONS", "GOALS & TRACKING" between card groups

### Changed
- WhatsNew screen updated to v3.3.0 | kAppVersion → 3.3.0
- Version: 3.2.5+116 → 3.3.0+117 | `flutter analyze`: 0 errors

---

## [3.2.4] - 2026-11-16

### Fixed (Critical — Defense Day Hotfixes)
- **AI auto mode immediate fallback** — `autoFallback()` now switches provider on first failure instead of silently retrying 3×35s = 105s wasted
- **Firebase short cache on cold start** — `minimumFetchInterval` drops to 5 min on first open (was 1hr), so OpenRouter key loads immediately
- **Empty-key provider skip** — Auto mode now detects and skips providers with no key, jumping straight to next available (Groq always has hardcoded key)
- **OpenRouter HTTP headers** — Added required `HTTP-Referer` and `X-Title: SmartSpend` headers, fixing HTTP 400 errors from OpenRouter
- **Context preserved on fallback** — Confirmed `_history` is static and survives provider switches; chat context no longer lost on fallback
- **Same fixes applied to llm_service.dart** — OpenRouter headers and fallback logic consistent across both AI services
- **kAppVersion updated to 3.2.4** — Debug log now shows correct version
- **WhatsNew screen updated** — Shows OpenRouter, AI fallback fix, Gov Contributions as top features; new prefKey so existing users see update once

### Technical
- Modified: `lib/services/app_config.dart`, `lib/services/ai_chat_service.dart`, `lib/services/llm_service.dart`, `lib/services/debug_service.dart`, `lib/screens/whats_new_screen.dart`
- `flutter analyze` on all modified files: 0 errors
- Version bump from 3.2.3+114 to 3.2.4+115

---

## [3.2.3] - 2026-11-16

### Fixed
- **CRITICAL:** AI timeout fallback - When all 3 retries timeout, now properly triggers provider fallback instead of hard failure
- Improves resilience when OpenRouter/primary provider is slow or unreachable
- Ensures Auto mode falls back through all 10 providers even on network timeouts

### Technical
- Modified: `lib/services/ai_chat_service.dart` - Added autoFallback() call in timeout exception handler
- Fixes "All AI providers timed out" error when first provider is unresponsive

### Context
- Hotfix for Final Defense day - ensures AI always works even if OpenRouter is slow
- Version bump from 3.2.2+113 to 3.2.3+114

---

## [3.2.2] - 2024-11-16

### Added
- **OpenRouter AI Gateway Integration** — Multi-provider AI architecture
  - Access to 100+ AI models through unified OpenRouter gateway
  - Default model: `google/gemini-flash-1.5` (optimal balance for all features)
  - Auto mode now prioritizes OpenRouter for intelligent task-based routing
  - 10-provider fallback chain ensures 24/7 AI uptime
  - $100 API credit available (expires May 14, 2027)
  - New provider option in Settings → AI: "🌐 OpenRouter Gateway"

### Changed
- Auto mode routing updated to prioritize OpenRouter when available
- AI provider description: "Smart routing — OpenRouter for best balance"
- Version bump from 3.2.1+112 to 3.2.2+113

### Technical
- Modified: `lib/services/app_config.dart` (+160 lines)
- OpenRouter API key stored in Firebase Remote Config (not in code)
- Compatible with all existing AI features (chat, advice, expense logging)
- Uses OpenAI-compatible API format (Bearer token authentication)
- Automatic failover on rate limits/errors to backup providers

### Context
- Enhances AI reliability and resilience
- Multi-provider architecture for production readiness
- Defense-ready implementation (Final Defense: November 16, 2026 at 3:00 PM)

---

## [3.2.0] - 2024-11-15

### Added
- **Government Contributions Tracker** — Filipino-specific feature for tracking mandatory government contributions
  - SSS (Social Security System) contribution tracking with year-to-date totals
  - PhilHealth (Philippine Health Insurance) contribution tracking
  - Pag-IBIG (Home Development Mutual Fund) contribution tracking
  - Three new expense categories: SSS, PhilHealth, Pag-IBIG (auto-available in all expense logging flows)
  - Dashboard widget showing total government expenses YTD (auto-hides when no contributions logged)
  - Full-featured Government Contributions screen (448 lines) with year selector
  - Simple SSS pension estimator calculator
  - Direct portal links to official government websites (sss.gov.ph, philhealth.gov.ph, pagibigfund.gov.ph)
  - Integrated into Tools hub under Quick Access on Home screen

### Fixed
- AI model selector bottom sheet scrolling overflow on small screens (<5.5")
- Layout improvements for accessibility on compact displays

### Changed
- Version bump from 3.1.2+110 to 3.2.0+111

### Technical
- New screen: `lib/screens/gov_contributions_screen.dart` (448 lines)
- Modified: `lib/screens/home_screen.dart` (158 line addition), `lib/services/category_service.dart` (+3 categories)
- Code analysis: `flutter analyze` clean (info-level lints only)
- Build output: Release APK 119.8 MB
- Build type: ProGuard/R8 enabled, tree-shaking applied (MaterialIcons reduced 97.8%)

### Context
- Addresses thesis recommendation F11 (Filipino-specific financial features)
- Defense-ready build with accessibility improvements
- Post-defense release (defense date: November 16, 2026)

---

## [3.1.2] - November 2026
### UX Polish + Final Capstone Release
- **Peso home ring** — colored tier ring (green/orange/red) around Peso on Home screen FHS card
- **clearSnackBars** — prevents snackbar pile-up on app startup
- **Setup CTA** — nudge card for new users without income set up
- **Quick input bar** — emerald border, Peso 24px, updated hint text
- **Weekly notification fix** — corrected \/\ string interpolation
- **FHS tier change announcements** — Peso reacts when score crosses tier boundaries
- **Streak milestone celebrations** — 7/14/21/30-day logging streak milestones

## [3.1.1] - October 2026
### Peso Gestures + AI Transaction Save Fix
- **AI transaction save bug fixed** — actions=0 in debug log; extended actionTagRegex to accept bullet format
- **Peso double-tap** — surprised mood + random Taglish voice line
- **Peso long-press** — context-aware tip bottom sheet for current screen
- **Idle speech timer** — winking reaction after 8 seconds (throttled 1/hour)
- **Website factual corrections** — FHS pillars, license, GCash number removed

## [3.1.0] - October 2026
### Peso Behavior Update
- FHS tier change detection with Peso Taglish snackbar reactions
- Expense logging streak milestones (7/14/21/30-day celebrations)
- Notification tap reaction (SA-6) — deep link to relevant screen
- Session-gated AI tips (SA-3) — contextual tips per screen, once per session

## [3.0.x] - September–October 2026
### Peso Companion System
- Peso on 45 screens with 12 moods
- 36 achievement badges
- Daily quests system
- PesoVoiceService (31 contexts)
- Paluwagan tracker
- Insurance/SSS/PhilHealth/Pag-IBIG tracker
- PH Banks comparison guide
- App lock (PIN + biometric)
- Local AI mode (Ollama/LM Studio/Jan)
- In-app feedback

## [2.9.x] - August–September 2026
### Core Feature Development
- Batch screenshot import (40+ platforms)
- Financial Health Score (FHS) dual-mode
- Multi-provider AI chain (6+ providers)
- RA 10173 PII redaction
- Firebase sync + Remote Config
