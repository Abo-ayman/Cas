import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF102B78);
  static const backgroundDeep = Color(0xFF0B225F);
  static const backgroundTop = Color(0xFF1A3B8B);
  static const glass = Color(0x335D82C4);
  static const glassStrong = Color(0x665F86C9);
  static const accent = Color(0xFF58A8FF);
  static const receive = Color(0xFF59C8BE);
  static const send = Color(0xFFB66BC9);
  static const positive = Color(0xFF51D69B);
  static const negative = Color(0xFFFF6666);
  static const white = Colors.white;
}

class AppTheme {
  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'NotoSansArabic',
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accent,
        brightness: Brightness.dark,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
