# FORMATTING AUDIT REPORT — Nov 10, 2026

> **Scope:** Cross-examination of all reference manuscripts and templates against `1_MAIN_MANUSCRIPT_FINAL.docx`.  
> **Method:** python-docx 1.2.0 — programmatic extraction of styles, section properties, and paragraph-level XML scans.  
> **Note:** Items marked `UNKNOWN` require visual inspection in Microsoft Word.  
> **Raw data:** `audit_raw.json` in this same folder for further reference.

---

## 0. File Inventory

| ID | File | Status |
|---|---|---|
| REF1 | `CAPSTONE_5_team_revision_backup.docx` | ✅ Found |
| REF2 | `LigTask_Manuscript_Reference.docx` | ✅ Found |
| TPL1 | `TEMPLATE_HABSS.docx` | ✅ Found |
| TPL2 | `TEMPLATE_LORMA_ACCESS_PLUS.docx` | ✅ Found |
| TPL3 | `Reference_LigTask_Manuscript.docx` | ✅ Found |
| TPL4 | `Template_ProgressReport_BSIT.docx` | ✅ Found |
| FINAL | `1_MAIN_MANUSCRIPT_FINAL.docx` | ✅ Found |

> **Important note on REF2 / TPL3:** `LigTask_Manuscript_Reference.docx` and `Reference_LigTask_Manuscript.docx` are identical files (same byte size: 6,605,439 bytes). They are treated as one source below.

---

## 1. Page Setup

### 1.1 Margin Consensus (all references)

| Reference | Top | Bottom | Left | Right | Paper | Orientation |
|---|---|---|---|---|---|---|
| REF1 — CAPSTONE_5 | 1.0 in | 1.0 in | **1.5 in** | 1.0 in | 8.5×11 in | portrait |
| REF2/TPL3 — LigTask | 0.944 in | 0.194 in | 1.25 in | 0.75 in | 8.5×11 in | portrait |
| TPL1 — HABSS | 1.0 in | 1.0 in | **1.5 in** | 1.0 in | 8.5×11 in | portrait |
| TPL2 — LORMA ACCESS+ | 1.0 in | 1.0 in | **1.5 in** | 1.0 in | 8.5×11 in | portrait |
| TPL4 — ProgressReport | 0.7 in | 0.7 in | 0.7 in | 0.7 in | 8.5×11 in | portrait |
| **FINAL** | **1.0 in** | **1.0 in** | **1.5 in** | **1.0 in** | **8.5×11 in** | **portrait** |

**Consensus standard (REF1, TPL1, TPL2 — the Lorma Colleges capstone templates):** T 1.0 / B 1.0 / L 1.5 / R 1.0 in.

> ⚠️ **Anomaly — FINAL Section 1:** Section index 1 (a continuation section in the middle of the document) has incorrect margins: Top 0.944 in, **Bottom 0.194 in**, Left 1.25 in, Right 0.75 in. This inherited from the LigTask reference document and was not corrected. The panel will likely notice tighter bottom margin on those pages.

### 1.2 Section Structure of FINAL

| Section | Top | Bottom | Left | Right | Diff 1st Page | Header PAGE# | Footer PAGE# |
|---|---|---|---|---|---|---|---|
| 0 (cover/front matter) | 1.0 | 1.0 | 1.5 | 1.0 | ✅ Yes | ❌ No | ❌ No |
| 1 (inherited LigTask margin) | 0.944 | **0.194** | **1.25** | **0.75** | ❌ No | ❌ No | ❌ No |
| 2 | 1.0 | 1.0 | 1.5 | 1.0 | ❌ No | ❌ No | ❌ No |
| 3 | 1.0 | 1.0 | 1.5 | 1.0 | ✅ Yes | ✅ Yes (PAGE field) | ❌ No |
| 4 | 1.0 | 1.0 | 1.5 | 1.0 | ✅ Yes | ✅ Yes (PAGE field) | ❌ No |

---

## 2. Body Text Font & Line Spacing

### 2.1 Font consensus (actual paragraph runs, not style definitions)

> **Why style definitions show null:** All .docx files use a custom `normal` style (lowercase) that inherits from a theme font. The actual font is embedded per-paragraph in run XML. Extracted from actual paragraph runs:

