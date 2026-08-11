import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'screens/splash_screen.dart';
import 'screens/app_lock_screen.dart';
import 'screens/home_screen.dart';
import 'services/theme_service.dart';
import 'services/currency_service.dart';
import 'services/notification_service.dart';
import 'services/app_lock_service.dart';
import 'services/app_config.dart';
import 'services/db_service.dart';

final themeService = ThemeService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
  ));

  await Firebase.initializeApp();

  // App Check — Play Integrity for Play Store builds, debug provider otherwise
  // Play Integrity only works for apps installed via Play Store with valid signing
  // For sideloaded APKs (QA testing), use debug provider
  try {
    await FirebaseAppCheck.instance.activate(
      // Use debug provider for all non-Play-Store builds
      // Switch to playIntegrity only when publishing to Play Store
      androidProvider: AndroidProvider.debug,
    );
  } catch (_) {
    // App Check activation failed — auth still works without it
  }

  // Fetch API key from Remote Config (fails silently — uses local fallback)
  try {
    await AppConfig.init();
  } catch (_) {
    // Remote Config unavailable — local fallback key will be used
  }

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  await runZonedGuarded(() async {
    await CurrencyService.init();
    await NotificationService.init();
    NotificationService.checkAndNotify();
    NotificationService.checkRecurringDue();
    NotificationService.checkDebtsDue();
    NotificationService.checkGoalDeadlines();
    NotificationService.checkDailyBriefing();
    // Anomaly detection — only if not disabled in settings
    DBService.getSetting('anomaly_detection_enabled').then((val) {
      if (val != 'false') NotificationService.checkAnomalyDetection();
    }).catchError((_) => NotificationService.checkAnomalyDetection());
    NotificationService.checkCategoryVelocity();
    NotificationService.checkWantSpendingAlert();
    runApp(const SmartSpendApp());
  }, (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  });
}

class SmartSpendApp extends StatefulWidget {
  const SmartSpendApp({super.key});

  @override
  State<SmartSpendApp> createState() => _SmartSpendAppState();
}

class _SmartSpendAppState extends State<SmartSpendApp> {
  // App lock is now handled only at login/splash — not on resume.
  // Users should not need to re-authenticate every time they switch apps.
  // The AppLockScreen is still used by SplashScreen for the initial
  // PIN/biometric check when the app is opened fresh after a logout.

  @override
  void initState() {
    super.initState();
    themeService.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Spend',
      themeMode: themeService.themeMode,
      theme: themeService.lightTheme,
      darkTheme: themeService.darkTheme,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(themeService.textScale),
        ),
        child: child!,
      ),
      home: const SplashScreen(),
    );
  }
}
