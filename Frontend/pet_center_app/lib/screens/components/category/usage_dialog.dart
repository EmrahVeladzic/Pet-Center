import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/category_dto.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/components/dropdown_menus.dart';
import 'package:pet_center_app/services/category_service.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/validators.dart';

class UsageCreationDialog extends StatefulWidget {
  final UsageSubDTO? fromCurrent;
  final String categoryId;
  final void Function(UsageSubDTO value) callback;

  const UsageCreationDialog({
    super.key,
    required this.callback,
    required this.categoryId,
    this.fromCurrent,
  });

  @override
  State<StatefulWidget> createState() => _UsageCreationDialogState();
}

class _UsageCreationDialogState extends State<UsageCreationDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _gramsController = TextEditingController();
  late final UsageSubDTO data;

  void invokeCallback() async {
    data.averageDailyAmountGrams = int.tryParse(_gramsController.text) ?? 100;

    final output = await CategoryService.setUsageEstimate(
      widget.categoryId,
      data.kindId,
      data.scaleSpecific,
      data.averageDailyAmountGrams,
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
        UsageSubDTO(categoryId: widget.categoryId);

    if (widget.fromCurrent == null) {
      data.kindId = kinds.first.id!;
    }

    _gramsController.text = data.averageDailyAmountGrams == 0
        ? ''
        : data.averageDailyAmountGrams.toString();
  }

  @override
  void dispose() {
    _gramsController.dispose();
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
                          });
                        }
                      }),
                    ],
                  ),
                  design.verticalGap(1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: data.scaleSpecific != null,
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            data.scaleSpecific = value
                                ? AnimalScale.values.first
                                : null;
                          });
                        },
                      ),
                      design.fittedText('Scale specific'),
                    ],
                  ),
                  if (data.scaleSpecific != null) ...[
                    design.verticalGap(1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        scaleWidget(
                          design.dialogWidth,
                          data.scaleSpecific ?? AnimalScale.medium,
                          (value) {
                            data.scaleSpecific = value;
                          },
                        ),
                      ],
                    ),
                  ],
                  design.verticalGap(design.spacing),
                  ColoredBox(
                    color: listTone,
                    child: TextFormField(
                      controller: _gramsController,
                      maxLines: 1,
                      minLines: 1,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Daily amount (g)...",
                      ),
                      validator: (value) =>
                          validateNumericInRange(value, 1, 10000),
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
