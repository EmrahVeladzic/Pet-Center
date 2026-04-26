import 'package:flutter/material.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/jwt_parser.dart';

class DeletionDialog extends StatefulWidget {
  final bool bannable;
  final void Function(bool ban) deletionAction;
  const DeletionDialog({
    super.key,
    required this.deletionAction,
    this.bannable = false,
  });

  @override
  State<StatefulWidget> createState() => _DeletionDialogState();
}

class _DeletionDialogState extends State<DeletionDialog> {
  bool banUser = false;

  @override
  Widget build(BuildContext context) {
    final Access role = userToken?.role ?? Access.user;

    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    return AlertDialog(
      title: Row(
        children: [
          Expanded(child: design.textMarquee('Delete item?')),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          design.textMarquee('You are about to delete this item.'),
          if (widget.bannable &&
              (role == Access.owner || role == Access.admin)) ...[
            design.verticalGap(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: design.textMarquee('Ban user')),
                Switch(
                  value: banUser,
                  onChanged: (val) => setState(() => banUser = val),
                ),
              ],
            ),
          ],
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            widget.deletionAction(banUser);
          },
          child: design.textMarquee(
            widget.bannable && banUser ? 'Delete & Ban' : 'Delete',
          ),
        ),
      ],
    );
  }
}
