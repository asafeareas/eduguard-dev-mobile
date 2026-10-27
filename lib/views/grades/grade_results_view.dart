import 'package:flutter/material.dart';

import '../../models/grades/assessment.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/grades/grades_view_model.dart';
import '../../widgets/app_avatar.dart';
import '../../widgets/app_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/status_badge.dart';

/// Tela de consulta das notas salvas da turma, por avaliação e por estudante.
/// Ao tocar em "Editar" de uma avaliação, retorna seu id para a tela de lançamento.
class GradeResultsView extends StatelessWidget {
  const GradeResultsView({super.key, required this.viewModel});

  final GradesViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final vm = viewModel;
        final assessments = vm.assessments;
        final students = vm.allStudents;

        return Scaffold(
          appBar: AppBar(title: const Text('Resultados da Turma')),
          body: CustomScrollView(
            slivers: [
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.sm,
                  AppSpacing.page,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child: SectionHeader(title: 'Avaliações'),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.page,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final a = assessments[index];
                      return _AssessmentResultCard(
                        assessment: a,
                        savedCount: vm.savedCount(a.id),
                        totalCount: vm.totalStudentsCount,
                        average: vm.savedAverage(a.id),
                        onEdit: () => Navigator.of(context).pop(a.id),
                      );
                    },
                    childCount: assessments.length,
                  ),
                ),
              ),
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.xxl,
                  AppSpacing.page,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child: SectionHeader(
                    title: 'Notas por Estudante',
                    subtitle:
                        'Média ponderada na escala 0 a 10, considerando as avaliações com nota lançada.',
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  0,
                  AppSpacing.page,
                  AppSpacing.xxl,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final student = students[index];
                      final average = vm.weightedAverage(student.id);

                      return AppCard(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        padding: const EdgeInsets.all(AppSpacing.md + 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                AppAvatar(
                                  initials: student.initials,
                                  size: AppSizes.avatarSm,
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Text(
                                    student.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                StatusBadge(
                                  label:
                                      'Média ${average == null ? '—' : Assessment.formatScore(average)}',
                                  tone: AppTone.accent,
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Wrap(
                              spacing: AppSpacing.xs + 2,
                              runSpacing: AppSpacing.xs + 2,
                              children: assessments.map((a) {
                                final score = vm.savedScore(a.id, student.id);
                                return StatusBadge(
                                  label:
                                      '${a.title}: ${score == null ? '—' : '${Assessment.formatScore(score)}/${Assessment.formatScore(a.maxScore)}'}',
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: students.length,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AssessmentResultCard extends StatelessWidget {
  const _AssessmentResultCard({
    required this.assessment,
    required this.savedCount,
    required this.totalCount,
    required this.average,
    required this.onEdit,
  });

  final Assessment assessment;
  final int savedCount;
  final int totalCount;
  final double? average;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final a = assessment;

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md + 2,
        AppSpacing.sm,
        AppSpacing.md + 2,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.title, style: textTheme.titleSmall),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${a.type.label} • ${a.formattedDate} • Escala ${a.scaleLabel} • Peso ${Assessment.formatScore(a.weight)}',
                  style: textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '$savedCount de $totalCount notas • Média ${average == null ? '—' : Assessment.formatScore(average!)}',
                  style: AppTypography.numeric(textTheme.labelMedium).copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: AppSizes.iconSm),
            label: const Text('Editar'),
          ),
        ],
      ),
    );
  }
}
