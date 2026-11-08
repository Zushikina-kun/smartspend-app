# SmartSpend — Capstone 2 Compliance Matrix
**AY 2026–2027, 1st Semester | Lorma Colleges, College of Computer Studies and Engineering (CCSE)**
**Group:** Lucid Frame — Brix A. Directo · Cyrille John M. Rubis · Djaunathan Albert S. Madayag
**Adviser:** Ms. Ellen F. Mangaoang, DIT
**Defense Date:** November 9, 2026 | **Submission Deadline:** November 6, 2026
**Last Updated:** November 6, 2026 | **App Version:** v3.1.2

> Status legend: ✅ DONE · 🔄 IN PROGRESS · ⏳ PENDING · ❌ NOT STARTED

---

## Section 1 — Capstone Documentation Requirements

| Requirement | Deliverable / Evidence | Status | Notes |
|-------------|----------------------|--------|-------|
| Title page (title, authors, adviser, institution, AY, date) | `CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx` | ✅ DONE | Mangaoang DIT confirmed. Dean: Jeoffrey B. Layco, MIS confirmed. |
| Abstract | Chapter I of __5_.docx | ✅ DONE | SUS sentence updated to preliminary 61.83 Grade C. No fabricated claims. |
| Chapter I: Introduction, Background of the Study | __5_.docx Chapter I | ✅ DONE | Written. BSP CFIS 2025 figures updated (literacy 74%, account ownership 50%, household access 85%). |
| Chapter I: Problem Statement | __5_.docx Chapter I | ✅ DONE | 5-point enumeration; validated via needs assessment |
| Chapter I: Objectives (3 research objectives) | __5_.docx Chapter I | ✅ DONE | Obj 1: financial practices baseline; Obj 2: system design/architecture; Obj 3: SUS evaluation |
| Chapter I: Scope & Limitations | __5_.docx Chapter I | ✅ DONE | Android-only, San Fernando La Union, N=30 sample |
| Chapter I: Significance of the Study | __5_.docx Chapter I | ✅ DONE | |
| Chapter II: Review of Related Literature & Studies (min 15 refs) | __5_.docx Chapter II | 🔄 IN PROGRESS | 16 references added in __4_/__5_. Three unverified refs: FHN (2026), Groq (2026), Li et al. (2024) — need final check before print. |
| Chapter II: Conceptual Framework / IPO diagram | __5_.docx Chapter II + Figure 1.2 placeholder | ⏳ PENDING | Figure 1.2 is a placeholder; must be drawn (Cyrille). |
| Chapter II: Development Methodology (Kanban, Table 2.2) | Table 2.2 added in __4_ | ✅ DONE | 3-column Kanban phases table |
| Chapter III: Results & Discussion — Objective 1 (needs assessment) | __5_.docx Ch. III Obj 1 | 🔄 IN PROGRESS | Survey live; `[[PENDING]]` tags for N, frequencies, percentages. Fill only from real responses. |
| Chapter III: Results & Discussion — Objective 2 (system design) | __5_.docx Ch. III Obj 2 | ✅ DONE | LLM benchmark Table 3.2 (20 models); FHS computation; system architecture; Peso companion; privacy tiers; local LLM. Two `[[VERIFY]]` notes remain (TBD cells in Table 3.2; Cerebras key). |
| Chapter III: Results & Discussion — Objective 3 (SUS evaluation) | __5_.docx Ch. III Obj 3 | 🔄 IN PROGRESS | SUS procedure written; preliminary N=5 results filled (61.83, Grade C, below 68 benchmark). Full N=30 ongoing. |
| Chapter III: Overview of the System (Figures 3.1–3.3) | __5_.docx placeholders | ⏳ PENDING | Flowchart, use case diagram, visual ToC — all placeholders. Must be replaced with real diagrams. |
| Chapter III: Production Screens (Figures 3.4–3.10) | __5_.docx placeholders | ⏳ PENDING | 7 figure placeholders for login/demo, dashboard, AI chat, receipt import, FHS, budgets/goals, Local AI. Replace with real v3.1.1 screenshots. |
| Chapter IV: Conclusions (3 objectives) | __5_.docx Chapter IV | 🔄 IN PROGRESS | Obj 2 conclusion written. Obj 1 & 3 pending survey data. |
| Chapter IV: Recommendations (7 items) | __5_.docx Chapter IV | 🔄 IN PROGRESS | 7 recommendations written (payday cycle, SMS autologging, edge AI, empirical validation, PLS-SEM, dual-method reporting, longitudinal evaluation). Payday cycle has `[[VERIFY]]` — confirm not already in v3.1.1. |
| Bibliography (APA 7th edition, all references) | References section of __5_.docx | 🔄 IN PROGRESS | 16 new refs added; 3 unverified (FHN 2026, Groq 2026, Li 2024); Bitrián DOI corrected; Kahneman & Tversky added. OFxPERA/BSP Open Finance ref may be orphaned after Ch. IV edit — check. |
| Table of Contents | Manual in manuscript | ⏳ PENDING | Not updated since Ch. III/IV added. Update after all figures are inserted and page count is final. |
| List of Tables | Manual in manuscript | ⏳ PENDING | Add Tables 2.2, 3.1–3.5. |
| List of Figures | Manual in manuscript | ⏳ PENDING | Add Figures 3.1–3.11. |
| Approval Sheet (adviser + panel signatures) | __5_.docx Approval Sheet | ⏳ PENDING | Adviser: Ellen F. Mangaoang, DIT. Chairperson: TBA. Panel: Raposas, Mzana. **Dean: Jeoffrey B. Layco, [title TBD — Brix to confirm]** |
| Appendices (SUS instrument, validator certificates, raw data) | Not yet compiled | ⏳ PENDING | Need: actual 10-item SUS questionnaire printout; validator signature pages (IT prof + finance expert); sample survey responses. |

