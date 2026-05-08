import 'package:flutter/material.dart';

import 'package:pet_center_app/services/listing_service.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/globals.dart';

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

  void sendReport() async {
    final output = await ListingService.reportMisuse(
      widget.listingId,
      _controller.text.trim(),
      widget.commentId,
    );
    if (output != null) {
      showSnackbar("Report submitted.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    return FittedBox(
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
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    maxLength: 255,
                    minLines: dialogMinLines,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(hintText: 'Reason:'),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (apiServiceBusy) {
                return;
              }
              Navigator.of(context).pop();
              sendReport();
              widget.reportAction();
            },
            child: design.textMarquee('Send report'),
          ),
        ],
      ),
    );
  }
}
