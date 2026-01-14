import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider del tema de la aplicación
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

/// Notifier para manejar el tema de la aplicación
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light) {
    _loadTheme();
  }

  static const String _themeKey = 'theme_mode';

  /// Carga el tema guardado desde SharedPreferences
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_themeKey) ?? false;
      state = isDark ? ThemeMode.dark : ThemeMode.light;
    } catch (e) {
      // Si hay error, mantener tema claro por defecto
      state = ThemeMode.light;
    }
  }

  /// Cambia el tema y guarda la preferencia
  Future<void> toggleTheme() async {
    try {
      final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
      state = newMode;

      // Guardar en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, newMode == ThemeMode.dark);
    } catch (e) {
      // Si hay error, solo cambiar el estado sin guardar
      state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    }
  }

  /// Establece el tema específico
  Future<void> setTheme(ThemeMode mode) async {
    try {
      state = mode;

      // Guardar en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, mode == ThemeMode.dark);
    } catch (e) {
      // Si hay error, solo cambiar el estado
      state = mode;
    }
  }

  /// Verifica si el tema actual es oscuro
  bool get isDarkMode => state == ThemeMode.dark;
}
