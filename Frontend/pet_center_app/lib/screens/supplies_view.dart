import 'package:flutter/material.dart';
import 'package:pet_center_app/screens/components/confirmation_dialog.dart';
import 'package:pet_center_app/screens/components/items/supply_record_card.dart';
import 'package:pet_center_app/screens/components/items/supply_record_dialog.dart';

import 'package:pet_center_app/screens/templates/screen_scaffold.dart';
import 'package:pet_center_app/screens/wishlist_view.dart';
import 'package:pet_center_app/services/category_service.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';

import 'package:pet_center_app/utils/app_style.dart';

class SuppliesViewScreen extends StatefulWidget {
  const SuppliesViewScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SuppliesViewScreenState();
}

class _SuppliesViewScreenState extends State<SuppliesViewScreen> {
  @override
  void initState() {
    super.initState();
  }

  void removeSupplies(String id) async {
    final output = await CategoryService.stopTracking(id);

    if (mounted && output == true) {
      setState(() {
        self?.userSupplies?.removeWhere((i) => i.id == id);
      });
    }
  }

  void setSupplies(String cat, String kind, int mass) async {
    final output = await CategoryService.trackSupplies(cat, kind, mass);

    if (output != null && mounted) {
      setState(() {
        self?.userSupplies?.removeWhere((i) => i.id == output.id);
        self?.userSupplies?.add(output);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    return BasicScreenScaffold(
      center: false,
      appBar: AppBar(
        title: SizedBox(
          width: design.screenWidth * marqueeTitleWMult,
          height: design.marqueeSize,
          child: design.textMarquee(
            'Supplies:',
            design.screenWidth * marqueeTitleWMult,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),

            onPressed: () {
              if (!mounted ||
                  kinds.isEmpty ||
                  categories.where((c) => c.consumable).isEmpty) {
                return;
              }

              showDialog(
                context: context,
                builder: (_) => SupplyRecordDialog(callback: setSupplies),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.view_list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => WishlistViewScreen()),
              );
            },
          ),
        ],
      ),
      body: [
        ...(self?.userSupplies ?? []).expand(
          (e) => [
            SupplyRecordCard(
              supply: e,
              deleteAction: () {
                showDialog(
                  context: context,
                  builder: (_) => ConfirmationDialog(
                    confirmAction: () {
                      final id = e.id;
                      if (id == null) {
                        return;
                      }
                      removeSupplies(id);
                    },
                  ),
                );
              },
            ),

            design.verticalGap(1),
          ],
        ),
      ],
    );
  }
}
