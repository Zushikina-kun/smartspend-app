# SmartSpend — TOC, List of Figures, List of Tables Fix Guide
**Version:** 2 (updated after full source-of-truth audit Nov 14, 2026)  
**For:** Groupmates applying manual fixes in Word  
**Rule:** The source of truth manuscript body is the law. The TOC/Lists must match what is actually in the body.

---

## ⚠️ CRITICAL — Fix this FIRST before touching the TOC

### Fix the duplicate Figure 5 / missing Figure 6 in the BODY

Right now the body has **two captions labeled Figure 5**:
- Figure 5 (correct) = Demographic Distribution chart
- Figure 5 (wrong) = SmartSpend System Flowchart — this should be **Figure 6**

**Find this caption in the body (Chapter III, before the Use Case Diagram):**
> `Figure 5. SmartSpend System Flowchart`

**Change it to:**
> `Figure 6. SmartSpend System Flowchart`

Also find the description paragraph right after it that starts:
> "Figure 5 presents the system flowchart of SmartSpend..."

**Change "Figure 5 presents" to "Figure 6 presents"**

That is the ONLY caption renumbering needed. All other figures (1–5, 7–17) are already correctly numbered.

---

## PART 1 — TABLE OF CONTENTS

### Step 1: Delete the first TOC entirely

You still have two Tables of Contents. The **first one** (the table-format one with Chapter I/II/III rows) must be **deleted completely**. Keep only the second one (plain text starting with "Title Page ... i").

### Step 2: Replace your second TOC with this exact text

Leave page numbers as `____` — fill them in after all edits by pressing Ctrl+A → F9.

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

## PART 2 — LIST OF FIGURES

**Replace the entire List of Figures with this** (17 figures, all verified against the body):

```
LIST OF FIGURES

Figure No.     Figure Name                                              Page

Figure 1.    Financial Literacy Rates by Demographic Group
             (BSP, 2021; Inquiro, 2024)  ...............................  ____

Figure 2.    Conceptual Framework (Mobile Application)  .................  ____

Figure 3.    System Usability Scale (SUS) Score Interpretation  .........  ____

Figure 4.    Agile Kanban Workflow for SmartSpend Development  ..........  ____

Figure 5.    Demographic Distribution of Needs-Assessment
             Respondents (N = 30)  .....................................  ____

Figure 6.    SmartSpend System Flowchart  ...............................  ____

Figure 7.    Use Case Diagram  ..........................................  ____

Figure 8.    Visual Table of Contents  ..................................  ____

Figure 9.    Login and Demo Mode Screen  ................................  ____

Figure 10.   Home Dashboard  ............................................  ____

Figure 11.   Expense Logging Through Peso Chat  .........................  ____

Figure 12.   Receipt Scanning and Batch Screenshot Import  ..............  ____

Figure 13.   Financial Health Score Breakdown  ..........................  ____

Figure 14.   Budgets, Safe-to-Spend, and Savings Goals  .................  ____

Figure 15.   Local AI Mode Setup  .......................................  ____

Figure 16.   SUS Computation Table  .....................................  ____

Figure 17.   SUS Scores by Respondent Group (N = 30)  ...................  ____
```

**What changed from your old list:**
- Old used chapter-prefixed numbers (1.1, 2.1, 3.1) → now sequential (1–17)
- Added Figure 3 (SUS Interpretation) — was missing
- Added Figure 6 (Flowchart) — was wrongly labeled Figure 5
- Removed 3.12 (SUS Score Distribution) — no histogram image exists in the body
- Removed 3.14 (duplicate demographic chart) — Figure 5 is the demographic chart

---

## PART 3 — LIST OF TABLES

**Replace the entire List of Tables with this** (9 tables, all verified against the body):

```
LIST OF TABLES

Table No.      Table Name                                               Page

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

**What changed from your old list:**
- Old used chapter-prefixed numbers (1.1, 2.1, 3.1) → now sequential (1–9)
- Fixed Table 4 — was wrongly labeled "Comparative Evaluation of LLM APIs"; correct name is "Agile Kanban Workflow Phases and Deliverables"
- Removed the duplicate LLM comparison entry (old 2.2 and 3.2 were both LLM — only Table 6 is correct)

---

## PART 4 — CAPTION PUNCTUATION IN THE BODY

While you are in the body, check that ALL figure captions use a **period** (not a colon):

| These need to change | Change to |
|---|---|
| `Figure 1: Financial Literacy Rates...` | `Figure 1. Financial Literacy Rates...` |
| `Figure 2: Conceptual Framework...` | `Figure 2. Conceptual Framework...` |
| `Figure 4: Agile Kanban Workflow...` | `Figure 4. Agile Kanban Workflow...` |
| `Figure 5: Demographic Distribution...` | `Figure 5. Demographic Distribution...` |

Figures 3, 6–17 already use a period — no change needed.

For tables, all use a **colon** — that is correct. No changes needed.

---

## PART 5 — AFTER ALL EDITS

1. **Refresh page numbers:** Select all (Ctrl+A) → press F9 → click "Update entire table" for each TOC/list
2. **Delete all comments:** Review tab → Delete → Delete All Comments in Document
3. **Save**

---

## SUMMARY OF ALL BODY CHANGES (body captions, not TOC)

| Fix | Action |
|---|---|
| `Figure 5. SmartSpend System Flowchart` | Change to `Figure 6. SmartSpend System Flowchart` |
| Description "Figure 5 presents the system flowchart..." | Change "Figure 5 presents" to "Figure 6 presents" |
| `Figure 1:`, `Figure 2:`, `Figure 4:`, `Figure 5:` captions | Change colon to period |

That is all. Everything else in the body is already correct.

---

*Updated: November 14, 2026 — based on full automated audit of source of truth manuscript*
