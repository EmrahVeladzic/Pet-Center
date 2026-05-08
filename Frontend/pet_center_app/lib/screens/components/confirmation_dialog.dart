import 'package:flutter/material.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/globals.dart';

class ConfirmationDialog extends StatefulWidget {
  final String title;
  final String body;
  final VoidCallback confirmAction;
  const ConfirmationDialog({
    super.key,
    required this.confirmAction,
    this.title = 'Confirm',
    this.body = 'Are you sure you want to do this?',
  });

  @override
  State<StatefulWidget> createState() => _ConfirmationDialogState();
}

class _ConfirmationDialogState extends State<ConfirmationDialog> {
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
            Expanded(child: design.textMarquee(widget.title)),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [design.textMarquee(widget.body)],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (apiServiceBusy) {
                return;
              }
              Navigator.of(context).pop();
              widget.confirmAction();
            },
            child: design.fittedText('OK'),
          ),
        ],
      ),
    );
  }
}
