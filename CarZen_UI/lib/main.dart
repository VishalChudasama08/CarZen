import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const CarZenApp());
}

class CarZenApp extends StatelessWidget {
  const CarZenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CarZen',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      // SplashScreen validates any stored token before deciding whether to
      // open HomeScreen or LoginScreen — see services/auth_service.dart.
      home: const SplashScreen(),
    );
  }
}
