# Changelog

All notable changes to SmartSpend are documented here.

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
