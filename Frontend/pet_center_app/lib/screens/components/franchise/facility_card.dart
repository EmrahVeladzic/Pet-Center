import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/facility_dto.dart';
import 'package:pet_center_app/utils/app_style.dart';

class FacilityCard extends StatelessWidget {
  final FacilityDTO facility;
  final VoidCallback editAction;
  final VoidCallback deleteAction;
  final bool owner;

  const FacilityCard({
    super.key,
    required this.facility,
    required this.editAction,
    required this.deleteAction,
    required this.owner,
  });

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 0, vertical: 1),
      child: Container(
        color: listTone,
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.all(design.spacing),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Flexible(
                      fit: FlexFit.loose,
                      child: design.fittedText(
                        "${facility.street}-${facility.city}",
                      ),
                    ),
                    if (facility.contact != null) ...[
                      Flexible(
                        fit: FlexFit.loose,
                        child: design.fittedText(facility.contact!),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (owner) ...[
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
          ],
        ),
      ),
    );
  }
}
