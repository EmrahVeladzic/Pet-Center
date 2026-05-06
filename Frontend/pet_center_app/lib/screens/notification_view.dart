import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/user/user_response_dto.dart';
import 'package:pet_center_app/screens/listing_view.dart';
import 'package:pet_center_app/services/listing_service.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/helpers.dart';

class NotificationViewScreen extends StatefulWidget {
  final NotificationSubDTO notification;
  const NotificationViewScreen({super.key, required this.notification});

  @override
  State<NotificationViewScreen> createState() => _NotificationViewScreenState();
}

class _NotificationViewScreenState extends State<NotificationViewScreen> {
  void getRelevant() async {
    if (validGuid(widget.notification.listingId)) {
      final listing = await ListingService.getById(
        widget.notification.listingId!,
      );

      if (listing != null) {
        if (!mounted) {
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ListingViewScreen(listing: listing),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    final notif = widget.notification;

    return Scaffold(
      backgroundColor: mainTone,
      appBar: AppBar(
        leading: BackButton(),
        title: SizedBox(
          width: design.screenWidth * marqueeTitleWMult,
          height: design.marqueeSize,
          child: design.textMarquee(notif.title),
        ),
      ),
      body: Center(
        child: FractionallySizedBox(
          widthFactor: design.bodyWMult,
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
              ElevatedButton(
                onPressed: getRelevant,
                child: design.fittedText("Go"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
