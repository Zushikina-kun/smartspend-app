# SmartSpend — Master Roadmap & To-Do List
**Version:** 2.8.0  
**Date:** June 13, 2026  
**Status:** Capstone 2 Active Development (Defense Prep Phase)

---

## 📋 PRIORITY FRAMEWORK

| Priority | Scope | Blocking? | Lead |
|----------|-------|-----------|------|
| 🔴 **CRITICAL** | Defense readiness, code fixes | Yes | Brix (Dev) |
| 🟡 **HIGH** | Research/testing for defense, academic papers | Yes | Team |
| 🟢 **MEDIUM** | Post-capstone features, nice-to-haves | No | Future |
| 🔵 **LOW** | Vision features, far future | No | Future |

---

## 🔴 TIER 1 — CODE QUALITY & DEFENSE PREP (This Sprint)

### 1.1 Code Fixes (5 min)
- [ ] **insurance_screen.dart** (line 476) — change `value:` → `initialValue:` in DropdownButtonFormField
- [ ] **insurance_screen.dart** (line 489) — change `value:` → `initialValue:` in DropdownButtonFormField (2nd occurrence)
- [ ] **setup_screen.dart** (line 34) — remove unused `_accountTypes` field (or use it if intentional)
- [ ] **app_config.dart** (line 53) — remove unused `_geminiLimitReached` field (or use in multi-model limiting logic)
- [ ] Run `flutter analyze` after fixes — should show 0 issues

### 1.2 Defense Testing (Physical Device — Poco X6 Pro)
**What:** 7 critical tests before panel defense  
**When:** Week before defense (June 15–17)  
**Lead:** Djaunathan (QA Lead)

- [ ] **FHS Formula Verification** — Load app → open any account → check FHS calculation matches academic paper formula
- [ ] **Groq API Failover** — Turn WiFi off → send AI message → verify friendly error + "Retry" button appears
- [ ] **Offline Mode** — WiFi off → manually add expense → WiFi on → verify expense syncs to Firestore
- [ ] **Weekly Notification** — Wait until Sunday → verify notification fires on open
- [ ] **AI Chat End-to-End** — Type "I spent 30 pesos for jeepney" → verify logs as single expense with transport category
- [ ] **Recurring Candidates** — Check if subscription auto-detection buttons (Dismiss/Add) respond
- [ ] **Multi-Model Fallback** — Simulate rate limit → verify fallback to next model works gracefully

---

## 🟡 TIER 2 — ACADEMIC DELIVERABLES (Team's Responsibility)

### 2.1 Research & User Testing (Due before defense week)

| Task | Owner | Status | Deadline |
|------|-------|--------|----------|
| Pre-survey (Objective 1) | Team | ⏳ Not started | June 15 |
| SUS testing (30 respondents) | Team | ⏳ Not started | June 15 |
| Qualitative interviews (5–10 users) | Team | ⏳ Not started | June 17 |

### 2.2 Academic Papers (Chapter 2, 3, 4)

| Chapter | Topic | Status | Needs | Owner |
|---------|-------|--------|-------|-------|
| Chapter 2 | Related Literature | ⏳ In progress | Competitor analysis doc | Cyrille (Doc Lead) |
| Chapter 3 | Methodology | ⏳ In progress | LLM comparison table | Cyrille |
| Chapter 4 | Results & Impact | ⏳ In progress | User testing data | Djaunathan (QA) |

**References available:**
- `docs/Competitor_Analysis_and_Feature_Ideas.md` — 9 apps compared
- `docs/LLM_Comparison_Table_Ch3.md` — 10 LLM models benchmarked

### 2.3 Play Store Readiness

- [ ] **Privacy Policy** — Required for Play Store (not needed for academic defense)
- [ ] **Terms of Service** — Optional but recommended
- [ ] **FAQ/Help Center** — Can be in-app or web-based

---

## 🟢 TIER 3 — POST-CAPSTONE CODE WORK (Future)

### 3.1 Code Deferred Features (9 items)

