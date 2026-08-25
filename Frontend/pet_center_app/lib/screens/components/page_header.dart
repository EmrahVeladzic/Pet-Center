import 'package:flutter/material.dart';
import 'package:pet_center_app/utils/tokens.dart';

class PageHeader extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? search;
  final List<Widget> actions;
  final Widget? leading;

  static const double _stackBelow = 720;

  const PageHeader({
    super.key,
    required this.title,
    this.description,
    this.search,
    this.actions = const [],
    this.leading,
  });

  Widget _titleBlock(BuildContext context, {required bool compact}) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: Spacing.xs),
            ],
            Expanded(
              child: Text(
                title,
                softWrap: true,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: compact
                    ? theme.textTheme.titleLarge
                    : theme.textTheme.headlineSmall,
              ),
            ),
          ],
        ),
        if (description != null) ...[
          const SizedBox(height: Spacing.xxs),
          Text(
            description!,
            softWrap: true,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final stacked = available < _stackBelow;

        final trailing = <Widget>[
          if (search != null)
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: stacked ? available : 360,
                minWidth: 0,
              ),
              child: search!,
            ),
          ...actions,
        ];

        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _titleBlock(context, compact: true),
              if (trailing.isNotEmpty) ...[
                const SizedBox(height: Spacing.sm),
                Wrap(
                  spacing: Spacing.xs,
                  runSpacing: Spacing.xs,
                  children: trailing,
                ),
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: _titleBlock(context, compact: false)),
            if (trailing.isNotEmpty) ...[
              const SizedBox(width: Spacing.md),
              Flexible(
                flex: 2,
                child: Wrap(
                  spacing: Spacing.xs,
                  runSpacing: Spacing.xs,
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: trailing,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
