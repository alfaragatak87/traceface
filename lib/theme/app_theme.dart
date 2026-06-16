// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║  FILE: lib/theme/app_theme.dart                                              ║
// ║                                                                              ║
// ║  DESKRIPSI:                                                                  ║
// ║  Kamus sentral (*Single Source of Truth*) untuk seluruh konfigurasi visual   ║
// ║  dan estetika UI aplikasi TraceFace. Meliputi palet warna, gradien modern,   ║
// ║  serta pengaturan tema material bawaan Flutter.                              ║
// ║                                                                              ║
// ║  KONEKSI & RELASI:                                                           ║
// ║  - Diimpor oleh `main.dart` untuk menginisialisasi `MaterialApp(theme)`.     ║
// ║  - Diimpor oleh hampir seluruh file di dalam folder `pages/` dan `widgets/`. ║
// ║                                                                              ║
// ║  BARIS KODE PENTING:                                                         ║
// ║  - `AppColors` : Menyimpan warna statis (misal: `primary`, `background`).    ║
// ║  - `AppGradients` : Menyimpan efek gradien (*glassmorphism*, warna dinamis). ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

import 'package:flutter/material.dart';

// ──────────────────────────────────────────────────────────────
//  PALET WARNA UTAMA — Tema Biru Indigo Modern
// ──────────────────────────────────────────────────────────────
class AppColors {
  AppColors._();

  // === WARNA UTAMA (Indigo Biru Modern) ===
  static const Color primary      = Color(0xFF2563EB); // Royal Blue
  static const Color primaryDark  = Color(0xFF1D4ED8); // Deeper Blue
  static const Color primaryLight = Color(0xFF3B82F6); // Lighter Blue
  static const Color primaryXLight = Color(0xFFEFF6FF); // Ultra Light Blue

  // === BACKGROUND & SURFACE ===
  static const Color background  = Color(0xFFF8FAFC); // Slate-50
  static const Color surface     = Color(0xFFFFFFFF);
  static const Color surfaceGrey = Color(0xFFF1F5F9); // Slate-100

  // === TEKS ===
  static const Color textPrimary   = Color(0xFF0F172A); // Slate-900
  static const Color textSecondary = Color(0xFF64748B); // Slate-500
  static const Color textHint      = Color(0xFFCBD5E1); // Slate-300

  // === STATUS KASUS ===
  static const Color success      = Color(0xFF059669); // Emerald-600
  static const Color successLight = Color(0xFFD1FAE5); // Emerald-100
  static const Color warning      = Color(0xFFD97706); // Amber-600
  static const Color warningLight = Color(0xFFFEF3C7); // Amber-100
  static const Color info         = Color(0xFF0284C7); // Sky-600
  static const Color infoLight    = Color(0xFFE0F2FE); // Sky-100
  static const Color danger       = Color(0xFFDC2626); // Red-600
  static const Color dangerLight  = Color(0xFFFEE2E2); // Red-100

  // === BORDER & DIVIDER ===
  static const Color border  = Color(0xFFE2E8F0); // Slate-200
  static const Color divider = Color(0xFFF1F5F9); // Slate-100
}

// ──────────────────────────────────────────────────────────────
//  GRADIENT
// ──────────────────────────────────────────────────────────────
class AppGradients {
  AppGradients._();

  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
  );

  static const LinearGradient hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.6, 1.0],
    colors: [Color(0xFF1E3A8A), Color(0xFF1D4ED8), Color(0xFF2563EB)],
  );

  static const LinearGradient surface = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
  );

  static const List<LinearGradient> avatars = [
    LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF9F67FA)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFF0891B2), Color(0xFF06B6D4)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFF059669), Color(0xFF34D399)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFFD97706), Color(0xFFFBBF24)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFFDC2626), Color(0xFFF87171)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
  ];
}

// ──────────────────────────────────────────────────────────────
//  TYPOGRAPHY
// ──────────────────────────────────────────────────────────────
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle heading1 = TextStyle(
    fontSize: 26, fontWeight: FontWeight.w800,
    color: AppColors.textPrimary, letterSpacing: -0.8,
    height: 1.2,
  );
  static const TextStyle heading2 = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, letterSpacing: -0.4,
  );
  static const TextStyle heading3 = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary, letterSpacing: -0.2,
  );
  static const TextStyle body = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400,
    color: AppColors.textPrimary, height: 1.6,
  );
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w400,
    color: AppColors.textSecondary, height: 1.5,
  );
  static const TextStyle label = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w600,
    color: AppColors.textSecondary, letterSpacing: 0.5,
  );
  static const TextStyle mono = TextStyle(
    fontSize: 12, fontFamily: 'monospace',
    color: AppColors.primary, fontWeight: FontWeight.w600,
  );
}

// ──────────────────────────────────────────────────────────────
//  THEME DATA
// ──────────────────────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',

    colorScheme: const ColorScheme.light(
      primary:   AppColors.primary,
      secondary: AppColors.primaryLight,
      surface:   AppColors.surface,
      error:     AppColors.danger,
      onPrimary: Colors.white,
      onSurface: AppColors.textPrimary,
    ),

    scaffoldBackgroundColor: AppColors.background,

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 2,
      shadowColor: AppColors.border,
      foregroundColor: AppColors.textPrimary,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 18, fontWeight: FontWeight.w700,
        color: AppColors.textPrimary, letterSpacing: -0.3,
      ),
    ),

    // Input field
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceGrey,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.danger, width: 2),
      ),
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      prefixIconColor: AppColors.textSecondary,
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceGrey,
      selectedColor: AppColors.primaryXLight,
      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
    ),

    // SnackBar
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      contentTextStyle: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
      elevation: 8,
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 1,
    ),

    // Dialog
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 20,
      titleTextStyle: const TextStyle(
        fontSize: 18, fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    ),
  );
}