| Source | Font | Size | Weight | Alignment |
|---|---|---|---|---|
| REF1 — CAPSTONE_5 | Tahoma | 12 pt | Normal | Justify |
| TPL1 — HABSS | Tahoma | 12 pt | Normal | Justify |
| TPL2 — LORMA ACCESS+ | Tahoma | 12 pt | Normal | Justify |
| **FINAL** | **Tahoma** | **12 pt** | **Normal** | **Justify** |

✅ **MATCH** — Body font is correctly Tahoma 12 pt, justified, throughout the main text.

### 2.2 First-line indent

| Source | First-line indent |
|---|---|
| TPL1 — HABSS body paragraphs | 36 pt (~0.5 in) |
| TPL2 — LORMA body paragraphs | 36 pt (~0.5 in) |
| REF1 — CAPSTONE_5 body paragraphs | 36 pt (~0.5 in) |
| **FINAL — main chapter paragraphs** | **36 pt (~0.5 in)** ✅ |
| FINAL — technical background (subsection text) | No first-line indent ⚠️ |

> ⚠️ **Partial MISMATCH:** Most body paragraphs correctly use 36 pt first-line indent. However, the Technical Background subsection (paragraphs ~223–237, all the technology stack entries) has **no first-line indent**. References use consistent 36 pt throughout. This is a cosmetic inconsistency within the FINAL manuscript.

### 2.3 Line spacing

| Source | XML line value | Rule | Equivalent |
|---|---|---|---|
| REF1 — CAPSTONE_5 (title/front) | 240 | auto | Single (12 pt) |
| REF1 — CAPSTONE_5 (abstract area) | 480 | auto | **Double (24 pt)** |
| TPL1 — HABSS body | 480 | auto | **Double (24 pt)** |
| TPL2 — LORMA body | 240 | auto | Single (12 pt) |
| **FINAL — main chapter text** | **480** | **auto** | **Double (24 pt)** ✅ |
| FINAL — List of Figures/Tables area | None (inherited) | — | Unclear |

✅ **MATCH** — Chapter body text uses double spacing (XML 480/auto) matching TPL1/HABSS standard.

---

## 3. Heading Styles

### 3.1 Heading style definitions (from styles panel)

| Style | Property | REF1/TPL1 (HABSS/CAPSTONE5) | TPL2 (LORMA) | REF2/TPL3 (LigTask) | **FINAL** | Status |
|---|---|---|---|---|---|---|
| Heading 1 | Font size | 24 pt | 18 pt | 12 pt | 24 pt | ✅ Matches HABSS |
| Heading 1 | Bold | Yes | Yes | Yes | Yes | ✅ MATCH |
| Heading 1 | Space before | 24 pt | 24 pt | — | 24 pt | ✅ MATCH |
| Heading 1 | Space after | 6 pt | 6 pt | — | 6 pt | ✅ MATCH |
| Heading 2 | Font size | 18 pt | 16 pt | 12 pt | 18 pt | ✅ Matches HABSS |
| Heading 2 | Bold | Yes | Yes | Yes | Yes | ✅ MATCH |
| Heading 2 | Space before | 18 pt | — | — | 18 pt | ✅ MATCH |
| Heading 2 | Space after | 4 pt | 2 pt | — | 4 pt | ✅ MATCH |
| Heading 3 | Font family | Times New Roman | — | — | Times New Roman | ✅ MATCH |
| Heading 3 | Font size | 13.5 pt | — | 14 pt | 13.5 pt | ✅ MATCH |
| Heading 3 | Bold | Yes | — | Yes | Yes | ✅ MATCH |

### 3.2 ⚠️ CRITICAL — Heading style MISUSE in FINAL

> **Major Issue Found:** In the FINAL manuscript, the `Heading 1` and `Heading 2` styles are applied to **body text paragraphs** that are NOT chapter headings.  

**Paragraphs incorrectly styled as `Heading 1` (23 total):**
- Front matter body paragraphs (Acknowledgement text, Dedication text) — paragraphs 56–71
- Approval sheet body text — paragraphs 27, 35, 45
- Abstract body paragraphs — paragraphs 51–54
- `DEDICATION` label (para 66) — OK as heading
- `APPENDIX C` (para 648)

