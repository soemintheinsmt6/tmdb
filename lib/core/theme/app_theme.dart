import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/core/theme/app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => _build(Brightness.light);
  static ThemeData get darkTheme => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    final fontFamily = GoogleFonts.plusJakartaSans().fontFamily;

    final textTheme = TextTheme(
      displayLarge: AppTypography.pageTitle,
      titleLarge: AppTypography.sectionTitle,
      titleMedium: AppTypography.subTitle,
      bodyLarge: AppTypography.bodyLarge,
      bodyMedium: AppTypography.bodyText,
      bodySmall: AppTypography.smallText.copyWith(color: colors.textSecondary),
      labelSmall: AppTypography.labelSmall.copyWith(color: colors.textSecondary),
      labelLarge: AppTypography.buttonLabel.copyWith(color: AppColors.cyan),
    ).apply(
      bodyColor: colors.textPrimary,
      displayColor: colors.textPrimary,
      fontFamily: fontFamily,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: colors.background,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: AppColors.cyan,
        onPrimary: AppColors.navy,
        primaryContainer: AppColors.navy,
        onPrimaryContainer: AppColors.white,
        secondary: AppColors.green,
        onSecondary: AppColors.navy,
        secondaryContainer: AppColors.navyDark,
        onSecondaryContainer: AppColors.white,
        surface: colors.surface,
        onSurface: colors.textPrimary,
        surfaceContainerHighest: colors.surfaceMuted,
        error: AppColors.error,
        onError: AppColors.white,
        outline: colors.border,
        outlineVariant: colors.divider,
      ),
      // ── AppBar ────────────────────────────────────────
      // Navy app bar in both modes — the brand band stays consistent.
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.white),
        titleTextStyle: AppTypography.subTitle.copyWith(
          fontFamily: fontFamily,
          color: AppColors.white,
          fontSize: 20,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      textTheme: textTheme,
      // ── ElevatedButton ────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cyan,
          foregroundColor: AppColors.navy,
          textStyle: AppTypography.buttonLabel.copyWith(
            fontFamily: fontFamily,
            color: AppColors.navy,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      // ── OutlinedButton ────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.cyan,
          textStyle: AppTypography.buttonLabel.copyWith(
            fontFamily: fontFamily,
            color: AppColors.cyan,
          ),
          side: const BorderSide(color: AppColors.cyan, width: 1.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      // ── TextButton ────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.cyan,
          textStyle: AppTypography.buttonLabel.copyWith(
            fontFamily: fontFamily,
            color: AppColors.cyan,
          ),
        ),
      ),
      // ── Input / TextField ─────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.cyan, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: AppTypography.bodyText.copyWith(color: colors.textMuted),
        labelStyle: AppTypography.bodyText.copyWith(
          color: colors.textSecondary,
        ),
        prefixIconColor: colors.textMuted,
        suffixIconColor: colors.textMuted,
      ),
      // ── Card ──────────────────────────────────────────
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      // ── Chip ──────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceMuted,
        selectedColor: AppColors.cyan,
        labelStyle: AppTypography.smallText.copyWith(
          color: colors.textPrimary,
        ),
        secondaryLabelStyle: AppTypography.smallText.copyWith(
          color: AppColors.navy,
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide.none,
        shape: const StadiumBorder(),
      ),
      // ── TabBar ───────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelStyle: AppTypography.bodyText.copyWith(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTypography.bodyText.copyWith(
          fontFamily: fontFamily,
        ),
        labelColor: AppColors.cyan,
        unselectedLabelColor: colors.textSecondary,
        indicatorColor: AppColors.cyan,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: colors.divider,
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
      ),
      // ── Divider ───────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: colors.divider,
        thickness: 1,
        space: 1,
      ),
      // ── SnackBar ──────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.surfaceMuted,
        contentTextStyle: AppTypography.bodyText.copyWith(
          color: colors.textPrimary,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
