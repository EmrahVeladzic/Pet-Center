import 'package:flutter/material.dart';

class NormalizedInput extends StatefulWidget {
  final bool bothAxis;
  final void Function(double input) changeCallback;
  final double initValue;

  const NormalizedInput({
    super.key,
    required this.bothAxis,
    required this.changeCallback,
    this.initValue = 0.0,
  });

  @override
  State<StatefulWidget> createState() => _NormalizedInputState();
}

class _NormalizedInputState extends State<NormalizedInput> {
  late double value;

  @override
  void initState() {
    super.initState();
    value = widget.initValue;
  }

  void onChange(double val) {
    setState(() {
      value = val;
    });
    widget.changeCallback(val);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Slider(
            value: value,
            max: 1.0,
            min: widget.bothAxis ? -1.0 : 0.0,
            onChanged: onChange,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 50,
          child: Text(value.toStringAsFixed(2), textAlign: TextAlign.right),
        ),
      ],
    );
  }
}
