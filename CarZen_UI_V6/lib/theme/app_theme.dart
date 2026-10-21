import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

/// CarZen design system: colour, type, spacing, radii, elevation and the
/// Material 3 [ThemeData]. Screens read from here instead of hard-coding
/// values.
///
/// Direction
/// * Blue-ink (from the logo's navy) carries text, primary actions and the
///   admin console. A cool grey canvas keeps car photos the most colourful
///   thing on screen.
/// * Chrome blue (the logo's cyan, deepened for contrast) is the interactive
///   colour: links, focus, selection.
/// * Plate yellow - the colour of Indian commercial number plates - is the
///   single highlight, used for at most one call to action per screen.
/// * Status is always a word plus a colour, never colour alone.
class AppColors {
  AppColors._();

  // ---- Brand -------------------------------------------------------------
  /// Blue-ink. Text, primary buttons, dark surfaces.
  static const Color ink = Color(0xFF0F1C2E);
  static const Color inkDeep = Color(0xFF0A1422);
  static const Color inkSoft = Color(0xFF22344D);

  /// Chrome blue: links, focus rings, selected states on light surfaces.
  static const Color chrome = Color(0xFF0B6FA4);

  /// Bright chrome for accents on dark surfaces only.
  static const Color chromeBright = Color(0xFF4CC3F0);

  /// Pale chrome tint for selected rows, chips and icon wells.
  static const Color chromeTint = Color(0xFFE8F3FA);

  /// Plate yellow - the one highlight colour.
  static const Color plate = Color(0xFFFFC629);
  static const Color plateTint = Color(0xFFFFF4D1);

  // ---- Surfaces & text ---------------------------------------------------
  static const Color background = Color(0xFFF2F4F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFEEF1F5);
  static const Color divider = Color(0xFFE0E5EC);
  static const Color lineStrong = Color(0xFFC6CFDA);
  static const Color textPrimary = ink;
  static const Color textSecondary = Color(0xFF55647A);
  static const Color textTertiary = Color(0xFF6E7C90);
  static const Color textOnDark = Color(0xFFFFFFFF);
  static const Color textOnDarkMuted = Color(0xFFB4C2D4);

  // ---- Feedback ----------------------------------------------------------
  static const Color success = Color(0xFF11845B);
  static const Color successTint = Color(0xFFE3F4EC);
  static const Color warning = Color(0xFFB26A00);
  static const Color warningTint = Color(0xFFFFF1DC);
  static const Color danger = Color(0xFFC62F3B);
  static const Color dangerTint = Color(0xFFFCE8EA);
  static const Color info = Color(0xFF2563C9);

  // ---- Legacy aliases (kept so older widgets keep compiling) -------------
  static const Color primary = ink;
  static const Color primaryDeep = inkDeep;
  static const Color primarySoft = inkSoft;
  static const Color secondary = chrome;
  static const Color cyan = chromeBright;
  static const Color cyanTint = chromeTint;
  static const Color warm = plate;
  static const Color favorite = danger;
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
  static const double section = 48;

  /// Horizontal page padding: roomier on larger screens, compact on phones.
  static double pageGutter(double width) =>
      width >= 1200 ? 40 : (width >= 900 ? 32 : (width >= 600 ? 24 : (width < 360 ? 12 : 16)));
}

/// Radii follow hierarchy: controls < cards < panels. Pills only for chips.
class AppRadii {
  AppRadii._();

  static const double xs = 6;
  static const double sm = 10;
  static const double md = 12;
  static const double lg = 14;
  static const double xl = 20;
  static const double pill = 999;
}

/// Elevation is reserved for things that float (menus, sheets, sticky bars,
/// hovered cards). Resting cards use a hairline border instead.
class AppShadows {
  AppShadows._();

  static List<BoxShadow> get card => const [
        BoxShadow(color: Color(0x0A0F1C2E), blurRadius: 2, offset: Offset(0, 1)),
      ];

  static List<BoxShadow> get raised => const [
        BoxShadow(color: Color(0x140F1C2E), blurRadius: 24, offset: Offset(0, 10)),
        BoxShadow(color: Color(0x0A0F1C2E), blurRadius: 4, offset: Offset(0, 1)),
      ];

  static List<BoxShadow> get floating => const [
        BoxShadow(color: Color(0x290F1C2E), blurRadius: 32, offset: Offset(0, 14)),
      ];
}

/// Type helpers. Archivo for interface text; the wide Archivo Expanded cut
/// for headings, prices and other "badge" text.
class AppText {
  AppText._();

  static const String body = 'Archivo';
  static const String display = 'ArchivoExpanded';

  static const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

  /// Display/heading style in the wide cut.
  static TextStyle heading(double size, {FontWeight weight = FontWeight.w700, Color color = AppColors.textPrimary, double height = 1.15}) =>
      TextStyle(
        fontFamily: display,
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: size >= 28 ? -0.6 : -0.2,
      );

