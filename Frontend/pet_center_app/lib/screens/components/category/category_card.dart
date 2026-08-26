import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/category_dto.dart';
import 'package:pet_center_app/screens/components/category/usage_card.dart';
import 'package:pet_center_app/screens/components/category/usage_dialog.dart';
import 'package:pet_center_app/screens/components/confirmation_dialog.dart';
import 'package:pet_center_app/screens/components/entity_list_tile.dart';
import 'package:pet_center_app/screens/components/status_chip.dart';
import 'package:pet_center_app/screens/item_view.dart';
import 'package:pet_center_app/services/category_service.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/utils/tokens.dart';

class CategoryCard extends StatelessWidget {
  final CategoryDTO category;
  final VoidCallback editAction;
  final VoidCallback deleteAction;
  final VoidCallback rebuildCallback;

  const CategoryCard({
    super.key,
    required this.category,
    required this.editAction,
    required this.deleteAction,
    required this.rebuildCallback,
  });

  void removeUsage(String id) async {
    final output = await CategoryService.removeUsageEstimate(id);

    if (output == true) {
      category.usageSpecifics?.removeWhere((s) => s.id == id);
      rebuildCallback();
    }
  }

  void openUsageDialog(BuildContext context, [UsageSubDTO? current]) {
    if (category.id == null || kinds.isEmpty) {
      return;
    }
    showDialog(
      context: context,
      builder: (_) => UsageCreationDialog(
        categoryId: category.id!,
        fromCurrent: current,
        callback: (value) {
          category.usageSpecifics?.removeWhere(
            (u) => u.id == (current?.id ?? value.id),
          );
          category.usageSpecifics?.add(value);
          rebuildCallback();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usages =
        category.usageSpecifics?.whereType<UsageSubDTO>().toList() ?? [];

    final actions = <EntityAction>[
      EntityAction(
        icon: Icons.view_list_outlined,
        tooltip: 'View items',
        onPressed: category.id == null
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ItemView(categoryId: category.id!),
                  ),
                );
              },
      ),
      if (category.consumable)
        EntityAction(
          icon: Icons.note_add_outlined,
          tooltip: 'Set usage estimate',
          onPressed: kinds.isEmpty ? null : () => openUsageDialog(context),
        ),
      EntityAction(
        icon: Icons.edit_outlined,
        tooltip: 'Edit category',
        onPressed: editAction,
      ),
      EntityAction(
        icon: Icons.delete_outline,
        tooltip: 'Delete category',
        onPressed: deleteAction,
        destructive: true,
      ),
    ];

    return EntityListTile(
      icon: Icons.category_outlined,
      title: category.title.isEmpty ? 'Untitled category' : category.title,
      subtitle: usages.isEmpty
          ? null
          : (usages.length == 1
                ? '1 usage estimate'
                : '${usages.length} usage estimates'),
      chips: [
        StatusChip(
          label: category.consumable ? 'Consumable' : 'Non-consumable',
          tone: StatusTone.neutral,
          showDot: false,
        ),
      ],
      expanded: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ResponsiveActionBar(actions: actions),
          if (usages.isNotEmpty) ...[
            const SizedBox(height: Spacing.xs),
            Theme(
              data: theme.copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text(
                  'Usage specifics',
                  style: theme.textTheme.titleSmall,
                ),
                children: [
                  for (final e in usages) ...[
                    UsageCard(
                      usage: e,
                      editAction: () => openUsageDialog(context, e),
                      deleteAction: () {
                        showDialog<bool>(
                          context: context,
                          builder: (_) => ConfirmationDialog(
                            title: 'Remove this usage estimate?',
                            body:
                                'The estimate will no longer apply to this category.',
                            consequence: 'This cannot be undone.',
                            confirmLabel: 'Remove',
                            destructive: true,
                            confirmAction: () {
                              final id = e.id;
                              if (id != null) {
                                removeUsage(id);
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
