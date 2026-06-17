import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/user/user_response_dto.dart';
import 'package:pet_center_app/screens/components/feed/notification_card.dart';
import 'package:pet_center_app/screens/notification_view.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/services/user_service.dart';

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

  void setSeen(String itemId) async {
    final newSeen = await UserService.setSeen(itemId);
    if (newSeen != null) {
      setState(() {
        _items.where((n) => n.id == itemId).firstOrNull?.seen = newSeen;
      });
    }
  }

  void load() async {
    final data = self?.notifications ?? [];

    if (mounted) {
      setState(() {
        _items = data;

        _loading = false;
      });
    }
  }

  void switchTo(NotificationSubDTO notif) async {
    final shouldRefresh = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationViewScreen(notification: notif),
      ),
    );

    if (shouldRefresh == true) {
      load();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) return const Center(child: CircularProgressIndicator());

    return ListView.builder(
      itemCount: _items.length,
      itemBuilder: (context, i) => NotificationCard(
        notification: _items[i],
        onTap: () {
          final id = _items[i].id;
          if (id == null) return;
          switchTo(_items[i]);
        },
        onSeen: () {
          final id = _items[i].id;

          if (id == null) return;
          setSeen(id);
        },
      ),
    );
  }
}
