# Names & Tense Issues — Cross-Examination Report
**Date**: November 10, 2026  
**Source of truth for names**: Approval Sheet (para 27/32 in every version) = `Shekiro R. Raposas, MIT`  
**Status**: DO NOT FIX YET — Maam Ellen is actively editing the manuscript  

---

## 🔴 ISSUE 1: Wrong Instructor Name in Acknowledgements

### Root Cause
The **Approval Sheet** (all versions) correctly states:
```
Shekiro R. Raposas, MIT — Capstone Teacher-in-Charge
```
The **Acknowledgements paragraph** has NEVER been correct in any version:

| File | Acknowledgements says | Correct? |
|------|-----------------------|----------|
| `1_MAIN_MANUSCRIPT.docx` (old) | "Dr. Janelli M. **Raposas**" | ❌ Wrong title + first name |
| `SmartSpend_updated_v2.docx` | "Dr. Janelli M. **Mendez**" | ❌ Wrong title + first name + wrong surname |
| `groupmates ver` | "Dr. Janelli M. **Raposas**" | ❌ Wrong title + first name |
| **CURRENT FINAL** | "Dr. Janelli M. **Raposas**" | ❌ Wrong title + first name |

### Fix Required (1 instance, para 60 in FINAL)
**Current text (para 60):**
> "The researchers would also like to thank their instructor in charge, **Dr. Janelli M. Raposas**, for providing direction, structure, and continuous reminders that helped ensure the completion of all requirements."

**Should be:**
> "The researchers would also like to thank their instructor in charge, **Mr. Shekiro R. Raposas, MIT**, for providing direction, structure, and continuous reminders that helped ensure the completion of all requirements."

### Why "Mendez" appeared in one version
`SmartSpend_updated_v2.docx` says "Dr. Janelli M. **Mendez**" — this was likely a different wrong draft that got merged in at some point. The correct surname from the Approval Sheet is **Raposas**, not Mendez.

---

## 🟡 ISSUE 2: "has been" / "have been" — 8 Instances

Maam Ellen flagged present-perfect tense. The screenshot shows "has been" found **3 of 4** (in the visible context). Full scan found **8 paragraphs**:

| Para | Context | Action Needed |
|------|---------|---------------|
| 27 | "and that the said capstone project **has been**..." (Approval Sheet boilerplate) | ✅ Leave — legal/formal boilerplate |
| 57 | "His presence **has been** a source of hope..." (Acknowledgements — God paragraph) | ✅ Acceptable in Acknowledgements |
| 63 | "Their motivation and belief **have been** a constant source of strength." (Acknowledgements) | ✅ Acceptable in Acknowledgements |
| 67 | "the people who **have been** a constant source of inspiration..." (Dedication) | ✅ Acceptable in Dedication |
| 68 | "love, sacrifices, and encouragement **have been** the foundation..." (Dedication) | ✅ Acceptable in Dedication |
| 244 | "A target SUS score of 80 or above...has been set as the acceptance threshold" (Ch II) | ⚠️ Change to "**was set**" |
| 296 | "several features **have been** identified for future implementation" (Ch III) | ⚠️ Change to "**were identified**" |
| 296 | "A multi-wallet system...has been fully implemented in the current version." (Ch III) | ⚠️ Change to "**was fully implemented**" / "**has been implemented**" (acceptable either way since it's still true) |
| 320 | "LLaMA 1 8B) were retired...and **have been** replaced in the fallback chain" (Ch III) | ⚠️ Change to "**were replaced**" |

### Summary: 3 fixes needed in research chapters, 5 acceptable as-is

---

## 🟡 ISSUE 3: Present Tense in Chapter Descriptions (App described as if still being built)

Several paragraphs use present tense to describe what SmartSpend "does" or "is." Some are appropriate (the app still exists and works), but these specific ones read like the development is ongoing rather than completed:

| Para | Current | Suggested |
|------|---------|-----------|
| 182 | "SmartSpend features a conversational AI assistant capable of executing..." | "SmartSpend **featured** / **includes**" — either past or present OK for product description |
| 183 | "Users can manually encode..." | Present tense OK for describing product features |
| 207 | "SmartSpend is designed as a mobile application that **helps** users manage..." | "that **helps**" is fine — describing current product |
| 211 | "A gamification layer...further **reinforces** positive financial habits" | Acceptable — describes the product as it exists |
| 244 | "A target SUS score of 80 or above...has been set" | ⚠️ **Was set** (past — the target was set before data collection) |
| 284 | "This figure illustrates the interpretation...that **was** used to evaluate" | ✅ Already past tense |
| 344 | "AI privacy **is** described as three tiers" | ⚠️ Could be "**was** described" or leave as is — describing a design decision |

**Verdict:** Most present-tense uses are acceptable (describing a product that still exists). The flagged "has been" instances at paras 244, 296, 320 are the main fixes needed.

---

## 🟢 ISSUE 4: Names Verified Correct

These are correct across all versions — do NOT change:

| Name | Location | Status |
|------|----------|--------|
| **Ellen F. Mangaoang, DIT** | Approval sheet, Acknowledgements | ✅ Correct in all versions |
| **Shekiro R. Raposas, MIT** | Approval sheet | ✅ Correct in all versions |
| **Jeoffrey B. Layco, MIS** | Approval sheet, Dean | ✅ Correct in all versions |
| **Mary-Ann Mzana** | Approval sheet (panelist) | ✅ Present in all versions |

---

## 🔴 ISSUE 5: "help" vs "helped" in Acknowledgements (Maam Ellen's specific flag)

The screenshot shows Maam Ellen specifically flagged the word "help" in the Acknowledgements.

**Current para 60:**
> "...continuous reminders that **help** ensure the completion of all requirements."

**Should be:**
> "...continuous reminders that **helped** ensure the completion of all requirements."

This is the same paragraph as Issue 1 — both the name AND the verb need fixing in para 60.

---

## FIXES REQUIRED (all in para 60 of CURRENT FINAL)

**Single paragraph fix — para 60:**
```
FROM:
"The researchers would also like to thank their instructor in charge, 
Dr. Janelli M. Raposas, for providing direction, structure, and 
continuous reminders that help ensure the completion of all requirements."

TO:
"The researchers would also like to thank their instructor in charge, 
Mr. Shekiro R. Raposas, MIT, for providing direction, structure, and 
continuous reminders that helped ensure the completion of all requirements."
```

**Additional "has been" fixes in research chapters:**
- Para 244: "has been set" → "was set"
- Para 296 (instance 1): "have been identified" → "were identified"  
- Para 296 (instance 2): "has been fully implemented" → "was fully implemented" (or leave — acceptable)
- Para 320: "have been replaced" → "were replaced"

---

## WAIT FOR MAAM ELLEN'S VERSION

Do not apply fixes until she sends back her edited manuscript. When she does:
1. Check if she already fixed the name and tense issues
2. If yes → merge her version preserving all our data/figures changes
3. If no → apply the fixes above on top of her edits

The fixes are small (1 Acknowledgements paragraph + 3-4 "has been" changes in Chapters III/IV).

---

**Cross-examination sources:**
- Approval sheet (para 27): `Shekiro R. Raposas, MIT` — same in all 4 versions ✅
- Screenshots from user showing: "Dr. Janelli M. Raposas" and "Dr. Janelli M. Mendez" ✅
- Maam Ellen's flag: "has been" (3 of 4), "help" → "helped" ✅
- Full scan of FINAL DOCX: 8 "has been" paragraphs, 1 wrong name paragraph ✅
