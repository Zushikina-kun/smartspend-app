# SmartSpend Defense Handoff — For Claude (Nov 16, 2026)

This document tells you exactly what has been done and what still needs your help.
Defense date: **November 16, 2026**.

---

## 1. CURRENT STATE OF FILES

| File | Location | Status |
|------|----------|--------|
| Manuscript (FINAL) | `docs/handsoff/FOR_CYRILLE/1_MAIN_MANUSCRIPT_FINAL.docx` | ✅ Automated fixes applied — see Section 2 |
| Presentation | `docs/handsoff/FOR_CYRILLE/SmartSpend_Defense.pptx` | ✅ 18 slides, synced to manuscript |
| Script | `docs/handsoff/FOR_CYRILLE/4_DEFENSE_SCRIPT_FINAL.md` | ✅ 18-slide script, Nov 16 date, 20 Q&As |
| Reviewer | `docs/handsoff/FOR_CYRILLE/5_DEFENSE_REVIEWER_NOV16.md` | ✅ 58 Q&As, all protected values |
| Confirm checklist | `docs/handsoff/FOR_CYRILLE/CONFIRM_CHECKLIST_NOV16.md` | ✅ 4 critical + 9 informational items |
| Fix guide (from you) | `docs/handsoff/claude/1_MANUSCRIPT_FIX_GUIDE.md` | ✅ All automatable items applied |
| Your new script v3 | `docs/handsoff/claude/2_DEFENSE_SCRIPT_v3.md` | ⚠️ 35 slides — too long (32 min). Not used. |
| Your new PPTX v3 | `docs/handsoff/claude/SmartSpend_Defense_v3.pptx` | ⚠️ 35 slides — not used (defense is ~15 min) |

---

## 2. WHAT KIRO ALREADY APPLIED TO THE MANUSCRIPT

From your `1_MANUSCRIPT_FIX_GUIDE.md`, these were applied via python-docx:

### Applied ✅
- **A3**: Deleted Peso drafting note ("Present Peso as a design feature… avoid 'dopamine reinforcement'")
- **A4**: Validator confirmed as **Avigail Candevario, PFMe** (not Susan C. Arquisal) — applied everywhere
- **A8**: 8 recommendations in abstract; Table 3.5 ref fixed to "Recommendation 2"; SUS text fixed
- **B1**: "eight-provider cloud failover chain (Gemini 3.5 Flash-Lite as primary, seven fallbacks)"
- **B2**: Grade attribution fixed — "Grade D on the Sauro and Lewis (2016) curved scale"
- **B3**: Target 80 description fixed — "lies between the Good (about 71) and Excellent (about 85) anchors"
- **B4**: Figure 2.1 description paragraph updated to match redrawn figure
- **B6**: SUS exclusion sentence fixed — "Of 36 respondents… 31 confirmed… 1 excluded for straight-line… 5 for time"
- **B7**: LLM criteria — "six weighted criteria: Filipino-English accuracy (25%)…" (×3 locations)
- **B8**: Table 3.2 Gemini 3.7 Flash — Provider cell fixed
- **B15**: Table ref "Table 2.1" → "Table 1.2"
- **B16**: Garbled sentences fixed (3 locations)
- **B17**: Proxy/encryption sentence fixed
- **B18**: Truncated sentence fixed
- **B19**: sqflite version fixed (×2); FHS "open item" note deleted
- **C**: Age range 20-35 → 21-35; adviser label added; role name normalized; Ariely URL deleted; Gubbins citation fixed; NPC citation added
- **Ch IV Recs**: Recommendations renumbered and physically reordered to 1-8 in correct sequence
- **Ch IV order**: 1=UI/UX, 2=Parsing, 3=Backend+GooglePlay, 4=SQLite, 5=On-device AI, 6=Payday, 7=Household, 8=Longitudinal

### NOT FOUND (need manual Word Ctrl+H):
- **A7**: "below target but acceptable for a prototype" → couldn't find exact string
- **B2 Ch III body**: Grade attribution in Chapter III body text
- **B5**: Q4 label "need for technical support" (likely in table cell)
- **B6 Ch IV**: Exclusion sentence in Ch IV
- **B14**: "lowest rates" claim contradicting Fig 1.1
- **B21**: Table 3.5 performance disclaimer

