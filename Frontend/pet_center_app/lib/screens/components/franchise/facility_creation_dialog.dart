import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/facility_dto.dart';

import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/globals.dart';
import 'package:pet_center_app/utils/validators.dart';

class FacilityCreationDialog extends StatefulWidget {
  final String owningFranchiseId;
  final FacilityDTO? editedObject;
  final void Function(FacilityDTO input) creationCallback;
  const FacilityCreationDialog({
    super.key,
    required this.creationCallback,
    required this.owningFranchiseId,
    this.editedObject,
  });

  @override
  State<StatefulWidget> createState() => _FacilityCreationDialogState();
}

class _FacilityCreationDialogState extends State<FacilityCreationDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _contactOverrideController =
      TextEditingController();
  bool hasContact = false;
  late FacilityDTO output;

  @override
  void initState() {
    super.initState();
    output =
        widget.editedObject?.copy() ??
        FacilityDTO(owningFranchise: widget.owningFranchiseId);
  }

  void setOutput() {
    output.city = _cityController.text.trim();
    output.street = _streetController.text.trim();
    output.contact = (hasContact)
        ? _contactOverrideController.text.trim()
        : null;
  }

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _contactOverrideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    return Form(
      key: _formKey,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: AlertDialog(
          title: Row(
            children: [
              Expanded(
                child: design.textMarquee(
                  '${(widget.editedObject == null) ? "Enter" : "Edit"} facility details:',
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          content: SizedBox(
            width: design.dialogWidth,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ColoredBox(
                    color: listTone,
                    child: TextFormField(
                      initialValue: output.city,
                      controller: _cityController,
                      maxLines: null,
                      maxLength: 100,
                      minLines: dialogMinLines,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(hintText: 'City:'),
                      validator: (value) {
                        return validateGeneric(value);
                      },
                    ),
                  ),
                  design.verticalGap(design.spacing / 2),
                  ColoredBox(
                    color: listTone,
                    child: TextFormField(
                      initialValue: output.street,
                      controller: _streetController,
                      maxLines: null,
                      maxLength: 150,
                      minLines: dialogMinLines,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(hintText: 'Street:'),
                      validator: (value) {
                        return validateGeneric(value);
                      },
                    ),
                  ),
                  design.verticalGap(design.spacing / 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: design.textMarquee('Has a contact')),
                      Switch(
                        value: hasContact,
                        onChanged: (val) => setState(() => hasContact = val),
                      ),
                    ],
                  ),
                  if (hasContact) ...[
                    design.verticalGap(design.spacing / 2),
                    ColoredBox(
                      color: listTone,
                      child: TextFormField(
                        initialValue: output.contact ?? "",
                        controller: _contactOverrideController,
                        maxLines: null,
                        maxLength: 255,
                        minLines: dialogMinLines,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(hintText: 'Contact:'),
                        validator: (value) {
                          if (!hasContact) {
                            return null;
                          }
                          return validateGeneric(value);
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState != null &&
                    _formKey.currentState!.validate()) {
                  if (apiServiceBusy) {
                    return;
                  }
                  Navigator.of(context).pop();
                  setOutput();
                  widget.creationCallback(output);
                }
              },
              child: design.textMarquee('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
