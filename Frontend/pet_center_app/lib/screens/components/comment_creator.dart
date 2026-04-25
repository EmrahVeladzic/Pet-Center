import 'package:flutter/material.dart';
import 'package:pet_center_app/services/listing_service.dart';
import 'package:pet_center_app/utils/app_style.dart';

class CommentCreator extends StatefulWidget {
  final String listingId;
  const CommentCreator({super.key, required this.listingId});

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

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    void sendReview() async {
      final String text = _controller.text.trim();
      if (text.isEmpty) return;

      await ListingService.sendReview(widget.listingId, text);

      _controller.clear();
    }

    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 0, vertical: 1),
      child: Container(
        padding: EdgeInsets.all(design.spacing),
        decoration: design.panelDecoration(),
        child: Row(
          children: [
            Expanded(
              flex: 3,

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
              child: Padding(
                padding: EdgeInsetsGeometry.symmetric(
                  horizontal: design.spacing,
                ),
                child: ElevatedButton(
                  onPressed: sendReview,
                  child: Icon(Icons.arrow_forward),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
