import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localization/app_localizations.dart';
import '../navigation/app_state.dart';
import '../services/voice_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Global voice-assistant UI, opened as a modal bottom sheet from a
/// floating mic button on both the Elderly and Caregiver shells. Reflects
/// VoiceService's five required states (idle/listening/processing/
/// speaking/error) and calls [onCommand] with an interpreted command key
/// (see VoiceCommandInterpreter) so the shell can navigate.
Future<void> showVoiceAssistantSheet(
  BuildContext context, {
  required void Function(String commandKey) onCommand,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => VoiceAssistantSheet(onCommand: onCommand),
  );
}

class VoiceAssistantSheet extends StatefulWidget {
  final void Function(String commandKey) onCommand;
  const VoiceAssistantSheet({super.key, required this.onCommand});

  @override
  State<VoiceAssistantSheet> createState() => _VoiceAssistantSheetState();
}

class _VoiceAssistantSheetState extends State<VoiceAssistantSheet> {
  final VoiceService _voice = VoiceService.instance;

  @override
  void initState() {
    super.initState();
    _voice.addListener(_onVoiceStateChanged);
  }

  @override
  void dispose() {
    _voice.removeListener(_onVoiceStateChanged);
    super.dispose();
  }

  void _onVoiceStateChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _handleTap() async {
    if (_voice.state == VoiceState.listening) {
      await _voice.stopListening();
      return;
    }

    await _voice.startListening(
      onResult: (text) {
        final commandKey = VoiceCommandInterpreter.interpret(text);
        if (commandKey != null) {
          widget.onCommand(commandKey);
          if (mounted) Navigator.of(context).pop();
        }
      },
    );
  }

  String _stateLabel(String Function(String) t) {
    switch (_voice.state) {
      case VoiceState.idle:
        return t('voice_tapToSpeak');
      case VoiceState.listening:
        return t('voice_listening');
      case VoiceState.processing:
        return t('voice_processing');
      case VoiceState.speaking:
        return t('voice_speaking');
      case VoiceState.error:
        return _voice.isListeningSupported ? t('voice_error') : t('voice_unsupported');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).t;
    final colors =
        Theme.of(context).extension<AppColorsExtension>()?.colors ?? AppColors.standard;
    final appState = context.watch<AppState>();

    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xl),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(color: colors.border, borderRadius: BorderRadius.circular(3)),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(t('voice_title'), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            t('voice_tryCommand'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xl),
          GestureDetector(
            onTap: _handleTap,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _voice.state == VoiceState.listening
                    ? colors.accentAmber
                    : _voice.state == VoiceState.error
                        ? colors.textMuted
                        : colors.primary,
              ),
              child: const Icon(Icons.mic, size: 48, color: Colors.white),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(_stateLabel(t), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          if (appState.accessibility.voiceAssistanceEnabled == false)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                t('voice_error'),
                style: TextStyle(color: colors.textMuted),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
