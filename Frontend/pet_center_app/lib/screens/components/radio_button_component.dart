import 'package:flutter/material.dart';
import 'package:pet_center_app/utils/app_style.dart';

class RadioOption<T> {
  final T value;
  final String label;
  const RadioOption({required this.value, required this.label});
}

class _RadioItem<T> extends StatelessWidget {
  final RadioOption<T> option;

  const _RadioItem({required this.option});

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    return InkWell(
      borderRadius: BorderRadius.circular(design.boundedIconSize),
      onTap: () => RadioGroup.maybeOf<T>(context)?.onChanged(option.value),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            children: [
              design.fittedText(" ${option.label} "),
              Radio<T>(
                value: option.value,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                  if (states.contains(WidgetState.selected)) return mainTone;
                  return secondaryTone;
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RadioButtonComponent<T> extends StatelessWidget {
  final List<RadioOption<T>> options;
  final T? groupValue;
  final ValueChanged<T?> onChanged;

  const RadioButtonComponent({
    super.key,
    required this.options,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RadioGroup<T>(
      groupValue: groupValue,
      onChanged: onChanged,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: options
              .map((option) => _RadioItem<T>(option: option))
              .toList(),
        ),
      ),
    );
  }
}
