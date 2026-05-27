import 'package:flutter/material.dart';
import 'package:pet_center_app/utils/app_style.dart';

class WishlistTermCard extends StatelessWidget {
  final String term;
  final VoidCallback deleteAction;

  const WishlistTermCard({
    super.key,
    required this.term,
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
                child: design.fittedText(term),
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
