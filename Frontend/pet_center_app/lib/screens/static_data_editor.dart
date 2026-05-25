import 'package:flutter/material.dart';
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
      body: [],
    );
  }
}
