import 'package:flutter/material.dart';

/// Central place for every colour, spacing step, radius, shadow and the
/// Material 3 [ThemeData] used across CarZen. Screens should read from here
/// instead of hard-coding values, so the whole app can be re-skinned (or a
/// dark theme added) without touching widget code.
///
/// Direction: a clean, light canvas; deep navy for text and navigation; the
/// blue/cyan of the CarZen logo for interactive accents; and a warm amber used
/// very sparingly (highlights such as a "popular" ribbon).
class AppColors {
  AppColors._();

  // ---- Brand -------------------------------------------------------------
  /// Deep automotive navy. Navigation, headings, primary buttons.
  static const Color primary = Color(0xFF0B1F3A);

  /// Slightly deeper navy used for gradients and the dark hero surfaces.
  static const Color primaryDeep = Color(0xFF06142A);

  /// Lifted navy used for hover/pressed states on dark surfaces.
  static const Color primarySoft = Color(0xFF16345C);

  /// Logo blue/cyan, tuned to stay readable as text on a white surface.
  static const Color secondary = Color(0xFF0B7FB8);

  /// Bright cyan from the logo glow — for highlights on *dark* surfaces and
  /// for accent buttons (navy text on cyan has strong contrast).
  static const Color cyan = Color(0xFF2CC4F0);

  /// Pale cyan tint for selected rows, chips and icon wells.
  static const Color cyanTint = Color(0xFFE6F6FD);

  /// Warm accent. Use sparingly.
  static const Color warm = Color(0xFFF2A33A);

  // ---- Surfaces & text ---------------------------------------------------
  static const Color background = Color(0xFFF4F7FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFEDF2F8);
  static const Color divider = Color(0xFFDDE5EF);
  static const Color textPrimary = Color(0xFF0F1B2D);
  static const Color textSecondary = Color(0xFF5A6B80);
  static const Color textOnDark = Color(0xFFFFFFFF);
  static const Color textOnDarkMuted = Color(0xFFB8C7DA);

  // ---- Feedback ----------------------------------------------------------
  static const Color success = Color(0xFF12A072);
  static const Color warning = Color(0xFFD98A0B);
  static const Color favorite = Color(0xFFE5484D);
  static const Color info = Color(0xFF2F6FDE);
}

/// 4-point spacing scale.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double section = 40;

  /// Horizontal page padding: roomier on larger screens.
  static double pageGutter(double width) => width >= 900 ? 32 : (width >= 600 ? 24 : 16);
}

class AppRadii {
  AppRadii._();

  static const double sm = 10;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 28;
  static const double pill = 999;
}

class AppShadows {
  AppShadows._();

  static List<BoxShadow> get card => [
        BoxShadow(color: const Color(0xFF0B1F3A).withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 6)),
      ];

  static List<BoxShadow> get raised => [
        BoxShadow(color: const Color(0xFF0B1F3A).withValues(alpha: 0.12), blurRadius: 28, offset: const Offset(0, 12)),
      ];
}

class AppTheme {
  AppTheme._();

  static const String _fontFamily = 'Roboto';

  static TextTheme _textTheme() => const TextTheme(
        displaySmall: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          height: 1.1,
          letterSpacing: -1,
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          height: 1.15,
          letterSpacing: -0.6,
        ),
        headlineMedium: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          height: 1.2,
          letterSpacing: -0.4,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          height: 1.25,
          letterSpacing: -0.2,
        ),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        bodyLarge: TextStyle(fontSize: 16, color: AppColors.textPrimary, height: 1.5),
        bodyMedium: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.45),
        bodySmall: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.1),
        labelMedium: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
        labelSmall: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, letterSpacing: 0.2),
      );

  static OutlineInputBorder _border(Color color, [double width = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: BorderSide(color: color, width: width),
      );

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.favorite,
      brightness: Brightness.light,
    );

    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.md));

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: _fontFamily,
      textTheme: _textTheme(),
      dividerColor: AppColors.divider,
      dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1, space: 1),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.secondary,
        linearTrackColor: AppColors.surfaceMuted,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary,
        side: const BorderSide(color: AppColors.divider),
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.pill)),
      ),
      // PrimaryButton / "call to action" buttons: bright logo cyan, navy label.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cyan,
          foregroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.surfaceMuted,
          disabledForegroundColor: AppColors.textSecondary,
          elevation: 0,
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: shape,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.surfaceMuted,
          disabledForegroundColor: AppColors.textSecondary,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
          shape: shape,
          textStyle: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          side: const BorderSide(color: AppColors.divider, width: 1.2),
          shape: shape,
          textStyle: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.secondary,
          shape: shape,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: AppColors.textPrimary),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.cyan,
        foregroundColor: AppColors.primary,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
        extendedTextStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        border: _border(AppColors.divider),
        enabledBorder: _border(AppColors.divider),
        focusedBorder: _border(AppColors.secondary, 1.6),
        errorBorder: _border(AppColors.favorite),
        focusedErrorBorder: _border(AppColors.favorite, 1.6),
        disabledBorder: _border(AppColors.divider),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          side: const BorderSide(color: AppColors.divider),
        ),
      ),
      listTileTheme: const ListTileThemeData(iconColor: AppColors.primary),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
        titleTextStyle: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl))),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
        contentTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.cyanTint,
        height: 66,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 11.5,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w800 : FontWeight.w600,
            color: states.contains(WidgetState.selected) ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected) ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.md))),
          side: const WidgetStatePropertyAll(BorderSide(color: AppColors.divider)),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}
