import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/widgets/carzen_nav_bar.dart';
import 'package:flutter/material.dart';

import 'package:carzen_flutter/widgets/auth_error_banner.dart';
import 'package:carzen_flutter/widgets/auth_header.dart';
import 'package:carzen_flutter/widgets/auth_text_field.dart';
import 'package:carzen_flutter/widgets/primary_button.dart';
import 'package:carzen_flutter/services/auth_exception.dart';
import 'package:carzen_flutter/services/auth_service.dart';
import 'package:carzen_flutter/utils/validators.dart';

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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.register(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phoneNumber: _phoneController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created! Please log in.')),
      );
      Navigator.pushReplacementNamed(context, '/Login');
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goToLogin() {
    Navigator.pushReplacementNamed(context, '/Login');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: const CarZenNavBar(current: NavSection.register, title: 'Register'),
      // AppBar(
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
                    title: "Create Account",
                    subTitle: "Join CarZen to buy, sell and resell\ncars with confidence."
                ),
                if (_errorMessage != null) AuthErrorBanner(message: _errorMessage!),
                AuthTextField(
                  controller: _firstNameController,
                  label: 'First Name *',
                  hint: 'Your name',
                  icon: Icons.person_outline_rounded,
                  validator: (v) => Validators.required(v, message: 'First name is required'),
                ),
                AuthTextField(
                  controller: _lastNameController,
                  label: 'Last Name (optional)',
                  hint: 'Your surname',
                  icon: Icons.person_outline_rounded,
                ),
                AuthTextField(
                  controller: _usernameController,
                  label: 'Username *',
                  hint: 'vishal08',
                  icon: Icons.alternate_email_rounded,
                  validator: Validators.username,
                ),
                AuthTextField(
                  controller: _emailController,
                  label: 'Email *',
                  hint: 'you@example.com',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                AuthTextField(
                  controller: _phoneController,
                  label: 'Phone Number (optional)',
                  hint: '9876543210',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: Validators.optionalPhone,
                ),
                AuthTextField(
                  controller: _passwordController,
                  label: 'Password *',
                  hint: 'At least 8 characters',
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                  validator: Validators.password,
                ),
                AuthTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password *',
                  hint: 'Re-enter your password',
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  validator: (v) => Validators.confirmPassword(v, _passwordController.text),
                ),
                const SizedBox(height: 8),
                PrimaryButton(label: 'Create Account', onPressed: _handleRegister, isLoading: _isLoading),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? ', style: TextStyle(color: AppColors.textSecondary)),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: _isLoading ? null : _goToLogin,
                        child: const Text(
                          'Log In',
                          style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w700),
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
