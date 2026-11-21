import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'db_service.dart';
import 'debug_service.dart'; // for kAppVersion

/// Holds info about an available update.
class UpdateInfo {
  final bool hasUpdate;
  final String latestVersion;
  final String currentVersion;
  final String releaseUrl;
  final String releaseNotes;
  final String? apkDownloadUrl; // direct arm64-v8a APK URL if available

  const UpdateInfo({
    required this.hasUpdate,
    required this.latestVersion,
    required this.currentVersion,
    required this.releaseUrl,
    required this.releaseNotes,
    this.apkDownloadUrl,
  });
}

/// Download progress state for UI.
class DownloadProgress {
  final double percent; // 0.0 – 1.0
  final int received;
  final int total;
  final bool done;
  final bool failed;
  const DownloadProgress({
    required this.percent,
    required this.received,
    required this.total,
    this.done = false,
    this.failed = false,
  });
}

/// In-app update checker + APK downloader.
///
/// Flow:
///   1. checkForUpdate() — hits GitHub API, caches 6 hrs.
///   2. If hasUpdate: show banner in home screen.
///   3. User taps "Update":
///      a. If apkDownloadUrl available → downloadAndInstall() — downloads
///         APK to cache dir and triggers Android installer. User taps Install.
///      b. Otherwise → openReleasePage() — opens GitHub releases in browser.
class UpdateService {
  static const _repo = 'Zushikina-kun/smartspend-app';
  static const _cacheKey = 'update_check_result';
  static const _cacheTimeKey = 'update_check_last';
  static const _cacheHours = 6;

  static UpdateInfo? _cached;
  static bool _dismissed = false;
  static bool _downloading = false;
  static DownloadProgress? _progress;
  static CancelToken? _cancelToken;

  static bool get isDismissed => _dismissed;
  static bool get hasUpdate => _cached?.hasUpdate == true && !_dismissed;
  static bool get isDownloading => _downloading;
  static DownloadProgress? get downloadProgress => _progress;
  static UpdateInfo? get cached => _cached;

  static void dismiss() => _dismissed = true;
  static void cancelDownload() {
    _cancelToken?.cancel('User cancelled');
    _downloading = false;
    _progress = null;
  }

  // ── Version comparison ───────────────────────────────────────────────────
  static bool _isNewer(String latest, String current) {
    List<int> parse(String v) => v
        .replaceAll('v', '')
        .trim()
        .split('.')
        .map((s) => int.tryParse(s) ?? 0)
        .toList();
    final l = parse(latest);
    final c = parse(current);
    for (int i = 0; i < 3; i++) {
      final lv = i < l.length ? l[i] : 0;
      final cv = i < c.length ? c[i] : 0;
      if (lv > cv) return true;
      if (lv < cv) return false;
    }
    return false;
  }

