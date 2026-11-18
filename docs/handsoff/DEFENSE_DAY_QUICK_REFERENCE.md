# SmartSpend Pre-Finals Defense - Quick Reference
**Date:** November 16, 2026
**Defense Time:** (Confirm with your instructor)

## 📋 Panel Members (From Manuscript Approval Sheet)
- **Chairperson:** Jeoffrey B. Layco, MIS (Dean, CCSE)
- **Members:** 
  - Shekiro R. Raposas, MTS, MIS
  - Mary-Ann Mzana, MTS
- **Adviser:** Dr. Ellen F. Mangaoang, DIT
- **Teacher-in-Charge:** Shekiro R. Raposas, MTS, MIS

## 📱 Demo Phone Setup (DO TONIGHT!)

### Pre-Demo Checklist
- [ ] Phone charged to 100%
- [ ] Do Not Disturb ON
- [ ] WiFi/Data connection verified working
- [ ] App installed: SmartSpend v3.2.1
- [ ] Demo data loaded (tap "Try Demo" on login)
- [ ] AI Model set to: **Auto (Recommended)**
- [ ] Settings → Quick Presets → **Normal** (NOT Lite)
- [ ] AI daily limit reset (⋮ menu → Reset Daily Limit = 150 messages)
- [ ] Run through demo script ONCE to verify everything works
- [ ] Close app, don't reopen until defense

### Backup Equipment
- [ ] USB cable + charger (in case battery runs low)
- [ ] Second phone with WiFi hotspot (backup internet)
- [ ] Printed manuscript (3 copies)
- [ ] Compliance Matrix (printed for signatures)
- [ ] Defense fee receipt
- [ ] Pen

---

## 🎯 10-Minute Demo Script

### 1. Opening (30 seconds)
- Cold start from home screen
- Tap "Try Demo" → Home loads with FHS score
- **Say:** *"This is SmartSpend v3.2.1 — an AI-powered personal finance app built for Filipino users."*

### 2. AI Taglish Logging (2 minutes)
- Go to **AI (Peso)** tab
- **Type:** `"nag-gastos ako ng 65 sa canteen for lunch at 13 para sa jeep"`
- Show Peso's Taglish confirmation
- Show session summary card (✅ 2 recorded)
- **Say:** *"Peso understands Filipino and English. No forms, no dropdowns — just natural conversation."*

### 3. Financial Health Score (1.5 minutes)
- Go to **Home** → tap FHS score card
- Show 5 components: Spending Control, Savings Rate, Debt Management, Budget Adherence, Goal Progress
- **Say:** *"Our Financial Health Score — 0 to 100, calculated from actual spending behavior. Each dimension is weighted based on financial planning best practices."*

### 4. Batch Screenshot Import (2 minutes)
- **AI tab** → camera icon → **Batch Screenshots**
- Select 2-3 GCash/Shopee screenshots
- Show AI parsing → review → confirm
- **Say:** *"Import from GCash, Shopee, Steam, Maya — 40+ platforms supported. Peso reads and logs everything automatically."*

### 5. Analytics Dashboard (1 minute)
- **Analytics tab** → Quick Jump: Overview
- Show pie chart, 50/30/20 tracker, spending trends
- **Say:** *"Real-time analytics showing spending patterns, category breakdowns, and financial health history."*

### 6. Theme Selection (30 seconds)
- **Settings** → **Appearance** → Show 12 theme options
- **Say:** *"Addressing panel feedback about 'color pollution' — users can now choose from 12 themes plus high-contrast mode and font size controls."*

### 7. Advanced Features (1 minute)
- Show **Achievements** screen (33 badges)
- Show **Goals** screen with milestones
- Show **Paluwagan/Debt Tracker**
- **Say:** *"Added features include government contributions tracker, paluwagan system, debt management, and gamification through achievement badges."*

### 8. Local AI Mode (30 seconds)
- **Settings** → **AI** → show Private Local Mode
- **Say:** *"Optional privacy mode — users can connect to their own Ollama or LM Studio server. Data never leaves their home network."*

### 9. Closing (30 seconds)
- Return to Home screen showing healthy FHS
- **Say:** *"SmartSpend addresses all three objectives: we assessed financial practices through our 30-respondent survey, designed and built this system with Gemini 3.5 Flash-Lite and 7 fallback LLMs, and evaluated usability with 30 SUS respondents. The system scored 61.83, which is below our 80 target and the 68 benchmark, indicating that Objective 3 was partially achieved. The main usability concerns identified were system consistency and complexity, which are addressed in our Recommendation 8 for UI/UX refinement."*

---

