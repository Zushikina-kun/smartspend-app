# Update Checker — Investigation & Implementation Plan

## Summary

No update-check logic exists anywhere in the codebase. The app is fully ready for the feature:
`http` and `url_launcher` are already in `pubspec.yaml`, `DBService.getSetting`/`setSetting` provide the cache layer, `kAppVersion` (`'3.3.1'`) is exported from `debug_service.dart`, and all four integration points have clean insertion sites. The GitHub Releases API returns `tag_name`, `html_url`, `body`, `published_at`, and `assets` — all the fields needed. Zero blockers.

---

## Evidence

### 1. GitHub Releases API fields

`GET https://api.github.com/repos/Zushikina-kun/smartspend-app/releases/latest`

Confirmed available fields (from GitHub REST API docs and issue trackers):
- `tag_name` — the release tag, e.g. `"v3.3.1"`
- `html_url` — browser URL to the release page
- `body` — markdown release notes
- `published_at` — ISO 8601 timestamp
- `assets` — array of release asset objects (APK files, etc.)

The `tag_name` will have a leading `v` prefix (e.g. `v3.3.1`), so comparison must strip it before comparing against `kAppVersion` (`3.3.1`).

### 2. No existing update-check logic

`grep` across all `lib/**/*.dart` for `update.*check`, `checkUpdate`, `update_check`, `UpdateService`, `updateService` → **no matches**. The feature is entirely new.

### 3. `kAppVersion` — where it lives and who imports it

**Defined:** `lib/services/debug_service.dart` line 12
```dart
const kAppVersion = '3.3.1';
```

**Current importers:**
- `lib/services/backup_service.dart` — `import '../services/debug_service.dart' show kAppVersion;`
- `lib/screens/about_screen.dart` — same import, displays as `"Version $kAppVersion"`
- `lib/screens/feedback_screen.dart` — same import, included in bug reports

**pubspec.yaml version:** `3.3.1+118` (version name `3.3.1`, build number `118`). The constant matches the version name only — correct for semver comparison.

### 4. pubspec.yaml — required packages already present

```yaml
http: ^1.1.0          # HTTP calls to GitHub API
url_launcher: ^6.3.1  # Open GitHub releases URL
```

No new dependencies needed.

### 5. `DBService.getSetting` / `setSetting` — cache layer

**Signatures** (`lib/services/db_service.dart` lines 1463–1476):
```dart
static Future<void> setSetting(String key, String value) async { ... }
static Future<String?> getSetting(String key) async { ... }
```
Writes/reads the `settings` SQLite table (key TEXT PRIMARY KEY, value TEXT). Used throughout the app for string-serialized settings. The update service will use two keys:
- `update_check_last` — ISO 8601 timestamp of last check
- `update_check_result` — JSON-serialized `UpdateInfo`

### 6. `lib/main.dart` — startup hook

`main.dart` calls `runZonedGuarded { ... runApp(...) }`. The `SmartSpendApp` widget's `_SmartSpendAppState.initState` only hooks `themeService`. The `Dashboard` widget (a `StatefulWidget` inside `HomeScreen`) has its own `initState` at line 2435 of `home_screen.dart` where it calls `_loadData()` and `_checkDashboardGreeting()`. The brief specifies a 3-second delayed call — this belongs in `Dashboard.initState` (not `main.dart`), which is the right place: it runs after the home screen renders and has `BuildContext` available for the banner `setState`.

### 7. `Dashboard` widget — banner insertion point

`Dashboard.build` constructs a `ListView` (or `CustomScrollView`). The sequence at lines 5984–5990:
```dart
const SizedBox(height: 12),
// Section: Your Finances
_buildSectionHeader(context, 'YOUR FINANCES'),
// Balance Card
Container(...)
```
The update banner goes **between** the section header and the balance card — after `_buildSectionHeader(context, 'YOUR FINANCES')` and before the `Container(...)` for the balance card. The `Dashboard` state class already manages a `List<Map<String, dynamic>> _wallets` and other reactive fields, so adding `bool _showUpdateBanner = true` and triggering `setState` from the delayed check fits the existing pattern exactly.

### 8. `lib/screens/settings_screen.dart` — tile insertion point

The settings screen ends with:
- `LOCAL AI` section (lines ~950–1165)
- `HOME SCREEN — SHOW / HIDE SECTIONS` section (lines ~1165–1310)
- `ANALYTICS SECTIONS` section
- `_ExperiencePresetSelector` widget (line ~1370+)

The best insertion is a new `APP UPDATES` section **before** `HOME SCREEN — SHOW / HIDE SECTIONS`. It follows the established `_sectionLabel` + `_sectionCard` + `InkWell` pattern (same as the "Spending limits" and "Display currency" tappable rows). The tile needs to be a `StatefulWidget` scope or use a `FutureBuilder` to show the current update status — the simplest approach is to convert the section to a `FutureBuilder<UpdateInfo?>` that calls `UpdateService.checkForUpdate(forceRefresh: false)`.

### 9. `lib/screens/about_screen.dart` — version display

Line 37–40:
```dart
Text(
  "Version $kAppVersion",
  style: const TextStyle(color: Colors.grey, fontSize: 13),
),
```
This is a `StatelessWidget`. The update status indicator needs to read from `UpdateService`'s static cache (no async needed if the check already ran from `Dashboard.initState`). The widget becomes a `StatefulWidget` or the version `Text` is wrapped in a `FutureBuilder<UpdateInfo?>`. The brief says "add update status indicator next to version number" — a `Row` wrapping the `Text` with a conditional `Container` badge ("🆕 Update available") works with `FutureBuilder`.

---

## Conclusions

### What to build