**Paragraphs incorrectly styled as `Heading 2` (7 total):**
- `INTRODUCTION` (para 162) — OK
- `Project Context` (para 164) — OK
- `Conceptual Framework` (para 188) — OK
- `Research Design` (para 242) — OK
- **`SmartSpend: An AI-Assisted...` title** (para 0) — this is styled as Heading 2 but is the manuscript title on the cover page
- **`Ellen F. Mangaoang, DIT`** (para 30) — adviser name incorrectly styled as Heading 2
- `System Usability Scale...` (para 649) — subsection inside Appendix C

**What the references show:** Body paragraphs should use `normal` style. Only actual chapter headings and section titles use Heading styles.

**Impact:** The document structure will be incorrect when navigated, the TOC generator would include body text paragraphs if regenerated, and heading numbering/styles will apply incorrectly.

---

## 4. Chapter Heading Format

### 4.1 Reference standard (from TPL1/TPL2)

From the HABSS and LORMA ACCESS+ templates, chapter headings use this pattern:
- `Chapter I` — "Title" style (large decorative), left-aligned, 36 pt Calibri Bold (this appears to be a navigation artifact)
- `CHAPTER I` / `Chapter I` — `normal` style, **centered**, Tahoma 12 pt Bold — this is the **actual visible heading**
- Chapter title (e.g., `INTRODUCTION`) — on the **same paragraph** separated by newline, **OR** in a separate paragraph, **centered**

From TPL1: `"CHAPTER III\nRESULTS AND DISCUSSION"` — chapter number and title in one paragraph with a line break (newline), centered.
From TPL2: `"Chapter I"` centered, then `INTRODUCTION` as next paragraph (`Heading 2`).

### 4.2 FINAL manuscript

```
[161] normal   | CENTER | "Chapter I"
[162] Heading 2 | CENTER | "INTRODUCTION"
```

✅ Chapter number and title are on separate lines, both centered — this is consistent with TPL2 pattern.

> However, the `Chapter I` label (para 161) uses `normal` style, not a dedicated heading style. References use the same `normal` + center + bold pattern, so this is acceptable.

---

## 5. Figure Captions

### 5.1 Reference standard

| Source | Style | Alignment | Font | Size | Format |
|---|---|---|---|---|---|
| REF1 (CAPSTONE_5) | normal | justify (LoF) / center (body) | Tahoma | 12 pt | `Figure 1.1. Title` |
| TPL1 (HABSS) | normal | justify / center | Tahoma | 12 pt | `Figure 1. Title` |
| TPL2 (LORMA) | normal | center | Tahoma | 12 pt | `Figure 1. Title` |

### 5.2 FINAL manuscript figure captions

**In List of Figures (LoF area, paras 124–142):**
- `normal` style, **justify** alignment
- Font: Tahoma, size NOT explicitly set (inherited)
- Format: `Figure 1.1.  Title  [tab]  page#`

**In body text (actual caption under figures):**
- `normal` style, **center** alignment ✅
- Font: Tahoma 12 pt ✅ (most)
- First-line indent: 36 pt (some), None (most body captions) — **inconsistent**
- Two figures (3.12, 3.13, 3.14) use **10 pt font** ❌

**Label format in FINAL:** `Figure 1.1. Title` (period after sub-number, no double period in body captions)
**Label format in LoF:** `Figure 1.1.  Title` (double space — cosmetic only)

**Issues found:**
1. ⚠️ Figures 3.12, 3.13, 3.14 have font size **10 pt** instead of 12 pt — inconsistent
2. ⚠️ Some figure captions have first-line indent (36 pt), others don't — inconsistent
3. ⚠️ No dedicated `Caption` style used — all use `normal` style (matches references, so not a strict error)

---

## 6. Table Captions

### 6.1 Reference standard

| Source | Alignment | Font | Size | Format |
|---|---|---|---|---|
| TPL1 (HABSS) | None/center | Tahoma | 12 pt | `Table 1. Title` |
| TPL2 (LORMA) | justify | Tahoma | 12 pt | `Table 1. Title` |

### 6.2 FINAL manuscript table captions

**In List of Tables (LoT area, paras 145–159):**
- `normal` style, **justify** alignment
- Font: Tahoma (some None/inherited), size NOT set explicitly
- Format: `Table 1.1.  Title  [tab]  page#`

**In body text (actual captions above/below tables):**
- `normal` style
- Alignment: CENTER (paras 173, 178) or **None** (unset — paras 256, 299, 307, 319, etc.)
- Font: Tahoma 12 pt (some) or None/inherited (Table 2.x)

