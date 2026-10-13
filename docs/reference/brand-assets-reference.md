 # SmartSpend Brand Assets Reference
**Last updated:** October 13, 2026

---

## App Icon / Logo
**File:** `assets/logo.png` (also `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`)
**Description:** Camera + magnifier lens + receipt illustration. Dark navy/charcoal outlines on white/transparent background. Green dollar sign on receipt. Blue eye/lens. Used as app launcher icon.
**Usage:** Nav brand (32px), Hero section (96px tilted -3°), Footer brand (36px rounded corners)

---

## Peso Mascot
**Flutter widget:** `lib/widgets/peso_mascot.dart` — `PesoMascot(size: 80, mood: PesoMood.happy)`
**SVG reference:** `docs/reference/peso-mascot-svg-reference.svg`
**Website inline SVG:** `<symbol id="peso-face">` in `index.html`

### Design Principles
- Inspired by **Duolingo's Duo** (one strong color, huge eyes, minimal detail, round) and **Miss Minutes from Loki** (rubber-hose style, anthropomorphic object as mascot, retro-friendly, flat color)
- **One color = the character** — emerald green is Peso's identity
- **Huge eyes** = emotional expressiveness at any size
- **Minimal detail** = readable at 24px or 240px
- **Round coin body** = approachable, reflects the ₱ peso coin concept

### Visual Elements
| Element | Description |
|---------|-------------|
| Body | Round coin — outer rim `#00C896`, inner gradient white-to-transparent |
| Forehead | ₱ symbol in muted green — identity marker |
| Eyes | Large white circles, dark pupils, dual shine dots |
| Eyebrows | Friendly arch — mood-responsive |
| Mouth | Wide smile with tooth fill for happy; frown/flat for other moods |
| Arms | Raised upward at ~45°, 3-blob hands |
| Legs | Short lines going down |
| Feet | Oval rounded feet |
| Blush | Soft pink ellipses on cheeks (happy/celebrating only) |

### Colors
| Name | Hex | Use |
|------|-----|-----|
| `kPesoGreen` | `#00C896` | Body rim, arms, legs |
| `kPesoGreenDark` | `#00A86B` / `#008F6A` | Rim shadow, eyebrows, ₱ symbol |
| `kPesoGreenLight` | `#B3F5E6` | Speech bubble background |
| Pupil/outline | `#0D2B1A` | Eyes, smile outline |
| Face surface | White radial gradient | Inner coin face |

### Moods (Flutter app)
- `PesoMood.happy` — Arms up, big smile, cheek blush (default)
- `PesoMood.sad` — Drooping arms, frown, half-lidded eyes, blue-tinted
- `PesoMood.excited` — Arms spread wide, wide grin, energetic pose
- `PesoMood.surprised` — Raised eyebrows, open-circle mouth, arms up
- `PesoMood.proud` — Chest out, confident smile, one hand on hip
- `PesoMood.embarrassed` — Arms inward, downward glance, blush cheeks
- `PesoMood.winking` — One eye closed, slight smirk
- `PesoMood.sleepy` — Half-lidded eyes, droopy arms, Zzz bubble
- `PesoMood.worried` — Furrowed brows, small sweat drop, arms close
- `PesoMood.neutral` — Arms slightly lower, small smile
- `PesoMood.thinking` — One eyebrow raised, tilted mouth, thought bubble
- `PesoMood.celebrating` — Arms high, open O-mouth, legs spread, confetti

### Website Usage (5 placements in index.html)
1. Hero right column — 120px
2. AI / Peso section heading — 48px
3. AI chat bubble avatar — 20px
4. Demo Lite section heading — 40px
5. Nav brand (currently using app icon instead — design choice)

---

## LucidFrame Logo
**File:** `assets/LucidFrameLogo.png`
**Description:** White angular "LF" geometric logo on transparent background. Isometric/3D style letterforms. "Lucid Frame" text in white.
**Usage on website:** Must always use `.lucid-logo-wrap` (dark navy `#1a1a2e` background pill) — the logo is white and invisible on light backgrounds without it.

---

## Lorma Colleges Logo
**File:** `assets/LormaLogo.jpg`
**Description:** Teal/dark green oval badge with "LORMA" in white serif text + "COLLEGES" below in dark green. White JPEG background.
**Usage on website:** Must always use `.lorma-logo-wrap` (white pill with shadow) — otherwise the white JPEG background looks broken on dark mode.

---

## Team Photos
**Location:** `assets/Devs/`
- `BRIX A. DIRECTO.png` — Lead Developer
- `CYRILLE JOHN M. RUBIS.png` — UI/UX & Docs
- `DJAUNATHAN ALBERT S. MADAYAG.png` — PM & QA

**Usage on website:** Circular crop via `border-radius:50%; object-fit:cover; width:72px; height:72px`

---

## Design Inspiration References

### Duolingo Owl (Duo)
Key lessons applied:
- Single dominant color = character identity
- Oversized eyes with expressive pupils for emotion
- Simple silhouette recognizable at any size
- Consistent across all moods/contexts

### Miss Minutes (Loki / Marvel Disney+)
An AI mascot for the Time Variance Authority — anthropomorphic clock with rubber-hose animation style. Key lessons applied:
- Object-as-character (clock → coin)
- Clean flat color fills
- Big personality from simple geometry
- Works at small sizes

### Duolingo + Coins as reference: Peso is essentially Duolingo's Duo but shaped like a ₱ peso coin instead of an owl.

---

## App Color System (Website)

### Dark Mode (`#0d1a0f` forest green, not gray)
| Variable | Value | Description |
|----------|-------|-------------|
| `--bg` | `#0d1a0f` | Page background |
| `--surface` | `#152218` | Card base |
| `--surface2` | `#1a2e1a` | Card elevated |
| `--surface3` | `#1f3520` | Card hover |
| `--primary` | `#00C896` | Accent / CTA |
| `--brand-blue` | `#2563EB` | Nav brand, hero badge |
| `--text` | `#eef2ee` | Main text |
| `--text-muted` | `#8aaa8a` | Secondary text |

### Light Mode (`#f4f0e6` warm parchment, not white)
| Variable | Value | Description |
|----------|-------|-------------|
| `--bg` | `#f4f0e6` | Page background |
| `--surface` | `#eaf0ea` | Card base |
| `--surface2` | `#dceadc` | Card elevated |
| `--primary` | `#00a876` | Accent / CTA (slightly darker for contrast) |
| `--brand-blue` | `#1d4ed8` | Nav brand |
| `--text` | `#1a2e1a` | Main text |
| `--text-muted` | `#4a6a4a` | Secondary text |

### Splash Screen Blue (brand identity moment)
`#2563EB` — used only for brand name in nav, hero badge, and survey CTA. Matches the app's splash screen background color.


---

## Update Log

### October 13, 2026 — v3.1.0 (Peso Everywhere)
- PesoMascot now appears on 34 of 45 screens
- Nav AI button uses PesoMascot instead of Icons.smart_toy
- AI chat reply bubbles show 22px Peso avatar on left
- AI typing indicator shows PesoMood.thinking
- AI AppBar: 32px Peso + "Your money buddy 💚" subtitle
- "Talk to Peso" and "Parse with AI" buttons use Peso
- All ❓ InfoButton dialogs show Peso bottom sheet
- PesoVoiceService: 31 Taglish speech contexts
- 36 achievement badges (was 25), all unlock with Peso celebration
- Tappable Peso: onTap bounce + tapMood override

### Current app version: v3.1.0
### Current website: https://zushikina-kun.github.io/smartspend-app/ (167.5 KB)
