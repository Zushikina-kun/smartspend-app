# SmartSpend — Formatting Audit Report
**Date:** August 2026 | **Purpose:** Cross-examination of our working .docx against both Lorma templates

---

## SOURCE FILES EXAMINED

| Label | File | Size |
|---|---|---|
| OUR DOC | `SMARTSPEND_CAPSTONE_WORKING.docx` | 513 paragraphs, 3 tables, 7 images |
| TEMPLATE 1 | `templates/TEMPLATE_LORMA_ACCESS_PLUS.docx` | 595+ paragraphs, 9 tables, 49 images |
| TEMPLATE 2 | `templates/TEMPLATE_HABSS.docx` | ~400 paragraphs, 4 tables, 8 images |

---

## PAGE SETUP — ALL THREE MATCH ✅

| Setting | Our Doc | Template 1 | Template 2 |
|---|---|---|---|
| Page size | 8.50" × 11.00" | 8.50" × 11.00" | 8.50" × 11.00" |
| Top margin | 1.000" | 1.000" | 1.000" |
| Bottom margin | 1.000" | 1.000" | 1.000" |
| Left margin | 1.500" | 1.500" | 1.500" |
| Right margin | 1.000" | 1.000" | 1.000" |
| Header distance | 0.500" | 0.500" | 0.500" |
| Footer distance | 0.500" | 0.500" | 0.500" |

**Conclusion:** Page setup is identical across all three. No changes needed.

---

## FONT — ALL THREE MATCH ✅

| Setting | Our Doc | Both Templates |
|---|---|---|
| Body font | **Tahoma 12pt** | **Tahoma 12pt** |
| Section headers (manual bold) | Tahoma 12pt Bold | Tahoma 12pt Bold |
| Table cells | Tahoma 12pt | Tahoma 12pt |
| Abstract body | Tahoma 12pt | Tahoma 12pt **Italic** |

**Note:** Both templates italicize abstract body text. Our working doc does not. → **Fix needed.**

---

## PARAGRAPH FORMATTING — CONFIRMED LORMA STANDARD

| Element | Font | Size | Bold | Align | SpaceBefore | SpaceAfter | FirstIndent |
|---|---|---|---|---|---|---|---|
| Title page lines | Tahoma | 12pt | varies | CENTER | inherited | 0pt | none |
| Section headers (e.g., "ACKNOWLEDGEMENT") | Tahoma | 12pt | **True** | CENTER | 12pt | 0pt | none |
| Chapter labels (e.g., "Chapter I") | Tahoma | 12pt | **True** | JUSTIFY | 12pt | 12pt | none |
| Body paragraphs | Tahoma | 12pt | False | **JUSTIFY** | 12pt | 12pt | **0.5"** |
| Right-aligned sign-offs ("The Researchers") | Tahoma | 12pt | True | RIGHT | inherited | inherited | none |
| Initials ("BAD", "CJMR", "DASM") | Tahoma | 12pt | True | RIGHT | inherited | 0pt | none |
| Table of Contents entries | Tahoma | 12pt | varies | JUSTIFY | 12pt | 12pt | 0.5" |
| References entries | Tahoma | 12pt | False | JUSTIFY | 12pt | 0pt | 0.5" (hanging) |
| Keywords line | Tahoma | 12pt | **Bold label** + Italic value | JUSTIFY | inherited | 0pt | none |

**Key rule:** All body text = Tahoma 12pt, JUSTIFY, 12pt space-before, 12pt space-after, 0.5" first-line indent.

---

## STYLE USAGE — IMPORTANT FINDING ⚠️

Both templates use **"normal"** (lowercase) for virtually all paragraphs — body, headers, captions, everything.
Actual formatting is applied at the **run level** (direct font/size/bold/align on each paragraph/run), not via Word styles.

| Style | Our Doc | Template 1 | Template 2 |
|---|---|---|---|
| `normal` | 475 uses | 595 uses | ~400 uses |
| `Heading 1` | 17 uses | 0 uses | 0 uses |
| `Heading 2` | 8 uses | 0 uses | 0 uses |
| `Heading 3` | 13 uses | 0 uses | 0 uses |

