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

  // App Check — Play Integrity for release, debug provider for debug builds
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
  );

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  await runZonedGuarded(() async {
    await CurrencyService.init();
    await NotificationService.init();
    NotificationService.checkAndNotify();
    NotificationService.checkRecurringDue();
    NotificationService.checkDebtsDue();
    NotificationService.checkGoalDeadlines();
    NotificationService.checkDailyBriefing();
    NotificationService.checkAnomalyDetection();
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

class _SmartSpendAppState extends State<SmartSpendApp>
    with WidgetsBindingObserver {
  final _navigatorKey = GlobalKey<NavigatorState>();
  bool _lockShowing = false;
  DateTime? _backgroundedAt; // track when app went to background
  static const _lockAfterSeconds = 180; // 3 minutes

  @override
  void initState() {
    super.initState();
    themeService.addListener(() => setState(() {}));
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Record when app went to background
      _backgroundedAt ??= DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      _checkLockOnResume();
    } else if (state == AppLifecycleState.detached) {
      // App fully closed — reset so it locks on next open
      _backgroundedAt = null;
    }
  }

  Future<void> _checkLockOnResume() async {
    if (_lockShowing) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final lockEnabled = await AppLockService.isEnabled();
    final hasPin = await AppLockService.hasPin();
    if (!lockEnabled || !hasPin) return;

    // Only lock if backgrounded for more than 3 minutes
    // This prevents the lock from triggering during brief interruptions
    // like share sheets, file pickers, camera, etc.
    final bg = _backgroundedAt;
    if (bg != null) {
      final secondsAway = DateTime.now().difference(bg).inSeconds;
      if (secondsAway < _lockAfterSeconds) {
        _backgroundedAt = null; // reset
        return; // too brief — don't lock
      }
    }
    _backgroundedAt = null; // reset

    _lockShowing = true;
    _navigatorKey.currentState
        ?.push(
          MaterialPageRoute(
            builder: (_) => AppLockScreen(destination: const HomeScreen()),
            fullscreenDialog: true,
          ),
        )
        .then((_) => _lockShowing = false);
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(themeService.textScale),
      ),
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Smart Spend',
        themeMode: themeService.themeMode,
        theme: themeService.lightTheme,
        darkTheme: themeService.darkTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
