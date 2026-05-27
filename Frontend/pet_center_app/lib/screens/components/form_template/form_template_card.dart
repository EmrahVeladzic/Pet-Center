import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/form_template_dto.dart';
import 'package:pet_center_app/screens/components/confirmation_dialog.dart';
import 'package:pet_center_app/screens/components/form_template/form_template_field_card.dart';
import 'package:pet_center_app/screens/components/form_template/form_template_field_dialog.dart';
import 'package:pet_center_app/services/form_template_service.dart';
import 'package:pet_center_app/utils/app_style.dart';

class FormTemplateCard extends StatelessWidget {
  final FormTemplateDTO template;
  final VoidCallback editAction;
  final VoidCallback deleteAction;
  final VoidCallback rebuildCallback;

  const FormTemplateCard({
    super.key,
    required this.template,
    required this.editAction,
    required this.deleteAction,
    required this.rebuildCallback,
  });

  void removeField(String id) async {
    final output = await FormTemplateService.deleteField(id);
    if (output == true) {
      template.fields.removeWhere((f) => f.id == id);
      rebuildCallback();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 0, vertical: 1),
      child: Container(
        decoration: design.panelDecoration(),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(design.spacing),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,

                    child: design.fittedText(template.description, 2.0),
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
                            onPressed: () {
                              if (template.id == null) return;
                              showDialog(
                                context: context,
                                builder: (_) => FormTemplateFieldDialog(
                                  formTemplateId: template.id!,
                                  callback: (value) {
                                    template.fields.removeWhere(
                                      (f) => f.id == value.id,
                                    );
                                    template.fields.add(value);
                                    rebuildCallback();
                                  },
                                ),
                              );
                            },
                            icon: const Icon(Icons.note_add),
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
            if (template.fields.isNotEmpty) ...[
              ExpansionTile(
                title: const Text("Fields"),
                children: template.fields
                    .expand(
                      (e) => [
                        FormTemplateFieldCard(
                          field: e,
                          editAction: () {
                            if (template.id == null) return;
                            showDialog(
                              context: context,
                              builder: (_) => FormTemplateFieldDialog(
                                formTemplateId: template.id!,
                                fromCurrent: e,
                                callback: (value) {
                                  template.fields.removeWhere(
                                    (f) => f.id == e.id,
                                  );
                                  template.fields.add(value);
                                  rebuildCallback();
                                },
                              ),
                            );
                          },
                          deleteAction: () {
                            showDialog(
                              context: context,
                              builder: (_) => ConfirmationDialog(
                                title: "Remove field",
                                body:
                                    "Are you sure you wish to remove this field?",
                                confirmAction: () {
                                  final id = e.id;
                                  if (id != null) {
                                    removeField(id);
                                  }
                                },
                              ),
                            );
                          },
                        ),
                        design.verticalGap(1),
                      ],
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
