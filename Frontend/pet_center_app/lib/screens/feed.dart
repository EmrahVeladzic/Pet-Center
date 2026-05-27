import 'package:flutter/material.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/components/feed/announcement_creation_dialog.dart';
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
  final GlobalKey<AnnouncementPageState> announcementKey =
      GlobalKey<AnnouncementPageState>();

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    final List<Widget> tabs = [
      const Tab(text: 'Announcements'),
      if (role != Access.admin && role != Access.owner)
        const Tab(text: 'Notifications'),
      if (role == Access.admin || role == Access.owner)
        const Tab(text: 'Reports'),
      if (role == Access.user) const Tab(text: 'Automated'),
    ];

    final List<Widget> pages = [
      AnnouncementPage(key: announcementKey),
      if (role != Access.admin && role != Access.owner)
        const NotificationPage(),
      if (role == Access.admin || role == Access.owner) const ReportPage(),
      if (role == Access.user) const NotePage(),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: SizedBox(
            width: design.screenWidth * marqueeTitleWMult,
            height: design.marqueeSize,
            child: design.textMarquee(
              'Feed',
              design.screenWidth * marqueeTitleWMult,
            ),
          ),

          actions: [
            Builder(
              builder: (context) {
                final controller = DefaultTabController.of(context);

                return AnimatedBuilder(
                  animation: controller,
                  builder: (context, _) {
                    final index = controller.index;

                    if (index == 0) {
                      return IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => AnnouncementCreationDialog(
                              callback: () {
                                announcementKey.currentState?.load();
                              },
                            ),
                          );
                        },
                      );
                    }

                    return const SizedBox.shrink();
                  },
                );
              },
            ),
          ],
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
