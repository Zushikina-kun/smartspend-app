# SmartSpend Website Redesign

This commit redesigns `index.html` to align the marketing site with the app's authentic dark-green theme: new CSS variables, a Peso SVG mascot sprite, an on-device AI section with model roadmap, dev photo cards, a footer rebrand, and updated demo section colors. The change is 66 insertions / 52 deletions — almost all cosmetic and structural HTML/CSS, with one JS change to extend the IntersectionObserver to cover `.dev-card` elements. The existing Swiper carousel, all 23 Kiro_Ready slides, and all 5 critical JS functions are intact and confirmed by grep.

**Watch for:**
- Advisor credentials changed from "Dr. Ellen F. Mangaoang, **DIT**" to "Ellen F. Mangaoang, **MIT**" — the title and honorific both differ from the base branch. Needs confirmation that the new version is correct. (**confirmed**)
- Two panel members removed: "Jeoffrey B. Layco (Chair)" and content validator "Avigail Candevario, PFMe" no longer appear anywhere in the file. This may be intentional, but it silently removes their acknowledgement. (**confirmed**)

**Verdict**: NEEDS_CHANGES

---

## High-level view

All 13 plan items are present and all mechanical checklist requirements pass: 9 key patterns matched, 23 Kiro_Ready slides, 2 Swiper CDN links, 5+ critical JS functions, HTML parses cleanly, commit pushed to `origin/master`.

The about section is the only area with meaningful content changes rather than pure style updates. The dev team cards were upgraded from `team-card` to `dev-photo` cards with inline SVG fallback avatars, the institution row was simplified, and the academic acknowledgements were edited. Those edits introduced a credential discrepancy and removed two people entirely — changes that should be human-reviewed before the site is considered final.

The `about-section` element was changed from `<section>` to `<div>`, removing the native landmark semantics. The `.about-section` CSS grid was also stripped off the element itself and left only on `.about-grid` inside it. Neither change breaks layout, but the accessibility regression is worth noting.

---

<details>
<summary>Issues (3)</summary>

1. **Advisor credential change** — "Dr. Ellen F. Mangaoang, DIT" in HEAD~1 became "Ellen F. Mangaoang, MIT" in this commit. Both the honorific ("Dr." dropped) and the degree abbreviation differ. Confirm which is correct before shipping.

2. **Removed panel members** — Jeoffrey B. Layco (panel chair) and Avigail Candevario (content validator) are no longer mentioned anywhere in the file. If this was intentional, no action needed; if not, they should be restored.

3. **`<section>` → `<div>` for about block** — The about block lost its `<section>` landmark, making it invisible to screen readers navigating by region. Low severity but trivial to restore.

</details>

---

<details>
<summary>Details</summary>

## About section content edits introduce factual and attribution concerns

The about section rewrite is the only place where the diff touches user-visible factual claims rather than just styling. The advisor title changed from "Dr. Ellen F. Mangaoang, DIT" to "Ellen F. Mangaoang, MIT" — both the honorific and the credential abbreviation differ, making it impossible to determine which is correct without human confirmation. (**confirmed**: diff lines at ~2237 vs HEAD~1 grep result)

Jeoffrey B. Layco is identified as panel chair in the base branch. Avigail Candevario holds the content validator credit. Neither name appears anywhere in the current `index.html`. The institution row was simplified from named-card components to a compact inline text block, and in that simplification both individuals were dropped. This is either a deliberate scope reduction or an accidental omission; either way it needs a human decision. (**confirmed**: `Select-String "Layco|Candevario"` returns count 0)

## About section landmark regression

The outer container changed from `<section id="about">` to `<div class="about-section" id="about">`. The `id` is preserved so anchor navigation still works. The semantic `<section>` landmark is gone, which removes this content from screen reader region navigation. The plan specified updating the about section structure; it did not specify removing the landmark. (**confirmed**)

## Checklist verification

All 9 required key patterns confirmed by live grep, 23 Kiro_Ready slides intact, 2 Swiper CDN links present, all 5 critical JS functions found (`openLightbox` at line 2413, `demoGetReply` at 2600, `filterSlides` at 2366, `demoTab` at 2552, `demoTypewriter` at 2617). Commit `fc916f5` is at `origin/master`.

</details>

---

<details>
<summary>File map</summary>

| File | What changed |
|------|-------------|
| `index.html` | About section restructured to dev-photo cards; demo/frame backgrounds updated to `#0f1a0f`; `.about-section` changed from `<section>` to `<div>`; `.dev-card` added to IntersectionObserver; advisor credits and panel attribution edited; institution row simplified |

Full diff: `git -C c:\xampp\htdocs\smartspend_app diff HEAD~1..HEAD -- index.html`

</details>
