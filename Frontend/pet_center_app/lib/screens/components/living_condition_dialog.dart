import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/living_condition_dto.dart';
import 'package:pet_center_app/screens/components/normalized_input.dart';

import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/validators.dart';

class LivingConditionDialog extends StatefulWidget {
  final LivingConditionFieldDTO? existing;

  final void Function(LivingConditionDialog input, bool exists) callback;

  const LivingConditionDialog({
    super.key,
    required this.callback,
    this.existing,
  });

  @override
  State<StatefulWidget> createState() => _LivingConditionDialogState();
}

class _LivingConditionDialogState extends State<LivingConditionDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();
  late LivingConditionFieldDTO data;

  @override
  void initState() {
    super.initState();

    data = widget.existing?.copy() ?? LivingConditionFieldDTO();
  }

  void invokeCallback() async {}

  @override
  void dispose() {
    _controller.dispose();
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
              Expanded(
                child: design.textMarquee(
                  '${(widget.existing == null) ? "Create" : "Edit"} living condition field:',
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
                      controller: _controller,
                      maxLines: null,
                      maxLength: 75,
                      minLines: dialogMinLines,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(labelText: "Question..."),
                      validator: (value) {
                        return validateGeneric(value);
                      },
                    ),
                  ),
                  design.verticalGap(design.spacing / 2),
                  design.fittedText("Investment:"),
                  NormalizedInput(
                    bothAxis: true,
                    initValue: data.investmentEffect,
                    changeCallback: (value) {
                      data.investmentEffect = value;
                    },
                  ),
                  design.fittedText("Territory:"),
                  NormalizedInput(
                    bothAxis: true,
                    initValue: data.territoryEffect,
                    changeCallback: (value) {
                      data.territoryEffect = value;
                    },
                  ),
                  design.fittedText("Pricing:"),
                  NormalizedInput(
                    bothAxis: true,
                    initValue: data.pricingEffect,
                    changeCallback: (value) {
                      data.pricingEffect = value;
                    },
                  ),
                  design.fittedText("Longevity:"),
                  NormalizedInput(
                    bothAxis: true,
                    initValue: data.longevityEffect,
                    changeCallback: (value) {
                      data.longevityEffect = value;
                    },
                  ),
                  design.fittedText("Cohabitation:"),
                  NormalizedInput(
                    bothAxis: true,
                    initValue: data.cohabitationEffect,
                    changeCallback: (value) {
                      data.cohabitationEffect = value;
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
