import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/user/user_response_dto.dart';
import 'package:pet_center_app/screens/components/notification_card.dart';
import 'package:pet_center_app/screens/notification_view.dart';
import 'package:pet_center_app/services/static_data_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage>
    with AutomaticKeepAliveClientMixin {
  List<NotificationSubDTO> _items = [];
  bool _loading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() {
    final data = self?.notifications ?? [];
    if (mounted) {
      setState(() {
        _items = data;
        _loading = false;
      });
    }
  }

  void addIndex(String i) {
    setState(() {
      if (!visitedNotifIndices.contains(i)) {
        visitedNotifIndices.add(i);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) return const Center(child: CircularProgressIndicator());

    return ListView.builder(
      itemCount: _items.length,
      itemBuilder: (context, i) => NotificationCard(
        notification: _items[i],
        visited: visitedNotifIndices.contains(_items[i].id),
        onTap: () {
          final id = _items[i].id;
          if (id == null) return;
          addIndex(id);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  NotificationViewScreen(notification: _items[i]),
            ),
          );
        },
      ),
    );
  }
}