---

## 3. WHAT STILL NEEDS YOUR HELP

### 3A. Verify the NOT FOUND items above

For each one, search the manuscript and apply the fix from `1_MANUSCRIPT_FIX_GUIDE.md`:

**A7** — Find this in Ch IV Conclusions:
- FIND: `below target but acceptable for a prototype system`  
- REPLACE: `below the 68 average benchmark and the pre-set target of 80, and rated marginal (not acceptable) under our criteria`

**B2 (Ch III body)** — Find the grade attribution sentence in Chapter III SUS section:
- FIND: `Per Bangor, Kortum, and Miller (2009), this corresponds to an adjective rating of "OK" (Grade D)`
- REPLACE: `an adjective rating of "OK" (Bangor et al., 2009) and Grade D on the Sauro and Lewis (2016) scale`

**B5** — In Table 3.4 or surrounding text:
- FIND: `complexity (Q2, Q4)`
- REPLACE: `complexity (Q2) and need for technical support (Q4)`

**B14** — In Chapter I:
- FIND any sentence saying parents have "the lowest rates" of budgeting/account ownership
- REPLACE: `Parents aged 35 to 55 carry the main household financial responsibility, yet, as Figure 1.1 shows, fewer than half of Filipino adults kept a household budget (46%) and only 2% answered all six financial literacy questions correctly.`

**B21** — Add after Table 3.5:
- ADD note: `Performance was assessed only through preliminary developer testing; no formal performance evaluation was conducted, which is why Recommendation 2 proposes one.`
- In Table 3.5 Overall row: add `(n = [CONFIRM number of test items])` after precision/recall figures

### 3B. CONFIRM items — these need the user's raw data

**CRITICAL — user must provide:**
1. **A1 (Figure 3.12)**: Export raw SUS responses (30 valid rows) from Google Forms → run `regen_sus_charts.py` in `docs/handsoff/claude/` → verify mean 61.83, SD 17.58, min 35.0, max 92.5. If numbers change, update Table 3.3, Table 3.4, Figure 3.12, Figure 3.13, abstract, and slides.
2. **A2 (Appendix F)**: Build a 30-row SUS Individual Scores table (Respondent | Group | Q1-Q10 | Score) from the Form export → add as Appendix F.
3. **A6 (Build version)**: Confirm which build the 30 SUS respondents tested — v3.1.0 or v3.1.1? Both cannot be true. Use ONE version everywhere.
4. **A9 (Challenges data)**: Get Q6 challenge counts, Q4/Q5/Q9 frequencies from Form export → add to Chapter III Objective 1.

**INFORMATIONAL (nice to have):**
- Confirm Raposas title: "Mr." (manuscript) or "Engr." (ORDINEX deck) — which is correct?
- Confirm sqflite schema version (currently says v14)
- Confirm 45 screens, 57 currencies, 9 providers, ~47.5 MB APK size from code
- Confirm Budget Adherence behavior when no budgets are set
- Confirm 91.2%/88.5% parsing accuracy N (number of test items)

### 3C. Manual Word tasks (open manuscript in Word)

These cannot be automated — formatting/structure changes:

1. **Apply NOT FOUND items** from Section 3A above (5 Ctrl+H replacements)
2. **Figure 2.1**: Replace image with the redrawn version from `docs/handsoff/claude/` folder (if available)
3. **Figures 1.2 and 2.2**: Replace with versions without baked-in captions (`Fig_1_2_IPO_no_baked_caption.png`)
4. **Appendix F**: Add 30-row SUS Individual Scores table (after getting data from user)
5. **TOC**: Update page numbers (Ctrl+A → F9) after all edits
6. **Save as PDF** last

---

## 4. PROTECTED VALUES — NEVER CHANGE THESE

