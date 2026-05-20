import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/app_lock_service.dart';
import '../services/auth_service.dart';
import '../services/db_service.dart';
import 'login_screen.dart';

/// App lock screen — shown when user returns to app without logging out.
/// Requires biometric or 4-digit PIN to unlock.
/// Only shown when a Firebase user is currently signed in.
class AppLockScreen extends StatefulWidget {
  final Widget destination;
  const AppLockScreen({super.key, required this.destination});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  String _pin = '';
  String? _error;
  bool _biometricAvailable = false;
  bool _checking = true;
  int _attempts = 0;
  DateTime? _lockedUntil;
  static const _maxAttempts = 5;
  static const _lockoutSeconds = 30;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final bioAvail = await AppLockService.isBiometricAvailable();
    setState(() {
      _biometricAvailable = bioAvail;
      _checking = false;
    });
    // Auto-trigger biometric on open if available
    if (bioAvail) {
      await Future.delayed(const Duration(milliseconds: 300));
      _tryBiometric();
    }
  }

  Future<void> _tryBiometric() async {
    final success = await AppLockService.authenticateWithBiometric();
    if (success && mounted) _unlock();
  }

  void _unlock() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => widget.destination),
    );
  }

  Future<void> _logout() async {
    // Push data to cloud before clearing local — same as profile_screen logout
    try {
      await DBService.pushAllToCloud();
    } catch (_) {} // non-fatal — proceed even if push fails
    await DBService.clearLocalData();
    await AppLockService.setEnabled(false);
    await AuthService.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  void _onDigit(String digit) {
    // Block input during lockout
    if (_lockedUntil != null && DateTime.now().isBefore(_lockedUntil!)) {
      final remaining = _lockedUntil!.difference(DateTime.now()).inSeconds;
      setState(() => _error = 'Locked. Try again in ${remaining}s.');
      return;
    }
    if (_pin.length >= 4) return;
    setState(() {
      _pin += digit;
      _error = null;
    });
    if (_pin.length == 4) _checkPin();
  }

  void _onDelete() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _checkPin() async {
    // Rate limiting check
    if (_lockedUntil != null && DateTime.now().isBefore(_lockedUntil!)) {
      final remaining = _lockedUntil!.difference(DateTime.now()).inSeconds;
      setState(() {
        _pin = '';
        _error = 'Too many attempts. Try again in ${remaining}s.';
      });
      return;
    }

    final correct = await AppLockService.verifyPin(_pin);
    if (correct) {
      _unlock();
    } else {
      _attempts++;
      if (_attempts >= _maxAttempts) {
        _lockedUntil =
            DateTime.now().add(const Duration(seconds: _lockoutSeconds));
        setState(() {
          _pin = '';
          _error = 'Too many attempts. Locked for ${_lockoutSeconds}s.';
        });
      } else {
        setState(() {
          _pin = '';
          _error =
              'Incorrect PIN. ${_maxAttempts - _attempts} attempt${_maxAttempts - _attempts == 1 ? '' : 's'} remaining.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? '';

    // Intercept back button — never allow navigating back past the lock screen
    // Either exit the app or do nothing. Never pop to app content.
    return PopScope(
      canPop: false, // block all back navigation
      onPopInvokedWithResult: (didPop, result) {
        // Do nothing — user must authenticate or log out
        // This prevents the bypass where back button skips the lock
      },
      child: Scaffold(
        body: SafeArea(
          child: _checking
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    const Spacer(),

                    // Logo + greeting
                    Image.asset(
                      'assets/logo.png',
                      width: 72,
                      height: 72,
                      errorBuilder: (_, __, ___) => Icon(
                          Icons.account_balance_wallet,
                          size: 64,
                          color: cs.primary),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Smart Spend",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email.isNotEmpty
                          ? "Welcome back, $email"
                          : "Welcome back",
                      style: TextStyle(
                          color: cs.onSurface.withValues(alpha: 0.5),
                          fontSize: 13),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    // PIN dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (i) {
                        final filled = i < _pin.length;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: filled
                                ? cs.primary
                                : cs.onSurface.withValues(alpha: 0.15),
                            border: Border.all(
                              color: filled
                                  ? cs.primary
                                  : cs.onSurface.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 12),

                    // Error message
                    SizedBox(
                      height: 20,
                      child: _error != null
                          ? Text(_error!,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 13))
                          : null,
                    ),

                    const SizedBox(height: 16),

                    // Biometric button
                    if (_biometricAvailable)
                      TextButton.icon(
                        onPressed: _tryBiometric,
                        icon: const Icon(Icons.fingerprint, size: 22),
                        label: const Text("Use Biometrics"),
                        style:
                            TextButton.styleFrom(foregroundColor: cs.primary),
                      ),

                    const SizedBox(height: 8),

                    // Number pad
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: Column(
                        children: [
                          for (final row in [
                            ['1', '2', '3'],
                            ['4', '5', '6'],
                            ['7', '8', '9'],
                            ['', '0', '⌫'],
                          ])
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: row.map((d) {
                                if (d.isEmpty) return const SizedBox(width: 72);
                                return _PadButton(
                                  label: d,
                                  onTap:
                                      d == '⌫' ? _onDelete : () => _onDigit(d),
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Logout link
                    TextButton(
                      onPressed: _logout,
                      child: Text(
                        "Not you? Log out",
                        style: TextStyle(
                            color: cs.onSurface.withValues(alpha: 0.4),
                            fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
        ), // closes Scaffold
      ), // closes PopScope
    );
  }
}

class _PadButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PadButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDelete = label == '⌫';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDelete
              ? Colors.transparent
              : cs.surfaceContainerHighest.withValues(alpha: 0.6),
        ),
        child: Center(
          child: isDelete
              ? Icon(Icons.backspace_outlined,
                  size: 22, color: cs.onSurface.withValues(alpha: 0.6))
              : Text(
                  label,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurface),
                ),
        ),
      ),
    );
  }
}
