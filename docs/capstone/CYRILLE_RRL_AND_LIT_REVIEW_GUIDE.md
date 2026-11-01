# Cyrille's RRL + Literature Review Guide
**For:** Cyrille John M. Rubis (Documentation Lead)
**Deadline:** November 6, 2026 — manuscript printing
**Purpose:** Step-by-step guide to finish Chapter II and verify all references

---

## PART 1 — "Paano niyo nakuha yung formula?" (answered)

See `FHS_FORMULA_DERIVATION_DEFENSE_GUIDE.md` — full short answer, Taglish version, and all follow-up Q&As.

**Short answer to memorize:**
> "Hindi po namin ginawa ang formula mula sa wala. Nag-base kami sa CBA–Melbourne Institute Observed Financial Health Indicator — isang academic framework na gumagamit ng actual transaction data para mag-compute ng 0–100 financial health score gamit ang equal-weighted components. Binago namin ang mga components para tumugma sa apat na pain points na natuklasan namin sa aming needs assessment."

---

## PART 2 — How to use NotebookLM for Chapter II

NotebookLM is free at notebooklm.google.com. It reads your uploaded documents and answers questions based only on those — no hallucinated sources.

### Step 1 — What to upload to NotebookLM

Upload these files from `docs/handsoff/`:
1. `FHS_Basis_and_Verification.docx` — FHS academic basis + citations
2. `SmartSpend_Comparative_Research_Report.docx` — competitor analysis + AI landscape
3. `FHS-Comparative-Review-Advantages-and-Disadvantages-FINAL.docx` — FHS framework comparison
4. Your current `CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx` — current manuscript

### Step 2 — Use these prompts IN ORDER

**Prompt 1 — Identify scope** (paste this exactly):
> "Review all uploaded sources. Identify the primary research topic, the central research problem, the key concepts and terminology, and the major themes across the literature. Organize the response using clear headings. Write in formal academic style. Use only the uploaded sources."

**Prompt 2 — Organize by theme** (paste this):
> "Organize the literature from the uploaded sources into logical categories based on themes: (1) financial management practices and challenges, (2) mobile application usability, (3) AI-powered personal finance tools, (4) financial health measurement frameworks. For each category, explain why the studies belong together and how they contribute to the research topic. Write in formal academic style. Use only the uploaded sources."

**Prompt 3 — Critical analysis** (paste this):
> "Critically analyze the literature by comparing the uploaded sources. For each theme, compare main arguments, identify agreements and disagreements, and evaluate the strengths and limitations of each approach. Specifically: compare FHS-like frameworks (Melbourne Institute, CFPB, FinHealth Score) and explain what gap SmartSpend addresses. Write in formal academic style. Use only the uploaded sources."

**Prompt 4 — Research gaps** (paste this):
> "Identify the research gaps revealed by the uploaded sources. Focus on: (1) gaps in mobile expense tracking for Filipino users, (2) gaps in transaction-derived financial health measurement, (3) limitations of existing personal finance apps for the Philippine context. Support each gap with evidence from the uploaded sources. Write in formal academic style."

**Prompt 5 — Write the literature review section** (paste this):
> "Write a comprehensive literature review by synthesizing the uploaded sources into a coherent academic narrative. Organize around: (1) financial management challenges in the Philippines, (2) mobile-based personal finance solutions, (3) AI and natural language processing in expense tracking, (4) financial health measurement frameworks. Each section should synthesize multiple sources, not summarize them individually. Build toward the research gap that justifies SmartSpend. Write in formal academic style."

**Prompt 6 — Strengthen** (paste this):
> "Review the literature review and strengthen its critical synthesis. Eliminate repetition, improve transitions, clarify relationships between concepts, and ensure each section builds logically toward the research gap. Maintain formal academic tone."

**Prompt 7 — Final review** (paste this):
> "Conduct a final review of the literature review. Check: logical flow, synthesis vs summary, critical analysis consistency, academic language, transitions, and that all conclusions are supported by the uploaded sources. Provide a revised version incorporating all improvements."

### Step 3 — After NotebookLM

1. Copy the output into a Word document
2. **DO NOT paste directly into the manuscript yet**
3. Check every citation against Part 3 below
4. Only after verification, integrate into the manuscript

---

## PART 3 — How to verify references (from LD TechLab guide)

Before adding ANY reference to Chapter II, check ALL 5 of these:

