import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/kind_dto.dart';
import 'package:pet_center_app/utils/app_style.dart';

class KindCard extends StatelessWidget {
  final KindDTO kind;
  final VoidCallback editAction;
  final VoidCallback deleteAction;
  final VoidCallback breedListAction;

  const KindCard({
    super.key,
    required this.kind,
    required this.editAction,
    required this.deleteAction,
    required this.breedListAction,
  });

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 0, vertical: 1),
      child: Container(
        decoration: design.panelDecoration(),
        child: Padding(
          padding: EdgeInsets.all(design.spacing),
          child: Row(
            children: [
              Expanded(flex: 5, child: design.fittedText(kind.title, 2.0)),
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: design.boundedIconSize,
                    height: design.boundedIconSize,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: IconButton(
                        onPressed: breedListAction,
                        icon: const Icon(Icons.pets),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: design.boundedIconSize,
                    height: design.boundedIconSize,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: IconButton(
                        onPressed: editAction,
                        icon: const Icon(Icons.edit),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: design.boundedIconSize,
                    height: design.boundedIconSize,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: IconButton(
                        onPressed: deleteAction,
                        icon: const Icon(Icons.delete),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