**Critical before printing:** `Ctrl+F [[` must find nothing (currently 97 tags in __5_.docx).

---

## Section 2 — System / Software Deliverables

| Requirement | Deliverable / Evidence | Status | Notes |
|-------------|----------------------|--------|-------|
| Android application (Flutter/Dart) | v3.1.2 APK, GitHub Releases | ✅ DONE | arm64-v8a ~47.6 MB; armeabi-v7a ~40.4 MB; x86_64 ~50.6 MB |
| Minimum SDK: Android 5.0 (API 21) | `pubspec.yaml`, `build.gradle` | ✅ DONE | Target SDK: API 36 (Android 16) |
| Taglish AI expense logging | `ai_chat_service.dart`; 34 agentic actions | ✅ DONE | Action parser bug fixed (c5434cd) — transactions now save correctly |
| 7 input modalities | Voice, OCR, batch screenshot, barcode, bank paste, manual, AI chat | ✅ DONE | All 7 functional in v3.1.1 |
| Financial Health Score (0–100) | `score_service.dart` | ✅ DONE | Full mode (4 components) + Lightweight mode (4 different components); confirmed from code |
| FHS breakdown dialog | Home screen + Analytics screen | ✅ DONE | Shows component name, points, reason for each of 4 components |
| Budget management | `budget_screen.dart`, `DBService` | ✅ DONE | Per-category monthly limits; 5 budget categories in demo data |
| Savings goals with milestone reactions | `savings_goals_screen.dart` | ✅ DONE | 25/50/75/100% Peso celebrations |
| Analytics & reporting | `analytics_screen.dart` | ✅ DONE | FHS history chart, 50/30/20, category breakdown, trends, heatmap |
| Push notifications (Peso-voiced Taglish) | `notification_service.dart` | ✅ DONE | 20+ notifications; all rewritten in Peso's Taglish voice (v3.0.8) |
| Offline-first operation | SQLite v14 (26 tables); `CloudService` | ✅ DONE | Core features 100% offline; AI chat + rates need internet |
| Batch screenshot import (40+ platforms) | `batch_image_import_screen.dart` | ✅ DONE | GCash, Shopee, Steam, Maya, Lazada, bank receipts, etc. |
| Export / Backup (CSV + JSON) | `backup_service.dart` | ✅ DONE | JSON + CSV export; auto-save on local mode logout |
| RA 10173 PII redaction | `_redactPii()` in `ai_chat_service.dart` | ✅ DONE | 5 pattern types redacted (mobile numbers, ref numbers, OTPs, account numbers) |
| Local AI mode (Ollama/LM Studio/Jan) | `app_config.dart` custom_local provider | ✅ DONE | WiFi-based local LLM; Local-only mode toggle (no cloud fallback) |
| Paluwagan tracker | `paluwagan_screen.dart` | ✅ DONE | Implemented v3.0.0 |
| Multi-wallet support (Cash, GCash, bank) | `wallet_screen.dart`, `DBService` | ✅ DONE | |
| Debt / lending tracker | `debt_screen.dart` | ✅ DONE | I Owe + Owed to Me tabs |
| Installment plan tracker | `payment_plans_screen.dart` | ✅ DONE | GLoan, HomeCredit, SPayLater, etc. |
| SSS / PhilHealth / Pag-IBIG contributions | `insurance_screen.dart` | ✅ DONE | Government contributions tracked |
| 36 achievement badges + Peso celebrations | `achievements_screen.dart` | ✅ DONE | 36 badges confirmed from source code |
| Peso Companion System (12 moods, gestures) | `peso_mascot.dart`, companion services | ✅ DONE | Double-tap, long-press, idle speech, 45 screens |
| Accessibility features (high contrast, text scaling, 12 themes, dark/light mode) | `theme_service.dart`, Settings screen | ✅ DONE | Material 3, WCAG AA high contrast mode, 12 themes (Emerald default), text scale (Normal/Large/XL), compact mode |
| Demo mode | `demo_service.dart`, login screen | ✅ DONE | "Try Demo" seeds realistic dataset |

