import 'package:flutter/material.dart';

import '../models/academic/academic_class.dart';
import '../theme/app_theme.dart';
import 'app_card.dart';
import 'status_badge.dart';

/// Card reutilizável para exibição de turma cadastrada.
class ClassCard extends StatelessWidget {
  const ClassCard({
    super.key,
    required this.academicClass,
    this.onTap,
    this.onAttendanceTap,
    this.onGradesTap,
  });

  final AcademicClass academicClass;
  final VoidCallback? onTap;
  final VoidCallback? onAttendanceTap;
  final VoidCallback? onGradesTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Código e semestre
          Row(
            children: [
              StatusBadge(label: academicClass.code, tone: AppTone.accent),
              const Spacer(),
              Text(academicClass.semester, style: textTheme.labelMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Nome da turma e curso
          Text(
            academicClass.name,
            style: textTheme.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            academicClass.course,
            style: textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.md),

          // Metadados: alunos, turno, sala
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.xs,
            children: [
              _MetaItem(
                icon: Icons.people_alt_outlined,
                label: '${academicClass.studentsCount} alunos',
              ),
              _MetaItem(
                icon: Icons.schedule_rounded,
                label: academicClass.shift,
              ),
              _MetaItem(
                icon: Icons.meeting_room_outlined,
                label: academicClass.room,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.sm),

          // Rodapé: próxima aula + ações rápidas
          Row(
            children: [
              const Icon(
                Icons.circle,
                size: 7,
                color: AppColors.success,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  academicClass.nextClass,
                  style: textTheme.labelMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onAttendanceTap != null)
                _QuickAction(
                  tooltip: 'Fazer Chamada',
                  icon: Icons.fact_check_outlined,
                  onPressed: onAttendanceTap!,
                ),
              if (onGradesTap != null) ...[
                const SizedBox(width: AppSpacing.xs),
                _QuickAction(
                  tooltip: 'Notas da Turma',
                  icon: Icons.grade_outlined,
                  onPressed: onGradesTap!,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 200),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSizes.iconXs, color: AppColors.textTertiary),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, size: AppSizes.iconMd),
      style: IconButton.styleFrom(
        backgroundColor: AppColors.surfaceHighest,
        foregroundColor: AppColors.textPrimary,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.smAll),
      ),
    );
  }
}
