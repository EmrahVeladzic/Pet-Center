import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/facility_dto.dart';
import 'package:pet_center_app/screens/components/entity_list_tile.dart';
import 'package:pet_center_app/utils/tokens.dart';

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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final address = [
      facility.street,
      facility.city,
    ].where((part) => part.trim().isNotEmpty).join(', ');

    return Container(
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: Radii.smAll,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.place_outlined,
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
                  address.isEmpty ? 'No address provided' : address,
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
                if (facility.contact != null && facility.contact!.isNotEmpty)
                  Text(
                    facility.contact!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          if (owner) ...[
            const SizedBox(width: Spacing.xs),
            EntityActionBar(
              actions: [
                EntityAction(
                  icon: Icons.edit_outlined,
                  tooltip: 'Edit facility',
                  onPressed: editAction,
                ),
                EntityAction(
                  icon: Icons.delete_outline,
                  tooltip: 'Remove facility',
                  onPressed: deleteAction,
                  destructive: true,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