**Issues found:**
1. ❌ **Tables 2.1 and 2.2 captions have no explicit font set** (None) — will inherit whatever the Word theme says
2. ❌ **Table caption alignment is inconsistent** — some are CENTER, some are unset (None/inherited), references use consistent centering
3. ⚠️ Label format `Table 1.1.` (chapter-numbered) vs references using `Table 1.` — this is a local style choice; check if adviser/panel expects chapter-numbered format

---

## 7. Abstract

### 7.1 Reference standard

| Source | Style | Alignment | Bold | Font | Indent |
|---|---|---|---|---|---|
| REF1 (CAPSTONE_5) | normal | CENTER | ✅ Yes | Tahoma 12 pt | — |
| TPL1 (HABSS) | normal | CENTER | ✅ Yes | Tahoma 12 pt | — |
| TPL2 (LORMA) | normal | CENTER | ✅ Yes | Tahoma 12 pt | — |

### 7.2 FINAL manuscript

```
[50] normal | CENTER | bold=True | font=Tahoma 12pt | "ABSTRACT"
```

✅ **MATCH** — `ABSTRACT` label is centered, bold, Tahoma 12 pt.

> ✅ Abstract body paragraphs (51–54) are styled as `Heading 1` — see Section 3.2 for the misuse concern. Visually they appear as 12 pt Tahoma bold text, which may look fine, but the structure is incorrect.

---

## 8. References Section

### 8.1 Reference standard (APA hanging indent)

Standard academic formatting: hanging indent with left indent ~0.5 in, first-line indent ~-0.5 in (negative, pulling first line to the left margin).

### 8.2 FINAL manuscript

```
[403] normal | fi=None  | li=None | "References"           ← heading para
[404] normal | fi=-45.0 | li=45.0 | "Agila: Finance Coach..."
[405] normal | fi=-45.0 | li=45.0 | ""
[406] normal | fi=-45.0 | li=45.0 | "Ariely, D. (2008)..."
[407] normal | fi=-45.0 | li=81.0 | "https://www.anthropic.com/..."  ← URL continuation, wider indent
```

> fi = first-line indent in pt, li = left indent in pt. 45 pt ≈ 0.625 in.

✅ **APA hanging indent is correctly applied** — fi=-45 pt, li=45 pt = proper hanging indent.

> ⚠️ One URL continuation line has `li=81.0` (wider indent) — this is a formatting inconsistency but minor.
> ⚠️ Empty paragraphs between entries (`fi=-45, li=45` with blank text) — this appears to be double-spacing method via blank lines, which is non-standard. References should use paragraph spacing (`space_after`) rather than blank lines. Visual result may look acceptable.

---

## 9. Appendix Headings

### 9.1 Reference standard (TPL2 — LORMA ACCESS+)

```
Appendix A | normal | CENTER | Tahoma 12 pt | bold=True
Appendix B | normal | CENTER | Tahoma 12 pt | bold=True
APPENDIX D | normal | CENTER | Tahoma 12 pt | bold=True
```

Pattern: `Appendix X` or `APPENDIX X`, centered, bold, normal style.

### 9.2 FINAL manuscript

| Para | Style | Alignment | Bold | Font | Text |
|---|---|---|---|---|---|
| 110 (LoT area) | normal | JUSTIFY | — | Tahoma | `Appendix A – Survey Questionnaire [tab] 84` |
| 475 | normal | CENTER | ✅ True | Tahoma | `APPENDIX A` |
| 622 | normal | CENTER | ✅ True | Tahoma | `APPENDIX B` |
| 648 | **Heading 1** | JUSTIFY | — | Tahoma 12 pt | `APPENDIX C` ❌ |
| 777 | normal | CENTER | ✅ True | (None/inherited) | `Appendix D` |
| 780 | normal | CENTER | ✅ True | (None/inherited) | `Appendix E` |

**Issues:**
1. ❌ `APPENDIX C` (para 648) is styled as `Heading 1` with **JUSTIFY** alignment — should be `normal` + **CENTER** like A, B, D, E
2. ⚠️ `Appendix D` and `Appendix E` (paras 777, 780) have no explicit font set — will inherit theme font
3. ⚠️ Mix of all-caps (`APPENDIX A/B/C`) and title-case (`Appendix D/E`) — inconsistent casing

---

## 10. Table of Contents

### 10.1 Reference standard

