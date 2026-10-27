import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Pílula compacta para status, contagens e metadados.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.tone = AppTone.neutral,
    this.icon,
    this.maxWidth,
  });

  final String label;
  final AppTone tone;
  final IconData? icon;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final color = tone.color;
    final textStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: tone == AppTone.neutral ? AppColors.textSecondary : color,
    );

    return Container(
      constraints: maxWidth == null
          ? null
          : BoxConstraints(maxWidth: maxWidth!),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: tone.background,
        borderRadius: AppRadius.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppSizes.iconXs - 1, color: textStyle?.color),
            const SizedBox(width: AppSpacing.xs),
          ],
          Flexible(
            child: Text(
              label,
              style: textStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
