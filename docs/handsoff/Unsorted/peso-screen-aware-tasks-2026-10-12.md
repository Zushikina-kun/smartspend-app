# Peso Screen-Aware Companion — Task Planning
**Date:** October 12, 2026
**Status:** Partially implemented — this doc covers what's done and what's remaining

---

## What's Already Done (committed)

### Notifications (notification_service.dart)
All 20+ push notification titles/bodies now sound like Peso:
- Weekly: "Peso's Weekly Recap" / Taglish body
- Budget alerts: "Peso: [category] over budget!"
- Daily limit: "Peso: Daily limit exceeded/warning"
- Morning: "Magandang umaga! Peso here 👋"
- Recurring: "Peso reminder: [item] due"
- Debt: "Peso: Overdue payment..."
- FHS level up: "Peso: Score Level Up!" + "Galing mo!"
- Anomaly: "Peso noticed: High [cat] spend"

### Nav Button Tap Logic (home_screen.dart)
- **Single tap (idle)**: shows context-aware Peso tip → navigates to AI chat after 800ms
- **Single tap (bubble showing)**: dismisses bubble, stays on current screen
- **Single tap (already on AI)**: no-op
- **Double tap**: immediately goes to AI chat (celebrate haptic)
- `_pesoNavBubbleActive` tracks bubble state
- `_pesoScreenTips` map: 3 tips per tab index (0=Home, 1=Analytics, 3=Profile)
- `_showContextualPesoTip()`: picks random tip from current tab's list

---

## Remaining Tasks

### SA-1: Expand screen-aware tip map to all screens/features (HIGH)
Current `_pesoScreenTips` only covers tabs 0, 1, 3. Expand to cover:
- Tools screen (tab -1 / Quick Access Hub)
- When on Budget feature (navigated there from Quick Access)
- When on Savings Goals
- When on Debt screen
- When on Insurance
- When on Analytics specific sections (Trends vs Health vs AI Advice)

**Approach:** Since non-home screens don't share `_HomeScreenState._index`, the better pattern is a global `PesoContextService` that any screen can update:
```dart
class PesoContextService {
  static String? _currentScreen;
  static Map<String, dynamic>? _screenData; // budget %, goal %, etc.
  
  static void setScreen(String screen, {Map<String, dynamic>? data}) {
    _currentScreen = screen;
    _screenData = data;
  }
  
  static String? getContextualTip() {
    return _tips[_currentScreen]?[_randomIndex];
  }
  
  static const Map<String, List<String>> _tips = {
    'budget': ['Want me to explain your budget breakdown? 📊', ...],
    'goals': ['How are your savings goals going? Ask me! 🎯', ...],
    'debts': ['Need help tracking who owes what? I''ve got it! 💳', ...],
    // ... all screens
  };
}
```

**Call `PesoContextService.setScreen()` in each screen's initState.**

**Files:** Create `lib/services/peso_context_service.dart`, update all screens' `initState`

**Estimate:** ~2h

---

### SA-2: Live data in context tips (MEDIUM)
The context tips are currently static strings. Make them data-aware:
- On Budget screen: "Your Food budget is at X% — tap me if you want tips!"
- On Goals screen: "New Laptop is 34% funded — you need ₱7,753/month to hit the deadline"
- On Analytics: "Your top spending category this month is [X]"

**Approach:** Pass live data to `PesoContextService.setScreen()` and interpolate in tips.

**Files:** `peso_context_service.dart`, screen initState calls

**Estimate:** ~2h (after SA-1)

---

### SA-3: Peso talks on screen entry (MEDIUM)
When a user navigates to a screen for the first time IN A SESSION (not first ever — PesoScreenTip handles first ever), show a brief animated Peso tip after 2 seconds.

Different from PesoScreenTip which shows only once ever — this is a session-based tip that shows the first time you visit a screen per session.

**Approach:** Track `Set<String> _visitedThisSession` in a session-level service. If screen not in set, show tip. Add to set after showing.