**Problem in our doc:** We use Heading 1/2/3 styles for body paragraphs. This causes them to appear in the Navigation pane as headings and may cause formatting inconsistencies when the document is opened in different Word versions or printed. Both templates use only `normal` with direct formatting.

**Fix needed:** When injecting new content, use `normal` style + direct run formatting, not Heading styles.

---

## DOCUMENT STRUCTURE — GAPS IN OUR DOC ❌

| Section | Our Doc | Template 1 | Template 2 | Action |
|---|---|---|---|---|
| Title Page | ✅ | ✅ | ✅ | Already present |
| Approval Sheet | ❌ MISSING | ✅ | ✅ | **Add** |
| Abstract | ❌ MISSING | ✅ | ✅ | **Add** |
| Acknowledgement | ✅ | ✅ | ✅ | Update text only |
| Dedication | ✅ | ✅ | ✅ | Update text only |
| Table of Contents | ✅ (partial) | ✅ | ✅ | Update to reflect Ch3+Ch4 |
| List of Figures | ❌ MISSING | ✅ | ✅ | **Add placeholder** |
| List of Tables | ❌ MISSING | ✅ | ✅ | **Add placeholder** |
| Chapter I | ✅ (Ch1+Ch2 only) | ✅ | ✅ | Update text |
| Chapter II | ✅ | ✅ | ✅ | Update text |
| Chapter III | ❌ MISSING | ✅ | ✅ | **Add** |
| Chapter IV | ❌ MISSING | ✅ | ✅ | **Add** |
| References | ✅ (outdated, ~28 refs) | ✅ | ✅ | **Replace** with full 50+ ref list |
| Appendix A (Validation Certs) | ❌ MISSING | ✅ | ✅ | **Add** |
| Appendix B (Survey) | ✅ | ✅ | ✅ | Update with new Part IV questions |
| Appendix C (Consent Form) | ✅ | ✅ | ✅ | Already present |
| Appendix D (SUS) | ✅ | ✅ | ✅ | Already present — rename from C |
| Curriculum Vitae | ✅ (all 3) | ✅ | ✅ | Already present, keep as-is |

---

## TABLE AUDIT — NEEDS UPDATES

| Table | Our Doc | Status | Action |
|---|---|---|---|
| Table 1.1 Gap Analysis | ✅ 4 rows × 3 cols | Outdated — 3 gaps only | Update with revised 3-level gap analysis |
| Table 1.2 Feature Comparison | ✅ 17 rows × 8 cols | Missing GCash Pera Coach column, missing new feature rows | **Expand to 19 rows × 9 cols** |
| Table 2.1 Respondents | ✅ 8 rows × 2 cols | Missing validator rows | **Add validator rows** |
| Table 2.2 LLM Comparison | ❌ MISSING | Not in document | **Add 15-model table** |
| Table 2.3 Kanban Phases | ❌ MISSING | Not in document | **Add 7-phase table** |
| Table 3.x FHS Interpretation | ❌ MISSING | Not in document | **Add score range table** |
| Table 3.x Lightweight Mode | ❌ MISSING | Not in document | **Add component table** |
| SUS Results Table | ❌ MISSING | Placeholder needed | **Add placeholder** |

---

## IMAGE AUDIT — EXISTING IMAGES TO PRESERVE

| Image | Size | What It Is | Action |
|---|---|---|---|
| IMG1 | 4.22" × 2.60" | Figure 1.1 — Financial Literacy bar chart (BSP) | **Keep** |
| IMG2 | 6.00" × 3.48" | Figure 1.2 — IPO Conceptual Framework | **Keep** |
| IMG3 | 6.00" × 3.36" | Figure 2.1 — SUS Score Interpretation chart | **Keep** |
| IMG4 | 6.00" × 3.21" | Figure 2.2 — Agile Kanban Workflow | **Keep** |
| IMG5 | 1.76" × 1.79" | Brix A. Directo profile photo (CV) | **Keep** |
| IMG6 | 1.80" × 2.06" | Cyrille John M. Rubis profile photo (CV) | **Keep** |
| IMG7 | 1.88" × 2.05" | Djaunathan Albert S. Madayag profile photo (CV) | **Keep** |