#### Will break existing users — risky before defense:
- [ ] **Full wallet-first migration** — Remove income/roles system, recompute FHS as `savings / total_received`
  - **Impact:** High-risk schema change, existing accounts affected
  - **Estimate:** 2–3 sessions
  - **Do this:** August 2026 (post-defense)

- [ ] **Business Mode** — Revenue tracking, P&L statements, invoicing, VAT
  - **Why deferred:** Different UX from personal finance mode
  - **Estimate:** 4–5 sessions
  - **Do this:** Q3 2026

#### Medium complexity, medium value:
- [ ] **Market Insights** — PSEi daily, fuel prices, CPI inflation tracking
  - **Requires:** API integrations (PSE, DOE, PSA)
  - **Estimate:** 2–3 sessions

- [ ] **Insurance coverage gap analysis** — Phase 2 after base tracker is live
  - **Estimate:** 1–2 sessions

- [ ] **Compact vs Comfortable UI mode** — Toggle layout density in settings
  - **Estimate:** 1 session

#### Lower priority:
- [ ] **Mascot character** — Design + animation (UI/UX lead task)
- [ ] **Multi-language UI** — Filipino/Bisaya translations
  - **Estimate:** 2–3 sessions (if budget allows)

- [ ] **Couple/Family sharing mode** — Multi-user architecture
  - **Complexity:** Very high (Firestore security rules, shared wallets)
  - **Estimate:** 5–6 sessions

- [ ] **Brankas API / BSP Open Banking** — Bank account auto-import
  - **Requires:** BSP sandbox access, API integration
  - **Estimate:** 3–4 sessions (if APIs available)

---

## 📊 COMPREHENSIVE STATUS MATRIX

### What's DONE ✅ (28 major features)

#### Core Features (v1.0)
- [x] Expense logging (voice, OCR, barcode, manual)
- [x] AI chat with 28 agentic actions
- [x] Analytics dashboard (7 charts + insights)
- [x] Budgets with pace tracking
- [x] Savings goals with auto-contribution
- [x] Debt tracker with payment plans
- [x] Recurring transactions
- [x] FHS calculation (4-component, 25pts each)
- [x] Daily mood tracking
- [x] Spending streaks & badges (23 total)
- [x] Daily quests (10 rotating)

#### Capstone 2 Additions (v2.8.0)
- [x] Multi-model LLM (Gemini → Groq → Cerebras)
- [x] Wallet system with 30+ PH banks
- [x] Insurance & contributions tracker
- [x] Startup alerts (7 conditions)
- [x] Smart barcode + receipt OCR with item extraction
- [x] Bank import (AI-powered)
- [x] Price memory (item-level price tracking)
- [x] Round-up savings (spare change to ₱10)
- [x] Smart daily allowance
- [x] PH banks comparison (4 tabs)
- [x] Peso Cost Averaging calculator
- [x] Financial Health Certificate (shareable)
- [x] Financial Glossary (23 terms)
- [x] BIR tax breakdown
- [x] High contrast + text size accessibility
- [x] Date/time editing on all records
- [x] AI can change dates via chat
- [x] Accessibility: Normal/Large/Extra Large text

### What's NOT DONE ❌ (9 features — explicitly deferred)

#### Risky/Breaking Changes
- [ ] Full wallet-first migration (removes income roles)
- [ ] Full account type removal (risky — existing users)

#### Requires External APIs
- [ ] Market Insights (PSEi, fuel, CPI — need APIs)
- [ ] Brankas / BSP Open Banking (needs BSP sandbox)

#### Design/UX Work
- [ ] Mascot character
- [ ] Compact vs Comfortable mode
- [ ] Multi-language UI (Filipino/Bisaya)

#### Architecture Changes
- [ ] Business Mode (revenue, P&L, invoicing)
- [ ] Family/Couple sharing mode (multi-user Firestore)
- [ ] Insurance coverage gap analysis (Phase 2)

---

## 🗓️ SUGGESTED TIMELINE

