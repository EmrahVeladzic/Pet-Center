import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/user/user_response_dto.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/helpers.dart';

class NotificationViewScreen extends StatefulWidget {
  final NotificationSubDTO notification;
  const NotificationViewScreen({super.key, required this.notification});

  @override
  State<NotificationViewScreen> createState() => _NotificationViewScreenState();
}

class _NotificationViewScreenState extends State<NotificationViewScreen> {
  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    final bool isLandscape = design.layoutDirection == Axis.horizontal;
    final double wMult = isLandscape ? 0.5 : 1.0;

    final notif = widget.notification;

    void getRelevant() async {}

    return Scaffold(
      backgroundColor: mainTone,
      appBar: AppBar(
        leading: BackButton(),
        title: SizedBox(
          width: design.screenWidth * marqueeWMult,
          height: design.marqueeSize,
          child: design.textMarquee(notif.title),
        ),
      ),
      body: Center(
        child: FractionallySizedBox(
          widthFactor: wMult,
          heightFactor: 1.0,
          child: ColoredBox(
            color: panelTone,
            child: Padding(
              padding: EdgeInsetsGeometry.all(design.spacing),
              child: Text(notif.body),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (validGuid(notif.listingId)) ...[
              ElevatedButton(onPressed: getRelevant, child: Text("Go")),
            ],
          ],
        ),
      ),
    );
  }
}
