import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../localization/app_localizations.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_card.dart';
import '../../widgets/ne_pattern_strip.dart';
import 'elderly_tab_controller.dart';

class ElderlyHomeScreen extends StatelessWidget {
  const ElderlyHomeScreen({super.key});

  // Rotates by day-of-year so it feels fresh without needing a backend.
  static const List<String> _tipKeys = [
    'elderlyHome_tip1',
    'elderlyHome_tip2',
    'elderlyHome_tip3',
    'elderlyHome_tip4',
    'elderlyHome_tip5',
    'elderlyHome_tip6',
    'elderlyHome_tip7',
  ];

  String _tipOfTheDayKey() {
    final dayOfYear =
        DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return _tipKeys[dayOfYear % _tipKeys.length];
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).t;
    final colors = Theme.of(context).extension<AppColorsExtension>()!.colors;

    final items = [
      ('elderlyHome_games', '🧩', 1),
      ('elderlyHome_reminders', '⏰', 2),
      ('elderlyHome_progress', '📈', 3),
      ('elderlyHome_settings', '⚙️', 4),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.sm),
            const NePatternStrip(),
            const SizedBox(height: AppSpacing.md),
            Text(t('elderlyHome_greeting'), style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(t('elderlyHome_subtitle'), style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.xl),
            // Fixed (non-expanded) height grid so it can sit above the tip
            // card instead of eating all remaining space.
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              // Slightly shorter ratio number = taller cells, which was
              // the actual fix for the "BOTTOM OVERFLOWED BY 1.0 PIXELS"
              // error (cards didn't have quite enough vertical room for
              // icon + spacing + label at the old 1.05 ratio).
              childAspectRatio: 0.92,
              children: items.map((item) {
                final (key, icon, tabIndex) = item;
                return AppCard(
                  onTap: () => ElderlyTabController.of(context)?.goToTab(tabIndex),
                  // Smaller padding than AppCard's 24px default frees up
                  // the vertical room the fixed-height grid cell needs.
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(icon, style: const TextStyle(fontSize: 40)),
                      const SizedBox(height: AppSpacing.sm),
                      // Flexible + maxLines as a safety net: if a label
                      // ever runs long in another language, it shrinks
                      // instead of overflowing again.
                      Flexible(
                        child: Text(
                          t(key),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            // "Tip for today" — fills the empty space below the grid with
            // something actually useful rather than just decoration.
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: colors.secondary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    border: Border.all(color: colors.accentAmber, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Text('💡', style: TextStyle(fontSize: 22)),
                          const SizedBox(width: AppSpacing.sm),
                          Text(t('elderlyHome_tipTitle'),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        t(_tipOfTheDayKey()),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
