import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/franchise/franchise_request_dto.dart';
import 'package:pet_center_app/models/data_transfer/franchise/franchise_response_dto.dart';

import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/validators.dart';

class FranchiseEditDialog extends StatefulWidget {
  final FranchiseResponseDTO editedObject;
  final void Function(FranchiseRequestDTO input) editCallback;
  const FranchiseEditDialog({
    super.key,
    required this.editCallback,
    required this.editedObject,
  });

  @override
  State<StatefulWidget> createState() => _FranchiseEditDialogState();
}

class _FranchiseEditDialogState extends State<FranchiseEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _contactController;
  late final TextEditingController _nameController;

  late FranchiseRequestDTO output;

  @override
  void initState() {
    super.initState();
    output = FranchiseRequestDTO(
      id: widget.editedObject.id,
      currentVersion: widget.editedObject.currentVersion,
      contact: widget.editedObject.contact,
      franchiseName: widget.editedObject.franchiseName,
    );

    _contactController = TextEditingController(text: output.contact);
    _nameController = TextEditingController(text: output.franchiseName);
  }

  void setOutput() {
    output.id = widget.editedObject.id;
    output.currentVersion = widget.editedObject.currentVersion;
    output.franchiseName = _nameController.text.trim();
    output.contact = _contactController.text.trim();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
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
              Expanded(child: design.textMarquee("Edit franchise details:")),
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
                      controller: _nameController,
                      maxLines: null,
                      maxLength: 75,
                      minLines: dialogMinLines,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(hintText: 'Name:'),
                      validator: (value) {
                        return validateGeneric(value);
                      },
                    ),
                  ),
                  design.verticalGap(design.spacing / 2),
                  ColoredBox(
                    color: listTone,
                    child: TextFormField(
                      controller: _contactController,
                      maxLines: null,
                      maxLength: 255,
                      minLines: dialogMinLines,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(hintText: 'Contact:'),
                      validator: (value) {
                        return validateContact(value);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState != null &&
                    _formKey.currentState!.validate()) {
                  Navigator.of(context).pop();
                  setOutput();
                  widget.editCallback(output);
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
