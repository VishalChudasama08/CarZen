import 'package:carzen_flutter/routes/app_router.dart';
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:url_strategy/url_strategy.dart';

void main() {
  setPathUrlStrategy();
  runApp(const CarZenApp());
}

class CarZenApp extends StatelessWidget {
  const CarZenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CarZen',
      theme: AppTheme.light(),
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRouter.onGenerateRoute,
      onGenerateInitialRoutes: AppRouter.onGenerateInitialRoutes,
      onUnknownRoute: AppRouter.onUnknownRoute,
    );
  }
}
