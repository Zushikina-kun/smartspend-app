# Peso Mascot — Personality, Reactivity & Expression Tasks
**Date:** October 12, 2026
**Status:** Planning / To-Do — NO CODE YET
**Context:** Raised during website overhaul session. Research conducted on Duolingo (Rive animation system), Miss Minutes (Loki/Marvel rubber-hose anthropomorphic object), Notion AI mascot, ChatGPT animated dots, and general mascot personality design.

---

## Current State Audit

### What already exists in `peso_mascot.dart`
The `PesoMascot` Flutter widget is a full `CustomPainter`-based coin character with:
- **5 moods:** `happy`, `neutral`, `thinking`, `sad`, `celebrating`
- **Per-mood visuals:** body color changes, eyebrow angle, eye shape, mouth shape, arm positions, blush, confetti, thought bubble
- **`withSpeech()` factory:** Peso + speech bubble above him
- **STATIC widget** — no animation, no transitions between moods

### Where it's already used (14+ screens)
| Screen | Usage | Mood |
|--------|-------|------|
| `ai_screen.dart` | Welcome/greeting when chat is empty | `happy` |
| `ai_screen.dart` | AppBar title row | `happy` — always, even during errors |
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

### Key Gaps
1. **No animation whatsoever** — every instance is completely static
2. **Only 2 of 5 moods are used regularly** — `happy` and `thinking` dominate; `sad`, `neutral`, `celebrating` are rare
3. **Not reactive to context** — Peso is `happy` in the AI header even when there's an error or the user is upset
4. **Missing moods** for many real scenarios — confused, excited, proud, embarrassed, sleepy, winking
5. **No idle personality** — Duolingo's Duo bobs, blinks, looks around; Peso just sits there
6. **Not in notifications** — push notifications use generic app icon
7. **Website SVG is static** — no CSS animations at all
8. **Under-used on key screens** — Analytics, Profile, Achievements, FHS breakdown don't have Peso

---

## Research Findings

### Duolingo's Approach (industry gold standard)
Duolingo uses **Rive** (formerly Flare) for character animation — a state machine approach where each state (idle, listening, thinking, talking, celebrating, sad) has its own animation loop, and transitions between states are defined as smooth blend animations. Key insight from their engineering: *"This is a state problem, not an animation problem."* The character must represent: idle/waiting, listening, thinking, talking, emotional feedback.

For SmartSpend without Rive: we can approximate this with Flutter `AnimationController` + `CustomPainter` by interpolating the coordinate values between two states using `Tween<double>`.

### Miss Minutes Design Lessons (Loki/Marvel)
Miss Minutes is an anthropomorphic clock with rubber-hose animation style — simple, flat, iconic shape, big expressive face, exaggerated reactions. The design lesson: **object identity + face = character**. For Peso: the ₱ coin shape IS his identity. The face makes him alive. Every expression should amplify both.

### Notion AI Mascot
Notion's mascot transitions "seamlessly between any state, adapting to user interactions in real time" — listening → thinking → writing within seconds, each transition organic. Key: **transitions must feel earned, not jarring**. A sudden mood switch (happy → sad) without a transition animation looks broken.

### ChatGPT Animated Dots
Even without a face, animated dots can convey state (idle pulse, thinking spiral, speaking bounce). For Peso: the body itself can pulsate, the eyes can look around during `thinking`, the arms can react during `celebrating`.

---

## Expanded Expression System

### Current 5 moods → Proposed 12 moods

