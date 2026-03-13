import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF0A0A0A);
  static const accent = Color(0xFFE8FF00);
  static const surface = Color(0xFF141414);
  static const card = Color(0xFF1E1E1E);
  static const cardLight = Color(0xFF252525);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF9E9E9E);
  static const textMuted = Color(0xFF616161);
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFFF4444);
  static const warning = Color(0xFFFFB300);
  static const info = Color(0xFF2196F3);
  static const divider = Color(0xFF2A2A2A);
  static const shimmerBase = Color(0xFF1E1E1E);
  static const shimmerHighlight = Color(0xFF2A2A2A);
}

class AppConstants {
  static const String baseUrl = 'http://10.0.2.2:5000/api';
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String appName = 'CarRento';
  static const String appTagline = 'Drive Your Dream';
}

ThemeData appTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.primary,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      background: AppColors.primary,
      error: AppColors.error,
      onPrimary: AppColors.primary,
      onSecondary: AppColors.primary,
      onSurface: AppColors.textPrimary,
      onBackground: AppColors.textPrimary,
    ),
    textTheme: GoogleFonts.spaceGroteskTextTheme().copyWith(
      displayLarge: GoogleFonts.spaceGrotesk(color: AppColors.textPrimary, fontWeight: FontWeight.w800, letterSpacing: -1.5),
      displayMedium: GoogleFonts.spaceGrotesk(color: AppColors.textPrimary, fontWeight: FontWeight.w700, letterSpacing: -1),
      displaySmall: GoogleFonts.spaceGrotesk(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
      headlineLarge: GoogleFonts.spaceGrotesk(color: AppColors.textPrimary, fontWeight: FontWeight.w700, letterSpacing: -0.5),
      headlineMedium: GoogleFonts.spaceGrotesk(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
      headlineSmall: GoogleFonts.spaceGrotesk(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
      titleLarge: GoogleFonts.spaceGrotesk(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.spaceGrotesk(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
      titleSmall: GoogleFonts.spaceGrotesk(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
      bodyLarge: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w400),
      bodyMedium: GoogleFonts.inter(color: AppColors.textSecondary, fontWeight: FontWeight.w400),
      bodySmall: GoogleFonts.inter(color: AppColors.textMuted, fontWeight: FontWeight.w400),
      labelLarge: GoogleFonts.spaceGrotesk(color: AppColors.primary, fontWeight: FontWeight.w700, letterSpacing: 0.5),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.spaceGrotesk(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.primary,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.3),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        minimumSize: const Size(double.infinity, 56),
        side: const BorderSide(color: AppColors.divider, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.accent, width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.error)),
      hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 15),
      labelStyle: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.card,
      selectedColor: AppColors.accent,
      labelStyle: GoogleFonts.spaceGrotesk(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 13),
      side: const BorderSide(color: AppColors.divider),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.accent,
      unselectedItemColor: AppColors.textMuted,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1),
    cardTheme: CardTheme(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
    ),
  );
}
