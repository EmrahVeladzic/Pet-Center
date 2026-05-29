import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/form_template_dto.dart';
import 'package:pet_center_app/services/form_template_service.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/validators.dart';

class FormTemplateFieldDialog extends StatefulWidget {
  final FormTemplateFieldDTO? fromCurrent;
  final String formTemplateId;
  final void Function(FormTemplateFieldDTO value) callback;

  const FormTemplateFieldDialog({
    super.key,
    required this.callback,
    required this.formTemplateId,
    this.fromCurrent,
  });

  @override
  State<StatefulWidget> createState() => _FormTemplateFieldDialogState();
}

class _FormTemplateFieldDialogState extends State<FormTemplateFieldDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  late final FormTemplateFieldDTO data;

  void invokeCallback() async {
    data.description = _descriptionController.text;

    final output = await FormTemplateService.setField(data);

    if (output != null) {
      widget.callback(output);
    }
  }

  @override
  void initState() {
    super.initState();
    data =
        widget.fromCurrent?.copy() ??
        FormTemplateFieldDTO(formTemplateId: widget.formTemplateId);
    _descriptionController.text = data.description;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
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
              Expanded(child: design.textMarquee('Enter:')),
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
                      controller: _descriptionController,
                      maxLines: 1,
                      maxLength: 75,
                      minLines: 1,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Description...",
                      ),
                      validator: (value) => validateGeneric(value),
                    ),
                  ),
                  SizedBox(height: design.spacing),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: data.optional,
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            data.optional = value;
                          });
                        },
                      ),
                      design.fittedText('Optional'),
                    ],
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
