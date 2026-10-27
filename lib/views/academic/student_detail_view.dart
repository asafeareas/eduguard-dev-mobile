import 'package:flutter/material.dart';

import '../../models/academic/academic_class.dart';
import '../../models/academic/student.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_avatar.dart';
import '../../widgets/app_card.dart';
import '../../widgets/metric_tile.dart';

class StudentDetailView extends StatelessWidget {
  const StudentDetailView({
    super.key,
    required this.student,
    required this.academicClass,
  });

  final Student student;
  final AcademicClass academicClass;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do estudante')),
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
              initials: student.initials,
              tone: AppTone.accent,
              size: 88,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            student.name,
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            academicClass.name,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Indicadores acadêmicos
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: MetricTile(
                      value: '${student.attendance}%',
                      label: 'Frequência',
                      alignment: CrossAxisAlignment.center,
                    ),
                  ),
                  const VerticalDivider(width: 1, color: AppColors.divider),
                  Expanded(
                    child: MetricTile(
                      value: student.averageGrade.toStringAsFixed(1),
                      label: 'Média atual',
                      tone: AppTone.accent,
                      alignment: CrossAxisAlignment.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Dados cadastrais em lista agrupada
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _DetailRow(
                  icon: Icons.badge_outlined,
                  label: 'Matrícula',
                  value: student.registration,
                ),
                const Divider(indent: 52),
                _DetailRow(
                  icon: Icons.mail_outline_rounded,
                  label: 'E-mail',
                  value: student.email,
                ),
                const Divider(indent: 52),
                _DetailRow(
                  icon: Icons.school_outlined,
                  label: 'Turma',
                  value: '${academicClass.code} • ${academicClass.semester}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
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
