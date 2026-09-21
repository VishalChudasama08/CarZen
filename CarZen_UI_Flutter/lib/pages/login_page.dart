import 'package:carzen_flutter/widgets/auth_error_banner.dart';
import 'package:carzen_flutter/widgets/auth_header.dart';
import 'package:carzen_flutter/widgets/auth_text_field.dart';
import 'package:carzen_flutter/widgets/carzen_nav_bar.dart';
import 'package:carzen_flutter/widgets/primary_button.dart';
import 'package:carzen_flutter/services/auth_exception.dart';
import 'package:carzen_flutter/services/auth_service.dart';
import 'package:carzen_flutter/utils/validators.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  /// When opened by a protected action, return `true` so that action can
  /// continue after a successful sign-in instead of sending the visitor to
  /// a fresh home page.
  final bool returnToPrevious;

  const LoginPage({super.key, this.returnToPrevious = false});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      if (widget.returnToPrevious) {
        Navigator.of(context).pop(true);
      } else {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goToRegister() {
    Navigator.pushReplacementNamed(context, '/Register');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      
      appBar: const CarZenNavBar(current: NavSection.login, title: 'Login'),
      // AppBar(
      //   // leading: const Icon(Icons.arrow_back),
      //   title: ClipRRect(
      //     borderRadius: BorderRadius.circular(8),
      //     child: Image.asset(
      //       'assets/images/carzen_logo.png',
      //       height: 40,
      //     ),
      //   ),
      // ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AuthHeader(
                  title: 'Welcome Back',
                  subTitle: 'Log in to continue buying, selling and\ntracking your cars on CarZen.',
                ),
                if (_errorMessage != null) AuthErrorBanner(message: _errorMessage!),
                AuthTextField(
                  controller: _emailController,
                  label: 'Email *',
                  hint: 'you@example.com',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                AuthTextField(
                  controller: _passwordController,
                  label: 'Password *',
                  hint: 'Enter your password',
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  validator: (v) => Validators.required(v, message: 'Password is required'),
                ),
                const SizedBox(height: 8),
                PrimaryButton(label: 'Log In', onPressed: _handleLogin, isLoading: _isLoading),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? ", style: TextStyle(color: AppColors.textSecondary)),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: _isLoading ? null : _goToRegister,
                        child: const Text(
                          'Register',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
