import 'package:flutter/material.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/globals.dart';

class BreedFilters extends StatefulWidget implements PreferredSizeWidget {
  static const textRows = 1;

  final bool initIncomplete;
  final void Function(bool inc) callback;

  const BreedFilters({
    super.key,
    this.initIncomplete = false,
    required this.callback,
  });

  @override
  Size get preferredSize => const Size.fromHeight(double.infinity);

  @override
  State<StatefulWidget> createState() => _BreedFiltersState();
}

class _BreedFiltersState extends State<BreedFilters> {
  late bool incomplete;

  void change(bool inc) {
    if (apiServiceBusy || !mounted) {
      return;
    }
    setState(() {
      incomplete = inc;
    });
    widget.callback(inc);
  }

  @override
  void initState() {
    super.initState();

    incomplete = widget.initIncomplete;
  }

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    return SizedBox.expand(
      child: Container(
        decoration: BoxDecoration(color: filterTone),
        padding: EdgeInsets.symmetric(horizontal: design.spacing),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  design.fittedText("Incomplete"),
                  Checkbox(
                    value: incomplete,
                    onChanged: apiServiceBusy
                        ? null
                        : (value) {
                            change(value!);
                          },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
