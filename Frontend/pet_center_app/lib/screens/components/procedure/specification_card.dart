import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/procedure_dto.dart';
import 'package:pet_center_app/screens/components/entity_list_tile.dart';
import 'package:pet_center_app/screens/components/status_chip.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';

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
    final kind = kinds.where((k) => k.id == specification.kindId).firstOrNull;
    final breed = kind?.breeds
        .where((b) => b.id == specification.breedId)
        .firstOrNull;

    final exempt = specification.approximateAge == null;
    final sex = specification.sexSpecific;

    final details = <String>[
      if (!exempt) 'From ${specification.approximateAge} days old',
      if (!exempt)
        if (specification.interval != null)
          'Every ${specification.interval} days'
        else
          'One-time',
    ];

    return EntityListTile(
      icon: Icons.rule,
      title: breed == null
          ? (kind?.title ?? 'Animal')
          : '${kind?.title ?? 'Animal'}, ${breed.title}',
      subtitle: details.isEmpty ? null : details.join(' · '),
      chips: [
        if (exempt)
          const StatusChip(label: 'Exempt', tone: StatusTone.neutral)
        else
          StatusChip(
            label: specification.optional ? 'Optional' : 'Required',
            tone: specification.optional
                ? StatusTone.neutral
                : StatusTone.warning,
            showDot: false,
          ),
        if (sex != null)
          StatusChip(
            label: sex ? 'Male' : 'Female',
            tone: StatusTone.neutral,
            showDot: false,
          ),
      ],
      actions: [
        EntityAction(
          icon: Icons.edit_outlined,
          tooltip: 'Edit specification',
          onPressed: editAction,
        ),
        EntityAction(
          icon: Icons.delete_outline,
          tooltip: 'Remove specification',
          onPressed: deleteAction,
          destructive: true,
        ),
      ],
    );
  }
}
