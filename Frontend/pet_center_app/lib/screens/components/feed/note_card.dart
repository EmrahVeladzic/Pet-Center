import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/note_sub_dto.dart';

import 'package:pet_center_app/utils/app_style.dart';

class NoteCard extends StatelessWidget {
  final NoteSubDTO note;
  final int noteKey;

  const NoteCard({super.key, required this.note, required this.noteKey});

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 0, vertical: 1),
      child: Container(
        decoration: design.panelDecoration(),

        child: ExpansionTile(
          key: PageStorageKey(noteKey),
          title: Text(note.title),
          children: [
            Container(
              color: panelTone,
              width: double.infinity,
              padding: EdgeInsets.all(design.spacing),
              child: Text(note.body),
            ),
          ],
        ),
      ),
    );
  }
}
