import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/user/user_response_dto.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/components/announcement_card.dart';
import 'package:pet_center_app/services/static_data_service.dart';
import 'package:pet_center_app/utils/hive_cache.dart';

class AnnouncementPage extends StatefulWidget {
  const AnnouncementPage({super.key});

  @override
  State<AnnouncementPage> createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage>
    with AutomaticKeepAliveClientMixin {
  List<AnnouncementSubDTO> _items = [];
  bool _loading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    final data = self?.announcements ?? [];
    final visited = await CacheManager.getAll(CacheEntityType.announcement);
    if (mounted) {
      setState(() {
        _items = data;
        visitedAnnouncementIndices = visited;
        _loading = false;
      });
    }
  }

  void addIndex(String i) async {
    await CacheManager.write(i, CacheEntityType.announcement);
    setState(() {
      if (!visitedAnnouncementIndices.contains(i)) {
        visitedAnnouncementIndices.add(i);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) return const Center(child: CircularProgressIndicator());

    return ListView.builder(
      itemCount: _items.length,
      itemBuilder: (context, i) => AnnouncementCard(
        announcement: _items[i],
        visited: visitedAnnouncementIndices.contains(_items[i].id),
        onTap: () {
          final id = _items[i].id;
          if (id == null) return;
          addIndex(id);
        },
      ),
    );
  }
}
