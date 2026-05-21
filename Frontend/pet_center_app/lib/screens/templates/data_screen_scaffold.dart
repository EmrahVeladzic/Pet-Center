import 'package:flutter/material.dart';

import 'package:pet_center_app/screens/components/page_selector.dart';
import 'package:pet_center_app/screens/templates/filter_template.dart';

import 'package:pet_center_app/utils/app_style.dart';

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
  });

  @override
  State<DataScreenScaffold<F, T>> createState() =>
      _DataScreenScaffoldState<F, T>();
}

class _DataScreenScaffoldState<F extends FilterTemplate, T>
    extends State<DataScreenScaffold<F, T>> {
  bool _filterVisible = false;

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    return Scaffold(
      backgroundColor: mainTone,
      appBar: AppBar(
        title: SizedBox(
          width: design.screenWidth * marqueeTitleWMult,
          height: design.marqueeSize,
          child: design.textMarquee(
            widget.appTitle,
            design.screenWidth * marqueeTitleWMult,
          ),
        ),
        actions: [
          if (widget.filterPrereq) ...[
            IconButton(
              icon: _filterVisible
                  ? const Icon(Icons.arrow_drop_up)
                  : const Icon(Icons.arrow_drop_down),
              onPressed: () {
                if (!mounted) {
                  return;
                }
                setState(() {
                  _filterVisible = !_filterVisible;
                });
              },
            ),
          ],
        ],
      ),
      body: Center(
        child: FractionallySizedBox(
          widthFactor: design.bodyWMult,
          heightFactor: 1.0,
          child: Container(
            color: listTone,
            child: widget.loading
                ? Center(
                    child: Transform.scale(
                      scale: 3,
                      child: CircularProgressIndicator(),
                    ),
                  )
                : NestedScrollView(
                    headerSliverBuilder: (context, _) => [
                      SliverAppBar(
                        pinned: true,
                        automaticallyImplyLeading: false,
                        toolbarHeight: _filterVisible
                            ? design.getToolbarHeight(
                                widget.filter.filterRowCount(),
                                widget.filter.filterFontSize(),
                              )
                            : 0,
                        flexibleSpace: FlexibleSpaceBar(
                          collapseMode: CollapseMode.none,
                          background: widget.filter,
                        ),
                      ),
                    ],
                    body: ListView.builder(
                      itemCount: widget.dataSource.length,
                      itemBuilder: (context, index) => Column(
                        children: [
                          widget.itemBuilder(context, widget.dataSource[index]),
                          design.verticalGap(1),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PageSelector(
                key: widget.pageSelectorKey,
                maxPage: widget.maxPage,
                onChanged: widget.switchPage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
