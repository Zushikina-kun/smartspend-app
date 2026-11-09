# ⚠️ CRITICAL — DO NOT CHANGE

**This document lists values and text that MUST NOT be modified in any defense document.**  
**Changing these will introduce errors that panelists will catch.**

Last Updated: November 9, 2026, 11:59 PM

---

## 🔴 PROTECTED NUMERICAL VALUES

### SUS Statistics (DO NOT CHANGE)
```
Overall Results:
├─ Mean: 61.83
├─ Standard Deviation: 17.58
├─ Grade: D
├─ Adjective: "OK"
├─ Sample Size: N = 30
└─ Exclusions: 6 (5 for insufficient time, 1 for straight-line bias)

Parent Group:
├─ n: 10
├─ Mean: 58.25
└─ SD: 19.72

Young Professional Group:
├─ n: 20
├─ Mean: 63.62
└─ SD: 16.65
```

**Why these are locked:**
- Computed from actual Excel data (03_SUS_Responses_FINAL_N36.xlsx)
- Verified with statistical formulas
- Cross-referenced in all documents
- Any change breaks consistency

**If you think these are wrong:**
1. DO NOT change them
2. Verify against original Excel file
3. Contact Kiro with evidence
4. Only change after full re-verification

---

## 🔴 PROTECTED TEXT STRINGS

### Demographics
```
✅ CORRECT:
"10 parents and 20 young professionals"
"10 parents (33.3%) and 20 young professionals (66.7%)"
"n = 10 parents, n = 20 young professionals"

❌ WRONG:
"20 parents and 10 young professionals"  [INVERTED]
"13 parents and 14 young professionals"  [MISSING RECLASSIFICATION]
"13+14+3" without footnote                [NO EXPLANATION]
```

**Rationale:** Original survey had 13 parents + 14 YP + 3 "both". The 3 "both" respondents were reclassified by their primary financial role for SUS subgroup analysis, resulting in 10 parents and 20 young professionals.

**Required footnote:**
```
† Note: The 3 respondents who identified as both parent and young 
professional were classified by their primary financial role for 
SUS subgroup analysis, resulting in a final breakdown of 10 parents 
and 20 young professionals.
```

---

### Exclusion Rationale
```
✅ CORRECT:
"30 respondents (6 excluded: 5 for insufficient time, 1 for straight-line bias)"
"N=30 after excluding 5 respondents with insufficient app exposure and 1 with straight-line response bias"
"Six respondents were excluded: five lacked sufficient time with the app for valid assessment, and one showed straight-line response bias"

❌ WRONG:
"30 respondents (5 excluded)"             [MISSING 6TH EXCLUSION]
"30 respondents (6 excluded for time)"    [WRONG REASON]
"31 respondents" or "36 respondents"      [WRONG N]
```

