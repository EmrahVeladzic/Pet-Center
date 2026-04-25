import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:pet_center_app/utils/globals.dart';

Color mainTone = Color.fromARGB(255, 60, 50, 75);
Color secondaryTone = Color.fromARGB(255, 50, 40, 55);
Color panelTone = Color.fromARGB(255, 225, 225, 225);
Color visitedPanelTone = Color.fromARGB(255, 185, 185, 185);
Color listTone = Color.fromARGB(255, 200, 200, 200);
Color shadowTone = Color.fromARGB(100, 10, 10, 10);
Color tabTone = Color.fromARGB(255, 90, 80, 105);
double marqueeTitleWMult = 0.75;
double marqueeNoteWMult = 0.95;
double marqueeSpeed = 15.0;
double marqueeBlank = 125.0;
double imgWMult = 0.75;

void showSnackbar(String message) {
  final messenger = rootScaffoldKey.currentState;
  if (messenger != null) {
    messenger.clearSnackBars();
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
  final double fontSize;
  final double marqueeSize;
  final Axis layoutDirection;
  final double bodyWMult;
  final double screenWidth;
  final double screenHeight;

  ReactiveDesignSystem({
    required this.spacing,
    required this.fontSize,
    required this.layoutDirection,
    required this.bodyWMult,
    required this.marqueeSize,
    required this.screenWidth,
    required this.screenHeight,
  });

  factory ReactiveDesignSystem.fromMediaQuery(MediaQueryData data) {
    final double width = data.size.width;
    final double height = data.size.height;
    final double aspectRatio = width / height;
    final bool isLandscape = aspectRatio > 1.0;
    final double shortSide = data.size.shortestSide;

    return ReactiveDesignSystem(
      spacing: isLandscape ? width * 0.015 : width * 0.04,

      fontSize: isLandscape ? shortSide * 0.02 : shortSide * 0.04,

      layoutDirection: isLandscape ? Axis.horizontal : Axis.vertical,

      bodyWMult: isLandscape ? 0.5 : 1.0,

      marqueeSize: (isLandscape ? shortSide * 0.02 : shortSide * 0.04) * 1.4,

      screenWidth: width,

      screenHeight: height,
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

  BoxDecoration panelDecoration([bool visited = false]) {
    return BoxDecoration(
      color: visited ? visitedPanelTone : panelTone,
      boxShadow: [BoxShadow(blurRadius: spacing, color: shadowTone)],
    );
  }

  @override
  ReactiveDesignSystem copyWith({
    double? spacing,
    double? fontSize,
    double? marqueeSize,
    Axis? layoutDirection,
    Color? backgroundColor,
    double? screenWidth,
    double? screenHeight,
    double? bodyWMult,
  }) {
    return ReactiveDesignSystem(
      spacing: spacing ?? this.spacing,
      fontSize: fontSize ?? this.fontSize,
      layoutDirection: layoutDirection ?? this.layoutDirection,
      marqueeSize: marqueeSize ?? this.marqueeSize,
      screenWidth: screenWidth ?? this.screenWidth,
      screenHeight: screenHeight ?? this.screenHeight,
      bodyWMult: bodyWMult ?? this.bodyWMult,
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
      fontSize: lerpDouble(fontSize, other.fontSize, t) ?? fontSize,
      marqueeSize: lerpDouble(marqueeSize, other.marqueeSize, t) ?? marqueeSize,
      screenWidth: lerpDouble(screenWidth, other.screenWidth, t) ?? screenWidth,
      screenHeight:
          lerpDouble(screenHeight, other.screenHeight, t) ?? screenHeight,
      layoutDirection: t < 0.5 ? layoutDirection : other.layoutDirection,
      bodyWMult: lerpDouble(bodyWMult, other.bodyWMult, t) ?? bodyWMult,
    );
  }
}
