# Security Policy

## Smart Spend — Lucid Frame

---

## Files NOT included in this repository

The following files contain sensitive credentials and are intentionally excluded from version control via `.gitignore`. You must provide your own copies to run or build the app.

| File | Contains | How to get it |
|------|----------|---------------|
| `android/app/google-services.json` | Firebase API key, OAuth client IDs, project number | Firebase Console → Project Settings → Android app → Download |
| `lib/services/app_config.dart` | Groq API key (AI chat), optional Gemini/Cerebras keys | Copy from `lib/services/app_config.dart.example`, fill in your keys |
| `android/key.properties` | Release keystore password and alias | Created locally — see HOWTORUN.md §6 |
| `android/app/*.jks` | Release signing keystore | Created locally — never share this file |

---

## Firebase Security

The `google-services.json` file was previously committed to this repository. **It has since been removed from tracking.** If you find a copy in the git history, the API key inside it should be treated as potentially exposed.

**Recommended action:** The API key in the old commits is already restricted by SHA-1 certificate fingerprint — it only works with APKs signed by your registered keystores. Someone with just the key and no matching signed APK cannot use it. However, if you want extra peace of mind, you can rotate it in Google Cloud Console → APIs & Services → Credentials.

Your actual user data is protected by **Firestore Security Rules** — the API key alone cannot read or write user data without passing those rules. However, rotating it is still good practice.

---

## AI API Keys

The Groq API key used for AI chat is:
- **Never stored in the APK binary** — it is fetched from Firebase Remote Config at runtime
- **Never committed to git** — `lib/services/app_config.dart` is gitignored
- **Rate-limited in-app** — 60 messages/day per user, enforced client-side

For production deployment, consider moving the key to a server-side proxy instead of Remote Config.

---

## App Check

Firebase App Check is currently configured in **debug/monitoring mode** (`AndroidProvider.debug`). This means violations are logged but not blocked.

Before publishing to the Google Play Store:
1. Switch to `AndroidProvider.playIntegrity` in `lib/main.dart`
2. Register the release SHA-256 fingerprint in Firebase Console
3. Enable enforcement in the Firebase Console

---

## Reporting Security Issues

This is an academic capstone project (Lorma Colleges, BSIT 2026–2027, 1st Semester).
If you find a security issue, please open a GitHub issue or contact the development team directly.

**Team:** Lucid Frame — Brix A. Directo, Cyrille John M. Rubis, Djaunathan Albert S. Madayag
