import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/item_dto.dart';
import 'package:pet_center_app/screens/components/confirmation_dialog.dart';
import 'package:pet_center_app/screens/components/category/item_card.dart';
import 'package:pet_center_app/screens/components/category/item_creation_dialog.dart';
import 'package:pet_center_app/screens/templates/screen_scaffold.dart';
import 'package:pet_center_app/services/item_service.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/utils/app_style.dart';

class ItemView extends StatefulWidget {
  final String categoryId;

  const ItemView({super.key, required this.categoryId});

  @override
  State<StatefulWidget> createState() => _ItemViewState();
}

class _ItemViewState extends State<ItemView> {
  List<ItemDTO> src = [];

  void load() {
    setState(() {
      src = items.where((i) => i.categoryId == widget.categoryId).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  void post(ItemDTO dto) async {
    final output = await ItemService.post(dto);
    if (output != null && mounted) {
      items.add(output);
      load();
    }
  }

  void edit(ItemDTO dto, String id) async {
    final output = await ItemService.put(dto, id);
    if (output != null && mounted) {
      setState(() {
        items.removeWhere((i) => i.id == id);
        items.add(output);
        load();
      });
    }
  }

  void delete(String id) async {
    final output = await ItemService.delete(id);
    if (output == true && mounted) {
      setState(() {
        items.removeWhere((i) => i.id == id);
        load();
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
            'Items:',
            design.screenWidth * marqueeTitleWMult,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => ItemCreationDialog(
                  categoryId: widget.categoryId,
                  callback: post,
                ),
              );
            },
            icon: const Icon(Icons.add),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
      body: [
        ...src.expand(
          (e) => [
            ItemCard(
              item: e,
              editAction: () {
                showDialog(
                  context: context,
                  builder: (_) => ItemCreationDialog(
                    categoryId: widget.categoryId,
                    fromCurrent: e,
                    callback: (value) {
                      if (e.id == null) return;
                      edit(value, e.id!);
                    },
                  ),
                );
              },
              deleteAction: () {
                showDialog(
                  context: context,
                  builder: (_) => ConfirmationDialog(
                    confirmAction: () {
                      final id = e.id;
                      if (id != null) {
                        delete(id);
                      }
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
