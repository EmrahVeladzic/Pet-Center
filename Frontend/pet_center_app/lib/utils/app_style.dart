import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:pet_center_app/utils/globals.dart';

Color mainTone = Color.fromARGB(255, 60, 50, 75);
Color secondaryTone = Color.fromARGB(255, 50, 40, 55);
Color panelTone = Color.fromARGB(255, 225, 225, 225);
Color filterTone = Color.fromARGB(255, 205, 195, 205);
Color visitedPanelTone = Color.fromARGB(255, 185, 185, 185);
Color listTone = Color.fromARGB(255, 200, 200, 200);
Color shadowTone = Color.fromARGB(100, 10, 10, 10);
Color tabTone = Color.fromARGB(255, 90, 80, 105);
double marqueeTitleWMult = 0.7;
double textRowMult = 1.5;
double marqueeNoteWMult = 0.95;
double marqueeSpeed = 15.0;
double marqueeBlank = 125.0;
double imgWMult = 0.75;
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
  });

  factory ReactiveDesignSystem.fromMediaQuery(MediaQueryData data) {
    final double width = data.size.width;
    final double height = data.size.height;
    final double aspectRatio = width / height;
    final bool isLandscape = aspectRatio > 1.0;
    final double shortSide = data.size.shortestSide;

    return ReactiveDesignSystem(
      spacing: isLandscape ? width * 0.015 : width * 0.04,

      boundedIconSize: isLandscape ? width * 0.02 : width * 0.05,

      boundedImageSize: isLandscape ? width * 0.075 : width * 0.2,

      fontSize: isLandscape ? shortSide * 0.02 : shortSide * 0.04,

      dialogWidth: isLandscape ? shortSide * 0.5 : shortSide,

      layoutDirection: isLandscape ? Axis.horizontal : Axis.vertical,

      bodyWMult: isLandscape ? 0.5 : 1.0,

      marqueeSize: (isLandscape ? shortSide * 0.02 : shortSide * 0.04) * 1.4,

      screenWidth: width,

      screenHeight: height,

      dropdownW: width * ((isLandscape) ? 0.25 : 0.5),
    );
  }

  Widget fittedText(
    String text, [
    double mult = 1.0,
    BoxFit fit = BoxFit.scaleDown,
  ]) {
    return FittedBox(
      fit: fit,
      child: Text(text, textScaler: TextScaler.linear(mult)),
    );
  }

  Widget textMarquee(
    String text, [
    double? limit,
    double marqueeWMult = 1.0,
    double fontMult = 1.0,
  ]) {
    final size = fontMult * fontSize;

    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: size),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    double extreme = limit ?? screenWidth;
    extreme *= marqueeWMult;

    if (painter.width > extreme) {
      return Center(
        child: SizedBox(
          width: extreme * marqueeWMult,
          height: marqueeSize * fontMult,
          child: Marquee(
            text: text,
            velocity: marqueeSpeed,
            blankSpace: marqueeBlank,
            style: TextStyle(fontSize: size),
          ),
        ),
      );
    } else {
      return Center(
        child: Text(text, style: TextStyle(fontSize: fontMult * fontSize)),
      );
    }
  }

  SizedBox verticalGap([double? height]) {
    return SizedBox(height: height ?? spacing);
  }

  SizedBox horizontalGap([double? width]) {
    return SizedBox(height: width ?? spacing);
  }

  BoxDecoration panelDecoration([bool visited = false]) {
    return BoxDecoration(
      color: visited ? visitedPanelTone : panelTone,
      boxShadow: visited
          ? []
          : [BoxShadow(blurRadius: spacing / 2, color: shadowTone)],
    );
  }

  double getToolbarHeight([int textRows = 1, double fontSize = 1.0]) {
    return textRows * fontSize * textRowMult * kToolbarHeight;
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
    );
  }
}
