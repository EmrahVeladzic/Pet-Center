import 'package:flutter/material.dart';

import 'package:pet_center_app/utils/app_style.dart';

class TextEntryDialog extends StatefulWidget {
  final int limit;
  final String? dialogName;
  final void Function(String value) callback;
  final bool hideText;
  const TextEntryDialog({
    super.key,
    required this.callback,
    this.limit = 75,
    this.hideText = false,
    this.dialogName,
  });

  @override
  State<StatefulWidget> createState() => _TextEntryDialogState();
}

class _TextEntryDialogState extends State<TextEntryDialog> {
  final TextEditingController _controller = TextEditingController();

  void invokeCallback() async {
    final text = _controller.text.trim();
    widget.callback(text);
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
              child: design.textMarquee(
                '${(widget.dialogName != null) ? widget.dialogName : 'Enter:'}:',
              ),
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
                    controller: _controller,
                    maxLines: (widget.hideText) ? 1 : null,
                    maxLength: widget.limit,
                    minLines: (widget.hideText) ? 1 : dialogMinLines,
                    keyboardType: TextInputType.multiline,
                    obscureText: widget.hideText,
                    decoration: InputDecoration(labelText: 'Text...'),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              invokeCallback();
            },
            child: design.textMarquee('Save'),
          ),
        ],
      ),
    );
  }
}
