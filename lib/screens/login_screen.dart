import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/demo_service.dart';
import '../services/db_service.dart';
import '../widgets/feature_tour.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _googleLoading = false;
  bool _obscure = true;
  String? _errorMessage;

  Future<void> _forgotPassword() async {
    final emailCtrl = TextEditingController(text: _email.text.trim());
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reset Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                "Enter your email address and we'll send you a password reset link."),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              decoration: InputDecoration(
                labelText: "Email",
                prefixIcon: const Icon(Icons.email_outlined),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Send Reset Link"),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final email = emailCtrl.text.trim();
    if (email.isEmpty) return;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Password reset email sent to $email"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_friendlyError(e.toString())),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _login() async {
    if (!_validate()) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final user = await AuthService.login(_email.text.trim(), _password.text);
      if (user != null && mounted) {
        _syncAfterLogin();
        _goHome();
      }
    } catch (e) {
      if (mounted) setState(() => _errorMessage = _friendlyError(e.toString()));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _syncAfterLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wasDemo = prefs.getBool('was_demo_mode') ?? false;
      if (wasDemo) {
        await DBService.clearLocalData();
        await prefs.setBool('was_demo_mode', false);
      }
      await DBService.syncFromCloud();
      await DBService.pushAllToCloud();

      // Save Google profile photo if available and not already set locally.
      // user.photoURL is a remote HTTPS URL — no Firebase Storage needed.
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.photoURL != null && user.photoURL!.isNotEmpty) {
        final existing = await DBService.getProfile(user.uid);
        final hasPhoto =
            existing?.photoUrl != null && existing!.photoUrl!.isNotEmpty;
        if (!hasPhoto) {
          final profile =
              (existing ?? UserProfile(uid: user.uid, email: user.email))
                  .copyWith(photoUrl: user.photoURL);
          await DBService.saveProfile(profile);
        }
      }
    } catch (_) {}
  }

  Future<void> _loginWithGoogle() async {
    setState(() {
      _googleLoading = true;
      _errorMessage = null;
    });
    try {
      final user = await AuthService.signInWithGoogle();
      if (user != null && mounted) {
        _syncAfterLogin();
        _goHome();
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _errorMessage = _friendlyError(e.toString()));
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('linkaccountexception') ||
          msg.contains('account-exists')) {
        if (mounted) {
          setState(() => _errorMessage =
              "An account with this email already exists. Please log in with your password first, then link Google from Profile settings.");
        }
      } else if (msg.contains('sign_in_canceled') ||
          msg.contains('network_error') ||
          msg.contains('canceled')) {
        // User cancelled or no network — silent, no error shown
      } else if (msg.contains('sha') ||
          msg.contains('certificate') ||
          msg.contains('10:') ||
          msg.contains('developer_error') ||
          msg.contains('sign_in_failed')) {
        // SHA-1 fingerprint not registered in Firebase
        if (mounted) {
          setState(() => _errorMessage =
              "Google sign-in configuration error.\n\nIf you're a developer: add your debug SHA-1 fingerprint to Firebase Console → Project Settings → Your Apps → Android app.\n\nDebug SHA-1: 4D:1C:67:D4:78:7A:30:20:6D:5B:D5:97:6E:F6:EF:87:3D:91:12:E8");
        }
      } else {
        if (mounted) {
          setState(() => _errorMessage =
              "Google sign-in failed. Try email/password login instead.\n\nError: ${e.toString().replaceAll('Exception: ', '')}");
        }
      }
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  void _goHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  Future<void> _tryDemo() async {
    setState(() => _loading = true);
    try {
      await DemoService.loadSampleData();
      await FeatureTour.markDone();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_done', true);
      await prefs.setBool('was_demo_mode', true);
      if (mounted) _goHome();
    } catch (e) {
      if (mounted) setState(() => _errorMessage = "Could not load demo: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _validate() {
    if (_email.text.trim().isEmpty || _password.text.isEmpty) {
      setState(() => _errorMessage = "Please fill in all fields.");
      return false;
    }
    return true;
  }

  String _friendlyError(String raw) {
    if (raw.contains('user-not-found'))
      return "No account found with this email.";
    if (raw.contains('wrong-password') || raw.contains('invalid-credential'))
      return "Incorrect password.";
    if (raw.contains('invalid-email')) return "Invalid email address.";
    if (raw.contains('network-request-failed'))
      return "No internet connection.";
    if (raw.contains('too-many-requests'))
      return "Too many attempts. Try again later.";
    return "Login failed. Please try again.";
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/logo.png',
                width: 100,
                height: 100,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(Icons.account_balance_wallet,
                    size: 64, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 12),
              const Text(
                "Smart Spend",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const Text("Your AI financial assistant",
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 36),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _password,
                obscureText: _obscure,
                onSubmitted: (_) => _login(),
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _loading ? null : _forgotPassword,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text("Forgot Password?",
                      style: TextStyle(fontSize: 13)),
                ),
              ),
              const SizedBox(height: 8),
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.redAccent),
                  ),
                  child: Text(
                    _errorMessage!,
                    style:
                        const TextStyle(color: Colors.redAccent, fontSize: 13),
                  ),
                ),

              // Login button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text("Login"),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child:
                        Text("or", style: TextStyle(color: Colors.grey[500])),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 12),

              // Google Sign-In button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _googleLoading ? null : _loginWithGoogle,
                  icon: _googleLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.g_mobiledata,
                          size: 24, color: Color(0xFFDB4437)),
                  label: _googleLoading
                      ? const Text("Signing in...")
                      : const Text("Continue with Google"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
              ),

              const SizedBox(height: 10),
              TextButton(
                onPressed: _loading
                    ? null
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RegisterScreen()),
                        ),
                child: const Text("Don't have an account? Register"),
              ),

              const SizedBox(height: 4),
              OutlinedButton.icon(
                onPressed: _loading ? null : _tryDemo,
                icon: const Icon(Icons.science_outlined, size: 18),
                label: const Text("Try Demo (No Account Needed)"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                  side: BorderSide(color: Colors.grey[300]!),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Demo uses sample data — no real account required",
                style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