---

## Section 3 — Evaluation & Validation

| Requirement | Deliverable / Evidence | Status | Notes |
|-------------|----------------------|--------|-------|
| Needs assessment survey (N=30, pre-design) | Google Forms Research Survey | 🔄 IN PROGRESS | N=13 preliminary responses collected. Need N=30. Revised to 13 questions per adviser. |
| SUS evaluation (N=30, target mean ≥80) | Google Forms SUS Survey | 🔄 IN PROGRESS | N=5 preliminary: mean SUS = 61.83 (Grade C, below 68 benchmark). Acknowledged as limitation. Full N=30 ongoing. |
| SUS form validity | Google Forms SUS Survey | ⏳ PENDING | Need: 10-item SUS standard wording confirmed; 18+ screening; consent statement; demographic items (age band, occupation, city, phone brand/RAM) |
| Expert validator — financial management | `docs/handsoff/FOR_MAAM_ELLEN/7_CERT_A3_FHS_Formula_Validation.pdf` | 🔄 IN PROGRESS | Ma'am Abby (finance expert) — certificate prepared, awaiting signature |
| Expert validator — IT professional | `docs/handsoff/FOR_MAAM_ELLEN/6_CERT_A1_Survey_Questionnaire_Validation.pdf` | ⏳ PENDING | Certificate prepared. Need IT/software expert to sign. Ask Sir Raposas. |
| LLM benchmark test (Table 3.2, 9 providers) | `docs/reference/BENCHMARK.md` | 🔄 IN PROGRESS | Gemini, Groq GPT-OSS 120B, Qwen3.6 filled. TBD: GPT-OSS 20B, Qwen3.8, Compound Mini speed + Filipino accuracy. Run against test corpus. |
| OCR parsing accuracy test (Table 3.5, 50 receipts) | None found in repo | ⏳ PENDING | **No real test exists.** Must conduct and log test: 50 receipts across platforms (GCash, Maya, Shopee, Lazada, thermal), record precision/recall per platform. |
| Engineering performance (sync recovery, DB integrity) | Debug logs; `DBService` | ✅ DONE | 100% DB recovery under simulated network dropout confirmed in testing. Zero locking/duplication errors. |
| OCR precision/recall (91.2%/88.5%) | Used in manuscript | ⏳ PENDING | Source of these numbers unclear — verify from a real test or remove. |
| AI categorization accuracy (94.6%) | Used in manuscript | ⏳ PENDING | Source unclear — verify from a real test or mark as estimate. |

