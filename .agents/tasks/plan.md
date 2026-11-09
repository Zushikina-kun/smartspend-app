# Implementation Plan — SmartSpend Website Redesign

> **Single-file target:** `c:\xampp\htdocs\smartspend_app\index.html` (~1600 lines)
> **Codebase state going in:** all 23 carousel slides present, Swiper CDN wired up, theme / hamburger / lightbox / demo-lite / filterSlides / IntersectionObserver JS all in place and working.
> Apply every item in order. Each item must leave `index.html` parseable (no unclosed tags, no broken JS).

---

## DO-NOT-TOUCH — verify after every item

These blocks must remain byte-for-byte identical:

| Block | Location |
|---|---|
| All 23 `<div class="swiper-slide"` with `docs/tools/image_converter/Kiro_Ready/` paths | lines 760–810 of original |
| `<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/swiper@11/swiper-bundle.min.css" />` | `<head>` |
| `<script src="https://cdn.jsdelivr.net/npm/swiper@11/swiper-bundle.min.js"></script>` | before closing `</body>` |
| Functions: `lbOpen / lbClose / setLbSlide / openLightbox / closeLightbox / buildLbSlides` | JS section |
| Functions: `demoTab / demoGetReply / demoTypewriter / demoSend / demoLogBtn` listener | JS section |
| `filterSlides` function | JS section |
| Theme toggle IIFE + `themeToggle` click handler | JS section |
| Hamburger + `closeMobileMenu` | JS section |
| `backToTop` scroll + click | JS section |
| All `IntersectionObserver` blocks (`fadeIO`, `statIO`, `sectionIO`) | JS section |

---

## Item 1 — CSS Variables + Fonts

**What:** Replace the entire `:root` and `[data-theme="light"]` blocks with the new color system. Add `--nav-bg` to both blocks. Add Google Fonts `<link>` tags in `<head>` before the `<style>` block. Add font-family rules for headings and body.

**Exact changes:**

1. In `<head>`, immediately before `<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/swiper@11/...">`, insert:
```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
```

2. Replace the existing `:root { ... }` block with:
```css
:root {
  --bg: #0d1a0f;
  --bg-deep: #080f09;
  --surface: #152218;
  --surface2: #1a2e1a;
  --surface3: #1f3520;
  --surface-elevated: #243d24;
  --text: #eef2ee;
  --text-muted: #8aaa8a;
  --text-dim: #5a7a5a;
  --primary: #00C896;
  --primary-dark: #009e78;
  --primary-glow: rgba(0,200,150,0.15);
  --border: rgba(0,200,150,0.12);
  --border-strong: rgba(0,200,150,0.25);
  --brand-blue: #2563EB;
  --peso-green: #2D9E6B;
  --radius: 18px;
  --nav-bg: rgba(13,26,15,0.95);
  --shadow: rgba(0,0,0,0.5);
}
```

3. Replace the existing `[data-theme="light"] { ... }` block with:
```css
[data-theme="light"] {
  --bg: #f4f0e6;
  --bg-deep: #ede8db;
  --surface: #eaf0ea;
  --surface2: #dceadc;
  --surface3: #f0f7f0;
  --surface-elevated: #ffffff;
  --text: #1a2e1a;
  --text-muted: #4a6a4a;
  --text-dim: #7a9a7a;
  --primary: #00a876;
  --primary-dark: #007a56;
  --primary-glow: rgba(0,168,118,0.12);
  --border: rgba(26,92,42,0.15);
  --border-strong: rgba(26,92,42,0.3);
  --brand-blue: #1d4ed8;
  --peso-green: #2D9E6B;
  --nav-bg: rgba(244,240,230,0.96);
  --shadow: rgba(0,0,0,0.12);
}
```

4. Update the `body` rule's `font-family` to:
```css
font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
```

5. Add after the existing `body { ... }` rule:
```css
h1, h2, h3, .section-title, .hero h1 {
  font-family: 'Plus Jakarta Sans', sans-serif;
}
```

6. Update the theme-toggle JS IIFE: change both `meta.content` assignments so dark → `#0d1a0f` and light → `#f4f0e6`. Also update the `themeToggle.addEventListener` handler's same two `meta.content` lines.
   - Find: `if (meta) meta.content = saved === 'dark' ? '#0f1117' : '#f8f9fa';`
   - Replace: `if (meta) meta.content = saved === 'dark' ? '#0d1a0f' : '#f4f0e6';`
   - Find: `if (meta) meta.content = next === 'dark' ? '#0f1117' : '#f8f9fa';`
   - Replace: `if (meta) meta.content = next === 'dark' ? '#0d1a0f' : '#f4f0e6';`

7. Add scrollbar styles inside `<style>` (append near the end of the style block, before `</style>`):
```css
/* scrollbar */
::-webkit-scrollbar { width: 8px; }
::-webkit-scrollbar-track { background: #1a2e1a; }
::-webkit-scrollbar-thumb { background: #2D9E6B; border-radius: 4px; }
[data-theme="light"] ::-webkit-scrollbar-track { background: #dceadc; }
[data-theme="light"] ::-webkit-scrollbar-thumb { background: #2D9E6B; border-radius: 4px; }
```

**Files:** `index.html`

**Verify:** Open `index.html` in a browser. Background must be deep forest green (`#0d1a0f`), not near-black. Text must be off-white (`#eef2ee`). Toggle to light mode — background becomes warm parchment (`#f4f0e6`). Run:
```powershell
Select-String -Path "c:\xampp\htdocs\smartspend_app\index.html" -Pattern "0d1a0f" | Measure-Object | Select-Object Count
# expect Count: at least 2
Select-String -Path "c:\xampp\htdocs\smartspend_app\index.html" -Pattern "Plus Jakarta" | Measure-Object | Select-Object Count
# expect Count: at least 2
Select-String -Path "c:\xampp\htdocs\smartspend_app\index.html" -Pattern "brand-blue" | Measure-Object | Select-Object Count
# expect Count: at least 1
```

---

## Item 2 — Peso SVG Mascot Sprite

**What:** Add a hidden SVG sprite element at the very top of `<body>` (before `<nav>`). This defines reusable symbols so the same defs are declared once and `<use>` references work. Also add the `.peso-mascot` CSS rule.

**Exact change:**

