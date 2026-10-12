# Kiro → Kiro Handoff — Website Overhaul — October 12, 2026

**Session type:** Vibe (conversational + implementation)
**Covers:** Everything done to `index.html` (the SmartSpend GitHub Pages landing page) in this session.
**Purpose:** Document what changed, what was fixed, what app improvements were identified, and what needs follow-up.

---

## 1. Summary of What Was Built

The SmartSpend landing page (`index.html`, now **149.8 KB**) was rebuilt from a generic dark-theme SaaS template into a properly branded, content-rich product page that actually represents the app.

**Live at:** https://zushikina-kun.github.io/smartspend-app/

### Commit history this session (oldest → newest)
| Commit | Description |
|--------|-------------|
| `32b1be6` | Replace all 109 UUID screenshot filenames with labeled names, update carousel (23 slides, correct descriptions) |
| `fa40778` | Remove demo lite section (deferred at the time) |
| `a71267b` | Major redesign: dark/light toggle, lightbox, hamburger nav, back-to-top, scroll animations, mobile nav |
| `eb9826d` | Fix lbOpen/lbClose alias functions |
| `3e488ad` | Full visual identity redesign: forest green theme, Peso SVG mascot, brand colors, team section |
| `0373c88` | Fix demo lite reviewer findings (desc input id, keyword matcher) |
| `fa40778` | Authentic app theming pass 2 |
| `7311e7e` | Add What is SmartSpend, How it Works, FAQ sections |
| `6a7b81d` | Add Research & Surveys section with Google Forms links |
| `23ca292` | Fix logos: LucidFrame wrapper, Lorma wrapper, Peso SVG rebuild, footer brand |
| `211cb4f` | Fix FAQ accordion (was completely broken), survey prominence, nav cleanup |
| `12d8088` | Dynamic canvas background, changelog, share strip, scroll animations, SEO, download UX |

---

## 2. All Features Added/Fixed

### Visual Identity
- **Color system:** Dark mode is now `#0d1a0f` (forest green) not generic `#0f1117` gray. Light mode is `#f4f0e6` (warm parchment) not pure white — matches actual app screenshots
- **Typography:** Plus Jakarta Sans (headings) + Inter (body) — matches app's rounded modern feel
- **Brand blue `#2563EB`:** Used for nav brand name, hero badge, survey CTA — echoes the splash screen's vibrant blue
- **Peso SVG mascot:** Rebuilt from scratch as inline SVG — round green body with radial gradient, large expressive eyes with dual shine, arms raised at 45° upward, cheek blush, wide smile. Used in 5 places: hero (120px), AI section (48px), AI bubble avatar (20px), demo section (40px), nav brand (tiny)
- **App icon:** Shown prominently in hero (96px, tilted -3°) and nav. Footer brand now uses app icon + "SmartSpend" in brand blue (not the Peso SVG blob)
- **LucidFrame logo:** Wrapped in dark navy pill (visible in both themes)
- **Lorma logo:** Wrapped in white pill with shadow (JPEG white bg now intentional-looking)

### New Sections
1. **"What is SmartSpend?"** — Problem/Solution two-column, target audience pills (Students · Young Professionals · Freelancers · Household Managers)
2. **"How it works"** — 3-step numbered cards (Download → Log → Understand)
3. **"Privacy-First AI"** — Two parts: Current (Ollama/LM Studio/Jan on PC) + Roadmap (on-device inference)
4. **Research & Surveys** — Prominent section with banner, quick-link buttons to both Google Forms
5. **FAQ** — 10 accordion questions (fixed: was completely broken, toggleFaq() was never defined)
6. **Changelog** — v3.0.4 + v3.0.0 release notes, color-coded ✨/🔧/🐛
7. **Share strip** — Facebook, Twitter/X, copy-link above footer

