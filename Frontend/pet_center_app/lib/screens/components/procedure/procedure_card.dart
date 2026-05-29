import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/procedure_dto.dart';
import 'package:pet_center_app/screens/components/confirmation_dialog.dart';
import 'package:pet_center_app/screens/components/procedure/specification_card.dart';
import 'package:pet_center_app/screens/components/procedure/specification_dialog.dart';
import 'package:pet_center_app/services/procedure_service.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/utils/app_style.dart';

class ProcedureCard extends StatelessWidget {
  final ProcedureDTO procedure;
  final VoidCallback editAction;
  final VoidCallback deleteAction;
  final VoidCallback rebuildCallback;

  const ProcedureCard({
    super.key,
    required this.procedure,
    required this.editAction,
    required this.deleteAction,
    required this.rebuildCallback,
  });

  void removeSpecification(String id) async {
    final output = await ProcedureService.removeSpecification(id);
    if (output == true) {
      procedure.specifications.removeWhere((s) => s.id == id);
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

                    child: design.fittedText(procedure.description, 2.0),
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
                              if (kinds.isEmpty || procedure.id == null) {
                                return;
                              }
                              showDialog(
                                context: context,
                                builder: (_) => SpecificationCreationDialog(
                                  procedureId: procedure.id!,
                                  callback: (value) {
                                    procedure.specifications.removeWhere(
                                      (s) => s.id == value.id,
                                    );
                                    procedure.specifications.add(value);
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
            if (procedure.specifications.isNotEmpty) ...[
              ExpansionTile(
                title: const Text("Specifications"),
                children: procedure.specifications
                    .expand(
                      (e) => [
                        SpecificationCard(
                          specification: e,
                          editAction: () {
                            if (procedure.id == null || kinds.isEmpty) return;
                            showDialog(
                              context: context,
                              builder: (_) => SpecificationCreationDialog(
                                procedureId: procedure.id!,
                                fromCurrent: e,
                                callback: (value) {
                                  procedure.specifications.removeWhere(
                                    (s) => s.id == value.id,
                                  );
                                  procedure.specifications.add(value);
                                  rebuildCallback();
                                },
                              ),
                            );
                          },
                          deleteAction: () {
                            showDialog(
                              context: context,
                              builder: (_) => ConfirmationDialog(
                                title: "Remove specification",
                                body:
                                    "Are you sure you wish to remove this specification?",
                                confirmAction: () {
                                  final id = e.id;
                                  if (id != null) {
                                    removeSpecification(id);
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