---

## Section 4 — Ethical & Legal Compliance

| Requirement | Deliverable / Evidence | Status | Notes |
|-------------|----------------------|--------|-------|
| RA 10173 Data Privacy Act compliance | `_redactPii()` in `ai_chat_service.dart`; first-use privacy disclosure screen | ✅ DONE | 5 PII types redacted before cloud; disclosure shown on first AI message |
| Informed consent on survey forms | Google Forms (both surveys) | ⏳ PENDING | Consent statement not yet confirmed present. Template in `ads-and-survey-copy-pack-2026-10-15.md` §4 |
| 18+ confirmation on surveys | Google Forms | ⏳ PENDING | Required since recruiting via social media reaches minors |
| Anonymous data collection | Google Forms | ⏳ PENDING | Only true if forms do not collect email / require sign-in — verify in Form Settings → Responses |
| APA 7th edition citations | References in manuscript | 🔄 IN PROGRESS | 16 refs added; 3 unverified; Bitrián DOI corrected |
| No plagiarism | Original development | ✅ DONE | All code by team; AI tools (Claude/Kiro) used for assistance |
| Source Available License (Non-Commercial) | `LICENSE` file in repo root | ✅ DONE | Academic review allowed; commercial use prohibited without written permission |
| Google Gemini free-tier disclosure | First-use privacy disclosure screen | 🔄 IN PROGRESS | Free-tier Gemini content may be used to improve Google products. Disclose this in the privacy screen and FAQ. Blaze billing does not by itself change terms — confirm key's Cloud project billing status. |
| No invented/fabricated data in manuscript | All `[[PENDING]]` tags | ⏳ PENDING | 97 tags in __5_.docx must be filled from real data only or deleted. Never leave a blank or invented number. |

---

## Section 5 — Defense Readiness

| Requirement | Deliverable / Evidence | Status | Notes |
|-------------|----------------------|--------|-------|
| Defense fee paid | Receipt | ⏳ PENDING | Computation from Sir Raposas. Pay before Nov 6. |
| 3 printed manuscript copies | Printed __5_.docx | ⏳ PENDING | Deadline Nov 6. Zero `[[` tags required first. Use Word (LibreOffice crashes on floating tables). |
| Numbered pages, consistent formatting | __5_.docx | 🔄 IN PROGRESS | Font/styles verified consistent. TOC/List of Tables/Figures need manual update. |
| Demo device with latest APK | Android phone | ⏳ PENDING | Install v3.1.2 arm64 APK. Load demo data via "Try Demo". Test all 7 input methods. Reset AI daily limit before demo. Set AI model to Auto. Charge to 100%. |
| Presentation slides (~16 slides) | `docs/capstone/SmartSpend_Defense_Presentation.html` + .pptx | 🔄 IN PROGRESS | 16 slides with real screenshots. Defense script per slide being created. |
| Pitch video (~3 min) | Not yet recorded | ⏳ PENDING | Script in "SmartSpend Defense Prep Pack (Nov 9, 2026).docx". Needs v3.1.1 screen recording with demo data loaded. |
| Certificate of Deployment or MOA | GitHub Release + website as deployment evidence | 🔄 IN PROGRESS | Sir Raposas indicated no partner org needed if app is deployed. Evidence: GitHub Releases page + download count screenshot + install guide. Templates in "Certificate of Deployment and MOA Templates.docx". |
| Q&A preparation | `docs/guides/DEFENSE_COUNTERARGUMENTS.md` | ✅ DONE | Counterarguments and defense responses documented. |
| Figures 3.1–3.11 in manuscript | All placeholders in __5_.docx | ⏳ PENDING | All 11 are placeholders. Insert real v3.1.1 screenshots and diagrams. Caption below each, centered, followed by Present/Interpret paragraph. |
| Figure numbering style confirmed with adviser | TBD | ⏳ PENDING | Chapter-based (Figure 3.1) vs sequential (Figure 15) — confirm with Ms. Mangaoang before final print. |
| SUS acceptance target consistent (≥80) | Chapters I, II, III, IV + Abstract | 🔄 IN PROGRESS | Must appear consistently in all chapters. |
| Adviser pre-final review | Scheduled meeting | ⏳ PENDING | Show draft to Ms. Mangaoang before printing. |

