import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/auth_exception.dart';
import 'package:carzen_flutter/services/auth_service.dart';
import 'package:carzen_flutter/services/session_controller.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/breakpoints.dart';
import 'package:carzen_flutter/utils/validators.dart';
import 'package:carzen_flutter/widgets/app_shell.dart';
import 'package:carzen_flutter/widgets/auth_error_banner.dart';
import 'package:carzen_flutter/widgets/auth_header.dart';
import 'package:carzen_flutter/widgets/auth_layout.dart';
import 'package:carzen_flutter/widgets/auth_text_field.dart';
import 'package:carzen_flutter/widgets/primary_button.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    for (final c in [
      _firstNameController,
      _lastNameController,
      _usernameController,
      _emailController,
      _passwordController,
      _confirmPasswordController,
      _phoneController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_isLoading) return;
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    try {
      final user = await _authService.register(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        username: _usernameController.text.trim(),
        email: email,
        password: password,
        phoneNumber: _phoneController.text.trim(),
      );
      // Sign the new account in straight away.
      try {
        await _authService.login(email: email, password: password);
        await SessionController.instance.refresh();
        if (!mounted) return;
        showAppSnack(context, 'Welcome to CarZen, ${user.firstName}.');
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (r) => false);
      } on AuthException {
        if (!mounted) return;
        showAppSnack(context, 'Account created. Log in to continue.');
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    } on AuthException catch (e) {
      if (mounted) setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final twoCol = Breakpoints.widthOf(context) >= 420;
    Widget pair(Widget a, Widget b) => twoCol
        ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: a), const SizedBox(width: 12), Expanded(child: b)])
        : Column(children: [a, b]);

    return AppScaffold(
      section: NavSection.register,
      title: 'Create account',
      body: AuthLayout(
        child: AutofillGroup(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AuthHeader(
                  title: 'Create your account',
                  subTitle: 'It takes a minute. You can add a phone number now or later.',
                ),
                if (_errorMessage != null) AuthErrorBanner(message: _errorMessage!),
                pair(
                  AuthTextField(
                    controller: _firstNameController,
                    label: 'First name',
                    required: true,
                    autofillHints: const [AutofillHints.givenName],
                    textCapitalization: TextCapitalization.words,
                    validator: (v) => Validators.required(v, message: 'Enter your first name'),
                  ),
                  AuthTextField(
                    controller: _lastNameController,
                    label: 'Last name',
                    autofillHints: const [AutofillHints.familyName],
                    textCapitalization: TextCapitalization.words,
                  ),
                ),
                AuthTextField(
                  controller: _usernameController,
                  label: 'Username',
                  required: true,
                  hint: 'e.g. rohan.mehta',
                  icon: Icons.alternate_email,
                  autofillHints: const [AutofillHints.newUsername],
                  helper: 'Letters, numbers, "." and "_"',
                  validator: Validators.username,
                ),
                AuthTextField(
                  controller: _emailController,
                  label: 'Email',
                  required: true,
                  hint: 'you@example.com',
                  icon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  validator: Validators.email,
                ),
                AuthTextField(
                  controller: _phoneController,
                  label: 'Phone number',
                  hint: '10-digit mobile number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  validator: Validators.optionalPhone,
                ),
                AuthTextField(
                  controller: _passwordController,
                  label: 'Password',
                  required: true,
                  icon: Icons.lock_outline,
                  isPassword: true,
                  autofillHints: const [AutofillHints.newPassword],
                  onChanged: (_) => setState(() {}),
                  validator: Validators.password,
                ),
                _PasswordChecklist(value: _passwordController.text),
                AuthTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm password',
                  required: true,
                  icon: Icons.lock_outline,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _handleRegister(),
                  validator: (v) => Validators.confirmPassword(v, _passwordController.text),
                ),
                const SizedBox(height: 4),
                PrimaryButton(label: 'Create account', onPressed: _handleRegister, isLoading: _isLoading),
                const SizedBox(height: 20),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text('Already have an account?', style: TextStyle(color: AppColors.textSecondary)),
                    TextButton(
                      onPressed: _isLoading ? null : () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                      child: const Text('Log in'),
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

/// Live checklist of the backend's password rules.
class _PasswordChecklist extends StatelessWidget {
  final String value;
  const _PasswordChecklist({required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 0),
      child: Wrap(
        spacing: 14,
        runSpacing: 6,
        children: [
          for (final rule in Validators.passwordRules)
            Builder(builder: (context) {
              final ok = rule.test(value);
              return Semantics(
                label: '${rule.label}: ${ok ? 'done' : 'not yet'}',
                excludeSemantics: true,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(ok ? Icons.check_circle : Icons.radio_button_unchecked, size: 15, color: ok ? AppColors.success : AppColors.textTertiary),
                    const SizedBox(width: 5),
                    Text(rule.label, style: TextStyle(fontSize: 12.5, color: ok ? AppColors.success : AppColors.textSecondary)),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
