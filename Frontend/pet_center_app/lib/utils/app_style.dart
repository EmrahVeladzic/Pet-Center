import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pet_center_app/utils/globals.dart';

Color mainTone = Color.fromARGB(255, 60, 50, 75);
Color secondaryTone = Color.fromARGB(255, 50, 40, 55);
Color panelTone = Color.fromARGB(255, 225, 225, 225);
Color shadowTone = Color.fromARGB(100, 10, 10, 10);

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
  final Axis layoutDirection;

  ReactiveDesignSystem({
    required this.spacing,
    required this.fontSize,
    required this.layoutDirection,
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
    );
  }

  BoxDecoration panelDecoration() {
    return BoxDecoration(
      color: panelTone,
      boxShadow: [BoxShadow(blurRadius: spacing, color: shadowTone)],
    );
  }

  @override
  ReactiveDesignSystem copyWith({
    double? spacing,
    double? fontSize,
    Axis? layoutDirection,
    Color? backgroundColor,
  }) {
    return ReactiveDesignSystem(
      spacing: spacing ?? this.spacing,
      fontSize: fontSize ?? this.fontSize,
      layoutDirection: layoutDirection ?? this.layoutDirection,
    );
  }

  @override
  ReactiveDesignSystem lerp(
    ThemeExtension<ReactiveDesignSystem>? other,
    double t,
  ) {
    if (other is! ReactiveDesignSystem) return this;
    return ReactiveDesignSystem(
      spacing: lerpDouble(spacing, other.spacing, t)!,
      fontSize: lerpDouble(fontSize, other.fontSize, t)!,

      layoutDirection: t < 0.5 ? layoutDirection : other.layoutDirection,
    );
  }
}
