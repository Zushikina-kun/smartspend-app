# Kiro → Kiro Handoff — App Improvements — October 12, 2026

**Session type:** Vibe
**Covers:** 4 app UX improvements implemented following the website overhaul session.
**Supersedes:** The "app improvements identified" section of `kiro-to-kiro-handoff-2026-10-12-website.md`

---

## What Was Built

### 1. Privacy Disclosure on First AI Chat (`ai_screen.dart`)

**Why:** The website now publicly states "your message goes to an AI provider." The app itself never informed users of this. Gap between website transparency and in-app disclosure.

**What was added:**
- `bool _privacyDisclaimerShown = false` state variable
- `_loadPrivacyDisclaimerState()` — reads `DBService.getSetting('ai_privacy_disclosed')` on screen open
- `_showPrivacyDisclaimer()` — bottom sheet shown before the first ever message sent:
  - Explains that message text + expense summary goes to AI provider
  - Names Local AI mode as the privacy-preserving alternative
  - "Got it" button persists the seen state
  - Does NOT block the message — shown first, proceeds after dismiss
- Called in `_sendMessage()` BEFORE the existing `_adviceDisclaimerShown` check
- Pref key: `'ai_privacy_disclosed'` (stored via `DBService.setSetting`)

**Design decision:** Made it a bottom sheet (not dialog) to match the app's existing UX pattern for non-blocking informational overlays. User taps "Got it" and the message sends. Not a gate — just a one-time heads-up.

---

### 2. Quick Tips Screen (`quick_tips_screen.dart` — new file)

**Why:** The website FAQ covers critical onboarding info (FHS, GCash import, Taglish, offline mode) but the app's onboarding doesn't. New users who install directly without visiting the website would miss this context.

**What was created:**
- New file: `lib/screens/quick_tips_screen.dart`
- Same `shouldShow()`/`markSeen()` pattern as `WhatsNewScreen`
- Pref key: `'quick_tips_seen_v1'`
- 4 tips:
  1. 💬 Talk to Peso in Taglish (with example: "nag-gastos ako ng 65 sa canteen")
  2. 🏆 What is the Financial Health Score? (4 pillars, tap for breakdown)
  3. 📷 Import GCash & Shopee screenshots (batch import walkthrough)
  4. 🔒 Works fully offline (core features, Peso needs internet unless Local AI)
- Shown as bottom sheet on first launch, after WhatsNew check
- "Got it — let's go!" button dismisses and marks seen

**Integration in `home_screen.dart`:**
- Import added
- `QuickTipsScreen.shouldShow()` checked in `initState()` startup sequence
- 800ms delay before showing (after WhatsNewScreen priority window)

---

### 3. Export & Backup in Quick Access Hub (`home_screen.dart`)

**Why:** Export to CSV and JSON backup exist but are buried in Profile → scroll down → find the section. Many users never find them.

**What was added:**
- New tile in `_QuickAccessHub` widget: "Export & Backup"
- Icon: `Icons.save_alt_rounded`, color: `Colors.brown`
- Subtitle: "CSV export · JSON backup · Restore"
- Navigation: goes to `ProfileScreen` (which has the full export/backup UI)
- Added after the existing Import (BankImportScreen) tile
- Also appears in hub search results

**Note for future:** A dedicated export/backup screen would be better UX than routing to Profile. Tracked as low-priority in this handoff.

---

### 4. Offline Banner Enhancement (`home_screen.dart`)

**Why:** The app tracked `_isOffline` and disabled Peso input, but users didn't know WHY or that core features still worked. The message "No internet — Peso unavailable" was alarming without context.

**What was changed:**
- Offline banner message updated to: "📴 Offline mode — all core features work. Peso AI and market data require internet."
- Banner is now tappable (InkWell) — shows a SnackBar explaining what's available offline vs what needs internet
- SnackBar message: "✅ Offline: Logging, budgets, analytics, goals, FHS\n❌ Needs internet: Peso AI chat, exchange rates"

---

## Research Context (for docs)

### On-device AI — what we committed to on the website
The website's Privacy-First AI section now publicly states SmartSpend is evaluating:
- **Gemma 3 1B/4B** (Google) — 30–40 tok/s on mid-range, multilingual
- **Phi-4 Mini** (Microsoft, 3.8B) — ~3GB at Q4, strong reasoning
- **Qwen 3 1.7B** — fast, compact, good at structured tasks

**Current state of on-device LLM on Android (October 2026):**
- Flagship phones (Snapdragon 8 Gen 5, Tensor G6): 45–60 TOPS NPU, 20–50 tok/s on 1B–4B models
- Runtime options: MediaPipe LLM Inference API (Google), llama.cpp Android, MLC-LLM
- **Blocker for financial apps:** accuracy on peso amounts, dates, categories must be ≥95% consistently — current 1B–3B models are ~85–90% on structured financial NLP
- **Not committed as a feature** — website correctly says "on the roadmap" and "waiting for stability"

For the manuscript/thesis: cite [aimagicx.com on-device AI 2026](https://aimagicx.com/blog/on-device-ai-models-local-llm-guide-2026) and [effloow.hashnode.dev LLMs on phone 2026](https://effloow.hashnode.dev/running-llms-on-phone-on-device-ai-developer-guide-2026) for the hardware specs claim.

---

## What Still Needs Doing (Not in This Session)

| Item | Priority | Notes |
|------|----------|-------|
| Dedicated Export/Backup screen | Low | Currently routes to Profile |
| On-device LLM implementation | Future | After model accuracy improves |
| Quick Tips content refresh for v4.0 | Future | Update pref key when content changes |
| Privacy disclosure for home screen quick-input bar | Low | Same AI call as ai_screen but no disclosure shown there |

---

## Commit
Committed as: `feat: privacy disclosure on AI chat, Quick Tips screen, export in Quick Access, offline banner`

---

*Compiled by Kiro — October 12, 2026*
