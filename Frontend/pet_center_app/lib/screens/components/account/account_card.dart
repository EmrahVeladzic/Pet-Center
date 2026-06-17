import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/account/account_response_dto.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/components/confirmation_dialog.dart';

import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/jwt_parser.dart';

class AccountCard extends StatefulWidget {
  final AccountResponseDTO acc;
  final VoidCallback onTap;
  final void Function(Access acc) onChangeRole;
  const AccountCard({
    super.key,
    required this.acc,
    required this.onTap,
    required this.onChangeRole,
  });
  @override
  State<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<AccountCard> {
  int _dropdownKey = 0;

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 0, vertical: 1),
      child: Container(
        padding: EdgeInsets.all(design.spacing),
        decoration: design.panelDecoration(),
        child: Row(
          children: [
            Expanded(
              flex: 7,
              child: design.fittedText(
                "${widget.acc.contact} - ${widget.acc.accessLevel.displayName} - ${widget.acc.verified ? "Verified" : "Unverified"}",
              ),
            ),

            if (role.value > widget.acc.accessLevel.value) ...[
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
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => ConfirmationDialog(
                              confirmAction: widget.onTap,
                              title: "Ban account",
                            ),
                          );
                        },
                        icon: const Icon(Icons.gavel),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ),
                ),
              ),
            ],

            if (role == Access.owner &&
                widget.acc.accessLevel == Access.admin) ...[
              Expanded(
                flex: 4,
                child: ElevatedButton(
                  child: design.fittedText("Promote to co-owner"),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => ConfirmationDialog(
                        confirmAction: () {
                          widget.onChangeRole(Access.owner);
                        },
                        title: "Warning",
                        body:
                            "Promoting this account to this role would make it your peer. Continue?",
                      ),
                    ).then((confirmed) {
                      if (confirmed != true) {
                        setState(() => _dropdownKey++);
                      }
                    });
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
