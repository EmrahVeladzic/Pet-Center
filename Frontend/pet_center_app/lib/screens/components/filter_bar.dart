import 'package:flutter/material.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/tokens.dart';

class FilterBar extends StatelessWidget {
  final List<Widget> children;
  final double targetColumnWidth;

  const FilterBar({
    super.key,
    required this.children,
    this.targetColumnWidth = 220,
  });

  @override
  Widget build(BuildContext context) {
    final design = context.design;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: design.spacing,
        vertical: Spacing.sm,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final available = constraints.hasBoundedWidth
              ? constraints.maxWidth
              : MediaQuery.sizeOf(context).width;

          const spacing = Spacing.sm;

          int columns = ((available + spacing) / (targetColumnWidth + spacing))
              .floor();
          if (columns < 1) columns = 1;
          if (columns > children.length) columns = children.length;

          final itemWidth = (available - (spacing * (columns - 1))) / columns;

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final child in children)
                SizedBox(width: itemWidth, child: child),
            ],
          );
        },
      ),
    );
  }
}

class FilterField extends StatelessWidget {
  final Widget child;
  final double minWidth;
  final double maxWidth;
  final bool expand;

  const FilterField({
    super.key,
    required this.child,
    this.minWidth = 180,
    this.maxWidth = 280,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) => child;
}

class FilterToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const FilterToggle({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: Radii.smAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.xs,
          vertical: Spacing.xxs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: value,
              onChanged: onChanged,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: Spacing.xs),
            Flexible(
              child: Text(
                label,
                softWrap: true,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
