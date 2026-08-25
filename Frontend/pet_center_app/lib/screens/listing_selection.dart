import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/breed_dto.dart';
import 'package:pet_center_app/models/data_transfer/individual/individual_response_dto.dart';
import 'package:pet_center_app/models/data_transfer/listing/listing_response_dto.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/components/listing/listing_card.dart';
import 'package:pet_center_app/screens/components/status_chip.dart';
import 'package:pet_center_app/screens/components/listing/listing_filters.dart';
import 'package:pet_center_app/screens/components/app_data_table.dart';
import 'package:pet_center_app/screens/components/media_thumbnail.dart';
import 'package:pet_center_app/screens/components/page_selector.dart';
import 'package:pet_center_app/screens/listing_edit.dart';
import 'package:pet_center_app/screens/listing_view.dart';
import 'package:pet_center_app/screens/templates/data_screen_scaffold.dart';
import 'package:pet_center_app/services/listing_service.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/utils/hive_cache.dart';
import 'package:pet_center_app/utils/jwt_utils.dart';
import 'package:pet_center_app/utils/tokens.dart';

class ListingSelectionScreen extends StatefulWidget {
  final int maxPage;
  final ListingType initType;
  final OrderingMethod initOrdering;
  final String? initRelevant;
  final bool? initShowApproved;
  final IndividualResponseDTO? initAnimal;
  final String? initKind;
  final VoidCallback? onModify;

  const ListingSelectionScreen({
    super.key,
    required this.maxPage,
    required this.initType,
    this.initOrdering = OrderingMethod.id,
    this.initRelevant,
    this.initShowApproved,
    this.initAnimal,
    this.initKind,
    this.onModify,
  });

  @override
  State<StatefulWidget> createState() => _ListingSelectionScreenState();
}

class _ListingSelectionScreenState extends State<ListingSelectionScreen> {
  List<ListingResponseDTO> dataSource = [];
  bool _initLoading = true;
  final _pageSelectorKey = GlobalKey<PageSelectorState>();

  late ListingType type;
  late OrderingMethod ordering;
  String? relevant;
  bool? showApproved;
  String? kind;
  String? breed;
  bool? sex;
  AnimalScale? scale;

  @override
  void initState() {
    super.initState();
    type = widget.initType;
    ordering = widget.initOrdering;
    relevant = widget.initRelevant;
    showApproved = widget.initShowApproved;

    breed = widget.initAnimal?.breedId;
    sex = widget.initAnimal?.sex;

    scale = kinds
        .expand((kind) => kind.breeds)
        .cast<BreedDTO?>()
        .firstWhere(
          (breed) => breed?.id == widget.initAnimal?.breedId,
          orElse: () => null,
        )
        ?.scale;

    kind =
        widget.initKind ??
        kinds
            .expand((kind) => kind.breeds)
            .cast<BreedDTO?>()
            .firstWhere(
              (breed) => breed?.id == widget.initAnimal?.breedId,
              orElse: () => null,
            )
            ?.kindId;

    switchPage(0);
  }

  void switchPage(int page) async {
    final newDataSrc = await ListingService.get(
      page,
      type,
      ordering,
      relevantId: relevant,
      showEvaluated: showApproved,
      kindSpecific: kind,
      breedSpecific: breed,
      sexSpecific: sex,
      scaleSpecific: scale,
    );
    if (newDataSrc != null && mounted) {
      setState(() {
        _initLoading = false;
        dataSource = newDataSrc;
      });
    } else {
      _pageSelectorKey.currentState?.revertPage();
    }
  }

  void resetPages(
    ListingType t,
    OrderingMethod o,
    String? r,
    bool? sh,
    String? k,
    String? b,
    bool? s,
    AnimalScale? sc,
  ) async {
    final output = await ListingService.count(
      t,
      o,
      relevantId: r,
      showEvaluated: sh,
      kindSpecific: k,
      breedSpecific: b,
      sexSpecific: s,
      scaleSpecific: sc,
    );

    if (output != null) {
      if (!mounted) return;

      setState(() {
        type = t;
        ordering = o;
        relevant = r;
        showApproved = sh;
        kind = k;
        breed = b;
        sex = s;
        scale = sc;
      });
      _pageSelectorKey.currentState?.resetMax(output);
    }
  }

