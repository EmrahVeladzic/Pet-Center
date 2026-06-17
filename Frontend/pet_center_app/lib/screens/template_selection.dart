import 'package:flutter/material.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/form_selection.dart';
import 'package:pet_center_app/screens/living_condition.dart';
import 'package:pet_center_app/screens/templates/screen_scaffold.dart';
import 'package:pet_center_app/services/form_service.dart';

import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/utils/app_style.dart';

import 'package:pet_center_app/utils/jwt_parser.dart';

class TemplateSelectionScreen extends StatefulWidget {
  const TemplateSelectionScreen({super.key});
  @override
  State<StatefulWidget> createState() => _TemplateSelectionScreenState();
}

class _TemplateSelectionScreenState extends State<TemplateSelectionScreen> {
  void switchToSelection(String id) async {
    final output = await FormService.count(id, false);
    if (output != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              FormSelectionScreen(maxPage: output, templateId: id, eval: false),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    return BasicScreenScaffold(
      center: true,
      appBar: AppBar(
        title: SizedBox(
          width: design.screenWidth * marqueeTitleWMult,
          height: design.marqueeSize,
          child: design.textMarquee(
            "Choose the template for your business:",
            design.screenWidth * marqueeTitleWMult,
          ),
        ),
      ),
      body: [
        ...templates.expand(
          (e) => [
            FractionallySizedBox(
              widthFactor: 0.5,
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  final id = e.id;
                  if (id == null) {
                    return;
                  }
                  switchToSelection(id);
                },
                child: design.fittedText(e.description),
              ),
            ),
            design.verticalGap(),
          ],
        ),
      ],

      bottomNavigationBar: BottomAppBar(
        child: role == Access.user
            ? FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LivingConditionScreen(),
                          ),
                        );
                      },
                      child: design.fittedText('Specify living conditions'),
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
