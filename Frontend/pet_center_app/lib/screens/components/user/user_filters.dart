import 'package:flutter/material.dart';
import 'package:pet_center_app/screens/components/filter_bar.dart';
import 'package:pet_center_app/screens/templates/filter_template.dart';
import 'package:pet_center_app/utils/globals.dart';
import 'package:pet_center_app/utils/tokens.dart';

class UserFilters extends StatefulWidget
    with FilterTemplate
    implements PreferredSizeWidget {
  static const textRows = 1;
  final String initName;
  final bool initInclude;
  final void Function(bool inc, String name) callback;

  const UserFilters({
    super.key,
    this.initInclude = true,
    this.initName = "",
    required this.callback,
  });

  @override
  Size get preferredSize => const Size.fromHeight(double.infinity);

  @override
  State<StatefulWidget> createState() => _UserFiltersState();
}

class _UserFiltersState extends State<UserFilters> {
  late final TextEditingController _controller;

  late bool include;
  late String usrName;

  void change(bool inc, String name) {
    if (!mounted) {
      return;
    }
    setState(() {
      include = inc;
      usrName = name;
    });
    widget.callback(inc, name);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initName);
    include = widget.initInclude;
    usrName = widget.initName;
  }

  @override
  Widget build(BuildContext context) {
    final busy = apiServiceBusy.value;

    return FilterBar(
      children: [
        FilterField(
          minWidth: 240,
          maxWidth: 360,
          expand: true,
          child: TextField(
            enabled: !busy,
            maxLength: 75,
            maxLines: 1,
            minLines: 1,
            keyboardType: TextInputType.text,
            controller: _controller,
            onSubmitted: (value) => change(include, value),
            decoration: InputDecoration(
              hintText: 'Search by username',
              counterText: '',
              prefixIcon: const Icon(Icons.search, size: IconSizes.md),
              suffixIcon: usrName.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.close, size: IconSizes.md),
                      onPressed: () {
                        _controller.clear();
                        change(include, '');
                      },
                    ),
            ),
          ),
        ),
        FilterToggle(
          label: 'Only employees',
          value: include,
          onChanged: (value) => change(value, usrName),
        ),
      ],
    );
  }
}