| Mood | When to Use | Visual Signature |
|------|-------------|-----------------|
| `happy` | Default, after logging, good FHS | Arms up-angled, wide smile, cheek blush |
| `neutral` | Idle, awaiting input | Arms at sides, slight smile |
| `thinking` | AI processing, empty states | One brow raised, flat mouth, thought bubble, pupils shifted right |
| `sad` | Error, low FHS (<50), overbudget warning | Arms drooping, frown, half-lidded eyes, blue-tinted body |
| `celebrating` | Milestone, badge unlock, goal reached, zero debt | Arms high, O-mouth, legs spread, confetti burst |
| **`excited`** *(new)* | Big achievement, streak milestone, first login | Both arms straight UP, huge smile, body bouncing, stars around head |
| **`surprised`** *(new)* | Unexpected insight, "did you know?" tip, large expense flagged | Eyes extra wide (bigger than normal), eyebrows high, mouth O, arms spread wide |
| **`proud`** *(new)* | Consistent savings, all budgets on track, FHS ≥ 90 | One arm on hip (akimbo), chest slightly puffed, satisfied smile, subtle glow |
| **`embarrassed`** *(new)* | User missed a logging streak, budget way over, impulse buy detected | Cheeks bright red, eyes looking down, arms covering face or one hand behind head |
| **`winking`** *(new)* | Tips, hints, "did you know" cards, suggestion chips | One eye closed/wink, slight smirk, one arm pointing |
| **`sleepy`** *(new)* | Inactive/no logging for 3+ days, app idle screen, night-time greeting | Half-lidded droopy eyes, Zzzz floating above, arms slack |
| **`worried`** *(new)* | Upcoming bill due, debt overdue, Safe-to-Spend very low | Eyebrows close together and low (concerned), slight frown, one hand on cheek |

### Body Color by Mood
| Mood | Body Rim Color | Body Tint |
|------|---------------|-----------|
| `happy`, `neutral`, `winking`, `proud` | `#00C896` (emerald) | Normal |
| `thinking`, `worried` | `#7C5CFC` (purple) | Slight purple tint |
| `sad`, `embarrassed` | `#8AABB8` (muted blue-gray) | Desaturated |
| `celebrating`, `excited` | `#FF8C00` (warm orange-gold) | Gold shimmer |
| `surprised` | `#FFD700` (bright yellow) | Brief flash |
| `sleepy` | `#6B8E9F` (slate blue) | Dim |

---

## Personality Traits to Encode (Character Bible)

Peso is a **Filipino Gen Z coin mascot** — think friendly, a bit playful, genuinely helpful but not corporate. His personality traits:

| Trait | Expression |
|-------|-----------|
| **Makulit** (playful/persistent) | Wiggles when ignored, waves arms for attention |
| **Supportive** | Never judges spending — celebrates improvement, not perfection |
| **Expressive** | Reacts to EVERY user action with a micro-expression |
| **Filipino** | Uses Taglish phrases in speech bubbles ("Grabe!", "Ay nako!", "Sige!") |
| **Curious** | Pupils dart around when `thinking`, peeks at new data |
| **Loyal** | More expressive reactions for users with long streaks |

### Taglish Speech Bubble Phrases (per context)
| Context | Phrase |
|---------|--------|
| Good morning greeting | "Magandang umaga! ☀️ Kumain ka na?" |
| After logging expense | "Noted! ✅ Maayos tayo." |
| Budget warning | "Ay, malapit na tayo sa limit! 😬" |
| Goal milestone (50%) | "Kalahati na! 🎯 Keep it up!" |
| FHS drops | "Huwag mag-alala — pwede nating ayusin 'to! 💪" |
| FHS improves | "Grabe ka! Gumaling pa ang score mo! 🎉" |
| No logging for 3 days | "Hoy! 3 days na wala akong balita... 👀" |
| Zero debt celebration | "WALANG UTANG! Peso is SO proud of you! 🥹" |
| First app open | "Kumusta! Ako si Peso — your money buddy! ₱" |
| Offline mode | "Walang internet pero okay lang — nandito pa rin ako! 📴" |

---

## Task List (expanded + reprioritized)

### PRIORITY 1 — Foundations (enables everything else)

**Task A-0: Convert PesoMascot to AnimatedWidget** *(prerequisite for all animation)*
- Change from `StatelessWidget` → `StatefulWidget` with `TickerProviderStateMixin`
- Add `AnimationController _idleCtrl` (looping, 2.4s) and `AnimationController _moodCtrl` (one-shot, 400ms)
- `_idleCtrl` drives the breathing bob: `scale 0.97→1.0→0.97` + `translateY 0→-2px→0`
- `_moodCtrl` drives mood transitions: interpolates all coordinate groups between old and new mood
- Export `AnimatedPesoMascot` as the primary widget; keep `PesoMascot` as a static fallback
- **Must support `prefers-reduced-motion`** — check `MediaQuery.of(context).disableAnimations`

