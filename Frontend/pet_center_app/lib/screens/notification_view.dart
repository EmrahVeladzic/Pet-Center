import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/listing/listing_response_dto.dart';
import 'package:pet_center_app/models/data_transfer/user/user_response_dto.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/components/listing_card.dart';
import 'package:pet_center_app/screens/listing_view.dart';
import 'package:pet_center_app/services/listing_service.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/helpers.dart';
import 'package:pet_center_app/utils/hive_cache.dart';

class NotificationViewScreen extends StatefulWidget {
  final NotificationSubDTO notification;
  const NotificationViewScreen({super.key, required this.notification});

  @override
  State<NotificationViewScreen> createState() => _NotificationViewScreenState();
}

class _NotificationViewScreenState extends State<NotificationViewScreen> {
  ListingResponseDTO? relevant;

  void getRelevant() async {
    if (validGuid(widget.notification.listingId)) {
      final listing = await ListingService.getById(
        widget.notification.listingId!,
      );
      if (!mounted) {
        return;
      }
      if (listing != null) {
        setState(() {
          relevant = listing;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getRelevant();
  }

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    final notif = widget.notification;

    void addIndex(String i) async {
      await CacheManager.write(i, CacheEntityType.listing);
      setState(() {
        if (!visitedListingIndices.contains(i)) {
          visitedListingIndices.add(i);
        }
      });
    }

    return Scaffold(
      backgroundColor: mainTone,
      appBar: AppBar(
        leading: BackButton(),
        title: SizedBox(
          width: design.screenWidth * marqueeTitleWMult,
          height: design.marqueeSize,
          child: design.textMarquee(
            notif.title,
            design.screenWidth * marqueeTitleWMult,
          ),
        ),
      ),
      body: Center(
        child: FractionallySizedBox(
          widthFactor: design.bodyWMult,
          heightFactor: 1.0,
          child: ColoredBox(
            color: panelTone,
            child: Padding(
              padding: EdgeInsets.all(design.spacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: SingleChildScrollView(child: Text(notif.body)),
                  ),
                  if (relevant != null)
                    Expanded(
                      flex: 1,
                      child: ListingCard(
                        listing: relevant!,
                        visited: visitedListingIndices.contains(relevant?.id),
                        onTap: () {
                          final listingId = relevant?.id;
                          if (listingId == null) return;
                          addIndex(listingId);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ListingViewScreen(listing: relevant!),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(),
    );
  }
}
