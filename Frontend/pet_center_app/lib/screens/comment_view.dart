import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/listing/sub_dtos.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/components/deletion_dialog.dart';
import 'package:pet_center_app/screens/components/listing/report_dialog.dart';
import 'package:pet_center_app/services/account_service.dart';
import 'package:pet_center_app/services/listing_service.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';

import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/helpers.dart';
import 'package:pet_center_app/utils/jwt_parser.dart';

class CommentViewScreen extends StatefulWidget {
  final CommentResponseSubDTO comment;
  final VoidCallback onDelete;
  const CommentViewScreen({
    super.key,
    required this.comment,
    required this.onDelete,
  });

  @override
  State<CommentViewScreen> createState() => _CommentViewScreenState();
}

class _CommentViewScreenState extends State<CommentViewScreen> {
  void deleteComment(bool ban) async {
    if (widget.comment.id != null) {
      final bool deleted = (ban)
          ? await AccountService.delete(widget.comment.posterId)
          : await ListingService.deleteReview(widget.comment.id!);

      if (!mounted) {
        return;
      }

      if (deleted) {
        widget.onDelete();
        Navigator.pop(context);
      }
    }
  }

  void reportComment() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    Access role = userToken?.role ?? Access.user;

    final comment = widget.comment;

    return Scaffold(
      backgroundColor: mainTone,
      appBar: AppBar(
        leading: BackButton(),
        title: SizedBox(
          width: design.screenWidth * marqueeTitleWMult,
          height: design.marqueeSize,
          child: design.textMarquee(
            "${comment.posterName} - ${formatDate(comment.lastEditDate)}",
            design.screenWidth * marqueeTitleWMult,
          ),
        ),
      ),
      body: Center(
        child: FractionallySizedBox(
          widthFactor: design.bodyWMult,
          heightFactor: 1.0,
          child: ColoredBox(
            color: panelTone,
            child: Padding(
              padding: EdgeInsetsGeometry.all(design.spacing),
              child: Text(comment.contents),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: FittedBox(
          fit: BoxFit.scaleDown,

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (role == Access.owner ||
                  role == Access.admin ||
                  comment.posterId == self?.id) ...[
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => DeletionDialog(
                        deletionAction: (ban) {
                          deleteComment(ban);
                        },
                        bannable: true,
                        itemName: 'comment',
                      ),
                    );
                  },
                  child: design.fittedText('Delete'),
                ),
              ] else ...[
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => ReportDialog(
                        reportAction: reportComment,
                        listingId: widget.comment.listingId,
                        commentId: widget.comment.id,
                      ),
                    );
                  },
                  child: design.fittedText('Report'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
