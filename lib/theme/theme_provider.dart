import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;

  bool get isDark => _isDark;

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }

  // ================= LIGHT THEME =================

  ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: Colors.white,

      colorScheme: base.colorScheme.copyWith(
        primary: const Color(0xFF22C55E),
        secondary: const Color(0xFF38BDF8),
        surface: Colors.white,
      ),

      // APPBAR
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF020617),
        elevation: 0,
      ),

      // CARD (FIXED)
      cardTheme: base.cardTheme.copyWith(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // FAB
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF22C55E),
        foregroundColor: Colors.white,
      ),
    );
  }

  // ================= DARK THEME =================

  ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF020617),

      colorScheme: base.colorScheme.copyWith(
        primary: const Color(0xFF22C55E),
        secondary: const Color(0xFF38BDF8),
        surface: const Color(0xFF020617),
      ),

      // APPBAR
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF020617),
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      // CARD (FIXED)
      cardTheme: base.cardTheme.copyWith(
        color: const Color(0xFF020617),
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // FAB
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF22C55E),
        foregroundColor: Colors.white,
      ),
    );
  }
}
