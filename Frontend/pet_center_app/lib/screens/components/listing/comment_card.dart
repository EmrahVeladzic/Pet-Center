import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/listing/sub_dtos.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/components/listing/deletion_dialog.dart';
import 'package:pet_center_app/screens/components/listing/report_dialog.dart';
import 'package:pet_center_app/services/account_service.dart';
import 'package:pet_center_app/services/listing_service.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/helpers.dart';
import 'package:pet_center_app/utils/jwt_parser.dart';

class CommentCard extends StatelessWidget {
  final CommentResponseSubDTO comment;

  final VoidCallback onDelete;

  const CommentCard({super.key, required this.comment, required this.onDelete});

  void deleteComment(bool ban) async {
    if (comment.id != null) {
      final bool deleted = (ban)
          ? await AccountService.delete(comment.posterId)
          : await ListingService.deleteReview(comment.id!);

      if (deleted) {
        onDelete();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;
    final role = userToken?.role ?? Access.user;

    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 0, vertical: 1),
      child: Container(
        padding: EdgeInsets.all(design.spacing),
        decoration: design.panelDecoration(),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Text(
                "\"${comment.contents}\" - ${comment.posterName}, ${formatDate(comment.lastEditDate)}",
              ),
            ),
            if (comment.posterId == self?.id ||
                (role == Access.admin || role == Access.owner)) ...[
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.center,
                  child: IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => DeletionDialog(
                          deletionAction: (ban) {
                            deleteComment(ban);
                          },
                          bannable:
                              (role == Access.admin || role == Access.owner),
                          itemName: 'comment',
                        ),
                      );
                    },
                    icon: const Icon(Icons.delete),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
            ] else ...[
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.center,
                  child: IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => ReportDialog(
                          commentId: comment.id,
                          listingId: comment.listingId,
                        ),
                      );
                    },
                    icon: const Icon(Icons.report),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
