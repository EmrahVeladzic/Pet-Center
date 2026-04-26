import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/user/user_response_dto.dart';
import 'package:pet_center_app/utils/app_style.dart';

class NotificationCard extends StatelessWidget {
  final NotificationSubDTO notification;
  final bool visited;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.visited,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 0, vertical: 1),
      child: Container(
        padding: EdgeInsets.all(design.spacing),
        decoration: design.panelDecoration(visited),
        child: Row(
          children: [
            Expanded(flex: 4, child: Text(notification.title)),
            Expanded(
              flex: 1,

              child: Align(
                alignment: Alignment.center,
                child: IconButton(
                  onPressed: onTap,
                  icon: const Icon(Icons.arrow_forward),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
