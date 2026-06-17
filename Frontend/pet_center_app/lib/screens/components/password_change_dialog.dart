import 'package:flutter/material.dart';

import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/validators.dart';

class PasswordChangeDialog extends StatefulWidget {
  final void Function(String oldPwd, String newPwd) callback;

  const PasswordChangeDialog({super.key, required this.callback});

  @override
  State<StatefulWidget> createState() => _PasswordChangeDialogState();
}

class _PasswordChangeDialogState extends State<PasswordChangeDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstController;
  late final TextEditingController _secondController;
  late final TextEditingController _thirdController;
  void invokeCallback() async {
    final firstText = _firstController.text.trim();
    final secondText = _secondController.text.trim();
    widget.callback(firstText, secondText);
  }

  @override
  void initState() {
    _firstController = TextEditingController();
    _secondController = TextEditingController();
    _thirdController = TextEditingController();
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
              Expanded(child: design.textMarquee('${'Change password:'}:')),
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
                      maxLength: 255,
                      minLines: 1,
                      keyboardType: TextInputType.text,
                      obscureText: true,
                      decoration: InputDecoration(labelText: "Old password..."),
                      validator: (value) {
                        return validateGeneric(value);
                      },
                    ),
                  ),
                  design.verticalGap(design.spacing / 2),
                  ColoredBox(
                    color: listTone,
                    child: TextFormField(
                      controller: _secondController,
                      maxLines: 1,
                      maxLength: 255,
                      minLines: 1,
                      keyboardType: TextInputType.text,
                      obscureText: true,
                      decoration: InputDecoration(labelText: "New password..."),
                      validator: (value) {
                        return validatePasswordWithConfirm(
                          value,
                          _thirdController.text,
                        );
                      },
                    ),
                  ),
                  design.verticalGap(design.spacing / 2),
                  ColoredBox(
                    color: listTone,
                    child: TextFormField(
                      controller: _thirdController,
                      maxLines: 1,
                      maxLength: 255,
                      minLines: 1,
                      keyboardType: TextInputType.text,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Confirm password...",
                      ),
                      validator: (value) {
                        return validatePasswordWithConfirm(
                          value,
                          _secondController.text,
                        );
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
