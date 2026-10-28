import 'package:flutter/material.dart';

import '../../models/app_identity.dart';
import '../../theme/app_theme.dart';
import '../../widgets/icon_tile.dart';

/// Estrutura comum às telas de login e cadastro: marca, título,
/// formulário centralizado e rodapé com ação secundária.
class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.form,
    required this.footer,
    this.showBack = false,
  });

  final String title;
  final String subtitle;
  final Widget form;
  final Widget footer;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const identity = AppIdentity.current;

    return Scaffold(
      appBar: showBack ? AppBar() : null,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.pagePadding(constraints.maxWidth),
                vertical: AppSpacing.xxl,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - AppSpacing.xxl * 2,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!showBack) ...[
                          const Center(
                            child: IconTile(
                              icon: Icons.shield_outlined,
                              size: 64,
                              filled: true,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            identity.name,
                            textAlign: TextAlign.center,
                            style: textTheme.labelMedium?.copyWith(
                              color: AppColors.accent,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                        ],
                        Text(
                          title,
                          textAlign: showBack
                              ? TextAlign.start
                              : TextAlign.center,
                          style: textTheme.headlineMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          subtitle,
                          textAlign: showBack
                              ? TextAlign.start
                              : TextAlign.center,
                          style: textTheme.bodyMedium,
                        ),
                        const SizedBox(height: AppSpacing.xxxl),
                        form,
                        const SizedBox(height: AppSpacing.xxl),
                        footer,
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Rodapé "Pergunta? Ação" das telas de autenticação.
class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    super.key,
    required this.question,
    required this.actionLabel,
    required this.onPressed,
  });

  final String question;
  final String actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(question, style: Theme.of(context).textTheme.bodyMedium),
        TextButton(onPressed: onPressed, child: Text(actionLabel)),
      ],
    );
  }
}

/// Conteúdo do botão principal com indicador de carregamento.
class SubmitButtonChild extends StatelessWidget {
  const SubmitButtonChild({
    super.key,
    required this.label,
    required this.isLoading,
  });

  final String label;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return Text(label);
    return const SizedBox(
      width: AppSizes.iconMd,
      height: AppSizes.iconMd,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        strokeCap: StrokeCap.round,
        color: AppColors.textSecondary,
      ),
    );
  }
}
