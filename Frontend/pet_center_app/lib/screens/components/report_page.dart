import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/listing/sub_dtos.dart';
import 'package:pet_center_app/screens/components/report_card.dart';
import 'package:pet_center_app/services/static_data_service.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage>
    with AutomaticKeepAliveClientMixin {
  List<ReportResponseSubDTO> _items = [];
  bool _loading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() {
    final data = self?.reports ?? [];
    if (mounted) {
      setState(() {
        _items = data;
        _loading = false;
      });
    }
  }

  void addIndex(String i) {
    setState(() {
      if (!visitedReportIndices.contains(i)) {
        visitedReportIndices.add(i);
      }
    });
  }

  void getRelevant() async {}

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) return const Center(child: CircularProgressIndicator());

    return ListView.builder(
      itemCount: _items.length,
      itemBuilder: (context, i) => ReportCard(
        report: _items[i],
        visited: visitedReportIndices.contains(_items[i].id),
        onTap: () {
          final id = _items[i].id;
          if (id == null) return;
          addIndex(id);
          getRelevant();
        },
      ),
    );
  }
}
