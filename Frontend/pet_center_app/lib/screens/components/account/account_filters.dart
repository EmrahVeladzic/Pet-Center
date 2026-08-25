import 'package:flutter/material.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/components/filter_bar.dart';
import 'package:pet_center_app/screens/templates/filter_template.dart';
import 'package:pet_center_app/utils/globals.dart';
import 'package:pet_center_app/utils/tokens.dart';

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
  void didUpdateWidget(AccountFilters oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.contact != oldWidget.contact && widget.contact != accContact) {
      accContact = widget.contact;
      _controller.text = widget.contact;
    }
    if (widget.role != oldWidget.role && widget.role != accRole) {
      accRole = widget.role;
    }
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
    final busy = apiServiceBusy.value;

    final search = TextField(
      enabled: !busy,
      maxLength: 255,
      maxLines: 1,
      minLines: 1,
      keyboardType: TextInputType.text,
      controller: _controller,
      onSubmitted: (value) => invokeCallback(accRole, value),
      decoration: InputDecoration(
        hintText: 'Search by contact',
        counterText: '',
        prefixIcon: const Icon(Icons.search, size: IconSizes.md),
        suffixIcon: accContact.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                icon: const Icon(Icons.close, size: IconSizes.md),
                onPressed: () {
                  _controller.clear();
                  invokeCallback(accRole, '');
                },
              ),
      ),
    );

    final roleField = DropdownMenu<Access>(
      key: ValueKey<Access>(accRole),
      enabled: !busy,
      expandedInsets: EdgeInsets.zero,
      initialSelection: accRole,
      requestFocusOnTap: false,
      label: const Text('Role'),
      onSelected: (value) {
        if (value != null) {
          invokeCallback(value, accContact);
        }
      },
      dropdownMenuEntries: Access.values
          .map(
            (level) => DropdownMenuEntry<Access>(
              value: level,
              label: level.displayName,
            ),
          )
          .toList(),
    );

    return FilterBar(
      children: [
        FilterField(minWidth: 240, maxWidth: 360, expand: true, child: search),
        FilterField(child: roleField),
      ],
    );
  }
}
