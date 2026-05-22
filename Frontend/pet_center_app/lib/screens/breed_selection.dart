import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/breed_dto.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/components/breed/breed_card.dart';
import 'package:pet_center_app/screens/components/breed/breed_filters.dart';
import 'package:pet_center_app/screens/components/page_selector.dart';
import 'package:pet_center_app/screens/listing_selection.dart';
import 'package:pet_center_app/screens/templates/data_screen_scaffold.dart';
import 'package:pet_center_app/services/breed_service.dart';
import 'package:pet_center_app/services/listing_service.dart';

import 'package:pet_center_app/utils/jwt_parser.dart';

class BreedSelectionScreen extends StatefulWidget {
  final int maxPage;
  final String? kindId;
  final bool adoptionPurposes;
  final bool incomplete;

  const BreedSelectionScreen({
    super.key,
    required this.maxPage,
    required this.adoptionPurposes,
    required this.incomplete,
    this.kindId,
  });

  @override
  State<StatefulWidget> createState() => _BreedSelectionScreenState();
}

class _BreedSelectionScreenState extends State<BreedSelectionScreen> {
  List<BreedDTO> dataSource = [];
  bool _initLoading = true;
  final _pageSelectorKey = GlobalKey<PageSelectorState>();
  late bool incomplete;
  late bool adoption;

  @override
  void initState() {
    super.initState();
    incomplete = widget.incomplete;
    adoption = widget.adoptionPurposes;
    switchPage(0);
  }

  void switchPage(int page) async {
    final newDataSrc = await BreedService.get(
      page,
      adoption,
      incomplete,
      widget.kindId,
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

  void switchToSelection(String id) async {
    final count = await ListingService.count(
      ListingType.pet,
      OrderingMethod.id,
      relevantId: id,
    );
    if (count != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ListingSelectionScreen(
            initType: ListingType.pet,
            initRelevant: id,
            maxPage: count,
          ),
        ),
      );
    }
  }

  void resetPages(bool inc, bool adp) async {
    final output = await BreedService.count(adp, inc, widget.kindId);

    if (output != null) {
      if (!mounted) {
        return;
      }

      setState(() {
        incomplete = inc;
        adoption = adp;

        _pageSelectorKey.currentState?.resetMax(output);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = userToken?.role ?? Access.user;

    return DataScreenScaffold<BreedFilters, BreedDTO>(
      maxPage: widget.maxPage,
      switchPage: switchPage,
      pageSelectorKey: _pageSelectorKey,
      appTitle: (role == Access.user)
          ? 'Best matches based on living condition:'
          : "Breeds:",
      loading: _initLoading,
      filterPrereq:
          (role == Access.owner || role == Access.admin || role == Access.user),
      dataSource: dataSource,
      filter: BreedFilters(
        callback: resetPages,
        initAdoption: adoption,
        initIncomplete: incomplete,
      ),
      itemBuilder: (p0, source) {
        return BreedCard(
          breed: source,
          onTap: () {
            final id = source.id;

            if (id != null) {
              switchToSelection(id);
            }
          },
          adminMode:
              (role == Access.admin ||
              role == Access.owner ||
              role == Access.user),
        );
      },
    );
  }
}
