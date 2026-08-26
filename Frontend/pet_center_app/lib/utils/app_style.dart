import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pet_center_app/utils/app_theme.dart';
import 'package:pet_center_app/utils/globals.dart';
import 'package:pet_center_app/utils/tokens.dart';

Color mainTone = kPageBackground;

Color secondaryTone = kLightScheme.surface;

Color panelTone = kLightScheme.surface;

Color filterTone = kLightScheme.surfaceContainer;

Color visitedPanelTone = kLightScheme.surfaceContainerHigh;

Color listTone = kPageBackground;

Color shadowTone = const Color(0x14101828);

Color tabTone = kLightScheme.primary;

double marqueeTitleWMult = 1.0;
double textRowMult = 1.0;
double marqueeNoteWMult = 1.0;
double marqueeSpeed = 15.0;
double marqueeBlank = 125.0;
double imgWMult = 1.0;
int dialogMinLines = 3;

void showSnackbar(String message, [bool overwrite = true]) {
  final messenger = rootScaffoldKey.currentState;
  if (messenger != null) {
    if (overwrite) {
      messenger.clearSnackBars();
    }
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }
}

void showError(Object ex) {
  switch (ex) {
    case SocketException():
      showSnackbar("Cannot reach the server. Check your connection.");
    case TimeoutException():
      showSnackbar("The request timed out. Try again.");
    case FormatException():
      showSnackbar("The server returned an unexpected response.");
    case HttpException():
      showSnackbar("A network error occurred.");
    default:
      showSnackbar("An unexpected error occurred.");
  }
}

class ReactiveDesignSystem extends ThemeExtension<ReactiveDesignSystem> {
  final double spacing;
  final double boundedIconSize;
  final double boundedImageSize;
  final double fontSize;
  final double marqueeSize;
  final Axis layoutDirection;
  final double bodyWMult;
  final double screenWidth;
  final double screenHeight;
  final double dialogWidth;
  final double dropdownW;

  final WindowClass windowClass;

  final bool isShort;

  final StatusPalette status;

  final ColorScheme scheme;

  ReactiveDesignSystem({
    required this.spacing,
    required this.boundedIconSize,
    required this.boundedImageSize,
    required this.fontSize,
    required this.layoutDirection,
    required this.bodyWMult,
    required this.marqueeSize,
    required this.screenWidth,
    required this.screenHeight,
    required this.dialogWidth,
    required this.dropdownW,
    required this.windowClass,
    required this.isShort,
    required this.status,
    required this.scheme,
  });

  factory ReactiveDesignSystem.fromMediaQuery(MediaQueryData data) {
    return ReactiveDesignSystem.fromSize(data.size);
  }

  factory ReactiveDesignSystem.fromSize(Size size, [ColorScheme? scheme]) {
    final double width = size.width;
    final double height = size.height;
    final WindowClass windowClass = Breakpoints.of(width);
    final bool wide = windowClass != WindowClass.compact;

    const fontScale = Responsive<double>(compact: 14, medium: 14, expanded: 15);
    const dropdown = Responsive<double>(
      compact: 160,
      medium: 200,
      expanded: 240,
    );
    const dialog = Responsive<double>(compact: 400, medium: 480, expanded: 560);

    final double resolvedFont = fontScale.resolve(windowClass);

    return ReactiveDesignSystem(
      spacing: Spacing.inset.resolve(windowClass),
      boundedIconSize: IconSizes.lg,
      boundedImageSize: IconSizes.thumbnail.resolve(windowClass),
      fontSize: resolvedFont,

      marqueeSize: resolvedFont * 2.0,

      layoutDirection: wide ? Axis.horizontal : Axis.vertical,

      bodyWMult: 1.0,

      screenWidth: width,
      screenHeight: height,

      dialogWidth: () {
        final preferred = dialog.resolve(windowClass);
        final available = width - (Spacing.lg * 2);
        return preferred < available ? preferred : available;
      }(),

      dropdownW: dropdown.resolve(windowClass),

      windowClass: windowClass,
      isShort: Breakpoints.isShort(height),
      status: StatusPalette.light,
      scheme: scheme ?? kLightScheme,
    );
  }

  double get contentMaxWidth => Breakpoints.maxContentWidth;

  bool get isExpanded => windowClass == WindowClass.expanded;

  bool get isCompact => windowClass == WindowClass.compact;

