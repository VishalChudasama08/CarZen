import 'package:flutter/material.dart';
import '../models/user_response.dart';
import '../services/api_exception.dart';
import '../services/profile_service.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';
import '../widgets/auth_error_banner.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/primary_button.dart';

/// Edits the current user's own profile fields —
/// `PATCH /v1/users/update/me` (`UserUpdateProfile`, all fields optional).
class EditProfileScreen extends StatefulWidget {
  final UserResponse user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _profileService = ProfileService();

  late final _firstNameController = TextEditingController(text: widget.user.firstName);
  late final _lastNameController = TextEditingController(text: widget.user.lastName ?? '');
  late final _phoneController = TextEditingController(text: widget.user.phoneNumber ?? '');

  bool _isSaving = false;
  String? _errorMessage;

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    try {
      await _profileService.updateMe({
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim().isEmpty ? null : _lastNameController.text.trim(),
        'phone_number': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      });
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Edit Profile'), backgroundColor: AppColors.background),
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
                  controller: _firstNameController,
                  label: 'First Name',
                  hint: 'Vishal',
                  icon: Icons.person_outline_rounded,
                  validator: (v) => Validators.required(v, message: 'First name is required'),
                ),
                AuthTextField(
                  controller: _lastNameController,
                  label: 'Last Name (optional)',
                  hint: 'Chudasama',
                  icon: Icons.person_outline_rounded,
                ),
                AuthTextField(
                  controller: _phoneController,
                  label: 'Phone Number (optional)',
                  hint: '9876543210',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  validator: Validators.optionalPhone,
                ),
                const SizedBox(height: 10),
                PrimaryButton(label: 'Save Changes', onPressed: _handleSave, isLoading: _isSaving),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