### **WEEK 1 (June 13–17) — DEFENSE PREP**
1. **Mon–Tue (Brix):** Fix 4 code issues (5 min total), run analyzer ✅
2. **Wed–Thu (Team):** Complete physical device testing (7 tests)
3. **Thu–Fri (Team):** Pre-survey administration + SUS testing begins
4. **By Fri (Cyrille):** Chapter 2 & 3 drafts ready for defense

### **WEEK 2 (June 18–22) — DEFENSE**
- Panel presentation
- Live demo on Poco X6 Pro
- Q&A on methodology, AI architecture, financial formulas
- **Post-defense:** Continue qualitative interviews + finalize Chapter 4

### **WEEK 3+ (June 23+) — POST-CAPSTONE**
- Finalize SUS/interview data (by June 30)
- Complete all 3 chapters
- *Optional:* Begin wallet-first migration if budget allows

---

## 🎯 IMMEDIATE ACTION ITEMS (Next 24 hours)

### For Brix (Dev):
1. **Fix 4 code issues** (5 min)
   ```bash
   # After fixing, run:
   flutter analyze
   ```
   Should show 0 issues.

2. **Verify build works** (do NOT build full APK yet)
   ```bash
   flutter pub get
   flutter run
   ```
   (Just check no errors on emulator/device)

### For Djaunathan (QA):
1. **Schedule device testing** — pick date June 15–17
2. **Prepare test plan** with 7 critical tests documented
3. **Document results** in test log for defense

### For Cyrille (Docs/UX):
1. **Confirm Chapter 2 & 3 outlines** match provided docs
2. **Update any docs** with final feature screenshots
3. **Prepare demo script** with top 5 features to showcase

---

## 📌 DEFERRED ITEMS (Post-Defense)

### Summer 2026 (August–September)
- Wallet-first migration (if time allows)
- Business Mode development (Q3)
- Market Insights MVP (if APIs available)

### Fall 2026+ (Uncertain Timeline)
- Family sharing mode
- Multi-language UI
- Brankas/BSP integration

---

## ⚠️ KNOWN CONSTRAINTS

| Constraint | Impact | Mitigation |
|-----------|--------|-----------|
| No backend server | API keys in APK | Firebase Remote Config + 60 msg/day cap |
| SQLite not encrypted | Data security | App lock PIN + Firestore Auth |
| Groq free tier rate limits | 429 errors | Multi-model fallback (Gemini, Cerebras) |
| Single-device sync | No multi-device | Last-write-wins acceptable for solo user |
| Profile photos local-only | No cross-device photos | Firebase Storage costs $$$ — deferred |

---

## 🚀 SUCCESS METRICS (For Defense)

### Technical Metrics
- ✅ All 28 AI actions working
- ✅ 7 physical device tests pass
- ✅ FHS formula verified against paper
- ✅ Zero analyzer warnings
- ✅ Multi-model LLM auto-fallback tested

### Academic Metrics
- ✅ 30 SUS respondents
- ✅ 5–10 qualitative interviews
- ✅ Chapters 2, 3, 4 complete
- ✅ Feature list vs competitors validated
- ✅ LLM model selection justified

### UX Metrics
- ✅ Demo script covers 5 key features
- ✅ Accessibility: tested text sizes + high contrast
- ✅ Gamification: badges/quests working
- ✅ Wallet system prominent on home

---

## 📞 CONTACT POINTS

| Role | Name | Responsibility | Contact |
|------|------|-----------------|---------|
| Lead Developer | Brix A. Directo | Code fixes, builds, technical decisions | Brix |
| UI/UX Lead | Cyrille John M. Rubis | Docs, papers, design, demo script | Cyrille |
| QA/PM Lead | Djaunathan Albert S. Madayag | Testing, research, defense prep | Djaunathan |

---

*SmartSpend v2.8.0 — Ready for Capstone 2 Defense*  
*Lucid Frame | Lorma Colleges BSIT | June 2026*
