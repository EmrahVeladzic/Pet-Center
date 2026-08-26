import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/category_dto.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/components/entity_list_tile.dart';
import 'package:pet_center_app/screens/components/status_chip.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';

class UsageCard extends StatelessWidget {
  final UsageSubDTO usage;
  final VoidCallback editAction;
  final VoidCallback deleteAction;

  const UsageCard({
    super.key,
    required this.usage,
    required this.editAction,
    required this.deleteAction,
  });

  @override
  Widget build(BuildContext context) {
    final kindName =
        kinds.where((k) => k.id == usage.kindId).firstOrNull?.title ?? 'Animal';
    final scale = usage.scaleSpecific;

    return EntityListTile(
      icon: Icons.restaurant_outlined,
      title: scale == null ? kindName : '$kindName, ${scale.displayName} scale',
      chips: [
        StatusChip(
          label: '${usage.averageDailyAmountGrams} g/day',
          tone: StatusTone.neutral,
          showDot: false,
        ),
      ],
      actions: [
        EntityAction(
          icon: Icons.edit_outlined,
          tooltip: 'Edit usage estimate',
          onPressed: editAction,
        ),
        EntityAction(
          icon: Icons.delete_outline,
          tooltip: 'Remove usage estimate',
          onPressed: deleteAction,
          destructive: true,
        ),
      ],
    );
  }
}
