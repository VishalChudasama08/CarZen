import 'package:flutter/widgets.dart';

/// Single source of truth for responsive layout decisions.
///
/// * compact  (< 600)   phones
/// * medium   (600-899) large phones, small tablets
/// * expanded (>= 900)  tablets in landscape, laptops, Flutter Web
class Breakpoints {
  Breakpoints._();

  static const double medium = 600;
  static const double expanded = 900;

  /// Widest a page's content column should get; keeps lines readable on
  /// very large monitors.
  static const double maxContentWidth = 1200;

  static bool isExpanded(BuildContext context) => MediaQuery.sizeOf(context).width >= expanded;
  static bool isCompact(BuildContext context) => MediaQuery.sizeOf(context).width < medium;
}
