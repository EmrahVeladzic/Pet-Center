import 'dart:ui';

import 'package:flutter/material.dart';

class ReactiveDesignSystem extends ThemeExtension<ReactiveDesignSystem> {
  final double spacing;
  final double fontSize;
  final Axis layoutDirection;
  final Color backgroundColor;

  ReactiveDesignSystem({
    required this.spacing,
    required this.fontSize,
    required this.layoutDirection,
    required this.backgroundColor,
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
      backgroundColor: isLandscape
          ? Colors.teal.shade100
          : Colors.orange.shade100,
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
      backgroundColor: backgroundColor ?? this.backgroundColor,
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
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
    );
  }
}