Insert immediately after `<body>` (before `<nav id="mainNav">`):
```html
<!-- SVG sprite — reusable Peso mascot -->
<svg xmlns="http://www.w3.org/2000/svg" style="display:none" id="peso-sprite">
  <symbol id="peso-face" viewBox="0 0 100 110">
    <circle cx="50" cy="55" r="38" fill="#2D9E6B"/>
    <circle cx="50" cy="55" r="38" fill="url(#pesoGradS)" opacity="0.4"/>
    <ellipse cx="36" cy="40" rx="10" ry="7" fill="rgba(255,255,255,0.25)" transform="rotate(-20,36,40)"/>
    <circle cx="37" cy="50" r="8" fill="white"/>
    <circle cx="39" cy="51" r="4.5" fill="#1a2e1a"/>
    <circle cx="41" cy="49" r="1.5" fill="white"/>
    <circle cx="63" cy="50" r="8" fill="white"/>
    <circle cx="65" cy="51" r="4.5" fill="#1a2e1a"/>
    <circle cx="67" cy="49" r="1.5" fill="white"/>
    <path d="M 38 64 Q 50 74 62 64" stroke="#1a2e1a" stroke-width="2.5" fill="none" stroke-linecap="round"/>
    <ellipse cx="16" cy="52" rx="7" ry="5" fill="#2D9E6B" transform="rotate(-30,16,52)"/>
    <ellipse cx="84" cy="52" rx="7" ry="5" fill="#2D9E6B" transform="rotate(30,84,52)"/>
    <circle cx="50" cy="17" r="4" fill="#00C896"/>
    <line x1="50" y1="17" x2="50" y2="25" stroke="#2D9E6B" stroke-width="2.5"/>
    <defs>
      <radialGradient id="pesoGradS" cx="40%" cy="35%">
        <stop offset="0%" stop-color="white"/>
        <stop offset="100%" stop-color="transparent"/>
      </radialGradient>
    </defs>
  </symbol>
</svg>
```

Add in `<style>` block (append before `</style>`):
```css
.peso-mascot { width: var(--peso-size, 48px); height: auto; display: inline-block; vertical-align: middle; }
```

Wherever the plan says "insert Peso mascot at Xpx", use:
```html
<svg class="peso-mascot" style="--peso-size:Xpx"><use href="#peso-face"/></svg>
```

**Files:** `index.html`

**Verify:** Page loads without console errors. The SVG sprite `#peso-sprite` is present in DOM but invisible (display:none). No visual change yet.

---

## Item 3 — Nav

**What:** Update nav styles; add "Privacy" link pointing to `#privacy-ai`; restyle brand name and CTA button.

**Exact CSS changes** (find-and-replace within the existing nav rules):

1. Find `background: var(--nav-bg); backdrop-filter: blur(12px);` in the `nav` rule — change blur to `16px`:
   ```css
   background: var(--nav-bg); backdrop-filter: blur(16px);
   ```

2. Find `.nav-brand { ... }` rule. Add `color: var(--brand-blue); font-family: 'Plus Jakarta Sans'; font-weight: 800;` to it. Remove `color: var(--text)`.

3. Find `.nav-links a { ... }` rule. Add `font-family: 'Inter';` to it.

4. Find `.nav-cta { background: var(--primary); ... border-radius: 20px; ... }` rule. Replace entirely with:
   ```css
   .nav-cta { background: linear-gradient(135deg, #00C896, #009e78); color: #000 !important; padding: 8px 20px; border-radius: 24px; font-weight: 700; font-size: 14px; transition: opacity .2s; white-space: nowrap; font-family: 'Plus Jakarta Sans'; }
   .nav-cta:hover { opacity: 0.85; color: #000 !important; text-decoration: none; }
   ```

**Exact HTML changes:**

5. In `<div class="nav-links" id="navLinks">`, add after the existing `<a href="privacy.html">Privacy</a>` entry (or replace it):
   ```html
   <a href="#privacy-ai">Privacy</a>
   <a href="privacy.html">Privacy Policy</a>
   ```
   (The existing `<a href="privacy.html">Privacy</a>` becomes two links — one anchor-jump, one full page.)

6. In `.mobile-menu`, similarly add `<a href="#privacy-ai" onclick="closeMobileMenu()">Privacy</a>` before the existing privacy.html link.

**Files:** `index.html`

**Verify:** Nav background is semi-transparent forest green (dark) / parchment (light). Brand name is blue. CTA is pill-shaped gradient green. Privacy link appears in nav and scrolls to `#privacy-ai` anchor (section added in Item 7 — use a placeholder `id` for now; verify scroll after Item 7).

---

## Item 4 — Hero Section

**What:** Remove hero orb divs + floatOrb keyframes. Rewrite hero layout to two-column flex on desktop. Update badge, h1, sub, buttons, and meta text.

**Exact CSS changes:**

1. Delete these rules entirely from `<style>`:
   - `.hero-orb { ... }`
   - `.hero-orb-1 { ... }`
   - `.hero-orb-2 { ... }`
   - `.hero-orb-3 { ... }`
   - `@keyframes floatOrb { ... }`
   - `@keyframes heroGradient { ... }` (unused after this change)

2. Update `.hero-wrapper` rule:
   ```css
   .hero-wrapper {
     position: relative;
     background: radial-gradient(ellipse at 80% 20%, rgba(37,99,235,0.08) 0%, transparent 50%),
                 radial-gradient(ellipse at 20% 80%, rgba(0,200,150,0.08) 0%, transparent 50%),
                 var(--bg);
   }
   ```

3. Update `.hero` rule:
   ```css
   .hero {
     max-width: 960px;
     margin: 0 auto;
     padding: 80px 24px 60px;
     position: relative;
     z-index: 1;
     display: flex;
     align-items: center;
     gap: 48px;
   }
   ```

4. Add new rules:
   ```css
   .hero-left { flex: 1; }
   .hero-right { flex-shrink: 0; display: flex; flex-direction: column; align-items: center; gap: 16px; }
   .hero-app-icon { width: 96px; height: 96px; border-radius: 20px; filter: drop-shadow(0 8px 24px rgba(0,200,150,0.3)); transform: rotate(-3deg); }
   @media (max-width: 767px) {
     .hero { flex-direction: column; text-align: center; }
     .hero-right { order: -1; }
   }
   ```

