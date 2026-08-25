import 'package:flutter/material.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/globals.dart';
import 'package:pet_center_app/utils/tokens.dart';

class PageSelector extends StatefulWidget {
  final int maxPage;
  final ValueChanged<int> onChanged;
  final int? resultCount;

  const PageSelector({
    super.key,
    required this.maxPage,
    required this.onChanged,
    this.resultCount,
  });

  @override
  State<PageSelector> createState() => PageSelectorState();
}

class PageSelectorState extends State<PageSelector> {
  late int maxPage;
  int currentPage = 1;
  int _lastConfirmedPage = 1;

  @override
  void initState() {
    super.initState();
    maxPage = widget.maxPage;
  }

  void resetMax(int newMax) {
    if (!mounted) {
      return;
    }
    setState(() {
      maxPage = newMax;
      currentPage = 1;
      _lastConfirmedPage = 1;
    });
    changePage(1);
  }

  void revertPage() {
    if (!mounted) {
      return;
    }
    setState(() {
      currentPage = _lastConfirmedPage;
    });
  }

  void changePage(int page) {
    if (apiServiceBusy.value) {
      return;
    }
    if (page < 1 || page > maxPage) {
      return;
    }

    _lastConfirmedPage = currentPage;
    setState(() {
      currentPage = page;
    });

    widget.onChanged(page - 1);
  }

  List<int?> _visiblePages() {
    final total = maxPage < 1 ? 1 : maxPage;
    if (total <= 7) {
      return List<int?>.generate(total, (i) => i + 1);
    }

    final pages = <int?>{1};
    for (var p = currentPage - 1; p <= currentPage + 1; p++) {
      if (p > 1 && p < total) pages.add(p);
    }
    pages.add(total);

    final sorted = pages.whereType<int>().toList()..sort();
    final result = <int?>[];
    int? previous;
    for (final p in sorted) {
      if (previous != null && p - previous > 1) {
        result.add(null);
      }
      result.add(p);
      previous = p;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final design = context.design;
    final total = maxPage < 1 ? 1 : maxPage;

    final label = widget.resultCount == null
        ? 'Page $currentPage of $total'
        : 'Showing ${widget.resultCount} on page $currentPage of $total';

    final controls = Wrap(
      spacing: Spacing.xxs,
      runSpacing: Spacing.xxs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        IconButton(
          tooltip: 'Previous page',
          onPressed: currentPage > 1 ? () => changePage(currentPage - 1) : null,
          icon: const Icon(Icons.chevron_left),
        ),
        for (final page in _visiblePages())
          if (page == null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.xxs),
              child: Text(
                '...',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            )
          else
            _PageButton(
              page: page,
              selected: page == currentPage,
              onTap: () => changePage(page),
            ),
        IconButton(
          tooltip: 'Next page',
          onPressed: currentPage < total
              ? () => changePage(currentPage + 1)
              : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: Radii.mdAll,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: design.isCompact
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: Spacing.xxs),
                controls,
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                controls,
              ],
            ),
    );
  }
}

class _PageButton extends StatelessWidget {
  final int page;
  final bool selected;
  final VoidCallback onTap;

  const _PageButton({
    required this.page,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: selected
          ? scheme.primary.withValues(alpha: 0.10)
          : Colors.transparent,
      borderRadius: Radii.smAll,
      child: InkWell(
        onTap: selected ? null : onTap,
        borderRadius: Radii.smAll,
        child: Container(
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: Radii.smAll,
            border: Border.all(
              color: selected ? scheme.primary : Colors.transparent,
            ),
          ),
          child: Text(
            '$page',
            style: theme.textTheme.labelLarge?.copyWith(
              color: selected ? scheme.primary : scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
