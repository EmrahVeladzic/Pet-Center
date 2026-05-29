import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/listing/sub_dtos.dart';
import 'package:pet_center_app/services/listing_service.dart';

import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/validators.dart';

class DiscountDialog extends StatefulWidget {
  final String listing;
  final void Function(DiscountResponseSubDTO) callback;

  const DiscountDialog({
    super.key,
    required this.callback,
    required this.listing,
  });

  @override
  State<StatefulWidget> createState() => _DiscountDialogState();
}

class _DiscountDialogState extends State<DiscountDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstController = TextEditingController();
  final TextEditingController _secondController = TextEditingController();
  void invokeCallback() async {
    final percent = int.parse(_firstController.text);
    final days = int.parse(_secondController.text);

    final output = await ListingService.setDiscount(
      widget.listing,
      percent,
      days,
    );

    if (output != null && mounted) {
      widget.callback(output);
    }
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
                      controller: _firstController,
                      maxLines: 1,
                      maxLength: 3,
                      minLines: 1,
                      keyboardType: TextInputType.number,

                      decoration: InputDecoration(labelText: "Percent..."),
                      validator: (value) {
                        return validateNumericInRange(value, 15, 100);
                      },
                    ),
                  ),
                  design.verticalGap(design.spacing / 2),
                  ColoredBox(
                    color: listTone,
                    child: TextFormField(
                      controller: _secondController,
                      maxLines: 1,
                      maxLength: 2,
                      minLines: 1,
                      keyboardType: TextInputType.number,

                      decoration: InputDecoration(labelText: 'Days valid...'),
                      validator: (value) {
                        return validateNumericInRange(value, 3, 45);
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