5. Update `.hero-badge` rule — change background/border/color to use `--brand-blue`:
   ```css
   .hero-badge { display: inline-block; background: rgba(37,99,235,0.12); border: 1px solid rgba(37,99,235,0.3); color: var(--brand-blue); font-size: 13px; font-weight: 600; padding: 4px 14px; border-radius: 20px; margin-bottom: 24px; }
   ```

6. Update `.hero p` (subheading):
   ```css
   .hero p { font-size: 1.15rem; color: var(--text-muted); max-width: 560px; margin: 0 0 36px; }
   ```
   (Remove `margin: 0 auto 36px` — centering is handled by parent on mobile via `text-align: center` on the `.hero` wrapper.)

**Exact HTML changes:**

7. Remove the three `<div class="hero-orb ...">` divs inside `.hero-wrapper`.

8. Replace the contents of `<section class="hero">` with:
   ```html
   <div class="hero-left">
     <div class="hero-badge">🤖 AI-Powered · 🇵🇭 Made for Filipinos · Free</div>
     <h1>Smart<span style="color:var(--primary)">Spend</span> —<br/>Your AI Finance<br/>Companion</h1>
     <p>Log expenses by voice, photo, or chat in Taglish or English. Get a real-time Financial Health Score. Works offline.</p>
     <div class="hero-buttons">
       <a class="btn-primary" href="#download">
         <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><path d="M12 16l-5-5h3V4h4v7h3l-5 5zm-7 4v-2h14v2H5z"/></svg>
         Download APK
       </a>
       <a class="btn-secondary" href="https://github.com/Zushikina-kun/smartspend-app" target="_blank" rel="noopener noreferrer">
         <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor"><path d="M12 2C6.48 2 2 6.48 2 12c0 4.42 2.87 8.17 6.84 9.49.5.09.68-.22.68-.48v-1.7c-2.78.6-3.37-1.34-3.37-1.34-.45-1.16-1.11-1.47-1.11-1.47-.91-.62.07-.61.07-.61 1 .07 1.53 1.03 1.53 1.03.89 1.52 2.34 1.08 2.91.83.09-.65.35-1.08.63-1.33-2.22-.25-4.55-1.11-4.55-4.94 0-1.09.39-1.98 1.03-2.68-.1-.25-.45-1.27.1-2.64 0 0 .84-.27 2.75 1.02A9.56 9.56 0 0112 6.8c.85 0 1.71.11 2.51.33 1.91-1.29 2.75-1.02 2.75-1.02.55 1.37.2 2.39.1 2.64.64.7 1.03 1.59 1.03 2.68 0 3.84-2.34 4.68-4.57 4.93.36.31.68.92.68 1.85v2.74c0 .27.18.58.69.48A10.01 10.01 0 0022 12c0-5.52-4.48-10-10-10z"/></svg>
         View on GitHub
       </a>
     </div>
     <div class="hero-meta">🔒 Local AI supported · 🇵🇭 Taglish · 📴 Works offline · v3.0.4 · Free</div>
   </div>
   <div class="hero-right">
     <svg class="peso-mascot" style="--peso-size:120px" aria-label="Peso mascot"><use href="#peso-face"/></svg>
     <img class="hero-app-icon" src="android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" alt="SmartSpend app icon" onerror="this.style.display='none'" />
   </div>
   ```

**Files:** `index.html`

**Verify:** Desktop — two-column hero: text left, mascot + icon right. Mobile (resize to <768px) — stacks vertically, mascot on top. Hero badge is blue-tinted. h1 uses "SmartSpend" with colored "Spend". Hero-meta shows lock/phone/offline icons.

---

## Item 5 — Stats Bar

**What:** Wrap the six `.stat` divs in a single card container. Remove individual stat backgrounds and use a right-border divider instead.

**Exact CSS changes:**

1. Add new rule:
   ```css
   .stats-card {
     background: var(--surface);
     border: 1px solid var(--border);
     border-radius: var(--radius);
     padding: 8px;
     max-width: 900px;
     margin: 0 auto 60px;
   }
   .stats-card .stats {
     margin: 0;
     padding: 0;
   }
   ```

2. Update `.stat` rule — remove `background` and `border`, add right-border divider:
   ```css
   .stat {
     background: transparent;
     border: none;
     border-right: 1px solid var(--border);
     border-radius: 0;
     padding: 20px;
     text-align: center;
     transition: opacity 0.5s ease, transform 0.5s ease;
     opacity: 0;
     transform: translateY(20px);
   }
   .stat:last-child { border-right: none; }
   .stat.visible { opacity: 1; transform: translateY(0); }
   ```

3. Update `.stat-number` to use `font-family: 'Plus Jakarta Sans'`:
   ```css
   .stat-number { font-size: 1.8rem; font-weight: 800; color: var(--primary); font-family: 'Plus Jakarta Sans', sans-serif; }
   ```

**Exact HTML changes:**

4. Wrap the existing `<div class="stats">` block:
   ```html
   <div class="stats-card">
     <div class="stats">
       <!-- existing six .stat divs unchanged -->
     </div>
   </div>
   ```

**Files:** `index.html`

**Verify:** Stats render inside a single rounded card. Numbers are green, font is Plus Jakarta Sans. Thin green border divides columns. Last stat has no right border.

---

## Item 6 — Features Grid

**What:** Update feature card styles. Wrap each feature icon in `.feature-icon-wrap`. Add three new feature cards.

**Exact CSS changes:**

1. Update `.feature-card` rule:
   ```css
   .feature-card {
     background: var(--surface2);
     border: 1px solid var(--border);
     border-radius: var(--radius);
     padding: 22px;
     transition: transform 0.2s, box-shadow 0.2s, background 0.2s, border-color 0.2s, opacity 0.5s ease;
     opacity: 0;
     transform: translateY(20px);
   }
   .feature-card.visible { opacity: 1; transform: translateY(0); }
   .feature-card:hover {
     transform: translateY(-3px);
     background: var(--surface3);
     border-color: var(--border-strong);
     box-shadow: 0 0 24px var(--primary-glow);
   }
   ```

2. Add `.feature-icon-wrap` rule:
   ```css
   .feature-icon-wrap {
     background: var(--primary-glow);
     border-radius: 12px;
     width: 48px;
     height: 48px;
     display: flex;
     align-items: center;
     justify-content: center;
     font-size: 1.5rem;
     margin-bottom: 14px;
   }
   ```

3. Remove (or comment out) the old `.feature-icon` rule — it is replaced by `.feature-icon-wrap`.

**Exact HTML changes:**

