import 'package:flutter/material.dart';

import 'package:pet_center_app/models/data_transfer/user/user_response_dto.dart';
import 'package:pet_center_app/models/enums.dart';

import 'package:pet_center_app/screens/components/page_selector.dart';
import 'package:pet_center_app/screens/components/user/user_card.dart';
import 'package:pet_center_app/screens/components/user/user_filters.dart';

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
    if (newDataSrc != null) {
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
    if (!mounted) {
      return;
    }
    setState(() {
      include = inc;
      userName = name;
    });
    if (output != null) {
      _pageSelectorKey.currentState?.resetMax(output);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;
    final role = userToken?.role ?? Access.user;

    return Scaffold(
      backgroundColor: mainTone,
      appBar: AppBar(
        title: SizedBox(
          width: design.screenWidth * marqueeTitleWMult,
          height: design.marqueeSize,
          child: design.textMarquee(
            'People:',
            design.screenWidth * marqueeTitleWMult,
          ),
        ),
      ),
      body: Center(
        child: FractionallySizedBox(
          widthFactor: design.bodyWMult,
          heightFactor: 1.0,
          child: Container(
            color: listTone,
            child: _initLoading
                ? Center(
                    child: Transform.scale(
                      scale: 3,
                      child: CircularProgressIndicator(),
                    ),
                  )
                : NestedScrollView(
                    headerSliverBuilder: (context, _) => [
                      SliverAppBar(
                        pinned: true,
                        automaticallyImplyLeading: false,
                        toolbarHeight: design.getToolbarHeight(),

                        flexibleSpace: FlexibleSpaceBar(
                          collapseMode: CollapseMode.none,
                          background: UserFilters(callback: resetPages),
                        ),
                      ),
                    ],
                    body: ListView.builder(
                      itemCount: dataSource.length,
                      itemBuilder: (context, index) => Column(
                        children: [
                          UserCard(
                            user: dataSource[index],
                            asEmployer:
                                (widget.franchiseId != null &&
                                role == Access.business),
                            employed: include,
                            callback: () {
                              final id = dataSource[index].id;
                              if (id == null) {
                                return;
                              }
                              hireFire(id);
                            },
                          ),
                          design.verticalGap(1),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: FittedBox(
          fit: BoxFit.scaleDown,

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PageSelector(
                key: _pageSelectorKey,
                maxPage: widget.maxPage,
                onChanged: switchPage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
