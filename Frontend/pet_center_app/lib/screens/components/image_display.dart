import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/image_dto.dart';
import 'package:pet_center_app/screens/components/confirmation_dialog.dart';
import 'package:pet_center_app/services/image_service.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/image_cache_service.dart';
import 'dart:ui' as ui;

class ImageDisplay extends StatefulWidget {
  final ImageDTO? dataSource;
  final String? creationToken;
  final bool locked;
  final bool creating;
  final void Function(ImageDTO? output)? editCallback;

  const ImageDisplay({
    super.key,
    required this.dataSource,
    required this.creationToken,
    required this.locked,
    required this.creating,
    this.editCallback,
  });

  @override
  State<ImageDisplay> createState() => ImageDisplayState();
}

class ImageDisplayState extends State<ImageDisplay> {
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

  @override
  Widget build(BuildContext context) {
    final design = Theme.of(context).extension<ReactiveDesignSystem>()!;
    final double w = design.screenWidth * design.bodyWMult * imgWMult;
    final double h = w * ((dataSrc?.height ?? 64) / (dataSrc?.width ?? 64));

    final double nw = (dataSrc?.width ?? 64).toDouble();
    final double nh = (dataSrc?.height ?? 64).toDouble();

    if (_loading) {
      return SizedBox(
        width: w,
        height: h,
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: nw,
            height: nh,
            child: ColoredBox(
              color: listTone,
              child: Center(
                child: SizedBox(
                  width: nw * 0.5,
                  height: nh * 0.5,
                  child: const CircularProgressIndicator(strokeWidth: 1),
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (_decoded != null) {
      return SizedBox(
        width: w,
        height: h,
        child: FittedBox(
          fit: BoxFit.contain,
          child: Stack(
            children: [
              SizedBox(
                width: nw,
                height: nh,
                child: Image.memory(
                  _decoded!,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.none,
                ),
              ),
              if (dataSrc?.canWrite == true && !widget.locked)
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => ConfirmationDialog(
                          confirmAction: _onDelete,
                          title: "Delete image",
                          body: "Are you sure you wish to delete this image?",
                        ),
                      );
                    },
                    child: ColoredBox(
                      color: visitedPanelTone,
                      child: Icon(Icons.delete_outline, size: nw * 0.125),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: w,
      height: h,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Stack(
          children: [
            SizedBox(
              width: nw,
              height: nh,
              child: ColoredBox(
                color: listTone,
                child: Icon(
                  (_error) ? Icons.error_outline : Icons.image,
                  size: nw * 0.5,
                ),
              ),
            ),
            if ((widget.creationToken != null || widget.creating) &&
                !widget.locked)
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _onCreate,
                  child: ColoredBox(
                    color: visitedPanelTone,
                    child: Icon(Icons.create_outlined, size: nw * 0.125),
                  ),
                ),
              ),
          ],
        ),
      ),
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
      allowedExtensions: ['webp', 'png', 'jpg', 'jpeg', 'bmp', 'gif'],
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

      if (realWidth > 4096 || realHeight > 4096) {
        showSnackbar("Image resolution is too high (max 4096x4096).");
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
