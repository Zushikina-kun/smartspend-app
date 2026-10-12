# SmartSpend — Remaining Tasks & Gaps
**Date:** October 12, 2026
**Status:** Planning — some items are being coded now, rest are task-listed

---

## Currently Being Coded (wf_c9fe22400d0c6077)
- FHS-reactive Peso mood on home screen (A-11 from mascot doc)
- Peso on Profile screen header (A-15)
- feedback_screen.dart lint fixes

---

## MASCOT — Remaining from A-series

### A-5: Peso reacts to FHS score CHANGE (not just current value)
When FHS changes between loads (score went up vs down), briefly show the appropriate mood.
- Score went UP from last known → `celebrating` for 2s, then back to score-based mood
- Score went DOWN → `sad` for 2s, then back to score-based mood
- Store previous score in SharedPreferences (`prev_fhs_score`) on each load, compare on next load
- **Files:** `home_screen.dart` — in the FHS calculation block
- **Estimate:** ~1h

### A-12: Peso reacts to budget status per-card
In the budget cards on home screen and analytics screen, show inline Peso with budget-appropriate mood:
- Budget ≤ 80% used → `happy` (tiny, 28px)
- Budget 80–100% → `worried` 
- Budget > 100% → `embarrassed` with bright blush
- **Files:** `home_screen.dart` budget card widget, `analytics_screen.dart` budget bars
- **Estimate:** ~1.5h

### A-13: Streak-aware Peso speech bubbles
- 7-day streak milestone → `excited` Peso + "Week Warrior! 🔥" speech bubble shown once
- 31-day streak → `celebrating` + "GRABE! Month Master!" shown once
- Streak broken after ≥3 days → `sad` + "Ay... nawala ang streak natin." shown once
- Store which milestones have been shown in SharedPreferences
- **Files:** `home_screen.dart` — in the streak display widget
- **Estimate:** ~1.5h

### A-6: Android notification icon (white silhouette PNG)
- Need a white-on-transparent PNG of Peso's coin face (circle + eyes + smile outline, all white)
- Size: 24dp × 24dp mdpi baseline, provide mdpi/hdpi/xhdpi/xxhdpi/xxxhdpi versions
- Once asset exists: change `AndroidInitializationSettings('@mipmap/ic_launcher')` to `('@drawable/ic_peso_notif')`
- **Files:** `notification_service.dart` (one line), plus PNG assets in `android/app/src/main/res/drawable*/`
- **Estimate:** ~30min code, ~1h graphic design
- **Blocker:** Needs a graphic asset first

---

## PESO LANGUAGE INTELLIGENCE

### Current state (already good)
Peso's system prompt already:
1. Auto-detects Filipino/Tagalog vs English from user's messages
2. Matches Taglish if user writes Taglish
3. Honors explicit language switch requests ("mag-Tagalog ka", "speak English")
4. Uses Filipino financial terms naturally (paluwagan, utang, bayad, gastos, ipon)

**This already works well — no code change needed for basic language following.**

### What's genuinely missing: User-settable language preference

**Task L-1: Add "Peso AI Language" preference to Settings**
A simple setting: "Peso AI Language" → Auto-detect (default) / Always English / Always Filipino
- Stored as `pref_peso_language` in SharedPreferences: `'auto'` / `'english'` / `'filipino'`
- When set to a specific language, inject it into the AI system prompt:
  - `'english'` → prepend "IMPORTANT: Always reply in English, regardless of what language the user writes in."
  - `'filipino'` → prepend "IMPORTANT: Always reply in Filipino/Tagalog, regardless of what language the user writes in. Use warm Taglish naturally."
  - `'auto'` → existing auto-detect behavior (no change to system prompt)
- **Files:** `settings_screen.dart` (UI), `ai_chat_service.dart` (read pref and inject)
- **Estimate:** ~1h

---

## PESO IS ALREADY CONNECTED TO LLM — but here's what's missing

### Current state (already exists)
Peso IS the LLM. When users chat with Peso in `ai_screen.dart`:
- `AIChatService.setFullContext()` injects their FULL financial data (expenses, budgets, goals, debts, wallets, income, FHS score) into every message
- Peso can answer questions about their data, log expenses, set budgets, update goals — 34 agentic actions
- This IS the LLM connection

### What's genuinely missing: Peso on OTHER screens talking to the LLM

Currently only `ai_screen.dart` sends messages to the LLM. The `PesoMascot.withSpeech()` widgets on other screens (empty states, celebrations) are **hardcoded Taglish strings** — they don't go through the AI.

**Task P-1: Contextual AI-powered Peso hints on screens (medium complexity)**
When Peso appears on empty state screens, instead of hardcoded text, optionally fetch a short contextual message from the AI:
- `savings_goals_screen.dart` empty state: ask AI "Give a 1-sentence Taglish encouragement for a user with no savings goals yet. Max 15 words."
- `achievements_screen.dart` empty state: similar short motivational message
- Cache the response so it doesn't re-fetch every time
- **Tradeoff:** Adds a small LLM call overhead. Worth doing for screens that matter most (savings goals, achievements).
- **Files:** `ai_chat_service.dart` (new `getShortContextualHint()` method), multiple screen files
- **Estimate:** ~2h

**Task P-2: Proactive Peso nudges from home screen (already partially exists)**
`BehavioralFeedbackService` already generates contextual messages. The home screen already shows AI insights. 
What's missing: having Peso *animate* (mood change) when these insights appear, not just static text.
- When `BehavioralFeedbackService.checkForCelebration()` returns a celebration → `PesoMood.celebrating`
- When it returns a warning → `PesoMood.worried`
- **Files:** `home_screen.dart` — find celebration/warning display and add mood
- **Estimate:** ~1h

