import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// A network photo with a quiet skeleton while loading and a clear fallback
/// when the URL is missing or fails. The parent decides the size (wrap in
/// [AspectRatio] / [SizedBox]); photos are cropped to fill, never stretched.
class NetworkPhoto extends StatelessWidget {
  final String? url;
  final BoxFit fit;
  final IconData fallbackIcon;
  final String? fallbackLabel;
  final String? semanticLabel;

  /// Decode at about this width instead of full size; keeps long lists light.
  final int? cacheWidth;

  const NetworkPhoto({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.fallbackIcon = Icons.directions_car_filled_outlined,
    this.fallbackLabel,
    this.semanticLabel,
    this.cacheWidth,
  });

  Widget _fallback() => PhotoFallback(icon: fallbackIcon, label: fallbackLabel);

  @override
  Widget build(BuildContext context) {
    final source = url;
    if (source == null || source.trim().isEmpty) return _fallback();
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return Image.network(
      source,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      cacheWidth: cacheWidth == null ? null : (cacheWidth! * dpr.clamp(1.0, 2.0)).round(),
      gaplessPlayback: true,
      semanticLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
      frameBuilder: (context, child, frame, wasSync) {
        if (wasSync || frame != null) return child;
        return const SkeletonBox(radius: 0);
      },
      errorBuilder: (_, _, _) => _fallback(),
    );
  }
}

/// Neutral tile with a car outline - used whenever there is no photo.
class PhotoFallback extends StatelessWidget {
  final IconData icon;
  final String? label;

  const PhotoFallback({super.key, this.icon = Icons.directions_car_filled_outlined, this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceMuted,
      alignment: Alignment.center,
      child: LayoutBuilder(
        builder: (context, c) {
          final small = c.maxHeight < 90;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: small ? 26 : 40, color: AppColors.lineStrong),
              if (label != null && !small) ...[
                const SizedBox(height: 6),
                Text(label!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5, fontWeight: FontWeight.w500)),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// Pulsing block used for loading placeholders. Respects reduced motion.
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
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      _controller.value = 0.4;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Color.lerp(AppColors.surfaceMuted, AppColors.divider, _controller.value),
            borderRadius: BorderRadius.circular(widget.radius),
          ),
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
  final int maxColumns;

  const SkeletonGrid({super.key, this.count = 6, this.minTileWidth = 260, this.tileHeight = 300, this.maxColumns = 4});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 16.0;
        final columns = ((constraints.maxWidth + spacing) / (minTileWidth + spacing)).floor().clamp(1, maxColumns);
        final width = (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [for (var i = 0; i < count; i++) SkeletonBox(width: width, height: tileHeight, radius: AppRadii.lg)],
        );
      },
    );
  }
}
