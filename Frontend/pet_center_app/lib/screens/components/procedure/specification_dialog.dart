import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/procedure_dto.dart';
import 'package:pet_center_app/screens/components/dropdown_menus.dart';
import 'package:pet_center_app/services/procedure_service.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/validators.dart';

class SpecificationCreationDialog extends StatefulWidget {
  final ProcedureSpecificationSubDTO? fromCurrent;
  final String procedureId;
  final void Function(ProcedureSpecificationSubDTO value) callback;

  const SpecificationCreationDialog({
    super.key,
    required this.callback,
    required this.procedureId,
    this.fromCurrent,
  });

  @override
  State<StatefulWidget> createState() => _SpecificationCreationDialogState();
}

class _SpecificationCreationDialogState
    extends State<SpecificationCreationDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _intervalController = TextEditingController();
  late final ProcedureSpecificationSubDTO data;

  bool _ageExempt = false;

  void invokeCallback() async {
    final output = await ProcedureService.setSpecification(
      procedureId: widget.procedureId,
      kindId: data.kindId,
      breedId: data.breedId,
      optional: data.optional,
      sex: data.sexSpecific,
      age: _ageExempt ? null : int.tryParse(_ageController.text),
      interval: data.interval != null
          ? int.tryParse(_intervalController.text)
          : null,
    );

    if (output != null) {
      widget.callback(output);
    }
  }

  @override
  void initState() {
    super.initState();
    data =
        widget.fromCurrent?.copy() ??
        ProcedureSpecificationSubDTO(procedureID: widget.procedureId);

    data.kindId = kinds.first.id!;
    _ageController.text = data.approximateAge?.toString() ?? "31";
    _intervalController.text = data.interval?.toString() ?? "7";
    _ageExempt = data.approximateAge == null;
  }

  @override
  void dispose() {
    _ageController.dispose();
    _intervalController.dispose();
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
                      kindWidget(design.dialogWidth, kinds, (value) {
                        if (mounted && value != null) {
                          setState(() {
                            data.kindId = value.id!;
                            data.breedId = null;
                          });
                        }
                      }),
                    ],
                  ),
                  design.verticalGap(design.spacing / 4),

                  if (kinds
                      .where((k) => k.id == data.kindId)
                      .expand((k) => k.breeds)
                      .isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: data.breedId != null,
                          onChanged: (value) {
                            if (value == null) return;

                            setState(() {
                              data.breedId = value
                                  ? kinds
                                        .where((k) => k.id == data.kindId)
                                        .expand((k) => k.breeds)
                                        .first
                                        .id
                                  : null;

                              if (!value) {
                                _ageExempt = false;
                              }
                            });
                          },
                        ),
                        design.fittedText('Breed specific'),
                      ],
                    ),
                  ],
                  if (data.breedId != null) ...[
                    design.verticalGap(design.spacing / 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        breedWidget(
                          design.dialogWidth,
                          kinds
                              .where((k) => k.id == data.kindId)
                              .expand((k) => k.breeds)
                              .toList(),
                          (value) {
                            if (mounted && value != null) {
                              setState(() {
                                data.breedId = value.id;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                  if (data.breedId != null) ...[
                    design.verticalGap(design.spacing / 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _ageExempt,
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _ageExempt = value;
                            });
                          },
                        ),
                        design.fittedText('Age exempt'),
                      ],
                    ),
                  ],
                  if (!_ageExempt) ...[
                    design.verticalGap(design.spacing / 4),
                    ColoredBox(
                      color: listTone,
                      child: TextFormField(
                        controller: _ageController,
                        maxLines: 1,
                        minLines: 1,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Approximate age (days)...",
                        ),
                        validator: (value) =>
                            validateNumericInRange(value, 0, 3650),
                      ),
                    ),
                  ],
                  design.verticalGap(design.spacing / 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: data.optional,
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            data.optional = value;
                          });
                        },
                      ),
                      design.fittedText('Optional'),
                    ],
                  ),
                  design.verticalGap(design.spacing / 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: data.sexSpecific != null,
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            data.sexSpecific = value ? false : null;
                          });
                        },
                      ),
                      design.fittedText('Sex specific'),
                    ],
                  ),
                  if (data.sexSpecific != null) ...[
                    design.verticalGap(design.spacing / 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: data.sexSpecific,
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              data.sexSpecific = value;
                            });
                          },
                        ),
                        design.fittedText('Male/Female'),
                      ],
                    ),
                  ],
                  design.verticalGap(design.spacing / 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: data.interval != null,
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            data.interval = value ? 0 : null;
                          });
                        },
                      ),
                      design.fittedText('Recurring'),
                    ],
                  ),
                  if (data.interval != null) ...[
                    design.verticalGap(design.spacing / 4),
                    ColoredBox(
                      color: listTone,
                      child: TextFormField(
                        controller: _intervalController,
                        maxLines: 1,
                        minLines: 1,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Interval (days)...",
                        ),
                        validator: (value) =>
                            validateNumericInRange(value, 1, 3650),
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
