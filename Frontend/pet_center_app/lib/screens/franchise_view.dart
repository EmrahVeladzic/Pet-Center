import 'package:flutter/material.dart';

import 'package:pet_center_app/models/data_transfer/franchise/franchise_response_dto.dart';

import 'package:pet_center_app/screens/components/franchise/franchise_card.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';

import 'package:pet_center_app/utils/app_style.dart';

class FranchiseViewScreen extends StatefulWidget {
  const FranchiseViewScreen({super.key});

  @override
  State<StatefulWidget> createState() => _FranchiseViewScreenState();
}

class _FranchiseViewScreenState extends State<FranchiseViewScreen> {
  List<FranchiseResponseDTO> dataSource = self?.workplaces ?? [];

  void rebuild() {
    if (!mounted) {
      return;
    }
    setState(() {
      dataSource = self?.workplaces ?? [];
    });
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
            'Workplaces:',
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...dataSource.expand(
                          (e) => [
                            FranchiseCard(
                              franchise: e,
                              editAction: () {},
                              deleteAction: () {},
                              employeeViewAction: () {},
                              rebuildCallback: rebuild,
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
      bottomNavigationBar: BottomAppBar(),
    );
  }
}