---

## Summary — What to do before Nov 6

### Brix (now, no Kiro needed)
1. Fix both Google Forms: add use-first screening, 18+ confirmation, consent line, demographic items
2. Edit site SUS banner: "Try the app for ~10 minutes first, then answer"
3. Confirm deployment evidence with Sir Raposas (in writing: no partner org needed?)
4. Start collecting survey responses
5. Verify Dean's name with school admin
6. Record pitch video using demo data

### Cyrille (Kiro can help with templates, but Cyrille must draw/create)
1. Draw Figures 1.1 (PH financial literacy bar chart), 1.2 (IPO diagram), 2.1 (SUS scale), 2.2 (Kanban board)
2. Replace Figures 3.1–3.11 placeholders with real v3.1.1 screenshots + diagrams
3. Update Table of Contents, List of Tables, List of Figures (manual — page numbers needed)
4. Verify 3 unverified references (FHN 2026, Groq 2026, Li 2024)
5. Fill `[[PENDING]]` tags once survey responses arrive (97 total)

### Claude (when Kiro's answers + survey data are ready)
1. Fill manuscript `[[PENDING]]` tags from real survey data only
2. Correct Budget Adherence zero-budget claim (reweight → auto-25)
3. Update cloud payload FAQ description in manuscript (matches code now)
4. Verify Dean name and update title page
5. Final `Ctrl+F [[` sweep — must find nothing before handing to Cyrille

---

*Last verified: October 26, 2026. Source: `docs/handsoff/kiro-to-claude-answers-2026-11-01.md`, `docs/reference/CAPSTONE_REFERENCE.md`, `docs/status/PROJECT_STATUS.md`.*

---

## Section 6 — Hard Panelist Questions & Ready Answers

These are the questions panelists are most likely to ask that are NOT already in `DEFENSE_QA_PREP.md`. Memorize these before Nov 9.

---

### "Why would someone use SmartSpend instead of just writing in a notebook or using Excel?"

> **Answer:** Manual tracking works, but it fails on three things our respondents confirmed: (1) **friction** — 53.8% of our respondents already use manual methods but find them inconvenient; the average expense takes 3–5 seconds to log in SmartSpend via Taglish voice or chat versus writing it by hand and calculating totals later; (2) **no behavioral feedback** — a notebook shows you what you spent but doesn't tell you if you're on track or warn you before you overspend; our FHS score and Warning Decay do this automatically; (3) **no AI categorization** — in the Philippines, GCash and Shopee transaction strings are cryptic (e.g., "GCash POS-19329"); SmartSpend parses those automatically. Excel addresses #3 partially but still requires manual entry and has no behavioral nudge layer.

---

### "Isn't your app only for rich people? Poor people don't log daily transactions."

