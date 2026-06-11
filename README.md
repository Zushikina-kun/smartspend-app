# Smart Spend

**AI-Assisted Financial Tracking & Advisory**
Version 2.7.0 | Lucid Frame | Academic Year 2025–2026

---

## About

Smart Spend is an AI-powered personal finance tracker for Android, built for everyday Filipino users. It helps you record, analyze, and manage your spending with minimal effort — using voice, camera, or just typing naturally.

**Developed by Lucid Frame:**
- Brix A. Directo — Lead Developer
- Cyrille John M. Rubis — UI/UX Designer & Documentation Lead
- Djaunathan Albert S. Madayag — Project Manager & QA Lead

---

## Features

- 🎙️ Voice, OCR, Barcode, and Manual expense input
- 🤖 AI Chat Assistant (Groq LLaMA 3.1) — **25 agentic action types (30 planned)** via natural language
- 📊 Analytics: pie chart, bar chart, 50/30/20 tracker, health score trend, category comparison, **DTI ratio**, **emergency fund calculator**
- 💰 Budget management with pace indicators and % of income mode
- 🎯 Savings goals with contribution tracking and emergency fund auto-calc
- 💳 Debt & lending tracker with payment plans (ShopeePayLater, GCash GLoan, etc.)
- 🔁 Recurring transactions with due date alerts and Log All Due
- 💵 **Wallet Balances** — Cash, GCash, Maya, BDO, BPI, 30+ PH banks (auto-deduct on expense, transfers between wallets)
- 🛡️ **Insurance & Contributions Tracker** — SSS, PhilHealth, Pag-IBIG, private insurance with due dates and overdue alerts
- 🔔 **Smart Startup Alerts** — on-open notifications for overdue bills, budget exceeded, debts due, FHS drops, idle money
- ⚙️ App Settings — toggle wallet auto-deduct, mood, impulse pause, budget alerts, balance mode
- 🔀 Auto-Categorization Rules — keyword → category mappings (fully cloud-synced)
- 💱 Multi-currency (57 currencies, live rates)
- 🧠 Financial Health Score (0–100, 4-component formula) — AI can explain breakdown
- 🏦 **PH Banks Database** — 20 banks, 5 e-wallets, government contributions, investment options with rates
- ☁️ Full Firestore sync — expenses, budgets, goals, income, recurring, debts, wallets, rules, insurance
- 🔒 App Lock (PIN + biometric, per-account)
- 🏆 **23 Achievements & Badges** + 10 rotating Daily Quests with streak tracking
- 😊 Daily Mood Check-In with spending correlation
- 🗓️ Unified Financial Calendar
- 🏪 Import from Bank / GCash (AI-powered bulk import)
- 🧾 Smart Receipt Import (OCR → AI item extraction → review table)
- 📅 **Date/Time Editing** — edit expense dates, AI can change dates via chat
- 🔤 **Text Size Accessibility** — Normal, Large, Extra Large for easier reading
- 🔲 **High Contrast Mode** — black/white for maximum readability
- 💰 **Round-Up Savings** — auto-save spare change to savings goals (rounds to ₱10)
- 📈 **Price Memory** — alerts when items cost more than last time (+15% threshold)
- 💡 **Smart Daily Allowance** — dynamic "how much can I spend today" based on remaining budget
- 🏦 **PH Banks & Investments** — compare 20 banks, digital banks, e-wallets, investment options
- 💹 **Peso Cost Averaging Calculator** — plan regular investments with year-by-year projections (MP2, UITFs, stocks)
- 🏅 **Financial Health Certificate** — shareable monthly score card (share via WhatsApp, social)
- 🔐 **API Security** — Firebase Remote Config + App Check (key never in APK binary)
- 📷 Google profile photo fallback (works across devices)
- 🌙 5 color themes + dark mode + high contrast
- 🤖 **AI**: **25 agentic action types** (30 planned), multi-model LLM switching planned (Groq → Gemini → Cerebras)
- 💹 **Peso Cost Averaging Calculator** — plan regular investments with year-by-year projections
- 🏅 **Financial Health Certificate** — shareable monthly score card
- 🔀 Multi-model LLM switching planned (currently Groq LLaMA 3.1 8B)

---

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Framework | Flutter (Dart) |
| AI Engine | Groq API — LLaMA 3.1 8B Instant |
| Local DB | SQLite (sqflite v11) |
| Cloud | Firebase Auth + Firestore |
| OCR | Google ML Kit Text Recognition |
| Charts | fl_chart |
| Backup | System share sheet (JSON, v8 format) |
| App Lock | local_auth (PIN + biometric) |
| Exchange Rates | open.er-api.com |
| Crash Reporting | Firebase Crashlytics |
| App Check | Firebase App Check (Play Integrity, monitoring mode) |

**Architecture:** Serverless/client-side only. No backend server. All logic runs on-device + Firebase + third-party APIs (Groq, open.er-api.com). Zero hosting costs.

---

## How to Run

See **[HOWTORUN.md](HOWTORUN.md)** for full setup and run instructions.

Quick start:
```bash
flutter pub get
flutter run
```

---

## Build

```bash
# Full release build — produces all 3 APKs (arm64, armeabi-v7a, x86_64)
flutter build apk --release --split-per-abi --shrink --obfuscate --split-debug-info=build/debug-info
```

**Release APKs:**
```
build/app/outputs/flutter-apk/
├── app-armeabi-v7a-release.apk  (~36 MB)  ← older/32-bit phones (Android 5+)
├── app-arm64-v8a-release.apk    (~44 MB)  ← modern 64-bit phones ← primary
└── app-x86_64-release.apk       (~47 MB)  ← emulators
```

Distribute both `arm64-v8a` and `armeabi-v7a` to cover all Android phones.

---

## Configuration

| File | Purpose |
|------|---------|
| `android/app/google-services.json` | Firebase config (not in repo) |
| `lib/services/app_config.dart` | Groq API key — centralized, in `.gitignore` |

> ⚠️ `app_config.dart` is excluded from git. Copy `app_config.dart.example` and fill in your key before building.

---

## Documentation

| File | Contents |
|------|---------|
| `DOCUMENTATION.md` | Full technical documentation |
| `HOWTORUN.md` | Setup, run, and build instructions |
| `KIRO_CONTEXT.md` | AI assistant context — architecture, conventions, current state |
| `FINAL_STATUS.md` | Complete fix history across all sessions |
| `SmartSpend_PendingIssues.md` | Known issues and their status |
| `SmartSpend_Master_TODO.md` | Feature backlog |
| `SmartSpend_QA_Brief.txt` | QA tester guide |

---

*Smart Spend — Spend Smart, Live Better.*
*© 2026 Lucid Frame. All rights reserved.*