---

## WEBSITE — Remaining Tasks

### Nav cleanup (minor)
The desktop nav has 14 links — starting to feel cramped. Consider grouping:
- Collapse Features/AI/Privacy/Screenshots into a "Product" dropdown on desktop
- Or just remove "Changelog" and "Team" from nav (keep in footer only)
- **Files:** `index.html` nav section
- **Estimate:** ~30min

### og:image social card
Current og:image points to `ic_launcher.png` (512×512 icon). For proper social sharing (Facebook, Twitter/X previews), should be a 1200×630 landscape image.
- Options: Use one of the screenshot images, or create a simple branded card
- **Files:** `index.html` meta tag, plus potentially a new image asset
- **Estimate:** ~1h (design) + 5min (code)

---

## APP — Other Gaps Found

### G-1: feedback_screen.dart uses hardcoded version "3.0.4"
Should read from `AppConfig.version` instead of being hardcoded. When version updates, it won't auto-update.
- Find `'**App version:** 3.0.4'` in `feedback_screen.dart`
- Replace with `'**App version:** ${AppConfig.version}'`
- **Files:** `feedback_screen.dart` — one line
- **Estimate:** 5 minutes

### G-2: Quick Tips screen tip #3 (screenshot import) may be outdated
The tip says "Tap Peso → 📷 camera icon → 'Batch Screenshots'". Verify this navigation path still matches the current UI (camera icon may have been renamed or moved).
- **Files:** `quick_tips_screen.dart` — verify tip text accuracy
- **Estimate:** 10 minutes check

### G-3: Peso mood `winking` used before it was confirmed in enum
The reactivity workflow used `PesoMood.winking` with a runtime check `PesoMood.values.contains(PesoMood.winking)`. Now that the enum definitely has it (12 moods confirmed), those `.contains()` checks can be simplified to direct `PesoMood.winking` usage.
- Not a bug (the contains() check handles both cases), but slightly verbose
- **Files:** `analytics_screen.dart`, `quick_tips_screen.dart`, `achievements_screen.dart`
- **Estimate:** 15 minutes cleanup

### G-4: `peso_mascot.dart` animation may cause issues on very small sizes
The idle bob (`translateY(-2px)`) at 20px size (used in AI bubble avatar) will be barely perceptible and might clip slightly. The animation should scale with size.
- Fix: multiply bob offset by `(size / 72.0)` so tiny instances bob proportionally
- **Files:** `peso_mascot.dart` — in the idle translation calculation
- **Estimate:** 5 minutes

### G-5: Missing `import 'dart:math'` in peso_mascot.dart for sin()
The animation uses `sin(idleT * pi)` — verify `import 'dart:math'` is at the top of the file.
- `flutter analyze` would catch this — check if it's already clean
- **Files:** `peso_mascot.dart` top imports
- **Estimate:** 2 minutes

---

## CAPSTONE / THESIS DOCS

### D-1: Update thesis Chapter 4 (Results) with new features
New features shipped that should be in the Results chapter:
- Peso mascot: 12 moods, animated (idle bob, eye blink, mood pop-in)
- In-app feedback screen
- Privacy disclosure on first AI chat
- Quick Tips screen
- Website: full feature set with interactive demo, animations
- **Files:** `docs/manuscript/reseaches/smartspend-thesis-chapter-4.md`
- **Estimate:** ~2h writing

### D-2: Update `smartspend-capstone-verification-report.md`
This report should list all implemented features against what was claimed in the thesis.
- **Files:** `docs/manuscript/reseaches/smartspend-capstone-verification-report.md`
- **Estimate:** ~1h

### D-3: Defense script update
The defense script (`smartspend-thesis-defense-script.md`) likely doesn't mention the latest features. Update the demo walkthrough section to include Peso reactions, feedback screen, website demo.
- **Files:** `docs/manuscript/reseaches/smartspend-thesis-defense-script.md`
- **Estimate:** ~1h

---

## SUMMARY TABLE

| Task | Priority | Effort | Status |
|------|----------|--------|--------|
| A-5: FHS score change → Peso mood | Medium | 1h | 📋 Task |
| A-12: Budget card Peso moods | Medium | 1.5h | 📋 Task |
| A-13: Streak milestone speech bubbles | Low | 1.5h | 📋 Task |
| A-6: Notification icon PNG | Low | 30min+design | 📋 Task (needs asset) |
| L-1: Language preference setting | Medium | 1h | 📋 Task |
| P-1: AI-powered contextual Peso hints | Medium | 2h | 📋 Task |
| P-2: BehavioralFeedback → Peso mood | Medium | 1h | 📋 Task |
| Nav cleanup (website) | Low | 30min | 📋 Task |
| og:image social card | Low | 1h | 📋 Task |
| G-1: Version hardcode fix | Low | 5min | **Do next** |
| G-2: Quick Tips tip #3 verify | Low | 10min | **Do next** |
| G-3: .contains() cleanup | Low | 15min | **Do next** |
| G-4: Bob scale with size | Low | 5min | **Do next** |
| G-5: dart:math import check | Low | 2min | **Do next** |
| D-1: Chapter 4 update | Medium | 2h | 📋 Task |
| D-2: Verification report update | Medium | 1h | 📋 Task |
| D-3: Defense script update | Medium | 1h | 📋 Task |

*Last updated: October 12, 2026*
