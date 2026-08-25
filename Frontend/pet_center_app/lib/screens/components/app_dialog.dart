import 'package:flutter/material.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/tokens.dart';

class AppDialog extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? content;
  final List<Widget> actions;
  final double? maxWidth;
  final bool scrollable;

  const AppDialog({
    super.key,
    required this.title,
    this.description,
    this.content,
    this.actions = const [],
    this.maxWidth,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final design = context.design;
    final width = maxWidth ?? design.dialogWidth;

    final body = Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (description != null)
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.sm),
              child: Text(
                description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ?content,
        ],
      ),
    );

    return Dialog(
      insetPadding: const EdgeInsets.all(Spacing.md),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: width,
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.lg,
                Spacing.md,
                Spacing.xs,
                Spacing.sm,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      softWrap: true,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(width: Spacing.xs),
                  IconButton(
                    tooltip: 'Close',
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: scheme.outlineVariant),
            Flexible(
              child: scrollable
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                      child: body,
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                      child: body,
                    ),
            ),
            if (actions.isNotEmpty) ...[
              Divider(height: 1, color: scheme.outlineVariant),
              Padding(
                padding: const EdgeInsets.all(Spacing.sm),
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: Spacing.xs,
                  runSpacing: Spacing.xs,
                  children: actions,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class DialogCancelButton extends StatelessWidget {
  final String label;

  const DialogCancelButton({super.key, this.label = 'Cancel'});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () => Navigator.of(context).pop(false),
      child: Text(label),
    );
  }
}

class DialogConfirmButton extends StatelessWidget {
  final String label;
  final VoidCallback onConfirm;
  final bool destructive;
  final IconData? icon;

  const DialogConfirmButton({
    super.key,
    required this.onConfirm,
    this.label = 'Confirm',
    this.destructive = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    void handle() {
      Navigator.of(context).pop(true);
      onConfirm();
    }

    final style = destructive
        ? FilledButton.styleFrom(
            backgroundColor: scheme.error,
            foregroundColor: scheme.onError,
          )
        : null;

    if (icon != null) {
      return FilledButton.icon(
        onPressed: handle,
        style: style,
        icon: Icon(icon, size: IconSizes.md),
        label: Text(label),
      );
    }

    return FilledButton(onPressed: handle, style: style, child: Text(label));
  }
}
