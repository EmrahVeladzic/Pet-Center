import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/category_dto.dart';
import 'package:pet_center_app/screens/components/category/usage_dialog.dart';
import 'package:pet_center_app/screens/components/confirmation_dialog.dart';
import 'package:pet_center_app/screens/components/category/usage_card.dart';
import 'package:pet_center_app/screens/item_view.dart';
import 'package:pet_center_app/services/category_service.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/utils/app_style.dart';

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

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    final usages =
        category.usageSpecifics?.whereType<UsageSubDTO>().toList() ?? [];

    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 0, vertical: 1),
      child: Container(
        decoration: design.panelDecoration(),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(design.spacing),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Flexible(
                          fit: FlexFit.loose,
                          child: design.fittedText(category.title, 2.0),
                        ),
                        Flexible(
                          fit: FlexFit.loose,
                          child: design.fittedText(
                            category.consumable
                                ? "Consumable"
                                : "Non-consumable",
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: design.boundedIconSize,
                        height: design.boundedIconSize,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: IconButton(
                            onPressed: editAction,
                            icon: const Icon(Icons.edit),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: design.boundedIconSize,
                        height: design.boundedIconSize,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: IconButton(
                            onPressed: () {
                              if (category.id == null) {
                                return;
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ItemView(categoryId: category.id!),
                                ),
                              );
                            },
                            icon: const Icon(Icons.view_list),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (category.consumable) ...[
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: design.boundedIconSize,
                          height: design.boundedIconSize,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: IconButton(
                              onPressed: () {
                                if (kinds.isEmpty) {
                                  return;
                                }
                                showDialog(
                                  context: context,
                                  builder: (_) => UsageCreationDialog(
                                    callback: (value) {
                                      category.usageSpecifics?.removeWhere(
                                        (u) => u.id == value.id,
                                      );

                                      category.usageSpecifics?.add(value);
                                      rebuildCallback();
                                    },
                                    categoryId: category.id!,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.note_add),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              constraints: const BoxConstraints(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: design.boundedIconSize,
                        height: design.boundedIconSize,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: IconButton(
                            onPressed: deleteAction,
                            icon: const Icon(Icons.delete),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (usages.isNotEmpty) ...[
              ExpansionTile(
                title: const Text("Usage specifics"),
                children: usages
                    .expand(
                      (e) => [
                        UsageCard(
                          usage: e,

                          editAction: () {
                            if (category.id == null || kinds.isEmpty) {
                              return;
                            }
                            showDialog(
                              context: context,
                              builder: (_) => UsageCreationDialog(
                                callback: (value) {
                                  category.usageSpecifics?.removeWhere(
                                    (u) => u.id == e.id,
                                  );
                                  category.usageSpecifics?.add(value);
                                  rebuildCallback();
                                },
                                categoryId: category.id!,
                                fromCurrent: e,
                              ),
                            );
                          },
                          deleteAction: () {
                            showDialog(
                              context: context,
                              builder: (_) => ConfirmationDialog(
                                title: "Remove usage",
                                body:
                                    "Are you sure you wish to remove this usage entry?",
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
                        design.verticalGap(1),
                      ],
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