  /// Prices and other figures that should line up.
  static TextStyle price(double size, {Color color = AppColors.textPrimary, FontWeight weight = FontWeight.w700}) => TextStyle(
        fontFamily: display,
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: 1.1,
        letterSpacing: -0.3,
        fontFeatures: _tabular,
      );

  /// Tabular body figures (tables, counters).
  static TextStyle figures(double size, {FontWeight weight = FontWeight.w600, Color color = AppColors.textPrimary}) =>
      TextStyle(fontFamily: body, fontSize: size, fontWeight: weight, color: color, fontFeatures: _tabular);
}

class AppTheme {
  AppTheme._();

  static TextTheme _textTheme() => const TextTheme(
        displayLarge: TextStyle(fontFamily: AppText.display, fontSize: 52, fontWeight: FontWeight.w800, height: 1.04, letterSpacing: -1.4, color: AppColors.textPrimary),
        displayMedium: TextStyle(fontFamily: AppText.display, fontSize: 42, fontWeight: FontWeight.w800, height: 1.06, letterSpacing: -1.1, color: AppColors.textPrimary),
        displaySmall: TextStyle(fontFamily: AppText.display, fontSize: 34, fontWeight: FontWeight.w800, height: 1.1, letterSpacing: -0.8, color: AppColors.textPrimary),
        headlineLarge: TextStyle(fontFamily: AppText.display, fontSize: 30, fontWeight: FontWeight.w700, height: 1.15, letterSpacing: -0.6, color: AppColors.textPrimary),
        headlineMedium: TextStyle(fontFamily: AppText.display, fontSize: 25, fontWeight: FontWeight.w700, height: 1.2, letterSpacing: -0.4, color: AppColors.textPrimary),
        headlineSmall: TextStyle(fontFamily: AppText.display, fontSize: 20, fontWeight: FontWeight.w700, height: 1.25, letterSpacing: -0.2, color: AppColors.textPrimary),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, height: 1.3, color: AppColors.textPrimary),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, height: 1.35, color: AppColors.textPrimary),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, height: 1.35, color: AppColors.textPrimary),
        bodyLarge: TextStyle(fontSize: 16, height: 1.55, color: AppColors.textPrimary),
        bodyMedium: TextStyle(fontSize: 14, height: 1.5, color: AppColors.textPrimary),
        bodySmall: TextStyle(fontSize: 12.5, height: 1.45, color: AppColors.textSecondary),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
        labelMedium: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
        labelSmall: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, letterSpacing: 0.1),
      );

  static OutlineInputBorder _border(Color color, [double width = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.sm),
        borderSide: BorderSide(color: color, width: width),
      );

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.ink,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.ink,
      onPrimary: Colors.white,
      primaryContainer: AppColors.chromeTint,
      onPrimaryContainer: AppColors.ink,
      secondary: AppColors.chrome,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.chromeTint,
      onSecondaryContainer: AppColors.ink,
      tertiary: AppColors.plate,
      onTertiary: AppColors.ink,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      surfaceContainerLowest: AppColors.surface,
      surfaceContainerLow: AppColors.background,
      surfaceContainer: AppColors.surfaceMuted,
      surfaceContainerHigh: AppColors.surfaceMuted,
      surfaceContainerHighest: AppColors.divider,
      outline: AppColors.lineStrong,
      outlineVariant: AppColors.divider,
      error: AppColors.danger,
      onError: Colors.white,
    );

    final controlShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.sm));
    const buttonText = TextStyle(fontFamily: AppText.body, fontSize: 14.5, fontWeight: FontWeight.w600, letterSpacing: 0.1);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: AppText.body,
      textTheme: _textTheme(),
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      splashFactory: InkRipple.splashFactory,
      focusColor: AppColors.chrome.withValues(alpha: 0.14),
      hoverColor: AppColors.ink.withValues(alpha: 0.04),
      dividerColor: AppColors.divider,
      dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1, space: 1),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.chrome,
        linearTrackColor: AppColors.surfaceMuted,
        circularTrackColor: Colors.transparent,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(fontFamily: AppText.body, fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.ink),
        iconTheme: IconThemeData(color: AppColors.ink),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.ink,
        secondarySelectedColor: AppColors.ink,
        checkmarkColor: Colors.white,
        side: const BorderSide(color: AppColors.lineStrong),
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        secondaryLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.pill)),
      ),
      // Accent call-to-action: plate yellow with ink label (one per screen).
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.plate,
          foregroundColor: AppColors.ink,
          disabledBackgroundColor: AppColors.surfaceMuted,
          disabledForegroundColor: AppColors.textTertiary,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 22),
          shape: controlShape,
          textStyle: buttonText.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      // Primary action: ink.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.surfaceMuted,
          disabledForegroundColor: AppColors.textTertiary,
          minimumSize: const Size(64, 46),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: controlShape,
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          backgroundColor: AppColors.surface,
          disabledForegroundColor: AppColors.textTertiary,
          minimumSize: const Size(64, 46),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          side: const BorderSide(color: AppColors.lineStrong),
          shape: controlShape,
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.chrome,
          minimumSize: const Size(48, 44),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          shape: controlShape,
          textStyle: buttonText,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.ink,
          minimumSize: const Size(44, 44),
          shape: controlShape,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.ink,
        foregroundColor: Colors.white,
        elevation: 3,
        focusElevation: 3,
        hoverElevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
        extendedTextStyle: buttonText,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        isDense: false,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 14.5),
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14.5),
        floatingLabelStyle: const TextStyle(color: AppColors.chrome, fontWeight: FontWeight.w600),
        helperStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
        errorStyle: const TextStyle(color: AppColors.danger, fontSize: 12.5, fontWeight: FontWeight.w500),
        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
        border: _border(AppColors.lineStrong),
        enabledBorder: _border(AppColors.lineStrong),
        focusedBorder: _border(AppColors.chrome, 2),
        errorBorder: _border(AppColors.danger),
        focusedErrorBorder: _border(AppColors.danger, 2),
        disabledBorder: _border(AppColors.divider),
      ),
      dropdownMenuTheme: const DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(AppColors.surface),
          surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
        ),
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
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.textSecondary,
        textColor: AppColors.textPrimary,
        titleTextStyle: TextStyle(fontFamily: AppText.body, fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        subtitleTextStyle: TextStyle(fontFamily: AppText.body, fontSize: 13, color: AppColors.textSecondary, height: 1.4),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.ink : null),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.ink : AppColors.textSecondary),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? Colors.white : AppColors.textSecondary),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.success : AppColors.surfaceMuted),
        trackOutlineColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.success : AppColors.lineStrong),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.ink,
        inactiveTrackColor: AppColors.divider,
        thumbColor: AppColors.ink,
        overlayColor: Color(0x1F0F1C2E),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.xl)),
        titleTextStyle: const TextStyle(fontFamily: AppText.display, fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        contentTextStyle: const TextStyle(fontFamily: AppText.body, fontSize: 14.5, height: 1.5, color: AppColors.textSecondary),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: Color(0x8C0A1422),
        showDragHandle: true,
        dragHandleColor: AppColors.lineStrong,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl))),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        actionTextColor: AppColors.plate,
        contentTextStyle: const TextStyle(fontFamily: AppText.body, color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
        width: null,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: const Color(0x330F1C2E),
        textStyle: const TextStyle(fontFamily: AppText.body, fontSize: 14, color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: const BorderSide(color: AppColors.divider),
        ),
      ),
      menuTheme: const MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(AppColors.surface),
          surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.chromeTint,
        elevation: 0,
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontFamily: AppText.body,
            fontSize: 11.5,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
            color: states.contains(WidgetState.selected) ? AppColors.ink : AppColors.textSecondary,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 23,
            color: states.contains(WidgetState.selected) ? AppColors.ink : AppColors.textSecondary,
          ),
        ),
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: AppColors.ink,
        indicatorColor: AppColors.inkSoft,
        selectedIconTheme: IconThemeData(color: AppColors.plate),
        unselectedIconTheme: IconThemeData(color: AppColors.textOnDarkMuted),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.sm))),
          side: const WidgetStatePropertyAll(BorderSide(color: AppColors.lineStrong)),
          backgroundColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.ink : AppColors.surface),
          foregroundColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? Colors.white : AppColors.textPrimary),
          textStyle: const WidgetStatePropertyAll(TextStyle(fontFamily: AppText.body, fontWeight: FontWeight.w600, fontSize: 13.5)),
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.ink,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.ink,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: AppColors.divider,
        labelStyle: TextStyle(fontFamily: AppText.body, fontWeight: FontWeight.w700, fontSize: 14),
        unselectedLabelStyle: TextStyle(fontFamily: AppText.body, fontWeight: FontWeight.w500, fontSize: 14),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(6)),
        textStyle: const TextStyle(fontFamily: AppText.body, color: Colors.white, fontSize: 12),
        waitDuration: const Duration(milliseconds: 400),
      ),
      badgeTheme: const BadgeThemeData(
        backgroundColor: AppColors.danger,
        textColor: Colors.white,
        textStyle: TextStyle(fontFamily: AppText.body, fontSize: 10.5, fontWeight: FontWeight.w700),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.chrome,
        selectionColor: AppColors.chrome.withValues(alpha: 0.22),
        selectionHandleColor: AppColors.chrome,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(AppColors.ink.withValues(alpha: 0.25)),
        radius: const Radius.circular(8),
        thickness: const WidgetStatePropertyAll(6),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
