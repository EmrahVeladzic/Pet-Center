import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/form_template_dto.dart';
import 'package:pet_center_app/screens/components/confirmation_dialog.dart';
import 'package:pet_center_app/screens/components/entity_list_tile.dart';
import 'package:pet_center_app/screens/components/form_template/form_template_field_card.dart';
import 'package:pet_center_app/screens/components/form_template/form_template_field_dialog.dart';
import 'package:pet_center_app/screens/components/status_chip.dart';
import 'package:pet_center_app/services/form_template_service.dart';
import 'package:pet_center_app/utils/tokens.dart';

class FormTemplateCard extends StatelessWidget {
  final FormTemplateDTO template;
  final VoidCallback editAction;
  final VoidCallback deleteAction;
  final VoidCallback rebuildCallback;

  const FormTemplateCard({
    super.key,
    required this.template,
    required this.editAction,
    required this.deleteAction,
    required this.rebuildCallback,
  });

  void removeField(String id) async {
    final output = await FormTemplateService.deleteField(id);
    if (output == true) {
      template.fields.removeWhere((f) => f.id == id);
      rebuildCallback();
    }
  }

  void openFieldDialog(BuildContext context, [FormTemplateFieldDTO? current]) {
    if (template.id == null) {
      return;
    }
    showDialog(
      context: context,
      builder: (_) => FormTemplateFieldDialog(
        formTemplateId: template.id!,
        fromCurrent: current,
        callback: (value) {
          template.fields.removeWhere((f) => f.id == (current?.id ?? value.id));
          template.fields.add(value);
          rebuildCallback();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fields = template.fields;

    final actions = <EntityAction>[
      EntityAction(
        icon: Icons.playlist_add,
        tooltip: 'Add field',
        onPressed: template.id == null ? null : () => openFieldDialog(context),
      ),
      EntityAction(
        icon: Icons.edit_outlined,
        tooltip: 'Edit template',
        onPressed: editAction,
      ),
      EntityAction(
        icon: Icons.delete_outline,
        tooltip: 'Delete template',
        onPressed: deleteAction,
        destructive: true,
      ),
    ];

    return EntityListTile(
      icon: Icons.assignment_outlined,
      title: template.description.isEmpty
          ? 'Untitled template'
          : template.description,
      subtitle: fields.isEmpty
          ? 'No fields defined yet'
          : (fields.length == 1 ? '1 field' : '${fields.length} fields'),
      chips: [
        if (fields.isEmpty)
          const StatusChip(label: 'Incomplete', tone: StatusTone.warning),
      ],
      expanded: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ResponsiveActionBar(actions: actions),
          if (fields.isNotEmpty) ...[
            const SizedBox(height: Spacing.xs),
            Theme(
              data: theme.copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text('Fields', style: theme.textTheme.titleSmall),
                children: [
                  for (final e in fields) ...[
                    FormTemplateFieldCard(
                      field: e,
                      editAction: () => openFieldDialog(context, e),
                      deleteAction: () {
                        showDialog<bool>(
                          context: context,
                          builder: (_) => ConfirmationDialog(
                            title: 'Remove this field?',
                            body:
                                'Forms built from this template will no longer ask for it.',
                            consequence: 'This cannot be undone.',
                            confirmLabel: 'Remove',
                            destructive: true,
                            confirmAction: () {
                              final id = e.id;
                              if (id != null) {
                                removeField(id);
                              }
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: Spacing.xs),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
