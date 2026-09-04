import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_role.dart';
import '../../navigation/app_state.dart';
import '../../services/auth_service.dart';
import '../../services/media_location_service.dart';
import '../../theme/app_spacing.dart';
import '../../utils/validators.dart';
import '../../widgets/app_button.dart';
import '../../widgets/ne_pattern_strip.dart';
import '../../widgets/otp_countdown_timer.dart';
import '../../widgets/otp_input_field.dart';
import '../../widgets/password_requirements_view.dart';
import '../../widgets/status_banner.dart';

/// Multi-step registration:
/// 0 = Basic Information (+ optional profile photo)
/// 1 = Contact Information (+ role-specific + current location)
/// 2 = OTP Verification
/// 3 = Create Password
/// 4 = Account Created (show generated User ID)
///
/// One Gmail = one account (elderly OR caregiver). Same email cannot
/// register twice.
class RegisterWizardScreen extends StatefulWidget {
  const RegisterWizardScreen({super.key});

  @override
  State<RegisterWizardScreen> createState() => _RegisterWizardScreenState();
}

class _RegisterWizardScreenState extends State<RegisterWizardScreen> {
  int _step = 0;
  bool _loading = false;
  String? _generatedOtp;
  String? _createdUserId;
  String? _profilePhotoPath; // optional
  bool _locating = false;
  bool _pickingPhoto = false;

  // Step 0 — Basic
  final _basicFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  String? _gender;

  // Step 1 — Contact + role-specific
  final _contactFormKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _accessibilityController = TextEditingController();
  bool _voiceAssistancePreferred = false;
  final _relationshipController = TextEditingController();
  final _linkedIdsController = TextEditingController();

  // Password
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  // OTP
  final _otpFieldKey = GlobalKey<OtpInputFieldState>();
  final _otpTimerKey = GlobalKey<OtpCountdownTimerState>();
  String _otpValue = '';
  bool _otpError = false;
  bool _otpVerifying = false;
  bool _otpVerified = false;
  bool _otpExpired = false;
  bool _resending = false;

  static const _genders = ['Male', 'Female', 'Other', 'Prefer not to say'];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _accessibilityController.dispose();
    _relationshipController.dispose();
    _linkedIdsController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickPhoto({required bool fromCamera}) async {
    final t = context.read<AppState>().localizations.t;
    setState(() => _pickingPhoto = true);
    final path = await MediaLocationService.instance
        .pickProfilePhoto(fromCamera: fromCamera);
    if (!mounted) return;
    setState(() {
      _pickingPhoto = false;
      if (path != null) _profilePhotoPath = path;
    });
    if (path == null) {
      _snack(t('profile_photoCancelled'));
    } else {
      _snack(t('profile_photoAdded'));
    }
  }

