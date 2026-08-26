import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/listing/sub_dtos.dart';
import 'package:pet_center_app/services/listing_service.dart';
import 'package:pet_center_app/utils/tokens.dart';
import 'package:pet_center_app/utils/validators.dart';

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
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void sendReview() async {
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
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: Radii.mdAll,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _controller,
              maxLines: null,
              maxLength: 150,
              minLines: 3,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                hintText: 'Share your experience with this listing...',
                labelText: 'Your review',
                alignLabelWithHint: true,
              ),
              validator: (value) {
                return validateGeneric(value);
              },
            ),
            const SizedBox(height: Spacing.xs),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () {
                  if (_formKey.currentState != null &&
                      _formKey.currentState!.validate()) {
                    sendReview();
                  }
                },
                icon: const Icon(Icons.send, size: IconSizes.md),
                label: const Text('Post review'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