### Check 1 — Title and Authors
1. Go to [Google Scholar](https://scholar.google.com)
2. Search the exact title in quotes: `"exact title here"`
3. Verify the authors match exactly
4. If nothing comes up, try ResearchGate or Academia.edu
5. If still nothing → **DO NOT CITE IT**

### Check 2 — Publication Source
1. Find where it was published (journal name, conference name)
2. Verify the journal exists:
   - IEEE papers → [ieeexplore.ieee.org](https://ieeexplore.ieee.org)
   - ACM papers → [dl.acm.org](https://dl.acm.org)
   - Open access → [doaj.org](https://doaj.org)
   - Any journal → search on Google Scholar
3. If the journal doesn't exist or the paper isn't in it → **DO NOT CITE IT**

### Check 3 — DOI
1. Copy the DOI (format: `10.xxxxx/xxxxx`)
2. Go to [doi.org](https://doi.org) and paste it
3. It must open the SAME paper (same title, same authors)
4. If it opens a different paper → **DO NOT CITE IT** (AI fabricated the DOI)

### Check 4 — Abstract
1. Read the abstract of the paper
2. Confirm it's actually about your topic (financial health / mobile apps / Filipino users)
3. A real paper about something completely different is useless even if verified

### Check 5 — Publication Status
1. Check if there's a retraction notice
2. Search: `"[paper title]" retracted`
3. If retracted → **DO NOT CITE IT**

---

## PART 4 — Search strings for SmartSpend RRL

Use these in Google Scholar, ResearchGate, or DOAJ:

### For financial health / FHS basis
- `"financial health score" mobile application`
- `"financial health indicator" transaction data`
- `"observed financial health" banking`
- `Comerton-Forde "financial health" Melbourne Institute`
- `CFPB "financial well-being scale" mobile`

### For Filipino / Philippine context
- `"personal finance" Philippines mobile application`
- `"expense tracking" Filipino Taglish`
- `"financial literacy" Philippines BSP 2021 OR 2025`
- `"mobile banking" Philippines GCash`
- `"financial management" Filipino students`

### For AI in finance apps
- `"large language model" expense tracking`
- `"natural language processing" personal finance`
- `"conversational AI" financial advisory`
- `"AI chatbot" budgeting mobile`
- `LLM "expense categorization"`

### For usability / SUS
- `"system usability scale" mobile application`
- `"SUS" "financial app" usability evaluation`
- `Brooke 1996 SUS usability scale`
- `Bangor Kortum Miller 2009 SUS adjective`

---

## PART 5 — Verified references already in your manuscript

These are confirmed real and correctly cited (from `kiro-to-claude-answers-2026-11-01.md`):

| Reference | Status | DOI / Source |
|-----------|--------|-------------|
| Comerton-Forde et al. (2018) — CBA-MI Observed scale | ✅ Verified | Technical Report No. 1, Melbourne Institute |
| Gubbins, Mazzotta & Rhyne (2021) — UNSGSA | ✅ Verified | unsgsa.org/publications |
| Bitrián, Buil & Catalán (2021) — IJBM gamification | ✅ Verified | DOI: 10.1108/IJBM-02-2021-0074 |
| Kahneman & Tversky (1979) — Prospect Theory | ✅ Verified | Econometrica 47(2) |
| Brooke (1996) — SUS | ✅ Verified | Usability Evaluation in Industry |
| Bangor, Kortum & Miller (2009) — SUS adjective scale | ✅ Verified | Journal of Usability Studies 4(3) |
| Warren & Tyagi (2004) — 50/30/20 rule | ✅ Verified | "All Your Worth" book |
| BSP CFIS 2025 | ✅ Verified | bsp.gov.ph |
| Deci & Ryan — Self-Determination Theory | ✅ Verified | Standard psychology citation |

### ⚠️ UNVERIFIED — do NOT use until confirmed
| Reference | Problem |
|-----------|---------|
| FHN (2026) title | Title unverified — check finhealthnetwork.org |
| Groq (2026) generic entry | No verifiable DOI — check Groq docs directly |
| Li et al. (2024) arXiv ID | Confirm arXiv ID exists before citing |

---

## PART 6 — Your Chapter II checklist before printing

- [ ] Every reference checked against Part 3 (all 5 checks)
- [ ] Unverified refs (FHN 2026, Groq 2026, Li 2024) confirmed or deleted
- [ ] Literature review synthesizes sources (not just summarizes them)
- [ ] FHS formula derivation clearly traces to Melbourne Institute + user pain points
- [ ] Research gap is explicit: "No existing app combines Taglish AI + GCash import + FHS for Filipino users"
- [ ] `Ctrl+F [[` → must find NOTHING before printing
- [ ] All figures inserted (3.1–3.11 are placeholders — you need to replace them)
- [ ] TOC page numbers updated after all figures are inserted

---

## PART 7 — Quick reference: What each framework contributes to your Chapter II

| Framework | What it justifies in SmartSpend |
|-----------|--------------------------------|
| Melbourne Institute Observed FHI | Transaction-based 0–100 scoring, equal-weight components |
| UNSGSA (2021) | Using transaction data as an "early-stage complement" to surveys |
| FinHealth Score® (FHN) | Spend/Save/Plan pillar ideas (inspiration, not copied) |
| Kahneman & Tversky Prospect Theory | Warning Decay — loss aversion as behavior change mechanism |
| Thaler & Sunstein Nudge Theory | Daily nudges, budget alerts, Peso companion system |
| Deci & Ryan SDT | Logging Consistency component, gamification, badges |
| Warren & Tyagi 50/30/20 | 20% savings target for Savings Rate component |
| Bangor et al. (2009) SUS scale | Adjective rating interpretation for your SUS results |
| BSP CFIS 2025 | Filipino financial literacy gap (74%), need justification |

---

*Save this file on your phone. If you get stuck, message Brix to share the FHS_FORMULA_DERIVATION_DEFENSE_GUIDE.md as well.*
