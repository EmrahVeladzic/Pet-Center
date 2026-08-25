import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/category_dto.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/components/entity_list_tile.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/utils/tokens.dart';

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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final kindName =
        kinds.where((k) => k.id == usage.kindId).firstOrNull?.title ?? 'Animal';
    final scale = usage.scaleSpecific;
    final label = scale == null
        ? kindName
        : '$kindName, ${scale.displayName} scale';

    return Container(
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: Radii.smAll,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(
            Icons.restaurant_outlined,
            size: IconSizes.md,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(width: Spacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  '${usage.averageDailyAmountGrams} g per day',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.xs),
          EntityActionBar(
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
          ),
        ],
      ),
    );
  }
}
