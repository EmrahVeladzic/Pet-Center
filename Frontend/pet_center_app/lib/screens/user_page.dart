import 'package:flutter/material.dart';

import 'package:pet_center_app/models/data_transfer/user/user_response_dto.dart';
import 'package:pet_center_app/models/enums.dart';

import 'package:pet_center_app/screens/components/page_selector.dart';
import 'package:pet_center_app/screens/components/user/user_card.dart';
import 'package:pet_center_app/screens/components/user/user_filters.dart';
import 'package:pet_center_app/screens/templates/data_screen_scaffold.dart';

import 'package:pet_center_app/services/user_service.dart';

import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/jwt_parser.dart';

class UserPageScreen extends StatefulWidget {
  final String? franchiseId;
  final int maxPage;
  const UserPageScreen({super.key, required this.maxPage, this.franchiseId});

  @override
  State<StatefulWidget> createState() => _UserPageScreenState();
}

class _UserPageScreenState extends State<UserPageScreen> {
  late int pageCount;
  List<UserResponseDTO> dataSource = [];
  bool _initLoading = true;
  final _pageSelectorKey = GlobalKey<PageSelectorState>();
  bool include = true;
  String userName = "";
  @override
  void initState() {
    super.initState();
    pageCount = widget.maxPage;

    switchPage(0);
  }

  void hireFire(String id) async {
    final output = await UserService.setEmployee(
      id,
      widget.franchiseId ?? "",
      !include,
    );

    if (output != null && mounted) {
      setState(() {
        dataSource.removeWhere((e) => e.id == id);
      });
      showSnackbar(output);
    }
  }

  void switchPage(int page) async {
    final newDataSrc = await UserService.get(
      include,
      userName,
      widget.franchiseId,
      page,
    );
    if (newDataSrc != null && mounted) {
      setState(() {
        _initLoading = false;
        dataSource = newDataSrc;
      });
    } else {
      _pageSelectorKey.currentState?.revertPage();
    }
  }

  void resetPages(bool inc, String name) async {
    final output = await UserService.count(inc, name, widget.franchiseId);

    if (output != null) {
      if (!mounted) {
        return;
      }
      setState(() {
        include = inc;
        userName = name;
      });
      _pageSelectorKey.currentState?.resetMax(output);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DataScreenScaffold<UserFilters, UserResponseDTO>(
      appTitle: 'People:',
      maxPage: pageCount,
      pageSelectorKey: _pageSelectorKey,
      switchPage: switchPage,
      loading: _initLoading,
      dataSource: dataSource,
      filter: UserFilters(callback: resetPages),
      filterPrereq: true,
      itemBuilder: (p0, source) {
        return UserCard(
          user: source,
          asEmployer: (widget.franchiseId != null && role == Access.business),
          callback: () {
            final id = source.id;
            if (id == null) {
              return;
            }
            hireFire(id);
          },
          employed: include,
        );
      },
    );
  }
}
