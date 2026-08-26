import 'package:flutter/material.dart';
import 'package:pet_center_app/screens/components/app_dialog.dart';
import 'package:pet_center_app/screens/components/dropdown_menus.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/validators.dart';

class SupplyRecordDialog extends StatefulWidget {
  final void Function(String categoryId, String kindId, int mass) callback;

  const SupplyRecordDialog({super.key, required this.callback});

  @override
  State<StatefulWidget> createState() => _SupplyRecordDialogState();
}

class _SupplyRecordDialogState extends State<SupplyRecordDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _massController = TextEditingController();

  late String _selectedKindId;
  late String _selectedCategoryId;

  final _consumables = categories.where((c) => c.consumable).toList();

  @override
  void initState() {
    super.initState();
    _selectedKindId = kinds.first.id!;
    _selectedCategoryId = _consumables.first.id!;
  }

  @override
  void dispose() {
    _massController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    return Form(
      key: _formKey,
      child: ScrollableAlertDialog(
        scrollable: true,
        title: Row(
          children: [
            Expanded(child: design.textMarquee('Set supplies:')),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        content: SizedBox(
          width: design.dialogWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              kindWidget(design.dialogWidth, kinds, (value) {
                if (mounted && value != null) {
                  setState(() {
                    _selectedKindId = value.id!;
                  });
                }
              }),
              design.verticalGap(design.spacing),

              categoryWidget(
                design.dialogWidth,
                categories.where((c) => c.consumable).toList(),
                (value) {
                  if (mounted && value != null) {
                    setState(() {
                      _selectedCategoryId = value.id!;
                    });
                  }
                },
              ),

              design.verticalGap(design.spacing),
              TextFormField(
                controller: _massController,
                maxLines: 1,
                minLines: 1,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Mass (g)..."),
                validator: (value) => validateNumericInRange(value, 0, 10000),
              ),
            ],
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState != null &&
                  _formKey.currentState!.validate()) {
                Navigator.of(context).pop();

                widget.callback(
                  _selectedCategoryId,
                  _selectedKindId,
                  int.parse(_massController.text),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
