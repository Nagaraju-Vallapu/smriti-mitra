import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localization/app_localizations.dart';
import '../localization/supported_locales.dart';
import '../navigation/app_state.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_button.dart';
import '../widgets/ne_pattern_strip.dart';
import '../utils/constants.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  late String _selectedCode;

  @override
  void initState() {
    super.initState();
    _selectedCode = context.read<AppState>().locale.languageCode;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).t;
    final appState = context.watch<AppState>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.sm),
              const NePatternStrip(),
              const SizedBox(height: AppSpacing.lg),
              Text(t('language_title'),
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.sm),
              Text(t('language_subtitle'),
                  style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: ListView.separated(
                  itemCount: kSupportedLanguages.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final lang = kSupportedLanguages[index];
                    final selected = lang.code == _selectedCode;
                    return _LanguageTile(
                      label: lang.label,
                      selected: selected,
                      onTap: () => setState(() => _selectedCode = lang.code),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: t('language_continue'),
                onPressed: () async {
                  await appState.setLanguage(_selectedCode);
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed(AppRoutes.userSelect);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageTile({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary.withOpacity(0.1) : theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? theme.colorScheme.primary : theme.dividerColor,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: theme.textTheme.titleLarge?.copyWith(
                      color: selected ? theme.colorScheme.primary : null)),
            ),
            if (selected) Icon(Icons.check_circle, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
