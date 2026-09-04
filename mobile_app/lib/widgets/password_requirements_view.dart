import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class _PasswordRequirement {
  final String labelKey;
  final bool Function(String) test;
  const _PasswordRequirement(this.labelKey, this.test);
}

/// The five password rules shown live by [PasswordRequirementsView].
/// Kept as a top-level list (rather than private to the widget) so
/// callers like a "Finish" button can gate on [isPasswordValid] without
/// duplicating the regexes.
final List<_PasswordRequirement> _passwordRequirements = [
  _PasswordRequirement('password_req_minLength', (p) => p.length >= 6),
  _PasswordRequirement('password_req_uppercase', (p) => p.contains(RegExp(r'[A-Z]'))),
  _PasswordRequirement('password_req_lowercase', (p) => p.contains(RegExp(r'[a-z]'))),
  _PasswordRequirement('password_req_number', (p) => p.contains(RegExp(r'[0-9]'))),
  _PasswordRequirement(
    'password_req_special',
    (p) => p.contains(RegExp(r'''[!@#$%^&*(),.?":{}|<>_\-+=\[\];'`~/\\]''')),
  ),
];

/// True only when every requirement (min length, upper/lowercase,
/// number, special character) is satisfied.
bool isPasswordValid(String password) =>
    _passwordRequirements.every((r) => r.test(password));

/// Live checklist of password requirements, each with a ✓ once met.
/// Purely visual feedback — the actual gate is [isPasswordValid], used
/// by the screen to enable/disable its submit button.
class PasswordRequirementsView extends StatelessWidget {
  final String password;
  const PasswordRequirementsView({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).t;
    final colors = Theme.of(context).extension<AppColorsExtension>()!.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _passwordRequirements.map((req) {
        final met = req.test(password);
        return Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: Row(
            children: [
              Icon(
                met ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 18,
                color: met ? colors.success : colors.textMuted,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                t(req.labelKey),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: met ? colors.success : colors.textMuted,
                    ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
