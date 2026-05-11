# Smart Spend

**AI-Assisted Financial Tracking & Advisory**
Version 2.6.0 | Lucid Frame | Academic Year 2025–2026

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
- 🤖 AI Chat Assistant (Groq LLaMA 3.1) — 15 action types via natural language
- 📊 Analytics: pie chart, bar chart, 50/30/20 tracker, health score trend, category comparison
- 💰 Budget management with pace indicators and % of income mode
- 🎯 Savings goals with contribution tracking and emergency fund auto-calc
- 💳 Debt & lending tracker with payment plans (ShopeePayLater, GCash GLoan, etc.)
- 🔁 Recurring transactions with due date alerts and Log All Due
- 💵 Wallet Balances — Cash, GCash, Maya, BDO, BPI, 30+ PH banks (fully cloud-synced)
- 🔀 Auto-Categorization Rules — keyword → category mappings (fully cloud-synced)
- 💱 Multi-currency (57 currencies, live rates)
- 🧠 Financial Health Score (0–100, 4-component formula)
- ☁️ Full Firestore sync — expenses, budgets, goals, income, recurring, debts, wallets, rules
- 🔒 App Lock (PIN + biometric, per-account)
- 🏆 16 Achievements & Badges
- 😊 Daily Mood Check-In with spending correlation
- 🗓️ Unified Financial Calendar
- 🏪 Import from Bank / GCash (AI-powered bulk import)
- 🌙 5 color themes + dark mode

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
# Recommended release build (arm64, shrunk, obfuscated)
flutter build apk --release --target-platform android-arm64 --split-per-abi --shrink --obfuscate --split-debug-info=build/debug-info
```

**Release APK location:**
```
build/app/outputs/flutter-apk/app-arm64-v8a-release.apk  (~44 MB)
```

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
