import 'package:flutter/material.dart';

import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/account_page.dart';
import 'package:pet_center_app/screens/dashboard.dart';
import 'package:pet_center_app/screens/feed.dart';
import 'package:pet_center_app/screens/form_selection.dart';
import 'package:pet_center_app/screens/franchise_view.dart';
import 'package:pet_center_app/screens/individual_view.dart';
import 'package:pet_center_app/screens/kind_selection.dart';
import 'package:pet_center_app/screens/listing_selection.dart';
import 'package:pet_center_app/screens/static_data_editor.dart';
import 'package:pet_center_app/screens/supplies_view.dart';
import 'package:pet_center_app/screens/user_view.dart';
import 'package:pet_center_app/services/account_service.dart';
import 'package:pet_center_app/services/form_service.dart';
import 'package:pet_center_app/services/listing_service.dart';
import 'package:pet_center_app/services/static_user_data_service.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/jwt_utils.dart';
import 'package:pet_center_app/utils/globals.dart';
import 'package:pet_center_app/utils/tokens.dart';
import 'package:signals/signals_flutter.dart';

class ShellDestination {
  final String label;
  final String description;
  final IconData icon;
  final IconData selectedIcon;
  final Future<Widget?> Function() open;

  const ShellDestination({
    required this.label,
    required this.description,
    required this.icon,
    required this.selectedIcon,
    required this.open,
  });
}

class AppShellScope extends InheritedWidget {
  final bool showsDrawerButton;
  final VoidCallback openDrawer;
  final void Function(int index) select;

  const AppShellScope({
    super.key,
    required this.showsDrawerButton,
    required this.openDrawer,
    required this.select,
    required super.child,
  });

  static AppShellScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppShellScope>();

