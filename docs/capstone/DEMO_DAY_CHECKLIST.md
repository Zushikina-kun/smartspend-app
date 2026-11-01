# SmartSpend — Defense Demo Day Checklist
**Defense Date:** November 9, 2026
**Manuscript Deadline:** November 6, 2026 (3 printed copies)
**Demo device:** Your Android phone (NOT the same phone running your SIM — bring a backup hotspot)

---

## 🔴 NIGHT BEFORE (Nov 8 evening)

### App setup on demo phone
- [ ] Download `SmartSpend-v3.1.1-arm64-v8a.apk` from https://github.com/Zushikina-kun/smartspend-app/releases/tag/v3.1.1
- [ ] Uninstall any old version first, then install fresh
- [ ] Open app → tap **"Try Demo"** on login screen (loads full realistic dataset)
- [ ] Verify Home shows: FHS score ~85–90, Safe-to-Spend card visible, wallets showing
- [ ] Settings → AI MODEL → set to **Auto (Recommended)**
- [ ] Settings → Quick Presets → **Normal** (NOT Lite mode)
- [ ] AI screen → ⋮ menu → **Reset Daily Limit** (gives full 150 messages)
- [ ] Run the demo script once end-to-end — make sure AI responds
- [ ] Charge phone to **100%**, enable Do Not Disturb
- [ ] Do NOT reopen the app after charging — cold start at the defense

### What to bring
- [ ] Demo phone (100% charged, DND on)
- [ ] USB cable + charger (backup power)
- [ ] WiFi hotspot on a second device (backup internet if venue WiFi fails)
- [ ] 3 printed manuscript copies (no `[[` tags remaining)
- [ ] Printed approval/signature pages (with adviser + panel signatures)
- [ ] Defense fee receipt
- [ ] Pen for signing attendance sheets

---

## 🟢 DEMO SCRIPT (~10 minutes)

### Opening (30 sec)
- Cold start from home screen — let panel see Peso greeting on login
- Tap "Try Demo" → Home loads
- *"This is SmartSpend — an AI-powered personal finance app built for Filipino users. Let me show you the key features."*

### 1. AI Taglish logging (2 min)
- Go to AI (Peso) tab
- Type: `"nag-gastos ako ng 65 sa canteen for lunch at 13 para sa jeep"`
- Show Peso's confirmation in Taglish
- Show the session summary card (✅ 2 recorded)
- *"Peso understands Filipino and English. No forms, no dropdowns — just say what you spent."*

### 2. FHS Score breakdown (1.5 min)
- Go to Home → tap the FHS score card
- Show 4 components: Savings Rate, Overspend Control, Budget Adherence, Logging Consistency
- *"This is our Financial Health Score — 0 to 100, calculated from actual transactions. Each component is worth 25 points."*

### 3. Batch screenshot import (2 min)
- AI tab → camera icon → Batch Screenshots
- Select 2–3 pre-saved Shopee/GCash screenshots
- Show AI parsing → review screen → confirm
- *"Import from GCash, Shopee, Steam, Maya — 40+ platforms. Peso reads them and logs everything at once."*

### 4. Analytics (1 min)
- Analytics tab → Quick Jump: Overview
- Show pie chart, 50/30/20 tracker
- *"Real-time analytics showing spending patterns, savings rate, and financial health history."*

### 5. Local AI mode (30 sec)
- Settings → AI → show Local AI option
- *"Optional privacy mode — connect to Ollama or LM Studio on your own PC. Your data never leaves your home network."*

### 6. Closing (30 sec)
- Show Achievements screen (36 badges)
- *"SmartSpend addresses all three objectives: we assessed financial practices through our survey, designed and built the system you just saw, and we're evaluating it through the System Usability Scale currently in data collection."*

---

## 🔧 IF THINGS GO WRONG

| Problem | What to say / do |
|---------|-----------------|
| No internet / AI fails | *"The AI requires internet, but I can show the offline features — expense logging, analytics, FHS, goals all work without internet."* Switch to manual entry demo. |
| App crashes | Restart, tap Try Demo again. Have backup screenshots ready on phone gallery. |
| Daily AI limit hit | AI screen → ⋮ → Reset Daily Limit |
| Panel asks about SUS results | *"Survey data collection is ongoing. We expect to complete the required 30 responses before final manuscript submission. All SUS analysis follows standard Brooke (1996) scoring."* |
| Panel asks about AI transaction bug | *"We identified and fixed a parser format mismatch in v3.1.1 — the model was outputting bullet-format actions but the parser expected legacy format. Both are now accepted and all transactions save correctly."* |
| WiFi drops | Switch to mobile hotspot on second phone |
| Panel asks why FHS is 17 in real data | *"That's my personal account. The demo device runs demo data — the FHS reflects our demo user's realistic spending profile."* (Make sure demo data is loaded!) |

---

## 📝 RE-LOG MISSING TRANSACTIONS (do in your REAL account before Nov 9)

These were "logged" Oct 13–26 but never saved due to the parser bug:

| Date | Item | Amount | Category |
|------|------|--------|----------|
| Oct 17 | Red Horse litro | ₱142 | Entertainment |
| Oct 19 | Philnits exam fee | ₱1,500 | Education |
| Oct 25 | Tricycle fare | ₱60 | Transportation |
| Oct 25 | Food and drinks | ₱325 | Food |
| Oct 25 | Jeepney fare | ₱47 | Transportation |
| Oct 26 | Omni 4-gang socket adapter | ₱485 | Shopping |

**Total: ₱2,559** — re-enter via Add Expense or tell Peso in chat.

---

## 📋 BEFORE NOV 6 (manuscript deadline)

- [ ] All 97 `[[PENDING]]` tags filled from real survey data OR deleted
- [ ] Figures 3.1–3.11 replaced with real screenshots/diagrams
- [ ] Table of Contents + List of Tables/Figures updated manually
- [ ] Approval Sheet: get chairperson name + signatures
- [ ] Verify Dean's name (call CCSE office)
- [ ] Defense fee paid (confirm amount with Sir Raposas)
- [ ] `Ctrl+F [[` in Word — must find NOTHING before printing

---

*Keep this file on your phone. Screenshot the demo script section.*
