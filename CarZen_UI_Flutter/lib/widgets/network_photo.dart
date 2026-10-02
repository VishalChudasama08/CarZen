import 'package:flutter/material.dart';
import 'package:carzen_flutter/theme/app_theme.dart';

/// A network photo with a branded placeholder while loading and a friendly
/// fallback when the URL is missing or fails to load. The parent decides the
/// size (wrap in [AspectRatio] / [SizedBox]).
class NetworkPhoto extends StatelessWidget {
  final String? url;
  final BoxFit fit;
  final IconData fallbackIcon;
  final String? fallbackLabel;

  const NetworkPhoto({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.fallbackIcon = Icons.directions_car_filled_rounded,
    this.fallbackLabel,
  });

  Widget _fallback() => PhotoFallback(icon: fallbackIcon, label: fallbackLabel);

  @override
  Widget build(BuildContext context) {
    final source = url;
    if (source == null || source.trim().isEmpty) return _fallback();
    return Image.network(
      source,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const SkeletonBox(radius: 0);
      },
      errorBuilder: (_, __, ___) => _fallback(),
    );
  }
}

/// Navy gradient tile with a soft icon — used whenever there is no photo.
class PhotoFallback extends StatelessWidget {
  final IconData icon;
  final String? label;

  const PhotoFallback({super.key, this.icon = Icons.directions_car_filled_rounded, this.label});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primarySoft, AppColors.primaryDeep],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: AppColors.cyan.withValues(alpha: 0.7)),
            if (label != null) ...[
              const SizedBox(height: 6),
              Text(
                label!,
                style: const TextStyle(color: AppColors.textOnDarkMuted, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Pulsing grey block used for loading placeholders.
class SkeletonBox extends StatefulWidget {
  final double? width;
  final double? height;
  final double radius;

  const SkeletonBox({super.key, this.width, this.height, this.radius = AppRadii.sm});

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Color.lerp(AppColors.surfaceMuted, AppColors.divider, _controller.value),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

/// Grid of card-shaped skeletons shown while a list loads for the first time.
class SkeletonGrid extends StatelessWidget {
  final int count;
  final double minTileWidth;
  final double tileHeight;

  const SkeletonGrid({super.key, this.count = 6, this.minTileWidth = 260, this.tileHeight = 280});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 16.0;
        final columns = (constraints.maxWidth / minTileWidth).floor().clamp(1, 4);
        final width = (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (var i = 0; i < count; i++)
              SkeletonBox(width: width, height: tileHeight, radius: AppRadii.lg),
          ],
        );
      },
    );
  }
}
