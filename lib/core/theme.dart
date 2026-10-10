import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF2E5BFF);
  static const primaryDark = Color(0xFF1B3FBF);
  static const bg = Color(0xFFF5F7FB);
  static const text = Color(0xFF1C2340);
  static const muted = Color(0xFF8A92A6);
  static const border = Color(0xFFE3E7F0);
  static const success = Color(0xFF22B573);
  static const danger = Color(0xFFE5484D);
  static const warning = Color(0xFFF5A524);
}

ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    scaffoldBackgroundColor: AppColors.bg,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      foregroundColor: AppColors.text,
      titleTextStyle: TextStyle(
        color: AppColors.text,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
