# Manuscript v4 — what changed and what's still blank
File: `CAPSTONE_LucidFrame_-_SMARTSPEND__4_.docx` (built from the last delivered __3_; your original is untouched).
Only `word/document.xml` differs from __3_. All new paragraphs/tables clone the document's own formatting.

## Added
- **Table 2.2** (Kanban phases, 3 cols) at the end of Chapter II.
- **Chapter III** (Results & Discussion) and **Chapter IV** (Conclusions & Recommendations), before References.
  Chapter III: Objective 1 (placeholders), Objective 2 (LLM benchmark Table 3.2 with 20 models, FHS computation, system development results incl. audit trail, Peso, privacy tiers, local LLM), Objective 3 (SUS: blank Table 3.3, blank Table 3.4).
- **16 references** inserted alphabetically (Ariely, Bitrián fix, CBA-MI/Comerton-Forde, CFPB, Duhigg, Faulkner, FHN 2021/2026, Groq, Kahneman & Tversky, Li, Nielsen & Landauer, Ramsey, Thaler & Sunstein, Wajid, Warren & Tyagi).

## Existing text I changed (6 paragraphs, nothing else)
1. Abstract, FHS sentence (now "adapting ideas from CBA-MI Observed scale + FinHealth pillars").
2. Abstract, SUS sentence: the made-up results/"expert validation" sentence is replaced by "usability is being evaluated… results will be reported once data collection is complete."
3. BSP paragraph: household access 86% → 85% (Consumer Expectations Survey, up from 74%), source distinction stated.
4. Gamification: 25 → 36 achievement badges.
5. UNSGSA reference title → "Measuring financial health: Concepts and considerations".
6. Bitrián, Buil & Catalán reference: wrong DOI (IJBM-09-2020-0491) → correct IJBM-02-2021-0074.

## Search these tags (Ctrl+F `[[`) — 69 spots
- `[[PENDING` (52): survey-dependent text. Fill ONLY from real responses.
- `[[VERIFY` (3): Cerebras key still active? Gemini quotas from AI Studio? Local-mode backup folder reachable on Android 11+?
- `[[N]]`, `[[mean]]`, `[[SD]]`, `[[adjective]]` etc.: fill-ins for the SUS paragraphs. SUS formula for Google Sheets is in `MANUAL_EDIT_GUIDE_v3.md` Part 4.3.
- Delete a tag's whole sentence if the data never arrives; never leave `[[ ]]` in the final print.

## Not touched (your call)
- Title page still says "Project Proposal" and "April 2026"; Chapter II is written in future tense ("will be conducted"); target sample "thirty (30)" in Chapter II is a plan, not a result.
- **Table of Contents / List of Tables are typed by hand and NOT updated** (page numbers unknown). Add: Approval Sheet, Abstract (front matter); III RESULTS AND DISCUSSION (Objectives 1–3); IV CONCLUSIONS AND RECOMMENDATIONS; Table 2.2; Tables 3.1–3.4.
- Approval Sheet: chairperson still TBA; Dean name (Jeoffrey B. Layco, MIS) came from a draft, verify.

## Still unverified (don't treat as facts)
- References: FHN (2026) title, Groq (2026) generic entry, Li et al. (2024) arXiv ID — check before final.
- Table 3.4 (parsing accuracy): no handoff shows a real test run. The old draft numbers (unconfirmed): GCash 15 docs 93.3% end-to-end; Maya 10 → 90.0%; Shopee/Lazada 10 → 80.0%; thermal 15 → 66.7%; "overall 82.5%" was a simple average (weighted would be 82.0%). Use only if a real, logged test exists.
- Table 3.2 free-tier column: Flash-Lite ~500/day and Flash ~20/day come from one third-party tracker; "~1,000/day" for Groq rows also unchecked.

## Opening it
If you use LibreOffice, the two floating tables in Chapter I (Tables 1.1/1.2) can crash it (same in your older __3_). Word is fine. I checked layout in a throwaway copy without that floating setting: ~99 pages, headers/footers/fonts match, table captions stay with tables.