## 🚨 Emergency Responses

| **Problem** | **What to Say/Do** |
|-------------|-------------------|
| **No internet / AI fails** | *"The AI requires internet, but let me show the offline features."* Demo manual entry, analytics, FHS, goals — all work offline. |
| **App crashes** | Restart app, tap "Try Demo" again. Have backup screenshots in gallery. |
| **AI daily limit hit** | AI screen → ⋮ → Reset Daily Limit |
| **Panel asks about numbers** | Refer to manuscript sections. Never improvise statistics. |
| **"Why not use [other app]?"** | *"Table 2 in our manuscript compares SmartSpend to 7 existing apps. Our unique combination is offline-first + LLM chat + FHS + Filipino-English AI + batch import in one integrated system."* |
| **"What about bank sync?"** | *"Bank API integration is Recommendation 1 for future work. Current version focuses on manual logging, receipt scanning, and screenshot import."* |

---

## ✅ Key Numbers to Remember

### Survey Results
- **30 respondents** needs assessment: 16 parents + 14 young professionals
- **30 respondents** SUS evaluation: 10 parents + 20 young professionals (separate group)
- **96.7%** (29/30) expressed intent to use AI finance app
- **93.3%** (28/30) already used GCash
- **Only 10%** (3/30) used dedicated expense tracking app

### System Stats (v3.1.0)
- **34 autonomous AI actions**
- **8-model cloud failover** (Gemini 3.5 Flash-Lite + 7 fallbacks)
- **40+ platforms** for screenshot import
- **33 achievement badges**
- **12 selectable themes**
- **5 FHS dimensions** (weighted scoring)
- **26-table SQLite schema**
- **SUS Score: 61.83/100** (Grade D, "OK" - below 68 benchmark and 80 target)

### LLM Selection
- **10 candidate models** from 4 providers evaluated
- **Gemini 3.5 Flash-Lite selected** for speed + free tier quota
- **7 fallback providers** (Groq/LLaMA, OpenRouter, Cerebras, Mistral, etc.)

---

## 📚 SAY vs DON'T SAY

| ✅ **SAY** | ❌ **DON'T SAY** |
|-----------|-----------------|
| "quantitative descriptive developmental" | "mixed methods" |
| "random sampling for respondents" | "stratified sampling" |
| "16 parents and 14 young professionals" | "13 parents" (old count) |
| "SUS scored 61.83/100, Grade D, adjective rating OK" | "passed" / "excellent" / "acceptable" |
| "Objective 3 was partially achieved" | "Objective 3 was fully achieved" |
| "below 68 benchmark and 80 target" | "acceptable for prototype" |
| "offline-first; core features work offline" | "fully offline" |
| "8-model cloud failover chain" | "8 providers" |
| "Gemini 3.5 Flash-Lite had high free-tier quota" | "highest quota" (Groq is higher) |
| "Prototype Observed Financial Health Indicator" | "validated instrument" |
| "Recommendation 8: UI/UX refinement" | "UI/UX is Recommendation 1" |
| "version 3.1.0" | "version 3.2.1" (manuscript evaluated 3.1.0) |

---

## 🎤 Opening Statement

*"Good afternoon, Dean Layco, Sir Raposas, Ma'am Mzana, and Dr. Mangaoang. We are Brix A. Directo, Cyrille John M. Rubis, and Djaunathan Albert S. Madayag from the College of Computer Studies and Engineering at LORMA Colleges. Our study is entitled **SmartSpend: An AI-Assisted Mobile Financial Tracking and Advisory Application for Personal Financial Management**, under the guidance of our adviser, Dr. Ellen F. Mangaoang, DIT. We are grateful for this opportunity and hope you find our work worthy of your consideration."*

---

## 📄 Documents to Bring

1. **Printed Manuscript** (3 copies) — `1_MAIN_MANUSCRIPT_FINAL.docx`
2. **Compliance Matrix** (1 copy for signatures) — `SmartSpend_ComplianceMatrix_Final.docx`
3. **Defense fee receipt**
4. **Backup: USB with digital copies** of manuscript + compliance matrix
5. **This quick reference sheet** (print this!)

---

## 🧘 Final Reminders

- **Sleep well tonight** — you're prepared
- **Breakfast tomorrow** — don't go on empty stomach
- **Arrive 30 minutes early** — setup time
- **Breathe** — you built an amazing system
- **Trust your work** — you addressed every panel recommendation from Capstone 1

---

**You've got this! All 12 panel recommendations are DONE. ✅**
**SmartSpend v3.2.1 is ready. Your team is ready. Good luck tomorrow! 🚀**
