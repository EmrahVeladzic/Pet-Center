import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/breed_dto.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/components/media_thumbnail.dart';
import 'package:pet_center_app/screens/components/status_chip.dart';
import 'package:pet_center_app/utils/tokens.dart';

class BreedTraits extends StatelessWidget {
  final BreedDTO breed;
  final bool compact;

  const BreedTraits({super.key, required this.breed, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final traits = <(String, double)>[
      ('Investment', breed.investment),
      ('Territory', breed.territory),
      ('Pricing', breed.pricing),
      ('Longevity', breed.longevity),
      ('Cohabitation', breed.cohabitation),
    ];

    return Wrap(
      spacing: Spacing.sm,
      runSpacing: Spacing.xxs,
      children: [
        for (final (label, value) in traits)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: Spacing.xxs),
              Text(
                value.toStringAsFixed(2),
                style: theme.textTheme.labelMedium,
              ),
            ],
          ),
      ],
    );
  }
}

class BreedCard extends StatefulWidget {
  final BreedDTO breed;
  final VoidCallback onTap;
  final VoidCallback onAdminTap;
  final VoidCallback onDelete;
  final bool adminMode;

  const BreedCard({
    super.key,
    required this.breed,
    required this.onTap,
    required this.onAdminTap,
    required this.adminMode,
    required this.onDelete,
  });

  @override
  State<BreedCard> createState() => _BreedCardState();
}

class _BreedCardState extends State<BreedCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final breed = widget.breed;
    final open = widget.adminMode ? widget.onAdminTap : widget.onTap;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: open,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          padding: const EdgeInsets.all(Spacing.sm),
          decoration: BoxDecoration(
            color: _hovered ? scheme.surfaceContainerLow : scheme.surface,
            borderRadius: Radii.mdAll,
            border: Border.all(
              color: _hovered ? scheme.primary : scheme.outlineVariant,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MediaThumbnail(media: breed.media, fallbackIcon: Icons.pets),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          breed.title.isEmpty ? 'Untitled breed' : breed.title,
                          softWrap: true,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: Spacing.xxs),
                        StatusChip(
                          label: '${breed.scale.displayName} scale',
                          tone: StatusTone.neutral,
                          showDot: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: Spacing.xs),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Open breed',
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: open,
                      ),
                      if (widget.adminMode)
                        IconButton(
                          tooltip: 'Delete breed',
                          icon: const Icon(Icons.delete_outline),
                          style: IconButton.styleFrom(
                            foregroundColor: scheme.error,
                          ),
                          onPressed: widget.onDelete,
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: Spacing.sm),
              BreedTraits(breed: breed),
            ],
          ),
        ),
      ),
    );
  }
}
