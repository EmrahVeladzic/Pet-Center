import 'package:flutter/material.dart';
import 'package:pet_center_app/screens/components/app_dialog.dart';
import 'package:pet_center_app/utils/tokens.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String body;
  final VoidCallback confirmAction;
  final bool destructive;
  final String confirmLabel;
  final String? consequence;

  const ConfirmationDialog({
    super.key,
    required this.confirmAction,
    this.title = 'Confirm',
    this.body = 'Are you sure you want to do this?',
    this.destructive = false,
    this.confirmLabel = 'Confirm',
    this.consequence,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AppDialog(
      title: title,
      description: body,
      content: consequence == null
          ? null
          : Container(
              padding: const EdgeInsets.all(Spacing.sm),
              decoration: BoxDecoration(
                color: scheme.errorContainer,
                borderRadius: Radii.smAll,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: IconSizes.md,
                    color: scheme.onErrorContainer,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Expanded(
                    child: Text(
                      consequence!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
      actions: [
        const DialogCancelButton(),
        DialogConfirmButton(
          onConfirm: confirmAction,
          label: confirmLabel,
          destructive: destructive,
        ),
      ],
    );
  }
}
