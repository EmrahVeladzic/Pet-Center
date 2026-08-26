import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/facility_dto.dart';
import 'package:pet_center_app/screens/components/entity_list_tile.dart';

class FacilityCard extends StatelessWidget {
  final FacilityDTO facility;
  final VoidCallback editAction;
  final VoidCallback deleteAction;
  final bool owner;

  const FacilityCard({
    super.key,
    required this.facility,
    required this.editAction,
    required this.deleteAction,
    required this.owner,
  });

  @override
  Widget build(BuildContext context) {
    final address = [
      facility.street,
      facility.city,
    ].where((part) => part.trim().isNotEmpty).join(', ');

    return EntityListTile(
      icon: Icons.place_outlined,
      title: address.isEmpty ? 'No address provided' : address,
      subtitle: (facility.contact != null && facility.contact!.isNotEmpty)
          ? facility.contact
          : null,
      actions: [
        if (owner)
          EntityAction(
            icon: Icons.edit_outlined,
            tooltip: 'Edit facility',
            onPressed: editAction,
          ),
        if (owner)
          EntityAction(
            icon: Icons.delete_outline,
            tooltip: 'Remove facility',
            onPressed: deleteAction,
            destructive: true,
          ),
      ],
    );
  }
}
