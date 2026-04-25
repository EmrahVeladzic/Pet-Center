import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/listing/sub_dtos.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/services/static_data_service.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/jwt_parser.dart';

class CommentViewScreen extends StatefulWidget {
  final CommentResponseSubDTO comment;
  const CommentViewScreen({super.key, required this.comment});

  @override
  State<CommentViewScreen> createState() => _CommentViewScreenState();
}

class _CommentViewScreenState extends State<CommentViewScreen> {
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
          child: design.textMarquee(comment.posterName),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (role == Access.owner ||
                role == Access.admin ||
                comment.posterId == self?.id) ...[
              ElevatedButton(onPressed: () {}, child: Text('Delete')),
            ] else ...[
              ElevatedButton(onPressed: () {}, child: Text('Report')),
            ],
          ],
        ),
      ),
    );
  }
}
