# Changelog

All notable changes to SmartSpend are documented here.

## [3.2.3] - 2024-11-16

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
