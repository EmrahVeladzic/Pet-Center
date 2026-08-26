import 'package:flutter/material.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/tokens.dart';

enum StatusTone { success, warning, danger, neutral, info }

class StatusChip extends StatelessWidget {
  final String label;
  final StatusTone tone;
  final IconData? icon;
  final bool showDot;

  const StatusChip({
    super.key,
    required this.label,
    this.tone = StatusTone.neutral,
    this.icon,
    this.showDot = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final design = context.design;
    final status = design.status;

    final (Color fg, Color bg) = switch (tone) {
      StatusTone.success => (
        status.onSuccessContainer,
        status.successContainer,
      ),
      StatusTone.warning => (
        status.onWarningContainer,
        status.warningContainer,
      ),
      StatusTone.danger => (status.onDangerContainer, status.dangerContainer),
      StatusTone.info => (
        theme.colorScheme.onPrimaryContainer,
        theme.colorScheme.primaryContainer,
      ),
      StatusTone.neutral => (
        status.onNeutralContainer,
        status.neutralContainer,
      ),
    };

    final Color accent = switch (tone) {
      StatusTone.success => status.success,
      StatusTone.warning => status.warning,
      StatusTone.danger => status.danger,
      StatusTone.info => theme.colorScheme.primary,
      StatusTone.neutral => status.neutral,
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.xs,
        vertical: Spacing.xxs,
      ),
      decoration: BoxDecoration(color: bg, borderRadius: Radii.pillAll),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: IconSizes.sm, color: accent),
            const SizedBox(width: Spacing.xxs),
          ] else if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            ),
            const SizedBox(width: Spacing.xxs),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(color: fg),
            ),
          ),
        ],
      ),
    );
  }
}
