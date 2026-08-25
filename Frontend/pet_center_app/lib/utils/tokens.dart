import 'package:flutter/material.dart';

enum WindowClass { compact, medium, expanded }

class Breakpoints {
  const Breakpoints._();

  static const double medium = 600;

  static const double expanded = 840;

  static const double maxContentWidth = 1280;

  static const double maxFormWidth = 720;

  static const double shortHeight = 560;

  static const double minPageHeight = 420;

  static WindowClass of(double width) {
    if (width >= expanded) return WindowClass.expanded;
    if (width >= medium) return WindowClass.medium;
    return WindowClass.compact;
  }

  static bool isShort(double height) => height < shortHeight;
}

@immutable
class Responsive<T> {
  final T compact;
  final T? medium;
  final T expanded;

  const Responsive({
    required this.compact,
    this.medium,
    required this.expanded,
  });

  const Responsive.all(T value)
    : compact = value,
      medium = value,
      expanded = value;

  T resolve(WindowClass windowClass) => switch (windowClass) {
    WindowClass.compact => compact,
    WindowClass.medium => medium ?? expanded,
    WindowClass.expanded => expanded,
  };
}

class Spacing {
  const Spacing._();

  static const double unit = 4;

  static const double xxs = unit;
  static const double xs = unit * 2;
  static const double sm = unit * 3;
  static const double md = unit * 4;
  static const double lg = unit * 6;
  static const double xl = unit * 8;
  static const double xxl = unit * 12;

  static const gutter = Responsive<double>(
    compact: sm,
    medium: md,
    expanded: lg,
  );

  static const inset = Responsive<double>(
    compact: sm,
    medium: md,
    expanded: md,
  );

  static const listGap = Responsive<double>(compact: xs, expanded: xs);
}

class Radii {
  const Radii._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double pill = 999;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
}

class AppDurations {
  const AppDurations._();

  static const Duration fast = Duration(milliseconds: 120);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 320);
}

class IconSizes {
  const IconSizes._();

  static const double sm = 16;
  static const double md = 20;
  static const double lg = 24;

  static const avatar = Responsive<double>(
    compact: 40,
    medium: 40,
    expanded: 44,
  );
  static const thumbnail = Responsive<double>(
    compact: 56,
    medium: 80,
    expanded: 96,
  );
}

@immutable
class StatusPalette {
  final Color success;
  final Color onSuccessContainer;
  final Color successContainer;
  final Color warning;
  final Color onWarningContainer;
  final Color warningContainer;
  final Color danger;
  final Color onDangerContainer;
  final Color dangerContainer;
  final Color neutral;
  final Color onNeutralContainer;
  final Color neutralContainer;

  const StatusPalette({
    required this.success,
    required this.onSuccessContainer,
    required this.successContainer,
    required this.warning,
    required this.onWarningContainer,
    required this.warningContainer,
    required this.danger,
    required this.onDangerContainer,
    required this.dangerContainer,
    required this.neutral,
    required this.onNeutralContainer,
    required this.neutralContainer,
  });

  static const StatusPalette light = StatusPalette(
    success: Color(0xFF16A34A),
    successContainer: Color(0xFFE7F6EC),
    onSuccessContainer: Color(0xFF10632F),
    warning: Color(0xFFD97706),
    warningContainer: Color(0xFFFDF1E0),
    onWarningContainer: Color(0xFF8A4B04),
    danger: Color(0xFFDC2626),
    dangerContainer: Color(0xFFFCEAEA),
    onDangerContainer: Color(0xFF991B1B),
    neutral: Color(0xFF64748B),
    neutralContainer: Color(0xFFF1F3F7),
    onNeutralContainer: Color(0xFF44506A),
  );
}

class ResponsiveLayout extends StatelessWidget {
  final WidgetBuilder compact;
  final WidgetBuilder? medium;
  final WidgetBuilder expanded;

  const ResponsiveLayout({
    super.key,
    required this.compact,
    this.medium,
    required this.expanded,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;

        return switch (Breakpoints.of(width)) {
          WindowClass.compact => compact(context),
          WindowClass.medium => (medium ?? expanded)(context),
          WindowClass.expanded => expanded(context),
        };
      },
    );
  }
}
