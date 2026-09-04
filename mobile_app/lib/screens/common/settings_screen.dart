import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../localization/app_localizations.dart';
import '../../localization/supported_locales.dart';
import '../../models/accessibility_settings.dart';
import '../../models/user_role.dart';
import '../../navigation/app_state.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/ne_pattern_strip.dart';
import 'profile_screen.dart';
import '../../utils/constants.dart';

/// Shared Settings screen used by BOTH the Elderly and Caregiver flows —
/// per the spec, both roles have a "Settings" section with identical
/// underlying functionality (language, text size, high contrast, voice
/// assistance, voice speed, reminder notifications, offline data,
/// clear-offline-data with confirmation, logout).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmClearData(BuildContext context) async {
    // NOTE: intentionally context.read (not AppLocalizations.of, which
    // uses context.watch internally). watch() is only legal during a
    // widget's build phase — calling it from a button's onPressed
    // callback throws "Tried to listen to a value exposed with
    // provider, from outside of the widget tree", which aborted this
    // whole method before showDialog ever ran, so the button appeared
    // to do nothing.
    final t = context.read<AppState>().localizations.t;
    final appState = context.read<AppState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t('settings_clearOfflineData')),
        content: Text(t('settings_clearOfflineDataConfirm')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(t('common_cancel'))),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t('common_delete'), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await appState.clearOfflineData();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t('settings_clearOfflineDataSuccess'))),
        );
      }
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    // See note in _confirmClearData above — must use read, not watch.
    final t = context.read<AppState>().localizations.t;
    final appState = context.read<AppState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(t('settings_logoutConfirm')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(t('common_no'))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(t('common_yes'))),
        ],
      ),
    );

    if (confirmed == true) {
      await appState.logout();
      if (context.mounted) {
        // rootNavigator: true so this always targets the app's top-level
        // Navigator, even though SettingsScreen is nested inside the
        // Elderly/Caregiver shell's IndexedStack.
        Navigator.of(context, rootNavigator: true)
            .pushNamedAndRemoveUntil(AppRoutes.userSelect, (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).t;
    final appState = context.watch<AppState>();
    final settings = appState.accessibility;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('settings_title')),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(14),
          child: NePatternStrip(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          // Extra bottom padding so the Logout button never sits under the
          // floating voice-assistant mic button (it previously did, which
          // made taps near the bottom of the screen hit the FAB instead of
          // Logout — the most common reason "Logout does nothing").
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xxl + 56),
          children: [
            // Profile
            AppCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person_outline, size: 32),
                title: Text(t('profile_title'), style: Theme.of(context).textTheme.titleLarge),
                subtitle: Text(t('profile_subtitle')),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Language
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t('settings_language'), style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: kSupportedLanguages.map((lang) {
                      final selected = lang.code == appState.locale.languageCode;
                      return ChoiceChip(
                        label: Text(lang.label),
                        selected: selected,
                        onSelected: (_) => appState.setLanguage(lang.code),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Text size
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t('settings_textSize'), style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: AppTextSize.values.map((size) {
                      final selected = size == settings.textSize;
                      return ChoiceChip(
                        label: Text(t('settings_textSize_${size.storageValue}')),
                        selected: selected,
                        onSelected: (_) =>
                            appState.updateAccessibility(settings.copyWith(textSize: size)),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // High contrast
            AppCard(
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(t('settings_highContrast'), style: Theme.of(context).textTheme.titleLarge),
                value: settings.highContrast,
                onChanged: (value) =>
                    appState.updateAccessibility(settings.copyWith(highContrast: value)),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Voice assistance + speed
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(t('settings_voiceAssistance'),
                        style: Theme.of(context).textTheme.titleLarge),
                    value: settings.voiceAssistanceEnabled,
                    onChanged: (value) => appState
                        .updateAccessibility(settings.copyWith(voiceAssistanceEnabled: value)),
                  ),
                  if (settings.voiceAssistanceEnabled) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(t('settings_voiceSpeed'), style: Theme.of(context).textTheme.bodyLarge),
                    Slider(
                      value: settings.voiceSpeed,
                      min: 0.25,
                      max: 1.0,
                      divisions: 15,
                      label: settings.voiceSpeed.toStringAsFixed(2),
                      onChanged: (value) =>
                          appState.updateAccessibility(settings.copyWith(voiceSpeed: value)),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Reminder notifications
            AppCard(
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(t('settings_reminderNotifications'),
                    style: Theme.of(context).textTheme.titleLarge),
                value: settings.reminderNotificationsEnabled,
                onChanged: (value) => appState
                    .updateAccessibility(settings.copyWith(reminderNotificationsEnabled: value)),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Offline data
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t('settings_offlineData'), style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: t('settings_clearOfflineData'),
                    onPressed: () => _confirmClearData(context),
                    variant: AppButtonVariant.outline,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            AppButton(
              label: t('common_logout'),
              onPressed: () => _confirmLogout(context),
              variant: AppButtonVariant.danger,
            ),
          ],
        ),
      ),
    );
  }
}