**Files:** New `peso_session_service.dart`, `peso_screen_tip.dart` (add session variant)

**Estimate:** ~1.5h

---

### SA-4: Peso in screen AppBars as interactive mini-avatar (LOW)
Instead of (or in addition to) the ❓ InfoButton, show a tiny tappable Peso (18px) in AppBar actions. Tapping him shows the screen's contextual tip.

This replaces the static InfoButton experience with a Peso-branded one while keeping the info content.

**Note:** InfoButton already shows Peso bottom sheet via `info_button.dart` — so this is additive, not a replacement.

**Files:** Multiple screen files (AppBar actions)

**Estimate:** ~1h

---

### SA-5: Notifications — Peso as the notification icon (MEDIUM)
Currently all notifications use `@mipmap/ic_launcher` (the app icon). Add a dedicated Peso notification icon:
- Create white silhouette PNG of Peso face: circle + two dots + smile arc — all white on transparent
- Sizes: 24dp (mdpi), 36dp (hdpi), 48dp (xhdpi), 72dp (xxhdpi), 96dp (xxxhdpi)
- Add to `android/app/src/main/res/drawable*/peso_notif.png`
- Update `AndroidInitializationSettings('@mipmap/ic_launcher')` → `('@drawable/peso_notif')`

**Blocker:** Needs graphic asset creation

**Files:** `notification_service.dart` (one line), plus PNG assets

**Estimate:** 30min code + 1h graphic design

---

### SA-6: Peso reacts when a notification is tapped (MEDIUM)
When user taps a push notification and opens the app, Peso should react to the notification context:
- Budget alert tapped → Peso `worried` + "Let's see what happened to [category]..."
- Level up tapped → Peso `celebrating` + "You leveled up! Check your new score!"
- Goal deadline tapped → Peso `thinking` + "Let's see how your goal is doing..."

**Approach:** Use `payload` in `_plugin.show()` to encode the notification type. In `initState` of the landing screen, check the last notification payload and show appropriate Peso reaction.

**Files:** `notification_service.dart` (add payload), `home_screen.dart` (handle payload)

**Estimate:** ~2h

---

### SA-7: Peso's "unfinished tasks" reminders (MEDIUM)
When user opens the app, Peso should gently mention unfinished tasks:
- "You have 2 recurring bills due this week — want to log them?"
- "Your Emergency Fund goal hasn't had a contribution this month"
- "You haven't set a budget for [category] yet"

These are GENTLE — shown at most once per day, via in-app SnackBar (not push notification), respecting the existing daily nudge gate pattern.

**Files:** `home_screen.dart` `initState` startup chain

**Estimate:** ~1.5h

---

## Summary Table

| Task | Priority | Est. | Blocker |
|------|----------|------|---------|
| SA-1: Expand screen context map | High | 2h | None |
| SA-2: Live data in tips | Medium | 2h | SA-1 |
| SA-3: Session-based tips | Medium | 1.5h | None |
| SA-4: Mini Peso in AppBars | Low | 1h | None |
| SA-5: Peso notification icon | Medium | 1.5h | Need PNG asset |
| SA-6: Notification tap reaction | Medium | 2h | None |
| SA-7: Unfinished tasks reminders | Medium | 1.5h | None |

---

## Current Implementation Quality Notes

### Things that are static/non-dynamic that should be improved:
1. `_pesoScreenTips` map only has 3 tabs (0, 1, 3) — Tools tab and sub-screens not covered
2. `PesoScreenTip` tips are hardcoded strings — should use `PesoVoiceService` for variety
3. The nav bubble tip selection uses `millisecondsSinceEpoch % tips.length` — works but not truly random; could use `Random()`
4. `_showPesoNavTip()` fires blindly 8s after launch — should check if user is a new user (first few launches) vs returning user and adjust message accordingly

*Added by Kiro — October 12, 2026*
