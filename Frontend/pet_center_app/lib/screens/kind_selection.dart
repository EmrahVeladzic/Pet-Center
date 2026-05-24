import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/kind_dto.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/breed_selection.dart';
import 'package:pet_center_app/screens/living_condition.dart';
import 'package:pet_center_app/screens/templates/screen_scaffold.dart';
import 'package:pet_center_app/services/breed_service.dart';

import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/utils/app_style.dart';

import 'package:pet_center_app/utils/jwt_parser.dart';

class KindSelectionScreen extends StatefulWidget {
  const KindSelectionScreen({super.key});
  @override
  State<StatefulWidget> createState() => _KindSelectionScreenState();
}

class _KindSelectionScreenState extends State<KindSelectionScreen> {
  List<KindDTO> dataSource = kinds;

  void switchToSelection(String id, bool userMode) async {
    final count = await BreedService.count(userMode, false, id);
    if (count != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BreedSelectionScreen(
            maxPage: count,
            adoptionPurposes: userMode,
            incomplete: false,
            kindId: id,
          ),
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
            role == Access.user
                ? 'Choose which kind of animal you are interested in:'
                : "Choose kind:",
            design.screenWidth * marqueeTitleWMult,
          ),
        ),
      ),
      body: [
        ...dataSource.expand(
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
                  switchToSelection(id, role == Access.user);
                },
                child: design.fittedText(e.title),
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
