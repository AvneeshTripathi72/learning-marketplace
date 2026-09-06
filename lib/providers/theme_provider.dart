import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _themeKey = 'app_theme_mode_v1';

  ThemeModeNotifier() : super(ThemeMode.light) {
    _loadSavedTheme();
  }

  Future<void> _loadSavedTheme() async {
    try {
      final saved = await _storage.read(key: _themeKey);
      if (saved == 'dark') {
        state = ThemeMode.dark;
      } else if (saved == 'light') {
        state = ThemeMode.light;
      }
    } catch (_) {}
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    try {
      _storage.write(key: _themeKey, value: mode == ThemeMode.dark ? 'dark' : 'light');
    } catch (_) {}
  }

  void toggleTheme() {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setThemeMode(next);
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

