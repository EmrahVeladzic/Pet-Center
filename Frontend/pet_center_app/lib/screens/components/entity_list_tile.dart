import 'package:flutter/material.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/tokens.dart';

class EntityAction {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool destructive;

  const EntityAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.destructive = false,
  });
}

class EntityActionBar extends StatelessWidget {
  final List<EntityAction> actions;

  const EntityActionBar({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final action in actions)
          IconButton(
            tooltip: action.tooltip,
            icon: Icon(action.icon),
            onPressed: action.onPressed,
            style: action.destructive
                ? IconButton.styleFrom(foregroundColor: scheme.error)
                : null,
          ),
      ],
    );
  }
}

class EntityListTile extends StatefulWidget {
  final IconData icon;
  final Widget? leading;
  final bool visited;
  final String title;
  final String? subtitle;
  final List<Widget> chips;
  final List<EntityAction> actions;
  final VoidCallback? onTap;
  final Widget? expanded;

  const EntityListTile({
    super.key,
    required this.icon,
    this.leading,
    this.visited = false,
    required this.title,
    this.subtitle,
    this.chips = const [],
    this.actions = const [],
    this.onTap,
    this.expanded,
  });

  @override
  State<EntityListTile> createState() => _EntityListTileState();
}

class _EntityListTileState extends State<EntityListTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final design = context.design;

    final header = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        widget.leading ??
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
                borderRadius: Radii.smAll,
              ),
              child: Icon(
                widget.icon,
                size: IconSizes.md,
                color: scheme.onSurfaceVariant,
              ),
            ),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                softWrap: true,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall,
              ),
              if (widget.subtitle != null) ...[
                const SizedBox(height: Spacing.xxs),
                Text(
                  widget.subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (widget.chips.isNotEmpty) ...[
          const SizedBox(width: Spacing.xs),
          Wrap(
            spacing: Spacing.xxs,
            runSpacing: Spacing.xxs,
            children: widget.chips,
          ),
        ],
        if (widget.actions.isNotEmpty) ...[
          const SizedBox(width: Spacing.xs),
          EntityActionBar(actions: widget.actions),
        ],
      ],
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.onTap == null
          ? MouseCursor.defer
          : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          padding: EdgeInsets.all(design.spacing),
          decoration: BoxDecoration(
            color: _hovered
                ? scheme.surfaceContainerLow
                : (widget.visited ? scheme.surfaceContainer : scheme.surface),
            borderRadius: Radii.mdAll,
            border: Border.all(
              color: _hovered && widget.onTap != null
                  ? scheme.primary
                  : scheme.outlineVariant,
            ),
          ),
          child: widget.expanded == null
              ? header
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    header,
                    const SizedBox(height: Spacing.sm),
                    Divider(height: 1, color: scheme.outlineVariant),
                    const SizedBox(height: Spacing.sm),
                    widget.expanded!,
                  ],
                ),
        ),
      ),
    );
  }
}

class ResponsiveActionBar extends StatelessWidget {
  final List<EntityAction> actions;
  final bool forceLabels;

  const ResponsiveActionBar({
    super.key,
    required this.actions,
    this.forceLabels = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final visible = actions.where((a) => a.onPressed != null).toList();

    if (visible.isEmpty) {
      return const SizedBox.shrink();
    }

    if (!forceLabels && !context.design.isCompact) {
      return Wrap(
        alignment: WrapAlignment.end,
        spacing: Spacing.xxs,
        runSpacing: Spacing.xxs,
        children: [
          for (final action in visible)
            IconButton(
              tooltip: action.tooltip,
              icon: Icon(action.icon),
              onPressed: action.onPressed,
              style: action.destructive
                  ? IconButton.styleFrom(foregroundColor: scheme.error)
                  : null,
            ),
        ],
      );
    }

    return Wrap(
      spacing: Spacing.xs,
      runSpacing: Spacing.xs,
      children: [
        for (final action in visible)
          OutlinedButton.icon(
            onPressed: action.onPressed,
            icon: Icon(action.icon, size: IconSizes.md),
            label: Text(action.tooltip),
            style: action.destructive
                ? OutlinedButton.styleFrom(
                    foregroundColor: scheme.error,
                    side: BorderSide(color: scheme.error),
                  )
                : null,
          ),
      ],
    );
  }
}
