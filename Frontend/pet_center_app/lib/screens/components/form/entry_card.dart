import 'package:flutter/material.dart';
import 'package:pet_center_app/utils/app_style.dart';

class EntryCard extends StatelessWidget {
  final String field;
  final String? entry;

  const EntryCard({super.key, required this.field, this.entry});

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    String ent = "---";

    if (entry != null && entry!.isNotEmpty) {
      ent = entry!;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 1),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            decoration: design.panelDecoration(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: design.spacing / 2),
              child: design.fittedText(field, 1.25),
            ),
          ),
          Container(
            width: double.infinity,
            color: visitedPanelTone,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: design.spacing / 2),

              child: LayoutBuilder(
                builder: (context, constraints) {
                  return UnconstrainedBox(
                    clipBehavior: Clip.hardEdge,
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: constraints.maxWidth,
                      child: Text(ent, softWrap: true),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
