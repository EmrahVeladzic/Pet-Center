import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/user/user_response_dto.dart';
import 'package:pet_center_app/services/user_service.dart';

import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/validators.dart';

class NotificationDialog extends StatefulWidget {
  final void Function(NotificationSubDTO? output) callback;

  final String userId;
  final String? listingId;
  final String? franchiseId;

  const NotificationDialog({
    super.key,
    required this.callback,
    required this.userId,
    this.franchiseId,
    this.listingId,
  });

  @override
  State<StatefulWidget> createState() => _NotificationDialogState();
}

class _NotificationDialogState extends State<NotificationDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  late final TextEditingController _daysController;
  void invokeCallback() async {
    final firstText = _titleController.text.trim();
    final secondText = _bodyController.text.trim();
    final days = int.tryParse(_daysController.text) ?? 1;

    final output = await UserService.addNotification(
      widget.userId,
      firstText,
      secondText,
      widget.franchiseId,
      widget.listingId,
      days,
    );

    if (output != null && mounted) {
      widget.callback(output);
    }
  }

  @override
  void initState() {
    _titleController = TextEditingController();
    _bodyController = TextEditingController();
    _daysController = TextEditingController(text: 1.toString());
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _daysController.dispose();
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
              Expanded(child: design.textMarquee("Add notification")),
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
                      controller: _titleController,
                      maxLines: 1,
                      maxLength: 75,
                      minLines: 1,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(labelText: "Title..."),
                      validator: (value) => validateGeneric(value),
                    ),
                  ),
                  design.verticalGap(design.spacing / 2),
                  ColoredBox(
                    color: listTone,
                    child: TextFormField(
                      controller: _bodyController,
                      maxLines: 1,
                      maxLength: 255,
                      minLines: 1,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(labelText: "Body..."),
                      validator: (value) => validateGeneric(value),
                    ),
                  ),
                  design.verticalGap(design.spacing / 2),
                  ColoredBox(
                    color: listTone,
                    child: TextFormField(
                      controller: _daysController,
                      maxLines: 1,
                      maxLength: 1,
                      minLines: 1,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Valid for (days)...",
                      ),
                      validator: (value) => validateNumericInRange(value, 1, 7),
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
