import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/listing/sub_dtos.dart';
import 'package:pet_center_app/utils/app_style.dart';

class AvailabilityCard extends StatelessWidget {
  final AvailabilityResponseSubDTO available;

  const AvailabilityCard({super.key, required this.available});

  @override
  Widget build(BuildContext context) {
    final ReactiveDesignSystem design = Theme.of(
      context,
    ).extension<ReactiveDesignSystem>()!;

    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 0, vertical: 1),

      child: Column(
        children: [
          Container(
            decoration: design.panelDecoration(),
            child: design.textMarquee(
              '${available.city} ${available.street}',
              design.screenWidth * design.bodyWMult,
              marqueeNoteWMult,
            ),
          ),
          Container(
            color: visitedPanelTone,
            child: design.textMarquee(
              available.contact,
              design.screenWidth * design.bodyWMult,
              marqueeNoteWMult,
            ),
          ),
        ],
      ),
    );
  }
}
