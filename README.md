# Smart Spend

**AI-Assisted Financial Tracking & Advisory**
Version 2.9.1 | Lucid Frame | Academic Year 2025–2026

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
- 📷 **Unified Smart Import** — one camera button opens: Live Camera (barcode/QR/receipt), Single Photo (auto-detects barcode/screenshot/receipt), Batch Screenshots (40+ platforms), Paste Text
- 🤖 AI Chat Assistant — **29 agentic action types** via natural language (Gemini 3.1 Flash-Lite primary, multi-model auto-fallback with financial_advice routing tier)
- ⚖️ **Lightweight Mode** — disable income/wallet tracking; FHS recalculates using spending habits (Spending Restraint, Consistency, Category Balance, Habit Streak)
- 🎯 **Multi-Period Spending Limits** — set daily/weekly/monthly/yearly caps independently; progress bars + alerts
- 📅 **Logging Gap Detection** — startup check for unlogged days; confirm spending (penalty) or clean days (bonus) for accurate FHS
- 🧠 **Financial Health Score** — 4-component formula that adapts to tracking mode; gap-aware adjustments; AI explains your breakdown
- 💸 **Split Expenses** — "Split dinner with John" auto-logs your share + creates debt for theirs
- 📊 Analytics: pie chart, bar chart, 50/30/20 tracker, health score trend, category comparison, DTI ratio, emergency fund calculator
- 💰 Budget management with pace indicators and % of income mode
- 🎯 Savings goals with contribution tracking and emergency fund auto-calc
- 💳 Debt & lending tracker with payment plans (ShopeePayLater, GCash GLoan, etc.)
- 🔁 Recurring transactions with due date alerts and Log All Due
- 💵 **Wallet Balances** — Cash, GCash, Maya, BDO, BPI, 30+ PH banks (auto-deduct, transfers)
- 🛡️ **Insurance & Contributions Tracker** — SSS, PhilHealth, Pag-IBIG, private insurance
- 🔔 **Smart Startup Alerts** — overdue bills, exceeded budgets, debt due, FHS drops, idle money, income sanity, balance discrepancy
- ⚙️ **App Settings** — track income/wallets toggle, mood, impulse pause, budget alerts, balance mode, compact mode
- 🔀 Auto-Categorization Rules — keyword → category mappings (fully cloud-synced)
- 💱 Multi-currency (57 currencies, live rates)
- 🏦 **PH Banks Database** — 20 banks, 5 e-wallets, government contributions, investment options
- ☁️ Full Firestore sync — expenses, budgets, goals, income, recurring, debts, wallets, rules, insurance
- 🔒 App Lock (PIN + biometric, per-account)
- 🏆 **23 Achievements & Badges** + 10 rotating Daily Quests with streak tracking
- 😊 Daily Mood Check-In with spending correlation
- 🗓️ Unified Financial Calendar
- 💹 **Peso Cost Averaging Calculator** — MP2, UITFs, stocks with year-by-year projections
- 🏅 **Financial Health Certificate** — shareable monthly score card
- 📖 **Financial Glossary** — 23 key terms in plain Filipino-English
- 💰 **BIR Tax Breakdown** — full monthly deductions (BIR, SSS, PhilHealth, Pag-IBIG, take-home)
- 🔐 **API Security** — Firebase Remote Config + App Check (key never in APK binary)
- 🌙 5 color themes + dark mode + high contrast + compact mode

---

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Framework | Flutter (Dart) |
| AI Engine | Multi-Model LLM: Gemini 3.1 Flash-Lite (primary), Gemini 3.5 Flash, Groq LLaMA 3.3 70B, Groq LLaMA 3.1 8B, Cerebras LLaMA 3.1 (auto-fallback on rate limit) |
| Local DB | SQLite (sqflite v11) |
| Cloud | Firebase Auth + Firestore |
| OCR | Google ML Kit Text Recognition |
| Barcode | Google ML Kit Barcode Scanning + MobileScanner |
| Charts | fl_chart |
| Backup | System share sheet (JSON, v9 format) |
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
