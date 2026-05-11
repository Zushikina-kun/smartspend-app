import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/db_service.dart';
import 'setup_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  bool _obscureConfirm = true;
  String? _errorMessage;

  Future<void> _register() async {
    if (!_validate()) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final user =
          await AuthService.register(_email.text.trim(), _password.text);
      if (user != null && mounted) {
        // Save the display name to Firebase profile
        await user.updateDisplayName(_name.text.trim());
        // Kick off background sync — new account has nothing to pull,
        // but this ensures any local data (e.g. from demo mode) is cleared
        // and the account is properly initialized in Firestore.
        _syncAfterRegister();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SetupScreen()),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _errorMessage = _friendlyError(e.toString()));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _syncAfterRegister() async {
    try {
      // Clear any leftover demo data so the new account starts clean
      final prefs = await SharedPreferences.getInstance();
      final wasDemo = prefs.getBool('was_demo_mode') ?? false;
      if (wasDemo) {
        await DBService.clearLocalData();
        await prefs.setBool('was_demo_mode', false);
      }
      // No pull needed — brand new account has no cloud data yet.
      // Setup screen will push everything after the user completes onboarding.
    } catch (_) {}
  }

  bool _validate() {
    if (_name.text.trim().isEmpty) {
      setState(() => _errorMessage = "Please enter your name.");
      return false;
    }
    final email = _email.text.trim();
    if (email.isEmpty) {
      setState(() => _errorMessage = "Please enter your email.");
      return false;
    }
    // Basic email regex
    final emailRegex = RegExp(r'^[\w\.\+\-]+@[\w\-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      setState(() => _errorMessage = "Please enter a valid email address.");
      return false;
    }
    if (_password.text.length < 6) {
      setState(() => _errorMessage = "Password must be at least 6 characters.");
      return false;
    }
    if (_password.text != _confirmPassword.text) {
      setState(() => _errorMessage = "Passwords do not match.");
      return false;
    }
    return true;
  }

  String _friendlyError(String raw) {
    if (raw.contains('email-already-in-use'))
      return "This email is already registered.";
    if (raw.contains('invalid-email')) return "Invalid email address.";
    if (raw.contains('weak-password'))
      return "Password is too weak. Use at least 6 characters.";
    if (raw.contains('network-request-failed'))
      return "No internet connection.";
    if (raw.contains('operation-not-allowed'))
      return "Registration is not enabled. Contact support.";
    return raw;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
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
                'logo.png',
                width: 100,
                height: 100,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.account_balance_wallet, size: 64),
              ),
              const SizedBox(height: 12),
              const Text(
                "Smart Spend",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const Text("Start tracking your finances",
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              TextField(
                controller: _name,
                decoration: InputDecoration(
                  labelText: "Full Name",
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 14),
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
              const SizedBox(height: 14),
              TextField(
                controller: _confirmPassword,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _register,
                  style: ElevatedButton.styleFrom(
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
                      : const Text("Create Account"),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Already have an account? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
