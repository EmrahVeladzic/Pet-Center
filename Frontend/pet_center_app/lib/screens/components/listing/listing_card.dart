import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/listing/listing_response_dto.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/components/media_thumbnail.dart';
import 'package:pet_center_app/screens/components/status_chip.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/utils/jwt_utils.dart';
import 'package:pet_center_app/utils/pricing.dart';
import 'package:pet_center_app/utils/tokens.dart';

bool ownsListing(ListingResponseDTO listing) {
  return role == Access.business &&
      self?.workplaces?.any((w) => w.id == listing.franchiseId) == true;
}

String listingPrice(ListingResponseDTO listing) {
  return fromMinor(listing.priceMinor, listing.listingDiscount?.percentage);
}

class ListingPrice extends StatelessWidget {
  final ListingResponseDTO listing;

  const ListingPrice({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final discount = listing.listingDiscount?.percentage;
    final discounted = discount != null && discount > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          listingPrice(listing),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(
            color: discounted ? scheme.primary : scheme.onSurface,
          ),
        ),
        if (discounted)
          Text(
            '$discount% off',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}

class VisibilityChip extends StatelessWidget {
  final ListingResponseDTO listing;

  const VisibilityChip({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    return StatusChip(
      label: listing.visible ? 'Visible' : 'Hidden',
      tone: listing.visible ? StatusTone.success : StatusTone.neutral,
      icon: listing.visible ? Icons.visibility : Icons.visibility_off,
    );
  }
}

class ListingCard extends StatefulWidget {
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
  State<ListingCard> createState() => _ListingCardState();
}

class _ListingCardState extends State<ListingCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final listing = widget.listing;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          padding: const EdgeInsets.all(Spacing.sm),
          decoration: BoxDecoration(
            color: _hovered
                ? scheme.surfaceContainerLow
                : (widget.visited ? scheme.surfaceContainer : scheme.surface),
            borderRadius: Radii.mdAll,
            border: Border.all(
              color: _hovered ? scheme.primary : scheme.outlineVariant,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MediaThumbnail(
                    media: listing.media,
                    fallbackIcon: Icons.sell_outlined,
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          listing.name.isEmpty
                              ? 'Untitled listing'
                              : listing.name,
                          softWrap: true,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: Spacing.xxs),
                        Text(
                          listing.franchiseName.isEmpty
                              ? 'Unknown provider'
                              : listing.franchiseName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: Spacing.xs),
                  ListingPrice(listing: listing),
                ],
              ),
              if (ownsListing(listing) || widget.visited) ...[
                const SizedBox(height: Spacing.sm),
                Wrap(
                  spacing: Spacing.xxs,
                  runSpacing: Spacing.xxs,
                  children: [
                    if (ownsListing(listing)) VisibilityChip(listing: listing),
                    if (widget.visited)
                      const StatusChip(label: 'Seen', tone: StatusTone.neutral),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
