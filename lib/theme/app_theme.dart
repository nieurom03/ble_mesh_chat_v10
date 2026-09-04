import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  AppTheme
//  Tailwind-inspired design tokens for Flutter.
//  Use AppSpacing, AppRadius, AppTextStyle,
//  and AppColors throughout the app for
//  consistent, easy-to-maintain styling.
// ─────────────────────────────────────────────

// Seed color — indigo-600 in Tailwind scale
const _seed = Color(0xFF4F46E5);

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.gray50,
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: AppColors.gray200),
      ),
      color: Colors.white,
      margin: EdgeInsets.zero,
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
    ),
    dividerTheme: DividerThemeData(
      color: AppColors.gray200,
      thickness: 1,
      space: 1,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      indicatorColor: const Color(0xFF4F46E5).withAlpha(20),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 11,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          color: selected ? _seed : AppColors.gray500,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? _seed : AppColors.gray500,
          size: 22,
        );
      }),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: AppColors.gray200,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.gray900,
      ),
      iconTheme: const IconThemeData(color: AppColors.gray700),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.gray100,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.full),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.full),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.full),
        borderSide: const BorderSide(color: _seed, width: 1.5),
      ),
      hintStyle: const TextStyle(color: AppColors.gray400, fontSize: 14),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: _seed,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _seed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
    ),
  );
}

// ── Spacing ── (Tailwind: 4px base unit)
abstract class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double x2l = 48;
}

// ── Border radius ──
abstract class AppRadius {
  static const double sm = 6;
  static const double md = 10;
  static const double lg = 14;
  static const double xl = 20;
  static const double full = 999;
}

// ── Color palette ── (Tailwind gray + indigo)
abstract class AppColors {
  // Grays
  static const gray50 = Color(0xFFF9FAFB);
  static const gray100 = Color(0xFFF3F4F6);
  static const gray200 = Color(0xFFE5E7EB);
  static const gray300 = Color(0xFFD1D5DB);
  static const gray400 = Color(0xFF9CA3AF);
  static const gray500 = Color(0xFF6B7280);
  static const gray600 = Color(0xFF4B5563);
  static const gray700 = Color(0xFF374151);
  static const gray800 = Color(0xFF1F2937);
  static const gray900 = Color(0xFF111827);

  // Indigo
  static const indigo50 = Color(0xFFEEF2FF);
  static const indigo100 = Color(0xFFE0E7FF);
  static const indigo500 = Color(0xFF6366F1);
  static const indigo600 = Color(0xFF4F46E5);
  static const indigo700 = Color(0xFF4338CA);

  // Semantic
  static const green500 = Color(0xFF22C55E);
  static const green100 = Color(0xFFDCFCE7);
  static const green700 = Color(0xFF15803D);
  static const red500 = Color(0xFFEF4444);
  static const red600 = Color(0xFFDC2626);
  static const red100 = Color(0xFFFEE2E2);
  static const red700 = Color(0xFFB91C1C);
  static const amber100 = Color(0xFFFEF3C7);
  static const amber700 = Color(0xFFB45309);
}

// ── Text styles ──
abstract class AppTextStyle {
  static const xs = TextStyle(fontSize: 11, height: 1.4);
  static const sm = TextStyle(fontSize: 12, height: 1.4);
  static const base = TextStyle(fontSize: 14, height: 1.5);
  static const md = TextStyle(fontSize: 15, height: 1.5);
  static const lg = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
  static const xl = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static const labelMuted = TextStyle(
    fontSize: 11,
    color: AppColors.gray400,
    height: 1.4,
  );
  static const bodyMuted = TextStyle(
    fontSize: 13,
    color: AppColors.gray500,
    height: 1.5,
  );
  static const semibold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );
  static const bold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    height: 1.5,
  );
}