No reference file uses Word's built-in TOC styles (`TOC 1`, `TOC 2`). All references use manually-formatted `normal` style paragraphs with tabs. This is consistent with the Lorma Colleges manuscript tradition.

### 10.2 FINAL manuscript TOC

Paragraphs 77–113 form the TOC area:
- Style: `normal`
- Alignment: JUSTIFY
- Line spacing: 480/auto (double)
- Font: Tahoma 12 pt (or None/inherited for some entries)
- Indentation: First-line indent 36 pt for sub-entries (e.g., `Project Context`)
- Format: `Entry [tab fills] page#`

**Issues:**
1. ⚠️ **TOC uses manual tabs, not dot leaders** — references show the same manual tab approach; no dot leaders in any reference either. So this is consistent, but academic practice typically expects dot leaders.
2. ⚠️ **Font missing on lower TOC entries** (paras 96–113, font=None) — these will inherit the theme default font, which may not be Tahoma. Should explicitly set Tahoma 12 pt.
3. ⚠️ The TOC heading `TABLE OF CONTENTS` appears twice (paras 75 and 80). Para 75 is centered (likely the visible heading), para 80 is in the justify-flow TOC area. May be a duplicate.

---

## 11. List of Figures / List of Tables

### 11.1 FINAL manuscript

**List of Figures (paras 124–142):**
- `LIST OF FIGURES` label: normal, justify, Tahoma (no size set)
- Entry format: `Figure X.X.  Title [tab] page#` — justify
- Inconsistent font: Tahoma (some entries), None (Figure 3.12, 3.13, 3.14)

**List of Tables (paras 145–159):**
- `LIST OF TABLES` label: normal, justify, Tahoma (no size set)
- Entry format: `Table X.X.  Title [tab] page#` — justify
- Inconsistent font: some entries have Tahoma, Table 2.1/2.2 have None

**Reference standard (TPL1/TPL2):** LoF/LoT headers use `normal`, centered/bold; entries use `normal`, justify, Tahoma 12 pt.

**Issues:**
1. ⚠️ `LIST OF FIGURES` and `LIST OF TABLES` labels are not bold and not centered — references show centered bold labels
2. ⚠️ Some entries have no explicit font size (None) — should be uniformly Tahoma 12 pt

---

## 12. Page Numbers

### 12.1 Reference standard

**TPL4 (ProgressReport)** — the only template with actual page numbers:
- Footer: `"Lorma Colleges – College of Computer Studies and Engineering | BS Information Technology Capstone Project  Page  of"`
- PAGE field in footer ✅

**REF1 (CAPSTONE_5), TPL1 (HABSS), TPL2 (LORMA)** — page number detection: **none found by python-docx**. This is likely because the page numbers are complex fields in multi-section headers/footers that python-docx does not expose as "PAGE" in simple XML scan of section 0.

### 12.2 FINAL manuscript

- **Sections 0–2:** No PAGE field detected in header or footer
- **Section 0 header text:** `"College of Computer Studies and Engineering LORMA COLLEGES | City of San Fernando..."` (institutional header)
- **Sections 3–4:** PAGE field **IS present in the header** ✅

> ⚠️ **Issue:** Page numbers appear to be in the **header** of sections 3–4, not in the footer. Standard academic manuscripts place page numbers at the **bottom center** (footer) or **top right** (header). The institutional header text already occupies the header. This may cause overlap or confusion between the institutional header and the page number.
>
> **Manual verification required:** Open the FINAL in Word, check where page numbers actually appear visually on pages in sections 3 and 4. The PAGE field may be on the same line as the institutional header or in a separate element.

---

## 13. Header Content

### 13.1 FINAL manuscript header (Section 0)

```
College of Computer Studies and Engineering
LORMA COLLEGES
City of San Fernando, La Union
Tel. No. (072) 888-2616 loc. 325 and Fax No. (072) 242-3628
Center of Development for Excellence in I.T Education in Region I
```

**Section 0** has `different_first_page_header_footer = True`, so the first page (title page) has a different header.
**Sections 1–2** are linked to Section 0's header.
**Sections 3–4** have empty header text (linked or separate but detected as empty) with the PAGE field present.

---

## 14. Consolidated Mismatch Summary (Actionable Items)

Priority: 🔴 HIGH (panel will likely notice) | 🟡 MEDIUM (academic standard) | 🟢 LOW (cosmetic)

