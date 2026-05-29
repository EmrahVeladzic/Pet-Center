import 'package:flutter/material.dart';
import 'package:pet_center_app/screens/category_view.dart';
import 'package:pet_center_app/screens/form_template_view.dart';
import 'package:pet_center_app/screens/kind_view.dart';
import 'package:pet_center_app/screens/living_condition.dart';
import 'package:pet_center_app/screens/procedure_view.dart';
import 'package:pet_center_app/screens/templates/screen_scaffold.dart';
import 'package:pet_center_app/utils/app_style.dart';

class StaticDataEditorScreen extends StatefulWidget {
  const StaticDataEditorScreen({super.key});
  @override
  State<StatefulWidget> createState() => _StaticDataEditorScreenState();
}

class _StaticDataEditorScreenState extends State<StaticDataEditorScreen> {
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
            "Edit data:",
            design.screenWidth * marqueeTitleWMult,
          ),
        ),
      ),
      body: [
        FractionallySizedBox(
          widthFactor: 0.5,
          alignment: Alignment.center,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProcedureView()),
              );
            },
            child: design.fittedText('Procedures'),
          ),
        ),
        design.verticalGap(design.spacing),
        FractionallySizedBox(
          widthFactor: 0.5,
          alignment: Alignment.center,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CategoryView()),
              );
            },
            child: design.fittedText('Categories'),
          ),
        ),
        design.verticalGap(design.spacing),
        FractionallySizedBox(
          widthFactor: 0.5,
          alignment: Alignment.center,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LivingConditionScreen()),
              );
            },
            child: design.fittedText('Living condition'),
          ),
        ),
        design.verticalGap(design.spacing),
        FractionallySizedBox(
          widthFactor: 0.5,
          alignment: Alignment.center,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FormTemplateView()),
              );
            },
            child: design.fittedText('Form templates'),
          ),
        ),
        design.verticalGap(design.spacing),
        FractionallySizedBox(
          widthFactor: 0.5,
          alignment: Alignment.center,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => KindViewScreen()),
              );
            },
            child: design.fittedText('Animals'),
          ),
        ),
        design.verticalGap(design.spacing),
      ],
    );
  }
}
