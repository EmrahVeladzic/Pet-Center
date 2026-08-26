import 'package:flutter/material.dart';
import 'package:pet_center_app/utils/tokens.dart';

const Color kSeedColor = Color(0xFF4F46E5);

final ColorScheme kLightScheme = ColorScheme.fromSeed(seedColor: kSeedColor)
    .copyWith(
      surface: const Color(0xFFFFFFFF),
      surfaceContainerLowest: const Color(0xFFFFFFFF),
      surfaceContainerLow: const Color(0xFFFAFBFC),
      surfaceContainer: const Color(0xFFF4F6F9),
      surfaceContainerHigh: const Color(0xFFEDF0F4),
      surfaceContainerHighest: const Color(0xFFE6EAF0),
      onSurface: const Color(0xFF171A20),
      onSurfaceVariant: const Color(0xFF5B6472),
      outline: const Color(0xFFC7CEDA),
      outlineVariant: const Color(0xFFE3E8EF),
    );

const Color kPageBackground = Color(0xFFF7F8FA);

ThemeData buildAppTheme(WindowClass windowClass) {
  final scheme = kLightScheme;
  final inset = Spacing.inset.resolve(windowClass);

  final TextTheme textTheme = Typography.material2021().black
      .copyWith(
        displaySmall: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
        headlineMedium: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w600,
          height: 1.25,
        ),
        headlineSmall: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        titleLarge: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        titleMedium: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.35,
        ),
        titleSmall: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        bodyLarge: const TextStyle(fontSize: 15, height: 1.45),
        bodyMedium: const TextStyle(fontSize: 14, height: 1.45),
        bodySmall: const TextStyle(fontSize: 13, height: 1.4),
        labelLarge: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        labelMedium: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        labelSmall: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
      )
      .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    textTheme: textTheme,
    scaffoldBackgroundColor: kPageBackground,
    canvasColor: kPageBackground,
    splashFactory: InkSparkle.splashFactory,
    visualDensity: VisualDensity.standard,
    materialTapTargetSize: MaterialTapTargetSize.padded,

    appBarTheme: AppBarTheme(
      centerTitle: false,
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      shape: Border(bottom: BorderSide(color: scheme.outlineVariant)),
      titleTextStyle: textTheme.titleLarge,
      iconTheme: IconThemeData(
        color: scheme.onSurfaceVariant,
        size: IconSizes.lg,
      ),
      actionsIconTheme: IconThemeData(
        color: scheme.onSurfaceVariant,
        size: IconSizes.lg,
      ),
    ),

    bottomAppBarTheme: BottomAppBarThemeData(
      color: scheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      height: 56,
      padding: EdgeInsets.symmetric(horizontal: inset),
    ),

    cardTheme: CardThemeData(
      color: scheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: Radii.mdAll,
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),

    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant,
      thickness: 1,
      space: 1,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        shape: const RoundedRectangleBorder(borderRadius: Radii.smAll),
        textStyle: textTheme.labelLarge,
        minimumSize: const Size(0, 40),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        shape: const RoundedRectangleBorder(borderRadius: Radii.smAll),
        textStyle: textTheme.labelLarge,
        minimumSize: const Size(0, 40),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.onSurface,
        side: BorderSide(color: scheme.outline),
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        shape: const RoundedRectangleBorder(borderRadius: Radii.smAll),
        textStyle: textTheme.labelLarge,
        minimumSize: const Size(0, 40),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: scheme.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm,
          vertical: Spacing.xs,
        ),
        shape: const RoundedRectangleBorder(borderRadius: Radii.smAll),
        textStyle: textTheme.labelLarge,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: scheme.onSurfaceVariant,
        iconSize: IconSizes.lg,
        shape: const RoundedRectangleBorder(borderRadius: Radii.smAll),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surface,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.sm,
      ),
      border: OutlineInputBorder(
        borderRadius: Radii.smAll,
        borderSide: BorderSide(color: scheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: Radii.smAll,
        borderSide: BorderSide(color: scheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: Radii.smAll,
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: Radii.smAll,
        borderSide: BorderSide(color: scheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: Radii.smAll,
        borderSide: BorderSide(color: scheme.error, width: 2),
      ),
      labelStyle: textTheme.bodyMedium?.copyWith(
        color: scheme.onSurfaceVariant,
      ),
      floatingLabelStyle: textTheme.labelMedium?.copyWith(
        color: scheme.primary,
      ),
      hintStyle: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
      helperStyle: textTheme.bodySmall?.copyWith(
        color: scheme.onSurfaceVariant,
      ),
      errorStyle: textTheme.bodySmall?.copyWith(color: scheme.error),
    ),

    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: scheme.surface,
      indicatorColor: scheme.primary.withValues(alpha: 0.10),
      indicatorShape: const RoundedRectangleBorder(borderRadius: Radii.smAll),
      selectedIconTheme: IconThemeData(
        color: scheme.primary,
        size: IconSizes.lg,
      ),
      unselectedIconTheme: IconThemeData(
        color: scheme.onSurfaceVariant,
        size: IconSizes.lg,
      ),
      selectedLabelTextStyle: textTheme.labelLarge?.copyWith(
        color: scheme.primary,
      ),
      unselectedLabelTextStyle: textTheme.labelLarge?.copyWith(
        color: scheme.onSurfaceVariant,
      ),
      useIndicator: true,
    ),

    navigationDrawerTheme: NavigationDrawerThemeData(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      indicatorColor: scheme.primary.withValues(alpha: 0.10),
      indicatorShape: const RoundedRectangleBorder(borderRadius: Radii.smAll),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? IconThemeData(color: scheme.primary, size: IconSizes.lg)
            : IconThemeData(color: scheme.onSurfaceVariant, size: IconSizes.lg),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? textTheme.labelLarge?.copyWith(color: scheme.primary)
            : textTheme.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
      ),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 3,
      shape: const RoundedRectangleBorder(borderRadius: Radii.lgAll),
      titleTextStyle: textTheme.titleLarge,
      contentTextStyle: textTheme.bodyMedium,
      insetPadding: const EdgeInsets.all(Spacing.lg),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: scheme.surfaceContainer,
      side: BorderSide.none,
      shape: const RoundedRectangleBorder(borderRadius: Radii.pillAll),
      labelStyle: textTheme.labelMedium,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.xs,
        vertical: Spacing.xxs,
      ),
    ),

    tabBarTheme: TabBarThemeData(
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      labelColor: scheme.primary,
      unselectedLabelColor: scheme.onSurfaceVariant,
      labelStyle: textTheme.titleSmall,
      unselectedLabelStyle: textTheme.titleSmall,
      dividerColor: scheme.outlineVariant,
      overlayColor: WidgetStatePropertyAll(
        scheme.primary.withValues(alpha: 0.06),
      ),
    ),

    expansionTileTheme: ExpansionTileThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      collapsedBackgroundColor: scheme.surface,
      iconColor: scheme.primary,
      collapsedIconColor: scheme.onSurfaceVariant,
      textColor: scheme.onSurface,
      collapsedTextColor: scheme.onSurface,
      childrenPadding: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(borderRadius: Radii.mdAll),
      collapsedShape: const RoundedRectangleBorder(borderRadius: Radii.mdAll),
    ),

    listTileTheme: ListTileThemeData(
      iconColor: scheme.onSurfaceVariant,
      textColor: scheme.onSurface,
      titleTextStyle: textTheme.titleSmall,
      subtitleTextStyle: textTheme.bodySmall?.copyWith(
        color: scheme.onSurfaceVariant,
      ),
      shape: const RoundedRectangleBorder(borderRadius: Radii.smAll),
      contentPadding: EdgeInsets.symmetric(
        horizontal: inset,
        vertical: Spacing.xxs,
      ),
    ),

    dataTableTheme: DataTableThemeData(
      headingRowColor: WidgetStatePropertyAll(scheme.surfaceContainerLow),
      headingTextStyle: textTheme.labelMedium?.copyWith(
        color: scheme.onSurfaceVariant,
      ),
      dataTextStyle: textTheme.bodyMedium,
      dividerThickness: 1,
      horizontalMargin: inset,
      columnSpacing: Spacing.lg,
      headingRowHeight: 48,
      dataRowMinHeight: 56,
      dataRowMaxHeight: 72,
    ),

    tooltipTheme: TooltipThemeData(
      waitDuration: AppDurations.slow,
      decoration: BoxDecoration(
        color: scheme.inverseSurface,
        borderRadius: Radii.smAll,
      ),
      textStyle: textTheme.bodySmall?.copyWith(color: scheme.onInverseSurface),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.xs,
        vertical: Spacing.xxs,
      ),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: scheme.inverseSurface,
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: scheme.onInverseSurface,
      ),
      actionTextColor: scheme.inversePrimary,
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(borderRadius: Radii.smAll),
      insetPadding: const EdgeInsets.all(Spacing.md),
    ),

    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: scheme.primary,
      linearTrackColor: scheme.surfaceContainerHigh,
      circularTrackColor: scheme.surfaceContainerHigh,
    ),

    checkboxTheme: CheckboxThemeData(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(Spacing.xxs)),
      ),
      side: BorderSide(color: scheme.outline, width: 1.5),
    ),

    popupMenuTheme: PopupMenuThemeData(
      color: scheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: Radii.mdAll,
        side: BorderSide(color: scheme.outlineVariant),
      ),
      textStyle: textTheme.bodyMedium,
    ),

    dropdownMenuTheme: DropdownMenuThemeData(
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(scheme.surface),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: Radii.mdAll,
            side: BorderSide(color: scheme.outlineVariant),
          ),
        ),
      ),
    ),

    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStatePropertyAll(scheme.outline),
      radius: const Radius.circular(Radii.pill),
      thickness: const WidgetStatePropertyAll(8),
    ),
  );
}
