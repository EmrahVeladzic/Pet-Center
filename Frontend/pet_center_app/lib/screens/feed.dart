import 'package:flutter/material.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/components/announcement_page.dart';
import 'package:pet_center_app/screens/components/notification_page.dart';
import 'package:pet_center_app/screens/components/report_page.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/jwt_parser.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});
  @override
  State<StatefulWidget> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  Access role = userToken?.role ?? Access.user;

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    List<Widget> tabs = [
      const Tab(text: 'Announcements'),
      const Tab(text: 'Notifications'),
      if (role == Access.admin || role == Access.owner) ...{
        const Tab(text: 'Reports'),
      },
    ];

    List<Widget> pages = [
      const AnnouncementPage(),
      if (role != Access.admin && role != Access.owner) ...{
        const NotificationPage(),
      },
      if (role == Access.admin || role == Access.owner) ...{const ReportPage()},
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: mainTone,
        appBar: AppBar(
          leading: BackButton(),
          title: const Text("Feed"),
          bottom: TabBar(tabs: tabs),
        ),
        body: Center(
          child: FractionallySizedBox(
            widthFactor: design.bodyWMult,
            heightFactor: 1.0,
            child: ColoredBox(
              color: listTone,
              child: TabBarView(children: pages),
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(),
      ),
    );
  }
}
