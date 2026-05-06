import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/listing/sub_dtos.dart';
import 'package:pet_center_app/utils/app_style.dart';

class CommentCard extends StatelessWidget {
  final CommentResponseSubDTO comment;
  final VoidCallback onTap;

  const CommentCard({super.key, required this.comment, required this.onTap});

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
              child: Text('"${comment.contents}" - ${comment.posterName}'),
            ),
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.center,
                child: IconButton(
                  onPressed: onTap,
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
