import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/living_condition_dto.dart';

import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/components/confirmation_dialog.dart';
import 'package:pet_center_app/screens/components/living%20condition/living_condition_card.dart';
import 'package:pet_center_app/screens/components/living%20condition/living_condition_dialog.dart';
import 'package:pet_center_app/screens/templates/screen_scaffold.dart';
import 'package:pet_center_app/services/living_condition_service.dart';

import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/jwt_parser.dart';

class LivingConditionScreen extends StatefulWidget {
  const LivingConditionScreen({super.key});
  @override
  State<StatefulWidget> createState() => _LivingConditionScreenState();
}

class _LivingConditionScreenState extends State<LivingConditionScreen> {
  void deleteField(String id) async {
    final output = await LivingConditionService.delete(id);
    if (output && mounted) {
      setState(() {
        condition.removeWhere((c) => c.id == id);
      });
    }
  }

  void editField(String id, LivingConditionFieldDTO ent) async {
    final output = await LivingConditionService.put(ent, id);
    if (output != null && mounted) {
      setState(() {
        condition.removeWhere((c) => c.id == id);
        condition.add(output);
      });
    }
  }

  void createField(LivingConditionFieldDTO ent) async {
    final output = await LivingConditionService.post(ent);
    if (output != null && mounted) {
      setState(() {
        condition.add(output);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    return BasicScreenScaffold(
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
      body: [
        ...condition.expand(
          (e) => [
            LivingConditionCard(
              livingCondition: e,
              deleteAction: () {
                showDialog(
                  context: context,
                  builder: (_) => ConfirmationDialog(
                    confirmAction: () {
                      final id = e.id;
                      if (id != null) {
                        deleteField(id);
                      }
                    },
                    title: "Delete question?",
                    body: "Are you sure you wish to delete this question.",
                  ),
                );
              },
              editAction: () {
                showDialog(
                  context: context,
                  builder: (_) => LivingConditionDialog(
                    existing: e.copy(),
                    callback: (output, exists) {
                      editField(output.id!, output);
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ],

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
                            callback: (output, exists) {
                              createField(output);
                            },
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
