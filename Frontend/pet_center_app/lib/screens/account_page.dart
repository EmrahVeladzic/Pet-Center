import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/account/account_response_dto.dart';

import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/components/account/account_card.dart';
import 'package:pet_center_app/screens/components/account/account_filters.dart';

import 'package:pet_center_app/screens/components/page_selector.dart';
import 'package:pet_center_app/screens/templates/data_screen_scaffold.dart';
import 'package:pet_center_app/services/account_service.dart';
import 'package:pet_center_app/utils/app_style.dart';

class AccountPageScreen extends StatefulWidget {
  final int maxPage;
  final String initContact;
  final Access initRole;
  const AccountPageScreen({
    super.key,
    required this.maxPage,
    required this.initContact,
    required this.initRole,
  });

  @override
  State<StatefulWidget> createState() => _AccountPageScreen();
}

class _AccountPageScreen extends State<AccountPageScreen> {
  late int pageCount;
  List<AccountResponseDTO> dataSource = [];
  bool _initLoading = true;
  final _pageSelectorKey = GlobalKey<PageSelectorState>();
  late String accContact;
  late Access accRole;

  void setRole(Access newRole, AccountResponseDTO e) async {
    if (e.id == null) {
      return;
    }
    final output = await AccountService.setRole(e.id!, newRole);

    if (output != null && mounted) {
      setState(() {
        e.accessLevel = newRole;
        dataSource.removeWhere((d) => d.id == e.id);
      });
      showSnackbar(output);
    }
  }

  void ban(String id) async {
    final output = await AccountService.delete(id);

    if (output == true && mounted) {
      setState(() {
        dataSource.removeWhere((d) => d.id == id);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    pageCount = widget.maxPage;
    accContact = widget.initContact;
    accRole = widget.initRole;

    switchPage(0);
  }

  void switchPage(int page) async {
    final newDataSrc = await AccountService.get(page, accRole, accContact);
    if (newDataSrc != null && mounted) {
      setState(() {
        _initLoading = false;
        dataSource = newDataSrc;
      });
    } else {
      _pageSelectorKey.currentState?.revertPage();
    }
  }

  void resetPages(Access r, String contact) async {
    final output = await AccountService.count(r, contact);

    if (output != null) {
      if (!mounted) {
        return;
      }
      setState(() {
        accRole = r;
        accContact = contact;
      });
      _pageSelectorKey.currentState?.resetMax(output);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DataScreenScaffold<AccountFilters, AccountResponseDTO>(
      appTitle: 'People:',
      maxPage: pageCount,
      pageSelectorKey: _pageSelectorKey,
      switchPage: switchPage,
      loading: _initLoading,
      dataSource: dataSource,
      filter: AccountFilters(
        callback: resetPages,
        role: accRole,
        contact: accContact,
      ),
      filterPrereq: true,
      itemBuilder: (p0, source) {
        return AccountCard(
          acc: source,
          onTap: () {
            if (source.id == null) {
              return;
            }
            ban(source.id!);
          },
          onChangeRole: (acc) {
            setRole(acc, source);
          },
        );
      },
    );
  }
}
