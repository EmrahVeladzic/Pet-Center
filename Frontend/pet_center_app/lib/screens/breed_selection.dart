import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/breed_dto.dart';
import 'package:pet_center_app/screens/components/breed/breed_card.dart';
import 'package:pet_center_app/screens/components/page_selector.dart';
import 'package:pet_center_app/services/breed_service.dart';

import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/globals.dart';

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

  @override
  void initState() {
    super.initState();
    switchPage(0);
  }

  void switchPage(int page) async {
    final newDataSrc = await BreedService.get(
      page,
      widget.adoptionPurposes,
      widget.incomplete,
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

  void switchToSelection(String id) async {
    if (apiServiceBusy) {
      return;
    }
  }

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
            'Best matches based on living condition:',
            design.screenWidth * marqueeTitleWMult,
          ),
        ),
      ),
      body: Center(
        child: FractionallySizedBox(
          widthFactor: design.bodyWMult,
          heightFactor: 1.0,
          child: Container(
            color: listTone,
            child: LayoutBuilder(
              builder: (context, boxConstraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: boxConstraints.maxHeight,
                    ),
                    child: _initLoading
                        ? Center(
                            child: Transform.scale(
                              scale: 3,
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...dataSource.expand(
                                (e) => [
                                  BreedCard(
                                    breed: e,
                                    onTap: () {
                                      final id = e.id;
                                      if (id == null) {
                                        return;
                                      }
                                      switchToSelection(e.id!);
                                    },
                                  ),
                                  design.verticalGap(1),
                                ],
                              ),
                            ],
                          ),
                  ),
                );
              },
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
