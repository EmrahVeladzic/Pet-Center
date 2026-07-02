import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/user/user_response_dto.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/utils/app_style.dart';

class SupplyRecordCard extends StatelessWidget {
  final SuppliesSubDTO supply;

  final VoidCallback deleteAction;

  const SupplyRecordCard({
    super.key,
    required this.supply,
    required this.deleteAction,
  });

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    final kind = kinds.where((k) => k.id == supply.kindId).firstOrNull;
    final cat = categories
        .where((c) => c.id == supply.consumableId)
        .firstOrNull;

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
                child: Text(
                  "Kind - ${kind?.title ?? "Animal"}\nCategory - ${cat?.title ?? "Category"}\nMass - ${supply.massGrams} grams",
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
                      tooltip: "Remove",
                      onPressed: deleteAction,
                      icon: const Icon(Icons.delete),
                      padding: EdgeInsets.zero,

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
