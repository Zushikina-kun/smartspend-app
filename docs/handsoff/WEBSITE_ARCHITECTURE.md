# SmartSpend Website Architecture

**Version:** v3.2.0  
**Last Updated:** November 15, 2024

---

## Two Separate Websites

SmartSpend has **two distinct, standalone websites** hosted in the repository:

### 1. Main Public Website (`index.html`)
**Purpose:** General audience, feature showcase, download hub  
**URL:** https://zushikina-kun.github.io/smartspend-app/  
**Target Audience:** 
- Potential users
- General public
- Press/media
- Casual visitors

**Key Sections:**
- Hero with app overview
- Feature showcase (cards + carousel)
- Screenshot gallery (40+ app screens)
- Download section (3 split APKs)
- Peso AI demo (interactive chat simulation)
- About & Team info

**Design System:**
- **Colors:** Primary teal (#00C896), dark green background (#0d1a0f)
- **Typography:** Plus Jakarta Sans (headings), Inter (body)
- **Style:** Modern, consumer-friendly, interactive
- **Theme:** Dark/Light mode toggle
- **Navigation:** Sticky nav with Download CTA

**Content:**
- Marketing-focused
- Feature benefits explained
- Screenshots with captions
- Downloadable APKs
- GitHub links

---

### 2. Defense Reviewer Website (`reviewer.html`)
**Purpose:** Defense preparation, panel guide, technical reference  
**URL:** https://zushikina-kun.github.io/smartspend-app/reviewer.html  
**Target Audience:**
- Defense panelists
- Thesis advisers
- Team members (Brix, Cyrille, Djaunathan)
- Academic reviewers

**Key Sections:**
- **Tab 1: Demo Script** - Step-by-step defense demo flow (8 steps + closing)
- **Tab 2: Panel Q&A** - Anticipated questions organized by category
- **Tab 3: Quick Facts** - Memorizable statistics and one-liners

**Design System:**
- **Colors:** Ledger green (#1B4332), paper beige (#F6F3EC), gold accents (#B3892B)
- **Typography:** Fraunces (headings), IBM Plex Sans (body), IBM Plex Mono (code)
- **Style:** Academic, ledger-inspired, focused
- **Theme:** Light/Dark with preference detection
- **Navigation:** Tabbed interface (radio inputs + CSS)

**Content:**
- Defense preparation focused
- Technical Q&A depth
- Formula breakdowns
- Implementation details
- Role assignments
- Troubleshooting scenarios

---

## Key Differences

| Aspect | Main Website (`index.html`) | Reviewer Website (`reviewer.html`) |
|--------|----------------------------|-----------------------------------|
| **Purpose** | Marketing & downloads | Defense preparation |
| **Tone** | Consumer-friendly, exciting | Academic, technical |
| **Primary Color** | Teal (#00C896) | Ledger Green (#1B4332) |
| **Typography** | Plus Jakarta Sans / Inter | Fraunces / IBM Plex |
| **Navigation** | Sticky nav with sections | Tabbed panels |
| **Content Depth** | Feature overview | Implementation details |
| **Audience** | General public | Academic panel |
| **Screenshots** | 40+ carousel slides | None (focuses on text) |
| **Interactive Elements** | Peso AI demo, theme toggle | Expandable Q&A accordions |
| **Download Links** | Prominent (3 APKs) | Not featured |
| **Version Display** | Subtle footer | Prominent header (v3.2.0) |

---

## Design Independence

### Why Two Separate Designs?

1. **Different Audiences:** Public users need inspiration; panelists need facts
2. **Different Goals:** Marketing vs. academic evaluation
3. **Information Density:** Consumer-friendly vs. comprehensive reference
4. **Context:** Casual browsing vs. formal defense preparation
5. **Maintenance:** Marketing updates don't affect defense docs

### No Cross-Linking

The websites do **not link to each other**:
- Main website → No mention of reviewer site
- Reviewer site → No navigation back to main site
- Each is discoverable through its own URL
- GitHub Pages hosts both independently

---

## Content Separation Matrix

### Main Website Content
✅ Feature benefits and use cases  
✅ Screenshot gallery with captions  
✅ Download buttons and installation guide  
✅ Peso mascot and branding  
✅ "What is SmartSpend?" explainer  
✅ Social proof (stats, testimonials placeholder)  
✅ Team credits in footer  
✅ GitHub links  

❌ Technical implementation details  
❌ Defense script  
❌ Panel Q&A preparation  
❌ Research methodology  
❌ FHS formula derivation  
❌ Limitations discussion  

### Reviewer Website Content
✅ Step-by-step demo script  
✅ Anticipated panel questions + answers  
✅ FHS formula with mathematical notation  
✅ Technical architecture details  
✅ Research methodology explanation  
✅ Limitations and future work  
✅ Role assignments (Brix/Cyrille/Djaunathan)  
✅ Troubleshooting scenarios  
✅ Memorization checklists  
✅ One-line rapid answers  

❌ Marketing copy  
❌ Screenshot carousel  
❌ Download buttons  
❌ Consumer-facing feature benefits  
❌ Social proof elements  
❌ Flashy interactive demos  

---

## v3.2.0 Updates Applied to Both

### Common Updates (Nov 15, 2024)
- ✅ Version number updated to v3.2.0
- ✅ Government Contributions Tracker documented
- ✅ Feature count updated (42+ screens)
- ✅ Post-defense roadmap mentioned (43 features)

### Main Website Specific
- ✅ Government Contributions card in features grid
- ✅ Screenshot slide with Insurance & Gov't Contributions screen
- ✅ Changelog item: "Insurance & Contributions tracker"
- ✅ Updated "What is SmartSpend?" to mention Pag-IBIG
- ✅ Figure_3.7 uncensored screenshot removed

### Reviewer Website Specific
- ⏳ New demo step for Government Contributions (in progress)
- ⏳ Q&A category for v3.2.0 features (in progress)
- ⏳ Updated Quick Facts with v3.2.0 stats (in progress)
- ⏳ Expanded "What's New" section (in progress)

---

## File Structure

```
smartspend_app/
├── index.html              ← Main public website
├── reviewer.html           ← Defense reviewer website
├── README.md               ← GitHub repository README
└── docs/
    └── handsoff/
        └── FOR_CYRILLE/
            └── defense_reviewer.html  ← Old backup (superseded by root reviewer.html)
```

**Note:** `docs/handsoff/FOR_CYRILLE/defense_reviewer.html` is an older version. The canonical reviewer website is `reviewer.html` at repository root.

---

## Deployment

Both websites are served via **GitHub Pages**:

- **Main Site:** `https://zushikina-kun.github.io/smartspend-app/`
- **Reviewer:** `https://zushikina-kun.github.io/smartspend-app/reviewer.html`

No build process required — pure HTML/CSS/JS static sites.

---

## Maintenance Guidelines

### When Updating Main Website:
1. Focus on consumer benefits
2. Keep technical jargon minimal
3. Prioritize visual appeal (screenshots, colors, animations)
4. Test on mobile first (majority of target users)
5. Ensure Download section is always prominent

### When Updating Reviewer Website:
1. Prioritize accuracy over marketing
2. Include implementation details for technical questions
3. Update formulas and statistics precisely
4. Organize Q&A by likely question categories
5. Keep demo script under 10 minutes total
6. Test tab navigation thoroughly

### When Adding New Features:
1. **Main Website:** Add feature card, screenshot slide if available, changelog entry
2. **Reviewer Website:** Add demo step if demo-worthy, Q&A entry, update Quick Facts

---

## Access Control

Both websites are **publicly accessible** via GitHub Pages.

**For Defense Day:**
- Share **reviewer.html** URL with panel (via email or QR code)
- Project **main website** on screen during demo (if showing website)
- Keep reviewer open on laptop for quick reference

---

## Version History

| Date | Main Website | Reviewer Website | Notes |
|------|-------------|-----------------|-------|
| Oct 2024 | v3.0.0 | v3.0.0 | Initial thesis version |
| Nov 2, 2024 | v3.1.2 | v3.1.2 | UX polish, PH Banks |
| Nov 15, 2024 | v3.2.0 | v3.2.0 | Gov Contributions, expanded Q&A |

---

## Quick Reference

**Need to:**
- Show app features to public? → **index.html**
- Prepare for defense? → **reviewer.html**
- Download APK? → **index.html** Download section
- Answer technical questions? → **reviewer.html** Panel Q&A tab
- Memorize stats? → **reviewer.html** Quick Facts tab
- Demo flow? → **reviewer.html** Demo Script tab

---

*This architecture ensures each website serves its audience optimally without compromise.*

**Last Updated:** November 15, 2024  
**Maintained by:** Team Lucid Frame (Brix, Cyrille, Djaunathan)
