import 'package:flutter/material.dart';
import 'package:pet_center_app/screens/components/text_entry_dialog.dart';
import 'package:pet_center_app/screens/components/user/wishlist_term_card.dart';
import 'package:pet_center_app/screens/templates/screen_scaffold.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/services/user_service.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/validators.dart';

class WishlistViewScreen extends StatefulWidget {
  const WishlistViewScreen({super.key});

  @override
  State<StatefulWidget> createState() => _WishlistViewScreenState();
}

class _WishlistViewScreenState extends State<WishlistViewScreen> {
  void addTerm(String term) async {
    final output = await UserService.setWishlistTerm(term);
    if (output != null && mounted) {
      setState(() {
        self?.userWishlist?.removeWhere((t) => t == term);
        self?.userWishlist?.add(term);
      });
      showSnackbar(output);
    }
  }

  void removeTerm(String term) async {
    final output = await UserService.removeWishlistTerm(term);
    if (output == true && mounted) {
      setState(() {
        self?.userWishlist?.removeWhere((t) => t == term);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    return BasicScreenScaffold(
      appBar: AppBar(
        title: SizedBox(
          width: design.screenWidth * marqueeTitleWMult,
          height: design.marqueeSize,
          child: design.textMarquee(
            'Wishlist:',
            design.screenWidth * marqueeTitleWMult,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => TextEntryDialog(
                  limit: 75,
                  inputDecoration: "Term...",
                  validation: (value) => validateGeneric(value),
                  callback: addTerm,
                ),
              );
            },
          ),
        ],
      ),
      body: [
        ...(self?.userWishlist ?? []).expand(
          (e) => [
            WishlistTermCard(term: e, deleteAction: () => removeTerm(e)),
            design.verticalGap(1),
          ],
        ),
      ],
    );
  }
}