**Rationale:** N=36 in raw data → 6 excluded → N=30 final. The 6th exclusion (Respondent #31, score 100.0) was excluded for straight-line response bias (all 5s and 1s pattern).

---

### Adviser Name
```
✅ CORRECT:
"Dr. Janelli M. Raposas"
"Ms. Ellen F. Mangaoang, DIT"

❌ WRONG:
"Dr. Mendez"                     [OUTDATED]
"Janelli Raposas" without Dr.    [MISSING TITLE]
```

**Rationale:** User confirmed "Dr. Janelli M. Raposas" is correct for acknowledgements. Ms. Ellen F. Mangaoang, DIT is the adviser for the capstone title page.

---

### Language: Surveys vs Interviews
```
✅ CORRECT:
"surveys"
"conducted surveys"
"survey respondents"

❌ WRONG:
"interviews"
"conducted interviews"
"interview participants"
```

**Rationale:** The study used SUS surveys and needs assessment surveys, NOT interviews. "Interviews" was flagged as incorrect terminology.

---

### SUS Grade Scale
```
✅ CORRECT:
"Grade D" (for SUS = 61.83)
"Adjective rating: OK" (Bangor scale)

❌ WRONG:
"Grade C"        [INCORRECT FOR 61.83]
"Grade F"        [TOO LOW]
```

**Rationale:** Using Bangor adjective scale, 61.83 falls in Grade D ("OK") range. Grade C starts at 71.1.

---

## 🔴 PROTECTED FILE NAMES

### Use These Files
```
✅ docs/handsoff/FOR_CYRILLE/1_MAIN_MANUSCRIPT_FINAL.docx
✅ docs/handsoff/FOR_CYRILLE/3_PRESENTATION_FINAL.pptx
✅ docs/handsoff/FOR_CYRILLE/3_PRESENTATION_FINAL.html
✅ docs/handsoff/FOR_CYRILLE/4_DEFENSE_SCRIPT_FINAL.md
```

### DO NOT Use These Files
```
❌ docs/handsoff/1_MAIN_MANUSCRIPT.docx
❌ docs/handsoff/3_PRESENTATION.pptx
❌ docs/handsoff/4_DEFENSE_SCRIPT.md
❌ docs/handsoff/SmartSpend_Manuscript_updated_v2.docx
```

**Rationale:** Files without "FINAL" suffix are outdated and contain errors. Only FINAL files have all 6 blockers fixed.

---

## 🔴 PROTECTED WARNINGS TO NEVER RE-ADD

### Forbidden Text Patterns
```
❌ "preliminary"     (except in references/literature)
❌ "pending"         (except in word "overspending")
❌ "in progress"
❌ "will be added"
❌ "N=5"            (except when explaining exclusion process)
❌ "[PENDING]"
❌ "TODO"
❌ "FIXME"
❌ "TBD"
❌ "to be inserted"
```

**Rationale:** These indicate incomplete work. All were systematically removed on Nov 9, 2026. DO NOT reintroduce them.

### Exception Cases
```
✅ "overspending" contains "pending" → OK
✅ "Preliminary results from literature..." → OK (historical reference)
✅ "The preliminary testing phase (N=5) led to..." → OK (explaining process)
```

---

## 🔴 PROTECTED DOCUMENT STRUCTURE

### Figures (DO NOT REMOVE OR RENUMBER)
```
Figure 3.4  — Login Screen
Figure 3.5  — Home Dashboard
Figure 3.6  — Peso Chat Interface
Figure 3.7  — GCash Batch Import
Figure 3.8  — Financial Health Score
Figure 3.9  — Budget Tracking
Figure 3.10 — Local AI Mode
Figure 3.11 — SUS Computation Table
```

**Rationale:** These are embedded in manuscript and referenced throughout. Removing or renumbering breaks all references.

---

### Demographic Footnotes (DO NOT REMOVE)
```
Required footnotes in manuscript:
1. After Table 3 (Demographics) — explains 13+14+3 → 10+20
2. After Table 5 (Survey profile) — explains 13+14+3 → 10+20  
3. After Table 8 (SUS by group) — explains 13+14+3 → 10+20
```

**Rationale:** Without these footnotes, demographic inconsistency (Blocker #1) returns.

---

## 🔴 VERIFICATION CHECKPOINTS

### Before Any Change
1. **Read this document first**
2. **Check if your change affects protected values**
3. **If yes, STOP and reconsider**
4. **If no, proceed with change**
5. **After change, run verification:**
   ```powershell
   cd "docs\handsoff\FOR_CYRILLE"
   python final_verification.py
   ```

### Expected Verification Output
```
============================================================
FINAL DEFENSE MATERIALS VERIFICATION
============================================================
📊 CHECKING PPTX (3_PRESENTATION_FINAL.pptx)...
  ✓ Passed: 5 checks
  ✗ Issues: 0 problems
📄 CHECKING MANUSCRIPT (1_MAIN_MANUSCRIPT_FINAL.docx)...
  ✓ Passed: 11 checks
  ✗ Issues: 0 problems
📜 CHECKING DEFENSE SCRIPT (4_DEFENSE_SCRIPT_FINAL.md)...
  ✓ Passed: 1 checks
  ✗ Issues: 0 problems
============================================================
✅ ALL CHECKS PASSED — DEFENSE READY
   17 verification checks successful
============================================================
```

**If verification fails:**
1. Note which test failed
2. Check MASTER_CHANGELOG.md for the original fix
3. Undo your change OR fix the issue properly
4. Re-run verification

---

## 🔴 COMMON MISTAKES TO AVOID

### Mistake #1: "Let me fix this typo in the numbers"
```
❌ Changing 61.83 to 61.8 or 62
❌ Rounding 17.58 to 17.6 or 18
```
**Why wrong:** All numbers must match Excel data exactly. No rounding.

---

### Mistake #2: "Demographics look wrong, let me swap them"
```
❌ Changing "10 parents + 20 YP" to "20 parents + 10 YP"
```
**Why wrong:** 10+20 is CORRECT per actual SUS data analysis. Don't trust intuition, trust data.

---

### Mistake #3: "I'll remove this footnote, it's too long"
```
❌ Deleting demographic footnotes
```
**Why wrong:** Footnotes explain why Tables 3/5 show 13+14+3 while Table 8 shows 10+20. Without them, Blocker #1 returns.

---

### Mistake #4: "Let me clean up the wording"
```
❌ Changing "surveys" back to "interviews"
❌ Changing "Dr. Raposas" back to "Dr. Mendez"
```
**Why wrong:** These corrections were explicitly made per user requirements.

---

### Mistake #5: "I'll update the old files too"
```
❌ Editing files without "FINAL" suffix
```
**Why wrong:** Old files are kept for reference only. All work should be on FINAL files.

---

## 🔴 EMERGENCY: If You Changed Something Protected

### Immediate Actions
1. **Don't panic**
2. **Don't try more changes to "fix" it**
3. **Restore from backup:**
   ```powershell
   cd "docs\handsoff\FOR_CYRILLE"
   
   # Restore specific file (example: manuscript)
   Copy-Item -Path "BACKUP_PRE_MERGE\1_MAIN_MANUSCRIPT.docx" `
             -Destination ".\1_MAIN_MANUSCRIPT_FINAL.docx" -Force
   
   # Or restore everything
   Copy-Item -Path "BACKUP_PRE_MERGE\*" -Destination ".\" -Force
   ```
4. **Run verification:**
   ```powershell
   python final_verification.py
   ```
5. **Document what happened in MASTER_CHANGELOG.md**

---

## 🔴 AUTHORIZED CHANGES

### What You CAN Change
✅ Table of Contents (must be updated manually)  
✅ Formatting (fonts, spacing, colors) — but don't break layout  
✅ Adding content (new sections) — but don't contradict existing numbers  
✅ Printing settings (margins, page breaks)  
✅ Comments and notes (for internal use)  

### What You CANNOT Change
❌ Any number listed in this document  
❌ Demographics breakdown  
❌ Figure numbers or captions  
❌ Demographic footnotes  
❌ Adviser names  
❌ File names (especially removing "FINAL")  
❌ Protected text patterns  

---

## 🔴 CONTACT / OVERRIDE PROCEDURE

### If You Believe Something Here Is Wrong

**Do NOT just change it.** Follow this procedure:

1. **Document your concern:**
   - What value/text you think is wrong
   - Why you think it's wrong
   - What evidence you have

2. **Verify against source data:**
   - Check Excel file: `docs/capstone/03_SUS_Responses_FINAL_N36.xlsx`
   - Check computation scripts: `docs/tools/compute_sus_groups.py`
   - Check MASTER_CHANGELOG.md for rationale

3. **If still concerned:**
   - Create a file: `FOR_CYRILLE/PROPOSED_CHANGE.md`
   - Document the issue thoroughly
   - Tag it for review

4. **Get approval:**
   - From thesis adviser
   - From all group members
   - Document approval in writing

5. **Only then make the change:**
   - Update all affected documents
   - Run verification
   - Update MASTER_CHANGELOG.md
   - Update this document (DO_NOT_CHANGE.md)

---

## 🎯 FINAL REMINDER

**These protections exist because:**
1. ✅ All values were computed from verified data
2. ✅ All changes were cross-verified across 4 documents
3. ✅ 17 automated checks passed
4. ✅ 6 critical blockers were fixed
5. ✅ Hours of work went into verification

**Changing protected values = reintroducing errors that panelists WILL catch.**

**When in doubt, DON'T CHANGE IT.**

---

**Protection Document Version**: 1.0  
**Created**: November 9, 2026, 11:59 PM  
**Authority**: Automated defense preparation system + user requirements  
**Status**: ACTIVE — Enforce before defense

**READ THIS BEFORE MAKING ANY CHANGES TO DEFENSE DOCUMENTS**
