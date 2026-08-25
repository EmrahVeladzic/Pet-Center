import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/living_condition_dto.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/components/entity_list_tile.dart';
import 'package:pet_center_app/screens/components/radio_button_component.dart';
import 'package:pet_center_app/services/living_condition_service.dart';
import 'package:pet_center_app/utils/jwt_utils.dart';

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

  void onAnswer(bool? newAnswer) async {
    if (newAnswer == null) {
      final output = await LivingConditionService.removeEntry(
        widget.livingCondition.id!,
      );
      if (output && mounted) {
        setState(() {
          widget.livingCondition.entry = null;
        });
      }
    } else {
      final output = await LivingConditionService.addEntry(
        widget.livingCondition.id!,
        newAnswer,
      );
      if (output != null && mounted) {
        setState(() {
          widget.livingCondition.entry = output;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = role == Access.owner || role == Access.admin;

    return EntityListTile(
      icon: Icons.help_outline,
      title: widget.livingCondition.title.isEmpty
          ? 'Untitled question'
          : widget.livingCondition.title,
      actions: [
        if (admin)
          EntityAction(
            icon: Icons.edit_outlined,
            tooltip: 'Edit question',
            onPressed: widget.editAction,
          ),
        if (admin)
          EntityAction(
            icon: Icons.delete_outline,
            tooltip: 'Remove question',
            onPressed: widget.deleteAction,
            destructive: true,
          ),
      ],
      expanded: role == Access.user
          ? RadioButtonComponent<bool?>(
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
            )
          : null,
    );
  }
}
