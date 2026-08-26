import 'package:flutter/material.dart';

import 'package:pet_center_app/screens/components/app_data_table.dart';
import 'package:pet_center_app/screens/components/empty_state.dart';
import 'package:pet_center_app/screens/components/page_header.dart';
import 'package:pet_center_app/screens/components/page_selector.dart';
import 'package:pet_center_app/screens/templates/filter_template.dart';
import 'package:pet_center_app/screens/templates/screen_scaffold.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/tokens.dart';

class DataScreenScaffold<F extends FilterTemplate, T> extends StatefulWidget {
  final int maxPage;
  final void Function(int page) switchPage;
  final GlobalKey<PageSelectorState> pageSelectorKey;
  final List<T> dataSource;
  final bool loading;
  final bool filterPrereq;
  final String appTitle;
  final F filter;
  final Widget Function(BuildContext, T source) itemBuilder;
  final List<Widget> importActions;

  final String? description;
  final List<DataColumnSpec<T>>? columns;
  final Widget? primaryAction;
  final String emptyTitle;
  final String? emptyMessage;
  final VoidCallback? onResetFilters;
  final void Function(T item)? onRowTap;

  const DataScreenScaffold({
    super.key,
    required this.maxPage,
    required this.switchPage,
    required this.pageSelectorKey,
    required this.appTitle,
    required this.loading,
    required this.filterPrereq,
    required this.dataSource,
    required this.filter,
    required this.itemBuilder,
    this.importActions = const [],
    this.description,
    this.columns,
    this.primaryAction,
    this.emptyTitle = 'Nothing to show yet',
    this.emptyMessage,
    this.onResetFilters,
    this.onRowTap,
  });

  @override
  State<DataScreenScaffold<F, T>> createState() =>
      _DataScreenScaffoldState<F, T>();
}

class _DataScreenScaffoldState<F extends FilterTemplate, T>
    extends State<DataScreenScaffold<F, T>> {
  bool? _filtersOpen;

  bool filtersVisible(ReactiveDesignSystem design) =>
      _filtersOpen ?? !design.isCompact;

  Widget _filterToggle(BuildContext context, ReactiveDesignSystem design) {
    final open = filtersVisible(design);

    return OutlinedButton.icon(
      onPressed: () => setState(() => _filtersOpen = !open),
      icon: Icon(
        open ? Icons.filter_list_off : Icons.filter_list,
        size: IconSizes.md,
      ),
      label: Text(open ? 'Hide filters' : 'Filters'),
    );
  }

  Widget _filterBar(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: Radii.mdAll,
        border: Border.all(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: widget.filter,
    );
  }

  Widget _empty(BuildContext context) {
    final filtered = widget.filterPrereq;

    return EmptyState(
      icon: filtered ? Icons.search_off : Icons.inbox_outlined,
      title: filtered ? 'No matching results' : widget.emptyTitle,
      message:
          widget.emptyMessage ??
          (filtered
              ? 'No records match the filters you selected. Try widening them or clearing the filter to see everything.'
              : 'There is nothing here yet. New records will appear in this list once they are added.'),
      secondaryActionLabel: filtered && widget.onResetFilters != null
          ? 'Clear filters'
          : null,
      onSecondaryAction: widget.onResetFilters,
    );
  }

  Widget _content(BuildContext context, ReactiveDesignSystem design) {
    if (widget.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.dataSource.isEmpty) {
      return _empty(context);
    }

    final columns = widget.columns;
    if (columns != null && !design.isCompact) {
      return AppDataTable<T>(
        columns: columns,
        items: widget.dataSource,
        onRowTap: widget.onRowTap,
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: widget.dataSource.length,
      separatorBuilder: (_, _) =>
          SizedBox(height: Spacing.listGap.resolve(design.windowClass)),
      itemBuilder: (context, index) =>
          widget.itemBuilder(context, widget.dataSource[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final design = context.design;
    final gutter = Spacing.gutter.resolve(design.windowClass);

    return Scaffold(
      appBar: AppBar(
        leading: BasicScreenScaffold.shellLeading(context),
        title: null,
        actions: widget.importActions,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: Breakpoints.maxContentWidth,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: gutter,
                vertical: design.isShort ? Spacing.sm : gutter,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final page = Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PageHeader(
                        title: widget.appTitle,
                        description: widget.description,
                        actions: [
                          if (widget.filterPrereq)
                            _filterToggle(context, design),
                          if (widget.primaryAction != null)
                            widget.primaryAction!,
                        ],
                      ),
                      SizedBox(height: gutter),
                      if (widget.filterPrereq && filtersVisible(design)) ...[
                        _filterBar(context),
                        const SizedBox(height: Spacing.sm),
                      ],
                      Expanded(child: _content(context, design)),
                      const SizedBox(height: Spacing.sm),
                      PageSelector(
                        key: widget.pageSelectorKey,
                        maxPage: widget.maxPage,
                        onChanged: widget.switchPage,
                        resultCount: widget.dataSource.length,
                      ),
                    ],
                  );

                  if (constraints.maxHeight.isFinite &&
                      constraints.maxHeight < Breakpoints.minPageHeight) {
                    return SingleChildScrollView(
                      child: SizedBox(
                        height: Breakpoints.minPageHeight,
                        child: page,
                      ),
                    );
                  }

                  return page;
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
