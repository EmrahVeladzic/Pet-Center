import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/listing/listing_response_dto.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/components/listing/listing_card.dart';
import 'package:pet_center_app/screens/components/listing/listing_filters.dart';
import 'package:pet_center_app/screens/components/page_selector.dart';
import 'package:pet_center_app/screens/listing_view.dart';
import 'package:pet_center_app/screens/templates/data_screen_scaffold.dart';
import 'package:pet_center_app/services/listing_service.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/utils/hive_cache.dart';

import 'package:pet_center_app/utils/jwt_parser.dart';

class ListingSelectionScreen extends StatefulWidget {
  final int maxPage;
  final String? kindId;
  final ListingType initType;
  final OrderingMethod initOrdering;
  final String? initRelevant;
  final bool? initShowApproved;
  final String? initKind;
  final String? initBreed;
  final bool? initSex;
  final AnimalScale? initScale;

  const ListingSelectionScreen({
    super.key,
    required this.maxPage,
    this.kindId,
    required this.initType,
    this.initOrdering = OrderingMethod.id,
    this.initRelevant,
    this.initShowApproved,
    this.initKind,
    this.initBreed,
    this.initSex,
    this.initScale,
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

  @override
  void initState() {
    super.initState();
    type = widget.initType;
    ordering = widget.initOrdering;
    relevant = widget.initRelevant;
    showApproved = widget.initShowApproved;
    kind = widget.initKind;
    breed = widget.initBreed;
    sex = widget.initSex;
    scale = widget.initScale;
    switchPage(0);
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
      if (!mounted) {
        return;
      }

      setState(() {
        type = t;
        ordering = o;
        relevant = r;
        showApproved = sh;
        kind = k;
        breed = b;
        sex = s;
        scale = sc;

        _pageSelectorKey.currentState?.resetMax(output);
      });
    }
  }

  void switchToSelection(ListingResponseDTO src) async {
    await CacheManager.write(src.id!, CacheEntityType.listing);
    setState(() {
      if (!visitedListingIndices.contains(src.id!)) {
        visitedListingIndices.add(src.id!);
      }
    });
    if (mounted) {
      final shouldRefresh = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ListingViewScreen(
            listing: src,
            onModify: () {
              if (mounted) {
                setState(() {});
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
  }

  @override
  Widget build(BuildContext context) {
    final role = userToken?.role ?? Access.user;

    return DataScreenScaffold<ListingFilters, ListingResponseDTO>(
      maxPage: widget.maxPage,
      switchPage: switchPage,
      pageSelectorKey: _pageSelectorKey,
      appTitle: "Listings:",
      loading: _initLoading,
      filterPrereq: (true),
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
            final id = source.id;

            if (id != null) {
              switchToSelection(source);
            }
          },

          visited: visitedListingIndices.contains(source.id),
        );
      },
    );
  }
}
