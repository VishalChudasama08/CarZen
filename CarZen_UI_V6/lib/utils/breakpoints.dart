import 'package:flutter/widgets.dart';

/// Single source of truth for responsive layout decisions.
///
/// * compact  (< 600)      phones (portrait)
/// * medium   (600-1023)   large phones in landscape, tablets in portrait
/// * expanded (>= 1024)    tablets in landscape, laptops, desktops
/// * large    (>= 1360)    wide desktops
///
/// Layouts are chosen from the width actually available, not the device
/// type, so split screens, browser zoom and resized windows behave.
class Breakpoints {
  Breakpoints._();

  static const double medium = 600;
  static const double expanded = 1024;
  static const double large = 1360;
  static const double narrow = 360;

  /// Width from which the top bar can carry the main links inline.
  static const double inlineNav = 760;

  /// Widest a page's content column should get.
  static const double maxContentWidth = 1280;

  static double widthOf(BuildContext context) => MediaQuery.sizeOf(context).width;

  static bool isExpanded(BuildContext context) => widthOf(context) >= expanded;
  static bool isLarge(BuildContext context) => widthOf(context) >= large;
  static bool isCompact(BuildContext context) => widthOf(context) < medium;
  static bool isNarrow(BuildContext context) => widthOf(context) < narrow;
  static bool isMedium(BuildContext context) {
    final w = widthOf(context);
    return w >= medium && w < expanded;
  }

  static bool hasInlineNav(BuildContext context) => widthOf(context) >= inlineNav;

  /// Number of grid columns for cards of at least [minTile] logical pixels.
  static int columnsFor(double available, {double minTile = 260, int max = 4}) {
    final c = (available / minTile).floor();
    return c.clamp(1, max);
  }
}
