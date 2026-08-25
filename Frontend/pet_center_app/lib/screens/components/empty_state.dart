import 'package:flutter/material.dart';
import 'package:pet_center_app/utils/tokens.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  const EmptyState({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHigh,
                    borderRadius: Radii.mdAll,
                  ),
                  child: Icon(
                    icon,
                    size: IconSizes.lg,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: Spacing.md),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                if (actionLabel != null || secondaryActionLabel != null) ...[
                  const SizedBox(height: Spacing.md),
                  Wrap(
                    spacing: Spacing.xs,
                    runSpacing: Spacing.xs,
                    alignment: WrapAlignment.center,
                    children: [
                      if (secondaryActionLabel != null)
                        OutlinedButton(
                          onPressed: onSecondaryAction,
                          child: Text(secondaryActionLabel!),
                        ),
                      if (actionLabel != null)
                        FilledButton(
                          onPressed: onAction,
                          child: Text(actionLabel!),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
