import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// The large banner at the top of the Home page: a premium car photo with a
/// dark gradient scrim, the "Find Your Perfect Car" headline, and a CTA
/// button. [onExplorePressed] should navigate to the car-listing screen.
class HeroBanner extends StatelessWidget {
  final VoidCallback? onExplorePressed;

  const HeroBanner({super.key, this.onExplorePressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          height: 260,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=1200',
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(color: AppColors.divider);
                },
                errorBuilder: (context, error, stack) => Container(color: AppColors.primary),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.05),
                      Colors.black.withValues(alpha: 0.75),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 22,
                right: 22,
                bottom: 22,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Find Your\nPerfect Car',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Buy, sell and resell — all in one trusted place.',
                      style: TextStyle(color: Colors.white70, fontSize: 13.5),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: onExplorePressed,
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      label: const Text('Explore Cars'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
