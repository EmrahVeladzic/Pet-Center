import 'package:flutter/material.dart';

import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/components/confirmation_dialog.dart';
import 'package:pet_center_app/screens/components/living_condition_card.dart';
import 'package:pet_center_app/screens/components/living_condition_dialog.dart';

import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/jwt_parser.dart';

class LivingConditionScreen extends StatefulWidget {
  const LivingConditionScreen({super.key});
  @override
  State<StatefulWidget> createState() => _LivingConditionScreenState();
}

class _LivingConditionScreenState extends State<LivingConditionScreen> {
  void deleteField(String id) async {}

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
            'Living conditions',
            design.screenWidth * marqueeTitleWMult,
          ),
        ),
      ),
      body: Center(
        child: FractionallySizedBox(
          widthFactor: design.bodyWMult,
          heightFactor: 1.0,
          child: Container(
            decoration: design.panelDecoration(),
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
                        ...condition.expand(
                          (e) => [
                            LivingConditionCard(
                              livingCondition: e,
                              deleteAction: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => ConfirmationDialog(
                                    confirmAction: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => LivingConditionDialog(
                                          existing: null,
                                          callback: (input, exists) {},
                                        ),
                                      );
                                    },
                                    title: "Delete question?",
                                    body:
                                        "Are you sure you wish to delete this question.",
                                  ),
                                );
                              },
                              editAction: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => LivingConditionDialog(
                                    existing: e,
                                    callback: (input, exists) {},
                                  ),
                                );
                              },
                            ),
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
        child: (role == Access.owner || role == Access.admin)
            ? FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => LivingConditionDialog(
                            existing: null,
                            callback: (input, exists) {},
                          ),
                        );
                      },
                      child: design.fittedText('Create a new question'),
                    ),
                  ],
                ),
              )
            : null,
      ),
    );
  }
}
