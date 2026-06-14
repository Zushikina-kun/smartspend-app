import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Available app color themes
enum AppTheme {
  blue,
  lightBlue,
  green,
  purple,
  orange,
}

extension AppThemeExtension on AppTheme {
  String get label {
    switch (this) {
      case AppTheme.blue:
        return 'Ocean Blue';
      case AppTheme.lightBlue:
        return 'Sky Blue';
      case AppTheme.green:
        return 'Forest Green';
      case AppTheme.purple:
        return 'Royal Purple';
      case AppTheme.orange:
        return 'Sunset Orange';
    }
  }

  Color get seedColor {
    switch (this) {
      case AppTheme.blue:
        return const Color(0xFF0066FF);
      case AppTheme.lightBlue:
        return const Color(0xFF0099DD);
      case AppTheme.green:
        return const Color(0xFF00875A);
      case AppTheme.purple:
        return const Color(0xFF6B21A8);
      case AppTheme.orange:
        return const Color(0xFFE65100);
    }
  }

  Color get primaryColor {
    switch (this) {
      case AppTheme.blue:
        return const Color(0xFF0066FF);
      case AppTheme.lightBlue:
        return const Color(0xFF0099DD);
      case AppTheme.green:
        return const Color(0xFF00875A);
      case AppTheme.purple:
        return const Color(0xFF6B21A8);
      case AppTheme.orange:
        return const Color(0xFFE65100);
    }
  }

  String get key {
    switch (this) {
      case AppTheme.blue:
        return 'blue';
      case AppTheme.lightBlue:
        return 'light_blue';
      case AppTheme.green:
        return 'green';
      case AppTheme.purple:
        return 'purple';
      case AppTheme.orange:
        return 'orange';
    }
  }

  static AppTheme fromKey(String key) {
    switch (key) {
      case 'light_blue':
        return AppTheme.lightBlue;
      case 'green':
        return AppTheme.green;
      case 'purple':
        return AppTheme.purple;
      case 'orange':
        return AppTheme.orange;
      default:
        return AppTheme.blue;
    }
  }
}

class ThemeService extends ChangeNotifier {
  static const _darkKey = 'dark_mode';
  static const _themeKey = 'app_theme';
  static const _textScaleKey = 'text_scale';
  static const _highContrastKey = 'high_contrast';
  static const _compactKey = 'compact_mode';

  bool _isDark = false;
  AppTheme _appTheme = AppTheme.blue;
  double _textScale = 1.0; // 1.0 = normal, 1.15 = large, 1.3 = extra large
  bool _highContrast = false;
  bool _compactMode = false;

  bool get isDark => _isDark;
  AppTheme get appTheme => _appTheme;
  double get textScale => _textScale;
  bool get highContrast => _highContrast;
  bool get compactMode => _compactMode;
  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  /// The primary color for the current theme — use this instead of hardcoded 0xFF0066FF
  Color get primaryColor => _appTheme.primaryColor;

  ThemeService() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool(_darkKey) ?? false;
    final themeKey = prefs.getString(_themeKey) ?? 'blue';
    _appTheme = AppThemeExtension.fromKey(themeKey);
    _textScale = prefs.getDouble(_textScaleKey) ?? 1.0;
    _highContrast = prefs.getBool(_highContrastKey) ?? false;
    _compactMode = prefs.getBool(_compactKey) ?? false;
    notifyListeners();
  }

  Future<void> toggle() async {
    _isDark = !_isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkKey, _isDark);
    notifyListeners();
  }

  Future<void> setTheme(AppTheme theme) async {
    _appTheme = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme.key);
    notifyListeners();
  }

  Future<void> setTextScale(double scale) async {
    _textScale = scale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_textScaleKey, scale);
    notifyListeners();
  }

  Future<void> setHighContrast(bool enabled) async {
    _highContrast = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_highContrastKey, enabled);
    notifyListeners();
  }

  Future<void> setCompactMode(bool enabled) async {
    _compactMode = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_compactKey, enabled);
    notifyListeners();
  }

  String get textScaleLabel {
    if (_textScale <= 1.0) return 'Normal';
    if (_textScale <= 1.15) return 'Large';
    return 'Extra Large';
  }

  ThemeData get lightTheme => ThemeData(
        colorScheme: _highContrast
            ? const ColorScheme.light(
                primary: Colors.black,
                onPrimary: Colors.white,
                secondary: Colors.black,
                surface: Colors.white,
                onSurface: Colors.black,
              )
            : ColorScheme.fromSeed(seedColor: _appTheme.seedColor),
        useMaterial3: true,
        fontFamily: 'Roboto',
        visualDensity:
            _compactMode ? VisualDensity.compact : VisualDensity.standard,
      );

  ThemeData get darkTheme => ThemeData(
        colorScheme: _highContrast
            ? const ColorScheme.dark(
                primary: Colors.white,
                onPrimary: Colors.black,
                secondary: Colors.white,
                surface: Colors.black,
                onSurface: Colors.white,
              )
            : ColorScheme.fromSeed(
                seedColor: _appTheme.seedColor,
                brightness: Brightness.dark,
              ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        visualDensity:
            _compactMode ? VisualDensity.compact : VisualDensity.standard,
      );
}