**Task A-1: Idle breathing + eye blink**
- Scale pulse: `0.97 → 1.00 → 0.97` (2.4s loop)
- Vertical bob: `+0 → -2px → +0` synchronized with scale
- Eye blink: every 3–5 seconds, `eyeR` briefly collapses to 20% height over 120ms then reopens — creates lifelike blink
- During `thinking` mood: pupils drift left–right slowly (curiosity)
- During `sleepy` mood: blink rate slows to every 1.5s, eyes stay 60% closed

**Task A-2: Mood entry animations**
- Pop-in: new mood starts at `scale 0.7` → `scale 1.08` → `scale 1.0` (elastic curve, 350ms)
- Body color cross-fade: interpolate `_rimColor` over 300ms using `ColorTween`
- Arms swing to new position over 400ms using coordinate `Tween<double>`
- Eyebrow angle transitions over 250ms
- Mouth path transitions over 250ms (interpolate quadratic bezier control points)

### PRIORITY 2 — New Expressions

**Task A-3: Add `excited` mood**
- Both arms straight upward (higher than celebrating)  
- Body slightly taller/stretched (scale Y 1.05)
- Stars or sparkles around the head (4-6 small star shapes that twinkle)
- Mouth: extra-wide smile, wider than `happy`
- Eyes: slightly bigger than normal
- Body color: gold/orange `#FF8C00`
- Use when: first streak milestone, badge newly unlocked, FHS reaches new tier

**Task A-4: Add `surprised` mood**
- Eyes: noticeably larger whites (r × 1.3), pupils centered and small
- Eyebrows: both raised high and arched sharply  
- Mouth: perfect O shape (small circle)
- Arms: spread wide horizontally, not raised
- Body: brief yellow flash `#FFD700` then back to normal green
- Use when: AI detects a notably large expense, "Did you know?" tip cards

**Task A-5: Add `proud` mood**
- Right arm on hip (drawn as a bent L-shape at the side)
- Left arm slightly raised
- Chin slightly raised (body tilts +3°)
- Subtle glow ring around the coin body (emerald radial gradient at 15% opacity)
- Mouth: satisfied closed-mouth smile (no teeth)
- Use when: FHS ≥ 90, all budgets on track, savings rate ≥ 20% for the month

**Task A-6: Add `embarrassed` mood**
- Cheeks: much brighter red blush `rgba(255,60,60,0.35)` (more intense than happy blush)
- Eyes: looking downward (pupils shifted to bottom of eye whites)
- One hand raised to cover part of face, or one hand behind head
- Mouth: closed, slight grimace
- Body: slightly desaturated pink-tinted
- Use when: impulse buy tagged "Want" > daily limit, budget ≥ 150% overspent

**Task A-7: Add `winking` mood**
- Left eye: fully closed (eye white becomes a curved arc `^` shape)
- Right eye: normal open with shine
- Left eyebrow: slightly raised
- Mouth: smirk (asymmetric — one side higher)
- Right arm: pointing outward (index finger extended — drawn as a small circle)
- Use when: tips, hints, "Try this" suggestion chips, Quick Tips screen

**Task A-8: Add `sleepy` mood**
- Eyes: heavily drooped (eye whites compressed to 40% height, pupils not visible)  
- Eyebrows: both slightly furrowed inward-down
- Mouth: small neutral line
- Arms: hanging low at sides, slightly drooping
- Body color: muted slate-blue `#6B8E9F`
- Zzz animation: 3 small "Z" text bubbles floating up from the top of the coin, fading out at different heights (staggered delays)
- Use when: no logging for 3+ days, late-night (after midnight) greeting

**Task A-9: Add `worried` mood**
- Eyebrows: both angled down toward center (classic worried/concerned)
- Eyes: slightly narrowed, looking forward
- Mouth: small downward curve (not full frown — more "uncertain")
- One hand on chin or cheek (thinking-but-worried pose)
- Body color: stays green but slightly desaturated
- Use when: bill due in <3 days, Safe-to-Spend < ₱100, debt overdue

### PRIORITY 3 — Reactive AI Chat Integration

