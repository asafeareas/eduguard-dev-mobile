import 'package:flutter/material.dart';

import '../../models/app_identity.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/auth/auth_view_model.dart';
import '../../widgets/app_avatar.dart';
import '../../widgets/app_card.dart';
import '../../widgets/inline_message.dart';
import '../../widgets/section_header.dart';

/// Perfil do professor autenticado, com opção de encerrar a sessão.
class ProfileView extends StatelessWidget {
  const ProfileView({super.key, required this.authViewModel});

  final AuthViewModel authViewModel;

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair da conta?'),
        content: const Text(
          'Suas turmas, frequências e notas continuam salvas neste dispositivo '
          'e estarão disponíveis no próximo login.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await authViewModel.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: authViewModel,
      builder: (context, _) {
        final teacher = authViewModel.teacher;
        final textTheme = Theme.of(context).textTheme;
        if (teacher == null) {
          return const Scaffold(body: SizedBox.shrink());
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Perfil')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.lg,
              AppSpacing.page,
              AppSpacing.xxl,
            ),
            children: [
              Center(
                child: AppAvatar(
                  initials: teacher.initials,
                  tone: AppTone.accent,
                  size: 88,
                  filled: true,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                teacher.name,
                textAlign: TextAlign.center,
                style: textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                teacher.title,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xxl),

              const SectionHeader(title: 'Conta'),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _ProfileRow(
                      icon: Icons.person_outline_rounded,
                      label: 'Nome',
                      value: teacher.name,
                    ),
                    const Divider(indent: 52),
                    _ProfileRow(
                      icon: Icons.mail_outline_rounded,
                      label: 'E-mail',
                      value: teacher.email,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const InlineMessage(
                tone: AppTone.info,
                message:
                    'Versão de demonstração: seus dados acadêmicos ficam salvos '
                    'apenas neste dispositivo e não são sincronizados entre aparelhos.',
              ),
              const SizedBox(height: AppSpacing.xxxl),

              OutlinedButton.icon(
                onPressed: authViewModel.isSigningOut
                    ? null
                    : () => _confirmSignOut(context),
                icon: const Icon(Icons.logout_rounded, size: AppSizes.iconMd),
                label: const Text('Sair da conta'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
                  side: BorderSide(
                    color: AppColors.danger.withValues(alpha: 0.4),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                '${AppIdentity.current.name} • Versão ${AppIdentity.current.version}',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md + 2,
      ),
      child: Row(
        children: [
          Icon(icon, size: AppSizes.iconMd, color: AppColors.textTertiary),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: textTheme.bodySmall),
                const SizedBox(height: AppSpacing.xxs),
                Text(value, style: textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
