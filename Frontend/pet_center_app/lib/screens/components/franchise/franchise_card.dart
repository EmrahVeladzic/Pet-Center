import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/facility_dto.dart';
import 'package:pet_center_app/models/data_transfer/franchise/franchise_response_dto.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/components/confirmation_dialog.dart';
import 'package:pet_center_app/screens/components/entity_list_tile.dart';
import 'package:pet_center_app/screens/components/franchise/facility_card.dart';
import 'package:pet_center_app/screens/components/franchise/facility_creation_dialog.dart';
import 'package:pet_center_app/screens/components/status_chip.dart';
import 'package:pet_center_app/screens/components/user/notification_dialog.dart';
import 'package:pet_center_app/services/facility_service.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/services/user_service.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/jwt_utils.dart';
import 'package:pet_center_app/utils/tokens.dart';

class FranchiseCard extends StatelessWidget {
  final FranchiseResponseDTO franchise;
  final VoidCallback editAction;
  final VoidCallback deleteAction;
  final VoidCallback employeeViewAction;
  final VoidCallback listingAction;
  final VoidCallback rebuildCallback;
  final VoidCallback animalAction;

  const FranchiseCard({
    super.key,
    required this.franchise,
    required this.editAction,
    required this.deleteAction,
    required this.employeeViewAction,
    required this.rebuildCallback,
    required this.listingAction,
    required this.animalAction,
  });

  bool get owns => role == Access.business && franchise.owned == true;

  bool get worksAt => role == Access.business && franchise.owned == false;

  void removeFacility(String input) async {
    final out = await FacilityService.delete(input);
    if (out) {
      franchise.facilities.removeWhere((f) => f.id == input);
      rebuildCallback();
    }
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
      rebuildCallback();
    }
  }

  void quit() async {
    String? output;

    if (franchise.id != null) {
      output = await UserService.setEmployee(self!.id!, franchise.id!, false);
    }

    if (output != null) {
      showSnackbar(output);
      self?.workplaces?.removeWhere((f) => f.id == franchise.id);
      rebuildCallback();
    }
  }

  void openFacilityDialog(BuildContext context, [FacilityDTO? edited]) {
    showDialog(
      context: context,
      builder: (_) => FacilityCreationDialog(
        creationCallback: (input) => setFacility(input),
        owningFranchiseId: franchise.id ?? '',
        editedObject: edited,
      ),
    );
  }

  void openNotificationDialog(BuildContext context) {
    if (self?.id == null || franchise.id == null) {
      return;
    }
    showDialog(
      context: context,
      builder: (_) => NotificationDialog(
        userId: self!.id!,
        franchiseId: franchise.id,
        callback: (value) {
          if (value == null || self == null) {
            return;
          }
          if (self!.notifications != null) {
            self!.notifications?.removeWhere((n) => n.id == value.id);
            self!.notifications?.add(value);
          } else {
            self!.notifications = [value];
          }
          showSnackbar('Notification added.');
        },
      ),
    );
  }

  List<EntityAction> actionsFor(BuildContext context) {
    if (owns) {
      return [
        EntityAction(
          icon: Icons.local_offer_outlined,
          tooltip: 'Listings',
          onPressed: listingAction,
        ),
        EntityAction(
          icon: Icons.pets,
          tooltip: 'Sheltered animals',
          onPressed: animalAction,
        ),
        EntityAction(
          icon: Icons.group_outlined,
          tooltip: 'Employees',
          onPressed: employeeViewAction,
        ),
        EntityAction(
          icon: Icons.campaign_outlined,
          tooltip: 'Notify employees',
          onPressed: () => openNotificationDialog(context),
        ),
        EntityAction(
          icon: Icons.add_business_outlined,
          tooltip: 'Add facility',
          onPressed: () => openFacilityDialog(context),
        ),
        EntityAction(
          icon: Icons.edit_outlined,
          tooltip: 'Edit franchise',
          onPressed: editAction,
        ),
        EntityAction(
          icon: Icons.delete_outline,
          tooltip: 'Remove franchise',
          onPressed: deleteAction,
          destructive: true,
        ),
      ];
    }

    if (worksAt) {
      return [
        EntityAction(
          icon: Icons.local_offer_outlined,
          tooltip: 'Listings',
          onPressed: listingAction,
        ),
        EntityAction(
          icon: Icons.pets,
          tooltip: 'Sheltered animals',
          onPressed: animalAction,
        ),
        EntityAction(
          icon: Icons.person_remove_outlined,
          tooltip: 'Quit this workplace',
          destructive: true,
          onPressed: () {
            showDialog<bool>(
              context: context,
              builder: (_) => ConfirmationDialog(
                confirmAction: quit,
                title: 'Quit this workplace?',
                body:
                    'You will stop working for ${franchise.franchiseName} and lose the access that comes with it.',
                consequence:
                    'You will need to be hired again to regain access to this franchise.',
                confirmLabel: 'Quit',
                destructive: true,
              ),
            );
          },
        ),
      ];
    }

    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actions = actionsFor(context);
    final facilities = franchise.facilities;

    return EntityListTile(
      icon: Icons.business_outlined,
      title: franchise.franchiseName.isEmpty
          ? 'Unnamed franchise'
          : franchise.franchiseName,
      subtitle: franchise.contact.isEmpty
          ? 'No contact provided'
          : franchise.contact,
      chips: [
        if (franchise.owned == true)
          const StatusChip(
            label: 'Owner',
            tone: StatusTone.info,
            icon: Icons.workspace_premium,
          )
        else if (worksAt)
          const StatusChip(label: 'Employee', tone: StatusTone.neutral),
      ],
      expanded: actions.isEmpty && facilities.isEmpty
          ? null
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (actions.isNotEmpty) ResponsiveActionBar(actions: actions),
                if (facilities.isNotEmpty) ...[
                  const SizedBox(height: Spacing.xs),
                  Theme(
                    data: theme.copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      title: Text(
                        facilities.length == 1
                            ? '1 facility'
                            : '${facilities.length} facilities',
                        style: theme.textTheme.titleSmall,
                      ),
                      children: [
                        for (final e in facilities) ...[
                          FacilityCard(
                            facility: e,
                            owner: franchise.owned ?? false,
                            editAction: () => openFacilityDialog(context, e),
                            deleteAction: () {
                              showDialog<bool>(
                                context: context,
                                builder: (_) => ConfirmationDialog(
                                  title: 'Remove this facility?',
                                  body:
                                      'The facility will be removed from this franchise.',
                                  consequence: 'This cannot be undone.',
                                  confirmLabel: 'Remove',
                                  destructive: true,
                                  confirmAction: () {
                                    final id = e.id;
                                    if (id != null) {
                                      removeFacility(id);
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: Spacing.xs),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