**Task A-10: Dynamic mood in AI screen header**
Add `ValueNotifier<PesoMood> _pesoChatMood` to `_AiScreenState`:
- **Sending message** → `thinking` (immediately, while waiting for reply)
- **Reply arrives (normal)** → `happy` after 300ms delay
- **Reply contains celebration keywords** ("congratulations", "nabayaran", "goal reached", "🎉", "badge") → `celebrating` for 2s then `happy`
- **Reply contains error/apology** ("error", "hindi ko", "sorry", "failed") → `sad` for 2s then `neutral`
- **Reply contains financial advice warning** ("over budget", "nag-overspend", "lampas na") → `worried` for 3s then `neutral`
- **Reply contains encouragement/compliment** ("great job", "galing mo", "consistent") → `proud` for 2s then `happy`
- **Large expense logged (>₱1000)** → `surprised` for 1.5s then `happy`
- **Daily limit reached** → `sad` for 3s then `neutral`
- **New badge unlocked** → `excited` for 3s with confetti then `happy`

**Task A-11: Peso reacts to FHS changes**
In `home_screen.dart` when FHS score is recalculated:
- Score went UP → `celebrating` for 2s
- Score went DOWN → `sad` for 2s
- FHS ≥ 90 on load → `proud`
- FHS < 50 on load → `worried`
- FHS 50–89 → `happy` or `neutral` based on direction of change

**Task A-12: Peso reacts to budget status**
In `home_screen.dart` budget cards and `analytics_screen.dart`:
- All budgets ≤ 80% used → `happy`
- Any budget 80–100% → `worried` on that card
- Any budget > 100% → `embarrassed` on that card (with bright blush)

**Task A-13: Streak-aware expressions**
- 1-day streak: `happy`
- 7-day streak: `excited` with "Week Warrior!" speech bubble
- 31-day streak: `celebrating` with "GRABE! 31 days! Month Master!" speech bubble
- Streak broken: `sad` + "Ay... nawala ang streak natin. Simulan ulit tayo!" speech bubble

### PRIORITY 4 — Screen-Specific Placements

**Task A-14: Peso on Analytics screen**
- When no data: `thinking` + "Wala pa tayong data! Mag-log tayo para makita ang charts."
- When FHS is displayed: mood matches FHS range (see A-11)
- "AI Financial Advice" section: `winking` Peso in header with "Heto ang tips ko para sa iyo! 💡"

**Task A-15: Peso on Profile screen**
- Top of profile: small `happy` Peso (48px) beside the avatar/name
- When Financial Health Certificate is viewed: `celebrating`
- When backup is completed: `proud` + "Safe na ang data mo! 🔒"

**Task A-16: Peso on Achievements screen**
- First open (no badges): `winking` + "Kumita tayo ng mga badges! Magsimula tayo!"
- Badge just unlocked: `excited` with confetti filling the screen briefly
- All 25 badges earned: `celebrating` + "COMPLETE! Ikaw ang pinakamahusay! 🏆"

**Task A-17: Peso on Quick Tips screen (new screen)**
- Show `winking` Peso at the top with "Heto ang ilang tips bago magsimula! 😉"

**Task A-18: Peso on Feedback/Report screen (when built)**
- `happy` Peso with "Salamat sa feedback! 🙏 Your input helps us improve."
- After submit: `celebrating` Peso

### PRIORITY 5 — Website Animations

**Prerequisite W-0: Add class attributes to SVG elements**
Before any CSS animation can target individual parts, the `<symbol id="peso-face">` needs class names on each animatable element:
- `.peso-body` — main coin circle
- `.peso-eye-l`, `.peso-eye-r` — eye white circles  
- `.peso-pupil-l`, `.peso-pupil-r` — pupils
- `.peso-arm-l`, `.peso-arm-r` — arm lines
- `.peso-smile` — mouth path
- `.peso-brow-l`, `.peso-brow-r` — eyebrow paths
- `.peso-leg-l`, `.peso-leg-r` — leg lines

**Task W-1: CSS idle animation (bob + blink)**
```css
@keyframes pesoBob {
  0%, 100% { transform: translateY(0) scale(1); }
  50%       { transform: translateY(-4px) scale(1.01); }
}
.peso-mascot { animation: pesoBob 2.4s ease-in-out infinite; }

@keyframes pesoBlink {
  0%, 90%, 100% { transform: scaleY(1); transform-origin: center; }
  93%           { transform: scaleY(0.1); }
  96%           { transform: scaleY(1); }
}
.peso-eye-l, .peso-eye-r, .peso-pupil-l, .peso-pupil-r {
  animation: pesoBlink 4s ease-in-out infinite;
}
/* Stagger right eye blink slightly */
.peso-eye-r, .peso-pupil-r { animation-delay: 0.05s; }
```
Accessibility: `@media (prefers-reduced-motion: reduce) { .peso-mascot, .peso-mascot * { animation: none !important; } }`

