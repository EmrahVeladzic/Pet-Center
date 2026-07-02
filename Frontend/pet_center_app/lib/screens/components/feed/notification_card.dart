import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/user/user_response_dto.dart';
import 'package:pet_center_app/utils/app_style.dart';
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
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 0, vertical: 1),
      child: Container(
        padding: EdgeInsets.all(design.spacing),
        decoration: design.panelDecoration(notification.seen),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text("Notification - ${notification.title}"),
            ),
            Expanded(
              flex: 1,
              child: Text(
                "Posted on:\n${formatDate(notification.datePosted)}",
                textAlign: TextAlign.center,
              ),
            ),

            Expanded(
              flex: 1,

              child: Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: design.boundedIconSize,
                  height: design.boundedIconSize,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: IconButton(
                      tooltip:
                          "Mark as ${notification.seen ? "not read" : "read"}",
                      onPressed: onSeen,
                      icon: notification.seen
                          ? const Icon(Icons.close)
                          : const Icon(Icons.check),
                      padding: EdgeInsets.zero,

                      constraints: const BoxConstraints(),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,

              child: Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: design.boundedIconSize,
                  height: design.boundedIconSize,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: IconButton(
                      tooltip: "Details",
                      onPressed: onTap,
                      icon: const Icon(Icons.arrow_forward),
                      padding: EdgeInsets.zero,

                      constraints: const BoxConstraints(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
