# Peso Mascot — Personality, Reactivity & Website Animation Tasks
**Date:** October 12, 2026
**Status:** Planning / To-Do — NO CODE YET
**Context:** Raised during website overhaul session. The mascot widget already exists and is used across the app, but its reactivity is inconsistent and the website has no animated version at all.

---

## Current State Audit

### What already exists in the app (peso_mascot.dart)
The `PesoMascot` Flutter widget is a full `CustomPainter`-based coin character with:
- **5 moods:** `happy`, `neutral`, `thinking`, `sad`, `celebrating`
- **Per-mood visuals:** body color changes, eyebrow angle, eye shape, mouth shape, arm positions, blush, confetti, thought bubble
- **`withSpeech()` factory:** Peso + speech bubble above him
- **Static widget** — no animation, no transitions between moods

### Where it's already used (14+ screens)
| Screen | Usage | Mood |
|--------|-------|------|
| `ai_screen.dart` | Welcome/greeting when chat is empty | `happy` |
| `ai_screen.dart` | AppBar title row | `happy` |
| `setup_screen.dart` | Onboarding step 1 (greeting) | `happy` |
| `setup_screen.dart` | Onboarding income step | `thinking` |
| `home_screen.dart` | Empty state hints | `thinking` |
| `home_screen.dart` | Subscription summary card | `thinking` |
| `home_screen.dart` | Achievement celebration inline | `celebrating` |
| `bill_calendar_screen.dart` | Empty state | `thinking` |
| `chat_history_screen.dart` | Empty chat history | `thinking` |
| `chat_history_screen.dart` | Empty session | `thinking` |
| `debt_payoff_screen.dart` | Zero debt celebration | `celebrating` |
| `income_screen.dart` | No income records | `thinking` |
| `insurance_screen.dart` | No insurance records | `thinking` |
| `manage_categories_screen.dart` | No categories | `thinking` |
| `manage_rules_screen.dart` | No rules | `thinking` |
| `recurring_screen.dart` | No recurring bills | `thinking` |
| `savings_goals_screen.dart` | No goals | `thinking` |
| `transactions_screen.dart` | No transactions | `thinking` |

### What's missing / gaps
1. **No animation** — moods switch instantly, no bounce/wiggle/blink
2. **No reactive mood in AI chat** — Peso is always `happy` in the header regardless of what the user is asking; he should react to message content
3. **Not present in notifications** — push notifications don't use Peso at all
4. **Not on the website** — website has a static SVG; no animation
5. **No idle animation** — Peso just sits there; Duolingo's Duo bobs/breathes
6. **Under-used screens** — analytics, profile, achievements, FHS breakdown don't use Peso despite being natural places for encouragement

---

## Task List

### PRIORITY 1 — App: Animate the existing widget

**Task A-1: Add idle "breathing" animation to PesoMascot**
- `PesoMascot` is currently a `StatelessWidget` — convert to `StatefulWidget` with `SingleTickerProviderStateMixin`
- Add a looping `AnimationController` (duration ~2s, repeat with reverse)
- Apply a subtle scale pulse: `0.97 → 1.00 → 0.97` on the whole widget
- Apply a subtle vertical bob: `+0` → `-2px` → `+0` on the Y position
- Should work at any size (24px nav icon should still breathe, just barely)
- **Reference:** Duolingo Duo's idle bounce

**Task A-2: Add mood transition animation**
- When `mood` prop changes, animate the face elements (eyebrows, mouth, blush) over ~300ms
- Use `AnimatedBuilder` + `Tween` on a single controller
- The body color change (`#00C896` → `#8AABB8` for sad, `#FF8C00` for celebrating) should cross-fade
- Arms should swing to new position over ~400ms
- **Research needed:** Tweening between two `CustomPainter` states — one approach is interpolating all the coordinates directly with a `Tween<double>` multiplier

**Task A-3: Add entry animation ("pop in")**
- When Peso first appears on screen (empty state, etc.), animate a scale from `0.6 → 1.05 → 1.0` over ~500ms with an elastic curve
- Use `AnimatedScale` wrapper or custom controller in `initState`

---

### PRIORITY 2 — App: Reactive mood in AI chat

