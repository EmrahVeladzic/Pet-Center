import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/individual/individual_response_dto.dart';
import 'package:pet_center_app/screens/components/dropdown_menus.dart';
import 'package:pet_center_app/services/individual_service.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/validators.dart';

class MedicalRecordDialog extends StatefulWidget {
  final String petId;
  final void Function(MedicalEntrySubDTO value) callback;

  const MedicalRecordDialog({
    super.key,
    required this.callback,
    required this.petId,
  });

  @override
  State<StatefulWidget> createState() => _SpecificationCreationDialogState();
}

class _SpecificationCreationDialogState extends State<MedicalRecordDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _daysController;

  String procedureId = procedures.first.id!;

  void invokeCallback() async {
    final output = await IndividualService.setMedical(
      widget.petId,
      procedureId,
      int.tryParse(_daysController.text) ?? 0,
    );

    if (output != null) {
      widget.callback(output);
    }
  }

  @override
  void initState() {
    super.initState();
    _daysController = TextEditingController(text: 0.toString());
  }

  @override
  void dispose() {
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      procedureWidget(design.dialogWidth, procedures, (value) {
                        if (mounted && value?.id != null) {
                          setState(() {
                            procedureId = value!.id!;
                          });
                        }
                      }),
                    ],
                  ),
                  design.verticalGap(design.spacing / 2),

                  ColoredBox(
                    color: listTone,
                    child: TextFormField(
                      controller: _daysController,
                      maxLength: 4,
                      maxLines: 1,
                      minLines: 1,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Days since procedure...",
                      ),
                      validator: (value) =>
                          validateNumericInRange(value, 0, 3650),
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
