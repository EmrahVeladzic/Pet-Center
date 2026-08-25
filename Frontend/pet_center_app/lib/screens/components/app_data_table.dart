import 'package:flutter/material.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/tokens.dart';

class DataColumnSpec<T> {
  final String label;
  final int flex;
  final double? width;
  final Alignment alignment;
  final Widget Function(BuildContext context, T item) cell;
  final bool hideOnMedium;

  const DataColumnSpec({
    required this.label,
    required this.cell,
    this.flex = 3,
    this.width,
    this.alignment = Alignment.centerLeft,
    this.hideOnMedium = false,
  });
}

class AppDataTable<T> extends StatelessWidget {
  final List<DataColumnSpec<T>> columns;
  final List<T> items;
  final void Function(T item)? onRowTap;
  final ScrollController? controller;

  const AppDataTable({
    super.key,
    required this.columns,
    required this.items,
    this.onRowTap,
    this.controller,
  });

  List<DataColumnSpec<T>> _visibleColumns(ReactiveDesignSystem design) {
    if (design.windowClass == WindowClass.medium) {
      return columns.where((c) => !c.hideOnMedium).toList();
    }
    return columns;
  }

  Widget _cellWrap(DataColumnSpec<T> spec, Widget child) {
    if (spec.width != null) {
      return SizedBox(
        width: spec.width,
        child: Align(alignment: spec.alignment, child: child),
      );
    }
    return Expanded(
      flex: spec.flex,
      child: Align(alignment: spec.alignment, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final design = context.design;
    final visible = _visibleColumns(design);
    final inset = design.spacing;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: Radii.mdAll,
        border: Border.all(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            color: scheme.surfaceContainerLow,
            padding: EdgeInsets.symmetric(
              horizontal: inset,
              vertical: Spacing.sm,
            ),
            child: Row(
              children: [
                for (final spec in visible)
                  _cellWrap(
                    spec,
                    Text(
                      spec.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Divider(height: 1, color: scheme.outlineVariant),
          Expanded(
            child: ListView.separated(
              controller: controller,
              itemCount: items.length,
              separatorBuilder: (_, _) =>
                  Divider(height: 1, color: scheme.outlineVariant),
              itemBuilder: (context, index) {
                final item = items[index];
                return _TableRow<T>(
                  item: item,
                  visible: visible,
                  inset: inset,
                  cellWrap: _cellWrap,
                  onTap: onRowTap == null ? null : () => onRowTap!(item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TableRow<T> extends StatefulWidget {
  final T item;
  final List<DataColumnSpec<T>> visible;
  final double inset;
  final Widget Function(DataColumnSpec<T> spec, Widget child) cellWrap;
  final VoidCallback? onTap;

  const _TableRow({
    required this.item,
    required this.visible,
    required this.inset,
    required this.cellWrap,
    this.onTap,
  });

  @override
  State<_TableRow<T>> createState() => _TableRowState<T>();
}

class _TableRowState<T> extends State<_TableRow<T>> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

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
          color: _hovered ? scheme.surfaceContainerLow : scheme.surface,
          padding: EdgeInsets.symmetric(
            horizontal: widget.inset,
            vertical: Spacing.sm,
          ),
          constraints: const BoxConstraints(minHeight: 60),
          child: Row(
            children: [
              for (final spec in widget.visible)
                widget.cellWrap(spec, spec.cell(context, widget.item)),
            ],
          ),
        ),
      ),
    );
  }
}
