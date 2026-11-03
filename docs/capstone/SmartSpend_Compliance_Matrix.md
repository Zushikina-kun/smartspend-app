# SmartSpend — Capstone 2 Compliance Matrix
**AY 2026–2027, 1st Semester | Lorma Colleges, College of Computer Studies and Engineering (CCSE)**
**Group:** Lucid Frame — Brix A. Directo · Cyrille John M. Rubis · Djaunathan Albert S. Madayag
**Adviser:** Ms. Ellen F. Mangaoang, DIT
**Defense Date:** November 9, 2026 | **Submission Deadline:** November 6, 2026
**Last Updated:** October 26, 2026 | **App Version:** v3.1.1

> Status legend: ✅ DONE · 🔄 IN PROGRESS · ⏳ PENDING · ❌ NOT STARTED

---

## Section 1 — Capstone Documentation Requirements

| Requirement | Deliverable / Evidence | Status | Notes |
|-------------|----------------------|--------|-------|
| Title page (title, authors, adviser, institution, AY, date) | `CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx` | 🔄 IN PROGRESS | Updated from "Proposal" → "Capstone Project"; Nov 2026; Adviser: Ellen F. Mangaoang, DIT. Chairperson still TBA. **Dean: Jeoffrey B. Layco, [title TBD — confirm with Brix before printing]** |
| Abstract | Chapter I of __5_.docx | 🔄 IN PROGRESS | SUS sentence updated to "pending". Some `[[PENDING]]` tags remain. |
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
| Chapter III: Results & Discussion — Objective 3 (SUS evaluation) | __5_.docx Ch. III Obj 3 | 🔄 IN PROGRESS | SUS procedure written; Table 3.3 (Overall SUS Result) blank; Figure 3.11 placeholder. All numbers `[[PENDING]]`. **No SUS results exist yet.** |
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
| Android application (Flutter/Dart) | v3.1.1 APK, GitHub Releases | ✅ DONE | arm64-v8a ~47.5 MB; armeabi-v7a ~40.3 MB; x86_64 ~50.5 MB |
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
| 36 achievement badges + Peso celebrations | `achievements_screen.dart` | ✅ DONE | Badge unlock shows Peso bottom sheet |
| Peso Companion System (12 moods, gestures) | `peso_mascot.dart`, companion services | ✅ DONE | Double-tap, long-press, idle speech, 45 screens |
| Demo mode | `demo_service.dart`, login screen | ✅ DONE | "Try Demo" seeds realistic dataset |

---

## Section 3 — Evaluation & Validation

| Requirement | Deliverable / Evidence | Status | Notes |
|-------------|----------------------|--------|-------|
| Needs assessment survey (N=30, pre-design) | Google Forms Research Survey | 🔄 IN PROGRESS | Survey live. Need N=30 responses. Convenience sample via social media — inform adviser. |
| SUS evaluation (N=30, target mean ≥80) | Google Forms SUS Survey | 🔄 IN PROGRESS | Survey live. **NO RESULTS YET.** Add screening question: "Did you use the app for ≥10 min?" Only "Yes" responses count. |
| SUS form validity | Google Forms SUS Survey | ⏳ PENDING | Need: 10-item SUS standard wording confirmed; 18+ screening; consent statement; demographic items (age band, occupation, city, phone brand/RAM) |
| Expert validator — IT professional | Appendix signature page | ⏳ PENDING | Must certify technical correctness of methodology |
| Expert validator — financial management | Appendix signature page | ⏳ PENDING | Must certify financial accuracy of FHS formula and content |
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
| Demo device with latest APK | Android phone | ⏳ PENDING | Install v3.1.1 arm64 APK. Load demo data via "Try Demo". Test all 7 input methods. Reset AI daily limit before demo. Set AI model to Auto. Charge to 100%. |
| Presentation slides (~15 slides) | Defense script in `docs/manuscript/reseaches/smartspend-thesis-defense-script.md` | 🔄 IN PROGRESS | Script written for 15 slides. Slides 14 updated for v3.1.x. |
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
