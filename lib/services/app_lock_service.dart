import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages app-level lock: biometric + 4-digit PIN.
/// Only active when a user is logged in and exits without logging out.
/// All PIN and enabled-state keys are per-account (keyed by Firebase UID).
class AppLockService {
  static final _localAuth = LocalAuthentication();

  static const _salt = 'smartspend_lucidframe_2026';

  // ── PER-ACCOUNT KEY HELPERS ───────────────────────────────

  /// Returns the current user's UID, or 'demo' for demo/unauthenticated mode.
  static String _getUid() => FirebaseAuth.instance.currentUser?.uid ?? 'demo';

  static String _pinKey([String? uid]) => 'app_lock_pin_${uid ?? _getUid()}';

  static String _enabledKey([String? uid]) =>
      'app_lock_enabled_${uid ?? _getUid()}';

  // ── PIN ───────────────────────────────────────────────────

  /// Simple obfuscation — not cryptographic but sufficient for a PIN lock
  static String _obfuscatePin(String pin) {
    final combined = '$_salt:$pin';
    return base64Encode(utf8.encode(combined));
  }

  static Future<void> setPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinKey(), _obfuscatePin(pin));
    await prefs.setBool(_enabledKey(), true);
  }

  static Future<bool> verifyPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_pinKey());
    if (stored == null) return false;
    return stored == _obfuscatePin(pin);
  }

  static Future<bool> hasPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pinKey()) != null;
  }

  static Future<void> removePin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pinKey());
    await prefs.setBool(_enabledKey(), false);
  }

  // ── LOCK STATE ────────────────────────────────────────────

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey()) ?? false;
  }

  static Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey(), value);
  }

  // ── BIOMETRIC ─────────────────────────────────────────────

  /// Check if device supports any form of biometric/device auth.
  /// Uses isDeviceSupported() as primary check — more reliable on
  /// Xiaomi/POCO devices with custom biometric stacks (HyperOS, MIUI).
  static Future<bool> isBiometricAvailable() async {
    try {
      // isDeviceSupported covers fingerprint, face, iris, and device PIN
      final isSupported = await _localAuth.isDeviceSupported();
      if (!isSupported) return false;
      // Also check canCheckBiometrics but don't require it —
      // some devices (Poco X6 Pro optical in-display) return false here
      // even when fingerprint is enrolled
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> authenticateWithBiometric() async {
    try {
      // biometricOnly: false — allows device PIN/pattern as fallback
      // This ensures it works on all devices including optical in-display sensors
      return await _localAuth.authenticate(
        localizedReason: 'Unlock Smart Spend',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          sensitiveTransaction: false,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
