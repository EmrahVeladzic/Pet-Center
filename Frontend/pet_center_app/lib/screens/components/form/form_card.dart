import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/form_dto.dart';

import 'package:pet_center_app/screens/components/image_display.dart';

import 'package:pet_center_app/utils/app_style.dart';

class FormCard extends StatelessWidget {
  final FormDTO form;
  final VoidCallback onTap;

  const FormCard({super.key, required this.form, required this.onTap});

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
                      dataSource: (form.media.isNotEmpty)
                          ? form.media[0]
                          : null,
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
              child: design.fittedText(form.franchiseName, 1.25),
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
