import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/form_template_dto.dart';
import 'package:pet_center_app/screens/components/confirmation_dialog.dart';
import 'package:pet_center_app/screens/components/form_template/form_template_card.dart';
import 'package:pet_center_app/screens/components/text_entry_dialog.dart';
import 'package:pet_center_app/screens/templates/screen_scaffold.dart';
import 'package:pet_center_app/services/form_template_service.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/validators.dart';

class FormTemplateView extends StatefulWidget {
  const FormTemplateView({super.key});

  @override
  State<StatefulWidget> createState() => _FormTemplateViewState();
}

class _FormTemplateViewState extends State<FormTemplateView> {
  @override
  void initState() {
    super.initState();
  }

  void post(String description) async {
    final dto = FormTemplateDTO()..description = description;
    final output = await FormTemplateService.post(dto);
    if (output != null && mounted) {
      setState(() {
        templates.add(output);
      });
    }
  }

  void edit(FormTemplateDTO current, String description) async {
    final dto = current.copy()..description = description;
    final output = await FormTemplateService.put(dto, current.id!);
    if (output != null && mounted) {
      setState(() {
        templates.removeWhere((t) => t.id == current.id);
        templates.add(output);
      });
    }
  }

  void delete(String id) async {
    final output = await FormTemplateService.delete(id);
    if (output == true && mounted) {
      setState(() {
        templates.removeWhere((t) => t.id == id);
      });
    }
  }

  void rebuild() {
    if (!mounted) return;
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
            'Form Templates:',
            design.screenWidth * marqueeTitleWMult,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => TextEntryDialog(
                  limit: 100,
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
        ...templates.expand(
          (e) => [
            FormTemplateCard(
              template: e,
              editAction: () {
                if (e.id == null) return;
                showDialog(
                  context: context,
                  builder: (_) => TextEntryDialog(
                    initText: e.description,
                    limit: 100,
                    inputDecoration: "Description...",
                    validation: (value) => validateGeneric(value),
                    callback: (value) => edit(e, value),
                  ),
                );
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
              rebuildCallback: rebuild,
            ),
            design.verticalGap(1),
          ],
        ),
      ],
    );
  }
}
