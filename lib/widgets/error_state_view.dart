import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'state_message_layout.dart';

/// Componente visual reutilizável para exibição de erros com opção de tentar novamente.
class ErrorStateView extends StatelessWidget {
  const ErrorStateView({
    super.key,
    this.title = 'Ops! Algo deu errado',
    required this.message,
    this.retryLabel = 'Tentar novamente',
    this.onRetry,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });

  final String title;
  final String message;
  final String retryLabel;
  final VoidCallback? onRetry;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    return StateMessageLayout(
      icon: Icons.error_outline_rounded,
      tone: AppTone.danger,
      title: title,
      message: message,
      primaryAction: onRetry != null
          ? FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: AppSizes.iconMd),
              label: Text(retryLabel),
            )
          : null,
      secondaryActionLabel: secondaryActionLabel,
      onSecondaryAction: onSecondaryAction,
    );
  }
}
