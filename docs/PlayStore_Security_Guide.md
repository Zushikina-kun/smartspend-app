# SmartSpend — Play Store Deployment & Security Guide
**Version:** 2.7.0 | **Date:** May 2026

---

## Security Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    SmartSpend App (APK)                      │
│  • No API key in binary (fetched from Remote Config)        │
│  • Code obfuscated (--obfuscate --split-debug-info)         │
│  • App Check token sent with every Firebase request         │
│  • Per-user rate limit: 60 AI messages/day                  │
└──────────────────────────┬──────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────┐
│              Firebase (Free Spark Plan)                      │
│  • App Check: Play Integrity verification                   │
│  • Remote Config: API key stored server-side                │
│  • Firestore: user data (UID-scoped security rules)         │
│  • Auth: email/password + Google Sign-In                    │
│  • Crashlytics: crash reporting                             │
└──────────────────────────┬──────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────┐
│                    Groq API                                  │
│  • Called directly from app (with Remote Config key)        │
│  • Rate limited: 30 req/min at API level                    │
│  • App-level limit: 60/user/day                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Current Security Measures (Already Implemented)

| Layer | Protection | Status |
|-------|-----------|--------|
| **API Key Storage** | Firebase Remote Config (not in APK) | ✅ Implemented |
| **App Verification** | Firebase App Check (Play Integrity) | ✅ Implemented |
| **User Rate Limiting** | 60 messages/day per device | ✅ Implemented |
| **Data Isolation** | Firestore rules: users can only read/write their own data | ✅ Implemented |
| **Auth Security** | Firebase Auth (email + Google OAuth) | ✅ Implemented |
| **Local Data** | SQLite (on-device, not accessible to other apps) | ✅ Implemented |
| **Crash Reporting** | Firebase Crashlytics | ✅ Implemented |
| **Git Security** | `app_config.dart` in `.gitignore` | ✅ Implemented |

---

## Play Store Deployment Checklist

### Before Publishing:

1. **Set up Firebase Remote Config:**
   ```
   Firebase Console → Remote Config → Add Parameter:
   Key: groq_api_key
   Value: gsk_your_actual_key_here
   → Publish Changes
   ```

2. **Build with obfuscation:**
   ```bash
   flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info
   ```
   This produces an AAB (Android App Bundle) with:
   - Code obfuscation (variable/class names randomized)
   - Split debug info (symbols stored separately for crash reports)

3. **Upload debug symbols to Crashlytics:**
   ```bash
   # Upload the split debug info so crash reports are readable
   firebase crashlytics:symbols:upload --app=YOUR_APP_ID build/debug-info/
   ```

4. **Verify Firestore Security Rules:**
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId}/{document=**} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
     }
   }
   ```

5. **App Check enforcement:**
   - Firebase Console → App Check → Enforce for Firestore
   - This blocks requests from non-verified apps (emulators, modified APKs)

6. **Rotate API key after publishing:**
   - Generate a new Groq API key
   - Update it in Remote Config (not in code)
   - Old key in the APK fallback becomes useless

### Play Store Listing Requirements:

- **Privacy Policy** — required (explain: data stored locally + Firebase sync)
- **Data Safety form** — declare: email, financial data, usage data
- **Target audience** — 18+ (financial app)
- **App category** — Finance
- **Content rating** — IARC questionnaire (no violence, no gambling)

---

## Future Security Upgrades (Post-Capstone)

### Option B: Cloud Functions Proxy (Requires Blaze Plan)
```
App → Cloud Function → Groq API
     (key never leaves server)
```
- API key stored in Cloud Functions environment variables
- Function validates App Check token before forwarding
- Adds ~200ms latency but maximum security
- Cost: ~$0.40/month for 1000 daily users

### Option C: Your Own Backend (Free)
```
App → Your PHP/Node server → Groq API
```
- Host on Vercel (free), Railway (free tier), or your XAMPP
- Validate Firebase ID token on your server
- Full control over rate limiting, logging, abuse detection
- Zero cost if self-hosted

---

## Key Rotation Procedure

If your API key is compromised:

1. Go to [Groq Console](https://console.groq.com/keys)
2. Generate a new API key
3. Update Firebase Remote Config with the new key
4. Publish Remote Config changes
5. App will fetch new key within 1 hour (or on next cold start)
6. Delete the old key from Groq Console
7. No app update needed — users get the new key automatically

---

## What Happens If Someone Decompiles the APK?

With our current setup:
1. **They find the fallback key** — but it's rate-limited (60/day per device)
2. **They can't bypass App Check** — Firebase rejects requests without valid Play Integrity token
3. **They can't access other users' data** — Firestore rules enforce UID-based access
4. **The real key is in Remote Config** — not in the APK binary
5. **You can rotate the fallback key** via Remote Config without an app update

---

*SmartSpend — Lucid Frame | Lorma Colleges CCSE BSIT 2025-2026*
