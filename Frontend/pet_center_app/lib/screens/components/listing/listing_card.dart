import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/listing/listing_response_dto.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/components/image_display.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';

import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/jwt_parser.dart';
import 'package:pet_center_app/utils/pricing.dart';

class ListingCard extends StatelessWidget {
  final ListingResponseDTO listing;
  final bool visited;
  final VoidCallback onTap;

  const ListingCard({
    super.key,
    required this.listing,
    required this.visited,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    final role = userToken?.role ?? Access.user;

    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 0, vertical: 1),
      child: Container(
        padding: EdgeInsets.all(design.spacing),
        decoration: design.panelDecoration(visited),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: design.boundedImageSize,
                  height: design.boundedImageSize,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: ImageDisplay(
                      dataSource: (listing.media.isNotEmpty)
                          ? listing.media[0]
                          : null,
                      creationToken: null,
                      locked: true,
                      creating: false,
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              flex: 3,
              child: design.fittedText(
                "${(role == Access.business && (self?.workplaces?.any((w) => w.id == listing.franchiseId) == true) ? (listing.visible ? "(VISIBLE) - " : "(HIDDEN) - ") : "")}${listing.name} - ${fromMinor(listing.priceMinor, listing.listingDiscount?.percentage)}",
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
                      onPressed: onTap,
                      icon: const Icon(Icons.arrow_forward),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
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
