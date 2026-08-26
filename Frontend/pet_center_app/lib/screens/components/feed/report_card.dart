import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/listing/sub_dtos.dart';
import 'package:pet_center_app/screens/components/entity_list_tile.dart';
import 'package:pet_center_app/screens/components/status_chip.dart';
import 'package:pet_center_app/utils/helpers.dart';

class ReportCard extends StatelessWidget {
  final ReportResponseSubDTO report;
  final bool visited;
  final VoidCallback onTap;

  const ReportCard({
    super.key,
    required this.report,
    required this.visited,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return EntityListTile(
      icon: Icons.flag_outlined,
      visited: visited,
      onTap: onTap,
      title: report.reason.isEmpty ? 'Report' : report.reason,
      subtitle: 'Reported ${formatDate(report.datePosted)}',
      chips: [
        if (!visited) const StatusChip(label: 'New', tone: StatusTone.info),
      ],
      actions: [
        EntityAction(
          icon: Icons.arrow_forward,
          tooltip: 'Open report',
          onPressed: onTap,
        ),
      ],
    );
  }
}
