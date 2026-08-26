import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/user/user_response_dto.dart';
import 'package:pet_center_app/screens/components/entity_list_tile.dart';
import 'package:pet_center_app/screens/components/status_chip.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';

class SupplyRecordCard extends StatelessWidget {
  final SuppliesSubDTO supply;
  final VoidCallback deleteAction;

  const SupplyRecordCard({
    super.key,
    required this.supply,
    required this.deleteAction,
  });

  @override
  Widget build(BuildContext context) {
    final kind = kinds.where((k) => k.id == supply.kindId).firstOrNull;
    final cat = categories
        .where((c) => c.id == supply.consumableId)
        .firstOrNull;

    return EntityListTile(
      icon: Icons.inventory_2_outlined,
      title: cat?.title ?? 'Category',
      subtitle: 'For ${kind?.title ?? 'animals'}',
      chips: [
        StatusChip(
          label: '${supply.massGrams} g',
          tone: StatusTone.neutral,
          showDot: false,
        ),
      ],
      actions: [
        EntityAction(
          icon: Icons.delete_outline,
          tooltip: 'Remove supply record',
          onPressed: deleteAction,
          destructive: true,
        ),
      ],
    );
  }
}