  // ── Check for update ─────────────────────────────────────────────────────
  static Future<UpdateInfo?> checkForUpdate({bool forceRefresh = false}) async {
    try {
      // Serve from cache if fresh
      if (!forceRefresh) {
        final lastCheck = await DBService.getSetting(_cacheTimeKey);
        if (lastCheck != null) {
          final last = DateTime.tryParse(lastCheck);
          if (last != null &&
              DateTime.now().difference(last).inHours < _cacheHours) {
            final cachedStr = await DBService.getSetting(_cacheKey);
            if (cachedStr != null) {
              final map = jsonDecode(cachedStr) as Map<String, dynamic>;
              _cached = UpdateInfo(
                hasUpdate: map['hasUpdate'] as bool,
                latestVersion: map['latestVersion'] as String,
                currentVersion: map['currentVersion'] as String,
                releaseUrl: map['releaseUrl'] as String,
                releaseNotes: map['releaseNotes'] as String,
                apkDownloadUrl: map['apkDownloadUrl'] as String?,
              );
              // Invalidate cache if it was built for a different app version,
              // then fall through to a fresh API call below.
              if (_cached != null && _cached!.currentVersion != kAppVersion) {
                _cached = null;
              }
              if (_cached != null) return _cached;
            }
          }
        }
      }

      // Fetch latest release from GitHub API
      final response = await http.get(
        Uri.parse('https://api.github.com/repos/$_repo/releases/latest'),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final tagName =
          (data['tag_name'] as String? ?? '').replaceAll('v', '').trim();
      final htmlUrl = data['html_url'] as String? ??
          'https://github.com/$_repo/releases/latest';
      final rawBody = data['body'] as String? ?? '';
      final releaseNotes = rawBody.substring(0, rawBody.length.clamp(0, 600));
      final hasUpdate = _isNewer(tagName, kAppVersion);

      // Find arm64-v8a APK download URL from release assets
      String? apkUrl;
      final assets = data['assets'] as List<dynamic>? ?? [];
      for (final asset in assets) {
        final name = (asset['name'] as String? ?? '').toLowerCase();
        final url = asset['browser_download_url'] as String? ?? '';
        // Prefer arm64-v8a (best for modern phones)
        if (name.contains('arm64-v8a') && name.endsWith('.apk')) {
          apkUrl = url;
          break;
        }
      }
      // Fallback to any APK if arm64 not found
      if (apkUrl == null) {
        for (final asset in assets) {
          final name = (asset['name'] as String? ?? '').toLowerCase();
          final url = asset['browser_download_url'] as String? ?? '';
          if (name.endsWith('.apk')) {
            apkUrl = url;
            break;
          }
        }
      }

      _cached = UpdateInfo(
        hasUpdate: hasUpdate,
        latestVersion: tagName,
        currentVersion: kAppVersion,
        releaseUrl: htmlUrl,
        releaseNotes: releaseNotes,
        apkDownloadUrl: apkUrl,
      );

      // Cache for 6 hours
      await DBService.setSetting(
        _cacheKey,
        jsonEncode({
          'hasUpdate': hasUpdate,
          'latestVersion': tagName,
          'currentVersion': kAppVersion,
          'releaseUrl': htmlUrl,
          'releaseNotes': releaseNotes,
          'apkDownloadUrl': apkUrl,
        }),
      );
      await DBService.setSetting(
          _cacheTimeKey, DateTime.now().toIso8601String());

      return _cached;
    } catch (_) {
      return null; // Never crash the app
    }
  }

  // ── Download APK and trigger Android installer ───────────────────────────
  /// Downloads the APK to the app cache directory, then opens the Android
  /// package installer so the user just taps "Install".
  ///
  /// [onProgress] is called repeatedly with 0.0–1.0 as download progresses.
  /// Returns true if the installer was launched, false on any failure.
  static Future<bool> downloadAndInstall({
    required void Function(DownloadProgress) onProgress,
  }) async {
    if (_cached?.apkDownloadUrl == null) return false;
    if (_downloading) return false;

    _downloading = true;
    _cancelToken = CancelToken();

    try {
      // Save to app cache directory (no storage permission needed)
      final cacheDir = await getTemporaryDirectory();
      final apkDir = Directory('${cacheDir.path}/apk_updates');
      if (!await apkDir.exists()) await apkDir.create(recursive: true);

      final apkPath =
          '${apkDir.path}/SmartSpend-v${_cached!.latestVersion}.apk';
      final apkFile = File(apkPath);

      // Delete old APK if exists
      if (await apkFile.exists()) await apkFile.delete();

      final dio = Dio();
      await dio.download(
        _cached!.apkDownloadUrl!,
        apkPath,
        cancelToken: _cancelToken,
        onReceiveProgress: (received, total) {
          if (total <= 0) return;
          _progress = DownloadProgress(
            percent: received / total,
            received: received,
            total: total,
          );
          onProgress(_progress!);
        },
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          headers: {'Accept': '*/*'},
        ),
      );

      _progress =
          DownloadProgress(percent: 1.0, received: 0, total: 0, done: true);
      onProgress(_progress!);

      // Launch Android installer using url_launcher with file URI
      // Uses content:// URI via FileProvider for Android 7+
      await _launchInstaller(apkPath);
      _downloading = false;
      return true;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        debugPrint('Update download cancelled');
      } else {
        debugPrint('Update download failed: $e');
      }
      _progress =
          DownloadProgress(percent: 0, received: 0, total: 0, failed: true);
      onProgress(_progress!);
      _downloading = false;
      return false;
    } catch (e) {
      debugPrint('Update install failed: $e');
      _progress =
          DownloadProgress(percent: 0, received: 0, total: 0, failed: true);
      onProgress(_progress!);
      _downloading = false;
      return false;
    }
  }

  static Future<void> _launchInstaller(String apkPath) async {
    // Use url_launcher with file URI — Android will route to package installer
    final uri = Uri.file(apkPath);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // Fallback: open GitHub releases page
      await openReleasePage();
    }
  }

  // ── Open GitHub releases page in browser ────────────────────────────────
  static Future<void> openReleasePage() async {
    final url =
        _cached?.releaseUrl ?? 'https://github.com/$_repo/releases/latest';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
