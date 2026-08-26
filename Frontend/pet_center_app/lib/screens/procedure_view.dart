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
      title: 'Procedures',
      description: 'Medical procedures that can be recorded against an animal.',
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: "Define procedure",
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => TextEntryDialog(
                  dialogName: "New medical procedure:",
                  limit: 50,
                  inputDecoration: "Description...",
                  validation: (value) => validateGeneric(value),
                  callback: post,
                ),
              );
            },
            icon: const Icon(Icons.add),
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
                    dialogName: "Edit procedure:",
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
                    title: "Remove this procedure?",
                    body:
                        "The procedure will be removed along with its specifications.",
                    consequence:
                        "This cannot be undone. Medical records referencing it lose that reference.",
                    confirmLabel: "Remove procedure",
                    destructive: true,
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
