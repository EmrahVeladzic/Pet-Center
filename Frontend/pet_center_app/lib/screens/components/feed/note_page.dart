import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/note_sub_dto.dart';
import 'package:pet_center_app/screens/components/feed/note_card.dart';

import 'package:pet_center_app/services/static_user_data_service.dart';

class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage>
    with AutomaticKeepAliveClientMixin {
  List<NoteSubDTO> _items = [];
  bool _loading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    final data = self?.notes ?? [];
    if (mounted) {
      setState(() {
        _items = data;

        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) return const Center(child: CircularProgressIndicator());

    return ListView.builder(
      itemCount: _items.length,
      itemBuilder: (context, i) => NoteCard(note: _items[i], noteKey: i),
    );
  }
}
