# Demo Lite interactive section added to SmartSpend landing page

A self-contained interactive demo was inserted between the screenshots section and the download CTA. It renders a mock phone frame with five navigable screens (Home, Peso chat, Analytics, Goals, Log Expense), each powered by purely client-side JS with no network calls. The intent is to let a first-time visitor experience the app's personality before downloading. All new code lives under the `.demo-` CSS namespace; no existing selectors were modified.

**Watch for:** The demo phone frame renders with hardcoded dark-mode colors regardless of the page's active theme — a visitor browsing in light mode will see a jarring dark island (confirmed). The description field in the Log screen is wired to no JS handler (possible usability confusion, low severity).

**Verdict**: APPROVED

---

## High-level view

The demo phone frame uses hardcoded dark background colors (`#0f1117`, `#1a1d27`, `#f0f0f4`) rather than the page's CSS custom properties. When the page switches to light mode, the rest of the page goes pale while the phone frame stays dark. There is no `[data-theme="light"]` override for any `.demo-*` rule, and no copy in the section heading to indicate this is intentional.

The Log screen's description `<input>` has no `id` and is never read by the submit handler. A user who types a description gets no feedback that it won't appear in the success toast or the injected transaction row.

The Peso keyword matcher uses substring matching without word boundaries. A message containing "somehow" fires the "how are you doing" reply. With only five canned responses and an honest fallback, the practical impact is low, but it's worth knowing the match can misfire.

---

<details>
<summary>Issues (3)</summary>

1. **Demo hardcoded dark theme in light mode** — All `.demo-*` color values are hardcoded dark hex constants with no `[data-theme="light"]` overrides. Visitors who switch to light mode see a dark phone island with no surrounding context. Add a `[data-theme="light"] .demo-wrapper` background adjustment, or add copy to the section header clarifying this is always a dark-mode preview.

2. **Description field silently ignored** — The `<input class="demo-desc-input">` has no `id` and is never read by the submit handler. A user who types a description and submits sees it silently dropped. Either wire it into the toast message or add `placeholder="(not used in demo)"` to set expectations.

3. **Keyword substring misfires in Peso chat** — `demoGetReply` matches keys like `'how'`, `'track'`, `'doing'` anywhere in the lowercased message string. "Somehow" triggers the monthly-summary reply; "backtrack" triggers the budget-check reply. Low-stakes given the fallback is honest, but easy to fix by anchoring keys with word boundaries or switching to exact-phrase matching.

</details>

---

<details>
<summary>Details</summary>

### Demo phone frame dark-mode isolation

The phone frame and all five screen `div`s set their background explicitly to `#0f1117` and text to `#f0f0f4`. These are inlined as literals, not as `var(--bg)`. When `[data-theme="light"]` is applied to `<html>`, the root `--bg` switches to `#f8f9fa` but the demo screens stay `#0f1117`. Every color property in `.demo-phone-frame`, `.demo-screens`, and `.demo-screen` (CSS lines 210–250) is a hardcoded hex, with no `[data-theme="light"] .demo-*` selector anywhere in the file.

The section heading says "Try it live" with no qualifier about the preview always showing dark mode, so a light-mode visitor will experience it as a rendering bug rather than intentional framing.

### Description field wired to nothing

Line 1018 adds `<input class="demo-desc-input" type="text" placeholder="Description (optional)" />` with no `id`. The submit handler (line 1486) reads `demo-amount-input`, `.demo-cat-pill.selected`, and `demo-wallet-select`, but has no reference to this field. The success toast (line 1506) and the injected transaction row (line 1514) both omit it. The shake-on-empty validation only guards the amount field. A user filling in a description gets no indication it will be ignored.

### Keyword matching boundary gap in Peso chat

`demoGetReply` uses `lower.indexOf(r.keys[j]) !== -1` against keys like `['how','doing','month']`. The match fires if any key appears as a substring anywhere in the message. "Somehow" contains "how", "backtrack" contains "track", "budgeting" contains "budget". For a demo with five responses and a self-disclosing fallback the damage is minimal — the wrong canned answer is still plausible — but adding `.includes(` word-boundary checks or switching keys to phrases would eliminate the ambiguity entirely.

</details>

---

<details>
<summary>File map</summary>

- `index.html` — sole file changed; added ~430 lines covering `.demo-*` CSS (lines 208–635), `<section id="demo">` HTML (lines 816–1045), demo JS functions (lines 1339–1535), and nav links in both `.nav-links` and `.mobile-menu`.

Full diff: `git diff HEAD~1 -- index.html`

</details>
