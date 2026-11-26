import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/profile_service.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/breakpoints.dart';
import 'package:carzen_flutter/utils/validators.dart';
import 'package:carzen_flutter/widgets/app_shell.dart';
import 'package:carzen_flutter/widgets/auth_text_field.dart';
import 'package:carzen_flutter/widgets/form_widgets.dart';
import 'package:carzen_flutter/widgets/page_container.dart';
import 'package:carzen_flutter/widgets/primary_button.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:flutter/material.dart';

/// `POST /v1/users/me/change-password`.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _profile = ProfileService();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await _profile.changePassword(currentPassword: _current.text, newPassword: _next.text);
      if (!mounted) return;
      showAppSnack(context, 'Password changed');
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      section: NavSection.profile,
      title: 'Change password',
      fallbackRoute: AppRoutes.account,
      showBackButton: true,
      body: SingleChildScrollView(
        child: PageContainer(
          maxWidth: 560,
          verticalPadding: Breakpoints.isCompact(context) ? 18 : 32,
          child: AutofillGroup(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const PageHeader(title: 'Change password', subtitle: 'Use a password you don\'t use anywhere else.'),
                  const SizedBox(height: 22),
                  if (_error != null) InlineError(_error!),
                  FormPanel(
                    title: 'New password',
                    children: [
                      AuthTextField(
                        controller: _current,
                        label: 'Current password',
                        required: true,
                        isPassword: true,
                        autofillHints: const [AutofillHints.password],
                        validator: (v) => Validators.required(v, message: 'Enter your current password'),
                      ),
                      AuthTextField(
                        controller: _next,
                        label: 'New password',
                        required: true,
                        isPassword: true,
                        autofillHints: const [AutofillHints.newPassword],
                        onChanged: (_) => setState(() {}),
                        validator: (v) {
                          final base = Validators.password(v);
                          if (base != null) return base;
                          return v == _current.text ? 'Choose a password different from the current one' : null;
                        },
                      ),
                      Wrap(
                        spacing: 14,
                        runSpacing: 6,
                        children: [
                          for (final r in Validators.passwordRules)
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(r.test(_next.text) ? Icons.check_circle : Icons.radio_button_unchecked,
                                  size: 15, color: r.test(_next.text) ? AppColors.success : AppColors.textTertiary),
                              const SizedBox(width: 5),
                              Text(r.label, style: TextStyle(fontSize: 12.5, color: r.test(_next.text) ? AppColors.success : AppColors.textSecondary)),
                            ]),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        controller: _confirm,
                        label: 'Confirm new password',
                        required: true,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _save(),
                        validator: (v) => Validators.confirmPassword(v, _next.text),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(label: 'Change password', onPressed: _save, isLoading: _saving),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
