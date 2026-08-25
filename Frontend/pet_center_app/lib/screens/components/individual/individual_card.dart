import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/breed_dto.dart';
import 'package:pet_center_app/models/data_transfer/individual/individual_response_dto.dart';
import 'package:pet_center_app/screens/components/entity_list_tile.dart';
import 'package:pet_center_app/screens/components/status_chip.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/utils/helpers.dart';

class IndividualCard extends StatelessWidget {
  final IndividualResponseDTO individual;
  final VoidCallback onTap;
  final VoidCallback onMedical;
  final VoidCallback onDelete;

  const IndividualCard({
    super.key,
    required this.individual,
    required this.onTap,
    required this.onMedical,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final BreedDTO? breed = kinds
        .expand((kind) => kind.breeds)
        .cast<BreedDTO?>()
        .firstWhere(
          (breed) => breed?.id == individual.breedId,
          orElse: () => null,
        );

    return EntityListTile(
      icon: Icons.pets,
      onTap: onTap,
      title: individual.name.isEmpty ? 'Unnamed animal' : individual.name,
      subtitle: 'Born ${formatDate(individual.birthDate, true)}',
      chips: [
        StatusChip(
          label: breed?.title ?? 'Unknown breed',
          tone: StatusTone.neutral,
          showDot: false,
        ),
        StatusChip(
          label: individual.sex ? 'Male' : 'Female',
          tone: StatusTone.neutral,
          showDot: false,
        ),
      ],
      actions: [
        EntityAction(
          icon: Icons.medical_services_outlined,
          tooltip: 'Medical record',
          onPressed: onMedical,
        ),
        EntityAction(
          icon: Icons.edit_outlined,
          tooltip: 'Edit animal',
          onPressed: onTap,
        ),
        EntityAction(
          icon: Icons.delete_outline,
          tooltip: 'Remove animal',
          onPressed: onDelete,
          destructive: true,
        ),
      ],
    );
  }
}
