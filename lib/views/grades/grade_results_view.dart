import 'package:flutter/material.dart';

import '../../models/grades/assessment.dart';
import '../../viewmodels/grades/grades_view_model.dart';

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
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final assessments = vm.assessments;
        final students = vm.allStudents;

        return Scaffold(
          appBar: AppBar(title: const Text('Resultados da Turma')),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Text(
                    'Avaliações',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final a = assessments[index];
                    final average = vm.savedAverage(a.id);
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Card(
                        elevation: 0,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: colorScheme.outlineVariant
                                .withValues(alpha: 0.5),
                          ),
                        ),
                        child: ListTile(
                          title: Text(a.title),
                          subtitle: Text(
                            '${a.type.label} • ${a.formattedDate} • Escala ${a.scaleLabel} • Peso ${Assessment.formatScore(a.weight)}\n'
                            '${vm.savedCount(a.id)} de ${vm.totalStudentsCount} notas • Média ${average == null ? '—' : Assessment.formatScore(average)}',
                          ),
                          isThreeLine: true,
                          trailing: TextButton.icon(
                            onPressed: () => Navigator.of(context).pop(a.id),
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: const Text('Editar'),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: assessments.length,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text(
                    'Notas por Estudante',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    'Média ponderada na escala 0 a 10, considerando as avaliações com nota lançada.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final student = students[index];
                      final average = vm.weightedAverage(student.id);
                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: colorScheme.outlineVariant
                                .withValues(alpha: 0.5),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      student.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Média ${average == null ? '—' : Assessment.formatScore(average)}',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: assessments.map((a) {
                                  final score =
                                      vm.savedScore(a.id, student.id);
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.surfaceContainerHighest
                                          .withValues(alpha: 0.4),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${a.title}: ${score == null ? '—' : '${Assessment.formatScore(score)}/${Assessment.formatScore(a.maxScore)}'}',
                                      style: theme.textTheme.labelSmall,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
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
