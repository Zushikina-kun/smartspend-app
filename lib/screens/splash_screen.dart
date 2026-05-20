import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/db_service.dart';
import '../services/app_lock_service.dart';
import 'app_lock_screen.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';
import 'setup_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    Future.delayed(const Duration(seconds: 2), _navigate);
  }

  void _navigate() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_done') ?? false;
    final user = FirebaseAuth.instance.currentUser;

    Widget next;
    if (!onboardingDone) {
      next = const OnboardingScreen();
    } else if (user != null) {
      final setupDone = await DBService.getSetting('setup_done');
      if (setupDone == null) {
        next = const SetupScreen();
      } else {
        // Check if app lock is enabled — show lock screen instead of home
        final lockEnabled = await AppLockService.isEnabled();
        final hasPin = await AppLockService.hasPin();
        if (lockEnabled && hasPin) {
          next = AppLockScreen(destination: const HomeScreen());
        } else {
          next = const HomeScreen();
        }
      }
    } else {
      // No Firebase user — check if we're in demo mode
      // If was_demo_mode is true, go straight to HomeScreen (preserve demo data)
      // If not, go to LoginScreen
      final wasDemo = prefs.getBool('was_demo_mode') ?? false;
      if (wasDemo) {
        final setupDone = await DBService.getSetting('setup_done');
        if (setupDone != null) {
          next = const HomeScreen();
        } else {
          next = const LoginScreen();
        }
      } else {
        next = const LoginScreen();
      }
    }

    if (mounted) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => next));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0066FF),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Use logo.png if available, fallback to icon
                Image.asset(
                  'assets/logo.png',
                  width: 160,
                  height: 160,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.account_balance_wallet,
                    size: 100,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Smart Spend",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Your AI Financial Assistant",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
