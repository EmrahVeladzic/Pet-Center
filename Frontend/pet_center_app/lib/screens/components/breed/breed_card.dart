import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/breed_dto.dart';
import 'package:pet_center_app/screens/components/image_display.dart';
import 'package:pet_center_app/utils/app_style.dart';

class BreedCard extends StatelessWidget {
  final BreedDTO breed;
  final VoidCallback onTap;

  const BreedCard({super.key, required this.breed, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 0, vertical: 1),
      child: Container(
        padding: EdgeInsets.all(design.spacing),
        decoration: design.panelDecoration(),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: design.boundedImageSize,
                  height: design.boundedImageSize,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: ImageDisplay(
                      dataSource: breed.media[0],
                      creationToken: null,
                      locked: true,
                      creating: false,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: design.fittedText(breed.title, 1.25),
                  ),
                  Flexible(
                    fit: FlexFit.loose,
                    child: design.fittedText(
                      'Investment: ${breed.investment.toStringAsFixed(2)}',
                    ),
                  ),
                  Flexible(
                    fit: FlexFit.loose,
                    child: design.fittedText(
                      'Territory: ${breed.territory.toStringAsFixed(2)}',
                    ),
                  ),
                  Flexible(
                    fit: FlexFit.loose,
                    child: design.fittedText(
                      'Pricing: ${breed.pricing.toStringAsFixed(2)}',
                    ),
                  ),
                  Flexible(
                    fit: FlexFit.loose,
                    child: design.fittedText(
                      'Longevity: ${breed.longevity.toStringAsFixed(2)}',
                    ),
                  ),
                  Flexible(
                    fit: FlexFit.loose,
                    child: design.fittedText(
                      'Cohabitation: ${breed.cohabitation.toStringAsFixed(2)}',
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
                      onPressed: onTap,
                      icon: const Icon(Icons.arrow_forward),
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
