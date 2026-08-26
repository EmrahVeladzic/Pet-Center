import 'package:flutter/material.dart';
import 'package:pet_center_app/screens/components/entity_list_tile.dart';

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
    return EntityListTile(
      icon: Icons.bookmark_outline,
      title: term.isEmpty ? 'Empty term' : term,
      actions: [
        EntityAction(
          icon: Icons.delete_outline,
          tooltip: 'Remove term',
          onPressed: deleteAction,
          destructive: true,
        ),
      ],
    );
  }
}
