import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager extends ChangeNotifier {
  static final ThemeManager instance = ThemeManager._internal();
  factory ThemeManager() => instance;
  ThemeManager._internal();

  static const String THEME_KEY = "APP_THEME_MODE_KEY";
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString(THEME_KEY);
    if (savedMode == "dark") {
      _themeMode = ThemeMode.dark;
    } else if (savedMode == "light") {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (mode == ThemeMode.dark) {
      await prefs.setString(THEME_KEY, "dark");
    } else if (mode == ThemeMode.light) {
      await prefs.setString(THEME_KEY, "light");
    } else {
      await prefs.setString(THEME_KEY, "system");
    }
  }
}

final themeManager = ThemeManager();
