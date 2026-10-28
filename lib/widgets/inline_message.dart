import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Mensagem contextual exibida dentro de formulários e cards
/// (erros de envio, avisos, confirmações).
class InlineMessage extends StatelessWidget {
  const InlineMessage({
    super.key,
    required this.message,
    this.tone = AppTone.danger,
  });

  final String message;
  final AppTone tone;

  @override
  Widget build(BuildContext context) {
    final icon = switch (tone) {
      AppTone.success => Icons.check_circle_rounded,
      AppTone.warning => Icons.warning_amber_rounded,
      AppTone.danger => Icons.error_rounded,
      _ => Icons.info_rounded,
    };

    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: tone.background,
          borderRadius: AppRadius.mdAll,
          border: Border.all(color: tone.color.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: AppSizes.iconMd, color: tone.color),
            const SizedBox(width: AppSpacing.sm + 2),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
