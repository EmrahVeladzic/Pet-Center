import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/breed_dto.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/components/breed/breed_card.dart';
import 'package:pet_center_app/screens/components/breed/breed_filters.dart';
import 'package:pet_center_app/screens/components/page_selector.dart';
import 'package:pet_center_app/services/breed_service.dart';

import 'package:pet_center_app/utils/app_style.dart';

import 'package:pet_center_app/utils/jwt_parser.dart';

class BreedSelectionScreen extends StatefulWidget {
  final int maxPage;
  final String? kindId;
  final bool adoptionPurposes;
  final bool incomplete;

  const BreedSelectionScreen({
    super.key,
    required this.maxPage,
    required this.adoptionPurposes,
    required this.incomplete,
    this.kindId,
  });

  @override
  State<StatefulWidget> createState() => _BreedSelectionScreenState();
}

class _BreedSelectionScreenState extends State<BreedSelectionScreen> {
  List<BreedDTO> dataSource = [];
  bool _initLoading = true;
  final _pageSelectorKey = GlobalKey<PageSelectorState>();
  late bool incomplete;

  @override
  void initState() {
    super.initState();
    incomplete = widget.incomplete;
    switchPage(0);
  }

  void switchPage(int page) async {
    final newDataSrc = await BreedService.get(
      page,
      widget.adoptionPurposes,
      incomplete,
      widget.kindId,
    );
    if (newDataSrc != null) {
      setState(() {
        _initLoading = false;
        dataSource = newDataSrc;
      });
    } else {
      _pageSelectorKey.currentState?.revertPage();
    }
  }

  void switchToSelection(String id) async {}

  void resetPages(bool inc) async {
    final output = await BreedService.count(
      widget.adoptionPurposes,
      inc,
      widget.kindId,
    );
    if (!mounted) {
      return;
    }
    setState(() {});
    if (output != null) {
      _pageSelectorKey.currentState?.resetMax(output);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    final role = userToken?.role ?? Access.user;

    return Scaffold(
      backgroundColor: mainTone,
      appBar: AppBar(
        title: SizedBox(
          width: design.screenWidth * marqueeTitleWMult,
          height: design.marqueeSize,
          child: design.textMarquee(
            (role == Access.user)
                ? 'Best matches based on living condition:'
                : "Breeds:",
            design.screenWidth * marqueeTitleWMult,
          ),
        ),
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: () {})],
      ),
      body: Center(
        child: FractionallySizedBox(
          widthFactor: design.bodyWMult,
          heightFactor: 1.0,
          child: Container(
            color: listTone,
            child: _initLoading
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
                        toolbarHeight:
                            role == Access.admin || role == Access.owner
                            ? design.getToolbarHeight()
                            : 0,
                        flexibleSpace: FlexibleSpaceBar(
                          collapseMode: CollapseMode.none,
                          background: BreedFilters(
                            callback: resetPages,
                            initIncomplete: incomplete,
                          ),
                        ),
                      ),
                    ],
                    body: ListView.builder(
                      itemCount: dataSource.length,
                      itemBuilder: (context, index) => Column(
                        children: [
                          BreedCard(
                            adminMode:
                                (role == Access.admin || role == Access.owner),
                            breed: dataSource[index],
                            onTap: () {
                              final id = dataSource[index].id;
                              if (id == null) {
                                return;
                              }
                              switchToSelection(dataSource[index].id!);
                            },
                          ),
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
                key: _pageSelectorKey,
                maxPage: widget.maxPage,
                onChanged: switchPage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
