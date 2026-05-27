import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/item_dto.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/utils/app_style.dart';

class ItemCard extends StatelessWidget {
  final ItemDTO item;
  final VoidCallback editAction;
  final VoidCallback deleteAction;

  const ItemCard({
    super.key,
    required this.item,
    required this.editAction,
    required this.deleteAction,
  });

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 0, vertical: 1),
      child: Container(
        color: listTone,
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Padding(
                padding: EdgeInsets.all(design.spacing),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Flexible(
                      fit: FlexFit.loose,
                      child: design.fittedText(item.title, 2.0),
                    ),
                    Flexible(
                      fit: FlexFit.loose,
                      child: design.fittedText(
                        "${kinds.where((k) => k.id == item.kindId).firstOrNull?.title ?? "Animal"}${item.scale != null ? " - ${item.scale?.displayName}" : ""}",
                      ),
                    ),
                    if (item.mass != null) ...[
                      Flexible(
                        fit: FlexFit.loose,
                        child: design.fittedText("${item.mass}g"),
                      ),
                    ],
                  ],
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
    );
  }
}
