import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/procedure_dto.dart';
import 'package:pet_center_app/screens/components/confirmation_dialog.dart';
import 'package:pet_center_app/screens/components/entity_list_tile.dart';
import 'package:pet_center_app/screens/components/procedure/specification_card.dart';
import 'package:pet_center_app/screens/components/procedure/specification_dialog.dart';
import 'package:pet_center_app/screens/components/status_chip.dart';
import 'package:pet_center_app/services/procedure_service.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/utils/tokens.dart';

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

  void openSpecificationDialog(
    BuildContext context, [
    ProcedureSpecificationSubDTO? current,
  ]) {
    if (kinds.isEmpty || procedure.id == null) {
      return;
    }
    showDialog(
      context: context,
      builder: (_) => SpecificationCreationDialog(
        procedureId: procedure.id!,
        fromCurrent: current,
        callback: (value) {
          procedure.specifications.removeWhere((s) => s.id == value.id);
          procedure.specifications.add(value);
          rebuildCallback();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final count = procedure.specifications.length;

    return EntityListTile(
      icon: Icons.medical_services_outlined,
      title: procedure.description.isEmpty
          ? 'Untitled procedure'
          : procedure.description,
      subtitle: count == 0
          ? 'Not defined for any species yet'
          : (count == 1 ? '1 specification' : '$count specifications'),
      chips: [
        if (count == 0)
          const StatusChip(label: 'Undefined', tone: StatusTone.warning),
      ],
      actions: [
        EntityAction(
          icon: Icons.note_add_outlined,
          tooltip: 'Define procedure for a species',
          onPressed: kinds.isEmpty || procedure.id == null
              ? null
              : () => openSpecificationDialog(context),
        ),
        EntityAction(
          icon: Icons.edit_outlined,
          tooltip: 'Edit procedure',
          onPressed: editAction,
        ),
        EntityAction(
          icon: Icons.delete_outline,
          tooltip: 'Remove procedure',
          onPressed: deleteAction,
          destructive: true,
        ),
      ],
      expanded: count == 0
          ? null
          : Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text(
                  'Specifications',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                children: [
                  for (final e in procedure.specifications) ...[
                    SpecificationCard(
                      specification: e,
                      editAction: () => openSpecificationDialog(context, e),
                      deleteAction: () {
                        showDialog<bool>(
                          context: context,
                          builder: (_) => ConfirmationDialog(
                            title: 'Remove this specification?',
                            body:
                                'The specification will no longer apply to this procedure.',
                            consequence: 'This cannot be undone.',
                            confirmLabel: 'Remove',
                            destructive: true,
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
                    const SizedBox(height: Spacing.xs),
                  ],
                ],
              ),
            ),
    );
  }
}
