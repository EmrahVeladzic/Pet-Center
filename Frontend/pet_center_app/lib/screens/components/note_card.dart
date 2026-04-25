import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/note_sub_dto.dart';
import 'package:pet_center_app/utils/app_style.dart';

class NoteCard extends StatelessWidget {
  final NoteSubDTO note;

  const NoteCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 0, vertical: 1),

      child: Column(
        children: [
          Container(
            decoration: design.panelDecoration(),
            child: design.textMarquee(
              note.title,
              design.screenWidth * design.bodyWMult,
              marqueeNoteWMult,
            ),
          ),
          Container(
            color: visitedPanelTone,
            child: design.textMarquee(
              note.body,
              design.screenWidth * design.bodyWMult,
              marqueeNoteWMult,
            ),
          ),
        ],
      ),
    );
  }
}
