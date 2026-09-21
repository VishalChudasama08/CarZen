import 'package:carzen_flutter/widgets/carzen_nav_bar.dart';
import 'package:carzen_flutter/widgets/content_width.dart';
import 'package:flutter/material.dart';
import 'package:carzen_flutter/models/user_response.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/profile_service.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/validators.dart';
import 'package:carzen_flutter/widgets/auth_error_banner.dart';
import 'package:carzen_flutter/widgets/auth_text_field.dart';
import 'package:carzen_flutter/widgets/primary_button.dart';

/// Edits the current user's own profile fields —
/// `PATCH /v1/users/update/me` for users and `PATCH /v1/admin/update/me` for
/// admins (`UserUpdateProfile`, all fields optional).
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
      final fields = <String, dynamic>{
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim().isEmpty ? null : _lastNameController.text.trim(),
        'phone_number': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      };
      if (widget.user.isAdmin) {
        await _profileService.adminUpdateOwnProfile(fields);
      } else {
        await _profileService.updateMe(fields);
      }
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
      appBar: const CarZenNavBar(current: NavSection.profile, title: 'Edit Profile'),
      body: ContentWidth(
        maxWidth: 560,
        child: SafeArea(
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
      ),
    );
  }
}
