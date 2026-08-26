import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/note_sub_dto.dart';
import 'package:pet_center_app/utils/tokens.dart';

class NoteCard extends StatelessWidget {
  final NoteSubDTO note;
  final int noteKey;

  const NoteCard({super.key, required this.note, required this.noteKey});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: Radii.mdAll,
        border: Border.all(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: PageStorageKey<int>(noteKey),
          leading: Icon(
            Icons.sticky_note_2_outlined,
            size: IconSizes.lg,
            color: scheme.onSurfaceVariant,
          ),
          title: Text(
            note.title.isEmpty ? 'Untitled note' : note.title,
            softWrap: true,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall,
          ),
          children: [
            Container(
              width: double.infinity,
              color: scheme.surfaceContainerLow,
              padding: const EdgeInsets.all(Spacing.md),
              child: Text(
                note.body.isEmpty ? 'This note is empty.' : note.body,
                softWrap: true,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
