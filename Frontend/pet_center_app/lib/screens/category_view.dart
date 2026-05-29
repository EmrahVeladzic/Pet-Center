import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/category_dto.dart';

import 'package:pet_center_app/screens/components/category/category_card.dart';
import 'package:pet_center_app/screens/components/category/category_creation_dialog.dart';
import 'package:pet_center_app/screens/components/confirmation_dialog.dart';

import 'package:pet_center_app/screens/templates/screen_scaffold.dart';
import 'package:pet_center_app/services/category_service.dart';

import 'package:pet_center_app/services/static_user_data_service.dart';

import 'package:pet_center_app/utils/app_style.dart';

class CategoryView extends StatefulWidget {
  const CategoryView({super.key});

  @override
  State<StatefulWidget> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {
  void post(CategoryDTO dto) async {
    final newCat = await CategoryService.post(dto);

    if (newCat != null && mounted) {
      setState(() {
        categories.add(newCat);
      });
    }
  }

  void edit(CategoryDTO dto, String id) async {
    final newCat = await CategoryService.put(id, dto);

    if (newCat != null && mounted) {
      setState(() {
        categories.removeWhere((c) => c.id == id);
        categories.add(newCat);
      });
    }
  }

  void delete(String id) async {
    final output = await CategoryService.delete(id);

    if (output == true && mounted) {
      setState(() {
        categories.removeWhere((c) => c.id == id);
      });
    }
  }

  void rebuild() {
    if (!mounted) {
      return;
    }
    setState(() {});
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
            'Categories:',
            design.screenWidth * marqueeTitleWMult,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => CategoryCreationDialog(callback: post),
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
        ...categories.expand(
          (e) => [
            CategoryCard(
              category: e,

              editAction: () {
                showDialog(
                  context: context,
                  builder: (_) => CategoryCreationDialog(
                    fromCurrent: e,
                    callback: (value) {
                      if (e.id == null) {
                        return;
                      }

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

              rebuildCallback: rebuild,
            ),
            design.verticalGap(1),
          ],
        ),
      ],
    );
  }
}
