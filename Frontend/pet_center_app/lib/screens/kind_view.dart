import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/kind_dto.dart';
import 'package:pet_center_app/screens/breed_selection.dart';
import 'package:pet_center_app/screens/components/breed/kind_card.dart';
import 'package:pet_center_app/screens/components/confirmation_dialog.dart';
import 'package:pet_center_app/screens/components/text_entry_dialog.dart';
import 'package:pet_center_app/screens/templates/screen_scaffold.dart';
import 'package:pet_center_app/services/breed_service.dart';
import 'package:pet_center_app/services/kind_service.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/validators.dart';

class KindViewScreen extends StatefulWidget {
  const KindViewScreen({super.key});

  @override
  State<StatefulWidget> createState() => _KindViewScreenState();
}

class _KindViewScreenState extends State<KindViewScreen> {
  @override
  void initState() {
    super.initState();
  }

  void post(String title) async {
    final dto = KindDTO()..title = title;
    final output = await KindService.post(dto);
    if (output != null && mounted) {
      setState(() {
        kinds.add(output);
      });
    }
  }

  void edit(KindDTO current, String description) async {
    final dto = current.copy()..title = description;
    final output = await KindService.put(dto, current.id!);
    if (output != null && mounted) {
      setState(() {
        kinds.removeWhere((t) => t.id == current.id);
        kinds.add(output);
      });
    }
  }

  void delete(String id) async {
    final output = await KindService.delete(id);
    if (output == true && mounted) {
      setState(() {
        kinds.removeWhere((t) => t.id == id);
      });
    }
  }

  void rebuild() {
    if (!mounted) return;
    setState(() {});
  }

  void switchToBreedScreen(String id) async {
    final output = await BreedService.count(false, true, id);

    if (output != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BreedSelectionScreen(
            maxPage: output,
            adoptionPurposes: false,
            incomplete: true,
            kindId: id,
          ),
        ),
      );
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
            'Form kinds:',
            design.screenWidth * marqueeTitleWMult,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => TextEntryDialog(
                  limit: 30,
                  inputDecoration: "Description...",
                  validation: (value) => validateGeneric(value),
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
        ...kinds.expand(
          (e) => [
            KindCard(
              kind: e,
              editAction: () {
                if (e.id == null) return;
                showDialog(
                  context: context,
                  builder: (_) => TextEntryDialog(
                    initText: e.title,
                    limit: 30,
                    inputDecoration: "Description...",
                    validation: (value) => validateGeneric(value),
                    callback: (value) => edit(e, value),
                  ),
                );
              },
              breedListAction: () {
                final id = e.id;

                if (id == null) {
                  return;
                }

                switchToBreedScreen(id);
              },
              deleteAction: () {
                showDialog(
                  context: context,
                  builder: (_) => ConfirmationDialog(
                    title: "Remove template",
                    body: "Are you sure you wish to remove this form template?",
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
