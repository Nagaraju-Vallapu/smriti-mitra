import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../navigation/app_state.dart';
import '../../services/auth_service.dart';
import '../../theme/app_spacing.dart';
import '../../utils/validators.dart';
import '../../widgets/app_button.dart';
import '../../widgets/ne_pattern_strip.dart';
import '../../widgets/otp_countdown_timer.dart';
import '../../widgets/otp_input_field.dart';
import '../../widgets/password_requirements_view.dart';
import '../../widgets/status_banner.dart';

/// Forgot-password flow: registered Gmail → OTP → new password, matching
/// the hand-drawn flow. Same one-screen-with-steps approach as
/// RegisterWizardScreen for the same reason.
class ForgotPasswordWizardScreen extends StatefulWidget {
  const ForgotPasswordWizardScreen({super.key});

  @override
  State<ForgotPasswordWizardScreen> createState() => _ForgotPasswordWizardScreenState();
}

class _ForgotPasswordWizardScreenState extends State<ForgotPasswordWizardScreen> {
  int _step = 0; // 0=gmail, 1=otp, 2=new password
  bool _loading = false;
  String? _generatedOtp;

  final _gmailFormKey = GlobalKey<FormState>();
  final _gmailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  // OTP step state.
  final _otpFieldKey = GlobalKey<OtpInputFieldState>();
  final _otpTimerKey = GlobalKey<OtpCountdownTimerState>();
  String _otpValue = '';
  bool _otpError = false;
  bool _otpVerifying = false;
  bool _otpVerified = false;
  bool _otpExpired = false;
  bool _resending = false;

  @override
  void dispose() {
    _gmailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submitGmail() async {
    final t = context.read<AppState>().localizations.t;
    if (!(_gmailFormKey.currentState?.validate() ?? false)) {
      _snack(t('register_detailsInvalid'));
      return;
    }
    setState(() => _loading = true);
    final exists = await AuthService.instance.emailExists(_gmailController.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (!exists) {
      _snack(t('forgot_emailNotFound'));
      return;
    }
    _sendOtp();
    setState(() => _step = 1);
  }

  /// Demo OTP — see AuthService doc: shown on-screen since there's no
  /// SMS/email gateway to actually send it through yet.
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
    setState(() => _step = 2);
  }

  Future<void> _submitNewPassword() async {
    final t = context.read<AppState>().localizations.t;

    setState(() => _loading = true);
    await AuthService.instance.resetPassword(
      gmail: _gmailController.text,
      newPassword: _passwordController.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);

    _snack(t('forgot_success'));
    // ForgotPasswordWizardScreen is always reached via push from
    // LoginScreen, so popping lands exactly back there.
    Navigator.of(context).pop();
  }

  void _back() {
    if (_step == 0) {
      Navigator.of(context).pop();
    } else {
      setState(() => _step -= 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppState>().localizations.t;

    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _step -= 1);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(t('forgot_title')),
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _back),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(14),
            child: NePatternStrip(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: _step == 0
                ? _buildGmailStep(t)
                : (_step == 1 ? _buildOtpStep(t) : _buildNewPasswordStep(t)),
          ),
        ),
      ),
    );
  }

  Widget _buildGmailStep(String Function(String) t) {
    return Form(
      key: _gmailFormKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(t('forgot_gmail'), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          TextFormField(
            controller: _gmailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              final v = value?.trim() ?? '';
              if (v.isEmpty) return t('auth_required');
              if (!Validators.isValidEmailOrPhone(v)) return t('auth_invalidEmail');
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(label: t('auth_next'), loading: _loading, onPressed: _submitGmail),
        ],
      ),
    );
  }

  Widget _buildOtpStep(String Function(String) t) {
    final canVerify = _otpValue.length == 6 && !_otpExpired && !_otpVerifying;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(t('forgot_otp_title'), style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(t('register_otp_hint'), style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.lg),
        if (_otpVerified) StatusBanner(message: t('otp_verified'), type: StatusBannerType.success),
        if (_otpError && !_otpVerified)
          StatusBanner(message: t('register_otp_invalid'), type: StatusBannerType.error),
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

  Widget _buildNewPasswordStep(String Function(String) t) {
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;
    final passwordOk = isPasswordValid(password);
    final passwordsMatch = confirm.isNotEmpty && password == confirm;
    final canFinish = passwordOk && passwordsMatch && !_loading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(t('forgot_newPassword_title'), style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.md),
        Text(t('forgot_newPassword'), style: Theme.of(context).textTheme.titleMedium),
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
        Text(t('forgot_confirmPassword'), style: Theme.of(context).textTheme.titleMedium),
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
          onPressed: canFinish ? _submitNewPassword : null,
        ),
      ],
    );
  }
}
