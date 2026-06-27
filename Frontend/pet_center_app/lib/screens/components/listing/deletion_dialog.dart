import 'package:flutter/material.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/jwt_utils.dart';

class DeletionDialog extends StatefulWidget {
  final bool bannable;
  final String? itemName;
  final void Function(bool ban) deletionAction;
  const DeletionDialog({
    super.key,
    required this.deletionAction,
    this.bannable = false,
    this.itemName,
  });

  @override
  State<StatefulWidget> createState() => _DeletionDialogState();
}

class _DeletionDialogState extends State<DeletionDialog> {
  bool banUser = false;

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: AlertDialog(
        title: Row(
          children: [
            Expanded(
              child: design.textMarquee('Remove ${widget.itemName ?? 'item'}?'),
            ),
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
            design.textMarquee(
              'You are about to remove this ${widget.itemName ?? 'item'}.',
            ),
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
            child: design.fittedText(
              widget.bannable && banUser ? 'Remove & Ban' : 'Remove',
            ),
          ),
        ],
      ),
    );
  }
}
