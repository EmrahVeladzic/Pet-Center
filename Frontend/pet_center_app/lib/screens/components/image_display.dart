import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/image_dto.dart';
import 'package:pet_center_app/utils/app_style.dart';

class ImageDisplay extends StatefulWidget {
  final ImageDTO dataSource;

  const ImageDisplay({super.key, required this.dataSource});

  @override
  State<ImageDisplay> createState() => _ImageDisplayState();
}

class _ImageDisplayState extends State<ImageDisplay> {
  Uint8List? _decoded;

  @override
  void initState() {
    super.initState();
    _decode();
  }

  void _decode() {
    final b64 = widget.dataSource.data?.split(',').last;

    if (b64 != null &&
        widget.dataSource.width > 0 &&
        widget.dataSource.height > 0) {
      _decoded = base64Decode(b64);
    } else {
      _decoded = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final design = Theme.of(context).extension<ReactiveDesignSystem>()!;

    if (_decoded != null) {
      return Image.memory(
        _decoded!,
        width: design.screenWidth * design.bodyWMult * imgWMult,
        height:
            design.screenWidth *
            (widget.dataSource.height / widget.dataSource.width) *
            design.bodyWMult *
            imgWMult,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.none,
      );
    } else {
      return Padding(
        padding: EdgeInsetsGeometry.all(design.spacing),
        child: SizedBox(
          width: design.screenWidth * design.bodyWMult * imgWMult * imgWMult,
          height:
              design.screenWidth *
              (widget.dataSource.height / widget.dataSource.width) *
              design.bodyWMult *
              imgWMult,

          child: ColoredBox(
            color: visitedPanelTone,
            child: const Icon(Icons.error_outline),
          ),
        ),
      );
    }
  }
}
