import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/kind_dto.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/components/entity_list_tile.dart';
import 'package:pet_center_app/screens/components/status_chip.dart';
import 'package:pet_center_app/utils/tokens.dart';

class KindCard extends StatelessWidget {
  final KindDTO kind;
  final VoidCallback editAction;
  final VoidCallback deleteAction;
  final VoidCallback breedListAction;

  const KindCard({
    super.key,
    required this.kind,
    required this.editAction,
    required this.deleteAction,
    required this.breedListAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final breeds = kind.breeds;
    final count = breeds.length;

    return EntityListTile(
      icon: Icons.pets,
      title: kind.title.isEmpty ? 'Untitled species' : kind.title,
      subtitle: count == 0
          ? 'No breeds defined yet'
          : (count == 1 ? '1 breed' : '$count breeds'),
      onTap: breedListAction,
      chips: [
        if (count == 0)
          const StatusChip(label: 'Incomplete', tone: StatusTone.warning),
      ],
      actions: [
        EntityAction(
          icon: Icons.list_alt,
          tooltip: 'View breeds',
          onPressed: breedListAction,
        ),
        EntityAction(
          icon: Icons.edit_outlined,
          tooltip: 'Rename species',
          onPressed: editAction,
        ),
        EntityAction(
          icon: Icons.delete_outline,
          tooltip: 'Delete species',
          onPressed: deleteAction,
          destructive: true,
        ),
      ],
      expanded: count == 0
          ? null
          : Theme(
              data: theme.copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text('Breeds', style: theme.textTheme.titleSmall),
                children: [
                  Wrap(
                    spacing: Spacing.xs,
                    runSpacing: Spacing.xs,
                    children: [
                      for (final breed in breeds)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Spacing.xs,
                            vertical: Spacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerLow,
                            borderRadius: Radii.smAll,
                            border: Border.all(color: scheme.outlineVariant),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  breed.title.isEmpty
                                      ? 'Untitled breed'
                                      : breed.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ),
                              const SizedBox(width: Spacing.xxs),
                              Text(
                                breed.scale.displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
