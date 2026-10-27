import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Exibe um aviso flutuante padronizado com ícone semântico.
void showAppSnackBar(
  BuildContext context,
  String message, {
  AppTone tone = AppTone.neutral,
}) {
  final icon = switch (tone) {
    AppTone.success => Icons.check_circle_rounded,
    AppTone.warning => Icons.warning_amber_rounded,
    AppTone.danger => Icons.error_rounded,
    _ => Icons.info_rounded,
  };

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              icon,
              size: AppSizes.iconMd,
              color: tone == AppTone.neutral ? AppColors.accent : tone.color,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
}
