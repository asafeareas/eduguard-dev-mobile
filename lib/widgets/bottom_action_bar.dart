import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'glass_surface.dart';

/// Barra inferior translúcida com resumo e ação principal da tela.
///
/// Projetada para ser usada com `Scaffold(extendBody: true)`, permitindo que
/// a lista role por trás do vidro.
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({
    super.key,
    required this.title,
    required this.status,
    required this.action,
    this.statusTone = AppTone.neutral,
  });

  final String title;
  final String status;
  final AppTone statusTone;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GlassSurface(
      border: const Border(top: BorderSide(color: AppColors.glassBorder)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.md,
            AppSpacing.page,
            AppSpacing.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.numeric(textTheme.titleSmall),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: statusTone.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs + 2),
                        Flexible(
                          child: Text(
                            status,
                            style: textTheme.bodySmall?.copyWith(
                              color: statusTone == AppTone.neutral
                                  ? AppColors.textSecondary
                                  : statusTone.color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              action,
            ],
          ),
        ),
      ),
    );
  }
}