### Interactive Features
- **Screenshot lightbox:** Click any phone frame → full-screen zoom, prev/next arrows, ESC to close, keyboard navigation, shows caption
- **Interactive Demo Lite:** 5-screen phone prototype (Home, Peso AI chat, Analytics donut, Goals progress, Log Expense) — uses real data from CSV backup. Peso chat has token-aware keyword matching
- **Dark/light mode toggle:** Persisted in localStorage, smooth CSS transitions, theme-color meta tag updates
- **Mobile hamburger nav:** Slide-down menu for mobile
- **Animated canvas background:** 60 floating ₱ peso signs + sparkles rising slowly, color-adapts to theme
- **Scroll fade-in animations:** Feature/step/team/research cards fade in with staggered delays
- **Stats count-up:** Numbers animate when scrolled into view
- **Active nav link tracking:** IntersectionObserver highlights current section in nav
- **Back-to-top button:** Appears after scrolling 300px
- **FAQ accordion:** Click to expand, closes others, smooth scroll into view
- **AI example click-to-copy:** Click any "You" bubble to copy the text
- **Share strip copy-link:** Clipboard API with fallback

### Content Added
- Hero survey banner (calls out capstone research need)
- Nav CTA changed to "🎓 Take Survey" with pulse animation
- Research section with big "📣 We need respondents!" gradient banner + both survey quick-links
- After-install 3-step guide in Download section
- System requirements (Android 5.0+, ~45MB, no account, offline)
- On-device AI roadmap (Gemma 3 1B/4B, Phi-4 Mini 3.8B, Qwen 3 1.7B, 20-50 tok/s on flagships)
- Team section: circular dev photos (Brix, Cyrille, Djaunathan) with roles
- Institution row: LucidFrame + Lorma logos + adviser credits (Ellen F. Mangaoang, MIT) + panel (Shekiro R. Raposas, Mary-Ann Mzana)

### Technical/SEO
- `<meta name="keywords">` — Filipino finance app terms
- `<meta name="author">`, `robots`, `og:type`, `og:site_name`
- `twitter:card`, `twitter:title`, `twitter:description`
- All external links: `rel="noopener noreferrer"`
- `aria-label` on all icon-only buttons
- Section dividers between every major section
- navSections updated to track all 11 sections

### Bugs Fixed
- **FAQ accordion broken** — `toggleFaq()` was called in HTML but never defined anywhere in JS
- **navSections incomplete** — only tracked 7 of 11 sections, active nav highlighting skipped new sections
- **Duplicate "About" in mobile nav** — two links labeled "About" pointing to different anchors
- **Footer brand using Peso SVG** — should use actual app icon
- **Duplicate footer links** — About, How it Works, Research each appeared twice from regex operations
- **LucidFrame logo invisible in light mode** — white logo on white/cream background
- **Lorma logo white background bleeding** — JPEG with white bg looked broken on dark mode
- **Peso SVG too rough** — old SVG was a basic blob not resembling the app mascot at all

---

## 3. Google Forms (Surveys) — Important for Capstone

Both surveys are linked prominently throughout the site:

| Survey | URL | Purpose | Time |
|--------|-----|---------|------|
| SUS Usability Evaluation | `https://docs.google.com/forms/d/e/1FAIpQLScs24mLCXnSpCZnqDJt46wSWXQUsxhgu0GBkMAlYcOo8oAf2g/viewform` | System Usability Scale — rate app experience 1-5 | ~2 min |
| Financial Management Practices | `https://docs.google.com/forms/d/e/1FAIpQLSfuDVpOSzTCQ8ICl-FGDjZ9a7iGPpKsh51xxAJ6ajesM36DXQ/viewform` | Research survey on Filipino financial habits | ~3-5 min |

**Where they appear on the page:**
1. Nav CTA button ("🎓 Take Survey")
2. Hero survey banner
3. Research section banner (prominent, with quick-link buttons)
4. Research section full cards
5. Mobile nav link

---

## 4. App Improvements Identified From This Session

These are things noticed while building the website that could improve the app itself:

### 4a. 🔴 Privacy disclosure gap (carry-over from Oct 10 handoff)
The website's Privacy-First AI section explicitly states: *"When you use AI chat, the conversation text (not your full expense history) is sent to an AI provider."* This is accurate — but the **app's own onboarding/consent flow** doesn't say this clearly. The website is now more transparent than the app about what data is sent where.

**Action:** Add a one-time disclosure on first Peso chat use: "Your message will be sent to [provider] to generate a response. No expense history is shared. [Switch to Local AI]"

### 4b. 🟡 The website FAQ is better than the app's onboarding
The FAQ covers: what FHS is, how Local AI works, how to import GCash, what the 7 input methods are. The app's onboarding flow doesn't cover most of this. Users who read the website FAQ before downloading will be more prepared than users who just install.

