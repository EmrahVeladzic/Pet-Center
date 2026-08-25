import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/image_dto.dart';
import 'package:pet_center_app/screens/components/confirmation_dialog.dart';
import 'package:pet_center_app/services/image_service.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/tokens.dart';
import 'package:pet_center_app/utils/image_cache_service.dart';
import 'dart:ui' as ui;

class ImageDisplay extends StatefulWidget {
  final ImageDTO? dataSource;
  final String? creationToken;
  final bool locked;
  final bool creating;
  final void Function(ImageDTO? output)? editCallback;
  final double maxHeightFactor;

  const ImageDisplay({
    super.key,
    required this.dataSource,
    required this.creationToken,
    required this.locked,
    required this.creating,
    this.editCallback,
    this.maxHeightFactor = 0.5,
  });

  @override
  State<ImageDisplay> createState() => ImageDisplayState();
}

class ImageDisplayState extends State<ImageDisplay> {
  double get maxHeightFactor => widget.maxHeightFactor;

  Uint8List? _decoded;
  ImageDTO? dataSrc;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    dataSrc = widget.dataSource;

    _decode();
  }

  @override
  void didUpdateWidget(covariant ImageDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.dataSource?.hash != widget.dataSource?.hash &&
        widget.dataSource?.hash != dataSrc?.hash) {
      dataSrc = widget.dataSource;
      _decoded = null;
      _loading = true;
      _error = false;
      _decode();
    }
  }

  Future<void> _decode() async {
    if (dataSrc?.token != null) {
      final cached = ImageCacheService.instance.get(dataSrc!.hash);
      if (cached != null) {
        if (mounted) {
          setState(() {
            _decoded = cached;
            _loading = false;
          });
        }
        return;
      }
      final bytes = await ImageService.get(dataSrc?.token);
      if (bytes != null) ImageCacheService.instance.put(dataSrc!.hash, bytes);
      if (mounted) {
        setState(() {
          _decoded = bytes;
          _loading = false;
          _error = (_decoded == null);
        });
      }
    } else {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  bool validate() {
    if (_loading) {
      showSnackbar("The image is still loading.", false);
      return false;
    }

    if (_error) {
      showSnackbar("The image failed to load.", false);
      return false;
    }

    final hasImage = (_decoded != null);

    if (!hasImage) {
      showSnackbar("An image is required.", false);
      return false;
    }

    return true;
  }

  Widget _overlayButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    required ColorScheme scheme,
  }) {
    return Material(
      color: scheme.surface.withValues(alpha: 0.85),
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: tooltip,
        icon: Icon(icon, size: IconSizes.md),
        onPressed: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final double nw = (dataSrc?.width ?? 64).toDouble();
    final double nh = (dataSrc?.height ?? 64).toDouble();
    final double aspect = (nw <= 0 || nh <= 0) ? 1.0 : nw / nh;

    final bool canDelete =
        dataSrc?.canWrite == true && !widget.locked && _decoded != null;
    final bool canCreate =
        (widget.creationToken != null || widget.creating) &&
        !widget.locked &&
        _decoded == null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screen = MediaQuery.sizeOf(context);

        final double availableWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : screen.width;

        double maxHeight = screen.height * maxHeightFactor;
        if (constraints.hasBoundedHeight && constraints.maxHeight < maxHeight) {
          maxHeight = constraints.maxHeight;
        }

        double w = availableWidth;
        double h = w / aspect;

        if (h > maxHeight) {
          h = maxHeight;
          w = h * aspect;
        }

        if (w > availableWidth) {
          w = availableWidth;
          h = w / aspect;
        }

        Widget content;

        if (_loading) {
          content = Container(
            color: scheme.surfaceContainerHigh,
            alignment: Alignment.center,
            child: const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        } else if (_decoded != null) {
          content = Image.memory(
            _decoded!,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
          );
        } else {
          content = Container(
            color: scheme.surfaceContainerHigh,
            alignment: Alignment.center,
            child: Icon(
              _error ? Icons.error_outline : Icons.image_outlined,
              size: IconSizes.lg,
              color: _error ? scheme.error : scheme.onSurfaceVariant,
            ),
          );
        }

        return SizedBox(
          width: w,
          height: h,
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(borderRadius: Radii.smAll, child: content),
              ),
              if (canDelete)
                Positioned(
                  top: Spacing.xxs,
                  right: Spacing.xxs,
                  child: _overlayButton(
                    icon: Icons.delete_outline,
                    tooltip: 'Delete image',
                    scheme: scheme,
                    onTap: () {
                      showDialog<bool>(
                        context: context,
                        builder: (_) => ConfirmationDialog(
                          confirmAction: _onDelete,
                          title: "Delete this image?",
                          body: "The image will be removed from this record.",
                          consequence: "This cannot be undone.",
                          confirmLabel: "Delete",
                          destructive: true,
                        ),
                      );
                    },
                  ),
                ),
              if (canCreate)
                Positioned(
                  top: Spacing.xxs,
                  right: Spacing.xxs,
                  child: _overlayButton(
                    icon: Icons.add_photo_alternate_outlined,
                    tooltip: 'Upload image',
                    scheme: scheme,
                    onTap: _onCreate,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onDelete() async {
    final success = await ImageService.delete(dataSrc?.token);
    if (success) {
      ImageCacheService.instance.invalidate(dataSrc!.hash);
      setState(() {
        _decoded = null;
        dataSrc = null;
      });
      if (widget.editCallback != null) {
        widget.editCallback!(null);
      }
    }
  }

  Future<void> _onCreate() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['webp', 'png', 'jpg', 'jpeg', 'bmp'],
      withData: true,
    );

    if (result == null) return;

    final bytes = result.files.single.bytes;
    if (bytes == null) {
      showSnackbar("Could not read file data.");
      return;
    }

    try {
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image image = frameInfo.image;

      final int realWidth = image.width;
      final int realHeight = image.height;
      final double aspectRatio = realWidth / realHeight;

      image.dispose();
      codec.dispose();

      if (bytes.length > (5 * 1024 * 1024)) {
        showSnackbar("Images may not be larger than 5MB.");
        return;
      }

      if (realWidth > 2048 || realHeight > 2048) {
        showSnackbar("Image resolution is too high (max 2048x2048).");
        return;
      }

      if (realWidth < 32 || realHeight < 32) {
        showSnackbar("Image resolution is too low (min 32x32).");
        return;
      }

      if (aspectRatio < 0.5 || aspectRatio > 2.0) {
        showSnackbar("Invalid aspect ratio. Try using a squarer image.");
        return;
      }
    } catch (e) {
      showSnackbar("Selected file is not a valid or readable image.");
      return;
    }

    if (widget.creating && (widget.creationToken == null)) {
      setState(() {
        _decoded = bytes;
        dataSrc = null;
        showSnackbar("Image queued for insert.");
      });
      return;
    }

    final dto = await ImageService.post(widget.creationToken, bytes);
    if (dto != null) {
      dto.canWrite = true;
      setState(() {
        dataSrc = dto;
        _decoded = bytes;
      });
      if (widget.editCallback != null) {
        widget.editCallback!(dto);
      }
    }
  }

  Future<void> createExternally(String creationToken) async {
    if (dataSrc != null) {
      return;
    }
    if (_decoded == null) {
      showSnackbar("No image to send.", false);
      return;
    }

    final dto = await ImageService.post(creationToken, _decoded);
    if (dto != null) {
      dto.canWrite = true;
      setState(() {
        dataSrc = dto;
      });
      if (widget.editCallback != null) {
        widget.editCallback!(dto);
      }
    }
  }
}
