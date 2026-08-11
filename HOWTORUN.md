# Smart Spend — How to Run & Build

**Version:** 2.9.1 | **Platform:** Android (Flutter)
**Academic Year:** 2026–2027, 1st Semester

---

## Prerequisites

| Tool | Version | Notes |
|------|---------|-------|
| Flutter | 3.x (stable) | `flutter --version` to check |
| Dart | Included with Flutter | |
| Android Studio | Latest | For Android SDK + emulator |
| Android SDK | API 33+ | Target: API 36 |
| Java | 17 (JDK) | Required by Gradle |
| Git | Any | For cloning |

---

## 1. Clone the Project

```bash
git clone https://github.com/Zushikina-kun/smartspend-app.git
cd smartspend-app
```

---

## 2. Firebase Setup

The app requires Firebase. The `google-services.json` file is **not included in the repo** (contains API keys — see `SECURITY.md`).

A template with placeholder values is at `android/app/google-services.json.example`.

To set up your own:
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Open the **SmartSpend** project (or create a new one)
3. Go to Project Settings → Android app (package: `com.lucidframe.smartspend_app`)
4. Download `google-services.json`
5. Place it at: `android/app/google-services.json`

Firebase services used:
- **Firebase Auth** — email/password + Google Sign-In
- **Firestore** — cloud data sync
- **Firebase Crashlytics** — crash reporting
- **Firebase App Check** — Play Integrity (release builds)

> **Note for the original dev team:** If you need the original `google-services.json`, get it from Brix or download it fresh from the Firebase Console. The copy that was previously committed has been removed from tracking — see `SECURITY.md`.

---

## 3. API Key Setup

The Groq API key is stored in `lib/services/app_config.dart` which is excluded from git.

Create the file:
```bash
# Copy the example file
cp lib/services/app_config.dart.example lib/services/app_config.dart
```

Then open `lib/services/app_config.dart` and fill in your Groq key:
```dart
static const groqApiKey = "gsk_YOUR_KEY_HERE";
```

Get a free Groq key at: https://console.groq.com

> The key used in development has a 60 req/day cap enforced in-app. For production, rotate the key and consider a server-side proxy.

---

## 4. Install Dependencies

```bash
flutter pub get
```

---

## 5. Run in Debug Mode

### On a physical device (recommended)
1. Enable Developer Options on your Android phone
2. Enable USB Debugging
3. Connect via USB
4. Run:
```bash
flutter run
```

### On an emulator
1. Open Android Studio → Device Manager → Start an emulator (API 33+)
2. Run:
```bash
flutter run
```

### Hot reload
While running, press `r` in the terminal for hot reload, `R` for hot restart.

---

## 6. Release Signing Setup

The app uses a proper release keystore so APK updates install over previous versions without uninstalling, and Google Sign-In works correctly.

**Files needed (NOT in git — you must have these locally):**
- `android/app/smartspend-release.jks` — the keystore file
- `android/key.properties` — passwords and alias

**`android/key.properties` format:**
```
storePassword=SmartSpend2026!
keyPassword=SmartSpend2026!
keyAlias=smartspend
storeFile=smartspend-release.jks
```

**If you're setting up on a new machine:**
1. Get `smartspend-release.jks` from Brix (keep it safe — losing it means you can never update the app on existing installs)
2. Create `android/key.properties` with the content above
3. Run `flutter build apk --release --split-per-abi ...`

