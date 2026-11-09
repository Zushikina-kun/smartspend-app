# Manuscript v5: what changed (Oct 26, 2026)
File: `CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx` (built from __4_; __4_ untouched). Only `word/document.xml` differs. New paragraphs and tables clone the document's own formatting. Rebuild script: `build_ms5.py` (needs `build_ms4_lib.py`).
Source of the rules: the CCSE "Chapters 3 and 4 Format Guide" and the SensiTeeth sample manuscript.

## Front matter
- Title page: "A CAPSTONE Project Proposal" is now "A CAPSTONE Project"; "April 2026" is now "November 2026" (change if you want the defense or submission month).
- Adviser is now **Ellen F. Mangaoang, DIT** (title page and Approval Sheet).

## Chapter III
- Introduction rewritten (3 sentences naming the kinds of results).
- Headings now follow the wording of the Chapter I objectives (no "Objective N:" prefix).
- Closing line added to each objective section ("These results showed that the ... objective of the study was achieved"). Objectives 1 and 3 are `[[PENDING]]` until real data exist; Objective 2 is written, with two `[[VERIFY]]` notes (TBD cells in Table 3.2; Cerebras key).
- New subsection "Overview of the System": Figures 3.1 to 3.3 (flowchart, use case diagram, visual table of contents) as placeholders.
- New subsection "Production Screens": Figures 3.4 to 3.10 as placeholders, grouped by feature (login/Demo Mode, dashboard, Peso chat logging, receipt and batch import, FHS breakdown, budgets/Safe-to-Spend/goals, local AI setup). **Swap in the screens you actually have.**
- Objective 3 (SUS) now follows the four-step format: procedure, Figure 3.11 (computation table placeholder), new **Table 3.3 Overall SUS Result** (score, grade, adjective, acceptable), interpretation with highest and lowest items.
- Renumbered: respondent-group table is now Table 3.4; parsing table is now Table 3.5.

## Chapter IV
- One-sentence introduction.
- Conclusions follow Objective, Result, Judgment. Objective 2 shortened and no new data. The "Overall..." paragraph was removed.
- Recommendations cut from 9 plus a paragraph to **7**, each in future tense, saying who acts, tied to a Chapter III limitation.
  - Removed: Safe-to-Spend (already built), OFxPERA (new claim, not in Chapter III).
  - Merged: family wallets and OFW remittance.
  - Added: longitudinal evaluation (from the old closing paragraph).
  - Check: the OFxPERA / BSP Open Finance reference may now be orphaned in the References.

## Search for `[[` before printing
Currently 97 tags (83 `[[PENDING`, 6 `[[VERIFY`, the rest fill-ins such as `[[N]]`). Delete a tag's sentence if its data never arrives. No `[[ ]]` may remain in the printed copies.

## Still to do by hand
1. **Figures:** all 11 Chapter III figures are placeholders. Insert real v3.1.0 images and diagrams; caption below, centered; each followed by an explanation (Present, Interpret).
2. **Table of Contents and List of Tables/Figures** are hand-typed and not updated. Add: Chapter III headings (3 objective headings plus the new subsections), Tables 3.1 to 3.5, Figures 3.1 to 3.11, Table 2.2.
3. **Numbering style:** the sample numbers figures 1 to 37 and tables 1, 2 across the whole manuscript. This manuscript uses chapter-based numbers (Figure 1.1, Table 3.2). Ask your adviser which she wants before the final print.
4. **Targets:** SUS acceptance target is 80 in Chapters III and IV. Confirm Chapter II, the Abstract and the grade scale (Figure 2.1) say the same, and that one final score appears everywhere.
5. **Approval Sheet:** the Chairperson is TBA; verify the Dean (Jeoffrey B. Layco, MIS in the 2025 sample).
6. **Recommendation 1** (payday cycle) has a `[[VERIFY]]`: confirm with Kiro it is not already in v3.1.0.
7. Still unverified from v4: references FHN (2026), Groq (2026), Li et al. (2024); Table 3.5 (parsing test) needs a real logged test; FHS pillar names depend on Kiro's answer.

## Checked
Package diff vs __4_: only `word/document.xml` changed. 1,104 `w14:paraId` values, all unique. LibreOffice renders a throwaway copy (floating tables un-floated) at 103 pages; the new table and chapter pages looked right. Open __5_ in Word to confirm, as with __4_.
