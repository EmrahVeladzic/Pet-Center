import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/form_template_dto.dart';
import 'package:pet_center_app/utils/app_style.dart';

class FormTemplateFieldCard extends StatelessWidget {
  final FormTemplateFieldDTO field;
  final VoidCallback editAction;
  final VoidCallback deleteAction;

  const FormTemplateFieldCard({
    super.key,
    required this.field,
    required this.editAction,
    required this.deleteAction,
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
              flex: 5,
              child: Padding(
                padding: EdgeInsets.all(design.spacing),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Flexible(
                      fit: FlexFit.loose,
                      child: Text(
                        "Field: ${field.description}",
                        textScaler: TextScaler.linear(1.5),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Tooltip(
                        message: field.optional ? "Optional" : "Required",
                        child: Icon(
                          field.optional
                              ? Icons.question_mark
                              : Icons.priority_high,
                        ),
                      ),
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
                      tooltip: "Edit field",
                      onPressed: editAction,
                      icon: const Icon(Icons.edit),
                      padding: EdgeInsets.zero,

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
                      tooltip: "Delete field",
                      onPressed: deleteAction,
                      icon: const Icon(Icons.delete),
                      padding: EdgeInsets.zero,

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