> **Answer:** The data says the opposite — low-income Filipinos are the ones who need this tool most, and SmartSpend was specifically designed to serve them.
>
> **Who needs it most:** The PSA (2025 Official Poverty Statistics) counted 15.5% of individual Filipinos — 17.54 million people — living in poverty in 2023, with 6.4% of families (1.90 million families) classified as poor in 2025. These households have zero margin for financial mismanagement. A wealthy family absorbs overspending easily; a low-income family cannot. Financial tracking tools are equity tools, not luxury tools — and the people who benefit most are those with the least room for error.
>
> **Digital adoption is not limited to the wealthy:** BSP CFIS 2025 reports that 62% of households with electronic devices used them for online financial transactions — up from 35% in 2022. That rapid adoption is not isolated to high-income brackets. GCash has 41.5 million monthly active users including lower- and middle-income households, women, and provincial communities (Bloomberg/Mynt 2026). ResearchSquare (2025) research in rural Philippine villages found that income had no notable influence on GCash adoption — meaning poor and low-income Filipinos actively use GCash at the same rate as higher-income users.
>
> **SmartSpend removes every adoption barrier for low-income users:**
> - **FREE** — no subscription, no bank account required, zero cost to download and use permanently.
> - **Offline-first** — core features work with zero internet or mobile data; no recurring data cost.
> - **Android 5.0+** — runs on budget phones available for ₱3,000–₱5,000, which are the phones most low-income Filipinos own.
> - **Lightweight Mode** — no income tracking needed; designed for gig workers, vendors, drivers, and informal economy workers who do not have a fixed salary. The FHS Lightweight Mode still calculates a meaningful score without any income data.
> - **Batch GCash screenshot import** — GCash users (who are disproportionately low-to-mid-income) can import their full transaction history in bulk from screenshots, with zero manual entry. For these users, the "logging is too much work" objection does not apply at all — SmartSpend does the logging for them from their existing GCash activity.
>
> **Daily logging is NOT required.** Even logging major expenses a few times a week gives useful FHS feedback. And for the 41.5 million GCash users — including the low-income households who form a large share of that base — batch screenshot import means there is no manual logging at all. Their existing GCash history becomes their expense log automatically.
>
> **Core argument:** "Poor people don't log expenses" is precisely the problem this app exists to solve. The absence of structured financial tracking is a pattern that can keep households in financial difficulty. SmartSpend reduces that friction to near-zero for GCash users — the very population most skeptics assume cannot use it.

---

### "Is your app deployed? Where can people download it?"

> **Answer:** Yes. SmartSpend v3.1.2 is deployed on GitHub Releases at https://github.com/Zushikina-kun/smartspend-app/releases/latest. Three APK variants are available: arm64-v8a (~47.6MB), armeabi-v7a (~40.4MB), and x86_64 (~50.6MB). It is also accessible via our project website. We did not deploy to the Google Play Store because Play Store requires a ₱25 one-time developer fee and a full privacy policy URL, which we will implement in future work. GitHub Releases is a valid and widely-used distribution channel for Android prototype applications during academic evaluation phases.

---

### "Did you test this with real users? How many?"

> **Answer:** Yes. For Objective 1 (needs assessment), we surveyed N=13 respondents (preliminary; target N=30) — 9 young professionals and 4 parents. For Objective 3 (usability evaluation using SUS), N=5 respondents evaluated the app (preliminary; target N=30), yielding a mean SUS score of 61.83 (Grade C, "OK" per Bangor et al., 2009). We acknowledge this is below the 68-point average benchmark and below our target of ≥80. We attribute this to the small preliminary sample size and the prototype nature of the system. Full N=30 data collection is ongoing.

---

### "Why only N=30? Other studies use hundreds of respondents."

> **Answer:** This question is addressed in our methodology. SmartSpend is evaluated as a **functional prototype** using the System Usability Scale — not a population-wide behavioral study. Nielsen (1993) and Faulkner (2003) empirically showed that 5 participants uncover 80–85% of usability defects, and 20–30 participants uncover 90–95% of issues. For SUS specifically, a purposive sample of N=30 is the established standard in HCI literature. In contrast, studies using PLS-SEM (like the Atlantis Press 2026 study we cite) needed large samples because they were testing structural covariance across a population — a fundamentally different statistical goal. Our N=30 is appropriate for prototype usability validation.

---

### "What happens to user data? Is it safe?"

> **Answer:** SmartSpend implements a three-tier privacy architecture compliant with RA 10173: (1) all transaction records are stored locally on-device in SQLite — nothing is sent to the cloud by default; (2) before any text or screenshot is processed by the cloud AI, our `_redactPii()` function strips 5 PII types — Philippine mobile numbers, GCash/bank reference numbers, OTPs/PINs, bank account numbers, and 09XX patterns; (3) optional Firebase sync is strictly scoped to the authenticated user's own UID. No third party can access another user's data. We acknowledge that Gemini free-tier usage may be used by Google to improve their models — this is disclosed in our first-use privacy screen.

---

### "Could the AI give wrong financial advice and harm users?"