**Task W-2: Hover wave animation**
```css
@keyframes pesoWave {
  0%, 100% { transform: rotate(0deg); }
  25%       { transform: rotate(-20deg); }
  75%       { transform: rotate(12deg); }
}
.peso-mascot:hover .peso-arm-r {
  animation: pesoWave 0.5s ease-in-out 2;
  transform-origin: 98px 58px; /* right arm shoulder joint */
}
```

**Task W-3: Pop-in on scroll into view**
JS: `IntersectionObserver` adds `.peso-visible` class when mascot enters viewport.
```css
@keyframes pesoPopIn {
  0%   { transform: scale(0.4) rotate(-10deg); opacity: 0; }
  65%  { transform: scale(1.1) rotate(3deg); opacity: 1; }
  100% { transform: scale(1) rotate(0deg); opacity: 1; }
}
.peso-mascot.peso-visible {
  animation: pesoPopIn 0.55s cubic-bezier(0.34, 1.56, 0.64, 1) forwards;
}
```

**Task W-4: Demo Lite mood switching via CSS classes**
Add CSS classes `.peso-thinking`, `.peso-celebrating`, `.peso-sad` to the SVG that override fill colors and transform arm/eye elements. JS switches classes based on demo state.

**Task W-5: Hero hover speech bubble**
```css
.peso-mascot::after {
  content: "Magandang araw! 👋";
  position: absolute; bottom: calc(100% + 8px); left: 50%;
  transform: translateX(-50%) scale(0.8); opacity: 0;
  background: var(--primary-glow); border: 1px solid var(--border-strong);
  border-radius: 12px; padding: 6px 12px; font-size: 12px; white-space: nowrap;
  transition: opacity 0.2s, transform 0.2s; pointer-events: none;
}
.peso-mascot:hover::after { opacity: 1; transform: translateX(-50%) scale(1); }
```

### PRIORITY 6 — Rive Migration (future, post-capstone)

**Task A-Future-1: Migrate to Rive animation system**
Duolingo uses Rive for fluid state-machine-based animation. Once the capstone is done:
- Design Peso character in Rive (or hire a UI animator)
- Define state machine: idle, listening, thinking, talking, celebrating, sad, excited, winking
- Each state has its own animation loop with entry/exit transitions
- Export as `.riv` file, use `rive` Flutter package
- The result: fully fluid, professional-grade animations with zero code for new expressions

**Why not now:** Rive requires a designer with animation skills + significant time investment. For the capstone timeline, the `CustomPainter` approach (Tasks A-0 through A-18) is achievable without a designer.

---

## Implementation Order (if doing in one session)

```
W-0 (add SVG classes) → W-1 (CSS bob+blink) → W-3 (pop-in)     [website, 2h]
A-0 (AnimatedWidget)  → A-1 (idle breathing) → A-10 (AI chat)  [app, 4h]
A-3–A-9 (new moods)                                              [app, 3h]
A-11–A-13 (FHS/budget/streak reactions)                          [app, 2h]
A-14–A-18 (more screen placements)                               [app, 2h]
W-2,W-4,W-5 (hover, demo mood, speech bubble)                   [website, 1h]
```
Total estimate: ~14h. Can be split over 2–3 sessions.

---

## Accessibility Requirements (all tasks)

**Flutter app:**
```dart
if (!MediaQuery.of(context).disableAnimations) {
  _idleCtrl.repeat(reverse: true);
}
```

**Website CSS:**
```css
@media (prefers-reduced-motion: reduce) {
  .peso-mascot, .peso-mascot * {
    animation: none !important;
    transition: none !important;
  }
}
```

Both are required before shipping any animation task.

---

*Last updated: October 12, 2026 — expanded with research on Duolingo/Rive, Miss Minutes, Notion AI mascot, ChatGPT dots. No code changes made.*
