import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'icon_tile.dart';

/// Layout compartilhado pelos estados vazio e de erro: ícone tonal,
/// título, mensagem e até duas ações.
class StateMessageLayout extends StatelessWidget {
  const StateMessageLayout({
    super.key,
    required this.icon,
    required this.tone,
    required this.title,
    required this.message,
    this.primaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });

  final IconData icon;
  final AppTone tone;
  final String title;
  final String message;
  final Widget? primaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxxl,
          vertical: AppSpacing.xxxl,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconTile(icon: icon, tone: tone, size: 64),
              const SizedBox(height: AppSpacing.xl),
              Text(
                title,
                textAlign: TextAlign.center,
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium,
              ),
              if (primaryAction != null) ...[
                const SizedBox(height: AppSpacing.xxl),
                primaryAction!,
              ],
              if (secondaryActionLabel != null && onSecondaryAction != null) ...[
                const SizedBox(height: AppSpacing.xs),
                TextButton(
                  onPressed: onSecondaryAction,
                  child: Text(secondaryActionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
