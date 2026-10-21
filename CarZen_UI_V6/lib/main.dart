import 'package:carzen_flutter/routes/app_router.dart';
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() {
  // Clean URLs on the web (`/cars/...` instead of `/#/cars/...`).
  // Has no effect on Android/iOS.
  usePathUrlStrategy();
  runApp(const CarZenApp());
}

class CarZenApp extends StatelessWidget {
  const CarZenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CarZen - Buy, sell and service cars',
      theme: AppTheme.light(),
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRouter.onGenerateRoute,
      onGenerateInitialRoutes: AppRouter.onGenerateInitialRoutes,
      onUnknownRoute: AppRouter.onUnknownRoute,
      builder: (context, child) {
        // Respect the user's text size, but cap extreme scaling so layouts
        // designed for it (wrapping, reflow) stay usable.
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(textScaler: media.textScaler.clamp(minScaleFactor: 0.9, maxScaleFactor: 1.6)),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
