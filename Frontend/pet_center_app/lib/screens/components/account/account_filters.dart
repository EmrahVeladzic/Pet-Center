import 'package:flutter/material.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/components/dropdown_menus.dart';

import 'package:pet_center_app/screens/templates/filter_template.dart';

import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/globals.dart';

class AccountFilters extends StatefulWidget
    with FilterTemplate
    implements PreferredSizeWidget {
  final String contact;
  final Access role;

  final void Function(Access r, String c) callback;

  const AccountFilters({
    super.key,
    required this.role,
    required this.contact,
    required this.callback,
  });

  @override
  Size get preferredSize => const Size.fromHeight(double.infinity);

  @override
  State<StatefulWidget> createState() => _AccountFiltersState();
}

class _AccountFiltersState extends State<AccountFilters> {
  late Access accRole;
  late String accContact;

  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    accContact = widget.contact;
    accRole = widget.role;
    _controller = TextEditingController(text: accContact);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void invokeCallback(Access a, String c) {
    if (!mounted) {
      return;
    }
    setState(() {
      accRole = a;
      accContact = c;
    });

    widget.callback(a, c);
  }

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    return SizedBox.expand(
      child: Container(
        decoration: BoxDecoration(color: filterTone),
        padding: EdgeInsets.symmetric(horizontal: design.spacing / 2),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: TextField(
                enabled: !apiServiceBusy.value,
                maxLength: 255,
                maxLines: 1,
                minLines: 1,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(hintText: "Contact"),
                controller: _controller,
                onSubmitted: (value) {
                  invokeCallback(accRole, value);
                },
              ),
            ),
            Expanded(flex: 1, child: design.horizontalGap(design.spacing / 2)),
            Expanded(
              flex: 4,
              child: accessWidget(design.dropdownW, accRole, (
                Access? newValue,
              ) {
                if (newValue != null) {
                  invokeCallback(newValue, accContact);
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}