> **Answer:** We mitigated this with four controls: (1) the AI is system-prompted to refuse investment, tax, and legal advice — it is restricted to educational financial assistance; (2) every agentic action (like logging an expense or setting a budget) requires a "Review and Confirm" screen before writing to the database — the user is always in control; (3) our NIST AI RMF integration registers hallucination as a known risk and we enforce a 120-transaction batch cap to prevent long-context hallucinations; (4) all AI responses include a disclaimer that they are non-prescriptive and educational only. No financial decision is executed without explicit user confirmation.

---

### "What if the internet is down — does the app still work?"

> **Answer:** Yes — SmartSpend is offline-first by design. All core features work without internet: manual expense logging, budget management, FHS calculation, savings goals, analytics, receipts OCR, and all reports. The only features that require internet are: cloud AI chat (Peso conversation), Firebase cloud sync (optional), and automatic exchange rates. We designed this specifically for regional users in La Union where mobile data coverage can be intermittent. The SQLite database is local and recovers automatically when connectivity returns.

---

### "Why did you use Gemini instead of GPT or a local model?"

> **Answer:** We conducted a structured benchmarking study of 15 LLM APIs. Gemini 3.5 Flash-Lite was selected because it offered: (1) the highest free-tier quota at 1,000 requests/day — GPT-4o Mini and Claude are paid-only, which is not viable for a capstone prototype; (2) 98.5% Taglish parsing accuracy — the highest among free-tier models; (3) a 1-million token context window enabling direct full-context injection of the user's entire database; (4) native function-calling for all 34 agentic actions. The full benchmarking results are in Table 3.2 of our manuscript. We do have a 6-provider fallback chain including Groq and Cerebras for availability resilience.

---

### "What are the limitations of your system?"

> **Answer (key points):** (1) **No direct bank API** — transactions must be manually logged, pasted, or imported via screenshots; (2) **AI requires internet** — offline operation means no AI chat; (3) **Android-only** — no iOS version yet; (4) **FHS is a prototype indicator** — not clinically validated; our equal weights are methodologically defensible but not empirically derived from longitudinal data; (5) **SUS 61.83 is below average** — we acknowledge this as a limitation of the current prototype at N=5 preliminary; (6) **No longitudinal behavioral data** — we cannot yet claim the app actually changes spending habits, only that it is designed to.

---

---

### "The app's colors/design are painful to the eyes. The UI/UX looks bad."

> **Answer:** The app is not locked into one color scheme — it ships with **12 selectable color themes**: Emerald (default, Peso's signature color), Ocean Blue, Sky Blue, Forest Green, Royal Purple, Sunset Orange, Crimson Red, Deep Navy, Midnight Teal, Rose Pink, Charcoal, and Slate. Users open Settings and switch themes in under 10 seconds.
>
> **Accessibility modes already in the app:**
> - **Dark / Light mode** — full toggle via `ThemeService.toggle()`
> - **High contrast mode** — when enabled, forces a full WCAG AA black/white scheme (`ColorScheme.light(primary: Colors.black)` / `ColorScheme.dark(primary: Colors.white)`); designed for users with visual impairments
> - **Text scaling** — three levels: Normal (1.0×), Large (1.15×), Extra Large (1.3×)
> - **Compact mode** — reduced UI density for smaller screens
>
> **Why it looks a certain way in the screenshots:** The defense screenshots show the default Emerald theme (`Color(0xFF00C896)`). That is Peso's signature color and our brand identity, but it is one of twelve options.
>
> **Color science:** SmartSpend uses **Material 3** (`useMaterial3: true`) with `ColorScheme.fromSeed()` — Google's 2023–2026 design system that auto-generates accessible, harmonious color relationships from a seed color. This is the same system used in Google's own first-party apps.
>
> **Live demo response (if panelist raises this during defense):** "Kung gusto ninyong makita ang ibang kulay, maaari po naming palitan ang theme ngayon sa Settings — tatagal lang ng sampung segundo. Pwede po nating subukan ang Sky Blue o Forest Green kung mas komportable kayo." (Switch right then in the demo.)

*Section 6 added November 6, 2026. Cross-reference: `docs/capstone/DEFENSE_QA_PREP.md` for additional Q&A.*
