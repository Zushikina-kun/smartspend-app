# SmartSpend Manuscript — Full Revision Plan

> **Source file (read-only reference):**
> `c:\xampp\htdocs\smartspend_app\docs\handsoff\1_MAIN_MANUSCRIPT_FINAL.docx.md`
>
> **Working DOCX (edit target):**
> `c:\xampp\htdocs\smartspend_app\docs\handsoff\1_MAIN_MANUSCRIPT_FINAL.docx`
>
> **Screenshots folder:**
> `c:\xampp\htdocs\smartspend_app\docs\handsoff\Screenshots\`
>
> **Extracted DOCX media (read during investigation, do not re-extract unless needed):**
> `c:\xampp\htdocs\smartspend_app\docs\handsoff\docx_media_extract\`

---

## Protected Values — NEVER Alter These Anywhere in the Manuscript

| Item | Exact value |
|---|---|
| SUS score | 61.83 |
| SD | 17.58 |
| Sample N | 30 |
| SUS grade / adjective | D / "OK" |
| Achievement phrase | "partially achieved" |
| Needs-assessment split | 16 parents + 14 YP = 30 |
| SUS subgroup split | 10 parents + 20 YP = 30 |
| GCash usage | 93.3% (28/30) |
| AI intent | 96.7% (29/30) |
| Validator | Avigail Candevario, PFMe |
| Panel chair | Jeoffrey B. Layco, MIS |
| Panel members | Shekiro R. Raposas MTS/MIS; Mary-Ann Mzana MTS |
| Adviser | Ellen Flores Mangaoang, DIT |
| Primary LLM | Gemini 3.5 Flash-Lite |
| Recommendation count | 9 |

---

## A. TOC Audit (Fix 1 + Fix 4)

### A1. Figure captions found in manuscript body (Figures 1–16)

| Figure # | Caption as written in body |
|---|---|
| Figure 1 | Financial Literacy Rates by Demographic Group (BSP, 2021; Inquiro, 2024) |
| Figure 2 | Conceptual Framework (Mobile Application) |
| Figure 3 | System Usability Scale (SUS) Score Interpretation |
| Figure 4 | Agile Kanban Workflow for SmartSpend Development |
| Figure 5 | Demographic Distribution of Needs-Assessment Respondents (N = 30) |
| Figure 6 | SmartSpend System Flowchart |
| Figure 7 | Use Case Diagram |
| Figure 8 | Visual Table of Contents |
| Figure 9 | Login and Demo Mode Screen |
| Figure 10 | Home Dashboard |
| Figure 11 | Expense Logging Through Peso Chat |
| Figure 12 | Receipt Scanning and Batch Screenshot Import |
| Figure 13 | Financial Health Score Breakdown |
| Figure 14 | Budgets, Safe-to-Spend, and Savings Goals |
| Figure 15 | Local AI Mode Setup |
| Figure 16 | SUS Computation Table |

**What the current TOC "List of Figures" contains:** Nothing — it has the heading "List of Figures" with page number "vi" but zero figure entries.

**Action required:** Add all 16 entries to the List of Figures section in the TOC, in order, with page numbers.

---

### A2. Table titles found in manuscript body

| Table # | Title as written in body |
|---|---|
| Table 1 | Three-Level Gap Analysis of SmartSpend |
| Table 2 | Feature Comparison of SmartSpend with Existing Financial Applications (including Filipino-context apps) |
| Table 3 | Distribution of Respondents and Validators |
| Table 4 | Agile Kanban Workflow Phases and Deliverables |
| Table 5 | *(ghost — see note below)* |
| Table 6 | Demographic Profile and Expense Tracking Methods of Respondents (N = 30) [**currently mislabeled Table 7** in body — see A3] |
| Table 7 | Comparative Evaluation of LLM APIs for SmartSpend Integration |
| Table 8 | Overall SUS Result |
| Table 9 | System Usability Scale (SUS) Results by Respondent Group |

**Note on Table 5 (ghost):** The TOC lists `Table 5. Demographic Distribution of Needs-Assessment Respondents (N = 30)` — but this content exists in the manuscript body **as Figure 5** (a pie/bar chart image), not as a data table. There is no body table that matches that title. The TOC entry for Table 5 must be removed; it is a residual numbering artifact.

**What the current TOC "List of Tables" contains:** All nine entries *including the ghost Table 5* are already listed in the TOC area — but they appear as plain text running directly into the chapter outline, not inside a proper "List of Tables" formatted section. The List of Tables must be presented as its own formatted list with page numbers.

**Action required:**
1. Format the List of Tables as a proper section with page numbers.
2. Remove the ghost `Table 5. Demographic Distribution…` entry.
3. Add Tables 1–4 and 6–9 (8 real tables) with page numbers.

---

### A3. Table Number Conflict (also listed as Fix — panel notification item 8)

**Problem:** Two different tables are both labeled "Table 7" in the manuscript body.
- The *Demographic Profile and Expense Tracking Methods* table is labeled **Table 7** in the body paragraph introducing it and in its heading.
- The *Comparative Evaluation of LLM APIs* table is also labeled **Table 7** in its body paragraph and heading.

**Root cause:** The TOC already correctly sequences these as Table 6 (Demographic Profile) and Table 7 (LLM APIs). The body was not updated to match.

**Fix:** Rename the *Demographic Profile* table from **Table 7 → Table 6** everywhere it appears:
- Narrative reference: `"Table 7 presented the demographic profile…"` → `"Table 6 presented…"`
- Table heading: `**Table 7: Demographic Profile…**` → `**Table 6: Demographic Profile…**`

---

### A4. Chapter, section, and subsection headings in body vs. TOC

**Body headings found (in order):**

**Chapter I – Introduction**
- Project Context
- Conceptual Framework
- Statement of Objectives
- Scope and Limitations of the Study
- Purpose and Description
- Technical Background

**Chapter II – Design and Methodology**
- Research Design
- Population and Locale
- Ethical Considerations
- Data Gathering Tools and Procedure
- Software Methodology

**Chapter III – Results and Discussion**
- Assessment of the Financial Management Practices, Budgeting Challenges, and Expense Tracking Behaviors of Parents and Young Professionals
- Designed and Developed of the SmartSpend Mobile Application *(heading has a grammatical error — should be "Design and Development of")*
- System Development Results / Overview of the System *(two sub-headings here; merge or nest properly)*

**Chapter IV – Conclusions and Recommendations**
- Conclusions
- Recommendations

**What the current TOC chapter/section outline contains:** The TOC currently shows no chapter or section entries at all — it lists only the front matter (Title Page, Approval Sheet, etc.) and then the Table/Figure lists. Zero chapter entries appear.

**Action required:** Add a full chapter and section outline to the TOC with page numbers, covering all four chapters and all sections listed above. Also fix the grammatical error in the Chapter III heading "Designed and Developed of" → "Design and Development of".

---

## B. Figure Image Audit (Fix 2 — FLAG ONLY, no pixel edits)

**How the DOCX images map to Figures:**
Images in `word/media/` are numbered by insertion order in the DOCX. The `.md` mirror uses `[imageN]` references that correspond directly to `word/media/imageN.*` filenames.

| image file | Figure # | Caption | Image type | Notes |
|---|---|---|---|---|
| image1.png (13 KB) | Figure 1 | Financial Literacy Rates by Demographic Group | Small chart/diagram | Likely a simple bar or line chart; low resolution (13 KB). Check for burned-in "Figure 1" or old number. |
| image2.jpg (106 KB) | Figure 2 | Conceptual Framework (Mobile Application) | Diagram/flowchart | IPO framework diagram — likely contains text labels burned in. Check for old "Figure 3.X" style numbering. |
| image3.png (12 KB) | Figure 3 | SUS Score Interpretation | Small chart | Very small file; annotated scale diagram. Likely has figure label burned in. Check for wrong number. |
| image4.png (45 KB) | Figure 4 | Agile Kanban Workflow | Diagram/flowchart | Contains phase labels; check for burned-in figure number. |
| image5.jpg (201 KB) | Figure 5 (appears 3× in md) | Demographic Distribution (appears before Table 6 and also as the Figure 5 caption) | Bar/pie chart | NOTE: `[image5]` is referenced three times. First two occurrences are before/beside Table 6 — likely the same chart image used as both a table support image and as Figure 5. The third occurrence is the actual Figure 5 caption placement. This may be an accidental duplicate. The coder should confirm in the DOCX whether image5 is used as both an in-line chart and as the named figure. |
| image6.png (154 KB) | Figure 5 *(second reference)* | — | Chart | Appears after Table 6 note, before the Figure 5 caption. This is the actual Figure 5 image. |
| image7.png (1,014 KB) | Figure 6 | SmartSpend System Flowchart | App diagram/flowchart | Large file — likely a detailed flowchart diagram. **HIGH RISK** for burned-in wrong figure number (previous versioning may have used "Figure 3.X" or "Figure 6.1"). Check carefully. |
| image8.png (1,133 KB) | Figure 7 | Use Case Diagram | UML diagram | Large diagram — check for burned-in "Figure 7" or old reference. |
| image9.png (2,359 KB) | Figure 8 | Visual Table of Contents | Navigation diagram/screenshot | Very large — likely a detailed navigation map. Check for burned-in numbering. |
| image10.png (1,550 KB) | Figure 9 | Login and Demo Mode Screen | App screenshot | App screenshot — text visible in app UI only, no burned-in figure number expected *unless* a diagram overlay was added. Mark as LOW RISK for figure number issues; HIGH RISK for privacy if personal account data is visible. |
| image11.png (1,416 KB) | Figure 10 | Home Dashboard | App screenshot | App screenshot. LOW RISK for wrong figure number. Check for real financial data (names, amounts). |
| image12.png (1,528 KB) | Figure 11 | Expense Logging Through Peso Chat | App screenshot | App screenshot. LOW RISK for burned-in number. Check for real transaction amounts/names in chat. |
| image13.png (2,570 KB) | Figure 12 | Receipt Scanning and Batch Screenshot Import | App screenshot composite | **HIGH RISK for privacy** — receipt/screenshot import feature likely shows GCash or other e-wallet screenshots embedded inside the app screen. These may expose real transaction amounts, merchant names, or phone numbers. Flag for blur/replacement. |
| image14.jpg (6 KB) | Figure 13 | Financial Health Score Breakdown | App screenshot (very small/compressed) | Very small file (6 KB) — may be a low-res thumbnail or placeholder. Verify in DOCX that this displays correctly. |
| image15.png (84 KB) | Figure 14 | Budgets, Safe-to-Spend, and Savings Goals | App screenshot | App screenshot. Check for real user names or amounts. |
| image16.png (91 KB) | Figure 15 | Local AI Mode Setup | App screenshot | App screenshot — settings screen. LOW RISK for privacy. |
| image17.png (1,519 KB) | Figure 16 | SUS Computation Table | Table/spreadsheet screenshot | Likely a screenshot of a spreadsheet or table. Check whether respondent names are visible — if so, flag for blur. |
| image18.png (1,531 KB) | (before Table 9) | — | Chart/table | Appears before Table 9 in the md; this may be a bar chart or graph of SUS results. No figure caption assigned — likely should be **Figure 16 continuation** or a separate figure that is currently unnumbered and undescribed. |

**Figures with the highest risk of wrong number burned into pixels (diagrams/flowcharts where numbers are typically embedded in the design tool):**

| Image | Figure # now | Suspected wrong number | Reason |
|---|---|---|---|
| image2.jpg | Figure 2 | Possibly old "Figure 1.2" or "Figure 2" — verify visually | IPO diagram — common to label inside the design file |
| image4.png | Figure 4 | Possibly old "Figure 2.X" (Kanban was often in Ch. II) | Methodology diagram |
| image7.png | Figure 6 | **Most likely wrong** — system flowcharts were renumbered during revision; previous version had these as "Figure 3.X" (e.g., "Figure 3.1") | Complex diagram, large file |
| image8.png | Figure 7 | Possibly old "Figure 3.2" or "Figure 3.3" | UML use case diagram |
| image9.png | Figure 8 | Possibly old "Figure 3.X" | Navigation map diagram |
| image17.png | Figure 16 | Possibly old "Figure 3.14" (matches user's report of "Figure 3.14" burned in) | SUS table — this is the specific image the user flagged |

**User explicitly reported:** "there's still remaining built-in descriptions or names on the png or image that says the wrong title like figure 3.14." This directly maps to **image17.png** (Figure 16, SUS Computation Table) which likely still has "Figure 3.14" burned into its pixels.

**Action (for coder):** Inspect each flagged image visually. For each confirmed wrong burned-in number, record it in the plan and notify the user to supply a replacement image. Do NOT attempt pixel editing.

---

## C. Privacy Blur Audit (Fix 3)

### C1. GCash screenshots requiring blur

All 8 screenshots with `com.globe.gcash.android` in the filename contain GCash app screens. Because GCash displays transaction history, wallet balance, mobile number, and account name, these are HIGH PRIVACY RISK.

| Filename | Privacy concern |
|---|---|
| Screenshot_2026-11-09-09-42-28-585_com.globe.gcash.android.jpg | GCash transaction list — amounts, merchant names |
| Screenshot_2026-11-09-09-42-34-345_com.globe.gcash.android.jpg | GCash transaction detail — may show recipient name/number |
| Screenshot_2026-11-09-09-42-42-226_com.globe.gcash.android.jpg | GCash transaction detail |
| Screenshot_2026-11-09-09-42-48-630_com.globe.gcash.android.jpg | GCash transaction detail |
| Screenshot_2026-11-09-09-42-55-828_com.globe.gcash.android.jpg | GCash transaction detail |
| Screenshot_2026-11-09-09-42-58-916_com.globe.gcash.android.jpg | GCash transaction detail |
| Screenshot_2026-11-09-09-43-03-953_com.globe.gcash.android.jpg | GCash transaction detail |
| Screenshot_2026-11-09-09-43-09-740_com.globe.gcash.android.jpg | GCash transaction detail |

**Strategy:** Apply a **full-image Gaussian blur** to all 8 GCash screenshots using Python + Pillow. Full-image blur is appropriate here because these screenshots are used as *import-source examples* inside the app screenshot (image13.png / Figure 12), not as standalone figures. The blurred versions replace the originals before the DOCX is rebuilt.

### C2. SmartSpend screenshots that may need blur

The 37 SmartSpend screenshots may show real user data (names, transaction amounts, wallet balances) entered during demo or real use. The ones used in the manuscript correspond to Figures 9–15 (images 10–16). Key candidates:

| Filename pattern | Risk | Notes |
|---|---|---|
| Screenshots showing transaction lists (09:39–09:41 range) | MEDIUM | May show real amounts and category names |
| Screenshots showing wallet screens (09:44–09:49 range) | MEDIUM–HIGH | May show real GCash/bank balance numbers |
| Screenshots embedded inside Figure 12 (Receipt Scanning) | HIGH | Likely shows GCash screenshots *within* the app screen |

**Strategy:** Apply a targeted Gaussian blur to any visible real-name, real-amount, or real-phone-number text visible in SmartSpend screenshots used in the manuscript. Because these are app UI screenshots, the blur should be applied to specific sub-regions (transaction amounts, names) rather than the whole image. If sub-region identification is not feasible programmatically, use full-image blur with moderate radius (σ=5) which softens readable numbers without destroying the UI chrome.

### C3. DOCX Figure that uses GCash screenshots

**image13.png (Figure 12)** is the most likely DOCX figure that embeds GCash screenshots within the app's batch-import screen. This image (2,570 KB — the largest screenshot) must be replaced after blur is applied to the source GCash screenshots, or the screenshot itself must be re-taken with blurred/demo data visible.

**Blur implementation:**
```
python blur_gcash.py
```
Using:
```python
from PIL import Image, ImageFilter
import os

