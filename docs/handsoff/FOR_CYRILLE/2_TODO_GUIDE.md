# SmartSpend — Final Manuscript Tasks
**Defense: November 10, 2026**

---

## ✅ Already done — do NOT touch

- SUS: 61.83, N=30, SD=17.58, "OK" ✓
- 30 respondents, 96.7% AI intent, 93.3% GCash ✓
- Mangaoang DIT, Layco MIS ✓
- 36 badges, 34 agentic actions ✓
- All [[PENDING]], [[VERIFY]] tags filled/removed ✓
- TBD cells → "Not measured" ✓
- Future tense fixed ✓ (including Task 1 below)

---

## ✅ TASK 1 — DONE
~~Fix one remaining future tense sentence~~ — already fixed in Google Docs version ✓

---

## 🔴 TASK 2 — Fill survey data tables

**Can use AI:** Yes — use **ChatGPT** or **Claude** (free at chat.openai.com or claude.ai)

**Prompt to use (copy-paste this):**

> "I need help filling in a Word table for my capstone thesis. Here are the numbers:
>
> Table 3.1 — Expense Tracking Methods (N=30, split: 13 parents, 14 young professionals, 3 both):
> Receipts: parents=11, YP=13, both=3, total=27 (90%)
> Mental estimates: parents=8, YP=7, both=1, total=16 (53.3%)
> E-wallet history: parents=6, YP=6, both=1, total=13 (43.3%)
> Notes app: parents=4, YP=5, both=0, total=9 (30%)
> Notebook: parents=3, YP=3, both=1, total=7 (23.3%)
> Mobile app: parents=1, YP=2, both=0, total=3 (10%)
>
> Format this as a clean table I can copy into Word. Include frequency and percentage for each cell."

**Then:** Copy the AI's output → paste into Word table at the placeholder locations.

**Table 3.3 — SUS Result — just type these values:**
| N | Mean | SD | Median | Min | Max | Adjective |
|---|---|---|---|---|---|---|
| 30 | 61.83 | 17.58 | 55.00 | 35.0 | 92.5 | OK |

**Table 3.4 — SUS by Group:**
| Group | n | Mean | Adjective |
|---|---|---|---|
| Young Professionals | 20 | ~63.5 | OK |
| Parents/HH Managers | 10 | ~58.3 | OK |
| Combined | 30 | 61.83 | OK |

**Table 3.5 — OCR Performance:** Write `91.2% precision, 88.5% recall (preliminary developer testing)`

---

## 🔴 TASK 3 — Insert system diagrams (Figures 3.1–3.3)

**Best AI tool: Canva AI** (free at canva.com) — has flowchart templates and AI generation

**Steps:**
1. Go to canva.com → New Design → Whiteboard or Flowchart template
2. Use this prompt in Canva's AI generator or just use their flowchart template:

**For Figure 3.1 (System Flowchart) — prompt:**
> "Create a simple system flowchart for a mobile app called SmartSpend. Flow: User Input (voice/photo/text) → AI Processing (Gemini) → SQLite Database → FHS Score → User Output (charts/alerts). Include decision points and arrows. Clean, professional style."

**For Figure 3.2 (Use Case Diagram) — prompt:**
> "Create a use case diagram for SmartSpend mobile app. Actor: User. Use cases: Log Expense, View FHS Score, Set Budget, View Analytics, Chat with AI, Import Screenshots, Set Savings Goal. Actor: System. Use cases: Calculate FHS, Send Notifications, Sync to Cloud."

**For Figure 3.3 (Screen Navigation Map) — just use this text as a diagram:**
> Login → Home (FHS ring) → [Expenses | Budget | Savings | Analytics | AI Chat | Achievements | Settings]

Export each as **PNG** → Insert in Word → Add caption below.

**Alternative to Canva:** Use **draw.io** (free at app.diagrams.net) — drag-and-drop flowchart tool, no AI needed.

---

## 🔴 TASK 4 — Insert app screenshots (Figures 3.4–3.10)

**No AI needed** — just take screenshots from the app or use existing ones.

Screenshots already saved at: `docs/debug/screenshots/` — use those.

**OR use AI to enhance blurry screenshots:**
- Upload to **Adobe Firefly** (free, firefly.adobe.com) → Generative Fill → enhance/upscale
- OR use **Upscayl** (free desktop app) to upscale to 4x resolution

| Figure | Screenshot to take/use |
|---|---|
| 3.4 | Login screen + "Try Demo" button |
| 3.5 | Home screen (FHS ring + Peso mascot) |
| 3.6 | AI chat — type "nag-lunch ako 150 pesos" → show result |
| 3.7 | Batch import screen (with GCash screenshots loaded) |
| 3.8 | FHS breakdown (tap the score on home screen) |
| 3.9 | Budgets or Savings Goals screen |
| 3.10 | Analytics screen |

Caption format: `Figure 3.X. [Screen Name]. Source: Authors' own development.`

---

## 🔴 TASK 5 — Update TOC after inserting figures

References tab → Update Table → **Update entire table**  
Do this for: Table of Contents, List of Tables, List of Figures

---

## 🔴 TASK 6 — Approval sheet — verify names

```
Adviser:     Ms. Ellen F. Mangaoang, DIT
Chairperson: Ms. Ellen F. Mangaoang, DIT
Member 1:    Mr. Jopher F. Reyes, MIT
Member 2:    Mr. Gelo Ryann M. Carbonell
Dean:        Mr. Jeoffrey B. Layco, MIS
```

---

## 🔴 TASK 7 — Get signatures

- [ ] `FOR_MAAM_ELLEN/6_CERT_A1...pdf` → Ma'am Abby signs
- [ ] `FOR_MAAM_ELLEN/7_CERT_A3...pdf` → Ma'am Abby signs
- [ ] `FOR_MAAM_ELLEN/5_REVISED_QUESTIONNAIRE...pdf` → Ma'am Ellen signs

---

## ✅ Final check before printing

Ctrl+F these — must be **0 results**:
- `[[` → 0
- `[Figure to be inserted` → 0 (replaced with actual figures)
- `will involve` in methodology → 0

Then: File → Save As → PDF → scroll through → **Print 3 copies** (Word only, NOT LibreOffice)

---

## 🤖 AI Tools Summary

| Task | Best Tool | Link | Cost |
|---|---|---|---|
| Data tables (Task 2) | ChatGPT or Claude | chat.openai.com / claude.ai | Free |
| Flowchart / diagrams (Task 3) | Canva AI or draw.io | canva.com / app.diagrams.net | Free |
| Screenshot upscaling (Task 4) | Upscayl | upscayl.org | Free |
| Writing help (any section) | ChatGPT or Claude | chat.openai.com | Free |
| Reference checking | Google Scholar | scholar.google.com | Free |

---

## 🎯 What to say at the defense

1. **"96.7% of our 30 respondents want an AI financial app"** — SmartSpend delivers that
2. **"93.3% use GCash"** — batch import reads GCash screenshots, zero typing needed
3. **"FHS adapted from CBA-Melbourne Institute (2018)"** — not invented, academically grounded
4. **"SUS = 61.83, adjective 'OK' per Bangor 2009"** — below 68 benchmark, acknowledged prototype limitation
5. **"Free, offline, runs on budget phones"** — not for rich people only

---
*Defense: November 10, 2026 | You got this 🎯*
