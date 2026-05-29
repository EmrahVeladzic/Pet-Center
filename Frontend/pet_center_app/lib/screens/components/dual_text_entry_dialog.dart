import 'package:flutter/material.dart';

import 'package:pet_center_app/utils/app_style.dart';

class DualTextEntryDialog extends StatefulWidget {
  final String firstInitText;
  final String secondInitText;
  final int limit;
  final String? dialogName;
  final String? linkName;
  final VoidCallback? linkCallback;
  final void Function(String first, String second) callback;
  final bool hideText;
  final String? firstDecor;
  final String? secondDecor;
  final String? Function(String? value)? sharedValidation;
  final String? Function(String? value)? firstValidation;
  final String? Function(String? value)? secondValidation;
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
    this.firstValidation,
    this.secondValidation,
    this.sharedValidation,
    this.firstInitText = "",
    this.secondInitText = "",
  });

  @override
  State<StatefulWidget> createState() => _DualTextEntryDialogState();
}

class _DualTextEntryDialogState extends State<DualTextEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstController;
  late final TextEditingController _secondController;
  void invokeCallback() async {
    final firstText = _firstController.text.trim();
    final secondText = _secondController.text.trim();
    widget.callback(firstText, secondText);
  }

  @override
  void initState() {
    _firstController = TextEditingController(text: widget.firstInitText);
    _secondController = TextEditingController(text: widget.secondInitText);
    super.initState();
  }

  @override
  void dispose() {
    _firstController.dispose();
    _secondController.dispose();
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
                    child: TextFormField(
                      controller: _firstController,
                      maxLines: 1,
                      maxLength: widget.limit,
                      minLines: 1,
                      keyboardType: TextInputType.text,
                      obscureText: widget.hideText,
                      decoration: InputDecoration(
                        labelText: widget.firstDecor ?? 'Text...',
                      ),
                      validator: (value) {
                        if (widget.sharedValidation != null) {
                          return widget.sharedValidation!(value);
                        } else if (widget.firstValidation != null) {
                          return widget.firstValidation!(value);
                        } else {
                          return null;
                        }
                      },
                    ),
                  ),
                  design.verticalGap(design.spacing / 2),
                  ColoredBox(
                    color: listTone,
                    child: TextFormField(
                      controller: _secondController,
                      maxLines: 1,
                      maxLength: widget.limit,
                      minLines: 1,
                      keyboardType: TextInputType.text,
                      obscureText: widget.hideText,
                      decoration: InputDecoration(
                        labelText: widget.secondDecor ?? 'Text...',
                      ),
                      validator: (value) {
                        if (widget.sharedValidation != null) {
                          return widget.sharedValidation!(value);
                        } else if (widget.secondValidation != null) {
                          return widget.secondValidation!(value);
                        } else {
                          return null;
                        }
                      },
                    ),
                  ),
                  if (widget.linkCallback != null) ...[
                    design.verticalGap(design.spacing / 2),
                    TextButton(
                      onPressed: () {
                        if (widget.linkCallback != null) {
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
                if (_formKey.currentState != null &&
                    _formKey.currentState!.validate()) {
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
