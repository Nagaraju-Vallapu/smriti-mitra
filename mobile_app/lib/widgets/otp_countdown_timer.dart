import 'dart:async';
import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';
import '../theme/app_colors.dart';

/// Frontend-only OTP countdown, e.g. "OTP expires in 04:59". Purely
/// cosmetic for this demo build: there is no backend OTP expiry (see
/// AuthService docs), so this never actually invalidates the OTP
/// server-side — it just gates the Verify/Resend buttons client-side so
/// the flow *feels* like a real OTP expiry.
class OtpCountdownTimer extends StatefulWidget {
  final int totalSeconds;
  final VoidCallback? onExpire;

  const OtpCountdownTimer({
    super.key,
    this.totalSeconds = 299, // 04:59
    this.onExpire,
  });

  @override
  State<OtpCountdownTimer> createState() => OtpCountdownTimerState();
}

class OtpCountdownTimerState extends State<OtpCountdownTimer> {
  late int _secondsLeft;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.totalSeconds;
    _start();
  }

  void _start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        setState(() => _secondsLeft = 0);
        timer.cancel();
        widget.onExpire?.call();
      } else {
        setState(() => _secondsLeft -= 1);
      }
    });
  }

  /// Restarts the countdown from the top — called by the parent screen
  /// right after a successful Resend.
  void restart() {
    setState(() => _secondsLeft = widget.totalSeconds);
    _start();
  }

  bool get isExpired => _secondsLeft <= 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).t;
    final colors = Theme.of(context).extension<AppColorsExtension>()!.colors;
    final minutes = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');

    if (_secondsLeft <= 0) {
      return Text(
        t('otp_expired'),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors.danger,
              fontWeight: FontWeight.bold,
            ),
      );
    }
    return Text(
      '${t('otp_expiresIn')} $minutes:$seconds',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.textMuted),
    );
  }
}
