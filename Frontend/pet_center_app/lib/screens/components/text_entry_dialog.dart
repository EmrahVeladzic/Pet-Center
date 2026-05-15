import 'package:flutter/material.dart';

import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/globals.dart';

class TextEntryDialog extends StatefulWidget {
  final int limit;
  final String? dialogName;
  final String? inputDecoration;
  final void Function(String value) callback;
  final bool hideText;
  final String? Function(String? value)? validation;
  const TextEntryDialog({
    super.key,
    required this.callback,
    this.limit = 75,
    this.hideText = false,
    this.dialogName,
    this.inputDecoration,
    this.validation,
  });

  @override
  State<StatefulWidget> createState() => _TextEntryDialogState();
}

class _TextEntryDialogState extends State<TextEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();

  void invokeCallback() async {
    final text = _controller.text.trim();
    widget.callback(text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Form(
        key: _formKey,
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
                    child: TextFormField(
                      controller: _controller,
                      maxLines: (widget.hideText) ? 1 : null,
                      maxLength: widget.limit,
                      minLines: (widget.hideText) ? 1 : dialogMinLines,
                      keyboardType: (widget.hideText)
                          ? TextInputType.text
                          : TextInputType.multiline,
                      obscureText: widget.hideText,
                      decoration: InputDecoration(
                        labelText: widget.inputDecoration ?? "Text...",
                      ),
                      validator: (value) {
                        if (widget.validation != null) {
                          return widget.validation!(value);
                        } else {
                          return null;
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState != null &&
                    _formKey.currentState!.validate()) {
                  if (apiServiceBusy) {
                    return;
                  }
                  Navigator.of(context).pop();
                  invokeCallback();
                }
              },
              child: design.fittedText('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
