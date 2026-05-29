// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/franchise/franchise_request_dto.dart';
import 'package:pet_center_app/models/data_transfer/franchise/franchise_response_dto.dart';

import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/components/confirmation_dialog.dart';

import 'package:pet_center_app/screens/components/franchise/franchise_card.dart';
import 'package:pet_center_app/screens/components/franchise/franchise_edit_dialog.dart';

import 'package:pet_center_app/screens/form_selection.dart';
import 'package:pet_center_app/screens/individual_view.dart';
import 'package:pet_center_app/screens/listing_selection.dart';
import 'package:pet_center_app/screens/template_selection.dart';
import 'package:pet_center_app/screens/templates/screen_scaffold.dart';
import 'package:pet_center_app/screens/user_page.dart';
import 'package:pet_center_app/services/form_service.dart';

import 'package:pet_center_app/services/franchise_service.dart';
import 'package:pet_center_app/services/listing_service.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/services/user_service.dart';

import 'package:pet_center_app/utils/app_style.dart';

class FranchiseViewScreen extends StatefulWidget {
  const FranchiseViewScreen({super.key});

  @override
  State<StatefulWidget> createState() => _FranchiseViewScreenState();
}

class _FranchiseViewScreenState extends State<FranchiseViewScreen> {
  void updateFranchise(String id, FranchiseRequestDTO input) async {
    final output = await FranchiseService.put(input, id);

    if (output != null) {
      self?.workplaces?.removeWhere((f) => f.id == id);
      self?.workplaces?.add(output);
      rebuild();
    }
  }

  void removeFranchise(String id) async {
    final output = await FranchiseService.delete(id);

    if (output) {
      self?.workplaces?.removeWhere((f) => f.id == id);

      rebuild();
    }
  }

  void rebuild() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  void switchToUserView(String id) async {
    final output = await UserService.count(true, "", id);
    if (!mounted) {
      return;
    }
    if (output != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UserPageScreen(maxPage: output, franchiseId: id),
        ),
      );
    }
  }

  void switchToListingView(String id) async {
    final output = await ListingService.count(
      ListingType.generic,
      OrderingMethod.id,
      relevantId: id,
    );
    if (!mounted) {
      return;
    }
    if (output != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ListingSelectionScreen(
            maxPage: output,
            initRelevant: id,
            initType: ListingType.generic,
            initOrdering: OrderingMethod.id,
          ),
        ),
      );
    }
  }

  void switchToAnimalView(FranchiseResponseDTO dt) async {
    if (!mounted) {
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            IndividualViewScreen(src: dt.shelteredAnimals, onBehalf: dt.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    return BasicScreenScaffold(
      appBar: AppBar(
        title: SizedBox(
          width: design.screenWidth * marqueeTitleWMult,
          height: design.marqueeSize,
          child: design.textMarquee(
            'Workplaces:',
            design.screenWidth * marqueeTitleWMult,
          ),
        ),
      ),
      body: [
        ...(self?.workplaces ?? []).expand(
          (e) => [
            FranchiseCard(
              franchise: e,
              listingAction: () {
                final id = e.id;
                if (id == null) {
                  return;
                }
                switchToListingView(id);
              },
              animalAction: () {
                if (e.id == null) {
                  return;
                }
                switchToAnimalView(e);
              },
              editAction: () {
                showDialog(
                  context: context,
                  builder: (_) => FranchiseEditDialog(
                    editedObject: e,
                    editCallback: (input) {
                      final id = e.id;
                      if (id == null) {
                        return;
                      }
                      updateFranchise(id, input);
                    },
                  ),
                );
              },
              deleteAction: () {
                showDialog(
                  context: context,
                  builder: (_) => ConfirmationDialog(
                    title: "Remove franchise",
                    body:
                        "Are you sure you wish to remove this franchise? Doing so will require a new form application if you change your mind.",
                    confirmAction: () {
                      final id = e.id;
                      if (id != null) {
                        removeFranchise(id);
                      }
                    },
                  ),
                );
              },
              employeeViewAction: () {
                final id = e.id;
                if (e.id == null) {
                  return;
                }
                switchToUserView(id!);
              },
              rebuildCallback: rebuild,
            ),
            design.verticalGap(1),
          ],
        ),
      ],
      bottomNavigationBar: BottomAppBar(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (templates.isNotEmpty) ...[
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TemplateSelectionScreen(),
                      ),
                    );
                  },
                  child: design.fittedText("Register franchise"),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
