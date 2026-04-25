import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/image_dto.dart';
import 'package:pet_center_app/utils/app_style.dart';

class ImageDisplay extends StatelessWidget {
  final ImageDTO dataSource;

  const ImageDisplay({super.key, required this.dataSource});

  @override
  Widget build(BuildContext context) {
    final design = Theme.of(context).extension<ReactiveDesignSystem>()!;
    final String? b64 = dataSource.data?.split(',').last;

    if (b64 != null && dataSource.width > 0 && dataSource.height > 0) {
      final data = base64Decode(b64);
      return Image.memory(
        data,
        width: design.screenWidth * design.bodyWMult * imgWMult,
        height:
            design.screenWidth *
            (dataSource.height / dataSource.width) *
            design.bodyWMult *
            imgWMult,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.none,
      );
    } else {
      return ColoredBox(color: panelTone, child: Icon(Icons.error));
    }
  }
}
