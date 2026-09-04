import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// A clean N-digit boxed OTP entry. Auto-advances focus as each digit is
/// typed, supports pasting the full code, and reports the combined code
/// via [onChanged]. Purely a frontend input control — OTP generation and
/// verification still live in AuthService.
class OtpInputField extends StatefulWidget {
  final int length;
  final ValueChanged<String> onChanged;
  final bool hasError;
  final bool enabled;

  const OtpInputField({
    super.key,
    this.length = 6,
    required this.onChanged,
    this.hasError = false,
    this.enabled = true,
  });

  @override
  State<OtpInputField> createState() => OtpInputFieldState();
}

class OtpInputFieldState extends State<OtpInputField> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  /// Clears every box — called by the parent screen after a wrong OTP
  /// or a resend, so the user retypes into a fresh field.
  void clear() {
    for (final c in _controllers) {
      c.clear();
    }
    if (widget.enabled) _focusNodes.first.requestFocus();
    widget.onChanged('');
  }

  String _currentCode() => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      // A paste landed in a single box — spread it across all boxes.
      final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
      for (var i = 0; i < widget.length; i++) {
        _controllers[i].text = i < digits.length ? digits[i] : '';
      }
      final lastFilled = digits.length.clamp(0, widget.length) - 1;
      if (lastFilled >= 0 && lastFilled < widget.length - 1) {
        _focusNodes[lastFilled + 1].requestFocus();
      } else {
        FocusScope.of(context).unfocus();
      }
      widget.onChanged(_currentCode());
      return;
    }
    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isNotEmpty && index == widget.length - 1) {
      FocusScope.of(context).unfocus();
    } else if (value.isEmpty && index > 0) {
      // Backspace cleared this box — hop back so the user can keep
      // deleting digits without re-tapping each box.
      _focusNodes[index - 1].requestFocus();
    }
    widget.onChanged(_currentCode());
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!.colors;
    final borderColor = widget.hasError ? colors.danger : colors.border;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (index) {
        return SizedBox(
          width: 44,
          height: 56,
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            enabled: widget.enabled,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: widget.length,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: Theme.of(context).textTheme.titleLarge,
            decoration: InputDecoration(
              counterText: '',
              contentPadding: EdgeInsets.zero,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.sm),
                borderSide: BorderSide(color: borderColor, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.sm),
                borderSide: BorderSide(
                  color: widget.hasError ? colors.danger : colors.primary,
                  width: 2,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.sm),
                borderSide: BorderSide(color: colors.border.withOpacity(0.5)),
              ),
            ),
            onChanged: (v) => _onDigitChanged(index, v),
          ),
        );
      }),
    );
  }
}
