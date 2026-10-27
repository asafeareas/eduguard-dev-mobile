import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Par valor + rótulo usado em resumos numéricos dentro de cards.
class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    required this.value,
    required this.label,
    this.tone = AppTone.neutral,
    this.alignment = CrossAxisAlignment.start,
  });

  final String value;
  final String label;
  final AppTone tone;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.numeric(textTheme.titleLarge).copyWith(
            color: tone == AppTone.neutral ? AppColors.textPrimary : tone.color,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.labelMedium,
        ),
      ],
    );
  }
}
