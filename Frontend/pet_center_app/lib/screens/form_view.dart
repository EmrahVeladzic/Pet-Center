import 'package:flutter/material.dart';

import 'package:pet_center_app/models/data_transfer/form_dto.dart';
import 'package:pet_center_app/models/data_transfer/form_template_dto.dart';
import 'package:pet_center_app/models/data_transfer/franchise/franchise_request_dto.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/components/confirmation_dialog.dart';
import 'package:pet_center_app/screens/components/form/entry_card.dart';
import 'package:pet_center_app/screens/components/image_display.dart';
import 'package:pet_center_app/screens/components/listing/deletion_dialog.dart';
import 'package:pet_center_app/screens/components/text_entry_dialog.dart';
import 'package:pet_center_app/screens/form_edit.dart';
import 'package:pet_center_app/screens/templates/screen_scaffold.dart';
import 'package:pet_center_app/services/account_service.dart';
import 'package:pet_center_app/services/form_service.dart';
import 'package:pet_center_app/services/franchise_service.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/helpers.dart';
import 'package:pet_center_app/utils/jwt_utils.dart';
import 'package:pet_center_app/utils/pdf_utils.dart';
import 'package:pet_center_app/utils/validators.dart';

class FormViewScreen extends StatefulWidget {
  final FormDTO form;
  final VoidCallback onModify;

  const FormViewScreen({super.key, required this.form, required this.onModify});

  @override
  State<StatefulWidget> createState() => _FormViewScreenState();
}

class _FormViewScreenState extends State<FormViewScreen> {
  late String franchiseName;
  late String defaultContact;
  late final FormTemplateDTO? template;

  @override
  void initState() {
    super.initState();
    franchiseName = widget.form.franchiseName;
    defaultContact = widget.form.defaultContact;
    template = templates.cast<FormTemplateDTO?>().firstWhere(
      (t) => t?.id == widget.form.formTemplateId,
      orElse: () => null,
    );
  }

  void removeForm() async {
    if (widget.form.id == null) return;
    final output = await FormService.delete(widget.form.id!);
    if (output && mounted) {
      Navigator.pop(context);
      widget.onModify();
    }
  }

  void denyForm(String reason) async {
    if (widget.form.id == null) return;
    final output = await FormService.deny(widget.form.id!, reason);
    if (output && mounted) {
      Navigator.pop(context);
      widget.onModify();
    }
  }

  void approveForm() async {
    if (widget.form.id == null) return;
    final output = await FranchiseService.post(
      FranchiseRequestDTO(creationFormId: widget.form.id),
    );
    if (mounted && output != null) {
      Navigator.pop(context);
      widget.onModify();
    }
  }

  void navigateToEdit() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormEditScreen(
          formTemplateId: widget.form.formTemplateId,
          fromCurrent: widget.form,
          callback: (updated) {
            if (mounted) {
              setState(() {
                franchiseName = updated.franchiseName;
                defaultContact = updated.defaultContact;
              });
            }
            widget.onModify();
          },
        ),
      ),
    );
  }

  void ownerDelete(bool ban) async {
    bool output = false;
    if (ban) {
      output = await AccountService.delete(widget.form.userId);
    } else {
      if (widget.form.id == null) {
        return;
      }

      output = await FormService.delete(widget.form.id!);
    }

    if (output && mounted) {
      Navigator.pop(context);
      widget.onModify();
    }
  }

  void toPdf() async {
    if (widget.form.id == null) {
      return;
    }
    await formToPdf(widget.form.id!);
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
            franchiseName,
            design.screenWidth * marqueeTitleWMult,
          ),
        ),
        actions: [
          if (role == Access.business) ...[
            IconButton(icon: const Icon(Icons.edit), onPressed: navigateToEdit),
          ],
          IconButton(icon: Icon(Icons.picture_as_pdf), onPressed: toPdf),
          IconButton(
            onPressed: () {
              if (role == Access.business) {
                showDialog(
                  context: context,
                  builder: (_) => ConfirmationDialog(
                    confirmAction: removeForm,
                    title: "Withdraw form",
                  ),
                );
              } else if (widget.form.evalContact == null) {
                showDialog(
                  context: context,
                  builder: (_) => TextEntryDialog(
                    limit: 150,
                    callback: denyForm,
                    validation: validateGeneric,
                    dialogName: "Deny form",
                    inputDecoration: "Reason...",
                  ),
                );
              } else if (role == Access.owner) {
                showDialog(
                  context: context,
                  builder: (_) => DeletionDialog(
                    deletionAction: (ban) => ownerDelete(ban),
                    bannable: true,
                    itemName: 'form',
                  ),
                );
              }
            },
            icon: (role == Access.business)
                ? const Icon(Icons.delete)
                : const Icon(Icons.block),
          ),
        ],
      ),
      body: [
        design.verticalGap(design.spacing),
        if (widget.form.status != EvaluationStatus.pending &&
            widget.form.evalContact != null &&
            widget.form.evalDate != null &&
            (role == Access.owner || role == Access.admin)) ...[
          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: design.spacing),
            child: Text(
              'Evaluation note: This form was ${widget.form.status.toString().toLowerCase()} by ${widget.form.evalContact} on ${formatDate(widget.form.evalDate!)}.${(widget.form.evalReason?.isNotEmpty ?? false) ? ' The specified reason was: "${widget.form.evalReason}".' : ''}',
              style: TextStyle(fontSize: design.fontSize * 1.5),
            ),
          ),
          design.verticalGap(design.spacing),
        ],
        ImageDisplay(
          dataSource: widget.form.media.isNotEmpty
              ? widget.form.media[0]
              : null,
          creationToken: null,
          locked: true,
          creating: false,
        ),
        design.verticalGap(design.spacing),
        Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: design.spacing),
          child: design.fittedText(franchiseName, 2.0),
        ),
        design.verticalGap(design.spacing),
        Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: design.spacing),
          child: design.fittedText(defaultContact),
        ),
        if (template != null) ...[
          design.verticalGap(design.spacing),
          ...template!.fields.map((field) {
            return EntryCard(
              field: field.description,
              entry: widget.form.entries
                  .where((e) => e.formTemplateFieldId == field.id)
                  .firstOrNull
                  ?.serialized,
            );
          }),
        ],
      ],
      bottomNavigationBar: BottomAppBar(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (role == Access.admin || role == Access.owner) ...[
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => ConfirmationDialog(
                        confirmAction: approveForm,
                        title: "Approve",
                        body: "This will create a new franchise. Continue?",
                      ),
                    );
                  },
                  child: design.fittedText("Approve"),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
