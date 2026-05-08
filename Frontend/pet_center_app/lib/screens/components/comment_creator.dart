import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/listing/sub_dtos.dart';
import 'package:pet_center_app/services/listing_service.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/globals.dart';

class CommentCreator extends StatefulWidget {
  final String listingId;
  final void Function(CommentResponseSubDTO feedback) onPost;

  const CommentCreator({
    super.key,
    required this.listingId,
    required this.onPost,
  });

  @override
  State<CommentCreator> createState() => _CommentCreatorState();
}

class _CommentCreatorState extends State<CommentCreator> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void sendReview() async {
    if (apiServiceBusy) {
      return;
    }
    final String text = _controller.text.trim();
    if (text.isEmpty) return;

    final output = await ListingService.sendReview(widget.listingId, text);

    if (output != null) {
      widget.onPost(output);
    }

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 0, vertical: 1),
      child: Container(
        padding: EdgeInsets.all(design.spacing),
        decoration: design.panelDecoration(),
        child: Row(
          children: [
            Expanded(
              flex: 4,

              child: ColoredBox(
                color: listTone,
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  maxLength: 150,
                  minLines: 3,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(hintText: 'Write a review...'),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.center,
                child: IconButton(
                  onPressed: sendReview,
                  icon: const Icon(Icons.arrow_forward),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
