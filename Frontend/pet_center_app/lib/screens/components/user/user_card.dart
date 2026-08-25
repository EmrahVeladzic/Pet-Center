import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/user/user_response_dto.dart';
import 'package:pet_center_app/screens/components/confirmation_dialog.dart';
import 'package:pet_center_app/screens/components/entity_list_tile.dart';
import 'package:pet_center_app/screens/components/status_chip.dart';

class UserCard extends StatelessWidget {
  final UserResponseDTO user;
  final VoidCallback callback;
  final bool asEmployer;
  final bool employed;

  const UserCard({
    super.key,
    required this.user,
    required this.asEmployer,
    required this.callback,
    required this.employed,
  });

  @override
  Widget build(BuildContext context) {
    void confirm() {
      showDialog<bool>(
        context: context,
        builder: (_) => ConfirmationDialog(
          confirmAction: callback,
          title: employed ? 'Remove this employee?' : 'Hire this person?',
          body: employed
              ? 'This person will no longer be employed at this franchise and will lose the access that comes with it.'
              : 'This person will be employed at this franchise and will gain the access that comes with it.',
          consequence: employed
              ? 'You can hire them again later, but any access tied to the role ends immediately.'
              : null,
          confirmLabel: employed ? 'Remove' : 'Hire',
          destructive: employed,
        ),
      );
    }

    return EntityListTile(
      icon: Icons.person_outline,
      title: user.userName.isEmpty ? 'Unnamed user' : user.userName,
      subtitle: employed ? 'Currently employed here' : 'Not employed here',
      chips: [
        StatusChip(
          label: employed ? 'Employed' : 'Available',
          tone: employed ? StatusTone.success : StatusTone.neutral,
        ),
      ],
      actions: [
        if (asEmployer)
          EntityAction(
            icon: employed ? Icons.person_remove : Icons.person_add,
            tooltip: employed ? 'Remove from franchise' : 'Hire',
            onPressed: confirm,
            destructive: employed,
          ),
      ],
    );
  }
}