```
SUS: 61.83 mean, 17.58 SD, 55.0 median, 35.0-92.5 range, Grade D, adjective "OK"
Sample: N=30 valid (excluded 6 from 36)
Demographics (SUS): 10 parents + 20 young professionals
Demographics (needs assessment): 13 parents + 14 YP + 3 both = 30
AI Intent: 96.7% (29/30), GCash: 93.3% (28/30)
App: v3.1.0 evaluated, 34 AI actions, 36 badges, 45 screens
Objective 3: "partially achieved"
Validator: Avigail Candevario, PFMe (content); Certificates in Appendices D and E
Panelists: Jeoffrey B. Layco MIS (Chair), Shekiro R. Raposas MTS/MIS, Mary-Ann Mzana MTS
Adviser: Ellen Flores Mangaoang, DIT
```

---

## 5. KNOWN REJECTIONS FROM YOUR FIX GUIDE

**A5 — Do NOT delete Figure 3.14.**
Your guide said Figure 3.14 is "arithmetically impossible" (13+14+3 can't become 10+20). This is wrong. Figure 3.14 shows the **needs-assessment** sample (13+14+3=30), not the SUS sample. The 10+20 is the separate SUS sample in Table 2.1. The figure is correct. Keep it.

**35-slide deck — Do NOT use.**
Your `SmartSpend_Defense_v3.pptx` is 35 slides with ~32 minutes of speaking time. The actual defense is ~15-20 minutes. The existing 18-slide deck is the right length. If you want to add slides from your v3, pick only the ones that add value without exceeding 20 minutes.

---

## 6. FILE LOCATIONS SUMMARY

```
docs/handsoff/FOR_CYRILLE/
├── 1_MAIN_MANUSCRIPT_FINAL.docx       ← Working manuscript (all automated fixes applied)
├── SmartSpend_Defense.pptx            ← 18-slide deck (synced to manuscript)
├── 4_DEFENSE_SCRIPT_FINAL.md          ← 18-slide script (Nov 16, 20 Q&As)
├── 5_DEFENSE_REVIEWER_NOV16.md        ← 58-question reviewer
├── CONFIRM_CHECKLIST_NOV16.md         ← Items needing user's raw data
├── 2_TODO_GUIDE.md                    ← Manual Word tasks for groupmates
├── 00_START_HERE.md                   ← Quick orientation
├── FIGURES/
│   ├── Peso_Logo.svg                  ← Official Peso mascot SVG
│   ├── Peso_Logo_transparent.png      ← (old matplotlib version — replace with SVG)
│   └── [all figure images]
└── analysis/
    ├── CLAUDE_RECONCILE_NOV16.md      ← Full reconciliation report
    ├── CONFIRM_CHECKLIST_NOV16.md     ← Confirm items detail
    └── RECONCILE_PLAN.md              ← Item-by-item classification

docs/handsoff/claude/
├── 1_MANUSCRIPT_FIX_GUIDE.md          ← Your fix guide (sections already applied marked)
├── 2_DEFENSE_SCRIPT_v3.md             ← Your 35-slide script (too long, not used)
├── 3_DEFENSE_REVIEWER.md              ← Your 58 Q&As (merged into 5_DEFENSE_REVIEWER)
├── SmartSpend_Defense_v3.pptx         ← Your 35-slide deck (too long, not used)
├── Fig_1_2_IPO_no_baked_caption.png   ← Cleaned Fig 1.2 (apply manually)
└── HANDOFF_FOR_CLAUDE_NOV16.md        ← This file
```

---

## 7. QUICK PRIORITY ORDER

If time is short, do these first:

1. ✅ Already done — manuscript has all major fixes
2. 🔴 **User must run regen_sus_charts.py** (A1) — verify Figure 3.12
3. 🔴 **User must provide Q6/Q4/Q5 data** (A9) — Objective 1 challenges
4. 🟡 Apply NOT FOUND items (Section 3A) — 5 manual Ctrl+H in Word
5. 🟡 Replace Figs 1.2 and 2.2 with clean versions
6. 🟢 Add Appendix F (SUS scores table) when data is available
7. 🟢 TOC page numbers + Save as PDF

---

*Prepared by Kiro | November 12, 2026*
*For use by Claude in a separate session with the groupmates' manuscript*