**SHA-1 fingerprints registered in Firebase:**
- Release: `9E:2E:EE:E5:0A:9D:80:66:4E:79:DF:22:8E:B9:79:8A:E0:C7:F2:28`
- Debug (machine 1): `40:B2:1D:58:7A:95:93:55:6D:A2:B0:5A:22:43:D4:1B:D0:C0:D6:62`
- Debug (machine 2 — Brix's current dev machine): `4D:1C:67:D4:78:7A:30:20:6D:5B:D5:97:6E:F6:EF:87:3D:91:12:E8`

All are registered in Firebase Console → Project Settings → Android app → SHA certificate fingerprints. This is required for Google Sign-In to work.

**If Google Sign-In fails on a new machine:**
1. Run: `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`
2. Copy the SHA-1 fingerprint
3. Add it to Firebase Console → Project Settings → Android app → Add fingerprint
4. Download the new `google-services.json` and replace `android/app/google-services.json`
5. Rebuild the APK

> **App Check note:** App Check is in **debug/monitoring mode** for sideloaded APKs (academic builds). Before submitting to Google Play Store, switch App Check to `PlayIntegrityProvider` enforcement in `main.dart` and register the release SHA-256 fingerprint in Firebase Console.

---

## 7. Build Release APK

### Recommended build (all ABIs — covers all phones)
```bash
flutter build apk --release --split-per-abi --shrink --obfuscate --split-debug-info=build/debug-info
```

**Output — 3 APKs, one per CPU architecture:**
```
build/app/outputs/flutter-apk/
├── app-armeabi-v7a-release.apk  (~36.9 MB)  ← older/32-bit phones (Android 5+)
├── app-arm64-v8a-release.apk    (~44.6 MB)  ← modern 64-bit phones ← primary
└── app-x86_64-release.apk       (~47.5 MB)  ← emulators / x86 devices
```

**Which APK to install:**
| Device | APK |
|--------|-----|
| Modern phones (2018+, Snapdragon 6xx/8xx, Dimensity, Helio G/A) | `app-arm64-v8a-release.apk` |
| Older phones (pre-2018, 32-bit, Android 5–7) | `app-armeabi-v7a-release.apk` |
| Android Studio emulator | `app-x86_64-release.apk` |
| Not sure | Try `arm64-v8a` first — if it says "App not installed", use `armeabi-v7a` |

### What the flags do
| Flag | Effect |
|------|--------|
| `--target-platform android-arm64` | Only build for 64-bit ARM (modern phones) |
| `--split-per-abi` | Separate APK per CPU arch — smaller than fat APK |
| `--shrink` | R8 code + resource shrinking via ProGuard |
| `--obfuscate` | Renames classes/methods — reduces DEX size, harder to reverse |
| `--split-debug-info=build/debug-info` | Required with `--obfuscate`; saves symbol maps for crash decoding |

> Keep the `build/debug-info/` folder if you need to decode Crashlytics stack traces.

### Simple build (no obfuscation, for testing)
```bash
flutter build apk --release --split-per-abi
```

---

## 8. Install APK on Device

```bash
# Via ADB
adb install build/app/outputs/flutter-apk/app-arm64-v8a-release.apk

# Or transfer the file to the phone and open it
```

---

## 9. Project Structure

```
smartspend-app/
├── lib/
│   ├── main.dart                  # App entry point
│   ├── models/                    # Data models (Expense, Budget, UserProfile)
│   ├── screens/                   # All UI screens (31 screens)
│   ├── services/                  # Business logic & data layer (23 services)
│   └── widgets/                   # Reusable widgets
├── android/
│   └── app/
│       └── google-services.json   # ← YOU MUST ADD THIS (not in repo)
├── lib/services/app_config.dart   # ← YOU MUST CREATE THIS (not in repo)
├── pubspec.yaml                   # Dependencies
├── DOCUMENTATION.md               # Full technical docs
├── HOWTORUN.md                    # This file
└── KIRO_CONTEXT.md                # AI assistant context
```

---

## 10. Common Issues

### `google-services.json not found`
You need to add the Firebase config file. See step 2 above.

### `app_config.dart not found`
You need to create the API key file. See step 3 above.

### `flutter pub get` fails
Make sure you're on Flutter stable channel:
```bash
flutter channel stable
flutter upgrade
flutter pub get
```

### Build fails with Gradle error
Make sure Java 17 is installed and set as JAVA_HOME:
```bash
java -version  # should show 17.x
```

### `Developer Mode` warning on Windows
Flutter on Windows requires Developer Mode for symlinks:
```
Settings → System → For developers → Developer Mode → ON
```

### App crashes on launch (release build)
Check that `google-services.json` matches the package name `com.lucidframe.smartspend` (or whatever is in `android/app/build.gradle`).

### Google Sign-In fails
Check that the SHA-1 fingerprint of your debug keystore is registered in Firebase. Your debug SHA-1:
```
4D:1C:67:D4:78:7A:30:20:6D:5B:D5:97:6E:F6:EF:87:3D:91:12:E8
```
If running on a different machine, generate your own:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```
Then add the SHA-1 in Firebase Console → Project Settings → Android app → Add fingerprint, download the updated `google-services.json`, and rebuild.

---

## 11. Test Device

Primary test device: **Poco X6 Pro** (Android 16, HyperOS 2)
- Use `app-arm64-v8a-release.apk`
- Optical in-display fingerprint works with `biometricOnly: false` in `local_auth`

---

## 12. Key Dependencies

| Package | Purpose |
|---------|---------|
| `sqflite` | Local SQLite database |
| `firebase_auth` | Authentication |
| `cloud_firestore` | Cloud sync |
| `firebase_crashlytics` | Crash reporting |
| `firebase_app_check` | API abuse protection |
| `google_sign_in` | Google OAuth |
| `local_auth` | PIN + biometric lock |
| `google_mlkit_text_recognition` | OCR for receipts |
| `google_mlkit_barcode_scanning` | Barcode/QR detection |
| `mobile_scanner` | Live camera barcode scanning |
| `fl_chart` | Charts (pie, bar, line) |
| `speech_to_text` | Voice input |
| `flutter_local_notifications` | Push notifications |
| `share_plus` | Backup export via share sheet |
| `file_picker` | Backup restore file picker |
| `shake` | Shake-to-undo gesture |
| `http` | Groq API + exchange rate calls |

---

*Smart Spend — Lucid Frame | Lorma Colleges CCSE, BSIT | 2026–2027 (1st Semester)*