  Widget fittedText(
    String text, [
    double mult = 1.0,
    BoxFit fit = BoxFit.scaleDown,
  ]) {
    return Text(
      text,
      softWrap: true,
      maxLines: isCompact ? 6 : 4,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: fontSize * mult,
        fontWeight: mult >= 1.35 ? FontWeight.w600 : FontWeight.w400,
        height: 1.35,
      ),
    );
  }

  Widget textMarquee(
    String text, [
    double? limit,
    double marqueeWMult = 1.0,
    double fontMult = 1.0,
  ]) {
    return Tooltip(
      message: text,
      child: Text(
        text,
        softWrap: true,
        maxLines: isCompact ? 3 : 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: fontSize * fontMult,
          fontWeight: fontMult >= 1.35 ? FontWeight.w600 : FontWeight.w500,
          height: 1.3,
        ),
      ),
    );
  }

  SizedBox verticalGap([double? height]) {
    return SizedBox(height: height ?? spacing);
  }

  SizedBox horizontalGap([double? width]) {
    return SizedBox(width: width ?? spacing);
  }

  BoxDecoration panelDecoration([bool visited = false]) {
    return BoxDecoration(
      color: visited ? scheme.surfaceContainerHigh : scheme.surface,
      borderRadius: Radii.mdAll,
      border: Border.all(color: scheme.outlineVariant),
      boxShadow: visited
          ? const []
          : [
              BoxShadow(
                color: shadowTone,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
    );
  }

  static const double controlHeight = 48;

  double getToolbarHeight([int textRows = 1, double fontSize = 1.0]) {
    final rows = textRows < 1 ? 1 : textRows;
    final labelHeight = this.fontSize * 1.4;
    return (rows * (labelHeight + controlHeight + Spacing.xs)) + (spacing * 2);
  }

  @override
  ReactiveDesignSystem copyWith({
    double? spacing,
    double? boundedIconSize,
    double? boundedImageSize,
    double? fontSize,
    double? marqueeSize,
    Axis? layoutDirection,
    Color? backgroundColor,
    double? screenWidth,
    double? screenHeight,
    double? bodyWMult,
    double? dialogWidth,
    double? dropdownW,
    WindowClass? windowClass,
    bool? isShort,
    StatusPalette? status,
    ColorScheme? scheme,
  }) {
    return ReactiveDesignSystem(
      spacing: spacing ?? this.spacing,
      boundedIconSize: boundedIconSize ?? this.boundedIconSize,
      boundedImageSize: boundedImageSize ?? this.boundedImageSize,
      fontSize: fontSize ?? this.fontSize,
      layoutDirection: layoutDirection ?? this.layoutDirection,
      marqueeSize: marqueeSize ?? this.marqueeSize,
      screenWidth: screenWidth ?? this.screenWidth,
      screenHeight: screenHeight ?? this.screenHeight,
      bodyWMult: bodyWMult ?? this.bodyWMult,
      dialogWidth: dialogWidth ?? this.dialogWidth,
      dropdownW: dropdownW ?? this.dropdownW,
      windowClass: windowClass ?? this.windowClass,
      isShort: isShort ?? this.isShort,
      status: status ?? this.status,
      scheme: scheme ?? this.scheme,
    );
  }

  @override
  ReactiveDesignSystem lerp(
    ThemeExtension<ReactiveDesignSystem>? other,
    double t,
  ) {
    if (other is! ReactiveDesignSystem) return this;
    return ReactiveDesignSystem(
      spacing: lerpDouble(spacing, other.spacing, t) ?? spacing,
      boundedIconSize:
          lerpDouble(boundedIconSize, other.boundedIconSize, t) ??
          boundedIconSize,
      boundedImageSize:
          lerpDouble(boundedImageSize, other.boundedImageSize, t) ??
          boundedImageSize,
      fontSize: lerpDouble(fontSize, other.fontSize, t) ?? fontSize,
      marqueeSize: lerpDouble(marqueeSize, other.marqueeSize, t) ?? marqueeSize,
      screenWidth: lerpDouble(screenWidth, other.screenWidth, t) ?? screenWidth,
      screenHeight:
          lerpDouble(screenHeight, other.screenHeight, t) ?? screenHeight,
      layoutDirection: t < 0.5 ? layoutDirection : other.layoutDirection,
      bodyWMult: lerpDouble(bodyWMult, other.bodyWMult, t) ?? bodyWMult,
      dialogWidth: lerpDouble(dialogWidth, other.dialogWidth, t) ?? dialogWidth,
      dropdownW: lerpDouble(dropdownW, other.dropdownW, t) ?? dropdownW,
      windowClass: t < 0.5 ? windowClass : other.windowClass,
      isShort: t < 0.5 ? isShort : other.isShort,
      status: t < 0.5 ? status : other.status,
      scheme: ColorScheme.lerp(scheme, other.scheme, t),
    );
  }
}

extension DesignSystemContext on BuildContext {
  ReactiveDesignSystem get design =>
      Theme.of(this).extension<ReactiveDesignSystem>()!;
}