**`lib/services/update_service.dart`** — new file:
- `UpdateInfo` data class: `hasUpdate`, `latestVersion`, `currentVersion`, `releaseUrl`, `releaseNotes`
- `UpdateService.checkForUpdate({bool forceRefresh = false})` — async static method:
  1. If `forceRefresh == false` and cache `update_check_last` is within 24 hours: deserialize and return `update_check_result`
  2. Otherwise: `GET https://api.github.com/repos/Zushikina-kun/smartspend-app/releases/latest` with `http` package, 10-second timeout
  3. Parse `tag_name` (strip leading `v`), compare with `kAppVersion` using `package:pub_semver`-style split on `.`
  4. Build `UpdateInfo`, serialize to JSON, write both cache keys, return
  5. Any exception → return `UpdateInfo(hasUpdate: false, ...)`
- `static UpdateInfo? _cached` — in-memory cache so home screen and about screen don't re-check
- Release URL is always `https://github.com/Zushikina-kun/smartspend-app/releases/latest` (not `html_url` from API — brief specifies this fixed URL)

**`lib/screens/home_screen.dart`** — `Dashboard` state:
- Add `bool _updateBannerDismissed = false` and `UpdateInfo? _updateInfo` to `_DashboardState`
- In `initState`, add:
  ```dart
  Future.delayed(const Duration(seconds: 3), () {
    if (!mounted) return;
    UpdateService.checkForUpdate().then((info) {
      if (info != null && info.hasUpdate && mounted) {
        setState(() => _updateInfo = info);
      }
    }).catchError((_) {});
  });
  ```
- In `build`, after `_buildSectionHeader(context, 'YOUR FINANCES')` and before the balance `Container`:
  ```dart
  if (_updateInfo != null && _updateInfo!.hasUpdate && !_updateBannerDismissed)
    _buildUpdateBanner(context),
  ```
- `_buildUpdateBanner` returns a teal/green `Container` with dismiss button and "Update" `TextButton` that calls `launchUrl`

**`lib/screens/settings_screen.dart`** — new section `APP UPDATES`:
- Add `import '../services/update_service.dart';` and `import 'package:url_launcher/url_launcher.dart';`
- Add `UpdateInfo? _updateInfo` to `_SettingsScreenState`; call `UpdateService.checkForUpdate()` in `_loadSettings()`
- Insert a new `_sectionLabel('APP UPDATES')` + `_sectionCard([...])` block containing one `InkWell` tappable row:
  - Icon: `Icons.system_update_outlined`
  - Title: `'Check for Updates'`
  - Subtitle: reactive — `'v$kAppVersion — Checking...'` during load, then `'Up to date'` or `'v${_updateInfo!.latestVersion} available — tap to update'`
  - `trailing`: `IconButton(Icons.refresh, ...)` that calls `UpdateService.checkForUpdate(forceRefresh: true)` then `setState`
  - `onTap`: launches `https://github.com/Zushikina-kun/smartspend-app/releases/latest`

**`lib/screens/about_screen.dart`** — convert to `StatefulWidget`:
- Change `class AboutScreen extends StatelessWidget` → `StatefulWidget` + State
- Add `UpdateInfo? _updateInfo`; call `UpdateService.checkForUpdate()` in `initState`
- Replace the version `Text` with a `Row` containing the version text plus a conditional green badge chip

### Version comparison logic

Strip `v` prefix from `tag_name`, split both strings on `.`, compare each integer segment left-to-right. No package needed — the app does not use `pub_semver`. A `hasUpdate` returns true only when the remote version is strictly greater.

### Error handling

All `http` calls are wrapped in `try/catch`. Timeout via `.timeout(const Duration(seconds: 10))`. On any failure: return `UpdateInfo(hasUpdate: false, currentVersion: kAppVersion, latestVersion: kAppVersion, releaseUrl: '...', releaseNotes: '')`. Never rethrow. Never show error UI to user.

### Cache keys

| Key | Type | Value |
|-----|------|-------|
| `update_check_last` | String | ISO 8601 datetime of last fetch |
| `update_check_result` | String | JSON: `{"hasUpdate":bool,"latestVersion":"x.y.z","releaseNotes":"..."}` |

24-hour TTL: compare `DateTime.now().difference(DateTime.parse(lastStr)).inHours >= 24`.

---

## Recommendations

1. **Import `url_launcher` in `settings_screen.dart` and `home_screen.dart`** — both need `launchUrl`. `about_screen.dart` already imports it (`import 'package:url_launcher/url_launcher.dart';`).

2. **Use `LaunchMode.externalApplication`** for the GitHub URL — consistent with how `about_screen.dart` already opens external links (see `_supportCard` → `open()` method).

3. **Place the banner below the greeting row** (line 5987 in `home_screen.dart`) and above the balance card. This is the highest-visibility non-intrusive position — it appears before any financial data, which the user scrolls past naturally. The brief says "below the top section header (before balance card)" — this matches exactly.

4. **Static `_cached` field on `UpdateService`** means the about screen and settings screen never trigger a redundant network call if `Dashboard.initState` already ran the check within the same app session.

5. **`forceRefresh: true`** in the settings refresh button must clear `_cached` as well as the DB keys before re-fetching, otherwise the in-memory cache returns stale data.

6. **`flutter analyze` safety**: import `'dart:convert'` for JSON encoding/decoding in the service. Use `jsonEncode`/`jsonDecode`. Avoid `dynamic` where the analyzer can infer types.

7. The `aboutScreen` currently uses `kAppVersion` via `import '../services/debug_service.dart' show kAppVersion;`. After conversion to `StatefulWidget`, that import is unchanged — just add `import '../services/update_service.dart';`.
