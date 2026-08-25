import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/breed_dto.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/breed_edit.dart';
import 'package:pet_center_app/screens/components/breed/breed_card.dart';
import 'package:pet_center_app/screens/components/breed/breed_filters.dart';
import 'package:pet_center_app/screens/components/confirmation_dialog.dart';
import 'package:pet_center_app/screens/components/app_data_table.dart';
import 'package:pet_center_app/screens/components/media_thumbnail.dart';
import 'package:pet_center_app/screens/components/page_selector.dart';
import 'package:pet_center_app/screens/components/status_chip.dart';
import 'package:pet_center_app/screens/listing_selection.dart';
import 'package:pet_center_app/screens/templates/data_screen_scaffold.dart';
import 'package:pet_center_app/services/breed_service.dart';
import 'package:pet_center_app/services/listing_service.dart';

import 'package:pet_center_app/utils/jwt_utils.dart';
import 'package:pet_center_app/utils/tokens.dart';

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
      });
      _pageSelectorKey.currentState?.resetMax(output);
    }
  }

  void removeBreed(String id) async {
    final output = await BreedService.delete(id);

    if (output) {
      resetPages(incomplete, adoption);
    }
  }

  void createBreed() async {
    if (widget.kindId == null) {
      return;
    }
    final shouldRefresh = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BreedEditScreen(
          kindId: widget.kindId!,
          callback: () {
            resetPages(incomplete, adoption);
          },
        ),
      ),
    );
    if (shouldRefresh == true) {
      resetPages(incomplete, adoption);
    }
  }

  void editBreed(BreedDTO current) async {
    if (widget.kindId == null) {
      return;
    }
    final shouldRefresh = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BreedEditScreen(
          fromCurrent: current,
          kindId: widget.kindId!,
          callback: () {
            resetPages(incomplete, adoption);
          },
        ),
      ),
    );
    if (shouldRefresh == true) {
      resetPages(incomplete, adoption);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DataScreenScaffold<BreedFilters, BreedDTO>(
      importActions: [
        if (role == Access.admin || role == Access.owner) ...[
          IconButton(
            tooltip: "Define breed",
            icon: Icon(Icons.add),
            onPressed: createBreed,
          ),
        ],
      ],
      maxPage: widget.maxPage,
      switchPage: switchPage,
      pageSelectorKey: _pageSelectorKey,
      appTitle: (role == Access.user) ? 'Recommended breeds' : 'Breeds',
      description: (role == Access.user)
          ? 'Breeds that best match the living conditions you described.'
          : 'Breeds available in the system, grouped by species.',
      emptyTitle: 'No breeds found',
      loading: _initLoading,
      filterPrereq:
          (role == Access.owner || role == Access.admin || role == Access.user),
      dataSource: dataSource,
      filter: BreedFilters(
        callback: resetPages,
        initAdoption: adoption,
        initIncomplete: incomplete,
      ),
      columns: [
        DataColumnSpec<BreedDTO>(
          label: 'Breed',
          flex: 4,
          cell: (context, breed) => Row(
            children: [
              MediaThumbnail(media: breed.media, fallbackIcon: Icons.pets),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Text(
                  breed.title.isEmpty ? 'Untitled breed' : breed.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ],
          ),
        ),
        DataColumnSpec<BreedDTO>(
          label: 'Scale',
          flex: 2,
          cell: (context, breed) => StatusChip(
            label: breed.scale.displayName,
            tone: StatusTone.neutral,
            showDot: false,
          ),
        ),
        DataColumnSpec<BreedDTO>(
          label: 'Traits',
          flex: 6,
          hideOnMedium: true,
          cell: (context, breed) => BreedTraits(breed: breed),
        ),
        DataColumnSpec<BreedDTO>(
          label: 'Actions',
          flex: 2,
          alignment: Alignment.centerRight,
          cell: (context, breed) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Open breed',
                icon: const Icon(Icons.arrow_forward),
                onPressed: () {
                  if (breed.id == null) {
                    return;
                  }
                  if (role == Access.admin || role == Access.owner) {
                    editBreed(breed);
                  } else {
                    switchToSelection(breed.id!);
                  }
                },
              ),
              if (role == Access.admin || role == Access.owner)
                IconButton(
                  tooltip: 'Delete breed',
                  icon: const Icon(Icons.delete_outline),
                  style: IconButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  onPressed: () {
                    showDialog<bool>(
                      context: context,
                      builder: (_) => ConfirmationDialog(
                        title: "Remove this breed?",
                        body:
                            "The breed will be removed along with any data that references it.",
                        consequence:
                            "This cannot be undone. Animals and listings referencing this breed lose that reference.",
                        confirmLabel: "Remove breed",
                        destructive: true,
                        confirmAction: () {
                          final id = breed.id;
                          if (id != null) {
                            removeBreed(id);
                          }
                        },
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
      itemBuilder: (p0, source) {
        return BreedCard(
          breed: source,
          onTap: () {
            final id = source.id;

            if (id != null) {
              switchToSelection(id);
            }
          },
          onAdminTap: () {
            if (source.id == null) {
              return;
            }
            editBreed(source);
          },
          onDelete: () {
            showDialog(
              context: context,

              builder: (_) => ConfirmationDialog(
                title: "Remove this breed?",
                body:
                    "The breed will be removed along with any data that references it.",
                consequence:
                    "This cannot be undone. Animals and listings referencing this breed lose that reference.",
                confirmLabel: "Remove breed",
                destructive: true,
                confirmAction: () {
                  final id = source.id;

                  if (id != null) {
                    removeBreed(id);
                  }
                },
              ),
            );
          },

          adminMode: (role == Access.admin || role == Access.owner),
        );
      },
    );
  }
}
