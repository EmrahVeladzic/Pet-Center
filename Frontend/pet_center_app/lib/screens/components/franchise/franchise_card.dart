import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/facility_dto.dart';
import 'package:pet_center_app/models/data_transfer/franchise/franchise_response_dto.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/components/franchise/facility_card.dart';
import 'package:pet_center_app/services/facility_service.dart';
import 'package:pet_center_app/utils/app_style.dart';

import 'package:pet_center_app/utils/jwt_parser.dart';

class FranchiseCard extends StatelessWidget {
  final FranchiseResponseDTO franchise;
  final VoidCallback editAction;
  final VoidCallback deleteAction;
  final VoidCallback employeeViewAction;
  final VoidCallback rebuildCallback;

  const FranchiseCard({
    super.key,
    required this.franchise,
    required this.editAction,
    required this.deleteAction,
    required this.employeeViewAction,
    required this.rebuildCallback,
  });

  void removeFacility(String input) async {
    await FacilityService.delete(input);
  }

  void setFacility(FacilityDTO input) async {
    FacilityDTO? output;

    if (input.id == null) {
      output = await FacilityService.post(input);
    } else {
      output = await FacilityService.put(input, input.id!);
    }

    if (output != null) {
      franchise.facilities.removeWhere((f) => f.id == output!.id);
      franchise.facilities.add(output);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    final role = userToken?.role ?? Access.user;

    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 0, vertical: 1),
      child: Container(
        decoration: design.panelDecoration(),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(design.spacing),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Flexible(
                          fit: FlexFit.loose,
                          child: design.fittedText(
                            "${franchise.franchiseName}${(franchise.owned == true) ? " (Owner)" : ""}",
                            2.0,
                          ),
                        ),
                        Flexible(
                          fit: FlexFit.loose,
                          child: design.fittedText(franchise.contact),
                        ),
                      ],
                    ),
                  ),
                  if (role == Access.business && franchise.owned == true) ...[
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
                              onPressed: employeeViewAction,
                              icon: const Icon(Icons.person),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              constraints: const BoxConstraints(),
                            ),
                          ),
                        ),
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
                              onPressed: () {},
                              icon: const Icon(Icons.add),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              constraints: const BoxConstraints(),
                            ),
                          ),
                        ),
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
                              onPressed: editAction,
                              icon: const Icon(Icons.edit),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              constraints: const BoxConstraints(),
                            ),
                          ),
                        ),
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
                              onPressed: deleteAction,
                              icon: const Icon(Icons.delete),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              constraints: const BoxConstraints(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (franchise.facilities.isNotEmpty) ...[
              ExpansionTile(
                title: Text("Facilities"),
                children: franchise.facilities
                    .expand(
                      (e) => [
                        FacilityCard(
                          facility: e,
                          owner: franchise.owned ?? false,
                          editAction: () {
                            setFacility(e);
                          },
                          deleteAction: () {
                            final id = e.id;
                            if (id != null) {
                              removeFacility(id);
                            }
                          },
                        ),
                        design.verticalGap(1),
                      ],
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
