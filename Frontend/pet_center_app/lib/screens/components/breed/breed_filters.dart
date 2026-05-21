import 'package:flutter/material.dart';
import 'package:pet_center_app/models/enums.dart';

import 'package:pet_center_app/screens/templates/filter_template.dart';

import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/jwt_parser.dart';

class BreedFilters extends StatefulWidget
    with FilterTemplate
    implements PreferredSizeWidget {
  final bool initIncomplete;
  final bool initAdoption;

  final void Function(bool inc, bool adp) callback;

  const BreedFilters({
    super.key,
    this.initIncomplete = false,
    this.initAdoption = false,
    required this.callback,
  });

  @override
  Size get preferredSize => const Size.fromHeight(double.infinity);

  @override
  State<StatefulWidget> createState() => _BreedFiltersState();
}

class _BreedFiltersState extends State<BreedFilters> {
  late bool incomplete;
  late bool adoption;

  void change(bool inc, bool adp) {
    if (!mounted) {
      return;
    }
    setState(() {
      incomplete = inc;
      adoption = adp;
    });
    widget.callback(inc, adp);
  }

  @override
  void initState() {
    super.initState();

    incomplete = widget.initIncomplete;
    adoption = widget.initAdoption;
  }

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    final role = userToken?.role ?? Access.user;

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
                  design.fittedText(
                    role == Access.user ? "Up for adoption" : "Incomplete",
                  ),
                  if (role == Access.user) ...[
                    Checkbox(
                      value: adoption,
                      onChanged: (value) {
                        change(incomplete, value!);
                      },
                    ),
                  ] else ...[
                    Checkbox(
                      value: incomplete,
                      onChanged: (value) {
                        change(value!, adoption);
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
