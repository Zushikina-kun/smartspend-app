# SmartSpend — TOC, List of Figures, List of Tables Fix Guide
**For:** Groupmates applying manual fixes in Word  
**Date:** November 14, 2026  
**Rule:** Match everything to what is actually in the manuscript body. You are updating the lists to reflect the body — not the other way around.

---

## PART 1 — TABLE OF CONTENTS

### Step 1: Delete the first TOC entirely

You have two Tables of Contents. The **first one** (the table-format one that starts with Chapter I / II / III rows and has `C | Transcript of Interview | 74`) must be **deleted completely**. 

Keep only the **second TOC** — the plain-text one that starts:
```
Title Page    i
Approval Sheet    ii
...
```

### Step 2: Use this exact TOC text (replace everything in your second TOC)

Copy-paste this into your TOC section. Leave page numbers blank as `____` — fill them in after all edits are done by pressing Ctrl+A → F9.

---

```
TABLE OF CONTENTS                                                    Page

Title Page  ............................................................. i
Approval Sheet  ......................................................... ii
Abstract  ............................................................... iii
Acknowledgement  ........................................................ iv
Dedication  ............................................................. v
Table of Contents  ...................................................... vi
List of Figures  ........................................................ vii
List of Tables  ......................................................... viii

CHAPTER I: INTRODUCTION  ............................................... ____
    Project Context  .................................................... ____
    Conceptual Framework  ............................................... ____
    Statement of Objectives  ............................................ ____
    Scope and Limitations of the Study  ................................. ____
    Purpose and Description  ............................................ ____
    Technical Background  ............................................... ____

CHAPTER II: DESIGN AND METHODOLOGY  ..................................... ____
    Research Design  .................................................... ____
    Population and Locale  .............................................. ____
    Ethical Considerations  ............................................. ____
    Data Gathering Tools and Procedures  ................................ ____
    Software Methodology  ............................................... ____

CHAPTER III: RESULTS AND DISCUSSION  .................................... ____
    Assessment of the Financial Management Practices, Budgeting
    Challenges, and Expense Tracking Behaviors of Parents
    and Young Professionals  ............................................ ____
    Design and Development of the SmartSpend Mobile Application  ........ ____
        Comparative Analysis of Large Language Model APIs  .............. ____
        Financial Health Score: Computation  ............................ ____
        Overview of the System  ......................................... ____
        Production Screens  ............................................. ____
    Evaluation of the Usability and Performance of SmartSpend
    Using the System Usability Scale and User Feedback Analysis  ........ ____

CHAPTER IV: CONCLUSIONS AND RECOMMENDATIONS  ............................ ____
    Conclusions  ........................................................ ____
    Recommendations  .................................................... ____

References  ............................................................. ____

Appendices  ............................................................. ____
    Appendix A: Survey Questionnaire  .................................. ____
    Appendix B: Informed Consent Form  ................................ ____
    Appendix C: System Usability Scale (SUS) Questionnaire  ........... ____
    Appendix D: Content Validation Certificate (Survey Questionnaire)  ____
    Appendix E: Content Validation Certificate (FHS Formula)  ......... ____

Photo Documentation  .................................................... ____

Curriculum Vitae  ....................................................... ____
    Brix A. Directo  ................................................... ____
    Cyrille John M. Rubis  ............................................. ____
    Djaunathan Albert S. Madayag  ...................................... ____
```

---

### Key changes from your old TOC:
| What you had | What it should be |
|---|---|
| "RESEARCH METHODOLOGY" | "DESIGN AND METHODOLOGY" |
| Missing: Ethical Considerations | Now added |
| "Data Gathering Procedure" | "Data Gathering Tools and Procedures" |
| Missing: Software Methodology | Now added |
| Missing: Purpose and Description | Now added |
| Missing: Technical Background | Now added |
| "System Development Results" | Removed — not a separate heading in the body |
| Missing: Photo Documentation | Now added |
| Appendix B: SUS Questionnaire | Changed to: Informed Consent Form |
| Appendix C: System Usability Scale... Questionnaire | Confirmed correct |
| Appendix C: Transcript of Interview | Deleted — no such appendix |

---

## PART 2 — LIST OF FIGURES

### Replace the entire List of Figures with this:

The old list used chapter-prefixed numbers (1.1, 2.1, 3.1). The body uses sequential numbers (Figure 1, Figure 2, etc.). Use sequential everywhere.

**Important notes before you start:**
- Figure 3 (SUS Score Interpretation) should appear in Chapter II in the body — check if it's there. If the image is there but labeled something else, relabel it Figure 3.
- Figures 6, 7, 8, 9 are **missing** from the current body. The body jumps from Figure 5 to Figure 10. This may mean images were removed or renumbered. For now the List of Figures reflects what actually exists in the body.
- Figure 3.12 (SUS Score Distribution histogram) — if there is no actual histogram image in the body, **do not include it**.
- Figure 3.14 (old demographic chart duplicate) — **do not include it** (Figure 5 is the demographic chart).

---

