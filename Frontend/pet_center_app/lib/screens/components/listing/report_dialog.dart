import 'package:flutter/material.dart';

import 'package:pet_center_app/services/listing_service.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/globals.dart';
import 'package:pet_center_app/utils/validators.dart';

class ReportDialog extends StatefulWidget {
  final String listingId;
  final VoidCallback reportAction;
  final String? commentId;
  const ReportDialog({
    super.key,
    required this.reportAction,
    required this.listingId,
    this.commentId,
  });

  @override
  State<StatefulWidget> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void sendReport() async {
    final output = await ListingService.reportMisuse(
      widget.listingId,
      _controller.text.trim(),
      widget.commentId,
    );
    if (output != null) {
      showSnackbar("Report submitted.");
    }
    if (mounted) {
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
        child: AlertDialog(
          title: Row(
            children: [
              Expanded(
                child: design.textMarquee(
                  'Report ${(widget.commentId != null) ? 'comment' : 'listing'}:',
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
                      maxLines: null,
                      maxLength: 255,
                      minLines: dialogMinLines,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(hintText: 'Reason:'),
                      validator: (value) {
                        return validateGeneric(value);
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

                  sendReport();
                  widget.reportAction();
                }
              },
              child: design.textMarquee('Send report'),
            ),
          ],
        ),
      ),
    );
  }
}