**Task A-4: Mood-reactive Peso header in ai_screen.dart**
- The `AppBar` title row has `PesoMascot(size: 28, mood: PesoMood.happy)` — always happy
- Add a `ValueNotifier<PesoMood> _pesoChatMood` in `_AiScreenState`
- React to the CURRENT message context:
  - User sends a message → `thinking` (while waiting for reply)
  - Reply arrives normally → `happy`
  - Reply is a celebration (badge unlocked, goal hit, debt cleared) → `celebrating` for 3s then back to `happy`
  - Error / all providers exhausted → `sad` for 3s then `neutral`
  - Financial advice query detected → `thinking`
- Detection: scan the reply text for keywords: `"🎉"`, `"congratulations"`, `"nabayaran"`, `"nadaan"`, etc. → `celebrating`; scan for `"error"`, `"sorry"`, `"hindi ko"` → `sad`
- **This is the highest-impact change** — makes Peso feel alive during the conversation

**Task A-5: Peso reacts to user's financial health**
- When FHS changes, show Peso with the appropriate mood as part of the "Score improved!" / "Score dropped" snackbar or card on home screen
- FHS ≥ 90 → `celebrating`
- FHS 70–89 → `happy`
- FHS 50–69 → `neutral`
- FHS < 50 → `sad`
- Currently the snackbar has an emoji but not the actual Peso widget

---

### PRIORITY 3 — App: Peso in more places

**Task A-6: Peso in push notifications (notification icon)**
- Android push notifications currently use the app icon
- Add a Peso coin face as a custom small notification icon (white silhouette on transparent background, ~24dp)
- Requires: creating a `peso_notif_icon.png` in `res/drawable/` — a simplified flat version of the coin face (just the circle outline + two dots for eyes + curve for smile, all white)
- Update `notification_service.dart` to use `androidIcon: 'peso_notif_icon'`
- **Note:** Android notification icons MUST be white on transparent — no color fills allowed

**Task A-7: Peso in achievement unlocks**
- When a badge is unlocked, the current SnackBar has an emoji
- Replace with a small Peso (`celebrating` mood) + badge name
- Either a custom SnackBar widget or a brief overlay

**Task A-8: Peso in more empty states**
- `analytics_screen.dart` — no Peso when there's no data
- `profile_screen.dart` — no Peso
- `achievements_screen.dart` — no Peso on first open (all locked badges)
- Add `PesoMascot.withSpeech()` to each empty state with contextual Taglish hint text

**Task A-9: Peso idle animations on the AI welcome screen**
- The AI screen's welcome state already shows `PesoMascot.withSpeech()` at 80px
- Add a gentle floating/bobbing animation here (this is the most visible placement)
- Could also add a slow blink animation (briefly close eyes) every ~4s

---

### PRIORITY 4 — Website: Animated Peso SVG

**Task W-1: CSS keyframe animations for website Peso**
The website has a static SVG `<symbol id="peso-face">`. Add CSS animations:

**Idle bob:**
```css
@keyframes pesoBob {
  0%, 100% { transform: translateY(0); }
  50%       { transform: translateY(-4px); }
}
.peso-mascot { animation: pesoBob 2.2s ease-in-out infinite; }
```

**Blink (close and reopen eyes):**
- Tricky in SVG — can animate `ry` on the eye white ellipses to briefly collapse to 0
- OR use `scaleY(0)` transform on the eye white groups
- Trigger: every ~4 seconds, blink duration ~200ms

```css
@keyframes pesoBlink {
  0%, 94%, 100% { transform: scaleY(1); }
  96%           { transform: scaleY(0.1); }
  98%           { transform: scaleY(1); }
}
```
Apply to `.peso-eye-left, .peso-eye-right` — needs the SVG elements to have those class names.

**Wave arm (on hover):**
```css
@keyframes pesoWave {
  0%, 100% { transform: rotate(0deg); }
  25%      { transform: rotate(-15deg); }
  75%      { transform: rotate(10deg); }
}
.peso-mascot:hover .peso-arm-right { 
  animation: pesoWave 0.6s ease-in-out 2; 
  transform-origin: 98px 58px; /* right arm base */
}
```