All 7 images must be preserved in their exact positions. New content is inserted **after** the existing Chapter II end.

---

## REFERENCES AUDIT — OUTDATED

Our doc has **28 references** (outdated — missing all 2026 sources). The revised manuscript has **50+ references**.
Missing entirely: BSP 2025, GCash/Mynt 2026, EY 2026, Plaid 2026, NielsenIQ 2026, PSA 2025, Bloomberg 2026, SWS 2026, Deloitte 2026, Meyll et al. 2025, Financial Health Network 2026, Strivecloud 2026, Wajid et al. 2025, Cambridge 2025, Springer 2026, Duhigg 2012, Nielsen 2006, Sweller 1988, Ramsey 2003, Social Weather Stations 2026, and more.

**Action:** Replace the entire References section with the full 50+ list from SMARTSPEND_REVISED_MANUSCRIPT.md.

---

## CONTENT UPDATES NEEDED IN EXISTING SECTIONS

### Title Page
- "April 2026" → "August 2026" ✅ minor fix

### Chapter I — Project Context
- Add new BSP CFIS 2025 stats (50% ownership, 86% household, SWS 58%)
- Add GCash Pera Coach as competitor (March 2026)
- Table 1.2: expand to 9 apps (add GCash Pera Coach column) and 19 feature rows
- Add new stats: GCash 41.5M users, PSA ₱2.74T GDP, NielsenIQ 99%/52%, EY 49%/18%

### Chapter I — Statement of Objectives
- Objective statement: "parents aged 35 to 55 as the **primary** focus, and young professionals aged 21 to 35 as a secondary demographic"

### Chapter I — Scope and Limitations
- API key section: already updated (Remote Config, not embedded) ✅

### Chapter I — Purpose and Description
- Add: Impulse Pause (loss aversion, Meyll et al. Spendception), Warning Decay, gamification stats (22% boost)
- Add: App Settings / Lite Mode / progressive disclosure paragraph
- Update badge count: already 23 ✅

### Chapter I — Technical Background
- Add: Firebase Remote Config + App Check paragraph
- Add: Smart Import 4-mode system (replaces old "6 input methods")
- Update LLM section: Gemini 3.1 Flash-Lite as primary (not Groq LLaMA 3.1)
- Add: 29 agentic actions table
- Add: dual-mode FHS paragraph (already partially present)

### Chapter II — Population and Locale
- Add explicit inclusion criteria bullets (4 bullets per group)
- Remove: "Susan C. Arquisal" named reference → use credential-based language
- Add: Table 2.1 validator rows

### Chapter II — Data Gathering
- Already has 6-step procedure ✅

### Chapter II — Software Methodology
- Add: Table 2.3 Kanban phases and deliverables

---

## SUMMARY — WHAT THE UPDATE SCRIPT MUST DO

1. **Preserve** all 7 images, all CV content, all Appendices B/C/D exactly
2. **Fix** title page date (April 2026 → August 2026)
3. **Add** Approval Sheet page (after title, before Abstract)
4. **Add** Abstract section (after Approval Sheet)
5. **Update** ToC to include Ch3, Ch4, new tables/figures
6. **Add** List of Figures and List of Tables placeholders
7. **Update** Chapter I text with new content (stats, Pera Coach, objectives fix, new tables)
8. **Expand** Table 1.2 (9 apps, 19 features)
9. **Update** Table 2.1 (add validator rows)
10. **Update** Chapter II text (population wording, inclusion criteria)
11. **Add** Table 2.3 Kanban phases
12. **Add** Chapter III — Results and Discussion (full)
13. **Add** Chapter IV — Conclusions and Recommendations (full)
14. **Replace** References section (full 50+ list)
15. **Add** Appendix A — Validation Certificates (before existing Appendix B/Survey)
16. All text: `normal` style, Tahoma 12pt, JUSTIFY, 12pt sb/sa, 0.5" first-line indent
17. All section headers: `normal` style, Tahoma 12pt **Bold**, CENTER, 12pt sb
18. Abstract body: Tahoma 12pt **Italic**, JUSTIFY, 0.5" first-line indent

---

*Generated by deep_inspect.py cross-examination — August 2026*
