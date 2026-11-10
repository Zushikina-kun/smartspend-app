# Names & Tense — Definitive Fix List
**Date**: November 10, 2026  
**Status**: WAIT for Maam Ellen's edited version, then apply these on top  
**Source of truth for names**: Approval Sheet (all versions agree): `Shekiro R. Raposas, MIT`

---

## FALSE POSITIVES (DO NOT CHANGE)

The workflow flagged ~30 "tense issues" in the Appendices. These are intentional:
- Survey questions (Appendix B) — present tense is correct ("Which expenses do you usually track?")
- Consent form (Appendix C) — future tense is correct ("Your responses will be treated confidentially")
- Reference titles ("Perceived ease of use", "Can AI help...") — titles must stay as-is
- Dedication/Acknowledgements "have been" — present-perfect in personal dedications is acceptable
- Figure captions ("Use Case Diagram") — "Use" is a noun here, not a verb

---

## 🔴 CRITICAL — Apply after Maam Ellen finishes

### Fix 1: Instructor name + tense in Acknowledgements (para 60)
**Current:**
> "...thank their instructor in charge, **Dr. Janelli M. Raposas**, for providing direction, structure, and continuous reminders that **help** ensure the completion of all requirements."

**Correct:**
> "...thank their instructor in charge, **Mr. Shekiro R. Raposas, MIT**, for providing direction, structure, and continuous reminders that **helped** ensure the completion of all requirements."

**Two changes in one sentence: name + "help" → "helped"**

---

## 🟡 HIGH — Research chapter tense fixes (Chapters I–IV body text)

These are real tense issues flagged by Maam Ellen's instruction to convert to past tense. Apply all after her edit:

| Para | Current | Fixed |
|------|---------|-------|
| **52** (Abstract) | "SmartSpend **integrates** a multi-provider..." | "SmartSpend **integrated** a multi-provider..." |
| **311** (Ch III) | "which **supports** the case for automated capture" | "which **supported** the case for automated capture" |
| **317** (Ch III) | "it directly **influences** the accuracy, latency" | "it directly **influenced** the accuracy, latency" |
| **320** (Ch III) | "it **offers** a high free-tier request quota" | "it **offered** a high free-tier request quota" |
| **320** (Ch III) | "LLaMA...and **have been** replaced in the fallback chain" | "LLaMA...and **were** replaced in the fallback chain" |
| **321** (Ch III) | "SmartSpend **uses** dynamic full-context injection" | "SmartSpend **used** dynamic full-context injection" |
| **343** (Ch III) | "a summary card **shows** which items were recorded" | "a summary card **showed** which items were recorded" |
| **343** (Ch III) | "first **shows** a warning" | "first **showed** a warning" |
| **344** (Ch III) | "Current research **indicates** this is feasible" | "Current research **indicated** this was feasible" |
| **345** (Ch III) | "a haptic service **provides** tactile feedback" | "a haptic service **provided** tactile feedback" |
| **347** (Ch III) | "to **help** a non-technical user choose" | "to **help** a non-technical user choose" ← LEAVE — infinitive after "to", not a conjugated verb |
| **244** (Ch II) | "has been set as the acceptance threshold" | "**was set** as the acceptance threshold" |
| **296** (Ch III) | "features **have been** identified for future implementation" | "features **were** identified for future implementation" |
| **296** (Ch III) | "multi-wallet system...has been fully implemented" | "multi-wallet system...was fully implemented" / "has been implemented" ← either is fine |

---

## 🟡 MEDIUM — Chapter IV Recommendations tense

Recommendations use "The developers **may** implement..." — this is standard future-conditional for academic recommendations. This is **intentional and correct** — do NOT change these to past tense.

---

## 🟢 ACCEPTABLE — Leave these as-is

| Location | Text | Why it's fine |
|----------|------|---------------|
| Acknowledgements para 57 | "His presence **has been** a source of hope" | Personal/religious present-perfect in Acknowledgements is acceptable |
| Dedication para 67, 68 | "who **have been** a constant source..." | Dedication present-perfect is standard |
| All Appendix B survey questions | "Which expenses do you usually track?" | Instrument text — keep original tense |
| All Appendix C consent form | "Your responses will be treated confidentially" | Consent form tense is correct |
| Product feature descriptions | "SmartSpend **features** 36 badges..." | App still exists and works — present-tense product descriptions are fine in a submitted thesis describing a live prototype |
| Reference titles | "Perceived ease of **use**" / "Can AI **help**" | Titles must not be altered |

---

## 🟡 CONFIRM BEFORE FIXING — Middle initial question

The workflow found:
> Para 713 (CV section): **CYRILLE JOHN M. RUBIS**

Middle initial is "M." — confirm whether this is correct or should be "A." (as stated in some docs). Check with Cyrille before changing.

---

## SUMMARY

| Category | Count | Action |
|----------|-------|--------|
| Wrong instructor name + "help" | 1 paragraph (para 60) | Fix after Maam Ellen |
| Real tense fixes in research chapters | ~12 sentences across Ch II–III | Fix after Maam Ellen |
| False positives (Appendices, consent, refs) | ~40 | Leave as-is |
| Confirm with student | 1 (Cyrille middle initial) | Ask Cyrille |
| Already correct | All other names | No action |

---

## HOW TO APPLY (after Maam Ellen sends edited file)

1. Take Maam Ellen's edited file as the new base
2. Check if she already fixed para 60 (name + "help"→"helped") — if yes, skip
3. Apply remaining tense fixes in the table above using python-docx
4. Confirm Cyrille's middle initial separately
5. That's it — Appendices and Recommendations do NOT need tense changes
