import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/procedure_dto.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/utils/app_style.dart';

class SpecificationCard extends StatelessWidget {
  final ProcedureSpecificationSubDTO specification;
  final VoidCallback editAction;
  final VoidCallback deleteAction;

  const SpecificationCard({
    super.key,
    required this.specification,
    required this.editAction,
    required this.deleteAction,
  });

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    final kind = kinds.where((k) => k.id == specification.kindId).firstOrNull;

    final breed = kind?.breeds
        .where((b) => b.id == specification.breedId)
        .firstOrNull;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 1),
      child: Container(
        color: listTone,
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Padding(
                padding: EdgeInsets.all(design.spacing),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    design.fittedText(
                      "${kind?.title ?? "Animal"}${breed != null ? " - ${breed.title}" : ""}",
                      2.0,
                    ),

                    design.fittedText(
                      (specification.approximateAge == null)
                          ? [
                              "Exempt",
                              if (specification.sexSpecific != null)
                                specification.sexSpecific! ? "Male" : "Female",
                            ].join(" · ")
                          : [
                              specification.optional ? "Optional" : "Required",
                              if (specification.sexSpecific != null)
                                specification.sexSpecific! ? "Male" : "Female",
                              "Age: ${specification.approximateAge}d",
                              if (specification.interval != null)
                                "Every ${specification.interval}d"
                              else
                                "One-time",
                            ].join(" · "),
                    ),
                  ],
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
    );
  }
}
