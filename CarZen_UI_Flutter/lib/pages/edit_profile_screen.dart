import 'package:carzen_flutter/models/user_response.dart';
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/profile_service.dart';
import 'package:carzen_flutter/services/session_controller.dart';
import 'package:carzen_flutter/utils/breakpoints.dart';
import 'package:carzen_flutter/utils/validators.dart';
import 'package:carzen_flutter/widgets/app_shell.dart';
import 'package:carzen_flutter/widgets/auth_text_field.dart';
import 'package:carzen_flutter/widgets/form_widgets.dart';
import 'package:carzen_flutter/widgets/page_container.dart';
import 'package:carzen_flutter/widgets/primary_button.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:flutter/material.dart';

/// Edit name, username, email and phone (`PATCH /v1/users/update/me`, or
/// `/v1/admin/update/me` for admins). Only changed fields are sent.
class EditProfileScreen extends StatefulWidget {
  final UserResponse? user;
  const EditProfileScreen({super.key, this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _profile = ProfileService();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();

  UserResponse? _user;
  bool _loading = true;
  Object? _loadError;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _fill(widget.user!);
    } else {
      _load();
    }
  }

  @override
  void dispose() {
    for (final c in [_first, _last, _username, _email, _phone]) {
      c.dispose();
    }
    super.dispose();
  }

  void _fill(UserResponse u) {
    _user = u;
    _first.text = u.firstName;
    _last.text = u.lastName ?? '';
    _username.text = u.username;
    _email.text = u.email;
    _phone.text = u.phoneNumber ?? '';
    _loading = false;
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final me = await _profile.getMe();
      if (mounted) setState(() => _fill(me));
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadError = e;
          _loading = false;
        });
      }
    }
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    final u = _user!;
    String? clean(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();
    final fields = <String, dynamic>{
      if (_first.text.trim() != u.firstName) 'first_name': _first.text.trim(),
      if (clean(_last) != u.lastName) 'last_name': clean(_last),
      if (_username.text.trim() != u.username) 'username': _username.text.trim(),
      if (_email.text.trim().toLowerCase() != u.email.toLowerCase()) 'email': _email.text.trim(),
      if (clean(_phone) != u.phoneNumber) 'phone_number': clean(_phone),
    };
    if (fields.isEmpty) {
      Navigator.of(context).pop(false);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final updated = u.isAdmin ? await _profile.adminUpdateOwnProfile(fields) : await _profile.updateMe(fields);
      SessionController.instance.updateUser(updated);
      if (!mounted) return;
      showAppSnack(context, 'Profile updated');
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
      title: 'Edit profile',
      fallbackRoute: AppRoutes.account,
      showBackButton: true,
      body: _loading
          ? const LoadingView()
          : _loadError != null
              ? ApiErrorView(error: _loadError!, onRetry: _load)
              : SingleChildScrollView(
                  child: PageContainer(
                    maxWidth: 620,
                    verticalPadding: Breakpoints.isCompact(context) ? 18 : 32,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const PageHeader(title: 'Edit profile', subtitle: 'Sellers and the CarZen team see your name when you message or buy.'),
                          const SizedBox(height: 22),
                          if (_error != null) InlineError(_error!),
                          FormPanel(
                            title: 'Your details',
                            children: [
                              FieldPair(
                                AuthTextField(
                                  controller: _first,
                                  label: 'First name',
                                  required: true,
                                  autofillHints: const [AutofillHints.givenName],
                                  validator: (v) => Validators.required(v, message: 'Enter your first name'),
                                ),
                                AuthTextField(controller: _last, label: 'Last name', autofillHints: const [AutofillHints.familyName]),
                              ),
                              AuthTextField(controller: _username, label: 'Username', required: true, icon: Icons.alternate_email, validator: Validators.username),
                              AuthTextField(
                                controller: _email,
                                label: 'Email',
                                required: true,
                                icon: Icons.mail_outline,
                                keyboardType: TextInputType.emailAddress,
                                helper: 'You log in with this email.',
                                validator: Validators.email,
                              ),
                              AuthTextField(
                                controller: _phone,
                                label: 'Phone number',
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                validator: Validators.optionalPhone,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _save(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          PrimaryButton(label: 'Save changes', onPressed: _save, isLoading: _saving),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}
