import 'package:flutter/material.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/components/filter_bar.dart';
import 'package:pet_center_app/screens/templates/filter_template.dart';
import 'package:pet_center_app/utils/jwt_utils.dart';

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

  @override
  void initState() {
    super.initState();
    incomplete = widget.initIncomplete;
    adoption = widget.initAdoption;
  }

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
  Widget build(BuildContext context) {
    return FilterBar(
      children: [
        if (role == Access.user)
          FilterToggle(
            label: 'Only breeds up for adoption',
            value: adoption,
            onChanged: (value) => change(incomplete, value),
          )
        else
          FilterToggle(
            label: 'Only incomplete breeds',
            value: incomplete,
            onChanged: (value) => change(value, adoption),
          ),
      ],
    );
  }
}
