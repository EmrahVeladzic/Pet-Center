import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/breed_dto.dart';
import 'package:pet_center_app/models/data_transfer/individual/individual_response_dto.dart';
import 'package:pet_center_app/models/data_transfer/listing/listing_response_dto.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/components/listing/listing_card.dart';
import 'package:pet_center_app/screens/components/listing/listing_filters.dart';
import 'package:pet_center_app/screens/components/page_selector.dart';
import 'package:pet_center_app/screens/listing_edit.dart';
import 'package:pet_center_app/screens/listing_view.dart';
import 'package:pet_center_app/screens/templates/data_screen_scaffold.dart';
import 'package:pet_center_app/services/listing_service.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/utils/hive_cache.dart';
import 'package:pet_center_app/utils/jwt_parser.dart';

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
      showApprovedAndPending: showApproved,
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
      showApprovedAndPending: sh,
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
          IconButton(icon: const Icon(Icons.add), onPressed: createListing),
        ],
      ],
      maxPage: widget.maxPage,
      switchPage: switchPage,
      pageSelectorKey: _pageSelectorKey,
      appTitle: "Listings:",
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