| # | Priority | Element | Reference Standard | FINAL Value | Recommended Action |
|---|---|---|---|---|---|
| 1 | 🔴 HIGH | **Section 1 bottom margin** | 1.0 in (all Lorma templates) | **0.194 in** (severely narrow) | Fix Section 1 margins: T 1.0 / B 1.0 / L 1.5 / R 1.0 in. This was inherited from LigTask reference and not corrected. |
| 2 | 🔴 HIGH | **Heading 1 misuse — body text** | Heading styles on headings only | 23 `Heading 1` paragraphs — most are body text (Acknowledgement, Abstract, Dedication paragraphs) | Change body text paragraphs (Acknowledgement, Abstract, Dedication text) from `Heading 1` → `normal` style |
| 3 | 🔴 HIGH | **Page number placement** | Footer (bottom) or header (top right), clear | PAGE field in header sections 3–4; may overlap institutional header | Open in Word and verify page numbers don't overlap with college header. Move to footer (bottom center) if overlapping. |
| 4 | 🟡 MEDIUM | **APPENDIX C alignment & style** | normal, centered, bold | `Heading 1`, justify, not bold | Change para 648 (`APPENDIX C`) to `normal` style + CENTER alignment |
| 5 | 🟡 MEDIUM | **Table 2.1/2.2 caption font** | Tahoma 12 pt | None/inherited | Explicitly set Tahoma 12 pt on Table 2.1 and Table 2.2 caption paragraphs |
| 6 | 🟡 MEDIUM | **Figure 3.12/3.13/3.14 caption font** | Tahoma 12 pt | 10 pt | Change to Tahoma 12 pt |
| 7 | 🟡 MEDIUM | **Table caption alignment** | Consistent CENTER (references) | Mixed: CENTER (some) vs None/unset (others) | Set all in-body table captions to CENTER alignment |
| 8 | 🟡 MEDIUM | **Technical Background first-line indent** | 36 pt throughout | 0 pt (no indent) | Add 36 pt first-line indent to subsection body paragraphs (~223–237) |
| 9 | 🟡 MEDIUM | **Appendix casing inconsistency** | Consistent ALL CAPS (APPENDIX A/B/C) in Lorma templates | Mixed: ALL CAPS (A/B/C) + title-case (Appendix D/E) | Normalize to `APPENDIX D` and `APPENDIX E` |
| 10 | 🟡 MEDIUM | **LoF/LoT entry font** | Tahoma 12 pt explicit | None (inherited) on some entries | Set Tahoma 12 pt on all LoF/LoT entries that show font=None |
| 11 | 🟡 MEDIUM | **LoF/LoT labels (LIST OF FIGURES/TABLES)** | Centered, bold | Justify, not bold | CENTER + bold the two list labels |
| 12 | 🟢 LOW | **Abstract body style** | `normal` | `Heading 1` (visually OK, structurally wrong) | Change abstract body paragraphs (51–54) from `Heading 1` → `normal` |
| 13 | 🟢 LOW | **Appendix D/E font** | Tahoma 12 pt | None/inherited | Set Tahoma 12 pt on Appendix D and E heading paragraphs |
| 14 | 🟢 LOW | **Duplicate TABLE OF CONTENTS entry** | One label | Appears twice (para 75 and 80) | Verify in Word — one may be hidden or on a different page |
| 15 | 🟢 LOW | **References — blank line spacers** | Paragraph spacing (space_after) | Blank paragraphs between entries | Minor: cosmetically same, structurally non-standard |

---

## 15. Manual Inspection Checklist (UNKNOWN — require Word)

The following cannot be reliably extracted via python-docx and must be checked visually in Microsoft Word:

