import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/user/user_response_dto.dart';
import 'package:pet_center_app/screens/components/entity_list_tile.dart';
import 'package:pet_center_app/screens/components/status_chip.dart';
import 'package:pet_center_app/utils/helpers.dart';

class NotificationCard extends StatelessWidget {
  final NotificationSubDTO notification;
  final VoidCallback onTap;
  final VoidCallback onSeen;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onSeen,
  });

  @override
  Widget build(BuildContext context) {
    final seen = notification.seen;

    return EntityListTile(
      icon: seen
          ? Icons.notifications_none_outlined
          : Icons.notifications_active_outlined,
      visited: seen,
      onTap: onTap,
      title: notification.title.isEmpty
          ? 'Untitled notification'
          : notification.title,
      subtitle: 'Received ${formatDate(notification.datePosted)}',
      chips: [
        if (!seen) const StatusChip(label: 'Unread', tone: StatusTone.info),
      ],
      actions: [
        EntityAction(
          icon: seen ? Icons.mark_email_unread_outlined : Icons.check,
          tooltip: seen ? 'Mark as unread' : 'Mark as read',
          onPressed: onSeen,
        ),
        EntityAction(
          icon: Icons.arrow_forward,
          tooltip: 'Open notification',
          onPressed: onTap,
        ),
      ],
    );
  }
}
