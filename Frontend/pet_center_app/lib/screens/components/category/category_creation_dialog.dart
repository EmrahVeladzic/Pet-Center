import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/category_dto.dart';

import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/validators.dart';

class CategoryCreationDialog extends StatefulWidget {
  final CategoryDTO? fromCurrent;

  final void Function(CategoryDTO value) callback;

  const CategoryCreationDialog({
    super.key,
    required this.callback,
    this.fromCurrent,
  });

  @override
  State<StatefulWidget> createState() => _CategoryCreationDialogState();
}

class _CategoryCreationDialogState extends State<CategoryCreationDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();
  late final CategoryDTO data;

  void invokeCallback() async {
    data.title = _controller.text;
    widget.callback(data);
  }

  @override
  void initState() {
    super.initState();
    data = widget.fromCurrent?.copy() ?? CategoryDTO();
    _controller.text = data.title;
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
                      controller: _controller,
                      maxLines: 1,
                      maxLength: 75,
                      minLines: 1,
                      keyboardType: TextInputType.text,

                      decoration: InputDecoration(labelText: "Title..."),
                      validator: (value) {
                        return validateGeneric(value);
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: data.consumable,
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            data.consumable = value;
                          });
                        },
                      ),
                      design.fittedText('Consumable'),
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