| # | Priority | Item | What to look for |
|---|---|---|---|
| 1 | 🔴 HIGH | **Page number visual position** | Do page numbers overlap with institutional header on body pages? Are they bottom center or top right? |
| 2 | 🔴 HIGH | **Section 1 margin visual impact** | Which pages fall in Section 1 (0.194 in bottom margin)? Are those pages visually cut off at the bottom? |
| 3 | 🟡 MEDIUM | **Chapter heading visual** | Are 'CHAPTER I' and 'INTRODUCTION' clearly separated with proper spacing? No text running together? |
| 4 | 🟡 MEDIUM | **TOC dot leaders** | Do dot leaders (...) connect TOC entries to page numbers? All references use manual tabs instead, so this may be intentional. |
| 5 | 🟡 MEDIUM | **TOC page number alignment** | Are page numbers right-aligned at the right margin in the TOC? |
| 6 | 🟡 MEDIUM | **Figure caption position** | Is caption BELOW each figure in the body? |
| 7 | 🟡 MEDIUM | **Table caption position** | Is caption ABOVE each table in the body? (academic standard) |
| 8 | 🟡 MEDIUM | **Roman numerals for front matter** | Pages before Chapter I (title, TOC, abstract) — do they show roman numerals (i, ii, iii...)? |
| 9 | 🟡 MEDIUM | **Title page layout** | School name, program, title, authors, date — positioning and spacing match TPL2 (LORMA ACCESS+) |
| 10 | 🟡 MEDIUM | **Approval sheet layout** | Signature lines, panelist names, margins — match reference format? |
| 11 | 🟡 MEDIUM | **Section breaks before chapters** | Does each chapter start on a new page (page break or section break)? |
| 12 | 🟡 MEDIUM | **Appendix page breaks** | Does each appendix (A, B, C, D, E) start on its own page? |
| 13 | 🟡 MEDIUM | **Reference heading alignment** | Is the `References` label centered and bold? (detected as plain `normal` style) |
| 14 | 🟢 LOW | **Running header on body pages** | What does the header show on chapter body pages? College name? Or page number? |
| 15 | 🟢 LOW | **Heading numbering** | Are chapter section headings numbered (1.1, 1.2...) or un-numbered? Match references. |
| 16 | 🟢 LOW | **Abstract paragraph indent** | Is abstract body text first-line indented or block format? |
| 17 | 🟢 LOW | **Bold/italic H3 usage** | Are H3 paragraphs (`Statement of Objectives`, `Section A`) italic or bold only? |
| 18 | 🟢 LOW | **Signature/affiliation page** | Is there a curriculum vitae / biodata section? Format matches reference? |
| 19 | 🟢 LOW | **Acknowledgement heading alignment** | Is `ACKNOWLEDGEMENT` centered? |
| 20 | 🟢 LOW | **Figures with 10 pt captions** | Visually noticeable? Figs 3.12, 3.13, 3.14 captions are 10 pt. |

---

## 16. Per-Reference Comparison Tables

### REF1 — CAPSTONE_5_team_revision_backup.docx

| Element | Reference | FINAL | Status |
|---|---|---|---|
| Top margin | 1.0 in | 1.0 in | ✅ MATCH |
| Bottom margin | 1.0 in | 1.0 in (Sec 0,2–4) / **0.194 in (Sec 1)** | ❌ MISMATCH (Sec 1) |
| Left margin | 1.5 in | 1.5 in | ✅ MATCH |
| Right margin | 1.0 in | 1.0 in | ✅ MATCH |
| Paper size | 8.5×11 in | 8.5×11 in | ✅ MATCH |
| Body font | Tahoma 12 pt | Tahoma 12 pt | ✅ MATCH |
| Body alignment | Justify | Justify | ✅ MATCH |
| First-line indent | 36 pt | 36 pt (most) / 0 pt (tech bg) | ⚠️ PARTIAL |
| Line spacing | Double (480/auto) | Double (480/auto) | ✅ MATCH |
| Abstract label | CENTER, bold | CENTER, bold | ✅ MATCH |
| Figure label format | `Figure 1.1. Title` | `Figure 1.1. Title` | ✅ MATCH |
| Heading 1 font size | 24 pt (style def) | 24 pt (style def) | ✅ MATCH |
| APA hanging indent | -45 pt / 45 pt | -45 pt / 45 pt | ✅ MATCH |

---

### TPL1 — TEMPLATE_HABSS.docx