```
LIST OF FIGURES

Figure No.          Figure Name                                          Page

Figure 1.    Financial Literacy Rates by Demographic Group
             (BSP, 2021; Inquiro, 2024)  ...............................  ____

Figure 2.    Conceptual Framework (Mobile Application)  .................  ____

Figure 3.    System Usability Scale (SUS) Score Interpretation  .........  ____

Figure 4.    Agile Kanban Workflow for SmartSpend Development  ..........  ____

Figure 5.    Demographic Distribution of Needs-Assessment
             Respondents (N = 30)  .....................................  ____

Figure 10.   SmartSpend System Flowchart  ...............................  ____

Figure 11.   Use Case Diagram  ..........................................  ____

Figure 12.   Visual Table of Contents  ..................................  ____

Figure 13.   Login and Demo Mode Screen  ................................  ____

Figure 14.   Home Dashboard  ............................................  ____

Figure 15.   Expense Logging Through Peso Chat  .........................  ____

Figure 16.   Receipt Scanning and Batch Screenshot Import  ..............  ____

Figure 17.   Financial Health Score Breakdown  ..........................  ____

Figure 18.   Budgets Screen  ............................................  ____

Figure 19.   Local AI Mode Setup  .......................................  ____

Figure 20.   SUS Computation Table  .....................................  ____

Figure 21.   SUS Scores by Respondent Group (N = 30)  ...................  ____
```

---

### ⚠️ Note on the missing figures 6–9:

If your manuscript body **has** figures between Figure 5 and Figure 10 (they might be unlabeled or labeled differently), renumber them and add them to this list. If the body genuinely jumps from 5 to 10, the list above is correct as-is. Either way, the List of Figures must only list figures that actually have images in the body.

---

## PART 3 — LIST OF TABLES

### Replace the entire List of Tables with this:

The old list used chapter-prefixed numbers (1.1, 2.1, 3.1) AND had a duplicate entry for the LLM comparison table. Use sequential numbers and remove the duplicate.

---

```
LIST OF TABLES

Table No.           Table Name                                           Page

Table 1.     Three-Level Gap Analysis of SmartSpend  ...................  ____

Table 2.     Feature Comparison of SmartSpend with Existing
             Financial Applications (including Filipino-context apps)  ..  ____

Table 3.     Distribution of Respondents and Validators  ................  ____

Table 4.     Agile Kanban Workflow Phases and Deliverables  .............  ____

Table 5.     Demographic Profile and Expense Tracking Methods
             of Respondents (N = 30)  ..................................  ____

Table 6.     Comparative Evaluation of LLM APIs for
             SmartSpend Integration  ...................................  ____

Table 7.     Overall SUS Result  ........................................  ____

Table 8.     System Usability Scale (SUS) Results by
             Respondent Group  .........................................  ____

Table 9.     SmartSpend Multimodal Import:
             Field-Level Parsing Performance  ..........................  ____
```

---

### Key changes from your old List of Tables:
| What you had | What it should be |
|---|---|
| 1.1 Three-Level Gap Analysis | Table 1 |
| 1.2 Feature Comparison | Table 2 |
| 2.1 Distribution of Respondents | Table 3 |
| 2.2 Comparative Evaluation of LLM APIs ← WRONG | Table 4: Agile Kanban Workflow Phases ← CORRECT |
| 3.1 Demographic Profile | Table 5 |
| 3.2 Comparative Evaluation of LLM APIs | Table 6 ← kept here (this is correct, it's in Ch III) |
| 3.3 Overall SUS Result | Table 7 |
| 3.4 SUS Results by Respondent Group | Table 8 |
| 3.5 Multimodal Import | Table 9 |

**The duplicate was:** Both 2.2 and 3.2 were labeled "Comparative Evaluation of LLM APIs." The table only exists once in the body (in Chapter III as Table 6). The old "2.2" entry was wrong — it should have been the Kanban table (Table 4).

---

## PART 4 — CAPTION PUNCTUATION IN THE BODY

While you are in the body fixing figures, check caption punctuation consistency:
- **Figures 1–5** use a **colon**: `Figure 1: Financial Literacy Rates...`
- **Figures 10–21** use a **period**: `Figure 10. SmartSpend System Flowchart`

Pick one style and apply it everywhere. The recommendation is to use a **period** for all figure captions (matches the LigTask style and is more common in this format):

| Fix | From | To |
|---|---|---|
| Figure 1 caption | `Figure 1:` | `Figure 1.` |
| Figure 2 caption | `Figure 2:` | `Figure 2.` |
| Figure 3 caption | `Figure 3:` | `Figure 3.` |
| Figure 4 caption | `Figure 4:` | `Figure 4.` |
| Figure 5 caption | `Figure 5:` | `Figure 5.` |
| Figures 10–21 | Already use `.` | No change |

For tables, all use a **colon** — that is correct. No changes needed to table captions.

---

## PART 5 — AFTER ALL EDITS

1. **Refresh page numbers:** Select all (Ctrl+A) → press F9 → click "Update entire table" for each TOC/list
2. **Delete all comments:** Review tab → Delete → Delete All Comments in Document
3. **Save**

---

*Guide written: November 14, 2026*
