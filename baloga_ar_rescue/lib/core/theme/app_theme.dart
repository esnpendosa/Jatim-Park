import 'package:flutter/material.dart';

class AppColors {
  // Primary palette – dark green jungle feel
  static const Color primary = Color(0xFF1B5E20);
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryGlow = Color(0xFF00E676);

  // Background
  static const Color bgDark = Color(0xFF0A1A0E);
  static const Color bgCard = Color(0xFF122018);
  static const Color bgSurface = Color(0xFF1A2D1F);

  // Accents
  static const Color accentGold = Color(0xFFFFD600);
  static const Color accentBlue = Color(0xFF00B0FF);
  static const Color accentPurple = Color(0xFFCE93D8);

  // Rarity colors
  static const Color rarityCommon = Color(0xFF9E9E9E);
  static const Color rarityRare = Color(0xFF2196F3);
  static const Color rarityEpic = Color(0xFFAB47BC);
  static const Color rarityLegendary = Color(0xFFFFD600);

  // Text
  static const Color textPrimary = Color(0xFFECF5E9);
  static const Color textSecondary = Color(0xFF81C784);
  static const Color textMuted = Color(0xFF558B5A);

  // Status
  static const Color success = Color(0xFF00E676);
  static const Color danger = Color(0xFFFF5252);
  static const Color warning = Color(0xFFFFAB40);
}

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bgDark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.primaryGlow,
      surface: AppColors.bgSurface,
      onPrimary: AppColors.textPrimary,
      onSurface: AppColors.textPrimary,
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Outfit', color: AppColors.textPrimary, fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Outfit',
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 20,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Outfit',
        color: AppColors.textPrimary,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Outfit',
        color: AppColors.textSecondary,
        fontSize: 14,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.bgCard,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bgDark,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.bgCard,
      selectedItemColor: AppColors.primaryGlow,
      unselectedItemColor: AppColors.textMuted,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
  );
}

Color rarityColor(String rarity) {
  switch (rarity) {
    case 'rare':
      return AppColors.rarityRare;
    case 'epic':
      return AppColors.rarityEpic;
    case 'legendary':
      return AppColors.rarityLegendary;
    default:
      return AppColors.rarityCommon;
  }
}

