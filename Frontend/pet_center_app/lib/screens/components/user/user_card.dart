import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/user/user_response_dto.dart';
import 'package:pet_center_app/screens/components/confirmation_dialog.dart';
import 'package:pet_center_app/utils/app_style.dart';

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
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    void confirm() {
      showDialog(
        context: context,
        builder: (_) => ConfirmationDialog(
          confirmAction: callback,
          body:
              "Are you sure you wish to ${(employed) ? "fire" : "hire"} this person?",
          title: employed ? "Fire" : "Hire",
        ),
      );
    }

    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 0, vertical: 1),
      child: Container(
        decoration: design.panelDecoration(),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsetsGeometry.all(design.spacing),
                child: Text(user.userName),
              ),
            ),
            if (asEmployer) ...[
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.center,
                  child: IconButton(
                    onPressed: confirm,
                    icon: employed
                        ? const Icon(Icons.person_remove)
                        : const Icon(Icons.person_add),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