  void createListing() async {
    if (relevant == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ListingEditScreen(
          franchiseId: relevant!,
          callback: (value) {
            resetPages(
              type,
              ordering,
              relevant,
              showApproved,
              kind,
              breed,
              sex,
              scale,
            );
          },
        ),
      ),
    );
  }

  void viewListing(ListingResponseDTO src) async {
    await CacheManager.write(src.id!, CacheEntityType.listing);
    setState(() {
      if (!visitedListingIndices.contains(src.id!)) {
        visitedListingIndices.add(src.id!);
      }
    });

    if (!mounted) return;

    final shouldRefresh = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ListingViewScreen(
          listing: src,
          forAnimal: widget.initAnimal?.id,
          obtainHook: () {
            if (mounted) {
              resetPages(
                type,
                ordering,
                relevant,
                showApproved,
                kind,
                breed,
                sex,
                scale,
              );

              if (widget.onModify != null) widget.onModify!();
            }
          },
          onModify: (hard) {
            if (mounted) {
              resetPages(
                type,
                ordering,
                relevant,
                showApproved,
                kind,
                breed,
                sex,
                scale,
              );

              if (widget.onModify != null) widget.onModify!();
            }
          },
        ),
      ),
    );

    if (shouldRefresh == true) {
      resetPages(
        type,
        ordering,
        relevant,
        showApproved,
        kind,
        breed,
        sex,
        scale,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DataScreenScaffold<ListingFilters, ListingResponseDTO>(
      importActions: [
        if (role == Access.business &&
            relevant != null &&
            self?.workplaces?.any((w) => w.id == relevant) == true) ...[
          IconButton(
            tooltip: "Create listing",
            icon: const Icon(Icons.add),
            onPressed: createListing,
          ),
        ],
      ],
      maxPage: widget.maxPage,
      switchPage: switchPage,
      pageSelectorKey: _pageSelectorKey,
      appTitle: 'Listings',
      description:
          'Products, services and animals offered across the platform.',
      emptyTitle: 'No listings yet',
      loading: _initLoading,
      filterPrereq: true,
      dataSource: dataSource,
      filter: ListingFilters(
        role: role,
        callback: resetPages,
        initType: type,
        initOrdering: ordering,
        initRelevant: relevant,
        initShowApproved: showApproved,
        initKind: kind,
        initBreed: breed,
        initSex: sex,
        initScale: scale,
      ),
      columns: [
        DataColumnSpec<ListingResponseDTO>(
          label: 'Listing',
          flex: 5,
          cell: (context, listing) => Row(
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
                      listing.name.isEmpty ? 'Untitled listing' : listing.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      listing.franchiseName.isEmpty
                          ? 'Unknown provider'
                          : listing.franchiseName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        DataColumnSpec<ListingResponseDTO>(
          label: 'Price',
          flex: 2,
          cell: (context, listing) => ListingPrice(listing: listing),
        ),
        DataColumnSpec<ListingResponseDTO>(
          label: 'Status',
          flex: 3,
          hideOnMedium: true,
          cell: (context, listing) => Wrap(
            spacing: Spacing.xxs,
            runSpacing: Spacing.xxs,
            children: [
              if (ownsListing(listing)) VisibilityChip(listing: listing),
              if (visitedListingIndices.contains(listing.id))
                const StatusChip(label: 'Seen', tone: StatusTone.neutral),
            ],
          ),
        ),
        DataColumnSpec<ListingResponseDTO>(
          label: 'Actions',
          flex: 2,
          alignment: Alignment.centerRight,
          cell: (context, listing) => IconButton(
            tooltip: 'Open listing',
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              if (listing.id != null) {
                viewListing(listing);
              }
            },
          ),
        ),
      ],
      onRowTap: (listing) {
        if (listing.id != null) {
          viewListing(listing);
        }
      },
      itemBuilder: (p0, source) {
        return ListingCard(
          listing: source,
          onTap: () {
            if (source.id != null) {
              viewListing(source);
            }
          },
          visited: visitedListingIndices.contains(source.id),
        );
      },
    );
  }
}
