import 'package:flutter/material.dart';

/// Stitch tasarım sistemi ("ProExam Turkish Drive") — Ehliyet Sınav 2026.
///
/// Marka kişiliği: Profesyonel, sakin, motive edici. Yeşil = başarı/doğru/"geç".
/// Font: **Plus Jakarta Sans** (offline gömülü — google_fonts KULLANILMAZ).
class AppColors {
  AppColors._();

  // --- Marka (yeşil) ---
  static const Color primary = Color(0xFF16A34A); // hero yeşil
  static const Color primaryDark = Color(0xFF15803D); // basılı / koyu vurgu
  static const Color greenLight = Color(0xFFF0FDF4); // seçili dolgu
  static const Color greenSoft = Color(0xFFDCFCE7); // ikon chip zemini

  // --- Nötr / yüzey ---
  static const Color background = Color(0xFFF8FAFC); // slate zemin (Level 0)
  static const Color surface = Color(0xFFFFFFFF); // beyaz kart (Level 1)
  static const Color border = Color(0xFFE2E8F0); // kenarlık / ayraç
  static const Color textPrimary = Color(0xFF0F172A); // slate-900
  static const Color textSecondary = Color(0xFF64748B); // slate-500

  // --- Vurgular ---
  static const Color amber = Color(0xFFF59E0B); // seri (ateş) / uyarı
  static const Color error = Color(0xFFDC2626); // yanlış / kaldı

  // --- Koyu tema yüzeyleri ---
  static const Color darkBackground = Color(0xFF0B1220);
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkBorder = Color(0xFF1F2937);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color primaryOnDark = Color(0xFF22C55E);
}

class AppTheme {
  AppTheme._();

  static const String fontFamily = 'Plus Jakarta Sans';

  /// Stitch "Ambient Shadow": 0 2px 8px rgba(15,23,42,0.06).
  /// Kart/Container'larda elle kullanmak için.
  static const List<BoxShadow> softShadow = [
    BoxShadow(
      color: Color(0x0F0F172A), // rgba(15,23,42,0.06)
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// Eski koda uyumluluk (önceden seed kullanılıyordu).
  static const Color seed = AppColors.primary;

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final scheme = ColorScheme(
      brightness: brightness,
      primary: isDark ? AppColors.primaryOnDark : AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.greenSoft,
      onPrimaryContainer: AppColors.primaryDark,
      secondary: isDark ? AppColors.primaryOnDark : AppColors.primary,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.greenSoft,
      onSecondaryContainer: AppColors.primaryDark,
      tertiary: AppColors.amber,
      onTertiary: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: const Color(0xFFFEE2E2),
      onErrorContainer: const Color(0xFF7F1D1D),
      surface: isDark ? AppColors.darkSurface : AppColors.surface,
      onSurface: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
      onSurfaceVariant:
          isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
      outline: isDark ? AppColors.darkBorder : AppColors.border,
      outlineVariant: isDark ? AppColors.darkBorder : AppColors.border,
      surfaceContainerLowest:
          isDark ? AppColors.darkBackground : AppColors.surface,
      surfaceContainerLow:
          isDark ? AppColors.darkSurface : AppColors.background,
      surfaceContainer: isDark ? AppColors.darkSurface : AppColors.background,
      surfaceContainerHigh:
          isDark ? AppColors.darkSurface : AppColors.greenLight,
      surfaceContainerHighest:
          isDark ? AppColors.darkSurface : AppColors.greenLight,
      inverseSurface: isDark ? AppColors.surface : AppColors.textPrimary,
      onInverseSurface: isDark ? AppColors.textPrimary : Colors.white,
    );

    final baseText = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final subText =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    final textTheme = TextTheme(
      headlineLarge: TextStyle(
          fontSize: 24, fontWeight: FontWeight.w700, height: 1.33, color: baseText),
      headlineMedium: TextStyle(
          fontSize: 22, fontWeight: FontWeight.w700, height: 1.27, color: baseText),
      titleLarge: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w600, height: 1.33, color: baseText),
      titleMedium: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600, height: 1.4, color: baseText),
      bodyLarge: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w400, height: 1.5, color: baseText),
      bodyMedium: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w400, height: 1.43, color: baseText),
      bodySmall: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w500, height: 1.33, color: subText),
      labelLarge: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600, height: 1.43, color: baseText),
      labelSmall: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w500, height: 1.33, color: subText),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: fontFamily,
      textTheme: textTheme,
      scaffoldBackgroundColor:
          isDark ? AppColors.darkBackground : AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.background,
        foregroundColor: baseText,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: baseText,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: const Color(0x0F0F172A),
        margin: EdgeInsets.zero,
        // Minimal: kenarlıksız, yumuşak köşeli.
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: scheme.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.greenSoft,
        elevation: 0,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.primaryDark : subText,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: fontFamily,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? AppColors.primaryDark : subText,
          );
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        selectedColor: scheme.primary,
        side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
        shape: const StadiumBorder(),
        labelStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: baseText,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkSurface : AppColors.surface,
        hintStyle: TextStyle(color: subText, fontFamily: fontFamily),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? AppColors.darkBorder : AppColors.border,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: subText,
        textColor: baseText,
      ),
    );
  }
}
