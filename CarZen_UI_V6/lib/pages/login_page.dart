import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/auth_exception.dart';
import 'package:carzen_flutter/services/auth_service.dart';
import 'package:carzen_flutter/services/session_controller.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/validators.dart';
import 'package:carzen_flutter/widgets/app_shell.dart';
import 'package:carzen_flutter/widgets/auth_error_banner.dart';
import 'package:carzen_flutter/widgets/auth_header.dart';
import 'package:carzen_flutter/widgets/auth_layout.dart';
import 'package:carzen_flutter/widgets/auth_text_field.dart';
import 'package:carzen_flutter/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {
  /// When opened by a protected action, return `true` so that action can
  /// continue after a successful sign-in instead of starting over on Home.
  final bool returnToPrevious;

  const LoginPage({super.key, this.returnToPrevious = false});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  final _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkExistingSession();
  }

  /// Someone who is already signed in and opens /login is sent on.
  Future<void> _checkExistingSession() async {
    if (widget.returnToPrevious) return;
    final hasToken = await _authService.hasStoredToken();
    if (!hasToken || !mounted) return;
    await SessionController.instance.refresh();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      SessionController.instance.isAdmin ? AppRoutes.admin : AppRoutes.home,
      (route) => false,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_isLoading) return;
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.login(email: _emailController.text.trim(), password: _passwordController.text);
      if (!mounted) return;
      TextInput.finishAutofillContext(shouldSave: true);
      await SessionController.instance.refresh();
      if (!mounted) return;
      if (widget.returnToPrevious) {
        Navigator.of(context).pop(true);
        return;
      }
      Navigator.pushNamedAndRemoveUntil(
        context,
        SessionController.instance.isAdmin ? AppRoutes.admin : AppRoutes.home,
        (route) => false,
      );
    } on AuthException catch (e) {
      TextInput.finishAutofillContext(shouldSave: false);
      if (mounted) {
        setState(() => _errorMessage = e.message);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _passwordFocusNode.canRequestFocus) {
            _passwordFocusNode.requestFocus();
            _passwordController.selection = TextSelection(
              baseOffset: 0,
              extentOffset: _passwordController.text.length,
            );
          }
        });
      }
    } catch (_) {
      TextInput.finishAutofillContext(shouldSave: false);
      if (mounted) {
        setState(() => _errorMessage = 'Something went wrong. Please check your connection and try again.');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _passwordFocusNode.canRequestFocus) {
            _passwordFocusNode.requestFocus();
          }
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      section: NavSection.login,
      title: 'Log in',
      body: AuthLayout(
        sideTitle: 'Welcome back to your garage.',
        child: AutofillGroup(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AuthHeader(
                  title: 'Log in',
                  subTitle: 'Pick up where you left off - saved cars, messages and bookings.',
                ),
                if (_errorMessage != null) AuthErrorBanner(message: _errorMessage!),
                AuthTextField(
                  controller: _emailController,
                  label: 'Email',
                  required: true,
                  hint: 'you@example.com',
                  icon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email, AutofillHints.username],
                  enabled: !_isLoading,
                  validator: Validators.email,
                ),
                AuthTextField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  label: 'Password',
                  required: true,
                  hint: 'Your password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  enabled: !_isLoading,
                  onSubmitted: (_) => _handleLogin(),
                  validator: (v) => Validators.required(v, message: 'Enter your password'),
                ),
                const SizedBox(height: 4),
                PrimaryButton(label: 'Log in', onPressed: _handleLogin, isLoading: _isLoading),
                const SizedBox(height: 20),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text('New to CarZen?', style: TextStyle(color: AppColors.textSecondary)),
                    TextButton(
                      onPressed: _isLoading ? null : () => Navigator.pushReplacementNamed(context, AppRoutes.register),
                      child: const Text('Create an account'),
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
