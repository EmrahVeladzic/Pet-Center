import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/breed_dto.dart';
import 'package:pet_center_app/models/data_transfer/individual/individual_response_dto.dart';

import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/helpers.dart';

class IndividualCard extends StatelessWidget {
  final IndividualResponseDTO individual;
  final VoidCallback onTap;
  final VoidCallback onMedical;

  const IndividualCard({
    super.key,
    required this.individual,
    required this.onTap,
    required this.onMedical,
  });

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    final BreedDTO? breed = kinds
        .expand((kind) => kind.breeds)
        .cast<BreedDTO?>()
        .firstWhere(
          (breed) => breed?.id == individual.breedId,
          orElse: () => null,
        );

    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 0, vertical: 1),
      child: Container(
        padding: EdgeInsets.all(design.spacing),
        decoration: design.panelDecoration(),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: design.fittedText(individual.name, 1.25),
                  ),
                  Flexible(
                    fit: FlexFit.loose,
                    child: design.fittedText(
                      "${(breed != null ? breed.title : "Animal")}, ${individual.sex ? "male" : "female"}",
                    ),
                  ),
                  Flexible(
                    fit: FlexFit.loose,
                    child: design.fittedText(
                      "Born on: ${formatDate(individual.birthDate, true)}",
                    ),
                  ),
                ],
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
                      onPressed: onMedical,
                      icon: const Icon(Icons.medical_services),
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
                      onPressed: onTap,
                      icon: const Icon(Icons.edit),
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
