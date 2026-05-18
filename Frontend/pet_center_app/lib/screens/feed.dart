import 'package:flutter/material.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/components/feed/announcement_page.dart';
import 'package:pet_center_app/screens/components/feed/note_page.dart';
import 'package:pet_center_app/screens/components/feed/notification_page.dart';
import 'package:pet_center_app/screens/components/feed/report_page.dart';
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
      if (role != Access.admin && role != Access.owner) ...{
        const Tab(text: 'Notifications'),
      },
      if (role == Access.admin || role == Access.owner) ...{
        const Tab(text: 'Reports'),
      },
      const Tab(text: 'Automated'),
    ];

    List<Widget> pages = [
      const AnnouncementPage(),
      if (role != Access.admin && role != Access.owner) ...{
        const NotificationPage(),
      },
      if (role == Access.admin || role == Access.owner) ...{const ReportPage()},
      const NotePage(),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(),
          title: SizedBox(
            width: design.screenWidth * marqueeTitleWMult,
            height: design.marqueeSize,
            child: design.textMarquee(
              'Feed',
              design.screenWidth * marqueeTitleWMult,
            ),
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: constraints.maxWidth * design.bodyWMult,
                child: ColoredBox(
                  color: listTone,
                  child: NestedScrollView(
                    key: const PageStorageKey('feed_scroll'),
                    headerSliverBuilder: (context, innerBoxIsScrolled) => [
                      SliverAppBar(
                        backgroundColor: listTone,

                        pinned: true,

                        toolbarHeight: 0,

                        bottom: TabBar(tabs: tabs),
                      ),
                    ],
                    body: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(
                        context,
                      ).copyWith(scrollbars: false),

                      child: TabBarView(children: pages),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: const BottomAppBar(),
      ),
    );
  }
}
