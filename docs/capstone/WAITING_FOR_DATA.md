# SmartSpend — Waiting for Data (Final Revision List)
**Last updated:** November 9, 2026  
**Defense:** November 10, 2026  
**When data arrives → give to Brix → Brix sends to Kiro → Kiro does final revision in one pass**

---

## 📊 FROM SURVEY RESPONDENTS (when N=30 complete)

| Item | What to send | What Kiro updates |
|---|---|---|
| Research survey responses | Download CSV from Google Sheets | Chapter III Tables 3.1–3.3 (frequencies, percentages), Chapter IV Conclusion Obj 1, Presentation Slides 4 & 12 |
| SUS survey responses | Download CSV from Google Sheets | Chapter III Table 3.4 (SUS scores), Chapter IV SUS conclusion, Presentation Slides 11 & 12 |

**How to download:**
1. Go to Google Forms → Responses tab → click Sheets icon → open linked Sheet
2. File → Download → Comma Separated Values (.csv)
3. Send both CSVs to Brix → Brix pastes in chat here

**Survey links:**
- Research: https://docs.google.com/forms/d/e/1FAIpQLSfuDVpOSzTCQ8ICl-FGDjZ9a7iGPpKsh51xxAJ6ajesM36DXQ/viewform
- SUS: https://docs.google.com/forms/d/e/1FAIpQLScs24mLCXnSpCZnqDJt46wSWXQUsxhgu0GBkMAlYcOo8oAf2g/viewform

**Current status:** N=13 research / N=5 SUS (preliminary)

---

## 🖼️ FROM CYRILLE (figures and diagrams)

| Figure | What to create | Tool | What Kiro does |
|---|---|---|---|
| Figure 3.1 — System Flowchart | Draw the app flow from login to expense logged | Canva / draw.io | Insert PNG into CAPSTONE__5_.docx |
| Figure 3.2 — Use Case Diagram | User ↔ System interactions | Canva / draw.io | Insert PNG into docx |
| Figure 3.3 — Screen Navigation Map | Visual table of contents of app screens | Canva | Insert PNG into docx |
| Figure 3.4 — Login/Demo Screen | Screenshot from app | Phone | Insert PNG into docx |
| Figure 3.5 — Home Dashboard | FHS ring, Peso, quick input | Phone | Insert PNG into docx |
| Figure 3.6 — AI Chat (expense logging) | Taglish expense being logged | Phone | Insert PNG into docx |
| Figure 3.7 — Batch Screenshot Import | Import screen with GCash screenshots | Phone | Insert PNG into docx |
| Figure 3.8 — FHS Breakdown | 0–100 breakdown with 4 components | Phone | Insert PNG into docx |
| Figure 3.9 — Budgets/Savings Goals | Budget screen or goals screen | Phone | Insert PNG into docx |
| Figure 3.10 — Analytics/Local AI | Analytics or Settings screen | Phone | Insert PNG into docx |

**How to send:** Drag PNG files into this chat

**Note:** Screenshots already exist in `docs/debug/screenshots/` — Cyrille can use those instead of taking new ones. Kiro will insert them at the correct placeholder locations.

---

## ✍️ FROM MA'AM ABBY (validator signatures)

| Document | Status | Action |
|---|---|---|
| `6_CERT_A1_Survey_Questionnaire_Validation.pdf` | ⏳ Pending signature | Print → Ma'am Abby fills name/position/signature |
| `7_CERT_A3_FHS_Formula_Validation.pdf` | ⏳ Pending signature | Print → Ma'am Abby fills name/position/signature |

**Files at:** `docs/handsoff/FOR_MAAM_ELLEN/`

---

## 📝 FROM MA'AM ELLEN (adviser approvals)

| Document | Status | Action |
|---|---|---|
| `5_REVISED_QUESTIONNAIRE_FOR_VALIDATION.pdf` | ⏳ Pending signature | Ma'am Ellen signs the Content Validator block |

---

## 🔍 FROM CYRILLE (reference verification)

| Task | What to check | Action |
|---|---|---|
| Sharma et al. (2026) DOI | Go to https://doi.org/10.2991/978-94-6463-IYC-2026_28 | If invalid → delete reference + in-text citations |
| FHN (2026) reference | Search Google Scholar for "Financial Health Network 2026" | If not found → delete |
| Groq (2026) reference | Check developer.groq.com for official citation | If not found → delete |

---

## ✅ WHAT KIRO WILL DO WHEN DATA ARRIVES

When Brix brings any of the above:

1. **Survey CSVs** → recompute all stats (frequency, percentage, SUS mean, SD, sub-groups) → update all relevant tables and conclusions → push in one commit

2. **Screenshots/Figures as PNG** → insert into `CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx` at figure placeholder locations → update List of Figures → push

3. **Any other data** → update relevant sections → run final grep (`[[PENDING]] = 0`, `figure placeholder = 0`) → push

4. **Final push sequence:**
   - Run final consistency scan
   - Update `NOV9_PROGRESS_REPORT.md` with final numbers
   - Update `SURVEY_DATA_PRELIMINARY.md` with final N=30 stats
   - Push everything
   - Done ✅

---

## 📋 WHAT'S ALREADY DONE (do NOT redo)

- ✅ All 4 chapter markdown files — 0 `[[PENDING]]` tags, all numbers correct
- ✅ `CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx` — DIT, MIS, 36 badges, 34 actions, 62.50 SUS
- ✅ Presentation — 18 slides, Nov 10 date, real screenshots
- ✅ Defense script — 18 entries, speaker assignments
- ✅ All Q&A prep docs — inclusivity, UI/UX, FHS formula, deployment, AI ethics, originality
- ✅ Validation certificates — PDF + DOCX for Ma'am Abby
- ✅ Related Studies Table 2.1 — added to Chapter II
- ✅ FHS Milestone Timeline — added to Chapter II
- ✅ Compliance Matrix — updated Nov 6, Section 6 hard Q&As
- ✅ NOV9_PROGRESS_REPORT.md — ready for tomorrow's reporting

---

*Kiro is standing by. Bring the data and the final revision happens in one pass.*
