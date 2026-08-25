import 'package:flutter/material.dart';
import 'package:pet_center_app/models/data_transfer/form_dto.dart';
import 'package:pet_center_app/models/enums.dart';
import 'package:pet_center_app/screens/components/media_thumbnail.dart';
import 'package:pet_center_app/screens/components/status_chip.dart';
import 'package:pet_center_app/utils/app_style.dart';
import 'package:pet_center_app/utils/tokens.dart';

StatusTone evaluationTone(EvaluationStatus status) {
  switch (status) {
    case EvaluationStatus.approved:
      return StatusTone.success;
    case EvaluationStatus.denied:
      return StatusTone.danger;
    case EvaluationStatus.pending:
      return StatusTone.warning;
  }
}

IconData evaluationIcon(EvaluationStatus status) {
  switch (status) {
    case EvaluationStatus.approved:
      return Icons.check_circle_outline;
    case EvaluationStatus.denied:
      return Icons.cancel_outlined;
    case EvaluationStatus.pending:
      return Icons.schedule;
  }
}

class EvaluationChip extends StatelessWidget {
  final EvaluationStatus status;

  const EvaluationChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return StatusChip(
      label: status.displayName,
      tone: evaluationTone(status),
      icon: evaluationIcon(status),
    );
  }
}

class FormThumbnail extends StatelessWidget {
  final FormDTO form;
  final double size;

  const FormThumbnail({super.key, required this.form, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return MediaThumbnail(
      media: form.media,
      fallbackIcon: Icons.description_outlined,
      size: size,
    );
  }
}

String formattedEvalDate(FormDTO form) {
  final date = form.evalDate;
  if (date == null) {
    return 'Not evaluated';
  }
  final d = date.day.toString().padLeft(2, '0');
  final m = date.month.toString().padLeft(2, '0');
  return '$d.$m.${date.year}';
}

class FormCard extends StatefulWidget {
  final FormDTO form;
  final VoidCallback onTap;

  const FormCard({super.key, required this.form, required this.onTap});

  @override
  State<FormCard> createState() => _FormCardState();
}

class _FormCardState extends State<FormCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final design = context.design;
    final form = widget.form;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          padding: EdgeInsets.all(design.spacing),
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
                  FormThumbnail(form: form),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          form.franchiseName.isEmpty
                              ? 'Unnamed franchise'
                              : form.franchiseName,
                          softWrap: true,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: Spacing.xxs),
                        Text(
                          form.defaultContact.isEmpty
                              ? 'No contact provided'
                              : form.defaultContact,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: Spacing.xs),
                  Icon(
                    Icons.chevron_right,
                    color: scheme.onSurfaceVariant,
                    size: IconSizes.lg,
                  ),
                ],
              ),
              const SizedBox(height: Spacing.sm),
              Wrap(
                spacing: Spacing.xxs,
                runSpacing: Spacing.xxs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  EvaluationChip(status: form.status),
                  Text(
                    formattedEvalDate(form),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
