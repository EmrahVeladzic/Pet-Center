import 'package:flutter/material.dart';

import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/globals.dart';

class DualTextEntryDialog extends StatefulWidget {
  final int limit;
  final String? dialogName;
  final String? linkName;
  final VoidCallback? linkCallback;
  final void Function(String first, String second) callback;
  final bool hideText;
  final String? firstDecor;
  final String? secondDecor;
  const DualTextEntryDialog({
    super.key,
    required this.callback,
    this.limit = 75,
    this.hideText = false,
    this.dialogName,
    this.linkName,
    this.linkCallback,
    this.firstDecor,
    this.secondDecor,
  });

  @override
  State<StatefulWidget> createState() => _DualTextEntryDialogState();
}

class _DualTextEntryDialogState extends State<DualTextEntryDialog> {
  final TextEditingController _firstController = TextEditingController();
  final TextEditingController _secondController = TextEditingController();
  void invokeCallback() async {
    final firstText = _firstController.text.trim();
    final secondText = _secondController.text.trim();
    widget.callback(firstText, secondText);
  }

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
              child: design.textMarquee('${widget.dialogName ?? 'Enter:'}:'),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        content: SizedBox(
          width: design.dialogWidth,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ColoredBox(
                  color: listTone,
                  child: TextField(
                    controller: _firstController,
                    maxLines: 1,
                    maxLength: widget.limit,
                    minLines: 1,
                    keyboardType: TextInputType.multiline,
                    obscureText: widget.hideText,
                    decoration: InputDecoration(
                      labelText: widget.firstDecor ?? 'Text...',
                    ),
                  ),
                ),
                design.verticalGap(design.spacing / 2),
                ColoredBox(
                  color: listTone,
                  child: TextField(
                    controller: _secondController,
                    maxLines: 1,
                    maxLength: widget.limit,
                    minLines: 1,
                    keyboardType: TextInputType.multiline,
                    obscureText: widget.hideText,
                    decoration: InputDecoration(
                      labelText: widget.secondDecor ?? 'Text...',
                    ),
                  ),
                ),
                if (widget.linkCallback != null) ...[
                  design.verticalGap(design.spacing / 2),
                  TextButton(
                    onPressed: () {
                      if (widget.linkCallback != null && !apiServiceBusy) {
                        widget.linkCallback!();
                      }
                    },
                    child: design.fittedText((widget.linkName ?? 'Problem?')),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (apiServiceBusy) {
                return;
              }
              Navigator.of(context).pop();
              invokeCallback();
            },
            child: design.fittedText('Save'),
          ),
        ],
      ),
    );
  }
}
