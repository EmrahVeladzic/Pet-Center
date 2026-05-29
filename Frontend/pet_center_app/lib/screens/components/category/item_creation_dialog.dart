import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/item_dto.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/components/dropdown_menus.dart';

import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/validators.dart';

class ItemCreationDialog extends StatefulWidget {
  final ItemDTO? fromCurrent;
  final String categoryId;
  final void Function(ItemDTO value) callback;

  const ItemCreationDialog({
    super.key,
    required this.callback,
    required this.categoryId,
    this.fromCurrent,
  });

  @override
  State<StatefulWidget> createState() => _ItemCreationDialogState();
}

class _ItemCreationDialogState extends State<ItemCreationDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _massController = TextEditingController();
  late final ItemDTO data;

  void invokeCallback() async {
    data.title = _titleController.text;
    data.mass = int.tryParse(_massController.text);

    widget.callback(data);
  }

  @override
  void initState() {
    super.initState();
    data = widget.fromCurrent?.copy() ?? ItemDTO(categoryId: widget.categoryId);

    if (widget.fromCurrent == null) {
      data.kindId = kinds.first.id!;
    }

    _titleController.text = data.title;
    _massController.text = data.mass == null ? '' : data.mass.toString();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _massController.dispose();
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
                      controller: _titleController,
                      maxLines: 1,
                      maxLength: 75,
                      minLines: 1,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(labelText: "Title..."),
                      validator: (value) => validateGeneric(value),
                    ),
                  ),
                  design.verticalGap(design.spacing),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      kindWidget(design.dialogWidth, kinds, (value) {
                        if (mounted && value != null) {
                          setState(() {
                            data.kindId = value.id!;
                          });
                        }
                      }),
                    ],
                  ),
                  design.verticalGap(design.spacing),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: data.scale != null,
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            data.scale = value
                                ? AnimalScale.values.first
                                : null;
                          });
                        },
                      ),
                      design.fittedText('Scale specific'),
                    ],
                  ),
                  if (data.scale != null) ...[
                    design.verticalGap(design.spacing),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        scaleWidget(
                          design.dialogWidth,
                          data.scale ?? AnimalScale.medium,
                          (value) {
                            setState(() {
                              data.scale = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                  design.verticalGap(design.spacing),
                  ColoredBox(
                    color: listTone,
                    child: TextFormField(
                      controller: _massController,
                      maxLines: 1,
                      minLines: 1,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Mass (g)...",
                      ),
                      validator: (value) =>
                          validateNumericInRange(value, 1, 100000),
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
