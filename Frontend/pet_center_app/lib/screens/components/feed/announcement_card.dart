import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/user/user_response_dto.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/components/entity_list_tile.dart';
import 'package:pet_center_app/screens/components/status_chip.dart';
import 'package:pet_center_app/utils/helpers.dart';
import 'package:pet_center_app/utils/jwt_utils.dart';
import 'package:pet_center_app/utils/tokens.dart';

class AnnouncementCard extends StatelessWidget {
  final AnnouncementSubDTO announcement;
  final bool visited;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const AnnouncementCard({
    super.key,
    required this.announcement,
    required this.visited,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final note = announcement.notes?.firstOrNull;

    return EntityListTile(
      icon: Icons.campaign_outlined,
      visited: visited,
      title: announcement.body.isEmpty
          ? 'Empty announcement'
          : announcement.body,
      subtitle: 'Posted ${formatDate(announcement.datePosted)}',
      chips: [
        if (!visited) const StatusChip(label: 'New', tone: StatusTone.info),
      ],
      actions: [
        EntityAction(
          icon: Icons.done_all,
          tooltip: 'Mark as read',
          onPressed: visited ? null : onTap,
        ),
        if (role == Access.owner)
          EntityAction(
            icon: Icons.delete_outline,
            tooltip: 'Delete announcement',
            onPressed: onDelete,
            destructive: true,
          ),
      ],
      expanded: note == null
          ? null
          : Container(
              padding: const EdgeInsets.all(Spacing.sm),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: Radii.smAll,
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    note.title,
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: Spacing.xxs),
                  Text(
                    note.body,
                    softWrap: true,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
