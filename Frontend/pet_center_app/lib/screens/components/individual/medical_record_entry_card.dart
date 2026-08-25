import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/individual/individual_response_dto.dart';
import 'package:pet_center_app/models/data_transfer/procedure_dto.dart';
import 'package:pet_center_app/screens/components/entity_list_tile.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/utils/helpers.dart';

class MedicalRecordEntryCard extends StatelessWidget {
  final MedicalEntrySubDTO entry;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const MedicalRecordEntryCard({
    super.key,
    required this.entry,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final ProcedureDTO? proc = procedures.cast<ProcedureDTO?>().firstWhere(
      (proc) => proc?.id == entry.procedureId,
      orElse: () => null,
    );

    return EntityListTile(
      icon: Icons.medical_information_outlined,
      onTap: onTap,
      title: proc?.description ?? 'Procedure',
      subtitle: 'Performed ${formatDate(entry.datePerformed, true)}',
      actions: [
        EntityAction(
          icon: Icons.edit_outlined,
          tooltip: 'Edit entry',
          onPressed: onTap,
        ),
        EntityAction(
          icon: Icons.delete_outline,
          tooltip: 'Remove entry',
          onPressed: onDelete,
          destructive: true,
        ),
      ],
    );
  }
}
