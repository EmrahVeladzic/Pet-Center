import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/image_dto.dart';
import 'package:pet_center_app/screens/components/image_display.dart';
import 'package:pet_center_app/utils/tokens.dart';

class MediaThumbnail extends StatelessWidget {
  final List<ImageDTO> media;
  final IconData fallbackIcon;
  final double size;

  const MediaThumbnail({
    super.key,
    required this.media,
    this.fallbackIcon = Icons.image_outlined,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: Radii.smAll,
      child: Container(
        width: size,
        height: size,
        color: scheme.surfaceContainerHigh,
        child: media.isEmpty
            ? Icon(
                fallbackIcon,
                size: IconSizes.md,
                color: scheme.onSurfaceVariant,
              )
            : ImageDisplay(
                dataSource: media[0],
                creationToken: null,
                locked: true,
                creating: false,
              ),
      ),
    );
  }
}
