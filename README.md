# Smart Spend

**AI-Assisted Financial Tracking & Advisory**  
Version 2.4.0 | Lucid Frame | Academic Year 2025–2026

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
- 🤖 AI Chat Assistant (Groq LLaMA 3.1) with full CRUD via natural language
- 📊 Analytics with pie chart, bar chart, health score trend, and category comparison
- 💰 Budget management with time-aware pace indicators
- 🎯 Savings goals with contribution tracking
- 💳 Debt & lending tracker
- 🔁 Recurring transactions with due date alerts
- 💱 Multi-currency (34+ currencies, live rates)
- 🧠 Income-relative Financial Health Score (0–100)
- ☁️ Firestore sync + Google Drive backup
- 🔒 App Lock (PIN + biometric)
- 🌙 5 color themes + dark mode

---

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Framework | Flutter (Dart) |
| AI Engine | Groq API — LLaMA 3.1 8B Instant |
| Local DB | SQLite (sqflite v10) |
| Cloud | Firebase Auth + Firestore |
| OCR | Google ML Kit |
| Charts | fl_chart |
| Backup | Google Drive REST API |

---

## Build

```bash
# Install dependencies
flutter pub get

# Debug run
flutter run

# Release APK (recommended: arm64-v8a for modern phones)
flutter build apk --release --split-per-abi
```

**Release APK location:**
```
build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

---

## Configuration

| File | Purpose |
|------|---------|
| `android/app/google-services.json` | Firebase config |
| `lib/services/llm_service.dart` | Groq API key |
| `lib/services/ai_chat_service.dart` | Groq API key |

---

## Documentation

See `DOCUMENTATION.md` for full technical documentation.  
See `SmartSpend_QA_Brief.txt` for QA tester guide.  
See `FINAL_STATUS.md` for complete fix history.

---

*Smart Spend — Spend Smart, Live Better.*  
*© 2026 Lucid Frame. All rights reserved.*
