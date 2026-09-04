import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_role.dart';
import '../../navigation/app_state.dart';
import '../../services/auth_service.dart';
import '../../theme/app_spacing.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/app_button.dart';
import '../../widgets/ne_pattern_strip.dart';
import '../../widgets/status_banner.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  bool _success = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _goBackToRoleSelect() async {
    // Clear role so user can pick Elderly or Caregiver again.
    final appState = context.read<AppState>();
    await appState.logout(); // clears role + logged-in flag without wiping accounts
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.userSelect,
      (route) => false,
    );
  }

  Future<void> _login(BuildContext context) async {
    final t = context.read<AppState>().localizations.t;

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _loading = true;
      _errorMessage = null;
      _success = false;
    });
    final matched = await AuthService.instance.login(gmail: email, password: password);
    if (!context.mounted) return;

    if (matched == null) {
      setState(() {
        _loading = false;
        _errorMessage = t('auth_invalidCredentials');
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t('auth_invalidCredentials'))));
      return;
    }

    setState(() {
      _loading = false;
      _success = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!context.mounted) return;

    final appState = context.read<AppState>();
    // Account already has a fixed role from registration — one Gmail = one role.
    final role = matched.role == 'caregiver' ? UserRole.caregiver : UserRole.elderly;
    await appState.setRole(role);
    await appState.completeLogin();
    if (!context.mounted) return;

    Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
      role == UserRole.elderly ? AppRoutes.elderlyShell : AppRoutes.caregiverShell,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppState>().localizations.t;
    final linkColor = Colors.blue.shade700;
    final role = context.watch<AppState>().role;
    final roleLabel = role == UserRole.caregiver
        ? t('role_caregiver')
        : t('role_elderly');

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goBackToRoleSelect();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(t('auth_loginTitle')),
          // Explicit back for both elderly and caregiver flows.
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: t('common_back'),
            onPressed: _goBackToRoleSelect,
          ),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(14),
            child: NePatternStrip(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '${t('auth_loginAs')}: $roleLabel',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (_success)
                    StatusBanner(
                        message: t('auth_loginSuccess'), type: StatusBannerType.success),
                  if (_errorMessage != null && !_success)
                    StatusBanner(
                        message: _errorMessage!, type: StatusBannerType.error),
                  Text(t('auth_email'), style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    validator: (value) {
                      final v = value?.trim() ?? '';
                      if (v.isEmpty) return t('auth_required');
                      if (!Validators.isValidEmailOrPhone(v)) {
                        return t('auth_invalidEmail');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(t('auth_password'),
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscure,
                    autofillHints: const [AutofillHints.password],
                    validator: (value) =>
                        (value == null || value.isEmpty) ? t('auth_required') : null,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(
                            _obscure ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed(AppRoutes.forgotPassword),
                      child: Text(t('auth_forgotPassword'),
                          style: TextStyle(color: linkColor)),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: t('auth_loginButton'),
                    loading: _loading,
                    onPressed: () => _login(context),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Center(
                    child: TextButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed(AppRoutes.register),
                      child: Text(t('auth_newRegister'),
                          style: TextStyle(
                              color: linkColor, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
