import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/item_dto.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/components/entity_list_tile.dart';
import 'package:pet_center_app/screens/components/status_chip.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';

class ItemCard extends StatelessWidget {
  final ItemDTO item;
  final VoidCallback editAction;
  final VoidCallback deleteAction;

  const ItemCard({
    super.key,
    required this.item,
    required this.editAction,
    required this.deleteAction,
  });

  @override
  Widget build(BuildContext context) {
    final kindName =
        kinds.where((k) => k.id == item.kindId).firstOrNull?.title ?? 'Animal';
    final scale = item.scale;
    final target = scale == null
        ? 'For $kindName'
        : 'For $kindName, ${scale.displayName} scale';

    return EntityListTile(
      icon: Icons.inventory_2_outlined,
      title: item.title.isEmpty ? 'Untitled item' : item.title,
      subtitle: target,
      chips: [
        if (item.mass != null)
          StatusChip(
            label: '${item.mass} g',
            tone: StatusTone.neutral,
            showDot: false,
          ),
      ],
      actions: [
        EntityAction(
          icon: Icons.edit_outlined,
          tooltip: 'Edit item',
          onPressed: editAction,
        ),
        EntityAction(
          icon: Icons.delete_outline,
          tooltip: 'Delete item',
          onPressed: deleteAction,
          destructive: true,
        ),
      ],
    );
  }
}
