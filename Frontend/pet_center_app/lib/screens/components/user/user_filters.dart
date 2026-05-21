import 'package:flutter/material.dart';
import 'package:pet_center_app/screens/templates/filter_template.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/globals.dart';

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
              flex: 4,

              child: TextField(
                enabled: !apiServiceBusy.value,
                maxLength: 75,
                maxLines: 1,
                minLines: 1,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(hintText: "Username"),
                controller: _controller,
                onSubmitted: (value) {
                  change(include, value);
                },
              ),
            ),

            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  design.fittedText("Employed"),
                  Checkbox(
                    value: include,
                    onChanged: (value) {
                      change(value!, usrName);
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
