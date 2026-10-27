import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'state_message_layout.dart';

/// Componente visual reutilizável para exibir estado vazio (sem turmas / sem dados).
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    this.icon = Icons.folder_open_outlined,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onActionPressed,
    this.actionIcon = Icons.add_rounded,
    this.secondaryActionLabel,
    this.onSecondaryActionPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final IconData actionIcon;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryActionPressed;

  @override
  Widget build(BuildContext context) {
    return StateMessageLayout(
      icon: icon,
      tone: AppTone.neutral,
      title: title,
      message: message,
      primaryAction: actionLabel != null && onActionPressed != null
          ? FilledButton.icon(
              onPressed: onActionPressed,
              icon: Icon(actionIcon, size: AppSizes.iconMd),
              label: Text(actionLabel!),
            )
          : null,
      secondaryActionLabel: secondaryActionLabel,
      onSecondaryAction: onSecondaryActionPressed,
    );
  }
}
