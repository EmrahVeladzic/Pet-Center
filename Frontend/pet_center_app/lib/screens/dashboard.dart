import 'package:flutter/material.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/account_page.dart';
import 'package:pet_center_app/screens/feed.dart';
import 'package:pet_center_app/screens/form_selection.dart';
import 'package:pet_center_app/screens/franchise_view.dart';
import 'package:pet_center_app/screens/individual_view.dart';
import 'package:pet_center_app/screens/kind_selection.dart';
import 'package:pet_center_app/screens/listing_selection.dart';
import 'package:pet_center_app/screens/static_data_editor.dart';
import 'package:pet_center_app/screens/supplies_view.dart';
import 'package:pet_center_app/screens/templates/screen_scaffold.dart';
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

class DashboardAction {
  final String label;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const DashboardAction({
    required this.label,
    required this.description,
    required this.icon,
    required this.onTap,
  });
}

class DashboardSection {
  final String title;
  final List<DashboardAction> actions;

  const DashboardSection({required this.title, required this.actions});
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<StatefulWidget> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final knd = (kinds.isNotEmpty) ? kinds.first.id : null;
  final rlv = (categories.isNotEmpty) ? categories.first.id : null;

  void _push(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  void enterMarket() async {
    final count = await ListingService.count(
      ListingType.product,
      OrderingMethod.id,
      scaleSpecific: AnimalScale.medium,
      kindSpecific: knd,
      relevantId: rlv,
    );

    if (count != null && mounted) {
      _push(
        ListingSelectionScreen(
          maxPage: count,
          initType: ListingType.product,
          initOrdering: OrderingMethod.id,
          initKind: knd,
          initRelevant: rlv,
        ),
      );
    }
  }

  void accountPage() async {
    final count = await AccountService.count(Access.user, "");

    if (count != null && mounted) {
      _push(
        AccountPageScreen(
          maxPage: count,
          initContact: "",
          initRole: Access.user,
        ),
      );
    }
  }

  void staticDataEditor() {
    _push(const StaticDataEditorScreen());
  }

  void evaluateListings() async {
    final count = await ListingService.count(
      ListingType.generic,
      OrderingMethod.id,
      showEvaluated: false,
    );

    if (count != null && mounted) {
      _push(
        ListingSelectionScreen(
          maxPage: count,
          initType: ListingType.generic,
          initOrdering: OrderingMethod.id,
          initShowApproved: false,
        ),
      );
    }
  }

  void viewForms() async {
    final output = await FormService.count(null, false);
    if (output != null && mounted) {
      _push(
        FormSelectionScreen(maxPage: output, templateId: null, eval: false),
      );
    }
  }

  List<DashboardSection> _sections() {
    final shared = DashboardSection(
      title: 'Account',
      actions: [
        DashboardAction(
          label: 'Messages',
          description: 'Announcements, notes and reports addressed to you',
          icon: Icons.forum_outlined,
          onTap: () => _push(const FeedScreen()),
        ),
        DashboardAction(
          label: 'Profile',
          description: 'Username, password, session and stored data',
          icon: Icons.person_outline,
          onTap: () => _push(const UserViewScreen()),
        ),
      ],
    );

    if (role == Access.user) {
      return [
        DashboardSection(
          title: 'Animals',
          actions: [
            DashboardAction(
              label: 'Adopt a pet',
              description: 'Browse animals currently available for adoption',
              icon: Icons.pets_outlined,
              onTap: () => _push(const KindSelectionScreen()),
            ),
            DashboardAction(
              label: 'My pets',
              description: 'Animals in your care and their medical records',
              icon: Icons.cruelty_free_outlined,
              onTap: () => _push(IndividualViewScreen(src: self?.ownedAnimals)),
            ),
          ],
        ),
        DashboardSection(
          title: 'Shopping',
          actions: [
            DashboardAction(
              label: 'Market',
              description: 'Products and services offered by providers',
              icon: Icons.storefront_outlined,
              onTap: enterMarket,
            ),
            DashboardAction(
              label: 'Supplies and wishlist',
              description: 'What you have in stock and what you are looking for',
              icon: Icons.inventory_2_outlined,
              onTap: () => _push(const SuppliesViewScreen()),
            ),
          ],
        ),
        shared,
      ];
    }

    if (role == Access.business) {
      return [
        DashboardSection(
          title: 'Work',
          actions: [
            DashboardAction(
              label: 'My workplaces',
              description: 'Franchises and facilities you are employed at',
              icon: Icons.business_outlined,
              onTap: () => _push(const FranchiseViewScreen()),
            ),
          ],
        ),
        shared,
      ];
    }

    return [
      DashboardSection(
        title: 'Review queue',
        actions: [
          DashboardAction(
            label: 'Evaluate listings',
            description: 'Listings submitted by providers awaiting approval',
            icon: Icons.fact_check_outlined,
            onTap: evaluateListings,
          ),
          DashboardAction(
            label: 'Evaluate forms',
            description: 'Adoption forms waiting for a decision',
            icon: Icons.assignment_outlined,
            onTap: viewForms,
          ),
        ],
      ),
      DashboardSection(
        title: 'Administration',
        actions: [
          DashboardAction(
            label: 'Manage users',
            description: 'Accounts, roles, verification and access',
            icon: Icons.group_outlined,
            onTap: accountPage,
          ),
          DashboardAction(
            label: 'Manage static data',
            description: 'Species, breeds, categories and procedures',
            icon: Icons.tune_outlined,
            onTap: staticDataEditor,
          ),
        ],
      ),
      shared,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final design = context.design;
    final sections = _sections();

    return Watch((context) {
      final name = self?.userName;
      selfRevision.value;

      return BasicScreenScaffold(
      title: name != null ? 'Welcome back, $name' : 'Dashboard',
      description: 'Pick up where you left off, or jump to a section below.',
      body: [
        for (final section in sections) ...[
          Padding(
            padding: const EdgeInsets.only(
              top: Spacing.xs,
              bottom: Spacing.sm,
            ),
            child: Text(
              section.title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final available = constraints.maxWidth;
              final columns = design.isCompact
                  ? 1
                  : (available >= 900 ? 3 : 2);
              final spacing = Spacing.sm;
              final cardWidth =
                  (available - (spacing * (columns - 1))) / columns;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (final action in section.actions)
                    SizedBox(
                      width: cardWidth,
                      child: _ActionCard(action: action),
                    ),
                ],
              );
            },
          ),
            const SizedBox(height: Spacing.lg),
          ],
        ],
      );
    });
  }
}

class _ActionCard extends StatefulWidget {
  final DashboardAction action;

  const _ActionCard({required this.action});

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        decoration: BoxDecoration(
          color: _hovered ? scheme.surfaceContainerLow : scheme.surface,
          borderRadius: Radii.mdAll,
          border: Border.all(
            color: _hovered ? scheme.primary : scheme.outlineVariant,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.action.onTap,
            borderRadius: Radii.mdAll,
            child: Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.10),
                      borderRadius: Radii.smAll,
                    ),
                    child: Icon(
                      widget.action.icon,
                      size: IconSizes.md,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.action.label,
                          maxLines: 2,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: Spacing.xxs),
                        Text(
                          widget.action.description,
                          maxLines: 2,
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
            ),
          ),
        ),
      ),
    );
  }
}