  void _showPhotoOptions() {
    final t = context.read<AppState>().localizations.t;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(t('profile_photoCamera')),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto(fromCamera: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(t('profile_photoGallery')),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto(fromCamera: false);
              },
            ),
            if (_profilePhotoPath != null)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(t('profile_photoRemove')),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _profilePhotoPath = null);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _useCurrentLocation() async {
    final t = context.read<AppState>().localizations.t;
    setState(() => _locating = true);
    final addr = await MediaLocationService.instance.getCurrentLocationAddress();
    if (!mounted) return;
    setState(() => _locating = false);
    if (addr == null) {
      _snack(t('register_locationFailed'));
      return;
    }
    _addressController.text = addr;
    setState(() {});
    _snack(t('register_locationFilled'));
  }

  Future<void> _submitBasic() async {
    final t = context.read<AppState>().localizations.t;
    if (!(_basicFormKey.currentState?.validate() ?? false)) {
      _snack(t('register_detailsInvalid'));
      return;
    }
    if (_gender == null) {
      _snack(t('register_genderRequired'));
      return;
    }
    setState(() => _loading = true);
    // One Gmail = one user only (cannot register twice as elderly and caregiver).
    final exists = await AuthService.instance.emailExists(_emailController.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (exists) {
      _snack(t('register_emailExists'));
      return;
    }
    setState(() => _step = 1);
  }

  Future<void> _submitContact() async {
    final t = context.read<AppState>().localizations.t;
    if (!(_contactFormKey.currentState?.validate() ?? false)) {
      _snack(t('register_detailsInvalid'));
      return;
    }
    _sendOtp();
    setState(() => _step = 2);
  }

  void _sendOtp() {
    final t = context.read<AppState>().localizations.t;
    _generatedOtp = AuthService.instance.generateOtp();
    _otpValue = '';
    _otpError = false;
    _otpVerified = false;
    _otpExpired = false;
    _otpFieldKey.currentState?.clear();
    _otpTimerKey.currentState?.restart();
    _snack('${t('register_otp_demoPrefix')} $_generatedOtp');
  }

  Future<void> _resendOtp() async {
    setState(() => _resending = true);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _resending = false);
    final t = context.read<AppState>().localizations.t;
    _sendOtp();
    setState(() {});
    _snack(t('otp_resent'));
  }

  Future<void> _submitOtp() async {
    final t = context.read<AppState>().localizations.t;
    if (_otpExpired) {
      _snack(t('otp_expired'));
      return;
    }
    if (_otpValue.length != 6) {
      _snack(t('otp_incomplete'));
      return;
    }
    setState(() {
      _otpVerifying = true;
      _otpError = false;
    });
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    if (_otpValue != _generatedOtp) {
      setState(() {
        _otpVerifying = false;
        _otpError = true;
      });
      _snack(t('register_otp_invalid'));
      return;
    }

    setState(() {
      _otpVerifying = false;
      _otpVerified = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _step = 3);
  }

  Future<void> _submitPassword() async {
    final t = context.read<AppState>().localizations.t;
    final appState = context.read<AppState>();
    final role = appState.role ?? UserRole.elderly;

    setState(() => _loading = true);
    try {
      final linkedRaw = _linkedIdsController.text.trim();
      final linked = linkedRaw.isEmpty
          ? null
          : linkedRaw
              .split(RegExp(r'[,;\s]+'))
              .where((s) => s.isNotEmpty)
              .toList();

      final profile = await AuthService.instance.register(
        name: _nameController.text,
        gmail: _emailController.text,
        password: _passwordController.text,
        role: role,
        phone: _phoneController.text,
        dateOfBirth: _dobController.text,
        gender: _gender,
        address: _addressController.text,
        preferredLanguage: appState.locale.languageCode,
        profilePhotoPath: _profilePhotoPath,
        emergencyContactName: _emergencyNameController.text,
        emergencyContactPhone: _emergencyPhoneController.text,
        accessibilityPreferences:
            role == UserRole.elderly ? _accessibilityController.text : null,
        voiceAssistancePreferred:
            role == UserRole.elderly ? _voiceAssistancePreferred : null,
        relationshipWithElderly:
            role == UserRole.caregiver ? _relationshipController.text : null,
        linkedElderlyIds: role == UserRole.caregiver ? linked : null,
      );
      if (!mounted) return;
      setState(() {
        _loading = false;
        _createdUserId = profile.id;
        _step = 4;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _snack(t('register_detailsInvalid'));
    }
  }

  void _finishToLogin() {
    Navigator.of(context).pop();
  }

  void _back() {
    if (_step == 0 || _step == 4) {
      if (_step == 4) {
        _finishToLogin();
      } else {
        Navigator.of(context).pop();
      }
    } else {
      setState(() => _step -= 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppState>().localizations.t;

    return PopScope(
      canPop: _step == 0 || _step == 4,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          if (_step == 4) {
            _finishToLogin();
          } else {
            setState(() => _step -= 1);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(t('register_title')),
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _back),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(14),
            child: NePatternStrip(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: _buildStep(t),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(String Function(String) t) {
    switch (_step) {
      case 0:
        return _buildBasicStep(t);
      case 1:
        return _buildContactStep(t);
      case 2:
        return _buildOtpStep(t);
      case 3:
        return _buildPasswordStep(t);
      case 4:
        return _buildSuccessStep(t);
      default:
        return _buildBasicStep(t);
    }
  }

  Widget _buildPhotoPicker(String Function(String) t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t('register_photoOptional'),
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              backgroundImage: _profilePhotoPath != null
                  ? FileImage(File(_profilePhotoPath!))
                  : null,
              child: _profilePhotoPath == null
                  ? Icon(Icons.person,
                      size: 40, color: Theme.of(context).colorScheme.primary)
                  : null,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppButton(
                    label: t('profile_addPhoto'),
                    loading: _pickingPhoto,
                    onPressed: _pickingPhoto ? null : _showPhotoOptions,
                    variant: AppButtonVariant.outline,
                  ),
                  const SizedBox(height: 4),
                  Text(t('register_photoHint'),
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBasicStep(String Function(String) t) {
    return Form(
      key: _basicFormKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(t('register_step_basic'),
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          _buildPhotoPicker(t),
          const SizedBox(height: AppSpacing.lg),
          Text(t('register_name'), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            validator: (value) =>
                (value == null || value.trim().isEmpty) ? t('auth_required') : null,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(t('register_phone'), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            validator: (value) {
              final v = value?.trim() ?? '';
              if (v.isEmpty) return t('auth_required');
              if (!Validators.isValidPhone(v)) return t('auth_invalidPhone');
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          Text(t('register_gmail'), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              final v = value?.trim() ?? '';
              if (v.isEmpty) return t('auth_required');
              if (!Validators.isValidEmail(v)) return t('auth_invalidEmail');
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          Text(t('register_dob'), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          TextFormField(
            controller: _dobController,
            readOnly: true,
            decoration: InputDecoration(
              hintText: t('register_dobHint'),
              suffixIcon: const Icon(Icons.calendar_today),
            ),
            onTap: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime(now.year - 60),
                firstDate: DateTime(1920),
                lastDate: now,
              );
              if (picked != null) {
                _dobController.text =
                    '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                setState(() {});
              }
            },
            validator: (value) =>
                (value == null || value.trim().isEmpty) ? t('auth_required') : null,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(t('register_gender'), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          DropdownButtonFormField<String>(
            value: _gender,
            items: _genders
                .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                .toList(),
            onChanged: (v) => setState(() => _gender = v),
            decoration: const InputDecoration(),
            validator: (value) => value == null ? t('auth_required') : null,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(label: t('auth_next'), loading: _loading, onPressed: _submitBasic),
        ],
      ),
    );
  }

  Widget _buildContactStep(String Function(String) t) {
    final role = context.watch<AppState>().role ?? UserRole.elderly;
    final isElderly = role == UserRole.elderly;

    return Form(
      key: _contactFormKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(t('register_step_contact'),
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          Text(t('register_address'), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          TextFormField(
            controller: _addressController,
            maxLines: 2,
            validator: (value) =>
                (value == null || value.trim().isEmpty) ? t('auth_required') : null,
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _locating ? null : _useCurrentLocation,
              icon: _locating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
              label: Text(t('register_useCurrentLocation')),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(t('register_emergencyName'),
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          TextFormField(
            controller: _emergencyNameController,
            validator: (value) =>
                (value == null || value.trim().isEmpty) ? t('auth_required') : null,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(t('register_emergencyPhone'),
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          TextFormField(
            controller: _emergencyPhoneController,
            keyboardType: TextInputType.phone,
            validator: (value) {
              final v = value?.trim() ?? '';
              if (v.isEmpty) return t('auth_required');
              if (!Validators.isValidPhone(v)) return t('auth_invalidPhone');
              return null;
            },
          ),
          if (isElderly) ...[
            const SizedBox(height: AppSpacing.md),
            Text(t('register_accessibility'),
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            TextFormField(
              controller: _accessibilityController,
              maxLines: 2,
              decoration:
                  InputDecoration(hintText: t('register_accessibilityHint')),
            ),
            const SizedBox(height: AppSpacing.md),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(t('register_voiceAssistance')),
              value: _voiceAssistancePreferred,
              onChanged: (v) => setState(() => _voiceAssistancePreferred = v),
            ),
          ],
          if (!isElderly) ...[
            const SizedBox(height: AppSpacing.md),
            Text(t('register_relationship'),
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            TextFormField(
              controller: _relationshipController,
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? t('auth_required') : null,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(t('register_linkedIds'),
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            TextFormField(
              controller: _linkedIdsController,
              decoration: InputDecoration(hintText: t('register_linkedIdsHint')),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          AppButton(label: t('auth_next'), onPressed: _submitContact),
        ],
      ),
    );
  }

  Widget _buildOtpStep(String Function(String) t) {
    final canVerify = _otpValue.length == 6 && !_otpExpired && !_otpVerifying;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(t('register_otp_title'), style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(t('register_otp_hint'), style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.lg),
        if (_otpVerified)
          StatusBanner(message: t('otp_verified'), type: StatusBannerType.success),
        if (_otpError && !_otpVerified)
          StatusBanner(
              message: t('register_otp_invalid'), type: StatusBannerType.error),
        OtpInputField(
          key: _otpFieldKey,
          hasError: _otpError,
          enabled: !_otpExpired && !_otpVerifying && !_otpVerified,
          onChanged: (value) {
            setState(() {
              _otpValue = value;
              if (_otpError) _otpError = false;
            });
          },
        ),
        const SizedBox(height: AppSpacing.md),
        Align(
          alignment: Alignment.centerLeft,
          child: OtpCountdownTimer(
            key: _otpTimerKey,
            onExpire: () => setState(() => _otpExpired = true),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          label: t('otp_verify'),
          loading: _otpVerifying,
          onPressed: canVerify ? _submitOtp : null,
        ),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: TextButton(
            onPressed: _resending ? null : _resendOtp,
            child: _resending
                ? SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                : Text(t('otp_resend')),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordStep(String Function(String) t) {
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;
    final passwordOk = isPasswordValid(password);
    final passwordsMatch = confirm.isNotEmpty && password == confirm;
    final canFinish = passwordOk && passwordsMatch && !_loading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(t('register_createPassword_title'),
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.md),
        Text(t('register_createPassword'),
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        PasswordRequirementsView(password: password),
        const SizedBox(height: AppSpacing.md),
        Text(t('register_confirmPassword'),
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirm,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            suffixIcon: IconButton(
              icon: Icon(_obscureConfirm ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
          ),
        ),
        if (confirm.isNotEmpty && !passwordsMatch) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            t('register_passwordMismatch'),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: t('register_finish'),
          loading: _loading,
          onPressed: canFinish ? _submitPassword : null,
        ),
      ],
    );
  }

  Widget _buildSuccessStep(String Function(String) t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StatusBanner(message: t('register_success'), type: StatusBannerType.success),
        const SizedBox(height: AppSpacing.lg),
        Text(t('register_yourUserId'), style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _createdUserId ?? '',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          t('register_saveUserId'),
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(label: t('register_continueLogin'), onPressed: _finishToLogin),
      ],
    );
  }
}
