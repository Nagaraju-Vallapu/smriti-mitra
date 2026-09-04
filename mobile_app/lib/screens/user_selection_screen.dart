import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localization/app_localizations.dart';
import '../models/user_role.dart';
import '../navigation/app_state.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_card.dart';
import '../widgets/ne_pattern_strip.dart';
import '../utils/constants.dart';

class UserSelectionScreen extends StatelessWidget {
  const UserSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).t;
    final appState = context.read<AppState>();

    Future<void> selectRole(UserRole role) async {
      await appState.setRole(role);
      if (context.mounted) {
        // Role chosen → Login comes next (per the app's auth flow), not
        // straight into the shell. LoginScreen/RegisterWizardScreen read
        // appState.role to know which shell to land in afterwards.
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    }

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
              Text(t('userSelect_title'),
                  style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.sm),
              Text(t('userSelect_subtitle'),
                  style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.xxl),
              AppCard(
                onTap: () => selectRole(UserRole.elderly),
                child: Column(
                  children: [
                    const Text('🧓', style: TextStyle(fontSize: 56)),
                    const SizedBox(height: AppSpacing.md),
                    Text(t('userSelect_elderly'),
                        style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                onTap: () => selectRole(UserRole.caregiver),
                child: Column(
                  children: [
                    const Text('🩺', style: TextStyle(fontSize: 56)),
                    const SizedBox(height: AppSpacing.md),
                    Text(t('userSelect_caregiver'),
                        style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
