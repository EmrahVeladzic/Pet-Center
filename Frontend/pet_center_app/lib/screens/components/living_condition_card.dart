import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/living_condition_dto.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/components/radio_button_component.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/jwt_parser.dart';

class LivingConditionCard extends StatefulWidget {
  final LivingConditionFieldDTO livingCondition;
  final VoidCallback deleteAction;
  final VoidCallback editAction;

  const LivingConditionCard({
    super.key,
    required this.livingCondition,
    required this.editAction,
    required this.deleteAction,
  });

  @override
  State<LivingConditionCard> createState() => _LivingConditionCardState();
}

class _LivingConditionCardState extends State<LivingConditionCard> {
  late bool? _answer = widget.livingCondition.entry?.answer;

  void onAnswer(bool? newAnswer) {
    if (newAnswer == null) {
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;
    final role = userToken?.role ?? Access.user;

    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 0, vertical: 1),
      child: Container(
        padding: EdgeInsets.all(design.spacing),
        decoration: design.panelDecoration(),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(flex: 8, child: Text(widget.livingCondition.title)),
                if (role == Access.owner || role == Access.admin) ...[
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: design.boundedIconSize,
                        height: design.boundedIconSize,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: IconButton(
                            onPressed: widget.editAction,
                            icon: const Icon(Icons.edit),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: design.boundedIconSize,
                        height: design.boundedIconSize,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: IconButton(
                            onPressed: widget.deleteAction,
                            icon: const Icon(Icons.delete),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),

            if (role == Access.user) ...[
              design.verticalGap(design.spacing / 2),

              RadioButtonComponent<bool?>(
                options: const [
                  RadioOption<bool?>(value: true, label: "Yes"),
                  RadioOption<bool?>(value: null, label: "Unsure"),
                  RadioOption<bool?>(value: false, label: "No"),
                ],
                groupValue: _answer,
                onChanged: (value) {
                  setState(() => _answer = value);
                  onAnswer(value);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