| Element | Reference | FINAL | Status |
|---|---|---|---|
| Top margin | 1.0 in | 1.0 in | ✅ MATCH |
| Bottom margin | 1.0 in | 1.0 in (most) / 0.194 in (Sec 1) | ❌ MISMATCH (Sec 1) |
| Left margin | 1.5 in | 1.5 in | ✅ MATCH |
| Right margin | 1.0 in | 1.0 in | ✅ MATCH |
| Body font | Tahoma 12 pt | Tahoma 12 pt | ✅ MATCH |
| Figure caption style | `normal` style | `normal` style | ✅ MATCH |
| Figure caption align | CENTER (body) | CENTER (body) | ✅ MATCH |
| Figure label format | `Figure 1. Title` | `Figure 1.1. Title` | ⚠️ DIFF (chapter-numbered in FINAL) |
| Table label format | `Table 1. Title` | `Table 1.1. Title` | ⚠️ DIFF (chapter-numbered in FINAL) |
| Appendix format | `Appendix X`, normal, center | Mixed — see Section 9 | ❌ MISMATCH (C misaligned) |
| ABSTRACT label | normal, center, bold | normal, center, bold | ✅ MATCH |
| Sections with page# | 5 (of 12) | 2 (of 5) in header | ⚠️ UNKNOWN placement |
| LoF/LoT labels | Centered, bold | Justify, not bold | ❌ MISMATCH |

---

### TPL2 — TEMPLATE_LORMA_ACCESS_PLUS.docx

| Element | Reference | FINAL | Status |
|---|---|---|---|
| Top margin | 1.0 in | 1.0 in | ✅ MATCH |
| Bottom margin | 1.0 in | 1.0 in (most) / 0.194 in (Sec 1) | ❌ MISMATCH (Sec 1) |
| Left margin | 1.5 in | 1.5 in | ✅ MATCH |
| Right margin | 1.0 in | 1.0 in | ✅ MATCH |
| Body font | Tahoma 12 pt | Tahoma 12 pt | ✅ MATCH |
| Heading 1 size (style) | 18 pt | 24 pt | ❌ MISMATCH (but HABSS uses 24, so FINAL follows HABSS) |
| Figure captions | normal, center, Tahoma 12 pt | normal, center, Tahoma 12 pt (mostly) | ✅ MATCH |
| Table captions | normal, justify, Tahoma 12 pt | normal, CENTER/None, mixed font | ❌ MISMATCH (alignment inconsistent) |
| Appendix headings | normal, center, bold | Mixed styles — see Sec 9 | ❌ MISMATCH (Appendix C) |
| Chapter heading | normal, center, bold | normal, center, bold | ✅ MATCH |

---

### TPL4 — Template_ProgressReport_BSIT.docx

> This is a progress report template, not a capstone manuscript template. Margins differ significantly (0.7 in all sides). Used here only to verify footer page number format.

| Element | Reference | FINAL | Status |
|---|---|---|---|
| Footer page number | ✅ Present ("Page X of Y") | PAGE field in header secs 3–4 | ⚠️ DIFFERENT PLACEMENT |
| Institutional footer | "Lorma Colleges – CCSE \| BS IT Capstone Project" | (empty footer) | UNKNOWN — may be intentional |

---

## 17. Summary of Priority Issues

### 🔴 HIGH — Fix before panel review
1. **Section 1 bottom margin = 0.194 in** — extremely narrow, pages in that section will look wrong when printed. Fix to 1.0 in.
2. **Body text styled as Heading 1** — 20+ paragraphs (Acknowledgement, Abstract, Dedication text) are styled as `Heading 1`. This corrupts document structure even if visually similar.
3. **Page number position unclear** — PAGE field in header may overlap with multi-line institutional college header. Verify visually, move to footer if needed.

### 🟡 MEDIUM — Fix if time allows
4. APPENDIX C heading: wrong style (Heading 1) and wrong alignment (justify → should be center)
5. Table 2.1 / 2.2 and Figure 3.12–3.14 caption fonts: None/10 pt → set to Tahoma 12 pt
6. Table caption alignment: set all to CENTER consistently
7. Technical background paragraphs: add 36 pt first-line indent for consistency
8. APPENDIX D/E: set explicit Tahoma 12 pt font
9. APPENDIX D/E casing: normalize to ALL CAPS (`APPENDIX D`, `APPENDIX E`)
10. LoF/LoT labels: CENTER + Bold

### 🟢 LOW — Cosmetic
11. Abstract body paragraphs: change from `Heading 1` → `normal` style
12. References: replace blank-line spacers with paragraph spacing
13. Duplicate TABLE OF CONTENTS entry: verify and remove one

---

*Report generated by `run_format_audit.py` using python-docx 1.2.0.*  
*All 7 files successfully parsed. Deep paragraph scan of FINAL: 785 paragraphs examined.*  
*Raw extraction data saved in `audit_raw.json`.*
