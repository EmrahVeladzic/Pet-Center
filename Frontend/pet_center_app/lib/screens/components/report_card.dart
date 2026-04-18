import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/listing/sub_dtos.dart';
import 'package:pet_center_app/utils/app_style.dart';

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
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 0, vertical: 1),
      child: Container(
        padding: EdgeInsets.all(design.spacing),
        decoration: design.panelDecoration(visited),
        child: Row(
          children: [
            Expanded(flex: 3, child: Text(report.reason)),
            Expanded(
              flex: 1,
              child: ElevatedButton(
                onPressed: onTap,
                child: Icon(Icons.arrow_forward),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
