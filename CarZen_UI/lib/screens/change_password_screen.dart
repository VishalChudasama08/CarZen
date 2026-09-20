import 'package:flutter/material.dart';
import '../services/api_exception.dart';
import '../services/profile_service.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';
import '../widgets/auth_error_banner.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/primary_button.dart';

/// `POST /v1/users/me/change-password` — requires the current password
/// plus a new one; confirm-new-password is a frontend-only check.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _profileService = ProfileService();

  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isSaving = false;
  String? _errorMessage;

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    try {
      await _profileService.changePassword(
        currentPassword: _currentController.text,
        newPassword: _newController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated.')));
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Change Password'), backgroundColor: AppColors.background),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_errorMessage != null) AuthErrorBanner(message: _errorMessage!),
                AuthTextField(
                  controller: _currentController,
                  label: 'Current Password *',
                  hint: 'Enter your current password',
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                  validator: (v) => Validators.required(v, message: 'Current password is required'),
                ),
                AuthTextField(
                  controller: _newController,
                  label: 'New Password *',
                  hint: 'At least 8 characters',
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                  validator: Validators.password,
                ),
                AuthTextField(
                  controller: _confirmController,
                  label: 'Confirm New Password *',
                  hint: 'Re-enter your new password',
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  validator: (v) => Validators.confirmPassword(v, _newController.text),
                ),
                const SizedBox(height: 10),
                PrimaryButton(label: 'Update Password', onPressed: _handleSave, isLoading: _isSaving),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
