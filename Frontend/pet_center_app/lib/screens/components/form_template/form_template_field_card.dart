import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/form_template_dto.dart';
import 'package:pet_center_app/screens/components/entity_list_tile.dart';
import 'package:pet_center_app/screens/components/status_chip.dart';

class FormTemplateFieldCard extends StatelessWidget {
  final FormTemplateFieldDTO field;
  final VoidCallback editAction;
  final VoidCallback deleteAction;

  const FormTemplateFieldCard({
    super.key,
    required this.field,
    required this.editAction,
    required this.deleteAction,
  });

  @override
  Widget build(BuildContext context) {
    return EntityListTile(
      icon: Icons.short_text,
      title: field.description.isEmpty ? 'Untitled field' : field.description,
      chips: [
        StatusChip(
          label: field.optional ? 'Optional' : 'Required',
          tone: field.optional ? StatusTone.neutral : StatusTone.warning,
          showDot: false,
        ),
      ],
      actions: [
        EntityAction(
          icon: Icons.edit_outlined,
          tooltip: 'Edit field',
          onPressed: editAction,
        ),
        EntityAction(
          icon: Icons.delete_outline,
          tooltip: 'Delete field',
          onPressed: deleteAction,
          destructive: true,
        ),
      ],
    );
  }
}
