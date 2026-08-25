import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/account/account_response_dto.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/components/confirmation_dialog.dart';
import 'package:pet_center_app/screens/components/status_chip.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/jwt_utils.dart';
import 'package:pet_center_app/utils/tokens.dart';

StatusTone accessTone(Access level) {
  switch (level) {
    case Access.owner:
      return StatusTone.info;
    case Access.admin:
      return StatusTone.info;
    case Access.business:
      return StatusTone.neutral;
    case Access.user:
      return StatusTone.neutral;
  }
}

IconData accessIcon(Access level) {
  switch (level) {
    case Access.owner:
      return Icons.workspace_premium;
    case Access.admin:
      return Icons.shield_outlined;
    case Access.business:
      return Icons.business_center_outlined;
    case Access.user:
      return Icons.person_outline;
  }
}

class AccountAvatar extends StatelessWidget {
  final AccountResponseDTO acc;
  final double radius;

  const AccountAvatar({super.key, required this.acc, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final contact = acc.contact.trim();
    final initial = contact.isNotEmpty
        ? contact.substring(0, 1).toUpperCase()
        : '?';

    return CircleAvatar(
      radius: radius,
      backgroundColor: scheme.primaryContainer,
      child: Text(
        initial,
        style: theme.textTheme.titleSmall?.copyWith(
          color: scheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class AccessChip extends StatelessWidget {
  final Access level;

  const AccessChip({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    return StatusChip(
      label: level.displayName,
      tone: accessTone(level),
      icon: accessIcon(level),
    );
  }
}

class VerificationChip extends StatelessWidget {
  final bool verified;

  const VerificationChip({super.key, required this.verified});

  @override
  Widget build(BuildContext context) {
    return StatusChip(
      label: verified ? 'Verified' : 'Unverified',
      tone: verified ? StatusTone.success : StatusTone.warning,
    );
  }
}

class AccountActions extends StatelessWidget {
  final AccountResponseDTO acc;
  final VoidCallback onBan;
  final void Function(Access level) onChangeRole;

  const AccountActions({
    super.key,
    required this.acc,
    required this.onBan,
    required this.onChangeRole,
  });

  bool get _canBan => role.value > acc.accessLevel.value;

  bool get _canPromote =>
      role == Access.owner && acc.accessLevel == Access.admin;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (!_canBan && !_canPromote) {
      return Text(
        'No actions',
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_canPromote)
          IconButton(
            tooltip: 'Promote to co-owner',
            icon: const Icon(Icons.upgrade),
            onPressed: () {
              showDialog<bool>(
                context: context,
                builder: (_) => ConfirmationDialog(
                  title: 'Promote to co-owner',
                  body:
                      'Promoting this account would make it your peer, with the same level of access you have.',
                  consequence:
                      'A co-owner can manage other administrators and cannot be demoted by you afterwards.',
                  confirmLabel: 'Promote',
                  confirmAction: () => onChangeRole(Access.owner),
                ),
              );
            },
          ),
        if (_canBan)
          IconButton(
            tooltip: 'Ban account',
            icon: const Icon(Icons.gavel),
            style: IconButton.styleFrom(foregroundColor: scheme.error),
            onPressed: () {
              showDialog<bool>(
                context: context,
                builder: (_) => ConfirmationDialog(
                  title: 'Ban this account?',
                  body:
                      'The account will be banned and every record belonging to it will be removed.',
                  consequence:
                      'This cannot be undone. All user data relating to the account is wiped permanently.',
                  confirmLabel: 'Ban account',
                  destructive: true,
                  confirmAction: onBan,
                ),
              );
            },
          ),
      ],
    );
  }
}

class AccountCard extends StatefulWidget {
  final AccountResponseDTO acc;
  final VoidCallback onTap;
  final void Function(Access acc) onChangeRole;

  const AccountCard({
    super.key,
    required this.acc,
    required this.onTap,
    required this.onChangeRole,
  });

  @override
  State<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<AccountCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final design = context.design;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: EdgeInsets.all(design.spacing),
        decoration: BoxDecoration(
          color: _hovered ? scheme.surfaceContainerLow : scheme.surface,
          borderRadius: Radii.mdAll,
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AccountAvatar(acc: widget.acc),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.acc.contact.isEmpty
                            ? 'No contact provided'
                            : widget.acc.contact,
                        softWrap: true,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: Spacing.xxs),
                      Text(
                        widget.acc.accessLevel.displayName,
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
            const SizedBox(height: Spacing.sm),
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: Spacing.xxs,
                    runSpacing: Spacing.xxs,
                    children: [
                      AccessChip(level: widget.acc.accessLevel),
                      VerificationChip(verified: widget.acc.verified),
                    ],
                  ),
                ),
                AccountActions(
                  acc: widget.acc,
                  onBan: widget.onTap,
                  onChangeRole: widget.onChangeRole,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
