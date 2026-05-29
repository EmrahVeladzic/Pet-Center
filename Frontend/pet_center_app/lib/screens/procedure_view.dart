import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/procedure_dto.dart';
import 'package:pet_center_app/screens/components/confirmation_dialog.dart';
import 'package:pet_center_app/screens/components/text_entry_dialog.dart';
import 'package:pet_center_app/screens/components/procedure/procedure_card.dart';
import 'package:pet_center_app/screens/templates/screen_scaffold.dart';
import 'package:pet_center_app/services/procedure_service.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/validators.dart';

class ProcedureView extends StatefulWidget {
  const ProcedureView({super.key});

  @override
  State<StatefulWidget> createState() => _ProcedureViewState();
}

class _ProcedureViewState extends State<ProcedureView> {
  @override
  void initState() {
    super.initState();
  }

  void post(String description) async {
    final dto = ProcedureDTO()..description = description;
    final output = await ProcedureService.post(dto);
    if (output != null && mounted) {
      setState(() {
        procedures.add(output);
      });
    }
  }

  void edit(ProcedureDTO current, String description) async {
    final dto = current.copy()..description = description;
    final output = await ProcedureService.put(dto, current.id!);
    if (output != null && mounted) {
      setState(() {
        procedures.removeWhere((p) => p.id == current.id);
        procedures.add(output);
      });
    }
  }

  void delete(String id) async {
    final output = await ProcedureService.delete(id);
    if (output == true && mounted) {
      setState(() {
        procedures.removeWhere((p) => p.id == id);
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
            'Procedures:',
            design.screenWidth * marqueeTitleWMult,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => TextEntryDialog(
                  limit: 50,
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
        ...procedures.expand(
          (e) => [
            ProcedureCard(
              procedure: e,
              editAction: () {
                showDialog(
                  context: context,
                  builder: (_) => TextEntryDialog(
                    limit: 50,
                    inputDecoration: "Description...",
                    validation: (value) => validateGeneric(value),
                    callback: (value) {
                      if (e.id == null) {
                        return;
                      }
                      edit(e, value);
                    },
                  ),
                );
              },
              deleteAction: () {
                showDialog(
                  context: context,
                  builder: (_) => ConfirmationDialog(
                    title: "Remove procedure",
                    body: "Are you sure you wish to remove this procedure?",
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
