import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';
import '../theme/app_spacing.dart';
import 'app_button.dart';

class LoadingState extends StatelessWidget {
  final String? message;
  const LoadingState({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).t;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: AppSpacing.md),
            Text(message ?? t('common_loading'), style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class ErrorStateView extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;
  const ErrorStateView({super.key, this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).t;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 40)),
            const SizedBox(height: AppSpacing.md),
            Text(
              message ?? t('common_error'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: 200,
                child: AppButton(
                  label: t('common_retry'),
                  onPressed: onRetry,
                  variant: AppButtonVariant.outline,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyStateView extends StatelessWidget {
  final String? message;
  final String icon;
  const EmptyStateView({super.key, this.message, this.icon = '📋'});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).t;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: AppSpacing.md),
            Text(
              message ?? t('common_empty'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