gcash_dir = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\Screenshots"
out_dir   = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\Screenshots\blurred"
os.makedirs(out_dir, exist_ok=True)

for fname in os.listdir(gcash_dir):
    if "gcash" in fname.lower() and fname.lower().endswith((".jpg", ".jpeg", ".png")):
        img = Image.open(os.path.join(gcash_dir, fname))
        blurred = img.filter(ImageFilter.GaussianBlur(radius=15))
        blurred.save(os.path.join(out_dir, fname))
```

**Libraries confirmed available:** Python 3.14.6, Pillow 12.3.0, python-docx 1.2.0.

---

## D. Writing Style Gaps (Fix 5 — LigTask Narrative Alignment)

### D1. Top differences between SmartSpend and LigTask writing styles

| # | LigTask style (target) | SmartSpend current style (gap) |
|---|---|---|
| 1 | **Short, declarative sentences.** Most body paragraphs average 1–2 sentences before a new paragraph begins. Transitions are signpost words ("Meanwhile," "Moreover," "These indicate that"). | SmartSpend paragraphs frequently run 4–6 sentences without a break and chain subordinate clauses ("…which made it suitable for users who preferred…, nor did it provide a conversational assistant that…"). |
| 2 | **Active, past-tense verbs with the subject stated.** "The researchers designed and developed LigTask…", "The game offers players…", "Figure 5 presents the interface…" | SmartSpend often uses noun-heavy constructions: "The selection of an appropriate LLM API was a critical design decision because it directly influenced…" vs. "The researchers selected the LLM API after evaluating…" |
| 3 | **Tables and figures are introduced with one-sentence lead-ins, then described in one short paragraph.** "Figure 5 presents the interface of character design…" (1 sentence), then a 2–3 sentence description. | SmartSpend introduces figures adequately but then embeds multi-clause technical asides inside the figure description paragraph (e.g., Figure 8 / Visual Table of Contents paragraph contains the full Paluwagan feature paragraph and version history). |
| 4 | **Results paragraphs state the finding, cite the number, interpret briefly, then stop.** "LigTask recorded a usability rating of 4.13, interpreted as Good." | SmartSpend Results/Discussion paragraphs frequently re-state framing and methodology before giving the number, adding 2–3 sentences of context the reader already has. |
| 5 | **Conclusions are brief — one paragraph per objective, no repeating numbers.** Chapter IV in LigTask: ~3 short paragraphs, one per objective, no re-printing of raw data already in Chapter III. | SmartSpend Chapter IV currently has three separate conclusion blocks that each re-state all three objectives. The 96.7%, 93.3%, SUS 61.83 numbers are repeated in every block. |
| 6 | **Technical background uses brief tool descriptions** — 2–3 sentences per tool, no elaboration on the tool's internal workings beyond what is used. | SmartSpend's Technical Background section is appropriately concise but Chapter III has extended technical asides (version history paragraph, full FHS formula with clamping notation, full LLM fallback chain naming) that interrupt narrative flow. |
| 7 | **Transitions between sections are explicit one-liners.** "The same questionnaire was also administered to the teachers…" before the teacher section. | SmartSpend transitions between Chapter III sub-sections are present but sometimes buried in long paragraphs. |
| 8 | **Figure descriptions are attached immediately after the image caption**, always starting with "Figure N [presents/shows/illustrates/displays]…" | In SmartSpend the description for Figure 15 appears immediately after Figure 11's caption text — a text ordering error. Figure 8 (Visual Table of Contents) has its description appended after a long development-features paragraph instead of directly below the caption. |

### D2. Per-section revision notes

**Abstract:** Clean; no changes needed to substance. Sentence length is acceptable for an abstract. Keep as-is.

**Chapter I — Project Context:**
- The first four paragraphs (BSP 2021 data, CFIS 2025 data, challenges, Flores 2025) can each be trimmed by 1–2 sentences. The key facts are already stated; the follow-up elaboration restates them.
- The "More recent data" paragraph (BSP CFIS 2025) is well-structured but can be condensed: the last clause about "suggesting access was broadening at the household level while individual account ownership…remained uneven" summarizes adequately — the in-between sentence comparing 56% to 50% can be cut.
- The two app comparison paragraphs (Table 2 lead-in) run long. The paragraph after Table 2 (listing Agila, PISO, Lista, Kibo, BunnyWise, GCash Pera Coach) is a lengthy acknowledgment block; condense to: "Several additional Philippine-context finance apps address adjacent needs (Agila, PISO, Lista, Kibo, BunnyWise, GCash Pera Coach) but none combine SmartSpend's offline-first operation, Taglish conversational AI, and Financial Health Score in one evaluated prototype."
- The "Traditional financial tracking systems" paragraph (passive tracking systems paragraph) can be fused with the paragraph below it (LLMs changing mobile interaction) — they address the same transition.

**Chapter I — Conceptual Framework:**
- Figure 2 description paragraph is clean. No changes needed.

**Chapter I — Statement of Objectives:**
- The two-paragraph lead-in before the numbered list is redundant. Merge into a one-sentence intro: "Specifically, this study achieved the following." The numbered list is the substance.

**Chapter I — Scope and Limitations:**
- Clean. Keep as-is.

**Chapter I — Purpose and Description:**
- The intro paragraph before the beneficiary list is adequate. The beneficiary descriptions (Parents, Budget-Conscious Individuals, Technology Enthusiasts, Demo Users, Researchers, Future Researchers) can each be trimmed to 2 sentences. Currently some run to 4 sentences.

**Chapter I — Technical Background:**
- Each tool entry (Flutter, SQLite, Firebase, LLM API, Speech-to-Text, etc.) is 2–4 sentences — appropriate. Keep as-is.

**Chapter II — Research Design:**
- The first paragraph ("This study applied a quantitative descriptive developmental research design…") is clean. The second paragraph ("To gather user input…") starts to loop back to what the first paragraph already said. Trim the second paragraph by cutting the sentence "By adopting a quantitative developmental approach, the study ensured that the system was not only technically functional but also user-centered…" — this repeats the opening framing.
- The three-sentence closing block ("By adopting…") can be reduced to one sentence.

**Chapter II — Population and Locale:**
- Table 3 is correctly numbered and clean.
- The sentence "Thirteen (13) respondents were parents who regularly handled household budgeting… Three (3) respondents identified as both" contains data that contradicts Table 3 (Table 3 says 16 parents, 14 YP, 1 validator = 30 total; the narrative says 13 parents and 14 YP). The "13" is the breakdown used for the demographic analysis excluding the "both" group. This is correct but the sentence should clarify: "Of the 30 respondents, 13 identified primarily as parents aged 35–55, 14 as young professionals aged 21–35, and 3 as both."

**Chapter II — Software Methodology:**
- The long "Done/Review Phase" paragraph must have the future-features list removed per panel notification item 7. Keep only: evaluation of SUS scores, review of feedback, documenting recommendations.
- Table 4 is clean and correctly numbered.

**Chapter III — Assessment section:**
- The paragraph before Table 6 ("Table 7 presented the demographic profile…") contains the duplicate Table 7 error (fix per A3).
- image5 appears three times — investigate in DOCX: once appears to be a stray duplicate. Remove the stray [image5] reference.
- The findings summary paragraph ending with "These results showed that the first objective of the study was achieved" is clean — keep as-is.

**Chapter III — LLM API section:**
- Condense the post-table paragraph (panel notification item 2): remove fallback model names, Groq migration notes, "cost-prohibitive" language. Keep 2–3 sentences: selected Gemini 3.5 Flash-Lite as primary (free tier, Filipino-English support, speed, function calling); seven fallback providers for reliability.

**Chapter III — FHS section:**
- Condense per panel notification item 1: ~600 words → ~200 words. Remove raw min/max/clamp formulas, Lightweight Mode, Warning Decay, Gap Adjustment, loss-aversion/habit-loop citations in the formula block. Keep: 4 component names, 25 pts each, CBA-MI and FinHealth Network as theoretical basis, 20% savings target, 2–3 plain English sentences per component. Add: "Detailed formula specifications are available in the application documentation."

**Chapter III — System Development / Overview:**
- Figure 6, 7, 8 description paragraphs: Figure 8 description is currently appended to a paragraph about Filipino features and version history (the long paragraph after image9). Move the Figure 8 description sentence directly below the Figure 8 caption and start a new paragraph for the feature additions.
- **Figure 15 description misplacement** (critical): The sentence "Figure 15 presents the Local AI Mode setup screen, which guides users in configuring an offline AI model using tools such as Ollama, LM Studio, or Jan for private use without internet connectivity." currently appears immediately after Figure 11's body text — before Figures 12–14 are even introduced. This sentence must be moved to appear directly after the [image16] Figure 15 caption.
- Version history paragraph (v2.9.97–3.1.0): Replace entirely with per panel notification item 4: "Development was iterative across multiple versions from v2.9.9 to v3.1.0, with progressive feature additions culminating in the final evaluated version SmartSpend v3.1.0."
- AI Privacy Tiers paragraph: Condense per panel notification item 3 to ~3 sentences. Keep: Cloud AI with on-device redaction; Local AI mode; privacy disclosure before first use. Remove: version numbers, Google API terms language, On-device AI tier (it's in Recommendations).
- Peso mascot paragraph: Condense per panel notification item 5 to 3–4 sentences. Keep: animated mascot, context-aware moods reflecting FHS, motivational messages.
- Local LLM setup paragraph: Condense per panel notification item 6 to 1–2 sentences.

**Chapter III — SUS Results:**
- Fix old table reference per panel notification item 9: "As shown in Tables 3.3 and 3.4" → "As shown in Tables 8 and 9."

**Chapter IV — Conclusions:**
- Condense per panel notification item 10: replace three redundant objective-restatement blocks with one paragraph per objective. No re-printing of raw numbers already stated in Chapter III.

---

## E. Figure Description Gaps (Fix 6)

Each figure should have a description paragraph *immediately below its caption* that (a) starts with "Figure N [presents/shows/illustrates/displays]…" and (b) explains what the image shows and its significance to the study, following LigTask style (3–5 sentences max).

| Figure | Has description? | Quality / Gap |
|---|---|---|
| Figure 1 | ✅ Yes | "Figure 1" is not referenced in a description paragraph — the image appears with only the bold caption. **Missing description paragraph.** Add: "Figure 1 presents the financial literacy rates across demographic groups in the Philippines, based on data from BSP (2021) and Inquiro (2024). The chart shows that literacy rates vary significantly by age group and income level, highlighting the gap that SmartSpend aims to address for parents aged 35–55 and young professionals aged 21–35." |
| Figure 2 | ✅ Yes | Description paragraph present and well-written (IPO model explanation). Adequate — trim to 3 sentences following LigTask length norms. |
| Figure 3 | ✅ Yes | Description paragraph present (SUS interpretation scale). Adequate. Keep. |
| Figure 4 | ✅ Yes | Description paragraph present (Kanban Workflow). Adequate. Keep. |
| Figure 5 | ⚠️ Partial | The paragraph following Figure 5's caption begins with the reclassification sentence ("The 3 respondents who identified as…") which is analytical text, not a figure description. **Add a one-sentence opening**: "Figure 5 presents the demographic distribution of the 30 needs-assessment respondents, showing the proportion of parents, young professionals, and those belonging to both groups." |
| Figure 6 | ✅ Yes | Description paragraph present. Good. Keep. |
| Figure 7 | ✅ Yes | Description paragraph present. Good. Keep. |
| Figure 8 | ⚠️ Partial | The description sentence is present but is *embedded inside a long paragraph* about Filipino-specific features. It needs to be its own standalone description paragraph directly below the caption. |
| Figure 9 | ✅ Yes | Description paragraph present. Good. Keep. |
| Figure 10 | ✅ Yes | Description paragraph present. Good. Keep. |
| Figure 11 | ✅ Yes | Description paragraph present. However, the stray "Figure 15 presents the Local AI Mode..." sentence is incorrectly placed here (misplacement error — fix in D2). |
| Figure 12 | ✅ Yes | Description paragraph present. Good. Keep. |
| Figure 13 | ✅ Yes | Description paragraph present. Good. Keep. |
| Figure 14 | ✅ Yes | Description paragraph present. Good. Keep. |
| Figure 15 | ⚠️ Present but misplaced | Description sentence exists but is placed before Figures 12–14 in the document flow (after Figure 11 caption). Must be moved to directly follow the Figure 15 caption and image. When moved, expand to 2–3 sentences: "Figure 15 presents the Local AI Mode setup screen. This screen guides users in configuring an optional offline AI model on their home network for use without sending data to external providers. The setup flow includes hardware guidance to help users choose an appropriate model for their device." |
| Figure 16 | ✅ Yes | Description paragraph present (SUS computation example). Good. Keep. |

**Summary of missing/inadequate descriptions:** Figures 1, 5 (partial), 8 (misplaced), 15 (misplaced) need new or relocated description paragraphs.

---

## F. Implementation Order

Execute the steps in this order. Each step leaves the DOCX in a valid, openable state.

### Step 0 — Backup (before touching anything)
```
copy "1_MAIN_MANUSCRIPT_FINAL.docx" "1_MAIN_MANUSCRIPT_FINAL_BACKUP_PRE_REVISION.docx"
```

### Step 1 — Fix table numbering (prerequisite for Steps 3–6)
Using python-docx: open the DOCX and rename every instance of "Table 7" that refers to the Demographic Profile table → "Table 6". Also fix all narrative references ("Table 7 presented the demographic profile…" → "Table 6 presented…"). Fix "Tables 3.3 and 3.4" → "Tables 8 and 9". This establishes correct numbering before TOC work.

Files: `1_MAIN_MANUSCRIPT_FINAL.docx`
Libraries: python-docx

### Step 2 — Blur GCash screenshots
Run the Python blur script on all 8 `com.globe.gcash.android` screenshots. Output blurred copies to `Screenshots/blurred/`. Do not overwrite originals yet — confirm quality first, then replace originals.

Files: `docs/handsoff/Screenshots/*.jpg` (GCash files only)
Libraries: Pillow

### Step 3 — Re-capture / replace privacy-flagged DOCX figure (image13)
image13.png (Figure 12 / Receipt Scanning) likely contains GCash screenshots embedded within the app UI. This image must be re-taken with blurred GCash data, or the existing image must be replaced with a blurred version. The blurred GCash screenshots from Step 2 may be used as the source for a re-capture.

**Manual action required:** Notify user that image13.png (Figure 12) needs manual replacement if it shows readable GCash transaction data.

### Step 4 — Fix Figure 15 description misplacement
Using python-docx: locate the paragraph "Figure 15 presents the Local AI Mode setup screen…" that currently appears after Figure 11's caption text, and move it to appear directly after the [image16] / Figure 15 caption paragraph.

### Step 5 — Condense/revise Chapter III technical paragraphs
Using python-docx, apply the following condensations in order:
1. FHS formula section: condense to ~200 words per panel notification item 1.
2. LLM API post-table paragraph: condense to 2–3 sentences per item 2.
3. AI Privacy Tiers paragraph: condense to 3 sentences per item 3.
4. Version history paragraph (v2.9.97–3.1.0): replace with one sentence per item 4.
5. Peso mascot paragraph: condense to 3–4 sentences per item 5.
6. Local LLM setup paragraph: condense to 1–2 sentences per item 6.
7. Kanban Done/Review phase: remove future-features list per item 7.
8. Figure 8 description: extract from embedded paragraph and place directly below Figure 8 caption.

### Step 6 — Revise writing style (LigTask alignment)
Apply D2 per-section revision notes throughout the manuscript:
- Break long run-on paragraphs in Chapter I (Project Context, app comparison section).
- Condense beneficiary descriptions in Purpose and Description.
- Trim Research Design closing paragraph.
- Fix Population/Locale narrative inconsistency (13 vs. 16 parents).
- Remove future-features list from Done/Review paragraph (duplicates Step 5 item 7).

### Step 7 — Add Figure 1 description paragraph
Insert a 2-sentence description paragraph below Figure 1's caption in Chapter I.

### Step 8 — Fix Figure 5 description opening
Add a one-sentence "Figure 5 presents…" opening to the paragraph following the Figure 5 caption.

### Step 9 — Condense Chapter IV Conclusions
Replace the three redundant conclusion blocks with one clean paragraph per objective per panel notification item 10.

### Step 10 — Rebuild TOC (List of Figures, List of Tables, Chapter Outline)
Using python-docx:
1. Populate List of Figures with all 16 figure entries (Figure 1–16) with page numbers.
2. Populate List of Tables with 8 real table entries (Tables 1–4, 6–9) — removing the ghost Table 5. Add page numbers.
3. Add chapter and section outline to the TOC body covering all four chapters and their sections.
4. Fix Chapter III heading "Designed and Developed of" → "Design and Development of".

### Step 11 — Final DOCX validation
Open the revised DOCX and verify:
- TOC List of Figures shows 16 entries, no gaps.
- TOC List of Tables shows 8 entries (no Table 5).
- No duplicate Table 7; Demographic Profile table is labeled Table 6.
- "Tables 3.3 and 3.4" reference does not appear anywhere.
- Figure 15 description paragraph is directly below Figure 15 caption.
- Figure 8 description is directly below Figure 8 caption.
- Figure 1 has a description paragraph.
- No redundant conclusion blocks in Chapter IV.
- All GCash screenshots in the DOCX are blurred.

---

## Digest

### Files the plan touches

| File | Block to change | Covering test |
|---|---|---|
| `docs/handsoff/1_MAIN_MANUSCRIPT_FINAL.docx` | TOC section (List of Figures, List of Tables, chapter outline); Table 7→6 rename; Figure 15 paragraph move; all Chapter III condensations (Steps 4–6); Figure 1/5/8 description additions; Chapter IV conclusions; "Tables 3.3 and 3.4" → "Tables 8 and 9"; heading fix | Manual: open DOCX, verify TOC entries, verify no duplicate Table 7, verify figure descriptions present and in correct positions |
| `docs/handsoff/Screenshots/*.jpg` (GCash 8 files) | Full-image Gaussian blur (radius 15), output to Screenshots/blurred/ | Visual inspection of blurred output — confirm numbers/names unreadable |
| `docs/handsoff/docx_media_extract/image17.png` | **FLAG ONLY** — user must supply replacement if "Figure 3.14" is confirmed burned in | Visual inspection by user |
| `docs/handsoff/docx_media_extract/image13.png` | **FLAG ONLY** — if GCash data visible inside batch-import screenshot, user must supply replacement | Visual inspection by user |

### Python libraries needed (all confirmed installed)

| Library | Version confirmed | Purpose |
|---|---|---|
| python-docx | 1.2.0 | Read/write DOCX paragraphs, runs, tables |
| Pillow | 12.3.0 | GaussianBlur on GCash screenshots |
| Python | 3.14.6 | Runtime |

### Build / test commands
There are no automated tests for a DOCX manuscript. Verification is manual in all steps.
- **Verify Step 1 (table renaming):** Open DOCX, Ctrl+F "Table 7" — only one result should remain (the LLM API table).
- **Verify Step 2 (blur):** Open blurred screenshots in image viewer — mobile number, account name, and transaction amounts must be unreadable.
- **Verify Step 10 (TOC):** Open DOCX, navigate to Table of Contents — List of Figures must show 16 entries, List of Tables must show 8 entries (no Table 5), chapter outline must list all four chapters with sections.
- **Verify full pass:** Compare against the original `.md` mirror to confirm no chapter text, table data, figure captions, or protected values were altered.

---

## Critical Findings Summary

1. **TOC is essentially empty:** The List of Figures and List of Tables headings exist but contain zero figure or table entries. The chapter/section outline is completely missing. All 16 figures and 8 real tables must be added with page numbers.

2. **Duplicate Table 7:** Two different tables are both labeled Table 7 in the manuscript body. The Demographic Profile table must be renamed Table 6 (matching the TOC list), along with all narrative references to it.

3. **Figure 15 description is misplaced:** The description sentence for Figure 15 currently appears after Figure 11 — four figures too early. It must be moved to directly follow the Figure 15 caption.

4. **image17.png (Figure 16) almost certainly has "Figure 3.14" burned into its pixels** — this is the specific case the user flagged. The user must supply a replacement PNG with the correct number.

5. **All 8 GCash screenshots need Gaussian blur** before the DOCX is finalized — these contain real account data (names, mobile numbers, transaction amounts) and are HIGH privacy risk.

6. **Chapter III contains several multi-hundred-word technical paragraphs** (FHS formula, version history, AI privacy tiers, Peso mascot, LLM fallback chain) that need to be condensed to 2–5 sentences each per panel-readability requirements.

7. **Chapter IV has three redundant conclusion blocks** each restating all three objectives — these must be collapsed into one clean paragraph per objective.

8. **Ghost Table 5** in the TOC ("Demographic Distribution of Needs-Assessment Respondents") does not correspond to any actual table in the body — that content exists as Figure 5. The Table 5 entry must be removed from the List of Tables.