4. For every existing `.feature-card`, wrap the `.feature-icon` emoji in the new div:
   Change: `<div class="feature-icon">🏆</div>` 
   To: `<div class="feature-icon-wrap">🏆</div>`
   Do this for all 13 existing cards (the emoji stays the same, only the wrapper class changes).

5. **Add three new feature cards** at the end of `.features-grid`, after the last existing card (`🏵️ Paluwagan Tracker`... wait — the grid actually has 13 cards, and "Local AI — Private Mode" `🔒` is already card #8. Check: yes, it's present. So only add the two missing ones):
   
   Re-reading the spec carefully: the spec says ADD three new cards: Local AI, Full Offline, Smart Export. Looking at the existing HTML, card `🔒 Local AI — Private Mode` already exists but `📴 Full Offline Mode` and `🗂️ Smart Export & Backup` do not. Add those two at the end of `.features-grid`:

   ```html
   <div class="feature-card">
     <div class="feature-icon-wrap">📴</div>
     <div class="feature-title">Full Offline Mode</div>
     <div class="feature-desc">All core features work with zero internet. Log expenses, view analytics, manage budgets, track goals — everything runs on-device. Internet only needed for AI chat and market data.</div>
   </div>
   <div class="feature-card">
     <div class="feature-icon-wrap">🗂️</div>
     <div class="feature-title">Smart Export &amp; Backup</div>
     <div class="feature-desc">Export to CSV, JSON backup, or restore from backup. Full data portability — your data is yours.</div>
   </div>
   ```

   Also update the existing `🔒 Local AI` card text to match the spec exactly:
   ```html
   <div class="feature-card">
     <div class="feature-icon-wrap">🔒</div>
     <div class="feature-title">Local AI — Private Mode</div>
     <div class="feature-desc">Connect to Ollama, LM Studio, or Jan running on your PC. Your financial data never touches a cloud server. Enable "local-only mode" — Peso refuses to fall back to cloud if your server is unreachable.</div>
   </div>
   ```

**Files:** `index.html`

**Verify:** All feature cards visible on scroll. Icon backgrounds are glowing green circles. Hover lifts card with glow. Two new cards (📴 Full Offline, 🗂️ Export) appear at end of grid.

---

## Item 7 — AI / Peso Section Restyle

**What:** Restyle the `#ai` section: new container style, heading with Peso SVG, styled chat bubbles with avatar.

**Exact CSS changes:**

1. Replace `.ai-section` rule:
   ```css
   .ai-section {
     background: var(--surface);
     border-left: 4px solid var(--primary);
     border: 1px solid var(--border);
     border-left: 4px solid var(--primary);
     border-radius: var(--radius);
     max-width: 900px;
     margin: 0 auto 60px;
     padding: 32px;
   }
   ```

2. Add `.ai-heading` rule:
   ```css
   .ai-heading {
     display: flex;
     align-items: center;
     gap: 12px;
     margin-bottom: 10px;
   }
   .ai-heading h2 { font-size: 1.5rem; font-weight: 800; margin: 0; }
   ```

3. Update `.ai-example` rule to add bubble styling:
   ```css
   .ai-example {
     border-radius: 12px 12px 4px 12px;
     padding: 10px 14px;
     font-size: 13px;
     display: flex;
     align-items: flex-start;
     gap: 10px;
     transition: opacity 0.5s ease, transform 0.5s ease;
     opacity: 0;
     transform: translateY(20px);
     cursor: pointer;
     border: 1px solid var(--border);
   }
   .ai-example.visible { opacity: 1; transform: translateY(0); }
   ```

4. Add user/peso bubble variant overrides:
   ```css
   .ai-example.bubble-you {
     background: var(--surface-elevated);
     border: 1px solid var(--border);
     border-radius: 12px 12px 4px 12px;
     margin-left: 8px;
   }
   .ai-example.bubble-peso {
     background: var(--primary-glow);
     border: 1px solid var(--border-strong);
     border-radius: 12px 12px 12px 4px;
     margin-right: 8px;
   }
   .ai-peso-avatar {
     flex-shrink: 0;
     margin-top: 2px;
   }
   ```

**Exact HTML changes:**

5. Replace the `<section class="ai-section" id="ai">` opening content. Change:
   ```html
   <h2>🤖 Meet Peso — Your AI Finance Coach</h2>
   ```
   To:
   ```html
   <div class="ai-heading">
     <svg class="peso-mascot" style="--peso-size:48px" aria-label="Peso mascot"><use href="#peso-face"/></svg>
     <h2>Meet Peso — Your AI Finance Coach</h2>
   </div>
   ```

6. For the "You" chat examples (the 3 `.ai-example` divs with `.you` span), add class `bubble-you`:
   ```html
   <div class="ai-example bubble-you" title="Click to copy">
   ```

7. For the "Peso" response example (the `.ai-example` with `.peso` span), add class `bubble-peso` and prepend the small avatar:
   ```html
   <div class="ai-example bubble-peso">
     <svg class="ai-peso-avatar peso-mascot" style="--peso-size:20px" aria-label="Peso"><use href="#peso-face"/></svg>
     <span class="peso">Peso</span>
     Based on your 6-month trend ...
   </div>
   ```

**Files:** `index.html`

**Verify:** AI section has a green left-border accent. Heading shows Peso SVG mascot (48px) next to the h2. User bubbles are elevated-surface style. Peso reply has small mascot avatar. The existing Peso emoji `🤖` in the demo-peso-mascot div is NOT affected (it's in the demo-lite screen).

---

## Item 8 — New Privacy-AI Section (id="privacy-ai")

**What:** Insert a brand-new section between the `</section>` closing tag of `#ai` and the `<section class="screenshots-section" id="screenshots">` opening tag. This section has two parts: current local-AI features and the on-device roadmap.

**Exact CSS to add** (append to `<style>` before `</style>`):
```css
/* ===== PRIVACY-AI SECTION ===== */
.privacy-ai-section {
  max-width: 900px;
  margin: 0 auto 70px;
  padding: 0 24px;
}
.privacy-ai-section .section-title { margin-bottom: 8px; }
.privacy-ai-section .section-sub { color: var(--text-muted); margin-bottom: 36px; }

.pai-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 32px;
  margin-bottom: 40px;
}
@media (max-width: 700px) { .pai-grid { grid-template-columns: 1fr; } }

.pai-badge {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 700;
  margin-bottom: 16px;
}
.pai-badge-green { background: rgba(0,200,150,0.15); color: var(--primary); border: 1px solid var(--border-strong); }
.pai-badge-blue  { background: rgba(37,99,235,0.12); color: var(--brand-blue); border: 1px solid rgba(37,99,235,0.3); }

.pai-left h3 { font-size: 1.2rem; font-weight: 800; margin-bottom: 8px; font-family: 'Plus Jakarta Sans', sans-serif; }
.pai-left p  { font-size: 13px; color: var(--text-muted); margin-bottom: 20px; line-height: 1.6; }

.pai-points { display: flex; flex-direction: column; gap: 14px; }
.pai-point { display: flex; align-items: flex-start; gap: 10px; }
.pai-point-icon { font-size: 1.2rem; flex-shrink: 0; margin-top: 1px; }
.pai-point-body strong { font-size: 14px; font-weight: 700; display: block; margin-bottom: 3px; }
.pai-point-body span  { font-size: 13px; color: var(--text-muted); line-height: 1.5; }

/* Architecture diagram */
.arch-diagram {
  background: #080f09;
  border: 1px solid rgba(0,200,150,0.25);
  border-radius: 14px;
  padding: 24px 20px;
  font-family: 'Courier New', monospace;
  font-size: 12px;
  color: #8aaa8a;
  line-height: 1.9;
  position: relative;
  overflow: hidden;
}
[data-theme="light"] .arch-diagram {
  background: #1a2e1a;
  color: #8aaa8a;
}
.arch-diagram .arch-box {
  display: inline-block;
  background: rgba(0,200,150,0.08);
  border: 1px solid rgba(0,200,150,0.3);
  border-radius: 6px;
  padding: 4px 10px;
  color: #eef2ee;
  font-weight: 700;
  white-space: nowrap;
}
.arch-diagram .arch-arrow { color: #00C896; }
.arch-diagram .arch-label { font-size: 11px; color: #5a7a5a; }
.arch-diagram .arch-highlight { color: #00C896; font-weight: 700; }

/* Roadmap card */
.roadmap-card {
  background: linear-gradient(135deg, var(--surface2), var(--surface3));
  border: 2px dashed var(--border-strong);
  border-radius: var(--radius);
  padding: 32px;
  margin-top: 8px;
}
.roadmap-card h3 { font-size: 1.2rem; font-weight: 800; margin-bottom: 16px; font-family: 'Plus Jakarta Sans', sans-serif; }
.roadmap-card p  { font-size: 13px; color: var(--text-muted); line-height: 1.7; margin-bottom: 16px; }
.roadmap-card p strong { color: var(--text); }
.roadmap-card ul { padding-left: 20px; margin-bottom: 16px; }
.roadmap-card li { font-size: 13px; color: var(--text-muted); line-height: 1.7; margin-bottom: 4px; }
.roadmap-card li strong { color: var(--text); }
.model-chips { display: flex; flex-wrap: wrap; gap: 8px; margin: 12px 0; }
.model-chip {
  background: rgba(37,99,235,0.1);
  border: 1px solid rgba(37,99,235,0.25);
  color: var(--brand-blue);
  border-radius: 20px;
  padding: 4px 12px;
  font-size: 12px;
  font-weight: 600;
}
.roadmap-note {
  font-size: 11px;
  color: var(--text-dim);
  margin-top: 20px;
  border-top: 1px solid var(--border);
  padding-top: 12px;
}
```

**Exact HTML to insert** (between `</section>` of `#ai` and `<section class="screenshots-section" id="screenshots">`):

```html
<section class="privacy-ai-section" id="privacy-ai">
  <div class="section-title">🔒 Privacy-First AI</div>
  <div class="section-sub">SmartSpend gives you full control over where your financial data goes.</div>

  <!-- Part A: Current -->
  <div class="pai-grid">
    <div class="pai-left">
      <div class="pai-badge pai-badge-green">🔒 Available Now</div>
      <h3>Your Finances, Your Device</h3>
      <p>SmartSpend is the only Filipino finance app with a built-in local AI mode. Connect to a local LLM server on your PC — Peso runs entirely on your hardware.</p>
      <div class="pai-points">
        <div class="pai-point">
          <span class="pai-point-icon">🏠</span>
          <div class="pai-point-body">
            <strong>Runs on your PC</strong>
            <span>Supports Ollama, LM Studio, and Jan. Any OpenAI-compatible endpoint works. Set your base URL, model name, and optional API key.</span>
          </div>
        </div>
        <div class="pai-point">
          <span class="pai-point-icon">🔒</span>
          <div class="pai-point-body">
            <strong>Zero cloud exposure</strong>
            <span>Financial data stays on your local network. No API keys sent to third parties. No training on your data.</span>
          </div>
        </div>
        <div class="pai-point">
          <span class="pai-point-icon">📴</span>
          <div class="pai-point-body">
            <strong>Local-only mode</strong>
            <span>Enable the toggle and Peso will refuse to fall back to cloud models even if your local server is unreachable. You decide.</span>
          </div>
        </div>
      </div>
    </div>
    <div class="pai-right">
      <div class="arch-diagram" role="img" aria-label="Architecture: phone connects via local WiFi to PC running Ollama">
        <div style="margin-bottom:10px;">
          <span class="arch-box">Your Phone</span>
          <span class="arch-arrow"> ──── WiFi ──── </span>
          <span class="arch-box">Your PC</span>
        </div>
        <div class="arch-label" style="padding-left:4px;">SmartSpend</div>
        <div class="arch-label" style="padding-left:4px;">Peso chat</div>
        <div style="margin:10px 0;padding-left:4px;">
          <span class="arch-arrow">↓ sends question</span>
        </div>
        <div style="margin-bottom:6px;">
          <span class="arch-highlight">Ollama / LM Studio / Jan</span>
        </div>
        <div class="arch-label">Llama 3.2 · Qwen3 · Phi-4 · any model</div>
        <div style="margin:10px 0;border-top:1px dashed rgba(0,200,150,0.3);padding-top:10px;">
          <span class="arch-highlight">Your financial data never leaves this network.</span>
        </div>
      </div>
    </div>
  </div>

  <!-- Part B: Roadmap -->
  <div class="roadmap-card">
    <div class="pai-badge pai-badge-blue" style="margin-bottom:20px;">🚀 On the Roadmap</div>
    <h3>The Next Step: AI That Lives on Your Phone</h3>
    <p>On-device LLM inference on Android has crossed a meaningful threshold in 2026. Flagship phones with Snapdragon 8 Gen 5 and Tensor G6 chips deliver 45–60 TOPS of NPU performance — enough to run 1B–4B parameter models at 20–50 tokens per second, faster than most people read.</p>
    <p><strong>What this means for SmartSpend:</strong><br/>We're actively researching full on-device AI for a future release. When stable enough for financial use, Peso would run entirely on your phone — no PC, no WiFi, no server.</p>
    <p><strong>Candidate models we're evaluating:</strong></p>
    <div class="model-chips">
      <span class="model-chip">Gemma 3 1B/4B</span>
      <span class="model-chip">Phi-4 Mini (3.8B)</span>
      <span class="model-chip">Qwen 3 1.7B</span>
    </div>
    <ul>
      <li><strong>Gemma 3 1B/4B</strong> (Google) — runs at 30–40 tok/s on mid-range devices, multilingual including Filipino</li>
      <li><strong>Phi-4 Mini</strong> (Microsoft, 3.8B) — ~3 GB at Q4 quantization, strong reasoning for its size</li>
      <li><strong>Qwen 3 1.7B</strong> — fast, compact, good at structured financial tasks</li>
    </ul>
    <p><strong>What we're waiting for:</strong><br/>The bottleneck isn't hardware — it's reliability. Financial AI needs to be accurate on peso amounts, dates, and categories every time, not 90% of the time. We're monitoring llama.cpp, MediaPipe, and MLC-LLM maturation on Android before committing to a release date.</p>
    <p><strong>What it would mean for you:</strong><br/>Zero cloud dependency. Zero API costs. Peso answers your budget questions even on airplane mode. Your entire financial life — conversations, analysis, advice — processed entirely on the glass in your pocket.</p>
    <div class="roadmap-note">* On-device AI availability depends on device hardware and model stability. Mid-range devices (6 GB+ RAM) are the target minimum.</div>
  </div>
</section>
```

**Files:** `index.html`

**Verify:**
```powershell
Select-String -Path "c:\xampp\htdocs\smartspend_app\index.html" -Pattern "privacy-ai" | Measure-Object | Select-Object Count
# expect 3+ (section id, nav link, mobile link)
Select-String -Path "c:\xampp\htdocs\smartspend_app\index.html" -Pattern "on-device|roadmap|Gemma|Phi-4|Qwen" | Measure-Object | Select-Object Count
# expect 5+
```
Section renders with green/blue badge pills, architecture diagram in terminal style, roadmap dashed-border card.

---

## Item 9 — About / Team Section Replacement

**What:** Replace the existing `<div class="about-section" id="about">` entirely with a new two-column layout: project description cards left, developer photo cards right, and institution row below.

**Exact CSS changes** (replace/add in `<style>`):

1. Replace `.about-section` rule:
   ```css
   .about-section {
     max-width: 900px;
     margin: 0 auto 60px;
     padding: 0 24px;
   }
   ```

2. Add new rules:
   ```css
   .about-grid {
     display: grid;
     grid-template-columns: 1fr 1fr;
     gap: 24px;
     margin-bottom: 32px;
   }
   @media (max-width: 700px) { .about-grid { grid-template-columns: 1fr; } }

   .dev-cards { display: flex; flex-direction: column; gap: 16px; }
   .dev-card {
     background: var(--surface2);
     border: 1px solid var(--border);
     border-radius: var(--radius);
     padding: 16px 20px;
     display: flex;
     align-items: center;
     gap: 16px;
     transition: background 0.2s, border-color 0.2s, opacity 0.5s ease, transform 0.5s ease;
     opacity: 0;
     transform: translateY(20px);
   }
   .dev-card.visible { opacity: 1; transform: translateY(0); }
   .dev-card:hover { background: var(--surface3); border-color: var(--border-strong); }
   .dev-photo {
     width: 72px;
     height: 72px;
     border-radius: 50%;
     object-fit: cover;
     border: 2px solid var(--primary);
     flex-shrink: 0;
   }
   .dev-name { font-weight: 700; font-size: 14px; color: var(--text); font-family: 'Plus Jakarta Sans', sans-serif; }
   .dev-role { font-size: 12px; color: var(--text-muted); margin-top: 3px; }

   .institution-row {
     display: flex;
     align-items: center;
     gap: 20px;
     flex-wrap: wrap;
     background: var(--surface);
     border: 1px solid var(--border);
     border-radius: var(--radius);
     padding: 20px 24px;
   }
   .institution-row img { display: block; opacity: 0.9; }
   .institution-text { font-size: 13px; color: var(--text-muted); line-height: 1.6; }
   .institution-text strong { color: var(--text); }
   ```

**Exact HTML changes:**

3. Replace the entire `<div class="about-section" id="about">` block (everything from `<div class="about-section"` to its closing `</div>`) with:
   ```html
   <div class="about-section" id="about">
     <div class="section-title" style="padding:0 24px;margin-bottom:8px;">About the Project</div>
     <div class="section-sub" style="padding:0 24px;margin-bottom:28px;">Built by students, for Filipinos.</div>
     <div class="about-grid">
       <!-- Left: project info cards -->
       <div style="display:flex;flex-direction:column;gap:16px;">
         <div class="about-card" style="background:var(--surface2);">
           <h3>About SmartSpend</h3>
           <p>A capstone thesis project by <strong>LucidFrame</strong> at <strong>Lorma Colleges, CCSE</strong> — Bachelor of Science in Information Technology, 4th Year, AY 2026–2027.</p>
           <br/>
           <p>Free, open-source, and built specifically for Filipino spending habits, income cycles, and financial products. No account required. Works offline. MIT Non-Commercial License.</p>
         </div>
         <div class="about-card" style="background:var(--surface2);">
           <h3>Technical Highlights</h3>
           <ul>
             <li>Flutter / Dart — Android API 21–36</li>
             <li>SQLite local database (v14, 26 tables)</li>
             <li>Firebase Auth, Firestore, Remote Config, Crashlytics</li>
             <li>Gemini 3.5 Flash-Lite as primary AI</li>
             <li>9-provider AI fallback chain</li>
             <li>Local LLM: Ollama / LM Studio / Jan support</li>
             <li>Fully offline core features</li>
             <li><a href="https://github.com/Zushikina-kun/smartspend-app" target="_blank" rel="noopener noreferrer">Open source — MIT Non-Commercial</a></li>
           </ul>
         </div>
       </div>
       <!-- Right: developer cards -->
       <div class="dev-cards">
         <div class="dev-card">
           <img class="dev-photo" src="assets/Devs/BRIX A. DIRECTO.png" alt="Brix A. Directo" onerror="this.src='data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 width=%2272%22 height=%2272%22><circle cx=%2236%22 cy=%2236%22 r=%2236%22 fill=%22%232D9E6B%22/><text x=%2236%22 y=%2242%22 text-anchor=%22middle%22 fill=%22white%22 font-size=%2224%22>B</text></svg>'" />
           <div>
             <div class="dev-name">BRIX A. DIRECTO</div>
             <div class="dev-role">Developer · Lead</div>
           </div>
         </div>
         <div class="dev-card">
           <img class="dev-photo" src="assets/Devs/CYRILLE JOHN M. RUBIS.png" alt="Cyrille John M. Rubis" onerror="this.src='data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 width=%2272%22 height=%2272%22><circle cx=%2236%22 cy=%2236%22 r=%2236%22 fill=%22%232D9E6B%22/><text x=%2236%22 y=%2242%22 text-anchor=%22middle%22 fill=%22white%22 font-size=%2224%22>C</text></svg>'" />
           <div>
             <div class="dev-name">CYRILLE JOHN M. RUBIS</div>
             <div class="dev-role">Developer · UI/UX &amp; Documentation</div>
           </div>
         </div>
         <div class="dev-card">
           <img class="dev-photo" src="assets/Devs/DJAUNATHAN ALBERT S. MADAYAG.png" alt="Djaunathan Albert S. Madayag" onerror="this.src='data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 width=%2272%22 height=%2272%22><circle cx=%2236%22 cy=%2236%22 r=%2236%22 fill=%22%232D9E6B%22/><text x=%2236%22 y=%2242%22 text-anchor=%22middle%22 fill=%22white%22 font-size=%2224%22>D</text></svg>'" />
           <div>
             <div class="dev-name">DJAUNATHAN ALBERT S. MADAYAG</div>
             <div class="dev-role">Developer · Project Manager &amp; QA</div>
           </div>
         </div>
       </div>
     </div>
     <!-- Institution row -->
     <div class="institution-row">
       <img src="assets/LucidFrameLogo.png" alt="LucidFrame logo" style="width:120px;" onerror="this.style.display='none'" />
       <img src="assets/LormaLogo.jpg" alt="Lorma Colleges logo" style="width:80px;" onerror="this.style.display='none'" />
       <div class="institution-text">
         Advised by <strong>Ellen F. Mangaoang, MIT</strong> · Lorma Colleges · Capstone Project 2026<br/>
         Panel: <strong>Shekiro R. Raposas</strong> · <strong>Mary-Ann Mzana</strong>
       </div>
     </div>
   </div>
   ```

4. Update the `IntersectionObserver` call that observes `.about-card` — add `.dev-card` to the selector list:
   ```js
   document.querySelectorAll('.feature-card, .stat, .about-card, .dev-card, .ai-example, .modality-chip').forEach(function(el, i) {
   ```

**Files:** `index.html`

**Verify:**
```powershell
Select-String -Path "c:\xampp\htdocs\smartspend_app\index.html" -Pattern "BRIX|LucidFrame" | Measure-Object | Select-Object Count
# expect 2+
```
Dev photos show as circular 72px images with green border. LucidFrame and Lorma logos visible. Institution text row below the grid.

---

## Item 10 — Footer

**What:** Replace footer contents with the new layout: Peso SVG + brand name, LucidFrame logo, expanded link list, updated copyright.

**Exact CSS changes** (add to `<style>`):
```css
.footer-brand {
  display: flex;
  align-items: center;
  gap: 10px;
  justify-content: center;
  margin-bottom: 20px;
  flex-wrap: wrap;
}
.footer-brand-name { font-weight: 800; font-size: 16px; font-family: 'Plus Jakarta Sans', sans-serif; color: var(--text); }
.footer-lucidframe {
  display: flex;
  align-items: center;
  gap: 8px;
  justify-content: center;
  margin-bottom: 16px;
  font-size: 12px;
  color: var(--text-muted);
}
```

**Exact HTML changes:**

Replace the entire `<footer>` block (from `<footer>` to `</footer>`) with:
```html
<footer>
  <div class="footer-brand">
    <svg class="peso-mascot" style="--peso-size:32px" aria-label="Peso"><use href="#peso-face"/></svg>
    <span class="footer-brand-name">SmartSpend</span>
  </div>
  <div class="footer-lucidframe">
    <img src="assets/LucidFrameLogo.png" alt="LucidFrame" style="width:60px;opacity:0.8;" onerror="this.style.display='none'" />
    <span>Built by LucidFrame</span>
  </div>
  <div class="footer-links">
    <a href="#features">Features</a>
    <a href="#ai">AI</a>
    <a href="#privacy-ai">Privacy</a>
    <a href="#screenshots">Screenshots</a>
    <a href="#download">Download</a>
    <a href="#about">About</a>
    <a href="https://github.com/Zushikina-kun/smartspend-app" target="_blank" rel="noopener noreferrer">GitHub</a>
    <a href="privacy.html">Privacy Policy</a>
  </div>
  <div class="footer-support">
    <a href="https://buymeacoffee.com/zushikina_kuroh143" target="_blank" rel="noopener noreferrer" style="background:#FFDD00;color:#000;font-weight:700;font-size:13px;padding:8px 16px;border-radius:8px;text-decoration:none;display:inline-flex;align-items:center;gap:6px;">&#x2615; Buy Me a Coffee</a>
    <a href="https://ko-fi.com/zushikina143" target="_blank" rel="noopener noreferrer" style="background:#29ABE0;color:#fff;font-weight:700;font-size:13px;padding:8px 16px;border-radius:8px;text-decoration:none;display:inline-flex;align-items:center;gap:6px;">&#x1F375; Ko-fi</a>
    <a href="https://paypal.me/BrixDirecto" target="_blank" rel="noopener noreferrer" style="background:#003087;color:#fff;font-weight:700;font-size:13px;padding:8px 16px;border-radius:8px;text-decoration:none;display:inline-flex;align-items:center;gap:6px;">&#x1F17F;&#xFE0F; PayPal</a>
    <span style="background:rgba(255,255,255,0.08);color:#9099b2;font-size:13px;padding:8px 16px;border-radius:8px;display:inline-flex;align-items:center;gap:6px;border:1px solid rgba(255,255,255,0.1);">&#x1F4F1; GCash / PayMaya: <strong style="color:#fff;">09953583040</strong></span>
  </div>
  <p style="font-size:12px;color:var(--text-dim);margin-bottom:8px;">SmartSpend is free and open-source. If it helped you, any support keeps it alive. 🙏</p>
  <p style="font-size:12px;color:var(--text-dim);">© 2026 LucidFrame. SmartSpend is a free, open-source capstone project.</p>
  <p style="margin-top:6px;font-size:12px;color:var(--text-dim);">SmartSpend is a capstone research project. Not affiliated with any financial institution.</p>
</footer>
```

**Files:** `index.html`

**Verify:** Footer shows Peso SVG (32px), SmartSpend name, LucidFrame logo, 8 links, support buttons, and "© 2026 LucidFrame" copyright. Scrollbar (if visible) uses green thumb.

---

## Item 11 — Demo Lite Section Restyle

**What:** Minor updates to the demo section heading and note. Do NOT change any demo JS or any demo screen HTML.

**Exact HTML changes only:**

1. Replace the demo section title+sub:
   ```html
   <!-- OLD -->
   <div class="section-title">📱 Try it — Interactive Demo</div>
   <div class="section-sub">A simplified prototype. Not connected to real data.</div>
   ```
   With:
   ```html
   <div class="section-title" style="display:flex;align-items:center;gap:10px;">
     <svg class="peso-mascot" style="--peso-size:40px" aria-label="Peso"><use href="#peso-face"/></svg>
     Try it — Interactive Demo
   </div>
   <div class="section-sub">A simplified prototype. Not connected to real data. The real app supports light mode too — this demo runs dark like the app default.</div>
   ```

2. The `demo-phone-frame` inner CSS rule `background:#0f1a0f` — update the existing inline `background:#0f1117` inside `.demo-screen`:
   In the CSS, find `.demo-screen { ... background:#0f1117; ... }` and `.demo-phone-frame { ... background:#0f1117; ... }` — change both to `background:#0f1a0f`.
   
   Also update the matching `.demo-screens { ... background:#0f1117; }` rule to `background:#0f1a0f`.

**Files:** `index.html`

**Verify:** Demo section heading shows Peso mascot SVG (40px) to the left of "Try it". Note about light mode appears below. Phone frame interior stays dark. All demo tabs still work.

---

## Item 12 — Verification Commands

Run these in order after completing all items:

```powershell
# 1. Spot-check key new content
Select-String -Path "c:\xampp\htdocs\smartspend_app\index.html" -Pattern "0d1a0f|peso-mascot|brand-blue|Plus Jakarta|privacy-ai|LucidFrame|BRIX|on-device|roadmap"
# All 9 patterns must match at least once

# 2. Carousel slides must still be exactly 23
Select-String -Path "c:\xampp\htdocs\smartspend_app\index.html" -Pattern "Kiro_Ready" | Measure-Object | Select-Object Count
# Count must be exactly 23

# 3. Swiper CDN still present
Select-String -Path "c:\xampp\htdocs\smartspend_app\index.html" -Pattern "cdn.jsdelivr.net/npm/swiper" | Measure-Object | Select-Object Count
# Count must be exactly 2 (CSS link + JS script)

# 4. Critical JS functions still present
Select-String -Path "c:\xampp\htdocs\smartspend_app\index.html" -Pattern "function openLightbox|function demoGetReply|function filterSlides|function demoTab|function demoTypewriter" | Measure-Object | Select-Object Count
# Count must be exactly 5

# 5. No unclosed tags — parse check (requires Node.js or Python)
# If Node available:
# node -e "require('fs').readFileSync('c:/xampp/htdocs/smartspend_app/index.html','utf8'); console.log('Parsed OK')"
# If Python available:
# python -c "from html.parser import HTMLParser; p=HTMLParser(); p.feed(open('c:/xampp/htdocs/smartspend_app/index.html').read()); print('Parsed OK')"
```

---

## Item 13 — Git Commit and Push

Run after all verification passes:

```powershell
git -C "c:\xampp\htdocs\smartspend_app" add index.html
git -C "c:\xampp\htdocs\smartspend_app" commit -m "redesign: authentic app theming, Peso SVG mascot, local AI section, on-device roadmap, team credits"
git -C "c:\xampp\htdocs\smartspend_app" push origin master
```

If `master` branch is not the default, check with `git -C "c:\xampp\htdocs\smartspend_app" branch` first and push to the correct branch name.

---

## Summary of what changes vs what stays

| Area | Status |
|---|---|
| CSS variables (`:root` + `[data-theme="light"]`) | ✅ Full replacement |
| Google Fonts import | ✅ Added |
| Heading font-family | ✅ Added |
| Body font-family | ✅ Updated |
| Scrollbar styles | ✅ Added |
| Nav background/blur/brand/CTA/Privacy link | ✅ Updated |
| Hero: orb divs + floatOrb removed | ✅ Removed |
| Hero: two-column flex layout | ✅ New |
| Hero: badge blue, h1 SmartSpend colored, meta icons | ✅ Updated |
| Hero: Peso SVG 120px + app icon | ✅ Added |
| Stats: single card wrapper + divider borders | ✅ Updated |
| Features: surface2 bg, hover glow, icon-wrap | ✅ Updated |
| Features: 2 new cards (📴, 🗂️) | ✅ Added |
| AI section: border-left accent, Peso heading, bubble styles | ✅ Updated |
| Privacy-AI section (new `id="privacy-ai"`) | ✅ New section |
| About section: dev photo cards + institution row | ✅ Full replacement |
| Footer: Peso SVG, LucidFrame logo, expanded links, new copyright | ✅ Full replacement |
| Demo section: heading with Peso SVG, note, dark bg color fix | ✅ Minor updates |
| All 23 carousel slides | 🔒 Preserved verbatim |
| Swiper CDN links | 🔒 Preserved verbatim |
| Lightbox JS | 🔒 Preserved verbatim |
| Demo Lite JS | 🔒 Preserved verbatim |
| filterSlides / IntersectionObserver / theme toggle / hamburger / backToTop | 🔒 Preserved verbatim |