**Entry pop-in (when first scrolled into view via IntersectionObserver):**
```css
@keyframes pesoPopIn {
  0%   { transform: scale(0.5); opacity: 0; }
  70%  { transform: scale(1.1); opacity: 1; }
  100% { transform: scale(1.0); opacity: 1; }
}
.peso-mascot.pop-in { animation: pesoPopIn 0.5s cubic-bezier(0.34,1.56,0.64,1) forwards; }
```
JS: `IntersectionObserver` adds `.pop-in` class when Peso enters viewport.

**Task W-2: Mood-switching in Demo Lite**
The Demo Lite phone frame has Peso. Currently just `🤖` emoji.
- Replace the demo Peso screen with the actual SVG coin character
- When user sends a message → change Peso SVG body/face to "thinking" state (add `.peso-thinking` class)
- When reply arrives → back to "happy"
- When certain keywords hit (zero debt, goal achieved, etc.) → "celebrating" class briefly
- Implementation: add CSS classes for each mood that override the SVG path attributes via CSS

**Task W-3: Peso on hover shows speech bubble**
On the hero section, when user hovers over the Peso mascot:
- Show a small speech bubble that says "Magandang araw! Ako si Peso 👋"
- CSS-only tooltip via `::after` pseudo-element or a hidden `<div>` that shows on `.peso-mascot:hover`
- Animate in with a `fadeInUp` keyframe

---

### PRIORITY 5 — Research Tasks (before implementing)

**Task R-1: Research Flutter CustomPainter animation patterns**
- How to tween between two sets of canvas coordinates
- `AnimatedBuilder` + `CurvedAnimation` approach vs `TweenAnimationBuilder`
- Reference: [Flutter CustomPainter animation guide]

**Task R-2: Research SVG CSS animation best practices for mascots**
- How popular apps (Duolingo, Grammarly, Headspace) animate their mascots in web
- SVG SMIL vs CSS keyframes (CSS preferred for modern browsers)
- Performance: will-change, requestAnimationFrame for idle loops
- Accessibility: `prefers-reduced-motion` media query — all idle animations should pause

**Task R-3: Android notification icon design rules**
- White-on-transparent silhouette requirements
- Minimum size (24dp, mdpi baseline)
- Adaptive icon vs legacy icon for notifications
- Test on Android 5.0 (API 21) — notification icon behavior differs from newer Android

---

## Implementation Notes for Future Session

### App priority order (if implementing):
1. A-4 (reactive mood in AI chat) — highest user-visible impact, relatively isolated change
2. A-1 (idle breathing) — makes every existing Peso instance feel alive
3. A-6 (notification icon) — requires a graphic asset, then one-line code change
4. A-9 (AI welcome screen bob) — specific to the most-used Peso placement
5. A-5 (FHS mood) — integrates with existing score card
6. A-2 (mood transitions) — more complex animation work
7. A-3 (entry pop-in) — polish
8. A-7, A-8 (more placements) — low effort once animation infrastructure exists

### Website priority order:
1. W-1: CSS bob + blink + hover wave — pure CSS, no JS needed, quick win
2. W-2: Demo Lite mood switching — needs SVG class system
3. W-3: Hero hover speech bubble — CSS tooltip

### Prerequisite for SVG animations (W-1, W-2, W-3):
The current `<symbol id="peso-face">` in `index.html` draws everything as flat SVG shapes without class attributes. To animate individual parts, each major element needs a class name:
- `.peso-eye-left`, `.peso-eye-right` — eye white circles
- `.peso-pupil-left`, `.peso-pupil-right` — pupils
- `.peso-arm-left`, `.peso-arm-right` — arm line + hand group
- `.peso-body` — main coin circle
- `.peso-smile` — mouth path

This means the SVG symbol needs to be refactored to add `class` attributes to each element before CSS animations can target them.

---

## Accessibility Note (important for all animation tasks)
All idle/looping animations MUST respect `prefers-reduced-motion`:
```css
@media (prefers-reduced-motion: reduce) {
  .peso-mascot, .peso-mascot * { animation: none !important; transition: none !important; }
}
```
In Flutter: check `MediaQuery.of(context).disableAnimations` before starting animation controllers.

---

*Added to backlog by Kiro — October 12, 2026*
*No code changes made — planning only.*
