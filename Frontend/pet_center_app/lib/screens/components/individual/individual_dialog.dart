import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/individual/individual_request_dto.dart';
import 'package:pet_center_app/models/data_transfer/individual/individual_response_dto.dart';

import 'package:pet_center_app/screens/components/dropdown_menus.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/helpers.dart';
import 'package:pet_center_app/utils/validators.dart';

class IndividualCreationDialog extends StatefulWidget {
  final IndividualResponseDTO? fromCurrent;
  final String? shelterId;
  final void Function(IndividualRequestDTO value) callback;

  const IndividualCreationDialog({
    super.key,
    required this.callback,
    this.fromCurrent,
    this.shelterId,
  });

  @override
  State<StatefulWidget> createState() => _IndividualCreationDialogState();
}

class _IndividualCreationDialogState extends State<IndividualCreationDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  late final IndividualRequestDTO data;

  void invokeCallback() {
    data.name = _nameController.text;
    widget.callback(data);
  }

  @override
  void initState() {
    super.initState();
    data = IndividualRequestDTO();

    if (widget.fromCurrent != null) {
      data.id = widget.fromCurrent!.id;
      data.breedId = widget.fromCurrent!.breedId;
      data.sex = widget.fromCurrent!.sex;
      data.currentVersion = widget.fromCurrent!.currentVersion;
      data.name = widget.fromCurrent!.name;
      data.birthDate = widget.fromCurrent!.birthDate;
      data.shelterId = widget.shelterId;
    } else {
      data.shelterId = widget.shelterId;
      data.breedId = kinds.expand((k) => k.breeds).first.id!;
    }

    _nameController.text = data.name;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Form(
        key: _formKey,
        child: AlertDialog(
          title: Row(
            children: [
              Expanded(child: design.textMarquee('Enter:')),
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
                      maxLines: 1,
                      maxLength: 75,
                      minLines: 1,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(labelText: "Name..."),
                      validator: (value) => validateGeneric(value),
                    ),
                  ),
                  design.verticalGap(design.spacing),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      breedWidget(
                        design.dialogWidth,
                        kinds.expand((k) => k.breeds).toList(),
                        (value) {
                          if (mounted && value != null) {
                            setState(() {
                              data.breedId = value.id!;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  design.verticalGap(1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: data.sex,
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            data.sex = value;
                          });
                        },
                      ),
                      design.fittedText('Male'),
                    ],
                  ),
                  design.verticalGap(1),

                  ListTile(
                    title: design.fittedText(
                      "Birth date: ${formatDate(data.birthDate, true)}",
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: data.birthDate.toLocal(),
                        firstDate: DateTime(DateTime.now().year - 100),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          data.birthDate = picked.toUtc();
                        });
                      }
                    },
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
                  invokeCallback();
                }
              },
              child: design.fittedText('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
