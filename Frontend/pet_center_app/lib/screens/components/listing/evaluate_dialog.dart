import 'package:flutter/material.dart';

import 'package:pet_center_app/screens/components/app_dialog.dart';
import 'package:pet_center_app/services/listing_service.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/validators.dart';

class EvaluateDialog extends StatefulWidget {
  final String listingId;
  final void Function(bool eval) evaluateCallback;

  const EvaluateDialog({
    super.key,
    required this.listingId,
    required this.evaluateCallback,
  });

  @override
  State<StatefulWidget> createState() => _EvaluateDialogState();
}

class _EvaluateDialogState extends State<EvaluateDialog> {
  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool approved = false;

  void sendEvaluation() async {
    final output = await ListingService.evaluate(
      widget.listingId,
      approved,
      _controller.text.trim(),
    );
    if (output == true && mounted) {
      showSnackbar("Listing evaluated.");
      widget.evaluateCallback(approved);
      Navigator.of(context).pop();
    }
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

    return Form(
      key: _formKey,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: ScrollableAlertDialog(
          scrollable: true,
          title: Row(
            children: [
              Expanded(child: design.textMarquee('Evaluate listing:')),
              IconButton(
                tooltip: "Close",
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
                TextFormField(
                  controller: _controller,
                  maxLines: null,
                  maxLength: 150,
                  minLines: dialogMinLines,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(hintText: 'Note:'),
                  validator: (value) {
                    return validateGeneric(value);
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: approved,
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() {
                          approved = value;
                        });
                      },
                    ),
                    Flexible(child: design.fittedText('Approved')),
                  ],
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
                  sendEvaluation();
                }
              },
              child: design.textMarquee('Send evaluation'),
            ),
          ],
        ),
      ),
    );
  }
}
