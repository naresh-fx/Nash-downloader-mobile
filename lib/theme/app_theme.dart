import 'package:flutter/material.dart';

/// Colors lifted directly from the desktop app's index.html so the mobile
/// app is a pixel-family match, not just "inspired by".
class NashColors {
  static const background = Color(0xFF000000);
  static const sidebar = Color(0xFF111113);
  static const card = Color(0xFF1C1C1E);
  static const cardAlt = Color(0xFF232325);
  static const inputFill = Color(0xFF2C2C2E);
  static const border = Color(0x0DFFFFFF); // white/[0.05]
  static const borderStrong = Color(0x14FFFFFF); // white/[0.08]
  static const accent = Color(0xFF0A84FF);
  static const accentHover = Color(0xFF0071E3);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB5B5BC);
  static const textMuted = Color(0xFF68686F);
  static const success = Color(0xFF34C759);
  static const danger = Color(0xFFFF453A);
}

class NashTheme {
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: NashColors.background,
      fontFamily: 'SFProText',
      colorScheme: const ColorScheme.dark(
        primary: NashColors.accent,
        surface: NashColors.card,
        background: NashColors.background,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: NashColors.background,
        elevation: 0,
        foregroundColor: NashColors.textPrimary,
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          color: NashColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        bodyMedium: TextStyle(color: NashColors.textPrimary, fontSize: 13),
        bodySmall: TextStyle(color: NashColors.textSecondary, fontSize: 11),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: NashColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: NashColors.sidebar,
        selectedItemColor: NashColors.accent,
        unselectedItemColor: NashColors.textMuted,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
