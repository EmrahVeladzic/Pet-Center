import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/listing/listing_response_dto.dart';
import 'package:pet_center_app/screens/components/image_display.dart';
import 'package:pet_center_app/utils/app_style.dart';

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
                child: ImageDisplay(
                  dataSource: listing.media[0],
                  creationToken: null,
                  locked: true,
                ),
              ),
            ),

            Expanded(flex: 3, child: design.fittedText(listing.name)),
            Expanded(
              flex: 1,
              child: LayoutBuilder(
                builder: (context, constraints) => Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: constraints.maxHeight,
                    height: constraints.maxHeight,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
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
            ),
          ],
        ),
      ),
    );
  }
}
