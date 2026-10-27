import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_card.dart';
import 'icon_tile.dart';
import 'status_badge.dart';

/// Botão/card reutilizável para acesso rápido a funcionalidades acadêmicas.
class AcademicFeatureButton extends StatelessWidget {
  const AcademicFeatureButton({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    this.badgeText,
    this.isPrimary = false,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  final String? badgeText;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md + 2,
      ),
      borderColor: isPrimary
          ? AppColors.accent.withValues(alpha: 0.35)
          : AppColors.border,
      child: Row(
        children: [
          IconTile(icon: icon, filled: isPrimary),
          const SizedBox(width: AppSpacing.md + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (badgeText != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      StatusBadge(label: badgeText!, tone: AppTone.accent),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  description,
                  style: textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }
}
