import 'dart:math' as math;

import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// The CarZen mark and wordmark, drawn as vectors so they stay crisp at any
/// size and work on light and dark surfaces. The mark keeps the identity of
/// the original badge: the "CZ" monogram under a car's roofline.
class AppLogo extends StatelessWidget {
  final double height;
  final VoidCallback? onTap;

  /// Light text for dark surfaces.
  final bool onDark;

  /// Only the square mark (no wordmark) - for tight spaces.
  final bool markOnly;

  const AppLogo({super.key, this.height = 34, this.onTap, this.onDark = false, this.markOnly = false});

  @override
  Widget build(BuildContext context) {
    final mark = SizedBox(
      width: height,
      height: height,
      child: CustomPaint(painter: _MarkPainter(onDark: onDark)),
    );
    final logo = Semantics(
      label: 'CarZen home',
      button: onTap != null,
      excludeSemantics: true,
      child: markOnly
          ? mark
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                mark,
                SizedBox(width: height * 0.28),
                Text(
                  'CarZen',
                  style: TextStyle(
                    fontFamily: AppText.display,
                    fontWeight: FontWeight.w800,
                    fontSize: height * 0.56,
                    letterSpacing: -0.4,
                    height: 1,
                    color: onDark ? Colors.white : AppColors.ink,
                  ),
                ),
              ],
            ),
    );
    if (onTap == null) return logo;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: logo),
    );
  }
}

class _MarkPainter extends CustomPainter {
  final bool onDark;
  _MarkPainter({required this.onDark});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final rect = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(s * 0.26));
    canvas.drawRRect(rect, Paint()..color = onDark ? AppColors.inkSoft : AppColors.ink);

    // Roofline arc in chrome.
    final roof = Path()
      ..moveTo(s * 0.16, s * 0.47)
      ..cubicTo(s * 0.26, s * 0.30, s * 0.40, s * 0.22, s * 0.55, s * 0.23)
      ..cubicTo(s * 0.70, s * 0.24, s * 0.79, s * 0.33, s * 0.86, s * 0.45);
    canvas.drawPath(
      roof,
      Paint()
        ..color = AppColors.chromeBright
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.065
        ..strokeCap = StrokeCap.round,
    );

    final stroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.09
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // "C"
    final c = Path()
      ..addArc(Rect.fromCircle(center: Offset(s * 0.33, s * 0.64), radius: s * 0.15), math.pi * 0.28, math.pi * 1.44);
    canvas.drawPath(c, stroke);

    // "Z"
    final z = Path()
      ..moveTo(s * 0.55, s * 0.51)
      ..lineTo(s * 0.80, s * 0.51)
      ..lineTo(s * 0.55, s * 0.78)
      ..lineTo(s * 0.81, s * 0.78);
    canvas.drawPath(z, stroke);
  }

  @override
  bool shouldRepaint(covariant _MarkPainter oldDelegate) => oldDelegate.onDark != onDark;
}