  @override
  bool updateShouldNotify(AppShellScope oldWidget) =>
      showsDrawerButton != oldWidget.showsDrawerButton;
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final List<ShellDestination> _destinations;
  int _index = 0;
  Widget? _content;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _destinations = _buildDestinations();
    _content = const DashboardScreen();
  }

  List<ShellDestination> _buildDestinations() {
    final overview = ShellDestination(
      label: 'Dashboard',
      description: 'Overview and quick actions',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      open: () async => const DashboardScreen(),
    );

    final messages = ShellDestination(
      label: 'Messages',
      description: 'Announcements, notes and reports',
      icon: Icons.forum_outlined,
      selectedIcon: Icons.forum,
      open: () async => const FeedScreen(),
    );

    final account = ShellDestination(
      label: 'Account',
      description: 'Your profile, session and data',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      open: () async => const UserViewScreen(),
    );

    if (role == Access.user) {
      return [
        overview,
        ShellDestination(
          label: 'Adopt',
          description: 'Browse animals available for adoption',
          icon: Icons.pets_outlined,
          selectedIcon: Icons.pets,
          open: () async => const KindSelectionScreen(),
        ),
        ShellDestination(
          label: 'Market',
          description: 'Products and services',
          icon: Icons.storefront_outlined,
          selectedIcon: Icons.storefront,
          open: () async {
            final knd = kinds.isNotEmpty ? kinds.first.id : null;
            final rlv = categories.isNotEmpty ? categories.first.id : null;
            final count = await ListingService.count(
              ListingType.product,
              OrderingMethod.id,
              scaleSpecific: AnimalScale.medium,
              kindSpecific: knd,
              relevantId: rlv,
            );
            if (count == null) return null;
            return ListingSelectionScreen(
              maxPage: count,
              initType: ListingType.product,
              initOrdering: OrderingMethod.id,
              initKind: knd,
              initRelevant: rlv,
            );
          },
        ),
        ShellDestination(
          label: 'My pets',
          description: 'Animals in your care',
          icon: Icons.cruelty_free_outlined,
          selectedIcon: Icons.cruelty_free,
          open: () async => IndividualViewScreen(src: self?.ownedAnimals),
        ),
        ShellDestination(
          label: 'Supplies',
          description: 'Your supplies and wishlist',
          icon: Icons.inventory_2_outlined,
          selectedIcon: Icons.inventory_2,
          open: () async => const SuppliesViewScreen(),
        ),
        messages,
        account,
      ];
    }

    if (role == Access.business) {
      return [
        overview,
        ShellDestination(
          label: 'Workplaces',
          description: 'Franchises and facilities you work at',
          icon: Icons.business_outlined,
          selectedIcon: Icons.business,
          open: () async => const FranchiseViewScreen(),
        ),
        messages,
        account,
      ];
    }

    return [
      overview,
      ShellDestination(
        label: 'Users',
        description: 'Manage accounts, roles and access',
        icon: Icons.group_outlined,
        selectedIcon: Icons.group,
        open: () async {
          final count = await AccountService.count(Access.user, '');
          if (count == null) return null;
          return AccountPageScreen(
            maxPage: count,
            initContact: '',
            initRole: Access.user,
          );
        },
      ),
      ShellDestination(
        label: 'Listings',
        description: 'Listings awaiting evaluation',
        icon: Icons.fact_check_outlined,
        selectedIcon: Icons.fact_check,
        open: () async {
          final count = await ListingService.count(
            ListingType.generic,
            OrderingMethod.id,
            showEvaluated: false,
          );
          if (count == null) return null;
          return ListingSelectionScreen(
            maxPage: count,
            initType: ListingType.generic,
            initOrdering: OrderingMethod.id,
            initShowApproved: false,
          );
        },
      ),
      ShellDestination(
        label: 'Forms',
        description: 'Adoption forms awaiting review',
        icon: Icons.assignment_outlined,
        selectedIcon: Icons.assignment,
        open: () async {
          final count = await FormService.count(null, false);
          if (count == null) return null;
          return FormSelectionScreen(
            maxPage: count,
            templateId: null,
            eval: false,
          );
        },
      ),
      ShellDestination(
        label: 'Static data',
        description: 'Species, breeds, categories and procedures',
        icon: Icons.tune_outlined,
        selectedIcon: Icons.tune,
        open: () async => const StaticDataEditorScreen(),
      ),
      messages,
      account,
    ];
  }

  Future<void> _select(int index) async {
    if (_loading) return;
    if (index == _index && _content != null) {
      _scaffoldKey.currentState?.closeDrawer();
      return;
    }

    final previous = _index;
    setState(() {
      _index = index;
      _loading = true;
    });
    _scaffoldKey.currentState?.closeDrawer();

    final resolved = await _destinations[index].open();
    if (!mounted) return;

    setState(() {
      _loading = false;
      if (resolved == null) {
        _index = previous;
      } else {
        _content = resolved;
      }
    });
  }

  Widget _brand(BuildContext context, {bool compact = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.md,
      ),
      child: Row(
        mainAxisAlignment: compact
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: Radii.smAll,
            ),
            child: Icon(
              Icons.pets,
              size: IconSizes.md,
              color: theme.colorScheme.onPrimary,
            ),
          ),
          if (!compact) ...[
            const SizedBox(width: Spacing.xs),
            Flexible(
              child: Text(
                'Pet Center',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _userTile(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Watch((context) {
      selfRevision.value;
      final name = self?.userName ?? 'Signed in';

      return Container(
        margin: const EdgeInsets.all(Spacing.sm),
        padding: const EdgeInsets.all(Spacing.xs),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: Radii.mdAll,
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: scheme.primaryContainer,
              child: Text(
                name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: scheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: Spacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                  Text(
                    role.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _rail(BuildContext context, {required bool extended}) {
    final scheme = Theme.of(context).colorScheme;
    final showChrome = context.design.screenHeight >= 360;

    return Container(
      width: extended ? 248 : 84,
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(right: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showChrome) _brand(context, compact: !extended),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
                child: Column(
                  children: [
                    for (var i = 0; i < _destinations.length; i++)
                      _RailTile(
                        destination: _destinations[i],
                        selected: i == _index,
                        extended: extended,
                        onTap: () => _select(i),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (extended && showChrome) _userTile(context),
        ],
      ),
    );
  }

  Widget _drawer(BuildContext context) {
    return NavigationDrawer(
      selectedIndex: _index,
      onDestinationSelected: _select,
      children: [
        _brand(context),
        const Divider(),
        for (final d in _destinations)
          NavigationDrawerDestination(
            icon: Icon(d.icon),
            selectedIcon: Icon(d.selectedIcon),
            label: Text(d.label),
          ),
        const Divider(),
        _userTile(context),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final design = context.design;
    final compact = design.isCompact;
    final extendedRail = design.screenWidth >= 1100;

    final body = _loading
        ? const Center(child: CircularProgressIndicator())
        : Navigator(
            key: ValueKey<int>(_index),
            onGenerateRoute: (settings) => MaterialPageRoute(
              settings: settings,
              builder: (_) => _content ?? const DashboardScreen(),
            ),
          );

    return AppShellScope(
      showsDrawerButton: compact,
      openDrawer: () => _scaffoldKey.currentState?.openDrawer(),
      select: (i) => _select(i),
      child: Scaffold(
        key: _scaffoldKey,
        drawer: compact ? _drawer(context) : null,
        body: SafeArea(
          child: Row(
            children: [
              if (!compact) _rail(context, extended: extendedRail),
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  }
}

class _RailTile extends StatelessWidget {
  final ShellDestination destination;
  final bool selected;
  final bool extended;
  final VoidCallback onTap;

  const _RailTile({
    required this.destination,
    required this.selected,
    required this.extended,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fg = selected ? scheme.primary : scheme.onSurfaceVariant;

    final content = extended
        ? Row(
            children: [
              Icon(
                selected ? destination.selectedIcon : destination.icon,
                size: IconSizes.lg,
                color: fg,
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Text(
                  destination.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(color: fg),
                ),
              ),
            ],
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? destination.selectedIcon : destination.icon,
                size: IconSizes.lg,
                color: fg,
              ),
              const SizedBox(height: Spacing.xxs),
              Text(
                destination.label,
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(color: fg),
              ),
            ],
          );

    return Tooltip(
      message: destination.description,
      waitDuration: const Duration(milliseconds: 600),
      child: Padding(
        padding: const EdgeInsets.only(bottom: Spacing.xxs),
        child: Material(
          color: selected
              ? scheme.primary.withValues(alpha: 0.10)
              : Colors.transparent,
          borderRadius: Radii.smAll,
          child: InkWell(
            onTap: onTap,
            borderRadius: Radii.smAll,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.sm,
                vertical: extended ? Spacing.sm : Spacing.xs,
              ),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