**Action:** Add an optional "Quick Tips" screen after first launch that mirrors the top 3-4 FAQ items (FHS explanation, GCash import, Peso input methods).

### 4c. 🟡 On-device AI roadmap — website commits to specific models
The website now publicly says we're evaluating **Gemma 3 1B/4B, Phi-4 Mini (3.8B), Qwen 3 1.7B** for on-device inference. This sets a public expectation. When/if implemented:
- Use **MediaPipe LLM Inference API** or **llama.cpp Android** as the runtime
- Target minimum: 6GB RAM Android device
- Accuracy gate before shipping: financial NLP must handle peso amounts, dates, categories correctly ≥95% of test cases

**Not a committed feature** — website correctly frames it as "on the roadmap" and "waiting for stability."

### 4d. 🟡 Demo Lite uses slightly different data than app
The interactive demo uses data from the Oct 10 CSV backup. If the app's demo mode data changes, the website demo won't match. Not critical but worth noting.

### 4e. 🟢 Changelog section reveals missing in-app version notes
The changelog on the website documents v3.0.4 and v3.0.0. The app currently has no in-app "What's New" screen.

**Action (low priority):** Add a "What's New" bottom sheet shown once after an update. Can be dismissed.

### 4f. 🟢 3 new feature cards added to website not prominently featured in app
- **Full Offline Mode** — the app works offline but never tells the user this explicitly. Add an offline indicator badge to the home screen (green dot when offline, not just when online).
- **Smart Export & Backup** — the export feature exists but is buried in Profile. Consider adding it to Quick Access grid or Tools hub.

---

## 5. Website Maintenance Notes

### Image paths (all relative from `index.html`)
- Screenshots: `docs/tools/image_converter/Kiro_Ready/<labeled-name>.jpg` (23 slides)
- App icon: `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`
- Dev photos: `assets/Devs/BRIX A. DIRECTO.png`, `CYRILLE JOHN M. RUBIS.png`, `DJAUNATHAN ALBERT S. MADAYAG.png`
- LucidFrame logo: `assets/LucidFrameLogo.png` (white PNG — needs dark wrapper)
- Lorma logo: `assets/LormaLogo.jpg` (white bg JPEG — needs white pill wrapper)
- SmartSpend logo/icon: same as app icon above

### To update the app version number on the website
Search `index.html` for `v3.0.4` — appears in: hero meta, download table, APK download URLs, changelog header, version note. Update all at once.

### To add a new screenshot to the carousel
1. Add the labeled `.jpg` to `docs/tools/image_converter/Kiro_Ready/`
2. Add a new `<div class="swiper-slide" data-tag="[core|ai|ph|tools|gamify]">` block in the `#screenshotsWrapper` div
3. The lightbox auto-discovers all slides via `buildLbSlides()` — no JS changes needed

### To add a new FAQ item
Add inside `<div class="faq-grid">`:
```html
<div class="faq-item">
  <button class="faq-q" onclick="toggleFaq(this)" aria-expanded="false">
    Your question here <span class="faq-arrow">▾</span>
  </button>
  <div class="faq-a">
    <p>Answer here.</p>
  </div>
</div>
```

### To update the surveys
The survey URLs are in 4 places in the HTML. Search for `FAIpQLScs24mL` (SUS) and `FAIpQLSfuDVpO` (research survey) to find all instances.

---

## 6. What the Next Kiro Session Should Do

**Website (low priority, cosmetic):**
- [ ] Consider adding a "Powered by Flutter" + "Open Source" badge row to the hero or download section
- [ ] The demo lite Peso chat suggestions chips could reflect more real app prompts
- [ ] Consider a proper `sitemap.xml` for the GitHub Pages site

**App (from discoveries this session):**
- [ ] Privacy disclosure on first Peso AI chat (Section 4a above) — **medium priority**
- [ ] Quick Tips screen after first launch (Section 4b) — **low priority**
- [ ] In-app "What's New" sheet after update (Section 4e) — **low priority**
- [ ] Offline mode indicator on home screen (Section 4f) — **low priority**

**Docs:**
- [ ] Update `smartspend-capstone-verification-report.md` to note the website is now live and properly representing the app
- [ ] Update thesis Chapter 4 (Results) to mention the landing page and demo lite as part of the deployment deliverables

---

*Compiled by Kiro — October 12, 2026*
*Session: Vibe — Website redesign, content, and improvements*
