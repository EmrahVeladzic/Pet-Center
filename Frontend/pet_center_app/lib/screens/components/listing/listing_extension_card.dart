import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/item_dto.dart';
import 'package:pet_center_app/models/data_transfer/listing/listing_response_dto.dart';
import 'package:pet_center_app/models/data_transfer/procedure_dto.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/utils/app_style.dart';

class ListingExtensionCard extends StatelessWidget {
  final ListingResponseDTO listing;

  const ListingExtensionCard({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    final item = items.cast<ItemDTO?>().firstWhere(
      (item) => item?.id == listing.productListingExtension?.productId,
      orElse: () => null,
    );

    final procedure = procedures.cast<ProcedureDTO?>().firstWhere(
      (procedure) =>
          procedure?.id == listing.medicalListingExtension?.procedureId,
      orElse: () => null,
    );

    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 0, vertical: 1),

      child: Column(
        children: [
          if (listing.type == ListingType.product &&
              listing.productListingExtension != null &&
              item != null) ...[
            Container(
              decoration: design.panelDecoration(),
              child: design.textMarquee(
                'This listing offers the following product:',
                design.screenWidth * design.bodyWMult,
                marqueeNoteWMult,
              ),
            ),
            Container(
              color: visitedPanelTone,
              child: design.textMarquee(
                '${listing.productListingExtension?.perListing}x - ${item.title}',
                design.screenWidth * design.bodyWMult,
                marqueeNoteWMult,
              ),
            ),
          ] else if (listing.type == ListingType.medical &&
              listing.medicalListingExtension != null &&
              procedure != null) ...[
            Container(
              decoration: design.panelDecoration(),
              child: design.textMarquee(
                'This listing offers the following procedure:',
                design.screenWidth * design.bodyWMult,
                marqueeNoteWMult,
              ),
            ),
            Container(
              color: visitedPanelTone,
              child: design.textMarquee(
                procedure.description,
                design.screenWidth * design.bodyWMult,
                marqueeNoteWMult,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
