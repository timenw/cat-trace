import 'package:flutter/material.dart';
import 'app_colors.dart';

/// App 主题配置
class AppTheme {
  AppTheme._();

  // ====== 浅色主题 ======
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryLight,
      secondary: AppColors.secondary,
      secondaryContainer: AppColors.secondaryLight,
      tertiary: AppColors.accent,
      error: AppColors.error,
      surface: AppColors.lightSurface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.lightTextPrimary,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    cardColor: AppColors.lightCard,
    dividerColor: AppColors.lightDivider,

    // 字体
    fontFamily: 'NotoSansSC',
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: AppColors.lightTextPrimary, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: AppColors.lightTextPrimary, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(color: AppColors.lightTextPrimary, fontWeight: FontWeight.bold),
      headlineLarge: TextStyle(color: AppColors.lightTextPrimary, fontWeight: FontWeight.w600),
      headlineMedium: TextStyle(color: AppColors.lightTextPrimary, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(color: AppColors.lightTextPrimary, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: AppColors.lightTextPrimary, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: AppColors.lightTextPrimary, fontWeight: FontWeight.w500),
      titleSmall: TextStyle(color: AppColors.lightTextSecondary, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(color: AppColors.lightTextPrimary),
      bodyMedium: TextStyle(color: AppColors.lightTextPrimary),
      bodySmall: TextStyle(color: AppColors.lightTextSecondary),
      labelLarge: TextStyle(color: AppColors.lightTextPrimary, fontWeight: FontWeight.w500),
      labelMedium: TextStyle(color: AppColors.lightTextSecondary),
      labelSmall: TextStyle(color: AppColors.lightTextHint),
    ),

    // AppBar
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: AppColors.lightBackground,
      foregroundColor: AppColors.lightTextPrimary,
      surfaceTintColor: Colors.transparent,
    ),

    // Card
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.lightCard,
    ),

    // Bottom Navigation
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightSurface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.lightTextHint,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    // FAB
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: CircleBorder(),
    ),

    // Input
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightDivider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    // Button
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.lightCard,
      selectedColor: AppColors.primaryLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      labelStyle: const TextStyle(fontSize: 13),
    ),

    // Dialog
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.lightSurface,
    ),
  );

  // ====== 深色主题 ======
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryDark,
      secondary: AppColors.secondary,
      secondaryContainer: AppColors.secondaryDark,
      tertiary: AppColors.accent,
      error: AppColors.error,
      surface: AppColors.darkSurface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.darkTextPrimary,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    cardColor: AppColors.darkCard,
    dividerColor: AppColors.darkDivider,

    fontFamily: 'NotoSansSC',
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.bold),
      headlineLarge: TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w600),
      headlineMedium: TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w500),
      titleSmall: TextStyle(color: AppColors.darkTextSecondary, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(color: AppColors.darkTextPrimary),
      bodyMedium: TextStyle(color: AppColors.darkTextPrimary),
      bodySmall: TextStyle(color: AppColors.darkTextSecondary),
      labelLarge: TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w500),
      labelMedium: TextStyle(color: AppColors.darkTextSecondary),
      labelSmall: TextStyle(color: AppColors.darkTextHint),
    ),

    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: AppColors.darkBackground,
      foregroundColor: AppColors.darkTextPrimary,
      surfaceTintColor: Colors.transparent,
    ),

    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.darkCard,
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.darkTextHint,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: CircleBorder(),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkDivider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: AppColors.darkCard,
      selectedColor: AppColors.primaryDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      labelStyle: const TextStyle(fontSize: 13),
    ),

    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.darkSurface,
    ),
  );
}
